main() {
    case "$1" in
        -h) shift ; __shelly_command__help 1 ;;
        help) shift ; __shelly_command__help 0 "$1" ;;
        build|install|shellcheck|test|version)
            command="$1" ; shift
            "__shelly_command__${command}" "$@"
            ;;
        *)
            if test -n "$1"; then
                echo "shelly $1: unknown command"
                echo "Run 'shelly help' for usage."
            else
                __shelly_command__help 1
            fi
    esac
}
