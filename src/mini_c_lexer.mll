{
  open Lexing
  open Printf
  exception Eof

  open Mini_c_parser

  (*let keyword_or_ident =
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
      with Not_found -> IDENT(s)*)
  let file = Sys.argv.(1)
  let cout = open_out (file ^ ".doc")

}



let alpha = ['a'-'z' 'A'-'Z']

let digit = ['0'-'9']*

let integer = ['1'-'9'] digit

let space = [' ']+

let ident =
  (alpha) (alpha | digit | '_')*

let boolean = "true" | "false"


rule token = parse
  | "int" {TYPGEN(Int)}
  | "bool" {TYPGEN(Bool)}
  | "void" {TYPGEN(Void)}

  | "putchar" {PUTCHAR}
  | "While" {WHILE}
  
  | "if" {IF}
  | "return" {RETURN}
  | "else" {ELSE}
  | "true" {CST(int_of_string n)}
  | "false" {CST(int_of_string n)}

  (*| ident as id
      { keyword_or_ident id }*)

  | ident as id {IDENT(id)}
  | integer as n
      { CST(int_of_string n) }

  

  | [' ' '\n' '\t' '\r'] { token lexbuf }

  (*| "(*"
      { comment lexbuf; token lexbuf }*)
  | ',' {COMMA}
  | ';' {SEMI}
  | '('   { PAR_O }
  | ')'   { PAR_F }
  | '{' {ACOL_O}
  | '}' {ACOL_F}
  | '+'   { PLUS }
  | '*'   { ETOILE }
  | '<'   { INF }
  | '='   { EGAL }
  |'-'   { MOINS }
  
(*
  | '-'   { MOINS }
  | "<>"  { INEGAL }
  | "<="  { INFEGAL }
  | "&&"  { ET }
  | "||"  { OU }*)

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

{
let rec token_to_string = function
    | IDENT s -> sprintf "IDENT(%s)" s
    | CST i -> sprintf "CST(%i)" i
    | PLUS -> sprintf "PLUS"
    | ETOILE -> sprintf "FOIS"
    | MOINS -> sprintf "MOINS"
    | TYPGEN Int -> sprintf "INT"
    | TYPGEN Bool -> sprintf "BOOL"
    | TYPGEN Void -> sprintf "VOID"
    | EGAL -> sprintf "EGAL"
    | INF -> sprintf "INF"
    | IF -> sprintf "IF"
    | ELSE -> sprintf "ELSE"
    | RETURN -> sprintf "RETURN"
    | PAR_O -> sprintf "PAR_O"
    | PAR_F -> sprintf "PAR_F"
    | ACOL_O -> sprintf "ACOL_O"
    | ACOL_F -> sprintf "ACOL_F"
    | WHILE -> sprintf "WHILE"
    | PUTCHAR -> sprintf "PUTCHAR"
    (*| COMMENTAIRE -> sprintf "COMMENTAIRE"*)
    (*| FIN -> sprintf "FIN"*)
    | SEMI -> sprintf "SEMI"
    | COMMA -> sprintf "COMMA"
    | FALSE -> sprintf "FALSE"
    | TRUE -> sprintf "TRUE"

  (*let () =
    (* Ouverture du fichier à analyser *)
    let cin = open_in file in
    try
      (* Initialisation de la structure [lexbuf] qui sera utilisée par les
         fonctions d'analyse *)
      let lexbuf = Lexing.from_channel cin in
      (* Boucle de lecture des lexèmes.*)
      while true do        
        let tok = token lexbuf in
        printf "%s\n" (token_to_string tok)
      done
      (* Lorsque la fin de fichier est atteinte : fermeture des fichiers
         et affichage d'un bilan *)
    with
      | Eof ->
        close_in cin;
        close_out cout;*)
}