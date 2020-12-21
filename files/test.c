int PARAM = 5;

  int fact(int n, bool b, int z) {
    int tab[10];
    if (n < tab[0]/*tab fera une erreur*/) {

      return n;
    } else {
      return b * fact(n + -1, n, z);
    }
  }

  void main() {
    putchar(fact(PARAM, true, 1));
  }
