__shelly_completion__suggest_commands() {
    shelly help \
        | grep '^\t' \
        | cut -f 2 \
        | while read -r command _; do
              echo "$command"
          done
}

__shelly_completion__suggest_commands_with_help() {
    __shelly_completion__suggest_commands | grep -v '^version$'
}
