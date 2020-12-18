# Mini-C
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
./main.native ../files/test.ml
```

**Pour vérifier le langage :**
```
menhir -v mini_c_parser.mly
```

> **Note:** On build déjà avec menhir, en effet dans le fichier_tag, on a bien  **true: use_menhir** 
