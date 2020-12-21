open Mini_c


module Env = Map.Make(String)

type typage =
  | Typ of typ
  | TypFun of typ list * typ
  | TypTab of typ
  

let findEnv s env =
  try Env.find s env
  with Not_found -> failwith "variable ou fonction inexistante"


let conv_implicite monTyp typCible = 
  if monTyp = typCible then monTyp 
else
  match monTyp, typCible with
  | Typ(Int), Typ(Bool) -> Typ(Bool)
  | Typ(Bool), Typ(Int) -> Typ(Int)
  | _,_ -> failwith "incomaptibilité de type"
;;



let str_typ tp = 
  if tp = Typ(Int) then "Int"
  else "Bool"
;;

let rec extract_typ_fun p l =
  match p with
  | (str,tp)::tl -> if tp = Int 
                    then 
                      let () = Printf.printf "Int" in extract_typ_fun tl (l@[tp])
                    else 
                      let () = Printf.printf "Bool" in extract_typ_fun tl (l@[tp])
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

  | Cst x -> Typ(Int)

  | Add(e1, e2) ->  let _ = conv_implicite (eval_expr e1 env) (Typ Int) in (*Erreur si la convertion est impossible donc rien ne sert de comparer*)
                    let _ = conv_implicite (eval_expr e2 env) (Typ Int) in
                    Typ(Int)

  | Mul(e1, e2) ->  let _ = conv_implicite (eval_expr e1 env) (Typ Int) in
                    let _ = conv_implicite (eval_expr e2 env) (Typ Int) in
                    Typ(Int)

  | Lt (e1, e2) ->  let t1 = conv_implicite (eval_expr e1 env) (Typ Int) in
                    let t2 = conv_implicite (eval_expr e2 env) (Typ Int) in
                    Typ(Bool)

  | Lte (e1, e2) -> eval_expr (Lt(e1, e2)) env

  | Eq (e1, e2) -> eval_expr (Lt(e1, e2)) env

  | Neq (e1, e2) -> eval_expr (Lt(e1, e2)) env

  | Get(s) -> findEnv s env

  | And(e1, e2) ->  let t1 = conv_implicite (eval_expr e1 env) (Typ Bool) in
                    let t2 = conv_implicite (eval_expr e2 env) (Typ Bool) in
                    Typ(Bool)

  | Or(e1, e2) -> eval_expr (And(e1, e2)) env

  | Getab(s,x) -> let TypTab(x) = findEnv s env in Typ(x)
  
  | Call(f, arg) ->
    let tf = findEnv f env in
    begin match tf with
    | TypFun(l, tr) -> let _ =  compare_type l arg env in
                       Typ(tr)

    | _ -> failwith (f^" n'est pas une focntion") 
    end

and compare_type l0 l1 env =
  match l0, l1 with
  | (ta::tl0, b::tl1) ->  let tb = eval_expr b env in
                          let () = Printf.printf "%s :: %s \n" (str_typ (Typ ta)) (str_typ tb) in
                          let _ = conv_implicite tb (Typ ta) in 
                          compare_type tl0 tl1 env
  | ([], []) -> ()
  | _ -> failwith "Les arguments passer à la fonction ne match pas"
;;



(**Renvoie un env et véirifie que la déclaration est bien typé**)
(**Utilisé pour globals et locals **)
(**l est de type (string * typ * decla) list
   env est de type (string * typ) list *)
let rec eval_declaration l env = 
  match l with
  | (s, t, Tabl(x))::tl ->  let () = Printf.printf "Eval Tableau %s \n" s in
                            let env = Env.add s (TypTab t) env in
                            let () = Printf.printf "Tableau %s bien typée \n" s in
                            eval_declaration tl env

  | (s, t, Exprd(e))::tl ->  let () = Printf.printf "Eval variable %s \n" s in
                            let te = conv_implicite (eval_expr e env) (Typ t) in
                            if te = (Typ t) 
                            then
                              let env = Env.add s (Typ t) env in
                              let () = Printf.printf "variable %s bien typée \n" s in
                              eval_declaration tl env
                            else failwith "declaration invalide"

  | (s, t, Empty)::tl  ->  let env = Env.add s (Typ t) env in
                           eval_declaration tl env
  | _ ->  env

;;


(**Renvoie un tyoe où une erreur ? **)
let rec eval_instr f instr env =
  match instr with
  | Setab(s, x, e) -> let te = eval_expr e env in
                      let TypTab(ts) = findEnv s env in
                      if (conv_implicite (Typ ts) te) = te
                      then ()
                      else failwith ("Affectation de tableau incorrect dans focntion : " ^ f.name)
                      

  | Putchar(e) -> let _ = eval_expr e env in
                          ()
  | Set(s, e) -> let ts = findEnv s env in
                 let te = eval_expr e env in
                 if ts = (conv_implicite te ts)
                 then ()
                 else failwith ("affectation incorrect dans focntion : " ^ f.name)

  | If(e,s1,s2) -> let t1 = eval_expr e env in
                   if (conv_implicite t1 (Typ Bool)) = (Typ Bool)
                   then
                   let _ = eval_seq f s1 env in 
                   let _ = eval_seq f s2 env in
                   ()
                   else failwith ("If incorrect dans focntion : " ^ f.name)

  | While(e, s) -> let t1 = eval_expr e env in
                   if t1 = (conv_implicite t1 (Typ Bool))
                   then let _ = eval_seq f s env in
                   ()
                   else failwith ("While incorrect dans focntion : " ^ f.name)

  | Return(e) -> let t1 = eval_expr e env in
                 if (conv_implicite t1 (Typ f.return)) = Typ(f.return)
                 then ()
                 else failwith ("type de retour de la focntion " ^ f.name ^ " incorrect")
  | Expr(e) -> let _ = eval_expr e env in
                      ()

  

and

(*f = fonction qu'on evalue
  instr = instr de la fonctionf qu'on évalue
  env environnement dans lequel on évalue*)
 eval_seq f l env =
  match l with
  | inst::tl -> let _ = eval_instr f inst env in
                let _ = eval_seq f tl env in ()
  | [] -> ()
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

let rec extract_typ_fun p l =
  match p with
  | (str,tp)::tl ->  extract_typ_fun tl (l@[tp])
  | _ -> l
;;


(**Renvoie un env avec les fonctions rajouter à l'env,
  vérifie que les var locals et les seqs sont bien typé,
  env_local est un environement transitoire propre à la fonction
  l est de type (string * typ) list 
  env est de type fun_def list**)

let rec eval_functions l env =

  match l with
  | f::tl -> let () = Printf.printf "Eval fonctions %s \n" f.name in
             let lst_typ = extract_typ_fun (f.params) [] in
             let env = Env.add (f.name) (TypFun (lst_typ, f.return)) env in
             let env_loc = eval_params (f.params) env in

             let env_loc = eval_declaration (f.locals) env_loc in
             let _ = eval_seq f f.code env_loc in
             (*if conv_implicite t0 (Typ f.return) = f.return
             then*) let () = Printf.printf "Fonctions %s bien typée \n" f.name in
            let _ = eval_functions tl env in
            ()
             (*else failwith "type error code : Non void focntion with no return"*)

  | [] -> () (*ou () ?*)
;;



(*vérifie que le prog est bien typé
  p est de type prog
  env est de type (string * typ) list *)
let rec eval_prog (p:Mini_c.prog) env =
  let () = Printf.printf "Eval Prog \n" in
  let env = Env.add "b" (Typ(Int)) env in
  let env = eval_declaration p.globals env in
  let _ = eval_functions p.functions env in 
  let () = Printf.printf "Prog bien typé \n" in
  ()
  
;;


let rec start_eval p =
  let () = print_string "VERIFICATION TYPAGE START\n" in
  let _ = eval_prog p Env.empty in
  let () =  print_string "TYPAGE CORRECT \n" in
  p
;;
