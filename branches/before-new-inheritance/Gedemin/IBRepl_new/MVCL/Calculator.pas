unit Calculator;

interface
const
 ParamNames : set of Char = ['a'..'d','f'..'z','A'..'D','F'..'Z']; // Допустимые имена переменных
 Operations : set of Char = ['+','-','*','/','^','%']; // Обрабатываемые операции
 Numbers    : set of Char = ['0'..'9',',','.'];  // Составляющие чисел

type
  TParametr = record
    Name:Char;
    Value:Extended;
  end;

  TCalculator = class
  protected
    Param: array of TParametr; // Переменные
    Error: Boolean;
    procedure ErrorMsg(NumberOfError: Word);
    function Rec(n0, nN: Word): Extended;
    function PriorityOfOperation(Operation: Char): Word;
    function BinaryOperation(x: Extended; Operation: Char; y: Extended): Extended;
    function IsParam(n0, nN: Word; var nk: Word; var x: Extended): boolean;
    function IsNumber(n0, nN: Word; var nk: Word; var x: Extended): boolean;
    function IsBrackets(n0, nN: Word; var nk: Word): Boolean;
    function Isfunction(var n0: Word; nN: Word; var nk: Word;
      var NumberOffunction: Word): boolean;
    function GetValueOffunction(n0, nN: Word; NumberOffunction: Word): Extended;
  public
    Expression: String;
    constructor Create;
    function GetValue(var Value: Extended): boolean; // Компиляция выражения
    procedure AddParam(str: string);{ Добавление и обновление
           переменных строками вида '<параметр>=<выражение>'}
    procedure DelParam(Name: Char); // Удаление переменной
  end;
{***************************************************************************}
implementation
uses Sysutils, Dialogs, Matematica;

constructor TCalculator.create;
begin
 setlength(Param,0);
end;

procedure TCalculator.ErrorMsg(NumberOfError: Word);
var
  Msg: string;
begin
 { TODO : Тут нужно переписать через константы }
  case NumberOfError of
    0 : Msg := 'Имя параметра не допустимо';
    1 : Msg := 'Введите выражение';
    5 : Msg := 'Деление на ноль';
    3 : Msg := 'В выражениях вида x^y  x не должно быть меньше нуля';
    7 : Msg := 'Неопределенная поебень';
    8 : Msg := 'Ботва в конце выражения';
    11: Msg := 'У вас разное количество открытых и закрытых скобочек.'+#13+
           'Это говорит о том, что вы малость ебануты';
  else
    Msg := 'Ты что, жертва оборта, издеваешся?';
  end;
  MessageDlg(Msg, mtError, [mbYes], 0);
  Error:=True;
end;


procedure TCalculator.AddParam(str:string);
var
  k,N:Word;
  value:Extended;
  s:string;
  Name:Char;
begin
  for k:=1 to length(str) do
    if str[k]<>' ' then
      if str[k]='=' then
        break
      else
        s:=s+str[k];

  if length(s)=1 then
  begin
    Name:=s[1];
    Expression:=copy(str,k+1,length(str)-k);
    if GetValue(value) then
   {} if Name in ParamNames then
      begin
        k:=0;
        N:=length(Param);
        while k<N do
          if Param[k].Name=Name then
            break
          else
            inc(k);
        if k=N then
        begin
          setlength(Param,k+1);
          Param[k].Name:=Name;
        end;
        Param[k].Value:=Value;
      end{}else
        ErrorMsg(0);
  end;
end;


procedure TCalculator.DelParam(Name:Char);
var
  i,k,N:Word;
  NameLS:char; // Name в нижнем регистре
begin
  NameLS:=Name;{?}
  k:=0;
  N:=length(Param);
  while k<N do
    if Param[k].Name=NameLS then
      break
    else
      inc(k);
  while k<N-1 do
  begin
    Param[k].Name :=Param[k+1].Name;
    Param[k].Value:=Param[k+1].Value;
    inc(k)
  end;
  if N>0 then
    setlength(Param,N-1);
end;

  //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
  //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
  //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}

function TCalculator.Rec(n0, nN: Word): Extended;
var
  nk, NumberOffunction: Word;
  Operation: array[1..100] of Char;
  Value: array[0..100] of Extended;
  Find: Boolean;
  col: Word;
  Sign: Char;
  i, j, k: Word;
begin
  col := 0;
  Sign := Expression[n0];
  if Sign in ['-','+'] then n0 := n0 + 1;
  nk:=n0-1;
  if not Error then
  begin
    while(nk<nN)do
    begin
      Find:=False;
      if IsNumber(n0, nN, nk, Value[col]) then
        Find:=True;
      if IsParam(n0, nN, nk, Value[col]) then
        Find:=True;
      if IsBrackets(n0, nN, nk) then
      begin
        Find := True;
        Value[col] :=Rec(n0+1,nk-1);
      end;
      if Isfunction(n0, nN, nk, NumberOffunction) then
      begin
        Find:=True;
        Value[col]:=GetValueOffunction(n0+1,nk-1,NumberOffunction);
      end;
      if Find then
      begin
        if Expression[nk+1] in Operations then
          if nk+1<nN then
          begin
            col:=col+1;
            Operation[col]:=Expression[nk+1];
            n0:=nk+2;
          end else
          begin
            ErrorMsg(8);
            break;
          end;
      end else
      begin
        ErrorMsg(7);
        nk:=nN;
      end;
    end;
  end;

 if Error then Rec:=0 else
 begin
  For i:=0 to 2 do
  begin j:=1;
   if i=2 then
   if Sign='-' then Value[0]:=-Value[0];
  while j<=col do
   if PriorityOfOperation(Operation[j])=i then
   begin Value[j-1]:=BinaryOperation(Value[j-1],Operation[j],Value[j]);
     for k:=j to col do
     begin Value[k]:=Value[k+1];
           Operation[k]:=Operation[k+1];
     end;
   col:=col-1;
   end
   else j:=j+1;
  end;
  Rec:=Value[0];
 end
end;
{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
function TCalculator.PriorityOfOperation(Operation:Char):Word;
begin
{ TODO : Тут нужно переписать через константы }
  case Operation of
    '^'        : PriorityOfOperation := 0;
    '*','/','%': PriorityOfOperation := 1;
    '+','-'    : PriorityOfOperation := 2
  end;
end;
{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
function TCalculator.BinaryOperation(x:Extended; Operation:Char; y:Extended):Extended;
begin
 case Operation of
   '+':BinaryOperation:=x+y;
   '-':BinaryOperation:=x-y;
   '*':BinaryOperation:=x*y;
   '/':if y=0 then ErrorMsg(5) else BinaryOperation:=x/y;
   '^':if x>0 then
         BinaryOperation:=exp(y*ln(x))
       else
       if x=0 then
         BinaryOperation:=0
       else
         ErrorMsg(4);
   '%':BinaryOperation:=100*x/y;
 end;
end;
{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
function TCalculator.IsParam( n0,nN:Word; var nk:Word; var x:Extended):boolean;
var
  i,k: Word;
  NameOfParam: string;
  return: boolean;
begin
 NameOfParam:='';
 Return := False;
 k := 0;// x:=0;
 while (n0+k<=nN) and (not(Expression[n0+k] in Operations)) do
 begin
   NameOfParam:=NameOfParam+Expression[n0+k];
   k:=k+1;
 end;
 if LowerCase(NameOfParam)='pi' then
 begin
   x:=pi;
   Return:=True;
 end;
 if LowerCase(NameOfParam)='e' then
 begin
   x:=exp(1);
   Return:=True;
 end;
 if k=1 then i:=0;
 while i<length(Param) do
 begin
   if(param[i].Name=NameOfParam)then
   begin
     x:=Param[i].Value;
     Return:=True;
   end;
   inc(i)
 end;
 if Return then
   nk:=n0+k-1;
 IsParam:=Return;
end;
{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
function TCalculator.IsNumber( n0,nN:Word; var nk:Word; var x:Extended):boolean;
var
  i,k:Word;
  str:string;
  return: boolean;
  code:integer;
begin
   str:='';
   code:=1;
   return:=False;
   k:=0;// x:=0;
   while(n0+k<=nN)and(Expression[n0+k] in Numbers)do
   begin
     str:=str+Expression[n0+k];
     k:=k+1;
   end;
   for i:=1 to length(str) do
     if str[i]=',' then
       str[i]:='.';
   try
     if k>0 then
     begin
       val(str,x,code);
       return:=(code=0);
     end;
   except
     ErrorMsg(2);
   end;
   if(n0+k<=nN)and(k>0)then
      if not(Expression[n0+k] in Operations)then
      begin
        return:=False;
        ErrorMsg(1);
      end;
   if Return then
     nk:=n0+k-1;
   IsNumber:=return;
end;
{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
function TCalculator.IsBrackets( n0,nN:Word; var nk:Word):Boolean;
var
  k:Word;
  sk:Word;
  return:boolean;
begin
 k:=0;
 if Expression[n0]='(' then
 begin
   sk:=1;
   while (n0+k<=nN)and(not((Expression[n0+k]=')')and(sk=0)))do
   begin
     k:=k+1;
     if (Expression[n0+k]=')') then sk:=sk-1;
     if (Expression[n0+k]='(') then sk:=sk+1;
   end;
 end;
 if((k<>0)and(sk=0))then
   nk:=n0+k;
 return:=((k<>0)and(sk=0));
 IsBrackets:=return;
end;
{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
function TCalculator.GetValueOffunction(n0,nN:Word; NumberOffunction:Word):Extended;
var
  x,y:array of Extended;
  i,n,k,sk:word;
  find:boolean;
begin
   n:=0;  k:=0;
   while(n0+k<=nN)do
   begin
    sk:=0;
    while((n0+k<=nN) and (not((Expression[n0+k]=';')and(sk=0))))do
    begin
     if (Expression[n0+k]='(') then
       sk:=sk+1;
     if (Expression[n0+k]=')') then
       sk:=sk-1;
     inc(k);
    end;
    if k>0 then
    begin
      y:=copy(x,0,n);
      setlength(x,n+1);
      if n>1 then
        for i:=0 to n-2 do
          x[i]:=y[i];
      x[n]:=Rec(n0,n0+k-1);
    end;
    n0:=n0+k+1;
    inc(n); k:=0;
   end;
   setlength(y,0);
   case NumberOffunction of
     1 :GetValueOffunction:=sin_M(x);
     2 :GetValueOffunction:=cos_M(x);
     3 :GetValueOffunction:=exp_M(x);
     4 :GetValueOffunction:= ln_M(x);
     5 :GetValueOffunction:= tg_M(x);
     6 :GetValueOffunction:= lg_M(x);
     7 :GetValueOffunction:=max_M(x);
     8 :GetValueOffunction:=min_M(x);
     9 :GetValueOffunction:=log_M(x);
     10:GetValueOffunction:=ctg_M(x);
   end;
end;
{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
function TCalculator.Isfunction(var n0:Word;nN:Word; var nk:Word; var NumberOffunction:Word):boolean;
var
  return:boolean;
  d1,d2,k:Word;
  NameOffunction:string;
begin
 d1:=n0;
 NameOffunction:='';
 return:=False; k:=0;
 while(n0+k<=nN)and(Expression[n0+k]<>'(')do
 begin
   NameOffunction:=NameOffunction+Expression[n0+k];
   inc(k);
 end;
 if LowerCase(NameOffunction)='sin' then
 begin
   return:=True;
   NumberOffunction:=1;
   d1:=n0+2;
 end;
 if LowerCase(NameOffunction)='cos' then
 begin
   return:=True;
   NumberOffunction:=2;
   d1:=n0+2;
 end;
 if LowerCase(NameOffunction)='exp' then
 begin
   return:=True;
   NumberOffunction:=3;
   d1:=n0+2;
 end;
 if LowerCase(NameOffunction)='ln'  then
 begin
   return:=True;
   NumberOffunction:=4;
   d1:=n0+1;
 end;
 if LowerCase(NameOffunction)='tg'  then
 begin
   return:=True;
   NumberOffunction:=5;
   d1:=n0+1;
 end;
 if LowerCase(NameOffunction)='lg'  then
 begin
   return:=True;
   NumberOffunction:=6;
   d1:=n0+1;
 end;
 if LowerCase(NameOffunction)='max' then
 begin
   return:=True;
   NumberOffunction:=7;
   d1:=n0+2;
 end;
 if LowerCase(NameOffunction)='min' then
 begin
   return:=True;
   NumberOffunction:=8;
   d1:=n0+2;
 end;
 if LowerCase(NameOffunction)='log' then
 begin
   return:=True;
   NumberOffunction:=9;
   d1:=n0+2;
 end;
 if LowerCase(NameOffunction)='ctg' then
 begin
   return:=True;
   NumberOffunction:=10;
   d1:=n0+2;
 end;

 if Return then
 if not(IsBrackets(d1+1,nN,d2))then
 begin
   return:=False;
   ErrorMsg(4);
 end;
 if Return then
 begin
   nk:=d2;
   n0:=d1+1
 end;
 Isfunction:=return;
end;


function TCalculator.GetValue(var Value:Extended):boolean;
var
  i,sk:integer;
  str:string;
{Main function}
begin
 Error:=False; sk:=0;
    {удаление пробелов}
 for i:=1 to length(Expression) do
   if Expression[i]<>' ' then str:=str+Expression[i];
   Expression:=str;
    {проверка на скобки}
   for i:=1 to length(Expression) do
   begin
     if (Expression[i]='(') then sk:=sk+1;
     if (Expression[i]=')') then sk:=sk-1;
   end;
   if sk<>0 then
   begin
     ErrorMsg(11);
     GetValue:=False
   end else
   if length(Expression)<>0 then
   begin
     Value:=Rec(1,length(Expression));
     GetValue:=not error
   end else
   begin
     ErrorMsg(1);
     GetValue:=False
   end;
end;

end.
