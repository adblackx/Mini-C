{
  open Lexing
  open Printf
  exception Eof

  open Mini_c_parser

let tbl = Hashtbl.create 17;;
let assoc = [

        ("int",  TYPGEN(Int));
        ("bool",  TYPGEN(Bool));
        ("void",  TYPGEN(Void));
        ("struct",  TYPGEN(Struct("Struct")));
        ("if",   IF);
        ("else", ELSE);
        ("return", RETURN);
        ("putchar", PUTCHAR);
        ("putchar", PUTCHAR);
        ("while", WHILE);
        ("for", FOR);
        ("true", CST( 1));
        ("false", CST( 0));
]
       ;;
let _ = List.iter (fun (s, tok) -> Hashtbl.add tbl s tok) assoc;;

let min s1 s2 =
  if (String.length s1) > (String.length s2)
  then (String.length s2)
  else (String.length s1)
  ;;

let rec compare_path s1 s2 acc param =  
    match (acc) < (min s1 s2) with
    | true -> if s1.[acc] = s2.[acc] then compare_path s1 s2 (acc+1) (param+1)
              else  compare_path s1 s2 (acc+1) (param) 
    | false -> param
      ;;

(* fonctions qui cherche les similiarites selon un critre de d'un nombre de caractere successifs commun *)
let findSimilar1 text =
    
    if (String.length text) >= 3 then  
(
    let r = Str.regexp text in
  List.iter (
    fun (s, tok) ->
    let a = ( compare_path text s 0 0  ) in 
  (*  if a>= ((String.length text)/2) then  Printf.printf "\n text: %s s: %s : %b \n" text s true *)
    if a>= 2 then  Printf.printf "\n Dans le code: %s qui ressemble a s: %s : %b ils semblent similaires ?  \n" text s true
    else () 

    ) assoc
  )
else

  ()
  ;;

(* tentative d'utilisation de str pour la reconnaissance, mais pas assez probant *)

let findSimilar text =
    
    if (String.length text) >= 3 then  
(
    let r = Str.regexp text in
  List.iter (
    fun (s, tok) ->
    let a = ( let r1 = Str.regexp s in  Str.string_partial_match r s (min text s) ) in 
    if a then  Printf.printf "\n text: %s s: %s : %b \n" text s true
    else () 

    ) assoc
  )
else

  ()
  ;;
  

let file = Sys.argv.(1);;
let cout = open_out (file ^ ".doc");;
        
}



let alpha = ['a'-'z' 'A'-'Z']

let digit = ['0'-'9']*

let integer = '0' | (['1'-'9'] digit)

let space = [' ']+

let ident =
  (alpha) (alpha | digit | '_')*


let boolean = "true" | "false"


rule token = parse
  | "//"
  
  (*| "int" {TYPGEN(Int)}
  | "bool" {TYPGEN(Bool)}
  | "void" {TYPGEN(Void)}
  | "struct" {TYPGEN(Struct("Struct"))}

  | "putchar" {PUTCHAR}
  | "while" {WHILE}
  | "for" {FOR}
  
  | "if" {IF}
  | "return" {RETURN}
  | "else" {ELSE}
  | "true" {CST( 1)}
  | "false" {CST( 0)}*)

  | "." {DOT}

  | ident as id {
    match Hashtbl.find_opt tbl id 
    with
      | Some tok ->  tok
      | None -> (* Printf.printf " Mot: %s " id ;*) findSimilar1 id ;IDENT(id)
    }
  | integer as n { CST(int_of_string n) }
  
  
  | [' ' '\n' '\t' '\r'] { (); token lexbuf }

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
  | '>'   { SUP }
  | '='   { EQ }
  | "&&"   { ET }
  | "||"   { OU }
  | "!=" { NEQ }
  | "<="   { INFE }
  | ">="   { SUPE }
  | "["   { CROCHET_L }
  | "]"   { CROCHET_R }
  |'-'   { MOINS }


  |"/*" {comment lexbuf; token lexbuf}
  | "//" [^ '\n']* {(); token lexbuf}
  
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
  | eof    {Printf.printf "LEXING DONE\n" ;FIN }

and comment = parse
  | "*/"
      { () }
  
  | _
      { comment lexbuf }
  
  | eof
      { failwith "unterminated comment" }

(*and init_for = parse
  | "(" ([^ ';']* as id) ";" ([^ ';']* as test) ";" ([^ ')']* as ite) ")" 
              {let () = print_string id in token (Lexing.from_string id); token lexbuf; SEMI; token (Lexing.from_string "while(");  token (Lexing.from_string test); token (Lexing.from_string " ) {") ; read_code ite lexbuf}

and read_code  ite = parse
  | ("{" _* "}") as s {token (Lexing.from_string s)}
  | "}" { token (Lexing.from_string ite); ACOL_F; token lexbuf  }*)

{

(*let rec token_to_string = function
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
*)
}