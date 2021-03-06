open Mini_c

let compteur_acc = ref 0;;
let compteur_l = ref 0;;

let rec print_type e =
	match e with
	|Int -> Printf.printf "Int" 
	|Bool -> Printf.printf "Bool" 
	|Void -> Printf.printf "Void"
	| _ -> Printf.printf " "
;;

let rec print_tab compteur =
	if compteur >0 then Printf.printf "\t"
	else ()
	;; 
let rec print_n compteur =
	if compteur >0 then Printf.printf "\n"
	else ()
	;; 

let op_to_string op = 
	match op with
	| Lt -> Printf.printf "Lt( "
	| Lte -> Printf.printf "Lte( "
	| Gt -> Printf.printf "Gt( "
	| Gte -> Printf.printf "Gte( "
	| Eq -> Printf.printf "Eq( "
	| Neq -> Printf.printf "Neq( "
;;

let rec print_exp e = 
	begin match e with
	| Cst n -> Printf.printf "%d" n
	| Add (e1,e2) ->  Printf.printf " Add(";  (print_exp e1) ;Printf.printf "," ;(print_exp e2) ; Printf.printf ")"
	| Mul (e1,e2) -> Printf.printf "Mul(";  (print_exp e1) ;Printf.printf "," ;(print_exp e2) ; Printf.printf ")"
	| Binop(op, e1, e2) -> (op_to_string op);  (print_exp e1) ;Printf.printf "," ;(print_exp e2) ; Printf.printf ")"
	| Get (e) -> Printf.printf "Get(%s)"  e
	| Call (e, t) -> Printf.printf "Call (%s)"  e; print_list_expr(t)
	| Or(e1, e2) -> Printf.printf " Or(";  (print_exp e1) ;Printf.printf "," ;(print_exp e2) ; Printf.printf ")"
	| And(e1, e2) -> Printf.printf " ANd(";  (print_exp e1) ;Printf.printf "," ;(print_exp e2) ; Printf.printf ")"
	| Getab (s,i) ->  Printf.printf " Getab(%s,%d)" s i    
    | Getstr (s1,s2) ->  Printf.printf " Getab(%s,%s)" s1 s2   

	end
and
 print_list_expr e =
	match e with
	| t1::t2 -> print_exp t1; print_list_expr t2
	| [] -> ()
;;


let rec print_decla d = 
	 
	match d with
	| Empty -> Printf.printf "Empty"
	| Exprd (x) -> Printf.printf "="; print_exp x
	| _ -> Printf.printf " "
	
;;

let rec print_list_instr i=
	begin 
	match i with
	| t1::t2 -> Printf.printf "\n"; print_tab !compteur_acc ;print_instr t1; print_list_instr t2; (* Printf.printf "\n" *)
	| [] -> ()
	end
and

 print_instr i=
	match i with
	| Putchar i ->  Printf.printf "Putchar("; print_exp i ;  Printf.printf ")"
	| Set (s,i) ->  Printf.printf "Set(%s" s; print_exp i ; Printf.printf ")"
	| If (e,s1,s2) ->  Printf.printf "If( "; print_exp e; 
						Printf.printf ")\n" ; 
						print_list_instr s1 ; 
						Printf.printf "(";
						print_list_instr s2 ; 
						Printf.printf ")\n";

	| While (e,s1) ->  Printf.printf "While( "; print_exp e; Printf.printf ")( \n"; print_list_instr s1;  Printf.printf ") \n"
	| Return i ->  Printf.printf "Return() "; print_exp i ; Printf.printf ")\n"
	| Expr i ->  print_exp i
	| _ -> Printf.printf " "




let rec print_var g =
	match g with  (* nom type et declaration/ou rien *)
	| (s, t, d)::tl -> print_type t ; Printf.printf " %s " s ; print_decla d ; Printf.printf ";  " ;print_var tl

	| [] -> Printf.printf " \n"
;;

let rec print_param p=
	match p with
	| (s,t)::tl -> print_type t; Printf.printf " %s " s;  print_param tl
	| [] -> ()
;;

let rec print_list_func l =
	match l with
	| deb::fin -> Printf.printf "\n name: %s " deb.name; Printf.printf "\n return:"; print_var deb.locals;
					Printf.printf "\n params:  "; print_param deb.params;
				Printf.printf " locals:  "; print_var deb.locals; Printf.printf " \n ";

					print_list_func fin
	| [] -> Printf.printf " \n \n"
;;



let rec print_func f =
	 match f with
	(* |deb::fin -> Printf.printf "%s " deb.name; print_param deb.params ;
	 print_type deb.return ;  print_var deb.locals; print_list_instr deb.code; print_func fin ;	Printf.printf " \n"*)

	 |deb::fin -> Printf.printf "%s (" deb.name; compteur_acc := !compteur_acc + 1; print_tab !compteur_acc  ;print_list_instr (List.rev deb.code) ; Printf.printf ")" ; print_func fin ;	Printf.printf " \n"

	| [] -> ()
;;


let print_prog p =
	Printf.printf " Variables globales: ";
	print_var p.globals;
	Printf.printf " \n Fonctions: ";
	print_list_func p.functions;
	print_func p.functions;
	Printf.printf " \n"
;;


(* ocamlc test_prog.ml -o test_prog.o
./test_prog.o

let glob = [("a", Int, Exprd(Cst(1)) ); ("b", Bool,  Exprd(Cst(1))) ]
let p =  { globals = glob; functions = [] };;
let _ = print_prog p;;*)