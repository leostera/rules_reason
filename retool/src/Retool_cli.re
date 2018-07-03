open Cmdliner;

type verb =
  | Normal
  | Quiet
  | Verbose;
let verb_str =
  fun
  | Normal => "normal"
  | Quiet => "quiet"
  | Verbose => "verbose";
type flags = {
  debug: bool,
  verb,
};

module Common = {
  let flags_make = (debug, verb) => {debug, verb};
  let help = [
    `S(Manpage.s_common_options),
    `P("These options are common to all commands."),
    `S("MORE HELP"),
    `P("Use `$(mname) $(i,COMMAND) --help' for help on a single command."),
    `Noblank,
    `S(Manpage.s_bugs),
    `P("Check bug reports at https://github.com/ostera/rules_reason."),
  ];
  let flags = {
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

    Term.(const(flags_make) $ debug $ verb);
  };
};

module Sync = {
  let sync = (flags, workdir, verify) =>
    Printf.printf(
      "flags = { verbose = %s, debug = %b }\nworkdir = %s\nverify = %b",
      verb_str(flags.verb),
      flags.debug,
      workdir,
      verify,
    );

  let cmd = {
    let workdir = {
      let doc = "Run the program in workspace directory $(docv).";
      Arg.(
        value
        & opt(file, Filename.current_dir_name)
        & info(["w", "workdir"], ~docv="DIR", ~doc)
      );
    };

    let verify = {
      let doc = "Verify integrity (no synchronization)";
      Arg.(value & flag & info(["verify"], ~doc));
    };

    let doc = "synchronize dependencies in this workspace";
    let exits = Term.default_exits;
    let man = [
      `S(Manpage.s_description),
      `P(
        "Synchronizes dependencies in this workspace by looking into 3rdparty/package.json and 3rdparty/package.opam, downloading the necessary files, and verifying the integrity of all the packages. Additional BUILD files will be created if needed.",
      ),
      `P(
        "By passing in the --verify flag, the program will only verify the SHA256 in the lock files against the downloaded packages and exit.",
      ),
      `Blocks(Common.help),
    ];

    (
      Term.(const(sync) $ Common.flags $ workdir $ verify),
      Term.info("sync", ~doc, ~sdocs=Manpage.s_common_options, ~exits, ~man),
    );
  };
};

let default_cmd = {
  let doc = "a monorepo tool for Bazel and ML";
  let sdocs = Manpage.s_common_options;
  let exits = Term.default_exits;
  let man = Common.help;
  (
    Term.(ret(const(_ => `Help((`Pager, None))) $ Common.flags)),
    Term.info("retool", ~version="v0.0.1", ~doc, ~sdocs, ~exits, ~man),
  );
};

let cmds = [Sync.cmd];

let run = () => Term.(exit @@ eval_choice(default_cmd, cmds));
