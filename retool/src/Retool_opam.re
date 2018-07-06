open Result;
open Angstrom;

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
    depends: list(dep),
  };
};

module Printer = {
  let print = (opam: Opam_file.t) => {
    print_string("name: " ++ opam.name);
    print_newline();
    print_string("version: " ++ opam.version);
    print_newline();
    print_string("opam_version: " ++ opam.opam_version);
    print_newline();
    print_string("depends: [");
    print_newline();
    List.iter(
      (dep: Opam_file.dep) => {
        print_string(
          "  \"" ++ dep.name ++ "\" {= \"" ++ dep.version ++ "\"}",
        );
        print_newline();
      },
      opam.depends,
    );
    print_string("]");
  };
};

module Parser = {
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

  let open_bracket = char('[');
  let closed_bracket = char(']');
  let bracketed = p =>
    open_bracket
    *> blank
    *> many_till(p <?> "List Elems", closed_bracket)
    <* blank
    <?> "List";

  let is_closed_brace = is_char('}');
  let open_brace = char('{');
  let closed_brace = char('}');
  let braced = p =>
    open_brace
    *> blank
    *> p
    <?> "Braced Elem"
    <* closed_brace
    <* blank
    <?> "Braced";

  let attr = name => blank *> label(name) *> spaces <?> "Attr=" ++ name;

  let name = (attr("name") <?> "Name attribute") *> quoted <?> "Name value";
  let version = attr("version") *> quoted;
  let opam_version = attr("opam-version") *> quoted;

  let semver_constraint = string("=") <?> "Semver Constraint";
  let semver =
    spaces *> semver_constraint *> spaces *> quoted <?> "Semver String";

  let dep_name = blank *> quoted <?> "Dep name";
  let dep_version = blank *> braced(semver) <?> "Dep version";
  let dep =
    lift2(
      (name, version) => ({name, version}: Opam_file.dep),
      dep_name,
      dep_version,
    );
  let depends = attr("depends") *> bracketed(dep);

  /* TODO(@ostera): rewrite using scan_state+proplist to support diff orders */

  let opam =
    lift4(
      (name, version, opam_version, depends) => (
        {name, version, opam_version, depends}: Opam_file.t
      ),
      name,
      version,
      opam_version,
      depends,
    );
};

let read = path => Retool_fs.read(path) |> parse_string(Parser.opam);
