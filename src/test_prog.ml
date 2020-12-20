open Mini_c

let rec print_type e =
	match e with
	|Int -> Printf.printf "Int" 
	|Bool -> Printf.printf "Bool" 
	|Void -> Printf.printf "Void" 
;;



let rec print_exp e = 
	begin match e with
	| Cst n -> Printf.printf "%d" n
	| Add (e1,e2) ->  Printf.printf " ( ";  (print_exp e1) ;Printf.printf " + " ;(print_exp e2) ; Printf.printf " ) "
	| Mul (e1,e2) -> Printf.printf " ( ";  (print_exp e1) ;Printf.printf " * " ;(print_exp e2) ; Printf.printf " ) "
	| Lt (e1,e2) -> Printf.printf " ( ";  (print_exp e1) ;Printf.printf " < " ;(print_exp e2) ; Printf.printf " ) "
	| Lte (e1, e2) -> Printf.printf " ( ";  (print_exp e1) ;Printf.printf " <= " ;(print_exp e2) ; Printf.printf " ) "
	| Eq (e1, e2) -> Printf.printf " ( ";  (print_exp e1) ;Printf.printf " == " ;(print_exp e2) ; Printf.printf " ) "
	| Neq (e1, e2) -> Printf.printf " ( ";  (print_exp e1) ;Printf.printf " != " ;(print_exp e2) ; Printf.printf " ) "
	| Get (e) -> Printf.printf "Get %s"  e
	| Call (e, t) -> Printf.printf "Call %s"  e; print_list_expr(t) 
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
	| Exprd (x) -> Printf.printf " = "; print_exp x
	
;;

let rec print_list_instr i=
	begin 
	match i with
	| t1::t2 -> print_instr t1; print_list_instr t2;  Printf.printf "; \n" 
	| [] -> ()
	end
and

 print_instr i=
	match i with
	| Putchar i ->  Printf.printf "Putchar"; print_exp i
	| Set (s,i) ->  Printf.printf "%s = " s; print_exp i
	| If (e,s1,s2) ->  Printf.printf "If( "; print_exp e; 
						Printf.printf ") { \n" ; 
						print_list_instr s1 ; 
						Printf.printf "{\n";
						print_list_instr s2 ; 
						Printf.printf "} \n";

	| While (e,s1) ->  Printf.printf "While( "; print_exp e; Printf.printf "){ \n"; print_list_instr s1;  Printf.printf "} \n"
	| Return i ->  Printf.printf "Return "; print_exp i ; Printf.printf ";\n"
	| Expr i ->  print_exp i




let rec print_var g =
	match g with 
	| (s, t, d)::tl -> print_type t ; Printf.printf " %s " s ; print_decla d ; Printf.printf ";  " ;print_var tl; Printf.printf " \n"

	| [] -> ()
;;

let rec print_param p=
	match p with
	| (s,t)::tl -> print_type t; Printf.printf " %s " s;  print_param tl
	| [] -> ()
;;

let rec print_func f =
	 match f with
	|deb::fin -> Printf.printf "%s" deb.name; print_param deb.params ;
	 print_type deb.return ;  print_var deb.locals; print_list_instr deb.code; print_func fin ;	Printf.printf " \n"
	| [] -> ()
	
;;


let print_prog p =
	Printf.printf " Variables globales: ";
	print_var p.globals;
	Printf.printf " \n Fonctions: ";
	print_func p.functions;
	Printf.printf " \n"
;;


(* ocamlc test_prog.ml -o test_prog.o
./test_prog.o

let glob = [("a", Int, Exprd(Cst(1)) ); ("b", Bool,  Exprd(Cst(1))) ]
let p =  { globals = glob; functions = [] };;
let _ = print_prog p;;*)