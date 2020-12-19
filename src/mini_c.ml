  type prog = {
    globals:   (string * typ * decla) list; 
    functions: fun_def list;
  }

  type fun_def = { 
    name:   string;
    params: (string * typ) list;
    return: typ;
    locals: (string * typ * decla) list;
    code:   seq;
  }

  type typ = (*types des fonctions*)
    | Int
    | Bool
    | Void

  type decla = (*types pour le pasrser*)
    | Integer of int
    | Boolean of bool
    | Expr of expr
    | Empty

   type instr =
    | Putchar of expr
    | Set     of string * expr
    | If      of expr * seq * seq
    | While   of expr * seq
    | Return  of expr
    | Expr    of expr
  and seq = instr list

    type expr =
    | Cst  of int
    | Add  of expr * expr
    | Mul  of expr * expr
    | Lt   of expr * expr
    | Get  of string
    | Call of string * expr list