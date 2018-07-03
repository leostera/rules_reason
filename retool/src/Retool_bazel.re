module Types = {
  /* TODO(@ostera): find a library with nice Path types */
  type path = string;
  type visibility =
    | Public
    | Subpackages(string)
    | Scoped(string, visibility);
  type label =
    | Label(string)
    | Path(path);
};

module type Rule = {
  type name: string;
  type srcs: list(label);
}

module Build_file = {
  type t = {
    visibility: option(visibility),
    file_path: path,
    subpackages: option(list(t)),
    rules: option(list(rule)),
  };

  let from_dep: Retool_lib.dep => t;
};

module Writer = {
  type write_error =
    | `No_access
    | `File_already_exists;

  let write: list(Build_file.t) => result(list(Build_file.t), `Error(write_error)) =
    build_file => {
      /* Actually write the file down, creating all folders on the way */
    };
};
