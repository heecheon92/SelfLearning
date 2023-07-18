#include <iostream>
#include <string>
using namespace std;

class BaseClass;
class Derived1;
class Derived2;
class Derived3;

class Processor {
public:
       Processor(){}
       void process(BaseClass* bc);
       void process(Derived1* d1);
       void process(Derived2* d2);
};

class BaseClass{
public:
       BaseClass(){}
       virtual void myFunction(){cout << "base myFunction called" << endl;}
       virtual void processWith(Processor* p){ p->process(this); };
};

class Derived1: public BaseClass{
public:
       Derived1():BaseClass(){}
       void myFunction(){cout << "Derived1 myFunction called" << endl;}
       void processWith(Processor* p) { p->process(this); };
};


class Derived2: public BaseClass{
public:
       Derived2():BaseClass(){}
       void myFunction(){cout << "Derived2 myFunction called" << endl;}
       void processWith(Processor* p) { p->process(this); };
};

class Derived3: public BaseClass{
public:
       Derived3():BaseClass(){}
       void myFunction(){cout << "Derived3 myFunction called" << endl;}
       void processWith(Processor* p) { p->process(this); };
};

void Processor::process(BaseClass* bc){cout << "got a base object" << endl; bc->myFunction();}
void Processor::process(Derived1* d1){cout << "got a derived1 object" << endl; d1->myFunction();}
void Processor::process(Derived2* d2){cout << "got a derived2 object" << endl; d2->myFunction(); }

int main() {
    
   BaseClass *bcp = new BaseClass();
   Derived1 *dc1p = new Derived1();   
   Derived2 *dc2p = new Derived2();
   Derived3 *dc3p = new Derived3();

   Processor p;//can also use Processor* p = new Processor()
   Processor* pp = &p;

   //first set results
   p.process(bcp);
   p.process(dc1p);
   p.process(dc2p);
   p.process(dc3p);

   cout << endl;
   cout << endl;

   BaseClass *bcp1=bcp;
   BaseClass *dc1p1=dc1p;   
   BaseClass *dc2p1=dc2p;
   BaseClass *dc3p1=dc3p;

   //second set results
   p.process(bcp1);
   p.process(dc1p1);
   p.process(dc2p1);
   p.process(dc3p1);

   cout << endl;
   cout << endl;

   bcp1->processWith(pp);
   dc1p1->processWith(pp);
   dc2p1->processWith(pp);
   dc3p1->processWith(pp);

   return 0;
}