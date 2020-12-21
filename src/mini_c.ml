  type typ = (*types des fonctions*)
    | Int
    | Bool
    | Void
    | Struct of string

  type binop =
  | Le  | Eq  | Neq | Lt 
  | Gt  |Gte

    type expr =
    | Cst  of int
    | Add  of expr * expr
    | Mul  of expr * expr
    | Get  of string
    | Call of string * expr list
    | Binop of binop * expr * expr
    | Or of expr * expr
    | And of expr * expr
    | Getab of string * int (*nom du tableau, indice*)
    | Getstr of string * string (*nom du struct, nom element*)

   type instr =
    | Putchar of expr
    | Set     of string * expr
    | Setab     of string * int * expr (*nom du tableau, indice, la valeur*)
    | Setstr     of string * string * expr (*nom de la struct, nom element, la valeur*)
    | If      of expr * seq * seq
    | While   of expr * seq
    | Return  of expr
    | Expr    of expr
  and seq = instr list


  type decla = (*types pour le pasrser*)
    | Exprd of expr
    | Tabl of int (*taille du tableau*)
    | Structd of (string * typ * decla) list (*suite de declaration*)
    | Empty


    type fun_def = { 
    name:   string;
    params: (string * typ) list;
    return: typ;
    locals: (string * typ * decla) list;
    code:   seq;
  }

  type prog = {
    globals:   (string * typ * decla) list; 
    functions: fun_def list;
  }

