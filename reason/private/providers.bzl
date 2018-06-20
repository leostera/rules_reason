ReasonModuleInfo = provider(fields = {
  "name": "the name of this module",
  "deps": "the dependencies of this module",
  "srcs": "the source files for this module",
  "outs": "the compiled files for this module (ML code)",
})

BsModuleInfo = provider(fields = {
  "name": "the name of this module",
  "deps": "the dependencies of this module",
  "srcs": "the source files for this module",
  "outs": "the compiled files for this module (.bs.js, .cmi, .cmj, .cmt)",
})
