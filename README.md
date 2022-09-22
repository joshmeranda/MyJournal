# Welcome to my Journal

This is intended to be a place where I can document things that I learn. Everyone is more than welcome to read and use
everything this journal contains. Just be aware that I am not responsible for any damage any script may cause son your
system.

I should note that while I hope this journal is useful to others, I am the main target audience. So there may be some
inside jokes or non-standard words (ex klonk yoink) that might not make sense to most users, but I hope they don't harm
the readability too much.

Note that this is not intended to be a 100% up-to-date reference on every topic that is listed, so use the info that you
find with care

## Format

Alongside this README you should find directories containing at least a `README.md`, but no other files or directories
are required. See below for a list of standard file and directory names inside each topic directory. If you are
contributing to this journal, please use these names when creating new files or directories:

| type | name      | purpose                                                                                                                                                                |
|------|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| f    | README.md | the main file containing notes / information / links / etc regarding a topic                                                                                           |
| f    | *.md      | any file matching the `*.md` pattern should server a similar purpose to `README.md` bu are included to improve organization or provide more specificity on a sub-topic |
| d    | tools     | a collection of scripts or programs which are related to the topic                                                                                                     |
| d    | examples  | a collection of examples of the topic                                                                                                                                  |
| d    | images    | a collection of examples of images related to the topic or used in any markdown files                                                                                  |

## Linting

This journal lints the markdown files with [markdownlint](https://github.com/markdownlint/markdownlint). To make
contributing easier for you, I've added some useful git hooks under the `hooks` directory. To utilize them simply copy
them into the `.git/hooks` directory:

```shell
cp --verbose hooks/* .git/hooks
```