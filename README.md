# Mini-C / Ramdane Moulou & Romain Mussard
Ce dépot git est celui d'un projet qui a pour objectif de construire la partie avant d'un compilateur pour un petit langage impératif correspondant à un fragment du langage C.

# Les fichiers à tester

**Les fichiers à tester se trouver dans le dossier files à la racine**
> **Note:** Sous WIndows **LE EOF NE MARCHE PAS** 

#### 

# Instructions d'utilisation

**D'abord utiliser (unique fois) :**

```
eval $(opam env)
```
**Compiler avec** :
```
ocamlbuild main.native
```
**Exécuter avec :**
```
./main.native ../files/test.c
```

**Pour vérifier le langage :**
```
menhir -v mini_c_parser.mly
```


**ATTENTION on utilise le module Str et donc aussi use_str dans le fichier _tag :**
```
true: use_menhir, explain, bin_annot, keep_locs, use_str
```

> **Note:** On build déjà avec menhir, en effet dans le fichier_tag, on a bien  **true: use_menhir**

# Notre Travail

## Syntaxe Abstraite : mini_c.ml

Nous avons choisi d'étendre le typ comme suit: 
- Tout d'abord pour différencier les différents typ nous avons ajouté Struct, mais nous n'avons pas ajouté le type Tab ici, mais seulement en déclaration, car en soit un tab n'est qu'une suite de constantes
- Ensuite nous avons créée le type binop pour les comparaisons, on aurait aussi pu le faire pour les additions mais nous n'avons pas voulu mélanger opérateurs arithmétique et logique
- le type expr a été étendu pour acceuillir binop, et les getteurs des tableaux et structs
- L'ajout du type struct marche uniquement pour le parser et le lexer, nous n'avons pas vérifié le type
- Pour le reste, les variables locals et globales sont de type (string * typ * decla) list où decla est ou bien empty (signifiant que la variable n'a pas de valeur) ou bien une expression, ou bien la taille du tableau pour un tableau, ou encore une suite de declaration pour la structure. C'est pour différencier déclarations et affectations que nous avons fait ces choix.



## Analyse Lexicale : mini_c_lexer.mll

- On reconait en plus des lexemes requis les opérateurs binaires tels que le "ou" logique, le "et" logique, les opérateurs de comparaisons : "<, >, <=, >=, ==, !="
- On tient compte des commentaires de ligne sur une ou plusieurs lignes (on se contente de ne pas les traiter comme des lexemes et de les ignorer)
- Nous avons du code commenté en fin de fichier qui peut permettre d'afficher les lexemes reconnu par l'analyseur. Il suffit de décomenter et de compiler classiquement avec la commande ocaml mini_c_lexer.ml chemin_du_fichier
- Ici nous avons géré le fait que si on déclare une variable qui ressemble à un identificateur, alors on nous affiche l'identificateur et l'identifiant/text qui lui ressemble Did you mean 'recursion'?

## Analyse Synatxique : mini_c_parser.mly

Pour le parser, nous avons réussit à choisir une grammaire non ambigu, et en prenant les bonnes priorités pour les opérateurs, pour illustrer ce propos un bonus a été fait, il permet d'afficher l'arbre, il suffit d'aller dans le main.ml et de décommenter : 
```
Test_prog.print_prog prog ;
```
- Nous avons réussit à factoriser avec Binop ici. 
- Pour les variables gloables, on a utilisé une hashtabl, pareil pour les variables locals, on a aussi des fonctions auxiliaures pour transformer le contenu des hashmap en liste pour correspondre à notre type de base
- la boucle for a été traité comme sucre syntaxique en une boucle while, la déclaration de variable est envoyée au variables locales, puis l'instruction d'incrémentation du compteur ajouté à la séquence du while
- On a implémenté avertissement en cas d'absence de virgule dans la grammaire, un message s'affiche "Missing semicolon"
- D'autres sucres syntaxiques sont gérés


## Vérificateur de type : mini_c_types.ml

- Notre vérificateur de type prend la sortie du parser c'est à dire qu'il prend ce qui correspond à prog dans la syntaxe abstraite et vérifie que tout est correctement typé

- Nous avons un environnement qui sera toujours composé des variables gloables du programme. De plus cette environnement est rempli récursivement aux fil de l'analyse des fonctions. Se faisant chaque fonction sera analysé dans son propre environnement locals qui se compose de ses variables locales, de ses paramètres et des variables globales du programme.

- Nous avons créée un type artificiel (```typage```)  pour faciliter le stockage dans l'environnement des types des variables et des fonctions. Le but était intialement de faciliter la vérification du typage lors d'appel de fonction. L'utilisation de ce type "artificelle" (non concurrent aux vrais types de la syntaxe abstraite) c'est avéré plus laborieux que prévu.


- Notre envrionement est de type maps, chaque composantes (variables, fonctions...) de notre environnement est désigné par son nom (un string) auxquel est associé sont type dans la map


- Le typage semble fonctionner. On a respecté le polymorphisme des types de base tel que int et bool.

- Le typage des tableau semble correctement fonctionner. Cependant par manque de temps nous n'avons pas pu le faire aussi bien que désiré. Par exemple les tableaux sont bien reconnu globalement sauf dans les paramètres de fonctions, elle sont reconnu comme étant mal typé alors qu'elle sont bien reconnu par l'analyseur syntaxique.



# Bonus Réalisés : 

- Affichage de l'arbre syntaxique
- **Commentaires** : Nous pouvons analyser du code C contenant de commentaires
- Nous avons rajouter des **opérateurs** (et, ou, <, > ...) et avons **factorisé** une partie du code pour éviter la redondance
- **Sucre Syntaxique** :
    - **Boucle For** : Transformation en while aux niveau du parser
    - Pour la déclaration de tableau et l'accès en écritures/lectures on peut utiliser des []

- **Tableau** : Nous avons implémenté les tableaux mais le typages est encore incomplets

- **Struct** : Nous avons avons réussi à le faire pour l'analyse syntaxique mais pas pour le vérificateur de type

- **Interpréteur** : Nous avons tenté de le faire mais n'avons pas eu le temps de le finir

- Nous avons autant que possiblé essayer de mettre des messages les plus complets possibles pour aider l'utilisateurs de ses corrections

