/* Retool_cli.run(); */

Retool_opam.run("name: \"hello\"");
Retool_opam.run("name: hello");
Retool_opam.run("name   :     \"hello");
Retool_opam.run(
  "\nname: \"hello\" \nversion: \"alpha\"\n opam-version: \"0.1-alpha\"",
);
Retool_opam.run("  name: \"hello\"");
