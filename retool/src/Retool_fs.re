let read: string => string =
  path => {
    let in_file = open_in(path);
    let rec read' = contents =>
      switch (input_line(in_file)) {
      | exception End_of_file => contents
      | value => read'([value, ...contents])
      };
    read'([]) |> List.rev |> String.concat("\n");
  };
