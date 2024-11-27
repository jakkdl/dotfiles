# convert pyright json output into the exact textual pyright output, but with
# relative paths instead of absolute.
#
# usage:
#     pyright --outputjson | jq -r -f pyright.jq --arg cwd "$(pwd)"
#
# Pyright will only ever output absolute paths, which doesn't map very well
# from docker path to host filesystem, making this conversion necessary.
# The output produced is byte-for-byte the same as what pyright outputs
# normally, with only the file paths changed.

def relpath(base): . | ltrimstr(base);

# ANSI sequences for colour output
def _ansi($c): tostring | "\u001b[\($c)m\(.)\u001b[39m";
def red:    _ansi(31);
def yellow: _ansi(33);
def blue:   _ansi(34);
def cyan:   _ansi(36);
def gray:   _ansi(90);

# diagnostic formatting based on
# https://github.com/microsoft/pyright/blob/72c1e7cfb7ca2dc57db06b3e6d80131c19d4892f/packages/pyright-internal/src/pyright.ts#L1276-L1309
def indent(prefix): prefix + gsub("\n"; "\n\(prefix)");

def styled_severity:
    if . == "error" then
        red
    elif . == "warning" then
        cyan
    else
        blue
    end;

def format_range: 
    if [.start[], .end[]] | any(. != 0) then
        "\(.start.line + 1 | yellow):\(.start.character + 1 | yellow) -"
    else
        ""
    end;

def format_rule:
    if . then
        " (\(.))" | gray
    else
        ""
    end;

def format_diagnostic(prefix):
    "\(.file):\(.range | format_range) \(.severity | styled_severity): \(.message)\(.rule | format_rule)"
    | indent(prefix);

def format_diagnostic: format_diagnostic("  ");

# summary format based on
# https://github.com/microsoft/pyright/blob/72c1e7cfb7ca2dc57db06b3e6d80131c19d4892f/packages/pyright-internal/src/pyright.ts#L1262-L1266
def plural: if . != 1 then "s" else "" end;
def stat(name): "\(.) \(name)\(plural)";
def format_summary:
    "\(.errorCount | stat("error")), \(.warningCount | stat("warning")), \(.informationCount | stat("information")) ";

(if $cwd | endswith("/") | not then $cwd + "/" else . end) as $prefix
| [
  (
    .generalDiagnostics
    | .[].file |= relpath($prefix)  # make file paths relative if within $prefix
    | group_by(.file)[]
    | "\(.[0].file)", (.[] | format_diagnostic)
  ),
  (.summary | format_summary)
]
| join("\n")
