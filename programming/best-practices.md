# Best Practices

While there is rarely one right way to do anything while programming, there are some best practices that will almost
always improve your code.

You may also want to check out [Programming Principles](principles.md) for more on writing good code!

## Input / Output (IO)

### Do not check for file before opening

One of the most common things to do in programming is opening files. A common pattern you will see, especially in newer
programmers (or those who aren't paying attention like me) is checking for file existence and optionally creating before
opening. This isn't ideal. Most file operations will result in one or more syscalls which will slow your program.
Instead, we should just open the file and deal with any errors as they occur, since the openieng and the checking will
have the same amount of syscalls, but just opening will also tell you if it exists, so we can usually get away with just
the open without too much issue. Let's see this in action:

```python
import os

def do_stuff(f):
    for (i, line) in enumerate(f.readlines()):
        print(f"{i}: {line.strip()}")

if os.path.exists("some_file.txt"):       # will trigger a syscall
    with open("some_file.txt", "r") as f: # will trigger another syscall
        do_stuff(f)
else:
    print("could not find file")
```

```python
def do_stuff(f):
    for (i, line) in enumerate(f.readlines()):
        print(f"{i}: {line.strip()}")

try:
    with open("some_file.txt", "r") as f: # will trigger a syscall
        do_stuff(f)
except FileNotFoundError:
    print("could not find file")
```

By looking at these snippets it should be clear how asking for forgiveness and not permission is better in this case. If
`some_file.txt` exists, the first example does two things to start syscalls, or one thing if the file does not exist. On
the other hand, the second snippet will only ever do one thing, that could start syscalls. So in most cases it will be
much more performant to just attempt to open it and handle any "file does not exist" errors that may arise.

## Evil ^ .5

One of the most common programming phrases is "premature optimization is the root of all evil." The quote comes from the
near universal experience the optimizing your code too soon will lead to bugs (or at least necessary frustration) more
often than not. Instead, get your code to work, write good tests, then go back and optimize. If you're like me and will
forget about anything not directly in front of you, leave some TODOs describing how you think or know the code could be
optimized for later.

## Styling

Styling can make your code much more readable and pleasant for other people to work with. Since there are so many
languages and organization each with their own list of conventions or style preferences, I can't give any specific
recommendations about what styling to use since nothing will work across the board. But I can give some very general
guidelines.

1. Follow the conventions of tha language

Most languages will specify what case they prefer for identifiers. For example, python uses `CamelCase` for classes and
`snake_case` for pretty much everything else. Whether you're working on a personal project, or writing an organization
wide style guide please please please don't stray from these conventions without a **really** good reason.

2. Follow your organizations style guide

If the company or organization you are working for provides a style guide, you better stick to it. Not only will you
have to deal with a lot of linting nitpicks during the code review, but you will also be making your code less readable
to those who expect the code to be formatted in a specific way.

3. If you're going to sin, sin consistently

If you decide to go against the grain for some reason, just do it consistently. This way reviewers can make the mental
switch once, and not multiple times while reviewing. It will also make it easier to refactor your code to the "right"
style since you can search (and maybe modify) for predictable patterns rather than manually updating every line.

### Use Formatting Tools

In an ideal world, all programmers would have access to formatting tools like `go-fmt` that will go through and format
our code for use according to some (hopefully not arbitrary) standard. Whenever possible use these formatting tools and
include how to use them your project's readme.

### Tabs vs Spaces

The battle for the ages is "Tabs vs Spaces." At surface level, this argument seems very subjective, without any *real*
arguments on either side; however, there are some real arguments for both sides.

If you're just looking for how I feel its simple: do what you want, just don't be a dick ot others.

#### Tabs

One of the most clear arguments for spaces is the smaller storage impact. If most of your lines of code are going to be
indented by either tabs or spaces, you will always have more bytes per line when using spaces over tabs. In most cases
I don't think this matters much. Maybe in the "olden times" when storage was sold at a premium this made sense, but
storage is pretty cheap nowadays and most of my code isn't even stored locally. In compiled languages, this doesn't even
matter much at all since whitespace has no impact on the resulting executable. I will say that in situations like HTML
where code is being sent over a network to be processed by a client, the increased byte count could really impact
performance. That being said, we probably shouldn't even be preserving whitespace in HTML where it only exists for the
programmer, so I'd argue this is mostly a non-issue, but still worth consideration.

The most important argument for using tabs is that fact that they allow programmers to choose their indentation size for
themselves. This is especially convincing when you consider those of us who are visually impaired and may need greater
indentation in order to easier differentiate indentation levels. Since I am not visually impaired I don't actually know
how useful tabs are.

#### Spaces

The biggest argument for spaces over tabs, is the consistency that spaces provide. Your code will always be formatted
the same no matter the configurations of the programmer's environment. This can be useful for the same reason that
consistent styling is useful. Consistent formatting is easier to read.

In my experience, copying and sharing code is a lot easier when using spaces than tabs. While in theory both should be
equally copyable, for whatever reason tabs usually give me trouble with messed up indentation. Code is meant to be
shared and spaces make that easier.