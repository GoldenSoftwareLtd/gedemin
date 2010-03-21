/* Tech yourself UDF programming in 21 minutes! */
/* Delta version */
/*********************************************************/
/*                                                       */
/*      InterBase User Defined Fuctions examples         */
/*       Copyright (c) 1996,1997 Oleg Kukartsev          */
/*                                                       */
/*      Written by:                                      */
/*        Oleg Kukarthev                                 */
/*      E-mail: Please look at InterBase List Server     */
/*              interbase@esunix1.emporia.edu            */
/*                                                       */
/*********************************************************/

/*
 Before run this script do following:

 1. Place UDFDemo.dll as said in UDFLib.pas
 2. Change next SQL statements:
   A. Where to create UDFS.GDB
   B. Enter correct SYSDBA password
*/

/* create database "IB_SERVER:/PATH/UDFS.GDB" user "SYSDBA" password "masterkey"; */
create database "c:\UDFS.GDB" user "SYSDBA" password "m";

/* After UDF was created and declared to a database, it can be used in */
/* a SQL statements whereever a built-in function is permited.         */

set autoddl off;

create table TestUDF(
  S SmallInt not null,
  I Integer,
  C Char(10),
  V VarChar(10),
  D Date,
  B Blob sub_type Text,
  primary key (S)
);

declare external function AddA
  smallint, integer
returns
  integer by value
entry_point "Add_A"
module_name "UDFDemo.dll";

declare external function AddB
  smallint, integer
returns
  integer
entry_point "Add_B"
module_name "UDFDemo.dll";

declare external function AddB2
  smallint, integer
returns
  integer
entry_point "Add_B2"
module_name "UDFDemo.dll";

declare external function TestNullValue
  integer, smallint, varchar(10)
returns
  parameter 3
entry_point "TestNullValue"
module_name "UDFDemo.dll";

declare external function CheckInvalidValue
  cstring(10)
returns
  integer by value
entry_point "CheckInvalidValue"
module_name "UDFDemo.dll";

declare external function StrToInt
  cstring(10)
returns
  integer by value
entry_point "StrToIntX"
module_name "UDFDemo.dll";

declare external function Fctrl
  smallint
returns
  double precision by value
entry_point "Factorial"
module_name "UDFDemo.dll";

declare external function TrimRight
  cstring(1000)
returns
  cstring(1000)
entry_point "TrimRight"
module_name "UDFDemo.dll";

declare external function Trim
  cstring(256), integer
returns
  cstring(256)
entry_point "Trim"
module_name "UDFDemo.dll";

declare external function ConcatA
  cstring(255), varchar(255), varchar(255)
returns
  parameter 3
entry_point "ConcatString_A"
module_name "UDFDemo.dll";

declare external function ConcatB
  cstring(255), varchar(255), cstring(255)
returns
  parameter 3
entry_point "ConcatString_B"
module_name "UDFDemo.dll";

declare external function ConcatA2
  cstring(255), varchar(255)
returns
  varchar(255)
entry_point "ConcatString_A2"
module_name "UDFDemo.dll";

declare external function ConcatB2
  cstring(255), varchar(255)
returns
  cstring(255)
entry_point "ConcatString_B2"
module_name "UDFDemo.dll";

declare external function CStrLen
  cstring(255)
returns
  integer by value
entry_point "CStrLength"
module_name "UDFDemo.dll";

declare external function VarCharLen
  varchar(255)
returns
  integer by value
entry_point "VarCharLength"
module_name "UDFDemo.dll";

declare external function CharLen
  char(255)
returns
  integer by value
entry_point "CharLength"
module_name "UDFDemo.dll";

declare external function IntToHex
  integer, varchar(10)
returns
  parameter 2
entry_point "HexValue"
module_name "UDFDemo.dll";

declare external function SubString
  cstring(256), integer, integer
returns
  cstring(256)
entry_point "SubString"
module_name "UDFDemo.dll";

declare external function PositionStr
  cstring(256), cstring(256)
returns
  integer by value
entry_point "Position"
module_name "UDFDemo.dll";

declare external function RightStr
  cstring(256), integer
returns
  cstring(256)
entry_point "Right"
module_name "UDFDemo.dll";

declare external function Raise_Exception
returns
  integer by value
entry_point "RaiseException"
module_name "UDFDemo.dll";

declare external function DateToStr
  date, cstring(255)
returns
  parameter 2
entry_point "DateToString"
module_name "UDFDemo.dll";

declare external function ServerDate
  date
returns
  date
entry_point "ServerDate"
module_name "UDFDemo.dll";

declare external function Check_Point
  cstring(255)
returns
  integer by value
entry_point "CheckPoint"
module_name "UDFDemo.dll";

declare external function BlobInfo
  blob, cstring(255)
returns
  parameter 2
entry_point "BLObInfo"
module_name "UDFDemo.dll";

declare external function BlobSearchSubStr
  blob, cstring(255)
returns
  integer by value
entry_point "BLObSearch"
module_name "UDFDemo.dll";

declare external function BLObToCString
  blob, cstring(16384)
returns
  parameter 2
entry_point "BLObToCString"
module_name "UDFDemo.dll";

declare external function CStringToBLOb
  cstring(16384), blob
returns
  parameter 2
entry_point "CStringToBLOb"
module_name "UDFDemo.dll";

declare external function LoadBLObFromFile
  cstring(256), blob
returns
  parameter 2
entry_point "LoadBLObFromFile"
module_name "UDFDemo.dll";


/*
drop external function AddA;
drop external function AddB;
drop external function AddB2;
drop external function TestNullValue;
drop external function CheckInvalidValue;
drop external function StrToInt;
drop external function Fctrl;
drop external function TrimRight;
drop external function Trim;
drop external function ConcatA;
drop external function ConcatB;
drop external function CharLen;
drop external function VarCharLen;
drop external function CStrLen;
drop external function ConcatA2;
drop external function ConcatB2;
drop external function SubString;
drop external function PositionStr;
drop external function RightStr
drop external function IntToHex
drop external function DateToStr;
drop external function ServerDate;
drop external function BLObInfo;
drop external function BLObSearchSubStr;
drop external function BLObToCString;
*/

commit work;

set term ^;

create procedure Len
  returns (Char_Len SmallInt, VarChar_Len SmallInt,
  VarChar_As_Char_Len SmallInt, Char_As_VarChar_Len SmallInt)
as
  declare variable Cs char(10);
  declare variable Vc varchar(10);
begin
  for select C, V
  from TestUDF
  into :Cs, :Vc
  do begin
    Char_Len = CStrLen(Cs);
    VarChar_Len = VarCharLen(Vc);

/* "Implicit" cast VarChar as Char -> Pass VarChar instead Char */
    VarChar_As_Char_Len = CStrLen(Vc);

/* "Implicit" cast Char as VarChar -> Pass Char instead VarChar */
    Char_As_VarChar_Len = VarCharLen(Cs);
    suspend;
  end
end^

create procedure Hex(I Integer)
  returns (C Char(10), V VarChar(10))
as
begin
/* Function IntToHex returns varchar(10) */
/* You can assign its result ether char(10) or varchar(10) variable */
  C = IntToHex(I);
  V = IntToHex(I);
  suspend;
end^

/*
  To pass null value, I must pass addition "null indicator"
  To return null value, also I must return "null indicator",
  So any UDF returns only one value... I must use two UDF function,
  1-st to return "main" value and 2-nd to return "null indicator".
*/

create procedure IsNull(I Integer)
  returns (V VarChar(10))
as
  declare variable Ix smallint;
begin
/*
  It must be something like this:
  if (I is null) then V = 'null';
  else V = IntToHex(I);

  But "let UDF know" the value in null!
  So I suggest in addition to "main" value
  to pass "null indicator"
*/

  if (I is null) then Ix = 1;
  else Ix = 0;
  V = TestNullValue(I, Ix);

  suspend;
end^

create procedure TestIsNull
  returns (V VarChar(10))
as
  declare variable I Integer;
begin
  execute procedure IsNull(100) returning_values V;
  suspend;

  I = null;
  execute procedure IsNull(I) returning_values V;
  suspend;
end^

create procedure StrToInt(V Char(10))
  returns (I integer)
as
begin  if (CheckInvalidValue(V) = 1) then I = null;
  else I = StrToInt(V);
  suspend;
end
^

create procedure TestStrToInt
  returns (I integer, J integer)
as
  declare variable Cs char(10);  declare variable Vc varchar(10);
begin
  for select C, V
  from TestUDF
  into :Cs, :Vc
  do begin
    execute procedure StrToInt(Cs) returning_values I;
    execute procedure StrToInt(Vc) returning_values J;
    suspend;
  end
end
^

create procedure HowToDebugSP
  returns (C char(10), V varchar(10), I integer, D date)
as
  declare variable N integer;
  declare variable Dummy integer;
begin
  Dummy = Check_Point('Enter to procedure "HowToDebugSP"');

  N = 0;
  for select C, V, I, D
  from TestUDF
  into :C, :V, :I, :D
  do begin
    N = N + 1;
    Dummy = Check_Point(' Line ' || N || ' C = ' || C || ' V = ' || V ||
      ' I = ' || I || ' D = ' || D || ' => ' || DateToStr(D));
    suspend;
  end

  Dummy = Check_Point('Exit from procedure "HowToDebugSP"');
end^

create procedure InsertBLObToId(Id Integer, C VarChar(16384))
as
  declare variable B BLOb;
begin
  /* Dummy read operation, you'll get GPF without it */
  select B from TestUDF where S = :Id into :B;

  B = CStringToBLOb(C);
  update TestUDF set B = :B where S = :Id;

  /* This doesn't work !!! */
  /* update TestUDF set B = CStringToBLOb(C) where S = :Id; */
end^

/* How to copy BLOb */
create procedure DuplicateBLOb(FromId Integer, ToId Integer)
as
  declare variable B BLOb;
begin
  select B from TestUDF where S = :FromId into :B;
  update TestUDF set B = :B where S = :ToId;
end^

create procedure InsertBLObFromFileToId(Id Integer, C VarChar(16384))
as
  declare variable B BLOb;
begin
  /* Dummy read operation, you'll get GPF without it */
  select B from TestUDF where S = :Id into :B;

  B = LoadBLObFromFile(C);
  update TestUDF set B = :B where S = :Id;
end^

set term ;^

commit work;

/* Populate table with data */
insert into TestUDF (S, I, C, V, D)
values (10, 100, '12345', 'ABCD ', '10/1/96 23:45:01.234');
/* It's VarChar field, so this ^ space "wouldn't be lost" */

insert into TestUDF (S, I, C, V, D)
values (100, 10, 'ABCD ', '12345', '10.1.96 1:23:56.789');
/*                    ^                          */
/* It's Char field, so this space "will be lost" */

/* Pay attention to date field */
/* 10/1/96 is  1 October 1996  */
/* 10.1.96 is 10 January 1996  */

commit work;

/* Use follow SQL statments to test UDFs */
select AddA(S, 5), AddB(5, I), Fctrl(99)
from TestUDF
where AddA(S, I) = 110;

select SubString('123456789ABCDEF', 1, 5) from TestUDF;
select SubString('123456789ABCDEF', 5, 100) from TestUDF;

select PositionStr('56789ABC', '123456789ABCDEF') from TestUDF;
select PositionStr('', '123456789ABCDEF') from TestUDF;
select PositionStr('012', '123456789ABCDEF') from TestUDF;

select RightStr('123456789ABCDEF', 5) from TestUDF;

/* Trim Left & Right */
select Trim('  A B C  ', 3) from TestUDF;
/* Trim Left */
select Trim('  A B C  ', 2) from TestUDF;
/* Trim Right */
select Trim('  A B C  ', 1) from TestUDF;

select CStrLen(ConcatA(C, V)), ConcatA(C, V)
from TestUDF;

select CStrLen(ConcatA(C, '67890')), ConcatA(C, '67890')
from TestUDF;

select CStrLen(ConcatA('!@#$%', V)), ConcatA('!@#$%', V)
from TestUDF;

select CStrLen(ConcatA('!@#$%', '67890')), ConcatA('!@#$%', '67890')
from TestUDF;

select VarCharLen(ConcatB(C, V)), ConcatB(C, V)
from TestUDF;

select VarCharLen(ConcatB(C, '67890')), ConcatB(C, '67890')
from TestUDF;

select VarCharLen(ConcatB('!@#$%', V)), ConcatB('!@#$%', V)
from TestUDF;

select VarCharLen(ConcatB('!@#$%', '67890')), ConcatB('!@#$%', '67890')
from TestUDF;

select * from Len;

select * from TestIsNull;
select * from StrToInt('100 ');
select * from StrToInt('');
select * from TestStrToInt;

select I, IntToHex(I)
from TestUDF;

select *
from Hex(305419896);

select Check_Point(' C = ' || C || ' V = ' || V || ' I = ' || I ||
 ' D = ' || D || ' => ' || DateToStr(D))
from TestUDF;

select * from HowToDebugSP;

select cast('Today' as date) - cast('Yesterday' as date)
from TestUDF;

select D, DateToStr(D)
from TestUDF;

select DateToStr('Now')
from TestUDF;

select ServerDate('24.08.95')  /* <= '24.08.95' ONLY SPACE for result!!! */
from TestUDF;

select ServerDate('11.06.96'), DateToStr(ServerDate('18.09.96'))
from TestUDF;

/* BLOb functions */

execute procedure InsertBLObToId(10,
'This BLOb
 is conversion
 from ...

 string value!');

execute procedure DuplicateBLOb(10, 100);

execute procedure InsertBLObToId(100,
'This BLOb
 contains
 "Text to find" string.
 Check this using
 BlobSearchSubStr
 function.');

select BlobInfo(B)
from TestUDF;

select B, BlobSearchSubStr(B, 'Text to find')
from TestUDF;

select B from TestUDF
where B containing 'Text to find';

/* Be carefull !!! IB doesn't handle a exception raised in UDF */
/*
select Raise_Exception
from TestUDF;
*/

