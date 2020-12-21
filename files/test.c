int PARAM = 5;
bool PARAM = 5;

 
// int zero = 1;
/* test test
*/
  int fact(int n, bool b, int z) {
    int tab[10];
    int a = 10;  
    if (n > tab[0]/*tab fera une erreur*/) {

      return n;
    } else {
      return b * fact(n + -1, n, z);
    }
  }

  void main(int n) {
    bool MrFalse = false;
    

    while( n < 5) {
      n = n+1;
    }

    for(int i = 5; i < 10; i = i + 1) {
      n = n+1;
    }
  	
    putchar(fact(PARAM, MrTrue, PARAM));
  }
