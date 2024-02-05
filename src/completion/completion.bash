__shelly_completion__bash() {
    test "$1" != shelly && return 1
    mapfile -t COMPREPLY < <(
        case "$3" in
            shelly)
                __shelly_completion__suggest_commands \
                    | grep "${COMP_WORDS[COMP_CWORD]}"
                ;;
            help)
                __shelly_completion__suggest_commands_with_help \
                    | grep "${COMP_WORDS[COMP_CWORD]}"
                ;;
        esac
    )
}

complete -F __shelly_completion__bash shelly
