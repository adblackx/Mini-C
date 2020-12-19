%{
  open Mini_c
%}

%token <int> CST
%token <string> IDENT
%token TYPGEN PUTCHAR RETURN
%token PLUS ETOILE
%token EGAL INF 
%token PAR_O PAR_F
%token TRUE FALSE 
%token ACOL_O ACOL_F
%token SEMI 
%token WHILE 
%token IF ELSE 
%token FIN 


%start prog
%type <Mini_c.prog> prog (* c'est le type de retour de mon programme *)

%%

prog:
|  vg = list(decla_vars) fs = list(fun_def) FIN 
  { let res = { globals = vg ; functions = fs } ; res (*let a =  { globals = [("test", Int, 1)]; functions = [] } je retourne un programme qui respecte la structure prog*) }  
| error
    { let pos = $startpos in
      let message = Printf.sprintf
        "Echec a  la position %d, %d"
        pos.pos_lnum
        (pos.pos_cnum - pos.pos_bol)
      in
      failwith message }
;



fun_def:
| freturn=TYPGEN fname=IDENT  PAR_O  fparam=list(params) PAR_F ACOL_O loc=list(decla_vars) s =seq ACOL_F {
  let res = {name = fname; params = fparam; return = freturn; locals = loc ; seq = s}
}

instr:
| PUTCHAR PAR_O e=expr PAR_F{Putchar(e)}
| i=IDENT EGAL e=expr{Set(i,e)}
| IF PAR_O e=expr PAR_F ACOL_O s1=seq ACOL_F ELSE ACOL_O s2=seq ACOL_F{If(e,s1,s2)}
| WHILE PAR_O e=expr PAR_F ACOL_O s=seq ACOL_F{While(e,s)}
| RETURN e=expr SEMI{Return(e)}
| e = expr {Expr(e)}

seq:
|e = list(instr) { e }


params:
| type_var =TYPGEN name_var=IDENT{(type_var,name_var)}

decla_vars:
| type_var=TYPGEN name_var=IDENT SEMI{(name_var,type_var,Empty)}
| type_var=TYPGEN name_var=IDENT EGAL aff1=affectation SEMI{(name_var,type_var,aff)}

affectation:
| n = CST { Integer(n) }
| n = TRUE { Boolean(true) }
| n = FALSE { Boolean(false) }
| e=expr { Expr(e) } (*au cas ou on ait un call*)


expr:
| n=CST   { Cst n }
| x=IDENT   { Get x }
(*CALL*)
| i=IDENT PAR_O e=list(expr) PAR_F{ Call(i,e)}

| e1=expr PLUS e2=expr
    { Add(e1, e2) }
| e1=expr ETOILE e2=expr
    { Mul(op, e1, e2) }

| e1=expr INF e2=expr
    { Lt( e1, e2) (*ici c'est inférieur soit e1<e2*) }
(*| e=expr_simple
    { e } *)


;
