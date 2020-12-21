 int PARAM = 5;
 int Mr10 = 10;
 bool MrTrue = true;
 
// int zero = 1;
/* test test


*/
  int fact(int n, bool b, int z) {
    bool MrFalse = false;
    if (n > 10 && n < 10) {
      return n * MrTrue;
    } else {
      n = n * fact(n + 1, MrFalse, z) + z;
    }

    return 10;
  }

  void main(int n) {
    bool MrFalse = false;
    int tab[10];
      tab[1] = 1+1;

    while( n < 5) {
      n = n+1;
    }

    for(int i = 5; i < 10; i = i + 1) {
      n = n+1;
    }
  	
    putchar(fact(PARAM, MrTrue, PARAM));
  }
