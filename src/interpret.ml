open Format

  type typ = (*types des fonctions*)
    | Int
    | Bool
    | Void
    | Struct of string


    type expr =
    | Cst  of int
    | Add  of expr * expr
    | Mul  of expr * expr
    | Get  of string
    | Call of string * expr list
    | Lt of expr * expr
    | Lte of expr * expr
    | Eq of expr * expr
    | Neq of expr * expr
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



let tblVar = Hashtbl.create 17 ;; (*variables globales *)
(*let tblStruct = Hashtbl.create 17 ;; variables globales *)

let find tbl s =
  try Hashtbl.find tbl s
  with Not_found -> failwith ("can't find : " ^ s)
;; 

let replace tbl s v =
  try Hashtbl.replace tbl s v
  with Not_found -> failwith ("can't find : " ^ s)
;;


let rec depile tbl name =
	Hashtbl.remove tbl name;;


let rec depiler tbl var =
	begin
		match var with
			| t1::t2 -> let name,typv,valeur = t1 in depile tbl name ; depiler tbl t2
			| _ -> ()
	end

;;

(*
let rec findPileParam params acc =
	match param with
	| t1::t2 -> let a = find tblVar t1 in params (a::acc)
	| [] -> acc
;;
*)

let rec interp_instr inst func params hasheuse =
	begin
		match inst with 
		|  Putchar e ->
	      let code = interp_exp e hasheuse in
	      printf "%d" ( code) 
		| Set (s, e) ->
	      let v = interp_exp e hasheuse in
	      replace hasheuse s v
	    | Setab (name, s, e) ->
	      let v = interp_exp e hasheuse in
	      replace hasheuse name v  
	  	| If (e, st, se) ->
	      let b = interp_exp e hasheuse in
	      if intToBool b then (interp_seq st func params hasheuse) else interp_seq se func params hasheuse
	  	| While (e, s) ->
	      let b = interp_exp e hasheuse in
	      if intToBool b then interp_seq (s @ [While (e, s)]) func params hasheuse
	  	| Expr e ->
	     interp_exp e hasheuse
		| Return e ->
	     interp_exp e hasheuse
 	end
and interp_seq seq func params hasheuse =
	begin 
		match seq with
		| t1 :: t2 -> interp_instr t1 hasheuse ; interp_seq  t2 func params hasheuse
		| [] -> () (* ne retourne rien car modifie la memoire ici*)
	end


(*on met en dernier dans la pile les variables, 
	on remarque qu'on dépile jamais les variable gloables
	en faisat find on trouve le dernier x par exemple, les vairables locals masquent les globales
	donc on chrche d'abord dans le pile ce qu'on a en dernier, donc on empile puis dépile*)

and interp_func func params hasheuse =
	begin

		 interp_vars func.locals tblVar ; (* on met dans la pile les variables de f*)
		(* les parametres de la fonctions sont déjà dans la pile *)
			interp_seq (func.code) func params hasheuse;

	end
and

 intToBool a =
	begin 
		match a with
		|0 -> false
		|_ -> true
	end


and interp_exp e hasheuse =
	begin
	match e with
	| Cst i -> i
	| Add (e1,e2) -> (interp_exp e1) + (interp_exp e2)
	| Mul (e1,e2) -> (interp_exp e1) * (interp_exp e2)
	| Lt (e1,e2) ->   Bool.to_int((interp_exp e1)<(interp_exp e2)) 
	| Lte (e1,e2) ->   Bool.to_int((interp_exp e1)<=(interp_exp e2)) 
	| Lte (e1,e2) ->   Bool.to_int((interp_exp e1)<=(interp_exp e2)) 
	| Eq (e1,e2) ->   Bool.to_int((interp_exp e1)=(interp_exp e2)) 
	| Neq (e1,e2) ->   Bool.to_int((interp_exp e1)!=(interp_exp e2)) 
	| Or (e1,e2) ->   Bool.to_int( intToBool (interp_exp e1) || intToBool (interp_exp e2) ) 
	| And (e1,e2) ->   Bool.to_int( intToBool (interp_exp e1)&& intToBool (interp_exp e2)) 
	| Get (s) -> interp_exp (find tblVar s).(0) (*un seul élément car cst*)
	| Getab (name,indice) -> interp_exp (find tblVar name).(indice) (*indice i du tableau*)
	(*| Getstr (name,name_var) -> let res = (find tblVar name)*)
	(*| Call (nom_f,params) -> let princ = findFunc f nom_f in interp_func nom_f params*)
	end


and addTab size  =
	Array.create size (Cst 0) 


and addUniqueElement e =
	 Array.create 1 e
	

(* ajoute soit un tableau initalisé à 0 ou bien ajoute la constante 
hasheuse c'est la hastabl ou je met mes valeurs

*)
and

 interp_decla name typv valeur hasheuse =
	begin 
		match valeur with 
		| Exprd e -> Hashtbl.add hasheuse name (addUniqueElement (Cst(interp_exp e hasheuse)))   
		| Tabl e ->  Hashtbl.add hasheuse name (addTab e)
		| Structd e -> ()
		| Empty -> ()
	end
and



 interp_vars vs hasheuse =
	begin
		match vs with
		| t1::t2 -> let name,typv,valeur = t1 in interp_decla name typv valeur hasheuse ; interp_vars t2 hasheuse
		| _ -> ()
	end

and

  findFunc f cible =
	begin
		match f with
		| t1::t2 -> if t1.name = cible then t1 else findFunc t2 cible
		| _ -> failwith "PAS DE FONCTION nommée %s" cible 
	end
and




 interp_main f = (*cette fonction n'a pas de paramètres par defaut*)

	begin

		let princ = findFunc f "main"
		in interp_func princ hasheuse []
	end
and
 interp_prog p =
 	let glob = p.globals in 
 	let func = p.functions in
 	interp_vars glob tblVar;
 	interp_main func
;;


(* 

ocamlc interpret.ml -o interpret.o
./test_prog.o

let glob = [("a", Int, Exprd(Cst(1)) ); ("b", Bool,  Exprd(Cst(1))) ]
let p =  { globals = glob; functions = [] };;
let _ = print_prog p;;*)