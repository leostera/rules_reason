/* Retool_cli.run(); */

Retool_opam.run("name: \"hello\"");
Retool_opam.run("name: hello");
Retool_opam.run("name   :     \"hello");
Retool_opam.run(
  "name: \"hello\" version: \"alpha\" opam-version: \"0.1-alpha\"",
);
