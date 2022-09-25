# Fish

> This is the documentation for fish, the friendly interactive shell.
>
> A shell is a program that helps you operate your computer by starting other programs. fish offers a command-line
> interface focused on usability and interactive use.

See [config.fish](/shells/fish/config.fish) for the `fish.config` file that I use as a base for new systems.

## Documentation

| description        | link                                          |
|--------------------|-----------------------------------------------|
| documentation root | https://fishshell.com/docs/current/index.html |

## Why I Like Fish

The [Fish syntax](https://fishshell.com/docs/current/language.html) looks and feels very different from POSIX, and Fish
scripts will not be cross-compatible with other shells. So why use it?

Well simply put I don't write scripts in Fish. In addition to being non-POSIX, Fish is nowhere near as ubiquitous as
shells like `bash` or `sh`, and you can't rely on most systems to have it installed. But Fish has a very nice
interactive mode. In addition to the features you'd expect from a shell, Fish has several other features that make it
stand out to me. While other shells may have similar features, I have the most experience with Fish so I keep using it.

### Autosuggestions

Fish's autosuggestions are quite nice. As you start typing a command, the suggestions will appear in a faded text to
show you what Fish thinks you might be typing. These suggestions go so far as to take the current working directory
(cwd), as well as the status of file paths into account when generating the suggestions.

For more info, see here: <https://fishshell.com/docs/current/interactive.html#autosuggestions>

### Tab Completions

While tab completions are expected to be a part of most shells, I find Fish's to be particularly nice. Fish will
complete commands, variables, usernames, and filenames. But it also handles some more specific completions for commands
like `man` or `make`. You can also [write your own completions](https://fishshell.com/docs/current/completions.html#completion-own).

For more info see here: <https://fishshell.com/docs/current/interactive.html#tab-completion>

### Private Mode

I do not use this feature often at all, but I like the concept behind it. If enabled, commands will not be written to
history. According to the docs:

> This both hides old history and prevents writing history to disk. This is useful to avoid leaking personal information
> (e.g. for screencasts) or when dealing with sensitive information.

For more info see here: <https://fishshell.com/docs/current/interactive.html#private-mode>

### `fish_config`

Once nice feature of Fish is the `fish_config` command. It allows you to view and edit some basic fish settings like
theme and prompt with provided templates. You can use it via command line or web browser if you provide no subcommand or
`browse`.

I like this because it makes configuring some aspects of Fish very easy, and is a novel idea. I would like to see it
provide control over more aspects of Fish like variables, functions, etc. As it stands using `fish_config` is more of a
config viewer than an editor.

For more info see here: <https://fishshell.com/docs/current/cmds/fish_config.html#cmd-fish-config>

## Adding to PATH

In older versions you'd have to set the `fish_user_paths` variable to add to the `PATH`:

```fish
set -Ua fish_user_paths /path
```

Since [v3.2.0](https://fishshell.com/docs/current/relnotes.html#fish-3-2-0-released-march-1-2021) you can use
`fish_add_apath` to add to your path. This is very nice!

## Set Greeting

I prefer to have an empty fish greeting, so I like to set the greeting to an empty string:

```fish
set fish_greeting ''
```

## Command Not Found

When a command cannot be found Fish does a lot of checks before reporting back to the user. I found this annoying, so I
wanted to get rid of these checks that I didn't feel were too helpful. You can set the default "command not found
handler". Since [v3.2.0](https://fishshell.com/docs/current/relnotes.html#fish-3-2-0-released-march-1-2021) we can use
the `fish_command_not_found` to change this behavior:

```fish
function fish_command_not_found
    echo "Command '$argv[1]' not found :("
end
```

But in older versions (and for [backwards compatibility](https://fishshell.com/docs/current/cmds/fish_command_not_found.html#backwards-compatibility))
you need to define an event handler, but this can just be a simple wrapper around the method we define above:

```fish
function __fish_command_not_found_handler --on-event fish_command_not_found
     fish_command_not_found $argv
end
```

For more info see here: <https://fishshell.com/docs/current/cmds/fish_command_not_found.html>