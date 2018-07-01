open Cmdliner;

let say_hi = () => print_string @@ Lib.message;

let hello_world_t = Term.(const(say_hi) $ const());

let cli = (hello_world_t, Term.info("retool"));

let run = () => Term.(exit @@ eval(cli));
