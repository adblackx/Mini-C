let () =
  let fichier = Sys.argv.(1) in
  let c = open_in fichier in
  let lexbuf = Lexing.from_channel c in
  let prog = Mini_c_parser.prog Mini_c_lexer.token lexbuf in
  let test = Mini_c_types.type_expr prog Mini_c_types.Env.empty in
  ignore(prog);
  close_in c;
  exit 0