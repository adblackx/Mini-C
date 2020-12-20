%{
  open Mini_c
%}

%token <int> CST
%token <string> IDENT
%token <Mini_c.typ> TYPGEN
%token  PUTCHAR RETURN
%token PLUS ETOILE MOINS
%token EGAL INF SUP SUPE INFE EQ NEQ
%token PAR_O PAR_F
%token ACOL_O ACOL_F
%token SEMI COMMA
%token WHILE 
%token IF ELSE 
%token FIN 

%left  INF
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
| d1 = decla_var d2 = decla_vars {d2::d1}
|  {[]}

decla_vars:
| type_var=TYPGEN name_var=IDENT SEMI{ (name_var,type_var,Empty)} 
| type_var=TYPGEN name_var=IDENT EGAL aff1=affectation SEMI{ (name_var,type_var,aff1)}

fun_def:
| freturn=TYPGEN fname=IDENT  PAR_O  fparam=param PAR_F ACOL_O loc=decla_var s=seq ACOL_F { 
 let res = {name = fname; params = fparam; return = freturn; locals = loc ; code = s} in res
}

instr:
| PUTCHAR PAR_O e=expr PAR_F SEMI{Putchar(e)}
| i=IDENT EGAL e=expr SEMI{Set(i,e)}
| IF PAR_O e=expr PAR_F ACOL_O s1=seq ACOL_F ELSE ACOL_O s2=seq ACOL_F{If(e,s1,s2)}
| WHILE PAR_O e=expr PAR_F ACOL_O s=seq ACOL_F {While(e,s)}
| RETURN e=expr SEMI{Return(e)}
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
| type_var =TYPGEN name_var=IDENT{(name_var,type_var)}
 

affectation:
| e=expr { (*Printf.printf "( expre )" ;*) Exprd(e) } (*au cas ou on ait un call*)


expr:
| n=CST   {  Cst n }
| MOINS n = CST   { Cst (-1*n) }
| x=IDENT   {Get x }
(*CALL*)
| i=IDENT PAR_O e=separated_list(COMMA,expr) PAR_F{  Call(i,e)}

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
(*| e=expr_simple
    { e } *)


;
