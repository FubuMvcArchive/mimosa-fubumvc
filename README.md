mimosa-fubumvc [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url] [![Coveralls Status][coveralls-image]][coveralls-url] ![Dependencies][dependencies-image]
===========
## Overview

Connects fubumvc concerns to mimosas asset pipeline

Mimosa expects all source asset files to come together into a common directory
before being built.  For us that directory will be "assets" although this is
configurable if you want to change it.

This modules goal is to help move files from various fubumvc locations to
mimosas "assets" directory so that they can be picked up, compiled /
transformed as necessary and then mimosa moves them to your "public" folder
which is what you can then serve as static content via your webserver

For more information regarding Mimosa, see http://mimosa.io

## Usage

Add `mimosa-fubumvc` to your list of modules.  That's all!  Mimosa will install the module for you when you start up.

## Functionality

### fubu:init command

Run this from the folder of your fubu mvc web application (ie, the same folder your .csproj sits in)

Creates

  * bower.json
  * mimosa-config.js (or mimosa-config.coffee if "coffee" flag is passed)
  * assets/scripts
  * assets/styles
  * public

### Workflow

  From the command line, run "mimosa build" while in the folder that holds the
mimosa-config file.

Rules for picking up files:

  * nothing at the root directory will get picked up, this is to avoid things
  like the bower.json and mimosa-config.js
  * must match the list of extensions provided by the mimosa copy modules config section, the defaults for it look like this:

  ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd","map","md","mp4","mp3"]

  * must not match excludePaths rules provided by fubumvc config section
    used to ignore things that come from bin/obj folders, and any folders that start with a . (hidden folders like .mimosa ,etc)

This means you can have assets side by side other source files in your solution
and they will still get picked up.

## Default Config

  fubumvc:
    excludePaths: ["bin", "obj", /^\./]

[npm-url]: https://npmjs.org/package/mimosa-fubumvc
[npm-image]: http://img.shields.io/npm/v/mimosa-fubumvc.svg

[travis-url]: https://travis-ci.org/DarthFubuMVC/mimosa-fubumvc
[travis-image]: https://travis-ci.org/DarthFubuMVC/mimosa-fubumvc.svg

[coveralls-url]: https://coveralls.io/r/DarthFubuMVC/mimosa-fubumvc
[coveralls-image]: https://img.shields.io/coveralls/DarthFubuMVC/mimosa-fubumvc.svg

[dependencies-image]: https://david-dm.org/DarthFubuMVC/mimosa-fubumvc.png
