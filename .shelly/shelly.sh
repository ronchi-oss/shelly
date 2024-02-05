__shelly_build_target__main() {
    find src/command/ src/main.sh -name '*.sh' -print0
}

__shelly_build_target__bash_completion() {
    find src/completion/completion.sh src/completion/completion.bash -print0
}
