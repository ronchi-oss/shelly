__shelly_command__test__help() {
    echo 'Usage: shell test [<target>]'
    echo
    echo 'test will run all test cases under the test/ directory.'
    echo
    echo 'Arguments:'
    echo
    printf '\t%-10s %s\n' 'target' 'The target to be built and sourced with every test case run (defaults to "main")'
}

__shelly_command__test() {
    exit_status=0

    exit_statuses_file=$(mktemp)
    readonly exit_statuses_file
    trap 'rm $exit_statuses_file' EXIT

    bundle_file=$(mktemp)
    readonly bundle_file
    trap 'rm $bundle_file' EXIT
    __shelly_command__build "$1" > "$bundle_file"
    if test $? -ne 0; then
        echo "error: could not bundle project." >&2
        exit 1
    fi

    test_files=$(mktemp)
    readonly test_files
    trap 'rm $test_files' EXIT
    find test -name '*.sh' > "$test_files"

    echo "Running tests..."
    echo

    while read -r test_file; do
        functions="$(grep '^test_.*() {$' "$test_file" | sed 's/() {$//')"
        for fn_name in $functions; do
            fn_log_file=$(mktemp)
            # shellcheck disable=SC2064
            trap "rm $fn_log_file" EXIT
            /bin/sh -x -c ". $bundle_file && . $test_file && $fn_name" > "$fn_log_file" 2>&1
            status="$?"
            echo "${fn_log_file}:${fn_name}:${status}" >> "$exit_statuses_file"
            test -t 1 ; is_tty=$?
            case "$status" in
                0) printf '%s' "$(echo '.' | __shelly_colorize "$is_tty" pass)" ;;
                *) printf '%s' "$(echo 'F' | __shelly_colorize "$is_tty" fail)" ;;
            esac
        done
    done < "$test_files"

    echo ; echo

    while IFS=: read -r fn_log_file fn_name status; do
        if test "$status" -ne 0; then
            exit_status="$status"
            echo "Function $fn_name exited with status code $status" | __shelly_colorize "$is_tty" fail
            cat "$fn_log_file"
            echo
        fi
    done < "$exit_statuses_file"

    count_passed="$(grep -c ':0$' "$exit_statuses_file")"
    count_failed="$(grep -c ':1$' "$exit_statuses_file")"
    readonly count_passed count_failed
    printf '%s, %s, %s.\n' \
        "$(echo "${count_passed} passed" | __shelly_colorize "$is_tty" pass)" \
        "$(echo "${count_failed} failed" | __shelly_colorize "$is_tty" fail)" \
        "$(echo "0 skipped" | __shelly_colorize "$is_tty" skip)"

    exit "$exit_status"
}

__shelly_colorize() {
    while read -r line; do
        if ! test "$1" -eq 0; then
            echo "$line"
        else
            case "$2" in
                fail) color=31 ;;
                pass) color=32 ;;
                skip) color=33 ;;
            esac
            printf "\033[%s;1m%s\033[0m\n" "$color" "$line"
        fi
    done
}
