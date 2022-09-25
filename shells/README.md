# shells

From the [bash reference](https://www.gnu.org/software/bash/manual/bash.html#What-is-a-shell_003f):

> At its base, a shell is simply a macro processor that executes commands. The term macro processor means functionality
> where text and symbols are expanded to create larger expressions.
>
> A Unix shell is both a command interpreter and a programming language. As a command interpreter, the shell provides
> the user interface to the rich set of GNU utilities. The programming language features allow these utilities to be
> combined. Files containing commands can be created, and become commands themselves. These new commands have the same
> status as system commands in directories such as /bin, allowing users or groups to establish custom environments to
> automate their common tasks.
>
> Shells may be used interactively or non-interactively. In interactive mode, they accept input typed from the keyboard.
> When executing non-interactively, shells execute commands read from a file.
>
> A shell allows execution of GNU commands, both synchronously and asynchronously. The shell waits for synchronous
> commands to complete before accepting more input; asynchronous commands continue to execute in parallel with the shell
> while it reads and executes additional commands. The redirection constructs permit fine-grained control of the input
> and output of those commands. Moreover, the shell allows control over the contents of commands’ environments.
>
> Shells also provide a small set of built-in commands (builtins) implementing functionality impossible or inconvenient
> to obtain via separate utilities. For example, cd, break, continue, and exec cannot be implemented outside of the
> shell because they directly manipulate the shell itself. The history, getopts, kill, or pwd builtins, among others,
> could be implemented in separate utilities, but they are more convenient to use as builtin commands. All of the shell
> builtins are described in subsequent sections.
>
> While executing commands is essential, most of the power (and complexity) of shells is due to their embedded
> programming languages. Like any high-level language, the shell provides variables, flow control constructs, quoting,
> and functions.
>
> Shells offer features geared specifically for interactive use rather than to augment the programming language. These
> interactive features include job control, command line editing, command history and aliases. Each of these features is
> described in this manual.

Or more simply as from the [fish docs](https://fishshell.com/docs/current/index.html):
> A shell is a program that helps you operate your computer by starting other programs

The shells I like to use and will provide configuration templates for are:

- [bash](/shells/bash)
- [fish](/shells/fish)

## Builtin vs Command

One important thing to note is the difference between a builtin and a command. When you run a normal command like `ls`,
your shell will create a new process to read the filesystem and write to `stdout`. However, consider what would happen
if `cd` was implemented in this way.

Of course this would not work. `cd` modifies the current working directory (cwd) of the current process and any child
process you create in the future, but most importantly, not the cwd of the parent process. This means that if `cd` was
run in the same way that `ls` was, it would be impossible (by normal means anyway) to actual "change directories". This
means that `cd` must be run in the shell's process.

This is where builtins come in. Because `cd` is a builtin it, it is never passed to the kernel and is instead run as
part of the shell. To help this make sense see the below `python` code that shows a **VERY** simple implementation of a
shell:

```python
import os
import sys

while True:
    raw = input(">>> ")
    cmd = raw.split()

    if cmd[0] == "cd":
        os.chdir(cmd[1])
    elif cmd[0] == "exit":
        sys.exit(int(cmd[1]))
    else:
        # pass commands to sh to handle non-builtins
        os.system(f"sh -c '{raw}'")
```

In the code above you should see that `cd` and `exit` are builtins because their side effects / output is produced by
the shell directly, rather than passing the command to the kernel (or in this case `sh` for simplicity).
