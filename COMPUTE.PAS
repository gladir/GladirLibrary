{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2021
  @website(https://www.gladir.com/)
  @abstract(Target: Free Pascal)
}

Unit Compute;

INTERFACE

Type
 Math=Object
  Function Abs(x:Real):Real;
  Function ACos(a:Real):Real;
  Function ASin(a:Real):Real;
  Function ASinH(X:Real):Real;
  Function Atan(X:Real):Real;
  Function Cos(X:Real):Real;
  Function Cosh(x:Real):Real;
  Function Exp(x:Real):Real;
  Function Log(x:Real):Real;
  Function Log10(x:Real):Real;
  Function Max(a,b:Real):Real;
  Function Min(a,b:Real):Real;
  Function POW(a,b:Real):Real;
  Function Sin(X:Real):Real;
  Function Sqrt(x:Real):Real;
  Function Tan(X:Real):Real;
 End;

IMPLEMENTATION

Function Math.Abs(x:Real):Real;Begin
 If x<0.0 Then x:=-x;
 Abs:=x;
End;

Function Math.ACos(a:Real):Real;
Const
 PI=3.141592653589793;
Begin
 If Math.Abs(a)=1.0 Then ACos := (1-a)*PI/2.0
                    Else ACos := Math.Atan(-a/Math.Sqrt(1-a*a))+2*Math.Atan(1);
End;

Function Math.ASin(a:Real):Real;
Const
 PI=3.141592653589793;
Begin
 If Math.Abs(a)=1.0Then ASin:=PI/2.0
                   Else ASin:=Math.ATan(a/Math.Sqrt(1.0-a*a));
End;

Function Math.ASinH(X:Real):Real;Begin
 ASinH:=Math.Log(X)-Math.Sqrt(x*x+1);
End;

Function Math.Atan(X:Real):Real;
Var
 A,B:Real;
 N:Integer;
Begin
 A := 1.0 / Math.Sqrt(1.0 + (X * X));
 B := 1.0;
 For N:=1 to 11 do Begin
  A := (A + B) / 2.0;
  B := Math.Sqrt(A * B);
 End;
 Atan:=X/(Math.Sqrt(1.0+(X*X))*A);
End;

Function Math.Cos(X:Real):Real;
Var
 R,S:Real;
 I:Byte;
Begin
 R:=X*X;
 S:=42.0;
 For I:=10 downto 1 do S:=4.0*I-2.0+(-R)/S;
 S:=S*S;
 Cos:=(S-R)/(S+R);
End;

Function Math.Cosh(x:Real):Real;Begin
 x:=Math.Abs(x);
 If x > 88.029691931 Then
  Cosh:=0 { Infini }
 Else
  Cosh:=(Math.Exp(x)+Math.Exp(-x))/ 2.0;
End;

Function Math.Exp(x:Real):Real;
Var
 Inverse:Boolean;
 n,i:Integer;
 dl,q:Real;
Begin
 Inverse := False;
 n := 0;
 dl := 1;
 i := 1;
 If x < 0 Then Begin
  Inverse := True;
  x := -x;
 End;
 While x >= 2 do Begin
  x := x / 2;
  n := n + 1;
 End;
 x := x / 16;
 n := n + 4;
 q := x;
 While q > 1.0E-15 do Begin
  dl := dl + q;
  i := i + 1;
  q := q * x / i;
 End;
 For i := 1 to n do dl := dl * dl;
 If Inverse Then dl := 1 / dl;
 Exp := dl;
End;

Function Math.Log(x:Real):Real;
Var
 negatif:Boolean;
 fois,i:Integer;
 ajout,savx,xp,quotient,dl:Real;
Begin
 negatif := False;
 fois := 1;
 ajout := 0;
 If x <= 0.0 Then Begin
  Log:=0;
  Exit;
 End;
 If x < 1.0 Then Begin
  negatif := True;
  x := 1.0 / x;
 End;
 While x >= 10.0 do Begin
  x := x / 10.0;
  ajout := ajout + 2.302585092994046;
 End;
 While x >= 1.1 do Begin
  x := Math.Sqrt(x);
  fois := fois * 2;
 End;
 x := x - 1;
 savx := x;
 i := 2;
 xp := x * x;
 quotient := (xp / i);
 dl := x - quotient;
 While 1.0E-15 < quotient do Begin
  i := i + 1;
  xp := xp * x;
  dl := dl + (xp / i);
  i := i + 1;
  xp := xp * x;
  quotient := (xp / i);
  dl := dl - quotient;
 End;
 dl := dl * fois;
 dl := dl + ajout;
 If(negatif)Then dl := - dl;
 Log:=dl;
End;

Function Math.Log10(x:Real):Real;Begin
 Log10:=Math.Log(x)/2.3025850930;
End;

Function Math.Max(a,b:Real):Real;Begin
 If a>b Then Max:=a Else Max:=b;
End;

Function Math.Min(a,b:Real):Real;Begin
 If a<b Then Min:=a Else Min:=b;
End;

Function Math.POW(a,b:Real):Real;
Var
 p:Real;
 I:Integer;
Begin
 p:=1;
 For i:=1 to Trunc(b) do Begin
  p := p * a;
 End;
 Pow:=p;
End;

Function Math.Sin(X:Real):Real;
Var
 R,S:Real;
 I:Byte;
Begin
 R:=X*X;
 S:=42.0;
 For I:=10 downto 1 do S:=4.0*I-2.0+(-R)/S;
 Sin:=2.0*X*S/(R+S*S);
End;

Function Math.Sqrt(X:Real):Real;
Var
 A,B,M,XN:Real;
Begin
 If X=0.0Then Begin
  Sqrt:=0.0;
 End
  Else
 Begin
  M := 1.0;
  XN := X;
  While XN >= 2.0 do Begin
   XN := 0.25 * XN;
   M := 2.0 * M;
  End;
  While XN < 0.5 do Begin
   XN:=4.0 * XN;
   M:=0.5 * M;
  End;
  A:=XN;
  B:=1.0-XN;
  Repeat
   A:=A*(1.0+0.5*B);
   B:=0.25*(3.0+B)*B*B;
  Until B<1.0E-15;
  Sqrt:=A*M;
 End;
End;

Function Math.Tan(X:Real):Real;Begin
 Tan:=Math.Sin(X)/Math.Cos(X);
End;

END.