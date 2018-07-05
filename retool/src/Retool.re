/* Retool_cli.run(); */

print_string("Common attribute parsing");
print_newline();
print_string("====================");
print_newline();
print_newline();
Retool_opam.run("name: \"hello\"");
Retool_opam.run("name: hello");
Retool_opam.run("name   :     \"hello");
Retool_opam.run(
  "\nname: \"hello\" \nversion: \"alpha\"\n opam-version: \"0.1-alpha\"",
);
Retool_opam.run("  name: \"hello\"");

print_newline();
print_newline();
print_string("Dep parsing");
print_newline();
print_string("====================");
print_newline();
print_newline();
Retool_opam.run2("depend");
Retool_opam.run2("depends: [");
Retool_opam.run2("depends: [\n\"cmdliner\" {= \"1.0.2\"}");
Retool_opam.run2("depends: [\n\"cmdliner\" {= \"1.0.2\"}\n]");
/*
 depends: [
   "cmdliner" {= "1.0.2"}
   "angstrom" {= "0.10.0"}
   "bigstringaf" {= "0.2.0"}
 ]
 */
Retool_opam.run2(
  "depends: [\n  \"cmdliner\" {= \"1.0.2\"}\n  \"angstrom\" {= \"0.10.0\"}\n  \"bigstringaf\" {= \"0.2.0\"}\n]",
);
