/*
 module Opam_file = {
   type dep = {
     name: string,
     version: string
   };
   type t = {
     opam_version: string,
     name: string,
     version: string,
     depends: list(dep)
     };
   };
 };

 module Reader = {
   type read_error =
     | `No_access
     | `File_does_not_exist
     | `Not_an_opam_file;

   let read: string => result(Opam_file.t, `Error(read_error));
 }

 type dep = {
   name: string
   archive: string,
   deps: list(dep),
   pkg_name: string,
   pkg_version: string,
   sha256: string,
 };
 */
