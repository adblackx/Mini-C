%{
  open Mini_c

  let compteur = ref 0;;
  let compteurG = ref 0;;
  let ht = Hashtbl.create 15;;
  let htG = Hashtbl.create 15;;

  (*converti une hstabl en list*)
  let rec hashTabltoList h l compt= 
    if compt >0 then
      (let res = Hashtbl.find h compt in hashTabltoList h (res::l) (compt-1))
    else l
  ;;
  (* permet d'afficher un tableau params *)
  let rec printTab t =
   match t with
   | t1::t2 -> let a,b = t1 in Printf.printf " %s " a; printTab t2
   | [] -> Printf.printf "\n "
   ;;

  (* permet d'afficher un tableau de decla *)
  let rec printTab1 t =
   match t with
   | t1::t2 -> let a,_,_ = t1 in Printf.printf " %s " a; printTab1 t2
   | [] -> Printf.printf "\n "
   ;;

   (*  On ajoute les éléments d'une liste à une hstable  *)

   let rec addToHT liste ht1 type_r =
      match liste with 
      | name :: t2 -> Hashtbl.add ht1 (!compteurG +1 ) (name, type_r, Empty) ; compteurG := !compteurG +1 ; addToHT t2 ht1 type_r
      | [] -> ()
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
%token SEMI COMMA DOT
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
  { Printf.printf "PARSING DONE\n" ; let res = { globals = vg ; functions = fs } in res ; }   

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

| type_var=TYPGEN name_var=IDENT ACOL_O l=nonempty_list(decla_vars_strcut) ACOL_F SEMI
{ Hashtbl.add htG (!compteurG +1 ) (name_var,Struct(name_var),Structd(l)); compteurG := !compteurG +1 ; (name_var,Struct(name_var),Structd(l))} (*declaration tab*)


| type_var=TYPGEN name_var=IDENT ACOL_O l=nonempty_list(decla_vars_strcut) ACOL_F listD = nonempty_list(multip_decl) SEMI
{ addToHT (listD) htG (Struct(name_var)) ; Hashtbl.add htG (!compteurG +1 ) (name_var,Struct(name_var),Structd(l)); compteurG := !compteurG +1 ; (name_var,Struct(name_var),Structd(l))}

multip_decl:
| ident = IDENT COMMA{ ident } 
| ident = IDENT { ident } 

decla_vars_strcut:
| type_var=TYPGEN name_var=IDENT SEMI{(name_var,type_var,Empty)} 
| type_var=TYPGEN name_var=IDENT SEMI{failwith "Missing semicolon"} 
| type_var=TYPGEN name_var=IDENT CROCHET_L n=CST CROCHET_R SEMI{(name_var,type_var, Tabl(n))} (*declaration tab*)

fun_def:
| freturn=TYPGEN fname=IDENT  PAR_O  fparam=param PAR_F ACOL_O loc=decla_var s=seq ACOL_F { (*je met à jour la hashtabl ici*)
let conv = hashTabltoList ht [] !compteur in let cop = Hashtbl.copy ht in Hashtbl.clear ht ;
compteur := 0 ; let loc1 = hashTabltoList htG [] !compteurG in let cop1 = Hashtbl.copy htG in Hashtbl.clear htG ;
compteurG := 0 ;
let res = {name = fname; params = conv; return = freturn; locals = loc1 ; code = s} in res
}

instr:
| PUTCHAR PAR_O e=expr PAR_F SEMI{Putchar(e)}
| PUTCHAR PAR_O e=expr PAR_F {failwith "Missing semicolon" }
| i=IDENT EGAL e=expr SEMI{Set(i,e)}
| i=IDENT EGAL e=expr PAR_F{Set(i,e)}
| i=IDENT CROCHET_L n=CST CROCHET_R EGAL e=expr SEMI { Setab(i,n,e) } (*t[n]=e affectation*)
| ident=IDENT DOT elmt=IDENT EGAL e=expr SEMI { Setstr(ident,elmt,e) } (*t.elmt=e affectation*)
| i=IDENT EGAL e=expr {failwith "Missing semicolon" }
| IF PAR_O e=expr PAR_F ACOL_O s1=seq ACOL_F ELSE ACOL_O s2=seq ACOL_F{If(e,s1,s2)}
| WHILE PAR_O e=expr PAR_F ACOL_O s=seq ACOL_F {While(e,s)}
| FOR PAR_O t=decla_vars e = expr SEMI i=instr ACOL_O s=seq ACOL_F  
{  While( e, [i]@s) }
| RETURN e=expr SEMI{Return(e)}
| RETURN e=expr { 
      failwith "Missing semicolon" }
| e = expr SEMI{Expr(e)}

seq:
| s1 = seq s2 = instr {s2::s1}
|  {[]}

param:
| l = separated_list(COMMA,params) {l}

params:
| type_var =TYPGEN name_var=IDENT{  Hashtbl.add ht (!compteur +1 ) (name_var,type_var); compteur := !compteur +1 ; (name_var,type_var)}
 
affectation:
| e=expr { Exprd(e) } (*au cas ou on ait un call*)


expr:
| n=CST   {  Cst n }
| MOINS n = CST   { Cst (-1*n) }
| x=IDENT   {Get x }
| i=IDENT PAR_O e=separated_list(COMMA,expr) PAR_F{  Call(i,e)}
| ident=IDENT CROCHET_L indice=CST CROCHET_R   { Getab(ident,indice) } (*t[indice] lecture*)
| ident=IDENT DOT elmt=IDENT   { Getstr(ident,elmt) } (*t.elmt lecture*)


| e1=expr op = binop e2=expr {Binop(op, e1, e2)}
| e1=expr PLUS e2=expr {Add(e1, e2)}
| e1=expr ETOILE e2=expr {Mul(e1, e2)}
| e1=expr ET e2=expr
    { And( e1, e2) }
| e1=expr OU e2=expr
    { Or( e1, e2) }

%inline binop:
| EQ    { Eq }
| NEQ  { Neq }
| INF     { Lt }
| INFE { Le }
| SUP {Gt}
| SUPE {Gte}
;
;
