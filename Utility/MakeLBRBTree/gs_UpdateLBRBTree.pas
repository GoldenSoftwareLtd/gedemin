unit gs_UpdateLBRBTree;

interface

uses
  SysUtils, Classes, Graphics, Controls,
  StdCtrls, contnrs;

type
  TUpdateLBRBTree = class
  private
    FStatements: TObjectList;
    FTableName: String;

    function GetPrefix(TableName: String): String;
    function GetName(TableName: String): String;

  public
    constructor Create(ATableName: String);
    destructor Destroy; override;

    property Statements: TObjectList read FStatements;

    procedure ReadFromFile(FName: String);
  end;


type
  //Метки для обозначения начала процедур, триггеров, исключений
//  TStartLabels = (lbStartProcedure, lbStartTrigger, lbException);
  TNameLabels = (nlbTableName, nlbPrefix, nlbName);

const
//  StartLabelsText: array [TStartLabels] of String = ('::STARTPROCEDURE', '::STARTTRIGGER', '::STARTEXCEPTION');
  NameLabelsText : array [TNameLabels] of String = ('::TABLENAME', '::PREFIX', '::NAME');

  cstStartLabel = '::START';
  cstEndLabel = '^';


implementation

{TUpdateLBRBTree}

//Функция возвращает название таблицы без префикса
constructor TUpdateLBRBTree.Create(ATableName: String);
begin
  FStatements := TObjectList.Create;
  FTableName := ATableName;
end;

destructor TUpdateLBRBTree.Destroy;
begin
  FStatements.Free;
end;

function TUpdateLBRBTree.GetName(TableName: String): String;
begin
  if AnsiPos('_', TableName) > 0 then
    Result := AnsiUpperCase(Trim(Copy(TableName, AnsiPos('_', TableName) + 1,
      Length(TableName) - AnsiPos('_', TableName))))
  else
    Result := AnsiUpperCase(Trim(TableName));
end;

//Функция возвращает префикс из названия таблицы
function TUpdateLBRBTree.GetPrefix(TableName: String): String;
begin
  if AnsiPos('_', TableName) > 0 then
    Result := AnsiUpperCase(Trim(Copy(TableName, 1, AnsiPos('_', TableName) - 1)))
  else
    Result := '';
end;

procedure TUpdateLBRBTree.ReadFromFile(FName: String);
var
  F: Text;
  CurrSt: String;
//  lb: TStartLabels;
  nlb: TNameLabels;
  StList: TStringList;
  St: String;
begin
  try
  	AssignFile(F, FName);
  	Reset(F);
    while not Eof(F) do
    begin
      Readln(F, CurrSt);
{      for lb := lbStartProcedure to lbException do
      begin
        MessageBox(HWND(nil), PChar(StartLabelsText[lb]), '', MB_OK);
      end;                                                           }
      {for lb := lbStartProcedure to lbException do
      begin}
     //   MessageBox(HWND(nil), PChar(StartLabelsText[lb]), '', MB_OK);
      if AnsiCompareText(Trim(CurrSt), cstStartLabel) = 0 then
      begin
        StList := TStringList.Create;
        Readln(F, CurrSt);
        //Пока не найдена метка конец
        while not ((AnsiCompareText(Trim(CurrSt), cstEndLabel) = 0) or Eof(F)) do
        begin
          //Если найдена метка имя таблицы, то заменяем ее в тексте на имя таблицы
          for nlb := nlbTableName to nlbName do
          begin
            case nlb of
              nlbTableName: St := FTableName;
              nlbPrefix: St := GetPrefix(FTableName);
              nlbName: St := GetName(FtableName);
              else St := ''
            end;

            if AnsiPos(NameLabelsText[nlb], UpperCase(CurrSt)) > 0 then
            begin
              CurrSt := Copy(CurrSt, 1, AnsiPos(NameLabelsText[nlb], UpperCase(CurrSt)) - 1) +
                AnsiLowerCase(St) +
                Copy(CurrSt, AnsiPos(NameLabelsText[nlb], UpperCase(CurrSt)) +
                Length(NameLabelsText[nlb]), Length(CurrSt) - AnsiPos(NameLabelsText[nlb], UpperCase(CurrSt)) -
                Length(NameLabelsText[nlb]) + 1);
            end;
          end;

          StList.Add(CurrSt);
          Readln(F, CurrSt);
        end;

        FStatements.Add(StList);
      end;
      {end;}
    end;
    Close(F);
  except

  end;
end;

end.
 
