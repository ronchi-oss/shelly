# shelly

[![CI](https://github.com/ronchi-oss/shelly/actions/workflows/ci.yml/badge.svg)](https://github.com/ronchi-oss/shelly/actions/workflows/ci.yml)

Writing a shell script can be fun. Eventually, however, as you add option parsing, sub-commands and other bells and whistles, those initial few lines of beautiful UNIX pipelines can grow to a couple hundred lines of spaghetti code in a single file. That's not as fun. At this point the common-sense advice on the internet tends to be "just rewrite it with [someone's preferred language]". Well, if you'd like to stick with shell script, `shelly` may help you.

`shelly` allows you to split a script into a directory structure, typical of projects in other languages, and then stitch all shell files into a single "build" file whenever you want to try them out. It also shipts with a minimal unit test suite runner, as well as a shorthand command for running `shellcheck` against all scripts in the project.

Here's the output of `shelly help`:

```
Usage: shelly <command> [arguments]

Available commands:

	build      Build a target
	install    Build and install a target under SHELLY_BIN
	shellcheck Run shellcheck across all project shell source code
	test       Run all test case functions under test/
	version    Print shelly version

Run "shelly help <command>" for further information about a command.

```

## Installation

For the time being the only way to install it is manually building it.

```
# Building `shelly`

git clone https://github.com/ronchi-oss/shelly.git
cd shelly
./bin/shelly-build -s main > shelly
chmod +x shelly

# Recommended: move `shelly` to a directory listed in your PATH

# Optionally: building and sourcing bash completion

./bin/shelly-build bash_completion > shelly-completion.bash
source shelly-completion.bash
```

## Building a project

What does it mean to "build" a project? For shelly, it means to create one shell script file that includes all of the code needed for that script to be usable. A typical project will include at least one target but may include as many as it requires. For instance, shelly itself (this repository) includes two: `main`, which builds the POSIX shell `shelly` script, and `bash_completion`, which is not executable and meant to be sourced by a bash login shell in order to provide tab completion.

shelly makes no assumptions about what targets exist: it will look for them under `.shelly/shelly.sh`, starting at a project root level. Consider the following project structure:

```
src
├── command
│   ├── build.sh
│   ├── help.sh
│   ├── install.sh
│   ├── shellcheck.sh
│   ├── test.sh
│   └── version.sh
├── completion
│   ├── completion.bash
│   └── completion.sh
└── main.sh
```

In order to declare a target called `main` that will include all shell script files under `src/command/` as well as `main.sh`, a function called `__shelly_build_target__main` must be defined in `.shelly/shelly.sh`:

```sh
__shelly_build_target__main() {
    find src/command/ src/main.sh -name '*.sh' -print0
}
```

That function must output a null byte separated (`print0`) list of files to be included in the build. The output order is respected by shelly, so in the example above, the contents of `src/main.sh` will be appended to the end of the build file.

Since this build target is intended as an executable script, it should include a she bang line as its first line.

Now, at the project root level, we tell shelly to build it:

```sh
shelly build -x main
```

`build` outputs to standard output. For running your script, write the output of `build` to a file, then make it executable and run it:

```sh
shelly build -s main > my-program
chmod +x my-program
./my-program
```

Alternatively, the following script will build the project `main` target with a she bang line (`-s`) and then place it under `SHELLY_BIN` as an executable (`-x`) named `foo`.

```sh
export SHELLY_BIN="$HOME/shelly/bin"
export PATH="$SHELLY_BIN:$PATH"

cd my-shell-project
shelly install -x foo -s main
```

Since `SHELL_BIN` is part of your `PATH`, you can immediately invoke `foo` from that same shell.

## Testing a project

Out of the box, shelly can find and run test cases (shell functions) as long as:

* project test files are located under `tests/`
* project test files are named with a `.sh` suffix
* project test files test case functions are named with a `test_` prefix

Consider the following directory structure:

```
test
└── test_example.sh
```

Assuming the following contents for `test_example.sh`:

```
test_one_equals_one() {
    test 1 -eq 1
}
```

Running `shelly test` will do what you'd expect:

```
Running tests...

.

1 passed, 0 failed, 0 skipped.
```

shelly will run each test function sequentially with `/bin/sh -c`, which guarantees that variables defined in the function bodies can't override variables defined by the outer scope.

The exit status of each test case function indicates to shelly whether it passed (zero) or failed (non-zero). Therefore, it's very convenient to write short test case functions with a single `test` command at the end.
