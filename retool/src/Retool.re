/* Retool_cli.run(); */

Retool_opam.run("name: \"hello\"");
Retool_opam.run("name: hello");
Retool_opam.run("name   :     \"hello");
Retool_opam.run(
  "name: \"hello\"\r\nversion: \"alpha\"\r\nopam-version: \"stable\"\r\n",
);
