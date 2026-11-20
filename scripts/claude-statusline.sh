#!/usr/bin/env bash
# Claude Code status line for this repo (`statusLine` in .claude/settings.json).
# Reads the status-line JSON on stdin and prints two lines:
#   model · context bar · prompt-cache countdown · spend
#   5-hour, weekly and per-model weekly plan-limit bars
#
# Spend shows only money that is billed. A subscriber pays a flat fee until a
# plan limit runs out, so a subscriber session shows the extra usage billed this
# period, and only once it is above zero. An API-key session pays for every
# token, so it shows Claude Code's list-price session cost.
#
# Per-model weekly limits (for example Fable) and extra usage are not in the
# status-line input. For a subscriber session, the script reads the Claude Code
# OAuth token (macOS keychain, else ~/.claude/.credentials.json) and calls the
# usage endpoint that Claude Code's /usage reads. It refreshes in the background
# at most once a minute and caches only the `limits` and `extra_usage` fields.
# The endpoint is undocumented, so any failure hides those items and nothing
# else.
#
# Env:
#   SOLA_STATUSLINE_USAGE      set to "off" to skip the usage-endpoint call
#   SOLA_STATUSLINE_USAGE_CACHE usage cache file (default ~/.claude/sola-statusline/usage.json)
#   SOLA_STATUSLINE_USAGE_SYNC refresh the usage cache in the foreground (tests)
#   SOLA_STATUSLINE_NOW        Unix seconds to treat as now (tests)
#   NO_COLOR                   disable ANSI colors when set
set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "status line needs jq (brew install jq)"
  exit 0
fi

input=$(cat)
now="${SOLA_STATUSLINE_NOW:-$(date +%s)}"

usage_cache="${SOLA_STATUSLINE_USAGE_CACHE:-$HOME/.claude/sola-statusline/usage.json}"

read_oauth_token() {
  local creds=""
  if command -v security >/dev/null 2>&1; then
    creds=$(security find-generic-password -s 'Claude Code-credentials' -w 2>/dev/null)
  fi
  if [ -z "$creds" ] && [ -r "$HOME/.claude/.credentials.json" ]; then
    creds=$(cat "$HOME/.claude/.credentials.json")
  fi
  jq -r '.claudeAiOauth.accessToken // empty' <<<"$creds" 2>/dev/null
}

refresh_usage() {
  local token body tmp="$usage_cache.$$"
  token=$(read_oauth_token)
  [ -n "$token" ] || return 0
  # The header goes through a curl config on stdin, so the token is not in argv.
  body=$(printf 'header = "Authorization: Bearer %s"\n' "$token" |
    curl -sS -m 5 -K - -H 'anthropic-beta: oauth-2025-04-20' https://api.anthropic.com/api/oauth/usage 2>/dev/null) || return 0
  if jq -e --argjson now "$now" '{fetched_at: $now, limits: (.limits | arrays), extra_usage: ((.extra_usage | objects) // null)}' <<<"$body" >"$tmp" 2>/dev/null; then
    mv -f "$tmp" "$usage_cache"
  fi
  rm -f "$tmp"
}

is_subscriber=$(jq -r 'if .rate_limits.five_hour or .rate_limits.seven_day then 1 else 0 end' <<<"$input" 2>/dev/null)
use_usage=0
[ "${SOLA_STATUSLINE_USAGE:-}" != "off" ] && [ "$is_subscriber" = 1 ] && use_usage=1

# The last attempt, successful or not, sets the pace, so a failing endpoint is
# also called at most once a minute.
attempt_file="$usage_cache.attempt"
attempted_at=$(cat "$attempt_file" 2>/dev/null || echo 0)
case "$attempted_at" in '' | *[!0-9]*) attempted_at=0 ;; esac
if [ "$use_usage" = 1 ] && [ $((now - attempted_at)) -ge 60 ] &&
  mkdir -p "$(dirname "$usage_cache")" 2>/dev/null; then
  lock="$usage_cache.lock"
  # A lock left by a killed refresh expires after 30 s.
  if [ -d "$lock" ] && [ $((now - $(cat "$lock/at" 2>/dev/null || echo 0))) -ge 30 ]; then
    rm -rf "$lock"
  fi
  if mkdir "$lock" 2>/dev/null; then
    echo "$now" >"$lock/at"
    echo "$now" >"$attempt_file"
    if [ -n "${SOLA_STATUSLINE_USAGE_SYNC:-}" ]; then
      refresh_usage
      rm -rf "$lock"
    else
      (refresh_usage; rm -rf "$lock") >/dev/null 2>&1 </dev/null &
    fi
  fi
fi

# Usage older than 10 minutes is not shown. The cache is shared by every
# session, so a session that does not fetch usage does not show it either.
usage='{}'
if [ "$use_usage" = 1 ]; then
  usage=$(jq -c --argjson now "$now" 'if (.fetched_at // 0) >= $now - 600 then {limits, extra_usage} else {} end' "$usage_cache" 2>/dev/null)
  [ -n "$usage" ] || usage='{}'
fi

# Each kind of information has its own color: model magenta, context and cache
# blue, plan limits bold, spend green. A bar turns yellow at 50% of a limit and
# red at 80%. The cache pie empties as its TTL runs out and turns yellow at
# 5 min left and red at 1 min.
jq -r \
  --argjson now "$now" \
  --argjson usage "$usage" \
  --arg color "$([ -z "${NO_COLOR:-}" ] && echo 1)" \
  '
  def paint($code): if $color == "1" then "\u001b[\($code)m\(.)\u001b[0m" else . end;
  def dim: paint("2");
  def warn($pct): if $pct >= 80 then paint("1;31") elif $pct >= 50 then paint("1;33") else . end;
  def pct: "\(. | round)%";
  def tokens: if . >= 1000000 then "\(. / 100000 | floor / 10)M" elif . >= 1000 then "\(. / 1000 | round)K" else "\(.)" end;
  def pad2: tostring | if length < 2 then "0" + . else . end;
  def usd: if . >= 100 then "$\(round)" else (. * 100 | round) as $c | "$\($c / 100 | floor).\($c % 100 | pad2)" end;
  def resets: (. - $now) | if . <= 0 then "resets now"
    elif . >= 86400 then "resets \(. / 86400 | floor)d \(. % 86400 / 3600 | floor)h"
    elif . >= 3600 then "resets \(. / 3600 | floor)h \(. % 3600 / 60 | floor)m"
    else "resets \(. / 60 | floor)m" end;
  def clock: floor | "\(. / 60 | floor):\(. % 60 | pad2)";
  def iso_epoch: sub("\\.[0-9]+"; "") | sub("(\\+00:00|Z)$"; "Z") | try fromdateiso8601 catch null;
  def capitalized: (.[:1] | ascii_upcase) + .[1:];
  def minor_units($currency; $places): . / pow(10; $places) | if ($currency // "USD" | ascii_upcase) == "USD" then usd
    else "\(. * 100 | round / 100) \($currency | ascii_upcase)" end;

  def model: paint("1;35");
  def context: paint("34");
  def cache: paint("34");
  def limit: paint("1");
  def spend: paint("32");

  def level_code($p; $code): if $p >= 80 then "1;31" elif $p >= 50 then "1;33" else $code end;
  def cells($p; $code): ($p / 10 | round | if . > 10 then 10 elif . < 0 then 0 else . end) as $n
    | ([range($n)] | map("▰") | join("") | paint($code)) + ([range(10 - $n)] | map("▱") | join("") | dim);
  def gauge($p; $code): level_code($p; $code) as $c | cells($p; $c) + " " + ($p | pct | paint($c));

  def plan_limit($name): .used_percentage as $p
    | ($name | limit) + " " + gauge($p; "1") + " " + ("(" + (.resets_at | resets) + ")" | dim);

  . as $in
  | [
    [
      ($in.model.display_name // $in.model.id // empty | model),

      ($in.context_window
        | select(.used_percentage != null)
        | ("Context" | context) + " " + gauge(.used_percentage; "34")
          + " " + ("(" + (.total_input_tokens | tokens) + " of " + (.context_window_size | tokens) + ")" | dim)),

      ($in.prompt_cache // empty
        | select(.caching_observed == true)
        | ("Cache" | cache) + " " +
          if .warm == true and .expires_at != null and .expires_at > $now
          then (.expires_at - $now) as $left
            | (if .ttl == "1h" then 3600 else 300 end) as $ttl
            | (if $left < 60 then "1;31" elif $left < 300 then "1;33" else "34" end) as $c
            | ($left * 100 / $ttl) as $share
            | (if $share > 87.5 then "●" elif $share > 62.5 then "◕" elif $share > 37.5 then "◑" elif $share > 12.5 then "◔" else "○" end)
              + " " + ($left | clock) | paint($c)
          else "○ expired" | dim end),

      (if $in.rate_limits.five_hour or $in.rate_limits.seven_day
        then ($usage.extra_usage // empty
          | select((.used_credits | type) == "number" and .used_credits > 0)
          | .currency as $cur | (.decimal_places // 2) as $places
          | (.utilization // (if (.monthly_limit | type) == "number" and .monthly_limit > 0
              then .used_credits * 100 / .monthly_limit else 0 end)) as $u
          | ("Extra usage" | spend) + " "
            + ((.used_credits | minor_units($cur; $places))
              + (if (.monthly_limit | type) == "number" then " of " + (.monthly_limit | minor_units($cur; $places)) else "" end)
              | warn($u)))
        else ($in.cost.total_cost_usd // empty | ("Session" | spend) + " " + usd) end)
    ],
    [
      ($in.rate_limits.five_hour // empty | plan_limit("5-hour")),

      ($in.rate_limits.seven_day // empty | plan_limit("Weekly")),

      ($usage.limits[]?
        | select(.kind == "weekly_scoped" and (.scope.model.display_name | type) == "string" and (.percent | type) == "number")
        | {used_percentage: .percent, resets_at: (.resets_at | iso_epoch), name: .scope.model.display_name}
        | select(.resets_at != null and .resets_at > $now)
        | plan_limit(.name)),

      ($in.rate_limits.spend_limit // empty
        | ((if .period then (.period | capitalized) + " spend" else "Spend" end) | limit) + " "
          + ((if .used_usd != null then (.used_usd | usd) + " of " + (.limit_usd | usd) else (.used_percentage | pct) end)
            | warn($in.rate_limits.spend_limit.used_percentage)))
    ]
  ]
  | map(join(" · " | dim) | select(. != ""))
  | join("\n")
  ' <<<"$input" 2>/dev/null || echo "status line: unreadable input"
