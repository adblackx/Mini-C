%{
  open Mini_c
%}

%token <int> CST
%token <string> IDENT
%token PLUS ETOILE MOINS
%token EGAL INEGAL INF INFEGAL ET OU
%token PAR_O PAR_F
%token FUN FLECHE
%token LET IN
%token IF THEN ELSE
%token FIN

%nonassoc IN ELSE FLECHE
%left ET OU
%left EGAL INEGAL INF INFEGAL
%left PLUS MOINS
%left ETOILE
%left PAR_O IDENT CST

%start prog
%type <Mini_c.prog> prog (* c'est le type de retour de mon programme *)

%%

prog:
| e= vg = list(globals) fs = list(fun_def) FIN 
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

globals:
| type1=IDENT nomVar=IDENT EQ e = expr  SEMICOLON {(nomVar,type1,nomVar)}


fun_def:
| freturn=IDENT fname=IDENT  PAR_O  fparam=list(params) PAR_F LBRACKET instr RBRACKET {
  let res = {name = fname; params = fparam; return = freturn; locals = ; seq = }
}

instr:
| PUTCHAR PAR_O e=expr PAR_F {Putchar(e)}
| i=IDENT EQ e=expr { Set(i,e)}
| IF PAR_O e=expr PAR_F LBRACKET s1=seq RBRACKET ELSE LBRACKET s2=seq RBRACKET { If(e,s1,s2)}
| WHILE PAR_O e=expr PAR_F LBRACKET s=seq RBRACKET{While(e,s)}
| RETURN e=expr SEMICOLON{Return(e)}
| e = expr {Expr(e)}
seq:
|e = list(instr) { e }


params:
| type_var =IDENT name_var=IDENT {(type_var,name_var)}

decla:
| type_var =IDENT name_var=IDENT {}


expr:
| n=CST   { Cst n }
| x=IDENT   { Get x }
(*CALL*)
| i=IDENT PAR_O e=list(expr) PAR_F{ Call(i,e)}
| e=expr_simple
    { e }
| e1=expr PLUS e2=expr
    { Add(e1, e2) }
| e1=expr ETOILE e2=expr
    { Mul(op, e1, e2) }

| e1=expr LT e2=expr
    { Lt( e1, e2) (*ici c'est inférieur soit e1<e2*) }


;
