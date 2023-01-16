# Go

Go is google's response to how bloated C++ has become.

## Documentation

| description      | link                                      |
|------------------|-------------------------------------------|
| Effective Go     | https://golang.google.cn/doc/effective_go |
| Go User Manual   | https://golang.google.cn/doc/?            |
| Standard Library | https://pkg.go.dev/std                    |

## Setting Values At Compile Time

One neat thing you can do when building go code is setting variables at compile time. This is very useful when you want
to  embed a version number into your binary which you won't necessarily know until compile time. This obviously would
make it much easier to package and distribute your code, since you no longer need to manually update version numbers.

To do this we can leverage the `-ldflags "-x <importpath>=<value>` flag to `go build`.
From the [docs](https://pkg.go.dev/cmd/link):

```text
-X importpath.name=value
    Set the value of the string variable in importpath named name to value.
    This is only effective if the variable is declared in the source code either uninitialized
    or initialized to a constant string expression. -X will not work if the initializer makes
    a function call or refers to other variables.
    Note that before Go 1.5 this option took two separate arguments.
```

The `importpath` will follow the format `<module_name>/<path_to_parent_package>.<variable_name>`. The easiest way to
determine the full import path is to run `go tool nm | grep <variable_name>`. Note from the excerpt above that this
functionality only support `string` values, and cannot affect `const` values.

For a simple example of this in action, see [./examples/compile-time-value]().
