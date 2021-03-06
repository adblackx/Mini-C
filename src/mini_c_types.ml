open Mini_c


(*Notre environnement*)
module Env = Map.Make(String)


(*Un type artificelle afin de conserver dans l'environnement des informations
  comme la liste des types de varibale pris par une fonction *)
type typage =
  | Typ of typ
  | TypFun of typ list * typ
  | TypTab of typ
  

(*Effectue une recherche dans notre evnrionnement et renvoie le type associé*)
let findEnv s env =
  try Env.find s env
  with Not_found -> failwith ("variable ou fonction " ^ s ^ " inexistante")


(**Gère les types qui sont polymorphique entre eux**)
let conv_implicite monTyp typCible = 
  if monTyp = typCible then monTyp 
else
  match monTyp, typCible with
  | Typ(Int), Typ(Bool) -> Typ(Bool)
  | Typ(Bool), Typ(Int) -> Typ(Int)
  | _,_ -> failwith "incomaptibilité de type"
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

  | Binop (_, e1, e2) ->  let t1 = conv_implicite (eval_expr e1 env) (Typ Int) in
                       let t2 = conv_implicite (eval_expr e2 env) (Typ Int) in
                       Typ(Bool)

  | And(e1, e2) ->  let t1 = conv_implicite (eval_expr e1 env) (Typ Bool) in
                    let t2 = conv_implicite (eval_expr e2 env) (Typ Bool) in
                    Typ(Bool)

  | Get(s) -> findEnv s env

  | Or(e1, e2) -> eval_expr (And(e1, e2)) env

  | Getab(s,x) -> let TypTab(x) = findEnv s env in Typ(x)
  
  | Call(f, arg) -> let tf = findEnv f env in
                    begin match tf with
                    | TypFun(l, tr) -> let _ =  compare_type l arg env in
                                       Typ(tr)

                    | _ -> failwith (f^" n'est pas une focntion") 
                    end
  | _ -> failwith ("expressions non reconnue")

and compare_type l0 l1 env =
  match l0, l1 with
  | (ta::tl0, b::tl1) ->  let tb = eval_expr b env in
                          let _ = conv_implicite tb (Typ ta) in 
                          compare_type tl0 tl1 env
  | ([], []) -> ()
  | (_,_) -> failwith "Les arguments passer à la fonction ne match pas"
;;



(**Renvoie un env et véirifie que la déclaration est bien correct**)
(**Utilisé pour globals et locals **)
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


(*On analyse ici la séquence d'instruction de la fonction f via des fonction en récursion croisé*)
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
  | _ -> failwith ("Instruction non reconnue dans la fonction"^f.name)

  

and

 eval_seq f l env =
  match l with
  | inst::tl -> let _ = eval_instr f inst env in
                let _ = eval_seq f tl env in ()
  | [] -> ()
;;


(*Renvoie un env, pas besoin d'evaluation on se contente d'ajouter 
les params à l'environnement locale à la focntion analysé *)
let rec eval_params l env =
  match l with
  | (s,t)::tl -> let env = Env.add s (Typ t) env in
                 eval_params tl env
  | [] -> env
;;


(**Ectrait le typ des paramètres d'une fonctions et renvoie typ list
c'est à dire le type de chaque argument pris par la fonction analysé**)
let rec extract_typ_fun p l =
  match p with
  | (str,tp)::tl ->  extract_typ_fun tl (l@[tp])
  | _ -> l
;;



(**Evalue chaque fonctions, en prenant soins de construire récursivement l'envrionnement
   de chaque fonction et d'ajouter à l'environement chaque fontion testé**)

let rec eval_functions l env =

  match l with
  | f::tl -> let () = Printf.printf "Eval fonctions %s \n" f.name in
             let lst_typ = extract_typ_fun (f.params) [] in
             let env = Env.add (f.name) (TypFun (lst_typ, f.return)) env in
             let env_loc = eval_params (f.params) env in

             let env_loc = eval_declaration (f.locals) env_loc in
             let _ = eval_seq f f.code env_loc in
             let () = Printf.printf "Fonctions %s bien typée \n" f.name in
            let _ = eval_functions tl env in
            ()

  | [] -> ()
;;



(*vérifie que le prog est bien typé
  env est de type (string * typage) list *)
let rec eval_prog (p:Mini_c.prog) env =
  let () = Printf.printf "Eval Prog \n" in
  let env = Env.add "b" (Typ(Int)) env in
  let env = eval_declaration p.globals env in
  let _ = eval_functions p.functions env in 
  let () = Printf.printf "Prog bien typé \n" in
  ()
  
;;


(*Lance la vérification du typage*)
let rec start_eval p =
  let () = print_string "VERIFICATION TYPAGE START\n" in
  let _ = eval_prog p Env.empty in
  let () =  print_string "TYPAGE CORRECT \n" in
  p
;;
