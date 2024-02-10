__shelly_build_target__main() {
    for path in src/command/* src/main.sh; do
        echo "$path"
    done
}

__shelly_build_target__bash_completion() {
    for path in src/completion/*; do
        echo "$path"
    done
}
