/* Implementations, just print the args. */

type verb =
  | Normal
  | Quiet
  | Verbose;
type copts = {
  debug: bool,
  verb,
  prehook: option(string),
};

let str = Printf.sprintf;
let opt_str = sv =>
  fun
  | None => "None"
  | Some(v) => str("Some(%s)", sv(v));
let opt_str_str = opt_str(s => s);
let verb_str =
  fun
  | Normal => "normal"
  | Quiet => "quiet"
  | Verbose => "verbose";

let pr_copts = (oc, copts) =>
  Printf.fprintf(
    oc,
    "debug = %b\nverbosity = %s\nprehook = %s\n",
    copts.debug,
    verb_str(copts.verb),
    opt_str_str(copts.prehook),
  );

let initialize = (copts, repodir) =>
  Printf.printf("%arepodir = %s\n", pr_copts, copts, repodir);

let record = (copts, name, email, all, ask_deps, files) =>
  Printf.printf(
    "%aname = %s\nemail = %s\nall = %b\nask-deps = %b\nfiles = %s\n",
    pr_copts,
    copts,
    opt_str_str(name),
    opt_str_str(email),
    all,
    ask_deps,
    String.concat(", ", files),
  );

let help = (copts, man_format, cmds, topic) =>
  switch (topic) {
  | None => `Help((`Pager, None)) /* help about the program. */
  | Some(topic) =>
    let topics = ["topics", "patterns", "environment", ...cmds];
    let (conv, _) = Cmdliner.Arg.enum(List.rev_map(s => (s, s), topics));
    switch (conv(topic)) {
    | `Error(e) => `Error((false, e))
    | `Ok(t) when t == "topics" =>
      List.iter(print_endline, topics);
      `Ok();
    | `Ok(t) when List.mem(t, cmds) => `Help((man_format, Some(t)))
    | `Ok(t) =>
      let page = (
        (topic, 7, "", "", ""),
        [`S(topic), `P("Say something")],
      );
      `Ok(Cmdliner.Manpage.print(man_format, Format.std_formatter, page));
    };
  };

open Cmdliner;

/* Help sections common to all commands */

let help_secs = [
  `S(Manpage.s_common_options),
  `P("These options are common to all commands."),
  `S("MORE HELP"),
  `P("Use `$(mname) $(i,COMMAND) --help' for help on a single command."),
  `Noblank,
  `P("Use `$(mname) help patterns' for help on patch matching."),
  `Noblank,
  `P("Use `$(mname) help environment' for help on environment variables."),
  `S(Manpage.s_bugs),
  `P("Check bug reports at http://bugs.example.org."),
];

/* Options common to all commands */

let copts = (debug, verb, prehook) => {debug, verb, prehook};
let copts_t = {
  let docs = Manpage.s_common_options;
  let debug = {
    let doc = "Give only debug output.";
    Arg.(value & flag & info(["debug"], ~docs, ~doc));
  };

  let verb = {
    let doc = "Suppress informational output.";
    let quiet = (Quiet, Arg.info(["q", "quiet"], ~docs, ~doc));
    let doc = "Give verbose output.";
    let verbose = (Verbose, Arg.info(["v", "verbose"], ~docs, ~doc));
    Arg.(last & vflag_all([Normal], [quiet, verbose]));
  };

  let prehook = {
    let doc = "Specify command to run before this $(mname) command.";
    Arg.(value & opt(some(string), None) & info(["prehook"], ~docs, ~doc));
  };

  Term.(const(copts) $ debug $ verb $ prehook);
};

/* Commands */

let initialize_cmd = {
  let repodir = {
    let doc = "Run the program in repository directory $(docv).";
    Arg.(
      value
      & opt(file, Filename.current_dir_name)
      & info(["repodir"], ~docv="DIR", ~doc)
    );
  };

  let doc = "make the current directory a repository";
  let exits = Term.default_exits;
  let man = [
    `S(Manpage.s_description),
    `P(
      "Turns the current directory into a Darcs repository. Any\n       existing files and subdirectories become ...",
    ),
    `Blocks(help_secs),
  ];

  (
    Term.(const(initialize) $ copts_t $ repodir),
    Term.info(
      "initialize",
      ~doc,
      ~sdocs=Manpage.s_common_options,
      ~exits,
      ~man,
    ),
  );
};

let record_cmd = {
  let pname = {
    let doc = "Name of the patch.";
    Arg.(
      value
      & opt(some(string), None)
      & info(["m", "patch-name"], ~docv="NAME", ~doc)
    );
  };

  let author = {
    let doc = "Specifies the author's identity.";
    Arg.(
      value
      & opt(some(string), None)
      & info(["A", "author"], ~docv="EMAIL", ~doc)
    );
  };

  let all = {
    let doc = "Answer yes to all patches.";
    Arg.(value & flag & info(["a", "all"], ~doc));
  };

  let ask_deps = {
    let doc = "Ask for extra dependencies.";
    Arg.(value & flag & info(["ask-deps"], ~doc));
  };

  let files =
    Arg.(value & (pos_all(file))([]) & info([], ~docv="FILE or DIR"));
  let doc = "create a patch from unrecorded changes";
  let exits = Term.default_exits;
  let man = [
    `S(Manpage.s_description),
    `P(
      "Creates a patch from changes in the working tree. If you specify\n         a set of files ...",
    ),
    `Blocks(help_secs),
  ];

  (
    Term.(const(record) $ copts_t $ pname $ author $ all $ ask_deps $ files),
    Term.info("record", ~doc, ~sdocs=Manpage.s_common_options, ~exits, ~man),
  );
};

let help_cmd = {
  let topic = {
    let doc = "The topic to get help on. `topics' lists the topics.";
    Arg.(
      value & pos(0, some(string), None) & info([], ~docv="TOPIC", ~doc)
    );
  };

  let doc = "display help about darcs and darcs commands";
  let man = [
    `S(Manpage.s_description),
    `P("Prints help about darcs commands and other subjects..."),
    `Blocks(help_secs),
  ];

  (
    Term.(
      ret(const(help) $ copts_t $ Arg.man_format $ Term.choice_names $ topic)
    ),
    Term.info("help", ~doc, ~exits=Term.default_exits, ~man),
  );
};

let default_cmd = {
  let doc = "a revision control system";
  let sdocs = Manpage.s_common_options;
  let exits = Term.default_exits;
  let man = help_secs;
  (
    Term.(ret(const(_ => `Help((`Pager, None))) $ copts_t)),
    Term.info("darcs", ~version="v1.0.2", ~doc, ~sdocs, ~exits, ~man),
  );
};

let cmds = [initialize_cmd, record_cmd, help_cmd];

Term.(exit @@ eval_choice(default_cmd, cmds));
