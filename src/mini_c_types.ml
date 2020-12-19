(**
   Typage de FUN
*)
open Mini_c

type typ =
  | TypInt
  | TypBool
  | TypVoid
  | TypFun of typ * typ


      
module Env = Map.Make(String)

(**Renvoie un env et véirifie que la déclaration est bien typé**)
(**Utilisé pour globals et locals **)
(**l est de type (string * typ * decla) list
   env est de type (string * typ) list *)
let rec eval_decalaration tl env = 
  match l with
  |  (s, t, d)::tl -> let env = Env.add s t env in
                      eval_expr d env;
                      eval_decalaration tl env
  | [] -> env
;;

(**Renvoie un env avec les focntions rajouter à l'env,
  vérifie que les var locals et les seqs sont bien typé,
  env_local est un environement transitoire propre à la fonction
  l est de type (string * typ) list 
  env est de type fun_def list**)
let rec eval_functions l env =
  match l with
  | f::tl -> let env = Env.add f.name f.return env in
             let env_loc = eval_params f.params env in
             let env_loc = eval_decalaration f.locals env;
             eval_seq f.code env_loc;
             eval_functions tl env
  | [] -> env
;;


(*Renvoie un env, pas besoin d'evaluation ici
  l est de type (string * typ) list
  env est de type (string * typ) list *)
let rec eval_params l env =
  match l with
  | (s,t)::tl -> let env = Env.add s t env in
                 eval_params tl env
  | [] -> env
;;

let rec eval_prog p env =





let rec eval_prog (p: prog) (env: typ Env.t): type =
  let globals =  p.globals in
  let functions = p.functions in
  
  match globals with
  | (s, t, d)::tl -> let p0 = {globals = tl; functions = p.functions} in
                     eval_prog p0 (Env.add s t);eval_globals
  | [] -> let functions = p.functions in
          match functions with
          | f::tl -> let p0 = {globals = p.globals; functions = p.functions} in
                     eval_prog p0 (Env.add f.name f.return)
          | _ -> expr2
;;

let rec functions =
  
let rec type_expr (e: expr) (env: typ Env.t): typ = match e with

(* 5.3 video
  -------------
   Γ ⊢ n : int
*)
  | Cst _ -> Printf.printf ;TypInt

(*
   Γ ⊢ e₁ : int     Γ ⊢ e₂ : int
  -------------------------------
       Γ ⊢ Add(e₁, e₂) : int
*)
  | Add(e1, e2) ->
    let t1 = type_expr e1 env in
    let t2 = type_expr e2 env in
    if t1 = TypInt && t2 = TypInt
    then TypInt
    else failwith "type error"

(*
  --------------
   Γ ⊢ x : Γ(x)
*)    
  | Var(x) -> Env.find x env

(*
   Γ ⊢ e₁ : τ₁      Γ, x:τ₁ ⊢ e₂ : τ₂
  ------------------------------------
       Γ ⊢ let x = e₁ in e₂ : τ₂
*)    
  | Let(x, e1, e2) ->
    let t1 = type_expr e1 env in
    type_expr e2 (Env.add x t1 env)

(*
        Γ, x:τ₁ ⊢ e : τ₂
  ---------------------------
   Γ ⊢ fun x -> e : τ₁ ⟶ τ₂
*)
  | Fun(x, tx, e) ->
    let te = type_expr e (Env.add x tx env) in
    TypFun(tx, te)

(*
   Γ ⊢ e₁ : τ₂ ⟶ τ₁     Γ ⊢ e₂ : τ₂
  ------------------------------------
             Γ ⊢ e₁ e₂ : τ₁
*)    
  | App(f, a) ->
    let tf = type_expr f env in
    let ta = type_expr a env in
    begin match tf with
      | TypFun(tx, te) ->
        if tx = ta
        then te
        else failwith "type error"
      | _ -> failwith "type error"
    end