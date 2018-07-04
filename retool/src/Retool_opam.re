open Angstrom;
open Result;

type dep;

module Opam_file = {
  type dep = {
    name: string,
    version: string,
  };
  type t = {
    opam_version: string,
    name: string,
    version: string,
  };
};

let is_space =
  fun
  | ' '
  | '\t' => true
  | _ => false;

let is_char = (a, b) => a == b;

let label = x =>
  skip_while(is_space)
  *> string(x)
  *> skip_while(is_space)
  *> char(':')
  *> skip_while(is_space)
  *> char('"')
  *> take_till(is_char('"'));

let name = label("name");
let version = label("version");
let opam_version = label("opam-version");

let opam =
  lift3(
    (name, version, opam_version) => (
      {name, version, opam_version}: Opam_file.t
    ),
    name,
    version,
    opam_version,
  );

let run = text =>
  switch (parse_string(opam, text)) {
  | Ok(opam_file) =>
    print_string("name: " ++ opam_file.name);
    print_string("version: " ++ opam_file.version);
    print_string("opam-version: " ++ opam_file.opam_version);
    print_newline();
  | Error(m) =>
    print_string("Failure => ");
    print_string(m);
    print_newline();
  };
