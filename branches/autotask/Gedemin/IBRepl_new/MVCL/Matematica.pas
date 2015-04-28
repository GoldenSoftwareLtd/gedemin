unit Matematica;

interface

function Sin_M(x:array of Extended):Extended;
function Cos_M(x:array of Extended):Extended;
function Exp_M(x:array of Extended):Extended;
function  Ln_M(x:array of Extended):Extended;
function  Tg_M(x:array of Extended):Extended;
function  Lg_M(x:array of Extended):Extended;
function Max_M(x:array of Extended):Extended;
function Min_M(x:array of Extended):Extended;
function Log_M(x:array of Extended):Extended;
function Ctg_M(x:array of Extended):Extended;

implementation
uses Sysutils,Dialogs;

Procedure Error(NumberOfError:word);
var Msg:string;
Begin
 case NumberOfError of
   0 :Msg:='Не соответствующее количество параметров';
   1 :Msg:='ln(x) определен только при x>0! Пора бы узнать.';
   2 :Msg:='tg(x) в точках вида x=k*pi+pi/2 (где к - целое число) не определен! Пора бы узнать.';
   3 :Msg:='lg(x) определен только при x>0! Пора бы узнать.';
   4 :Msg:='ctg(x) в точках вида x=k*pi (где к - целое число) не определен! Пора бы узнать.';
 Else Msg:='Ты что, жертва оборта, издеваешся?';
 End;
 MessageDlg(Msg,mtError,[mbYes],0);
End;

function Sin_M(x:array of Extended):Extended;
var return:Extended;
begin  return:=0;
 if length(x)=1 then
  return:=Sin(x[0])
 else  Error(0);
 Sin_M:=return;
end;

function Cos_M(x:array of Extended):Extended;
var return:Extended;
begin  return:=0;
 if length(x)=1 then
  return:=Cos(x[0])
 else  Error(0);
 Cos_M:=return;
end;

function Exp_M(x:array of Extended):Extended;
var return:Extended;
begin  return:=0;
 if length(x)=1 then
  return:=Exp(x[0])
 else  Error(0);
 Exp_M:=return;
end;

function  Ln_M(x:array of Extended):Extended;
var return:Extended;
begin  return:=0;
 if length(x)=1 then
  begin
  if x[0]>0 then return:=ln(x[0]) else Error(1);
  end
 else  Error(0);
 Ln_M:=return;
end;

function  Tg_M(x:array of Extended):Extended;
var return:Extended;
begin  return:=0;
 if length(x)=1 then
  begin
  if Round(1E+10*cos(x[0]))<>0 then return:=sin(x[0])/cos(x[0]) else Error(2);
  end
 else  Error(0);
 Tg_M:=return;
end;

function  Lg_M(x:array of Extended):Extended;
var return:Extended;
begin return:=0;
 if length(x)=1 then
  begin
  if x[0]>0 then return:=ln(x[0])/ln(10) else Error(3);
  end
 else  Error(0);
 Lg_M:=return;
end;

function Max_M(x:array of Extended):Extended;
var return:Extended;
    n,i:word;
begin  return:=0;
       n:=length(x);
 if n>0 then
  begin
  for i:=0 to n-1 do
   if x[0]<x[i] then x[0]:=x[i];
   return:=x[0];
  end
 else Error(0);
 Max_M:=return;
end;

function Min_M(x:array of Extended):Extended;
var return:Extended;
    n,i:word;
begin  return:=0;
       n:=length(x);
 if n>0 then
  begin
  for i:=0 to n-1 do
   if x[0]>x[i] then x[0]:=x[i];
   return:=x[0];
  end
 else Error(0);
 Min_M:=return;
end;

function  Log_M(x:array of Extended):Extended;
var return:Extended;
begin return:=0;
 if length(x)=2 then
  begin
  if(x[0]>0)and(x[1]>0)then return:=ln(x[0])/ln(x[1]) else Error(3);
  end
 else  Error(0);
 Log_M:=return;
end;

function Ctg_M(x:array of Extended):Extended;
var return:Extended;
begin  return:=0;
 if length(x)=1 then
  begin
  if Round(1E+10*sin(x[0]))<>0 then return:=cos(x[0])/sin(x[0]) else Error(4);
  end
 else  Error(0);
 Ctg_M:=return;
end;

end.
