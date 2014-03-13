Building a Module
===

As this is a CoffeeScript skeleton, it comes with its own `mimosa-config.coffee` that you can use to compile the skeleton itself.  (Installing CoffeeScript modules to NPM is frowned upon.)  Compilation of the skeleton will happen naturally when you run `mimosa mod:install`.  `mimosa mod:install` is how you would install this module locally to test it.

The contents of this skeleton consist of some example code, a ton of comments and some [Docco](http://jashkenas.github.io/docco/) style documentation.

If you have any questions about building a mimosa module, feel free to hit up @mimosajs or open up [an issue](https://github.com/dbashford/mimosa/issues?state=open) for discussion purposes.

The rest of this README is what you may want to transform the README to once development is complete.

Fubu
===========
## Overview

Asset pipeline for fubu

Define where your main project is located, aka "src/myproject"

Allows you to set your asset files side by side your controllers and still have them get picked up

Everything gets pulled into "src/myproject/assets" for precompiled bits, and post compilation things end up at "src/myproject/public"

Goals:
Automatically watch _content folder for backwards compatibility
support arbitrary number of additional folders to behave the same way
support side by side files next to .cs files anywhere in the application
support content that needs to come from bottles
javascript resources pull through bower, somehow sort that out with bottles

For more information regarding Mimosa, see http://mimosa.io

## Usage

Add `'???'` to your list of modules.  That's all!  Mimosa will install the module for you when you start up.

## Functionality


## Default Config

```
```

## Example Config

```
```
