{
  open Lexing
  open Mini_c_parser

  let keyword_or_ident =
    let h = Hashtbl.create 17 in
    List.iter
      (fun (s, k) -> Hashtbl.add h s k)
      [ "fun",  FUN;
        "let",  LET;
        "in",   IN;
        "if",   IF;
        "then", THEN;
        "else", ELSE;
      ] ;
    fun s ->
      try  Hashtbl.find h s
      with Not_found -> IDENT(s)
}

let alpha = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let ident =
  (alpha | digit) (alpha | digit | '_')*

rule token = parse
  | ['\n']
      { new_line lexbuf; token lexbuf }
  | [' ' '\t' '\r']+
      { token lexbuf }
  | "(*"
      { comment lexbuf; token lexbuf }
  | digit+ as n
      { CST(int_of_string n) }
  | ident as id
      { keyword_or_ident id }
  | '+'   { PLUS }
  | '*'   { ETOILE }
  | '-'   { MOINS }
  | '='   { EGAL }
  | "<>"  { INEGAL }
  | '<'   { INF }
  | "<="  { INFEGAL }
  | "&&"  { ET }
  | "||"  { OU }
  | "->"  { FLECHE }
  | '('   { PAR_O }
  | ')'   { PAR_F }
  | _ as c
      { failwith
          (Printf.sprintf
             "invalid character: %c" c) }
  | eof    { FIN }

and comment = parse
  | "*)"
      { () }
  | "(*"
      { comment lexbuf; comment lexbuf }
  | '\n'
      { new_line lexbuf; comment lexbuf }
  | _
      { comment lexbuf }
  | eof
      { failwith "unterminated comment" }