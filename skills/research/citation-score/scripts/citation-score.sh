#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# citation-score: how much of a text is cited, approximately. It splits the text into sentences
# and counts those that carry a citation mark: a pandoc key ([@smith2016]), a DOI, a URL or a
# Markdown link, a wiki link ([[note]]), a footnote ([^1]), a numbered reference ([12]), an author-year ((Nash, 1955);
# Nash 1955) or a "Source:" line. The score is cited sentences over all sentences. It cannot know
# if a citation is right, or if an uncited sentence needs one: it counts marks, no more.
# The owner set the two ends of the scale (Hoffmann, 13 October 2026): 100% is "PERFECT. HIGHEST
# MATURITY LEVEL." and 0% is "POOR. 2 DIGIT IQ."
#   scripts/citation-score.sh "a phrase or a longer text"
#   scripts/citation-score.sh path/to/file.md
#   scripts/citation-score.sh https://example.org/page
#   some-command | scripts/citation-score.sh -
#   --color=always|never (default: colour on a terminal; NO_COLOR turns it off)   --list=N uncited sentences shown (default 5)
#   --tsv: percent, cited, total and verdict on one line, tab-separated
#   scripts/citation-score.sh --self-test
set -euo pipefail

color=auto list=5 input="" format=text
for a in "$@"; do
  case "$a" in
    --color=*) color="${a#--color=}" ;;
    --list=*) list="${a#--list=}" ;;
    --tsv) format=tsv ;;
    --self-test) input=--self-test ;;
    *) input="$a" ;;
  esac
done

# Text on stdin -> one line per sentence, prefixed "1\t" when it carries a citation mark, else "0\t".
sentences() {
  perl -CSD -0777 -ne '
    s/\A---\n.*?\n---\n//s;                       # front matter
    s/```.*?```//gs; s/<!--.*?-->//gs;            # code blocks, comments
    s/<(script|style)\b.*?<\/\1>//gis;            # a web page: scripts and styles
    s/<a\b[^>]*\bhref="(https?:\/\/[^"]+)"[^>]*>/ $1 /gi;   # a link is a citation mark
    s/<[^>]+>/ /g; s/&nbsp;/ /g; s/&amp;/&/g;
    s/^\s*#+\s.*$//mg; s/^\s*\|?[-: |]+\|?\s*$//mg;         # headings, table rules
    s/^\s*(?:[-*+]|\d+\.)\s+/\n\n/mg;                       # each list item is its own unit
    my @units = split /\n\s*\n|(?<=[.!?])["\x{201d})\]]?\s+(?=[\p{Lu}\p{Ll}\x{201c}"(\[*_`])/, $_;
    for my $u (@units) {
      $u =~ s/\s+/ /g; $u =~ s/^ | $//g;
      my $words = () = $u =~ /[\p{L}\p{N}]+/g;
      next if $words < 3;
      my $cited = ($u =~ /\[\@[^\]]+\]|(?<![\w.])\@[A-Za-z][\w:.-]*\d{2}/
        || $u =~ /\b10\.\d{4,9}\/\S+/ || $u =~ /https?:\/\// || $u =~ /\]\([^)\s]+\)/
        || $u =~ /\[\^[^\]]+\]/ || $u =~ /\[\[[^\]]+\]\]/ || $u =~ /\[\d{1,3}(?:\s*[,\x{2013}-]\s*\d{1,3})*\]/
        || $u =~ /\(\p{Lu}[^()]{1,80}?,?\s(?:1[5-9]|20)\d{2}[a-z]?(?:[,;][^()]*)?\)/
        || $u =~ /\b\p{Lu}[\p{L}-]+(?:\s+et al\.?|\s+(?:and|e|&)\s+\p{Lu}[\p{L}-]+)?,?\s+\(?(?:1[5-9]|20)\d{2}[a-z]?\)?/
        || $u =~ /^\*{0,2}(?:Source|Sources|Fonte|Fontes)\b\*{0,2}\s*:/i) ? 1 : 0;
      print "$cited\t$u\n";
    }'
}

paint() { # paint <sgr> <text>
  if [ "$color" = always ] || { [ "$color" = auto ] && [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; }; then
    printf '\033[%sm%s\033[0m' "$1" "$2"
  else
    printf '%s' "$2"
  fi
}

# verdict <percent> -> "<sgr>\t<label>"
verdict() {
  local p="$1"
  if [ "$p" -ge 100 ]; then printf '1;32\tPERFECT. HIGHEST MATURITY LEVEL.'
  elif [ "$p" -ge 75 ]; then printf '32\tSTRONG. Almost every sentence stands on a source.'
  elif [ "$p" -ge 50 ]; then printf '33\tFAIR. Half of it stands on a source; the rest is yours, or unsupported.'
  elif [ "$p" -ge 25 ]; then printf '33\tTHIN. Most of it is yours, or unsupported.'
  elif [ "$p" -ge 1 ]; then printf '31\tWEAK. Nearly all of it is yours, or unsupported.'
  else printf '1;31\tPOOR. 2 DIGIT IQ.'
  fi
}

report() { # scored sentences on stdin
  local scored total cited pct sgr label filled bar_on bar_off
  scored="$(cat)"
  total="$(grep -c . <<<"$scored" || true)"
  [ "$total" -gt 0 ] || { echo "citation-score: no sentence of three words or more to score" >&2; exit 1; }
  cited="$(grep -c '^1' <<<"$scored" || true)"
  pct=$(( (cited * 100 + total / 2) / total ))
  IFS=$'\t' read -r sgr label <<<"$(verdict "$pct")"
  filled=$(( pct / 5 ))
  bar_on="$(printf '%*s' "$filled" '' | sed 's/ /█/g')"
  bar_off="$(printf '%*s' $(( 20 - filled )) '' | sed 's/ /░/g')"
  printf 'citation score  '; paint "$sgr" "$bar_on"; printf '%s  ' "$bar_off"; paint "$sgr" "$pct% cited"; printf '\n'
  printf '                '; paint "$sgr" "$label"; printf '\n'
  printf '                %s of %s sentences carry a citation mark; %s%% is original, or unsupported.\n' "$cited" "$total" "$(( 100 - pct ))"
  if [ "$list" -gt 0 ] && [ "$cited" -lt "$total" ]; then
    printf 'no citation mark:\n'
    grep '^0' <<<"$scored" | head -n "$list" | cut -f2 | cut -c1-110 | while IFS= read -r s; do printf '  '; paint 31 '✗'; printf ' %s\n' "$s"; done
    [ $(( total - cited )) -le "$list" ] || printf '  … and %s more\n' $(( total - cited - list ))
  fi
}

# --tsv: "percent<TAB>cited<TAB>total<TAB>verdict" and nothing else, for scripts/citation-board.sh.
tsv() {
  local scored total cited pct
  scored="$(cat)"
  total="$(grep -c . <<<"$scored" || true)"
  cited="$(grep -c '^1' <<<"$scored" || true)"
  [ "$total" -gt 0 ] || { echo "citation-score: no sentence of three words or more to score" >&2; exit 1; }
  pct=$(( (cited * 100 + total / 2) / total ))
  printf '%s\t%s\t%s\t%s\n' "$pct" "$cited" "$total" "$(verdict "$pct" | cut -f2)"
}
if [ "$format" = tsv ]; then report() { tsv; }; fi

case "$input" in
  --self-test)
    fail() { echo "citation-score: self-test: $*" >&2; exit 1; }
    s() { printf '%s' "$1" | sentences | cut -f1 | tr -d '\n'; }
    [ "$(s 'Openness scales, as Linux shows [@raymond1999]. I think so too, for my own reasons.')" = 10 ] || fail "pandoc key: $(s 'Openness scales, as Linux shows [@raymond1999]. I think so too, for my own reasons.')"
    [ "$(s 'See the record at 10.5281/zenodo.23333656 for the text. Read it at https://example.org/x today. It is [here](docs/a.md) in full.')" = 111 ] || fail "DOI, URL, link"
    [ "$(s 'Nash wrote to the NSA (Nash, 1955). Smith et al. 2016 set the principles. Codes fail when keys leak [12]. A footnote helps here.[^3]')" = 1111 ] || fail "author-year, number, footnote: $(s 'Nash wrote to the NSA (Nash, 1955). Smith et al. 2016 set the principles. Codes fail when keys leak [12]. A footnote helps here.[^3]')"
    [ "$(s 'This is my own idea. Nobody told me this at all. It came to me in 2026 on a walk.')" = 000 ] || fail "an uncited sentence was counted: $(s 'This is my own idea. Nobody told me this at all. It came to me in 2026 on a walk.')"
    [ "$(s $'# A Heading (Nash, 1955)\n\n```\nsee https://x.org now\n```\n\nok.')" = "" ] || fail "a heading, a code block or a two-word line was scored"
    [ "$(s '<p>Read <a href="https://example.org/a">this page</a> first.</p><script>var a = "x y z w";</script>')" = 1 ] || fail "html"
    [ "$(s 'The idea is in [[202610130000-rea-for-forecast-models]] and nowhere else.')" = 1 ] || fail "wiki link"
    [ "$(verdict 100 | cut -f2)" = "PERFECT. HIGHEST MATURITY LEVEL." ] || fail "100"
    [ "$(verdict 0 | cut -f2)" = "POOR. 2 DIGIT IQ." ] || fail "0"
    out="$(printf 'One cited sentence here [@a2020]. One sentence of my own.' | sentences | color=never report)"
    grep -q '50% cited' <<<"$out" || fail "report: $out"
    [ "$(printf 'One cited sentence here [@a2020]. One sentence of my own.' | sentences | tsv | cut -f1-3)" = $'50\t1\t2' ] || fail "tsv"
    echo "citation-score: self-test ok" >&2
    ;;
  "") echo "citation-score: usage: scripts/citation-score.sh [--color=always|never] [--list=N] <text | file | URL | ->" >&2; exit 1 ;;
  -) sentences | report ;;
  http://* | https://*) curl -fsSL --max-time 30 -A citation-score "$input" | sentences | report ;;
  *)
    if [ -f "$input" ]; then sentences <"$input" | report; else printf '%s' "$input" | sentences | report; fi
    ;;
esac
