exports.config =
  modules: ["jshint", "coffeescript"]
  watch:
    sourceDir: "src"
    compiledDir: "lib"
    javascriptDir: null
  coffeescript:
    options:
      sourceMap: false
  jshint:
    rules:
      node: true
