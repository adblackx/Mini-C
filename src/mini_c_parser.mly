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
%type <Mini_c.expr> prog

%%

prog:
| e=expr FIN { e }
| error
    { let pos = $startpos in
      let message = Printf.sprintf
        "Echec a  la position %d, %d"
        pos.pos_lnum
        (pos.pos_cnum - pos.pos_bol)
      in
      failwith message }
;

expr_simple:
| n=CST   { Cst n }
| x=IDENT   { Var x }
| PAR_O e=expr PAR_F   { e }
;

expr:
| e=expr_simple
    { e }
| e1=expr op=binop e2=expr
    { Binop(op, e1, e2) }
| FUN x=IDENT FLECHE e=expr
    { Fun(x, e) }
| e1=expr e2=expr_simple
    { App(e1, e2) }
| IF c=expr THEN e1=expr ELSE e2=expr
    { If(c, e1, e2) }
(* | LET x=IDENT EGAL e1=expr IN e2=expr   { Letin(x, e1, e2) } *)
| LET f=IDENT args=list(IDENT)
    EGAL e1=expr IN e2=expr
    { Letin(f, mk_fun args e1, e2) }
;

(* expr: *)
(* | n=CST   { Cst n } *)
(* | x=IDENT   { Var x } *)
(* | PAR_O e=expr PAR_F   { e } *)
(* | e1=expr op=binop e2=expr   { Binop(op, e1, e2) } *)
(* | FUN x=IDENT FLECHE e=expr   { Fun(x, e) } *)
(* | e1=expr e2=expr   { App(e1, e2) } *)
(* | IF c=expr THEN e1=expr ELSE e2=expr   { If(c, e1, e2) } *)
(* | LET x=IDENT EGAL e1=expr IN e2=expr   { Letin(x, e1, e2) } *)
(* ; *)

%inline binop:
| PLUS    { Add }
| MOINS   { Sub }
| ETOILE  { Mul }
| EGAL    { Eq }
| INEGAL  { Neq }
| INF     { Lt }
| INFEGAL { Le }
| ET      { And }
| OU      { Or }
;