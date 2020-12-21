%{
  open Mini_c

  let compteur = ref 0;;
  let compteurG = ref 0;;
  let ht = Hashtbl.create 15;;
  let htG = Hashtbl.create 15;;
  let htL = Hashtbl.create 15;;

  let rec hashTabltoList h l compt= 
    if compt >0 then
      (let res = Hashtbl.find h compt in hashTabltoList h (res::l) (compt-1))
    else l
  ;;

  let rec printTab t =
   match t with
   | t1::t2 -> let a,b = t1 in Printf.printf " %s " a; printTab t2
   | [] -> Printf.printf "\n "
   ;;

  let rec printTab1 t =
   match t with
   | t1::t2 -> let a,_,_ = t1 in Printf.printf " %s " a; printTab1 t2
   | [] -> Printf.printf "\n "
   ;;

%}

%token <int> CST
%token <string> IDENT
%token <Mini_c.typ> TYPGEN
%token  PUTCHAR RETURN
%token PLUS ETOILE MOINS
%token ET OU CROCHET_L CROCHET_R
%token EGAL INF SUP SUPE INFE EQ NEQ
%token PAR_O PAR_F
%token ACOL_O ACOL_F
%token SEMI COMMA
%token WHILE FOR
%token IF ELSE 
%token FIN 


%left EQ NEQ
%left ET
%left OU
%left SUPE
%left SUP
%left INFE
%left INF

%left PLUS
%left ETOILE


%start prog
%type <Mini_c.prog> prog (* c'est le type de retour de mon programme *)

%%

prog:
|  vg = decla_var fs = nonempty_list(fun_def) FIN 
  { Printf.printf "PARSING DONE\n" ; let res = { globals = vg ; functions = fs } in res ; 
  (*let a =  { globals = [("test", Int, 1)]; functions = [] } je retourne un programme qui respecte la structure prog*) }   
(*|   fs = nonempty_list(fun_def) FIN 
  { let res = { globals = [] ; functions = fs } in res }*)
| error
    { let pos = $startpos in
      let message = Printf.sprintf
        "Echec a  la position %d, %d"
        pos.pos_lnum
        (pos.pos_cnum - pos.pos_bol)
      in
      failwith message }
;

decla_var:
| d1 = decla_var d2 = decla_vars {  d2::d1}
|  {[]}

decla_vars:
| type_var=TYPGEN name_var=IDENT SEMI{Hashtbl.add htG (!compteurG +1 ) (name_var,type_var,Empty); compteurG := !compteurG +1 ; (name_var,type_var,Empty)} 
| type_var=TYPGEN name_var=IDENT {failwith "Missing semicolon"} 
| type_var=TYPGEN name_var=IDENT EGAL aff1=affectation SEMI{Hashtbl.add htG (!compteurG +1 ) (name_var,type_var,aff1); compteurG := !compteurG +1 ;  (name_var,type_var,aff1)}
| type_var=TYPGEN name_var=IDENT EGAL aff1=affectation { failwith "Missing semicolon"}
| type_var=TYPGEN name_var=IDENT CROCHET_L n=CST CROCHET_R SEMI
{ Hashtbl.add htG (!compteurG +1 ) (name_var,type_var,Tabl(n)); compteurG := !compteurG +1 ; (name_var,type_var,Tabl(n))} (*declaration tab*)

fun_def:
| freturn=TYPGEN fname=IDENT  PAR_O  fparam=param PAR_F ACOL_O loc=decla_var s=seq ACOL_F { 
let conv = hashTabltoList ht [] !compteur in let cop = Hashtbl.copy ht in Hashtbl.clear ht ;
compteur := 0 ; let loc1 = hashTabltoList htG [] !compteurG in let cop1 = Hashtbl.copy htG in Hashtbl.clear htG ;
compteurG := 0 ;  printTab1 loc1 ;
let res = {name = fname; params = conv; return = freturn; locals = loc1 ; code = s} in res
}

instr:
| PUTCHAR PAR_O e=expr PAR_F SEMI{Putchar(e)}
| PUTCHAR PAR_O e=expr PAR_F {failwith "Missing semicolon" }
| i=IDENT EGAL e=expr SEMI{Set(i,e)}
| i=IDENT EGAL e=expr PAR_F{Set(i,e)}
| i=IDENT CROCHET_L n=CST CROCHET_R EGAL e=expr SEMI { Setab(i,n,e) } (*t[n]=e affectation*)
| i=IDENT EGAL e=expr {failwith "Missing semicolon" }
| IF PAR_O e=expr PAR_F ACOL_O s1=seq ACOL_F ELSE ACOL_O s2=seq ACOL_F{If(e,s1,s2)}
| WHILE PAR_O e=expr PAR_F ACOL_O s=seq ACOL_F {While(e,s)}
| FOR PAR_O t=decla_vars e = expr SEMI i=instr ACOL_O s=seq ACOL_F  
{  While( e, [i]@s) }
| RETURN e=expr SEMI{Return(e)}
| RETURN e=expr { 
      failwith "Missing semicolon" }
| e = expr {Expr(e)}



(*
seq:
|e = separated_list(SEMI, instr) { e } *)


seq:
| s1 = seq s2 = instr {s2::s1}
|  {[]}



param:
| l = separated_list(COMMA,params) {l}


params:
| type_var =TYPGEN name_var=IDENT{  Hashtbl.add ht (!compteur +1 ) (name_var,type_var); compteur := !compteur +1 ; (name_var,type_var)}
 

affectation:
| e=expr { (*Printf.printf "( expre )" ;*) Exprd(e) } (*au cas ou on ait un call*)


expr:
| n=CST   {  Cst n }
| MOINS n = CST   { Cst (-1*n) }
| x=IDENT   {Get x }
(*CALL*)
| i=IDENT PAR_O e=separated_list(COMMA,expr) PAR_F{  Call(i,e)}
| ident=IDENT CROCHET_L indice=CST CROCHET_R   { Getab(ident,indice) } (*t[indice] lecture*)


| e1=expr PLUS e2=expr
    { Add(e1, e2) }
| e1=expr ETOILE e2=expr
    {Mul( e1, e2) }
| e1=expr INF e2=expr
    { Lt( e1, e2) (*ici c'est inférieur soit e1<e2*) }
| e1=expr SUP e2=expr
    { Lt( e2, e1) }
| e1=expr INFE e2=expr
    { Lte( e1, e2) }
| e1=expr SUPE e2=expr
    { Lte( e2, e1) }
| e1=expr EQ e2=expr
    { Eq( e1, e2) }
| e1=expr NEQ e2=expr
    { Neq( e1, e2) }
| e1=expr ET e2=expr
    { And( e1, e2) }
| e1=expr OU e2=expr
    { Or( e1, e2) }
(*| e=expr_simple
    { e } *)


;
