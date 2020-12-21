(*open Test_prog*)

let () =
 
  let fichier = Sys.argv.(1) in
  let c = open_in fichier in
  
  let lexbuf = Lexing.from_channel c in
  let prog = Mini_c_parser.prog Mini_c_lexer.token lexbuf in
  Test_prog.print_prog prog ; (*commenter tout cette ligne pour enlever le print*) 
  let _ = Mini_c_types.start_eval prog in (**Commenter cette ligne pour ne pas faire de verification de type**)
  ignore(prog);
  close_in c;
 