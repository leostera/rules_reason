open Cmdliner;

let run = () => {
  let say_hi = () => print_string("Hello there!");
  let hello_world_t = Term.(const(say_yi) $ const());
  let cmd_info = Term.info("retool-cli");
  Term.exit @@ Term.eval(hello_world_t, cmd_info);
};
