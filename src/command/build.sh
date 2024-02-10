__shelly_command__build__help() {
    echo 'Usage: shelly build [-s] [<target>]'
    echo
    echo 'build builds a target and writes the result to standard output.'
    echo
    echo 'Arguments:'
    echo
    printf '\t%-10s %s\n' 'target' 'The target to be built (defaults to "main")'
    echo
    echo 'Available options:'
    echo
    printf '\t%-10s %s\n' '-s' 'If set, the POSIX she bang line will be included'
}

__shelly_command__build() {
    if ! test -r .shelly/shelly.sh; then
        echo "error: .shelly/shelly.sh not found." >&2
        exit 1
    fi

    . .shelly/shelly.sh

    OPTIND=1
    while getopts s option "$@"; do
        case "$option" in
            s) with_shebang=1 ;;
            *) ;;
        esac
    done

    shift $((OPTIND - 1))

    build_target_fn="__shelly_build_target__${1:-main}"
    line="$(type "$build_target_fn" 2>/dev/null | head -n 1)"
    if test "${line##* }" != 'function'; then
        echo "error: function $build_target_fn is not defined." >&2
        exit 1
    fi

    build_file=$(mktemp) ; trap 'rm $build_file' EXIT
    if test -n "$with_shebang"; then
        echo '#!/bin/sh' > "$build_file"
    fi
    if test -r LICENSE; then
        while read -r line; do
            if test "${#line}" -eq 0; then
                echo "#"
            else
                echo "# $line"
            fi
        done < LICENSE >> "$build_file"
    fi
    "$build_target_fn" \
        | while read -r path; do
              cat "$path"
          done \
        | sed '/^$/d' >> "$build_file"
    if test -n "$with_shebang"; then
        echo 'main "$@"' >> "$build_file"
    fi
    cat "$build_file"
}
