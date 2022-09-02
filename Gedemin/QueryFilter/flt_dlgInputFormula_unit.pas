// ShlTanya, 10.03.2019

unit flt_dlgInputFormula_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, IBSQL, gsComboElements, IBDatabase;

type
  TdlgInputFormula = class(TForm)
    ActionList1: TActionList;
    pnlActionBtn: TPanel;
    pnlEndBtn: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlMemo: TPanel;
    mmFormula: TMemo;
    actUndo: TAction;
    gscbFields: TgsComboButton;
    gscbOperators: TgsComboButton;
    gscbFunctions: TgsComboButton;
    btnProcedure: TButton;
    actProcedure: TAction;
    btnSQLEditor: TButton;
    procedure actUndoExecute(Sender: TObject);
    procedure gscbFieldsCloseUp(Sender: TObject; AnIndex: Integer);
    procedure gscbOperatorsCloseUp(Sender: TObject; AnIndex: Integer);
    procedure actProcedureExecute(Sender: TObject);
    procedure btnSQLEditorClick(Sender: TObject);
  private
    FComponentKey: TID;
  public
    // Эти параметры необходимо присваивать перед вызовом процедуры
    PIBDatabase: TIBDatabase;
    PIBTransaction: TIBTransaction;

    // Даем пользователю написать свои условия или отредактировать запрос
    function InputFormula(var TextFormula: String; const AnSortList, AnFunctionList: TStrings; const AnComponentKey: TID): Boolean;
  end;

var
  dlgInputFormula: TdlgInputFormula;

implementation

uses
  flt_sqlfilter_condition_type,
  {$IFDEF SYNEDIT}
  flt_frmSQLEditorSyn_unit,
  {$ELSE}
  flt_frmSQLEditor_unit,
  {$ENDIF}
  flt_dlgViewProcedure_unit;

{$R *.DFM}

function TdlgInputFormula.InputFormula(var TextFormula: String; const AnSortList, AnFunctionList: TStrings; const AnComponentKey: TID): Boolean;
begin
  // Присваиваем локальные переменные
  Result := False;
  FComponentKey := AnComponentKey;
  mmFormula.Text := TextFormula;
  gscbFields.Items.Assign(AnSortList);
  gscbFunctions.Items.AddStrings(AnFunctionList);
  if ShowModal = mrOk then
  begin
    TextFormula := mmFormula.Text;
    Result := True;
  end;
end;

procedure TdlgInputFormula.actUndoExecute(Sender: TObject);
begin
  // Возврат введенного
  mmFormula.Undo;
end;

procedure TdlgInputFormula.gscbFieldsCloseUp(Sender: TObject;
  AnIndex: Integer);
begin
  // Добавляем выбранное поле
  if AnIndex > -1 then
    mmFormula.SelText :=
     ' ' + TFilterOrderBy((Sender as TgsComboButton).Items.Objects[AnIndex]).TableAlias
     + TFilterOrderBy((Sender as TgsComboButton).Items.Objects[AnIndex]).FieldName + ' ';
  if mmFormula.CanFocus then
    mmFormula.SetFocus;
end;

procedure TdlgInputFormula.gscbOperatorsCloseUp(Sender: TObject;
  AnIndex: Integer);
begin
  // Добавляем выбранный оператор
  if AnIndex > -1 then
    mmFormula.SelText := (Sender as TgsComboButton).Items[AnIndex];
  if mmFormula.CanFocus then
    mmFormula.SetFocus;
end;

procedure TdlgInputFormula.actProcedureExecute(Sender: TObject);
var
  F: TdlgViewProcedure;
begin
  F := TdlgViewProcedure.Create(Self);
  try
    F.ibsqlProcedure.Database := PIBDatabase;
    F.ibsqlProcedure.Transaction := PIBTransaction;
    // Добавляем выбранную процедуру
    mmFormula.SelText := F.SelectProcedure(mmFormula.Text, FComponentKey);
  finally
    F.Free;
    if mmFormula.CanFocus then
      mmFormula.SetFocus;
  end;
end;

procedure TdlgInputFormula.btnSQLEditorClick(Sender: TObject);
begin
  {$IFDEF SYNEDIT}
  with TfrmSQLEditorSyn.Create(Self) do
  {$ELSE}
  with TfrmSQLEditor.Create(Self) do
  {$ENDIF}
  try
    FDatabase := PIBDatabase;
    ShowSQL(mmFormula.SelText);
  finally
    Free;
  end;
end;

end.
