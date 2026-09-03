#!/bin/sh
# Content gate for the public export: fail if any internal reference survives
# in the text that ships with the package. Run from the package root.

status=0

files="README.md CHANGELOG.md .project.json"
for f in ros2_sysmlv2/*.sysml; do
    files="$files $f"
done

report() {
    echo "$2" | sed "s|^|$1:|"
    status=1
}

scan_one() {
    # $1 = extra grep flags, $2 = pattern, $3 = file list
    flags=$1
    pat=$2
    for f in $3; do
        [ -f "$f" ] || continue
        out=$(grep -n $flags -E -- "$pat" "$f" 2>/dev/null)
        [ -n "$out" ] && report "$f" "$out"
        jout=$(tr '\n' ' ' < "$f" | tr -s ' \t' ' ' | grep -o $flags -E -- "$pat" 2>/dev/null)
        [ -n "$jout" ] && report "$f" "joined: $jout"
    done
}

# ------------------------------------------------------------------
# case-insensitive patterns
while IFS= read -r p; do
    [ -n "$p" ] || continue
    scan_one -i "$p" "$files"
done <<'PATS'
bridge pipeline
the bridge
generate_ros2
extract_architecture
architecture\.json
run_demo
regen_demos
docs/
references/
tests/
tools/
demos/
bridge/
debug/
analysis/
ros2-py-outputs
ros2-cpp
Phases? [0-9]
workstation
session
handover
implementation_log
implog
Architecture-as-Code
PATS

# ------------------------------------------------------------------
# case-sensitive patterns
while IFS= read -r p; do
    [ -n "$p" ] || continue
    scan_one "" "$p" "$files"
done <<'PATS'
(^|[^A-Za-z0-9])W[0-9][0-9]([^A-Za-z0-9]|$)
E7 qos_policies
/Users/
/home/
/mnt/
garbage_
IDDMBSE
PERFECT
TRADES-X
VERITAS
Claude
Anthropic
github\.com/sdamera/
sdamera95/Architecture
PATS

# ------------------------------------------------------------------
# CHANGELOG.md carries release dates, so the internal-date pattern skips it
nodate_files=$(echo "$files" | tr ' ' '\n' | grep -v '^CHANGELOG.md$' | tr '\n' ' ')
scan_one "" '2026-[0-9]{2}-[0-9]{2}' "$nodate_files"

# ------------------------------------------------------------------
# .meta.json carries a legitimate created timestamp, so only paths are checked
while IFS= read -r p; do
    [ -n "$p" ] || continue
    scan_one "" "$p" ".meta.json"
done <<'PATS'
/Users/
/home/
/mnt/
docs/
references/
PATS

if [ "$status" -eq 0 ]; then
    echo clean
fi
exit $status
