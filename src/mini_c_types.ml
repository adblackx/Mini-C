(**
   Typage de FUN
*)
open Mini_c

type typage =
  | Typ of typ
  | TypFun of typ list * typ

  

(*type typ = (*types des fonctions*)
  | Int
  | Bool
  | Void

type expr =
    | Cst  of int
    | Add  of expr * expr
    | Mul  of expr * expr
    | Lt   of expr * expr
    | Get  of string
    | Call of string * expr list

type decla = (*types pour le pasrser*)
| Boolean of bool
| Exprd of expr
| Empty

type instr =
| Putchar of expr
| Set     of string * expr
| If      of expr * seq * seq
| While   of expr * seq
| Return  of expr
| Expr    of expr
and seq = instr list

    
type typage =
  | Typ of typ
  | TypFun of typ list * typ


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
*)

module Env = Map.Make(String)






let rec extract_typ p l =
  match p with
  | (str,tp)::tl -> extract_typ tl (tp::l)
  | _ -> l
;;


(*Renvoie un env, pas besoin d'evaluation ici
  l est de type (string * typ) list
  env est de type (string * typ) list *)
let rec eval_params l env =
  match l with
  | (s,t)::tl -> let env = Env.add s (Typ t) env in
                 eval_params tl env
  | [] -> env
;;




(**Evalue les expressions**)
let rec eval_expr (e: expr) (env: typage Env.t): typage = match e with

  | Cst _ -> Typ(Int)

  | Add(e1, e2) ->
    let t1 = eval_expr e1 env in
    let t2 = eval_expr e2 env in
    if t1 = Typ(Int) && t2 = Typ(Int)
    then Typ(Int)
    else failwith "type error code : 93 in eval_expr"

  | Mul(e1, e2) ->
    let t1 = eval_expr e1 env in
    let t2 = eval_expr e2 env in
    if t1 = Typ(Int) && t2 = Typ(Int)
    then Typ(Int)
    else failwith "type error code : 100 in eval_expr"

  | Lt(e1, e2) ->
    let t1 = eval_expr e1 env in
    let t2 = eval_expr e2 env in
    if t1 = Typ(Int) && t2 = Typ(Int)
    then Typ(Bool)
    else failwith "type error code : 107 in eval_expr" 

  | Get(s) -> Env.find s env

  | Call(f, arg) ->
    let tf = Env.find f env in
    begin match tf with
    | TypFun(l, tr) -> if compare_type l arg env
                       then Typ(tr)
                       else failwith "type error code : 116 in eval_expr"
    | _ -> failwith "type error code : 117 in eval_expr"
    end

and compare_type l0 l1 env =
  match l0, l1 with
  | (ta::tl0, b::tl1) -> let tb = eval_expr b env in
                           if Typ(ta) = tb then compare_type tl0 tl1 env
                         else false
  | ([], []) -> true
  | _ -> false
;;

let rec eval_decla t d env =
  match d with
  | Empty -> ()
  | Boolean(b) -> if t = Typ(Bool) then ()
                  else failwith "type error code : 133 in eval_expr"
  | Exprd(e) -> let eval = eval_expr e env in 
                if t = eval then ()
                  else failwith "type error code : 136 in eval_expr"
;;
(**Renvoie un env et véirifie que la déclaration est bien typé**)
(**Utilisé pour globals et locals **)
(**l est de type (string * typ * decla) list
   env est de type (string * typ) list *)
let rec eval_declaration l env = 
  match l with
  | (s, t, d)::tl ->  let () = Printf.printf "Eval variable %s \n" s in
                      let env = Env.add s (Typ t) env in
                      eval_decla (Typ t) d env;
                      let () = Printf.printf "variable %s bien typée \n" s in
                      eval_declaration tl env
  | [] -> env
;;


(**Renvoie un tyoe où une erreur ? **)
let rec eval_instr f instr env =
  match instr with
  | Putchar(e) -> let _ = eval_expr e env in
                          ()
  | Set(s, e) -> let ts = Env.find s env in
                 let te = eval_expr e env in
                 if ts = te 
                 then ()
                 else failwith "type error code : 160 in eval_instr"

  | If(e,s1,s2) -> let t1 = eval_expr e env in
                   if t1 = Typ(Bool)
                   then
                   let _ = eval_seq f s1 env in 
                   let _ = eval_seq f s2 env in
                   ()
                   else failwith "type error code : 167 in eval_instr"

  | While(e, s) -> let t1 = eval_expr e env in
                   if t1 = Typ(Bool) 
                   then let _ = eval_seq f s env in
                   ()
                   else failwith "type error code : 172 in eval_instr"

  | Return(e) -> let t1 = eval_expr e env in
                 if t1 = Typ(f.return)
                 then ()
                 else failwith "type error code : 177 in eval_instr" (**qqch à faire ici ? vérifier que type retour = retour focntion**)
  | Expr(e) -> let _ = eval_expr e env in
                      ()
and

(*f = fonction qu'on evalue
  instr = instr de la fonctionf qu'on évalue
  env environnement dans lequel on évalue*)
 eval_seq f l env =
  match l with
  | inst::tl -> let _ = eval_instr f inst env in ()
  | [] -> ()
  (*| [] -> ()*) (*crée une erreur donc on surppime ? *)
;;

(**Renvoie un env avec les fonctions rajouter à l'env,
  vérifie que les var locals et les seqs sont bien typé,
  env_local est un environement transitoire propre à la fonction
  l est de type (string * typ) list 
  env est de type fun_def list**)

let rec eval_functions l env =

  match l with
  | f::tl -> let () = Printf.printf "Eval fonctions %s \n" f.name in
             let lst_typ = extract_typ (f.params) [] in
             let env = Env.add (f.name) (TypFun (lst_typ, f.return)) env in
             let env_loc = eval_params (f.params) env in
             let env_loc = eval_declaration (f.locals) env_loc in
             let () = Printf.printf "Fonctions %s bien typée \n" f.name in
             eval_seq f f.code env_loc;
             eval_functions tl env
  | [] -> env (*ou () ?*)
;;










(*vérifie que le prog est bien typé
  p est de type prog
  env est de type (string * typ) list *)
let rec eval_prog (p:Mini_c.prog) env =
  let () = Printf.printf "Eval Prog \n" in
  let env = eval_declaration p.globals env in
  let _ = eval_functions p.functions env in 
  let () = Printf.printf "Prog bien typé \n" in
  ()
  
;;

let rec eval_start p =
  let _ = eval_prog p Env.empty in
  p
;;

(*
let glob = [("a", Int, Exprd(Cst(1)) ); ("b", Bool, Boolean(true)) ]

let p =  { globals = glob; functions = [] };;

let _ = eval_prog p Env.empty;;*)