{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2021
  @website(https://www.gladir.com/)
  @abstract(Target: Free Pascal)

  Structure m‚moire : ArrayList,...
}

Unit StrucMem;

INTERFACE

Type

     PCharByteRec = Record
      PChr:PChar;
      Nm:Byte;
     End;

     StrByteRec = Record
      PChr:PChar;
      Nm:Byte;
      Len:Word;
     End;

     StrWordRec = Record
      PChr:PChar;
      Nm,Len:Word;
     End;

     PCharWordRec = Record
      PChr:PChar;
      Nm:Word;
     End;

     RBufPtr = ^RBufRec;

     RBufRec = Record
      Buf:Pointer;
      Size:Word;
      Previous,Next:RBufPtr;
     End;

     ArrayList = Object
      Constructor Init;
      Procedure Next;
      Procedure Previous;
      Function AddBuf(Size:Word;Var Addr:Pointer):Boolean;
      Function AddLn:Boolean;
      Function AddPChr(PChr:PChar):Boolean;
      Function AddPChrByte(PChr:PChar;Num:Byte):Boolean;
      Function AddPChrWord(PChr:PChar;Num:Word):Boolean;
      Function AddStr(Str:String):Boolean;
      Function AddStrByte(Str:String;Num:Byte):Boolean;
      Function AddStrWord(Str:String;Num:Word):Boolean;
      Function Count:LongInt;
      Function GetBuf(P:LongInt;Var Size:Word):Pointer;
      Function GetCurrBuf(Var Size:Word):Pointer;
      Function InsBuf(P:LongInt;Size:Word;Var Addr:Pointer):Boolean;
      Function InsStr(P:LongInt;Str:String):Boolean;
      Function InsStrWord(P:LongInt;Str:String;Num:Word):Boolean;
      Function RemoveAt(P:LongInt):Boolean;
      Function SetBuf(P:LongInt;Size:Word;Var Addr:Pointer):Boolean;
      Function MaxList:LongInt;
      Function IsEmpty:Boolean;
      Procedure SetPtr(P:LongInt);
      Function _AddBuf(Size:Word):Pointer;
      Function _GetBuf(P:LongInt):Pointer;
      Function _GetCurrBuf:Pointer;
      Function _GetStr(P:LongInt):String;
      Function _SetBuf(P:LongInt;Size:Word):Pointer;
      Destructor Done;
      PRIVATE
      PCurrPtr,NB:LongInt;
      CurrPtr,List,EndListPtr:RBufPtr;
     End;

IMPLEMENTATION

Uses Strings;

Function MaxAvail:LongInt;Begin
 MaxAvail:=High(LongInt);
End;

Function MemAlloc(Size:Word):Pointer;
Var Ptr:Pointer;
Begin
 MemAlloc := NIL;
 If(Size = 0)Then Exit;
 If(MaxAvail < Size)Then Exit;
 GetMem(Ptr,Size);
 MemAlloc := Ptr;
End;

Constructor ArrayList.Init;
Begin
 PCurrPtr := -1; CurrPtr := NIL; List := NIL; EndListPtr := NIL; NB := 0;
End;

Function ArrayList.IsEmpty:Boolean;
Begin
 IsEmpty := (List = NIL);
End;

Function ArrayList.AddBuf(Size:Word;Var Addr:Pointer):Boolean;
Var W:RBufRec; WPtr:RBufPtr;
Begin
 AddBuf := False;
 If(Size = 0)Then
 Begin
  W.Buf := NIL; W.Size := 0;
 End
  Else
 Begin
  Addr := MemAlloc(Size);
  If(Addr = NIL)Then Exit;
  W.Buf := Addr; W.Size := Size;
 End;
 W.Previous := NIL; W.Next := NIL;
 If(List = NIL)Then
 Begin
  List := MemAlloc(SizeOf(List^));
  If(List = NIL)Then Exit;
  Move(W,List^,SizeOf(List^)); EndListPtr := List;
 End
  Else
 Begin
  WPtr := EndListPtr; W.Previous := WPtr; WPtr^.Next := MemAlloc(SizeOf(List^));
  Move(W,WPtr^.Next^,SizeOf(List^)); EndListPtr := WPtr^.Next;
 End;
 Inc(NB); AddBuf := True;
End;

Function ArrayList._AddBuf(Size:Word):Pointer;
Var Ptr:Pointer;
Begin
 _AddBuf := NIL;
 If Not(AddBuf(Size,Ptr))Then Exit;
 _AddBuf := Ptr;
End;

Function ArrayList._SetBuf(P:LongInt;Size:Word):Pointer;
Var Ptr:Pointer;
Begin
 _SetBuf := NIL;
 If Not(SetBuf(P,Size,Ptr))Then Exit;
 _SetBuf := Ptr;
End;

Function ArrayList.InsBuf(P:LongInt;Size:Word;Var Addr:Pointer):Boolean;
Var WP,NewP:RBufPtr; I:LongInt;
Begin
 InsBuf := False;
 If(P > NB)Then Exit;
 If(P = NB)Then InsBuf := AddBuf(Size,Addr)
  else
 Begin
  InsBuf := False;
  If(P = 0)Then
  Begin
   WP := MemAlloc(SizeOf(List^));
   If(WP = NIL)Then Exit;
   List^.Previous := WP; WP^.Previous := NIL; WP^.Next := List;
   If(Size = 0)Then
   Begin
    WP^.Buf := NIL; WP^.Size := 0; Addr := NIL;
   End
    Else
   Begin
    Addr := MemAlloc(Size);
    If(Addr = NIL)Then Exit;
    WP^.Buf := Addr; WP^.Size := Size;
   End;
   List := WP;
  End
   else
  Begin
   NewP := MemAlloc(SizeOf(List^));
   If(NewP = NIL)Then Exit;
   WP := List;
   For I := 1 to P do
   Begin
    If(WP = NIL)Then Exit;
    WP := WP^.Next;
   End;
   NewP^.Next := WP; NewP^.Previous := WP^.Previous;
   If(Size = 0)Then
   Begin
    NewP^.Buf := NIL; NewP^.Size := 0; Addr := NIL;
   End
    Else
   Begin
    Addr := MemAlloc(Size);
    If(Addr = NIL)Then Exit;
    NewP^.Buf := Addr; NewP^.Size := Size;
   End;
   WP^.Previous^.Next := NewP; WP^.Previous := NewP;
  End;
  Inc(NB); InsBuf := True;
 End;
End;

Function ArrayList.AddPChr(PChr:PChar):Boolean;
Var Ptr:Pointer; PBuf:PChar Absolute Ptr; L:Word;
Begin
 AddPChr := False; L := StrLen(PChr) + 1;
 If Not(AddBuf(L,Ptr))Then Exit;
 If(Ptr = NIL)Then Exit;
 Move(PChr[0],PBuf[0],L);
 AddPChr := True;
End;

Function ArrayList.AddPChrByte(PChr:PChar;Num:Byte):Boolean;
Var PCharByte:^PCharByteRec; Ptr:Pointer;
Begin
 AddPChrByte := False;
 If Not(AddBuf(SizeOf(PCharByteRec),Ptr))Then Exit;
 PCharByte := Ptr; PCharByte^.PChr := PChr; PCHarByte^.Nm := Num;
 AddPChrByte := True;
End;

Function ArrayList.AddStrByte(Str:String;Num:Byte):Boolean;
Var StrByte:^StrByteRec; Ptr:Pointer; PChr:Array[0..255] of Char;
Begin
 AddStrByte := False;
 If Not(AddBuf(SizeOf(StrByteRec),Ptr))Then Exit;
 StrByte := Ptr; StrPCopy(PChr,Str); StrByte^.PChr := StrNew(PChr);
 StrByte^.Len := Length(Str); StrByte^.Nm := Num; AddStrByte := True;
End;

Function ArrayList.AddStrWord(Str:String;Num:Word):Boolean;
Var StrWord:^StrWordRec; Ptr:Pointer; PChr:Array[0..255] of Char;
Begin
 AddStrWord := False;
 If Not(AddBuf(SizeOf(StrWordRec),Ptr))Then Exit;
 StrWord := Ptr; StrPCopy(PChr,Str); StrWord^.PChr := StrNew(PChr);
 StrWord^.Len := Length(Str); StrWord^.Nm := Num; AddStrWord := True;
End;

Function ArrayList.AddStr(Str:String):Boolean;
Var Ptr:Pointer; PChr:PChar; Size:Word;
Begin
 AddStr := False; Size := Length(Str)+1;
 If(Size < 32)Then Size := 32;
 If Not(AddBuf(Size,Ptr))Then Exit;
 If(Ptr = NIL)Then Exit;
 PChr := Ptr; StrPCopy(PChr,Str); AddStr := True;
End;

Function ArrayList.AddLn:Boolean;
Begin
 AddLn := AddPChr('');
End;

Function ArrayList.InsStr(P:LongInt;Str:String):Boolean;
Var Ptr:Pointer; PChr:PChar; Size:Word;
Begin
 InsStr := False; Size := Length(Str)+1;
 If(Size < 32)Then Size := 32;
 If Not(InsBuf(P,Size,Ptr))Then Exit;
 If(Ptr = NIL)Then Exit;
 PChr := Ptr; StrPCopy(PChr,Str); InsStr := True;
End;

Function ArrayList.InsStrWord(P:LongInt;Str:String;Num:Word):Boolean;
Var StrWord:^StrWordRec; Ptr:Pointer; PChr:Array[0..255] of Char;
Begin
 InsStrWord := False;
 If Not(InsBuf(P,SizeOf(StrWordRec),Ptr))Then Exit;
 StrWord := Ptr; StrPCopy(PChr,Str);
 StrWord^.PChr := StrNew(PChr); StrWord^.Len := Length(Str);
 StrWord^.Nm := Num; InsStrWord := True;
End;

Function ArrayList.AddPChrWord(PChr:PChar;Num:Word):Boolean;
Var PCharWord:^PCharWordRec; Ptr:Pointer;
Begin
 AddPChrWord := False;
 If Not(AddBuf(SizeOf(PCharWordRec),Ptr))Then Exit;
 PCharWord := Ptr; PCharWord^.PChr := PChr;
 PCHarWord^.Nm := Num; AddPChrWord := True;
End;

Function ArrayList.GetBuf(P:LongInt;Var Size:Word):Pointer;
Var WP:RBufPtr; I:LongInt;
Begin
 Size := 0; GetBuf := Nil;
 If(P < 0)or(P >= NB)Then Exit;
 If(P = 0)Then
 Begin
  GetBuf := List^.Buf; Size := List^.Size;
 End
  Else
 Begin
  WP := List;
  For I := 1 to P do
  Begin
   If(WP = NIL)Then Exit;
   WP := WP^.Next;
  End;
  If(WP = NIL)Then Exit;
  GetBuf := WP^.Buf; Size := WP^.Size;
 End;
End;

Function ArrayList._GetStr(P:LongInt):String;
Begin
 _GetStr := StrPas(_GetBuf(P));
End;

Procedure ArrayList.SetPtr(P:LongInt);
Var WP:RBufPtr; I:LongInt;
Begin
 If(P = 0)Then
 Begin
  PCurrPtr := 0; CurrPtr := List;
 End
  else
 If Not(PCurrPtr = P)Then
 Begin
  If(PCurrPtr - 1 = P)Then Previous else
  If(PCurrPtr + 1 = P)Then Next
   else
  Begin
   WP := List;
   If(P > 0)Then For I := 1 to P do
   Begin
    If(WP = NIL)Then Exit;
    WP := WP^.Next;
   End;
   If(WP = NIL)Then Exit;
   PCurrPtr := P;
   CurrPtr  := WP;
  End;
 End;
End;

Procedure ArrayList.Previous;
Begin
 If Not(CurrPtr = NIL)Then
 Begin
  CurrPtr := CurrPtr^.Previous;
  Dec(PCurrPtr);
 End;
End;

Procedure ArrayList.Next;
Begin
 If Not(CurrPtr = NIL)Then
 Begin
  CurrPtr := CurrPtr^.Next;
  Inc(PCurrPtr);
 End;
End;

Function ArrayList._GetCurrBuf:Pointer;
Begin
 If(CurrPtr = NIL)Then _GetCurrBuf := NIL Else _GetCurrBuf := CurrPtr^.Buf;
End;

Function ArrayList.GetCurrBuf(Var Size:Word):Pointer;
Begin
 If(CurrPtr = NIL)Then
 Begin
  GetCurrBuf := NIL; Size := 0;
 End
  Else
 Begin
  GetCurrBuf := CurrPtr^.Buf; Size := CurrPtr^.Size;
 End;
End;

Function ArrayList._GetBuf(P:LongInt):Pointer;
Var Size:Word;
Begin
 _GetBuf := GetBuf(P,Size);
End;

Function ArrayList.RemoveAt(P:LongInt):Boolean;
Var WP:RBufPtr; I:LongInt;
Begin
 RemoveAt := False;
 If(NB = 0)or(P < 0)or(P >= NB)Then Exit;
 If(P = 0)Then
 Begin
  If(List = NIL)Then Exit;
  WP := List;
  FreeMem(WP^.Buf,WP^.Size);
  FreeMem(WP,SizeOf(WP^));
  If(NB > 1)Then
  Begin
   If(List^.Next = NIL)Then Exit;
   WP^.Next^.Previous := NIL; List := List^.Next; CurrPtr := NIL;
   PCurrPtr := -1; Dec(NB); RemoveAt := True;
   Exit;
  End
   else
  Begin
   PCurrPtr := -1; CurrPtr := NIL; List := NIL; EndListPtr := NIL;
   NB := 0; RemoveAt := True;
   Exit;
  End;
 End
  else
 Begin
  WP := List;
  For I := 1 to P do
  Begin
   If(WP = NIL)Then Exit;
   WP := WP^.Next;
  End;
  If(WP = NIL)Then Exit;
  If(NB - 1 = P)Then
  Begin
   EndListPtr := WP^.Previous; WP^.Previous^.Next := NIL;
  End
   Else
  Begin
   WP^.Next^.Previous := WP^.Previous; WP^.Previous^.Next := WP^.Next;
  End;
  FreeMem(WP^.Buf,WP^.Size);
  FreeMem(WP,SizeOf(List^));
  Dec(NB);
  RemoveAt := True;
 End;
End;

Function ArrayList.SetBuf(P:LongInt;Size:Word;Var Addr:Pointer):Boolean;
Var WP:RBufPtr; I:LongInt;
Begin
 SetBuf := False;
 If(P < 0)or(P > NB)Then Exit;
 If(P = NB)Then
 Begin
  SetBuf := AddBuf(Size,Addr);
  Exit;
 End;
 If(P = 0)Then
 Begin
  FreeMem(List^.Buf,List^.Size);
  If(Size = 0)Then
  Begin
   List^.Buf := NIL; List^.Size := 0;
  End
   Else
  Begin
   Addr := MemAlloc(Size);
   If(Addr = NIL)Then Exit;
   List^.Buf := Addr; List^.Size := Size;
  End;
  SetBuf := True;
  Exit;
 End;
 WP := List;
 For I := 1 to P do
 Begin
  If(WP = NIL)Then Exit;
  WP := WP^.Next;
 End;
 FreeMem(WP^.Buf,WP^.Size);
 If(Size = 0)Then
 Begin
  WP^.Buf := NIL; WP^.Size := 0;
 End
  Else
 Begin
  Addr := MemAlloc(Size);
  If(Addr = NIL)Then Exit;
  WP^.Buf := Addr; WP^.Size := Size;
 End;
 SetBuf := True;
End;

Function ArrayList.Count:LongInt;
Begin
 Count := NB;
End;

Function ArrayList.MaxList:LongInt;
Begin
 MaxList := NB - 1;
End;

Destructor ArrayList.Done;
Var WP:RBufPtr; Ptr:^StrByteRec;
Begin
 WP := List;
 While Not(WP = NIL) do
 Begin
  If(WP^.Size = SizeOf(StrByteRec))Then
  Begin
   Ptr := WP^.Buf;
   StrDispose(Ptr^.PChr);
  End;
  FreeMem(WP^.Buf,WP^.Size);
  FreeMem(WP,SizeOf(RBufRec));
  WP := WP^.Next;
 End;
End;


BEGIN
END.