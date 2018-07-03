open Cmdliner;

let repeater = (count, msg) =>
  for (i in 1 to count) {
    print_endline(msg);
  };

let count = {
  let doc = "Repeat the message $(docv) times.";
  Arg.(value & opt(int, 10) & info(["c", "count"], ~docv="COUNT", ~doc));
};

let msg = {
  let env_doc = "Overrides the default message to print";
  let env = Arg.env_var("REPEATER_MSG", ~doc=env_doc);
  let doc = "The message to print";
  Arg.(
    value & pos(0, string, "Revolt!") & info([], ~env, ~docv="MSG", ~doc)
  );
};

/* equivalent to calling `repeater(count, msg)` after we get those values */
let repeater_t = Term.(const(repeater) $ count $ msg);

let info = {
  let doc = "print a customizable message repeatedly";
  let man = [
    `S(Manpage.s_bugs),
    `P("Email bug reports to <leandro at ostera.io>."),
  ];
  Term.info(
    "repeater",
    ~version="0.0-alpha",
    ~doc,
    ~exits=Term.default_exits,
    ~man,
  );
};

Term.exit @@ Term.eval((repeater_t, info));
