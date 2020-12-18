{
  open Lexing
  open Printf

  (*open Mini_c_parser*)

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

  type token =
    | IDENT of string
    | CST of int
    | EGAL
    | INT
    | BOOL
    | VOID
    | PUTCHAR
    | WHILE
    | IF
    | ELSE
    | RETURN
    | INF
    | FOIS
    | PLUS
    | MOINS
    | PAR_O
    | PAR_F
    | ACOL_O
    | ACOL_F
    | FIN
    | SEMI
    | COMMA
exception Eof

}



let alpha = ['a'-'z' 'A'-'Z']

let digit = ['0'-'9']*

let integer = ['1'-'9'] digit

let space = [' ']+

let ident =
  (alpha) (alpha | digit | '_')*

let boolean = "true" | "false"


rule token = parse
  | "int" {INT}
  | "bool" {BOOL}
  | "putchar" {PUTCHAR}
  | "While" {WHILE}
  
  | "if" {IF}
  | "return" {RETURN}
  | "void" {VOID}
  | "else" {ELSE}

  (*| ident as id
      { keyword_or_ident id }*)

  | ident as id {IDENT(id)}
  | integer as n
      { CST(int_of_string n) }

  | ['\n']
      { new_line lexbuf; token lexbuf }

  | [' ' '\t' '\r']+ { token lexbuf }

  (*| "(*"
      { comment lexbuf; token lexbuf }*)
  | ',' {COMMA}
  | ';' {SEMI}
  | '('   { PAR_O }
  | ')'   { PAR_F }
  | '{' {ACOL_O}
  | '}' {ACOL_F}
  | '+'   { PLUS }
  | '*'   { FOIS }
  | '<'   { INF }
  | '='   { EGAL }
  |'-'   { MOINS }

  (*| '-'   { MOINS }
  | "<>"  { INEGAL }
  | "<="  { INFEGAL }
  | "&&"  { ET }
  | "||"  { OU }*)

  | _ as c
      { failwith
          (Printf.sprintf
             "invalid character: %c" c) }
  | eof    { FIN;raise Eof }

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
    | CST i -> sprintf "INT(%i)" i
    | PLUS -> sprintf "PLUS"
    | FOIS -> sprintf "FOIS"
    | MOINS -> sprintf "MOINS"
    | INT -> sprintf "INT"
    | BOOL -> sprintf "BOOL"
    | VOID -> sprintf "VOID"
    | EGAL -> sprintf "EGAL"
    | INF -> sprintf "INF"
    | IF -> sprintf "IF"
    | ELSE -> sprintf "ELSE"
    | RETURN -> sprintf "RETURN"
    | PAR_O -> sprintf "RPARENTHESIS"
    | PAR_F -> sprintf "LPARENTHESIS"
    | ACOL_O -> sprintf "ACOL_O"
    | ACOL_F -> sprintf "ACOL_F"
    | WHILE -> sprintf "WHILE"
    | PUTCHAR -> sprintf "PUTCHAR"
    (*| COMMENTAIRE -> sprintf "COMMENTAIRE"*)
    | FIN -> sprintf "FIN"
    | SEMI -> sprintf "SEMI"
    | COMMA -> sprintf "COMMA"

  let () =
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
        close_out cout;
}