__shelly_command__help() {
    exit_status=0
    if test "$1" -gt 0; then
        exec >&2
        exit_status="$1"
    fi
    case "$2" in
        build|install|shellcheck|test|version) "__shelly_command__${2}__help" ;;
        *)
            if test -n "$2"; then
                echo "shelly help $2: no usage information available." >&2
                return 1
            fi
            echo 'Usage: shelly <command> [arguments]'
            echo
            echo 'Available commands:'
            echo
            printf '\t%-10s %s\n' 'build'      'Build a target'
            printf '\t%-10s %s\n' 'install'    'Build a target and install it under SHELLY_BIN'
            printf '\t%-10s %s\n' 'shellcheck' 'Run shellcheck across all project shell source code'
            printf '\t%-10s %s\n' 'test'       'Run all test case functions under test/'
            printf '\t%-10s %s\n' 'version'    'Print shelly version'
            echo
            echo 'Run "shelly help <command>" for further information about a command.'
            ;;
    esac
    return "$exit_status"
}
