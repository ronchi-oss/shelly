__shelly_command__shellcheck__help() {
    echo 'Usage: shelly shellcheck'
    echo
    echo 'shellcheck runs shellcheck across all project shell source code.'
}

__shelly_command__shellcheck() {
    tmp=$(mktemp) ; trap 'rm $tmp' EXIT
    exit_status=0

    ( find .shelly/* ; test -d bin && find bin/* ; find src -name '*.sh') > "$tmp"

    while read -r path; do
        shellcheck -x --shell sh "$path"
        test $? -ne 0 && exit_status=1
    done < "$tmp"

    find src -name '*.bash' > "$tmp"

    while read -r path; do
        shellcheck --shell bash "$path"
        test $? -ne 0 && exit_status=1
    done < "$tmp"

    exit "$exit_status"
}
