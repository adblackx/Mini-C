 int PARAM = 5;
 int Mr10 = 10;
 bool MrTrue = true;
 
// int zero = 1;
/* test test


*/
  int fact(int n, bool b, int z) {
    bool MrFalse = false;
    if (n > 10) {
      return n * MrTrue;
    } else {
      n = n * fact(n + 1, MrFalse, z) + z;
    }
  }

  void main() {
  	
    putchar(fact(PARAM, MrTrue, PARAM));
  }
