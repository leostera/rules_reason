open Angstrom;
open Result;

type dep;

module Opam_file = {
  type dep = {
    name: string,
    version: string,
  };
  type t = {
    name: string,
    version: string,
    opam_version: string,
  };
};

let is_space =
  fun
  | ' '
  | '\t' => true
  | _ => false;

let is_eol =
  fun
  | '\r'
  | '\n' => true
  | _ => false;

let is_char = (a, b) => a == b;

let is_blank = x => is_space(x) || is_eol(x);

let spaces = skip_while(is_space);
let eol = skip_while(is_eol);
let blank = skip_while(is_blank);

let colon = char(':');
let label = x => string(x) *> spaces *> colon <?> "Label=" ++ x;

let is_quote = is_char('"');
let quote = char('"');
let quoted = quote *> take_till(is_quote) <* quote <?> "Quoted text";

let attr = name => blank *> label(name) *> spaces *> quoted <?> "Attr=" ++ name;

let name = attr("name");
let version = attr("version");
let opam_version = attr("opam-version");

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
    print_newline();
    print_string("version: " ++ opam_file.version);
    print_newline();
    print_string("opam-version: " ++ opam_file.opam_version);
    print_newline();
    print_newline();
  | Error(m) =>
    print_string("Failure => ");
    print_string(m);
    print_newline();
  };
