
(* The type of tokens. *)

type token = 
  | WHILE
  | TYPGEN
  | TRUE
  | SEMI
  | RETURN
  | PUTCHAR
  | PLUS
  | PAR_O
  | PAR_F
  | INF
  | IF
  | IDENT of (string)
  | FIN
  | FALSE
  | ETOILE
  | ELSE
  | EGAL
  | CST of (int)
  | COMMA
  | ACOL_O
  | ACOL_F

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Mini_c.prog)
