
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGridFilter.pas

  Abstract

    A part of a visual component mmDBGrid.
    Filters forming dialog.

  Author

    Romanovski Denis (01-05-99)

  Revisions history

    Initial  01-05-99  Dennis  Initial version.

--}

unit mmDBGridFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  mmRadioButtonEx, StdCtrls, mmCheckBoxEx, mmComboBox, mBitButton,
  ExtCtrls, mTabSetHor, mmDBGrid, DB, DBTables, ExList;

type
  TfrmDBGridFiltering = class(TForm)
    pnlOkCancel: TPanel;
    btnOk: TmBitButton;
    btnCancel: TmBitButton;
    shpBorder: TShape;
    btnAddCondition: TmBitButton;
    btnDeleteCondition: TmBitButton;
    btnPrior: TmBitButton;
    btnNext: TmBitButton;
    btnSetComplicated: TmBitButton;
    cbCompicated: TmmCheckBoxEx;
    memQuery: TMemo;
    gbCondition: TGroupBox;
    lblColumn: TLabel;
    cbColumn: TmmComboBox;
    lblOperation: TLabel;
    cbOperation: TmmComboBox;
    lblValue: TLabel;
    editValue: TEdit;
    cbNot: TmmCheckBoxEx;
    gbTieKind: TGroupBox;
    rbOR: TmmRadioButtonEx;
    rbAnd: TmmRadioButtonEx;
    lblQuery: TLabel;

    procedure FormCreate(Sender: TObject);

  private
    FGrid: TmmDBGrid;

    procedure SetGrid(const Value: TmmDBGrid);
    procedure SetDefaultValues;
    procedure EnableAll(DoEnable: Boolean);
    function GetSQL: String;

  public
    constructor Create(AnOwner: TComponent); override;

    property Grid: TmmDBGrid read FGrid write SetGrid;
    property SQL: String read GetSQL;
  end;

var
  frmDBGridFiltering: TfrmDBGridFiltering;

implementation

{$R *.DFM}

const
  CONST_EQUAL = '=';
  CONST_NONEQUAL = '<>';
  CONST_BIGGER = '>';
  CONST_SMALLER = '<';
  CONST_BIGGEREQUAL = '>=';
  CONST_SMALLEREQUAL = '<=';
  CONST_NONE = '';

const
  CONST_AND = ' И ';
  CPNST_OR = ' ИЛИ ';

type
  TFilterOperation = (foEqual, foNonEqual, foBigger, foSmaller, foBiggerEqual, foSmallerEqual, foNone);

const  
  OperationLetters: array[TFilterOperation] of string[2] =
    (
      CONST_EQUAL, CONST_NONEQUAL, CONST_BIGGER, CONST_SMALLER, CONST_BIGGEREQUAL,
      CONST_SMALLEREQUAL, CONST_NONE
    );

type
  TTieKind = (tkAnd, tkOr, tkNone);

{
  -----------------------------------------------
  ---   Additional Procedures and functions   ---
  -----------------------------------------------
}

// Удаляет двойные пробелы
function DeleteDoubleSpaces(T: String): String;
var
  I: Integer;
begin
  repeat
    I := AnsiPos('  ', T);
    if I > 0 then T := Copy(T, 1, I - 1) + Copy(T, I + 1, Length(T));
  until I = 0;
end;

// Расшифровывает запрос и возвращает его параметры.
function DecodeSubQuery(T: String; var Col, Val: String; var FO: TFilterOperation): Boolean;
var
  I: Integer;
  C: Integer;
begin
  Result := False;
  T := Trim(T);

  // Производим поиск необходимого символа
  I := AnsiPos(CONST_EQUAL, T);
  if I > 0 then
    FO := foEqual
  else begin
    I := AnsiPos(CONST_NONEQUAL, T);
    if I > 0 then
      FO := foNonEqual
    else begin
      I := AnsiPos(CONST_BIGGER, T);
      if I > 0 then
        FO := foBigger
      else begin
        I := AnsiPos(CONST_SMALLER, T);
        if I > 0 then
          FO := foSmaller
        else begin
          I := AnsiPos(CONST_BIGGEREQUAL, T);
          if I > 0 then
            FO := foBiggerEqual
          else begin
            I := AnsiPos(CONST_SMALLEREQUAL, T);
            if I > 0 then
              FO := foSmallerEqual
            else
              FO := foNone;
          end;
        end;
      end;
    end;
  end;

  // Если необходимый знак найден, то работаем с ним
  if (I > 0) and (FO <> foNone) then
  begin
    Result := True;

    // Кол-во символов на знак
    if FO in [foNonEqual, foBiggerEqual, foSmallerEqual] then
      C := 2
    else
      C := 1;

    // Возвращаем наименование колонки и значение запроса  
    Col := Trim(Copy(T, 1, I - 1));
    Val := Trim(Copy(T, I + C, Length(T)));
  end;
end;

// Разделяет сложный запрос на несколько простых
function DecodeNoBracketsQuery(T: String; Quaries: TStringList): Boolean;
var
  I, L: Integer;
begin
  Result := False;

  // Удаляем все параметры из массива строк
  Quaries.Clear;

  repeat
    // Производим поиск необходимых команд
    I := AnsiPos(CONST_AND, T);
    if I = 0 then
    begin
      I := AnsiPos(CONST_AND, T);
      if I = 0 then
        L := 0
      else
        L := Length(CONST_AND);
    end else
      L := Length(CONST_AND);

    // Если необходимые команды найдены
    if I > 0 then
    begin
      Result := True;
      Quaries.Add(Copy(T, 1, I - 1));

      // Указываем вид связи
      if L = Length(CONST_AND) then
        Quaries.Objects[Quaries.Count - 1] := Pointer(tkAnd)
      else
        Quaries.Objects[Quaries.Count - 1] := Pointer(tkOR);
        
      T := Copy(T, I + L, Length(T));
    end;
  until I = 0;
end;

{
  ---------------------------
  ---   TSubQuery Class   ---
  ---------------------------
}


type
  TSubQuery = class
  private
    FSQL: String;
    FSubs: TExList;
    FParent: TSubQuery;
    FTieKind: TTieKind;
    FFilterOperation: TFilterOperation;
    FColumn: String;
    FValue: String;
    FIsCorrect: Boolean;

    function IsWithBrackets: Boolean;
    procedure AnalizeSQL;

  public
    constructor Create(AnOwner: TSubQuery; AnSQL: String);
    destructor Destroy; override;

    function IsComplicated: Boolean;

  end;

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TSubQuery.Create(AnOwner: TSubQuery; AnSQL: String);
begin
  // Необходимо избавиться от лишних пробелов
  FSQL := DeleteDoubleSpaces(ANSIUpperCase(AnSQL));
  FSubs := TExList.Create;
  FParent := AnOwner;
  FTieKind := tkNone;
  FFilterOperation := foNone;
  FValue := '';
  FColumn := '';
  FIsCorrect := False;

  AnalizeSQL;
end;

{
  Высвобождаем память.
}

destructor TSubQuery.Destroy;
begin
  FSubs.Free;

  inherited Destroy;
end;

{
  Является ли сложным подзапросом.
}

function TSubQuery.IsComplicated: Boolean;
begin
  Result := (ANSIPos('AND', FSQL) > 0) or (ANSIPos('OR', FSQL) > 0);
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Содержит ли запрос скобки.
}

function TSubQuery.IsWithBrackets: Boolean;
begin
  Result := (ANSIPos('(', FSQL) > 0) and (ANSIPos(')', FSQL) > 0);
end;

{
  Произвлдит анализ запроса.
}

procedure TSubQuery.AnalizeSQL;
var
  Quaries: TStringList;
  I: Integer;
begin
  // Если выражение сложное
  if IsComplicated then
  begin
    //  Если имеются скобки, то необходимо их обработать
    if IsWithBrackets then
    begin
    end else begin // Если нет скобок, то разбираем несколько обычных подзапросов
      Quaries := TStringList.Create;
      try
        FIsCorrect := DecodeNoBracketsQuery(FSQL, Quaries);

        if FIsCorrect then // Если получены подзапросы, то создаем объекты для них
          for I := 0 to Quaries.Count - 1 do
            FSubs.Add(TSubQuery.Create(Self, Quaries[I]));
      finally
        Quaries.Free;
      end;
    end;
  end else begin // Если выражение простое
    FIsCorrect := DecodeSubQuery(FSQL, FColumn, FValue, FFilterOperation);
  end;
end;

{
  -------------------------------------
  ---   TfrmDBGridFiltering Class   ---
  -------------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TfrmDBGridFiltering.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FGrid := nil;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Делаем первичные установки.
}

procedure TfrmDBGridFiltering.FormCreate(Sender: TObject);
begin
  EnableAll(True);
  SetDefaultValues;
end;

{
  Устанавливаем таблицу для работы.
}

procedure TfrmDBGridFiltering.SetGrid(const Value: TmmDBGrid);
var
  K: Integer;
begin
  if Value <> FGrid then
  begin
    FGrid := Value;

    if (FGrid <> nil) and (FGrid.DataSource <> nil) and (FGrid.DataSource.DataSet <> nil) then
    begin
      // Добавляем колонки таблицы для дальнейшей работы
      cbColumn.Items.Clear;
      for K := 0 to FGrid.DataSource.DataSet.FieldCount - 1 do
        cbColumn.Items.Add(FGrid.DataSource.DataSet.Fields[K].DisplayName);
    end;
  end;
end;

{
  Производим установки по умолчанию.
}

procedure TfrmDBGridFiltering.SetDefaultValues;
begin
  btnSetComplicated.Enabled := False;
  cbCompicated.Checked := False;

  memQuery.Text := '';
  cbColumn.ItemIndex := 0;
  cbOperation.ItemIndex := 0;

  editValue.Text := '';

  cbNot.Checked := False;
  rbAnd.Checked := True;
end;

{
  Позволяет либо запрещает работу с контролами.
}

procedure TfrmDBGridFiltering.EnableAll(DoEnable: Boolean);
begin
  btnOk.Enabled := DoEnable;
  btnCancel.Enabled := DoEnable;
  btnAddCondition.Enabled := DoEnable;
  btnDeleteCondition.Enabled := DoEnable;
  btnPrior.Enabled := DoEnable;
  btnNext.Enabled := DoEnable;
  btnSetComplicated.Enabled := DoEnable;
  cbCompicated.Enabled := DoEnable;
  memQuery.Enabled := DoEnable;
  gbCondition.Enabled := DoEnable;
  lblColumn.Enabled := DoEnable;
  cbColumn.Enabled := DoEnable;
  lblOperation.Enabled := DoEnable;
  cbOperation.Enabled := DoEnable;
  lblValue.Enabled := DoEnable;
  editValue.Enabled := DoEnable;
  cbNot.Enabled := DoEnable;
  gbTieKind.Enabled := DoEnable;
  rbAnd.Enabled := DoEnable;
  rbOr.Enabled := DoEnable;
  lblQuery.Enabled := DoEnable;
end;

{
  Возвращает текст SQL запроса.
}

function TfrmDBGridFiltering.GetSQL: String;
begin
  if FGrid <> nil then
    Result := (FGrid.DataSource.DataSet as TQuery).SQL.Text
  else
    Result := '';  
end;

end.

