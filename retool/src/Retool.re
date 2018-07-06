/* Retool_cli.run(); */

switch (
  Retool_opam.read(
    "/Users/ostera/repos/github.com/ostera/rules_reason/retool/3rdparty/package.opam",
  )
) {
| Ok(s) => Retool_opam.Printer.print(s)
| Error(e) => print_string(e)
};
