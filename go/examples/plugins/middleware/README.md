# SimplePlugin

This directory contains an example of loading a plugin using the golang stdlib `plugin` package. This example is a bit
more involved than the [simple](../simple) example, in that the provided example contains 3 modules:

1. A plugin
2. A plugin loader
3. Middleware package between the plugin and the loader
