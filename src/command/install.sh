__shelly_command__install__help() {
    echo 'Usage: shelly install [-x] <script-name> [-s] [<target>]'
    echo
    echo 'install builds a target and installs it under SHELLY_BIN.'
    echo
    echo 'Arguments:'
    echo
    printf '\t%-11s %s\n' 'script-name' 'The script name'
    printf '\t%-11s %s\n' 'target' 'The target to be built (defaults to "main")'
    echo
    echo 'Available options:'
    echo
    printf '\t%-11s %s\n' '-x' 'If set, makes <script-name> executable'
    printf '\t%-11s %s\n' '-s' 'If set, the POSIX she bang line will be included'
}

__shelly_command__install() {
    OPTIND=1
    while getopts x option "$@"; do
        case "$option" in
            x) make_executable=1 ;;
            *) ;;
        esac
    done

    shift $((OPTIND - 1))

    if test -z "$SHELLY_BIN"; then
        echo 'error: environment variable SHELLY_BIN not set.' >&2
        exit 1
    fi

    if ! test -d "$SHELLY_BIN"; then
        echo 'error: environment variable SHELLY_BIN does not point to a directory.' >&2
        exit 1
    fi

    if test -z "$1"; then
        echo 'error: argument <script-name> missing.' >&2
        exit 1
    fi

    script_name="$1" ; shift
    script_path="$SHELLY_BIN/$script_name"

    if test -r "$script_path"; then
        echo "warning: $script_path already exists."
        while :; do
            printf 'Overwrite it (yes/no)? '
            read -r choice
            case "$choice" in
                yes) break ;;
                no) echo 'Ok, exiting.' ; exit 0 ;;
            esac
        done
    fi

    tmp=$(mktemp) ; trap 'rm $tmp' EXIT
    __shelly_command__build "$@" > "$tmp"
    if test $? -ne 0; then
        echo "error: could not build target '$1'." >&2
        exit 1
    fi

    cp "$tmp" "$script_path"

    if test -n "$make_executable"; then
        chmod +x "$script_path"
    fi
}
