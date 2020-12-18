type binop =
  | Add | Mul | Sub
  | Eq | Neq | Lt | Le
  | And | Or

type expr = 
  | Cst   of int
  | Var   of string
  | Binop of binop * expr * expr
  | Fun   of string * expr
  | App   of expr * expr
  | If    of expr * expr * expr
  | Letin of string * expr * expr

let rec mk_fun args e =
  match args with
  | [] -> e
  | x::args ->
    Fun(x, mk_fun args e)
  