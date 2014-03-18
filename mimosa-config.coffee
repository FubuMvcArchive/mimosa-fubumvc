exports.config =
  modules: ["jshint", "coffeescript"]
  watch:
    sourceDir: "src"
    compiledDir: "lib"
    javascriptDir: null
  jshint:
    rules:
      node: true
