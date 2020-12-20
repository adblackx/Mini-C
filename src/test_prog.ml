  type typ = (*types des fonctions*)
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

   type instr =
    | Putchar of expr
    | Set     of string * expr
    | If      of expr * seq * seq
    | While   of expr * seq
    | Return  of expr
    | Expr    of expr
  and seq = instr list


  type decla = (*types pour le pasrser*)
    | Exprd of expr
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



let rec print_type e =
	match e with
	|Int -> Printf.printf "Int" 
	|Bool -> Printf.printf "Bool" 
	|Void -> Printf.printf "Void" 
;;



let rec print_exp e = 
	begin match e with
	| Cst n -> Printf.printf "%d" n
	| Add (e1,e2) ->   (print_exp e1) ;Printf.printf " + " ;(print_exp e2)
	| Mul (e1,e2) -> (print_exp e1) ;Printf.printf " * " ;(print_exp e2)
	| Lt (e1,e2) -> (print_exp e1) ;Printf.printf " < " ;(print_exp e2)
	| Get (e) -> Printf.printf "Get %s"  e
	| Call (e, t) -> Printf.printf "Get %s"  e; print_list_expr(t) 
	end
and
 print_list_expr e =
	match e with
	| t1::t2 -> print_exp t1; print_list_expr t2
	| [] -> ()
;;


let rec print_decla d = 
	match d with
	| Empty -> Printf.printf "%Empty"
	| Exprd x -> print_exp x;;
;;


let rec print_list_instr i=
	match i with
	| t1::t2 -> print_instr t1; print_list_instr t2
	| [] -> ()
;;

let rec print_instr i=
	match i with
	| Putchar i ->  Printf.printf "Putchar" print_exp i
	| Set (s,i) ->  Printf.printf "%s = " s; print_exp i
	| If (e,s1,s2) ->  Printf.printf "If( " print_exp e; 
						Printf.printf ") {" ; 
						print_list_instr s1 ; 
						Printf.printf "{";
						print_list_instr s2 ; 
						Printf.printf "}";

	| While (e,s1) ->  Printf.printf "While( " print_exp i; Printf.printf ") " print_list_instr s1
	| Return i ->  Printf.printf "Return " print_exp i
	| Expr i ->  print_exp i




let rec print_glob g =
	match g with 
	| (s, t, d)::tl -> Printf.printf "%s"; print_type t ; print_decla d ; print_glob tl
	| [] -> ()

;;


let print_prog p =
	let glob = p.globals in
	let func = p.functions in
	print_glob glob in
	print_func func;;