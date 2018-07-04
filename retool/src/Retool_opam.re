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

let spaces = skip_while(is_space);

let eol = skip_while(is_eol);

let blank = spaces <|> eol;

let colon = char(':');
let label = x => blank *> string(x) *> colon *> blank <?> "Label=" ++ x;

let is_quote = is_char('"');
let quote = char('"');
let quoted = quote *> take_till(is_quote) <* quote <?> "Quoted text";

let name = label("name") *> quoted;
let version = label("version") *> quoted;
let opam_version = label("opam-version") *> quoted;

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
