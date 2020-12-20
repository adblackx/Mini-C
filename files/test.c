 int PARAM = 5;
 bool bobo = true;
  int fact(int n) {
    bool toto = false;
    if (n < 2) {
      return 1;
    } else {
      return n * fact(n + 1);
    }
  }

  void main() {
    putchar(fact(PARAM));
  }
