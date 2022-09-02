// ShlTanya, 10.03.2019

unit flt_dlgInputFormulaSyn_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, IBSQL, gsComboElements, IBDatabase,
  SynEditHighlighter, SynHighlighterSQL, SynEdit, gdcBaseInterface;

type
  TdlgInputFormulaSyn = class(TForm)
    ActionList1: TActionList;
    pnlActionBtn: TPanel;
    pnlEndBtn: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlMemo: TPanel;
    actUndo: TAction;
    gscbFields: TgsComboButton;
    gscbOperators: TgsComboButton;
    gscbFunctions: TgsComboButton;
    btnProcedure: TButton;
    actProcedure: TAction;
    btnSQLEditor: TButton;
    seFormula: TSynEdit;
    SynSQLSyn: TSynSQLSyn;
    procedure actUndoExecute(Sender: TObject);
    procedure gscbFieldsCloseUp(Sender: TObject; AnIndex: Integer);
    procedure gscbOperatorsCloseUp(Sender: TObject; AnIndex: Integer);
    procedure actProcedureExecute(Sender: TObject);
    procedure btnSQLEditorClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FComponentKey: TID;
    procedure UpdateSyncs;
  public
    // Эти параметры необходимо присваивать перед вызовом процедуры
    PIBDatabase: TIBDatabase;
    PIBTransaction: TIBTransaction;

    // Даем пользователю написать свои условия или отредактировать запрос
    function InputFormula(var TextFormula: String; const AnSortList, AnFunctionList: TStrings; const AnComponentKey: TID): Boolean;
  end;

var
  dlgInputFormulaSyn: TdlgInputFormulaSyn;

implementation

uses
  flt_sqlfilter_condition_type,
  {$IFDEF SYNEDIT}
  flt_frmSQLEditorSyn_unit,
  {$ELSE}
  flt_frmSQLEditor_unit,
  {$ENDIF}
  flt_dlgViewProcedure_unit, syn_ManagerInterface_unit;

{$R *.DFM}

function TdlgInputFormulaSyn.InputFormula(var TextFormula: String; const AnSortList, AnFunctionList: TStrings; const AnComponentKey: TID): Boolean;
begin
  // Присваиваем локальные переменные
  Result := False;
  FComponentKey := AnComponentKey;
  seFormula.Text := TextFormula;
  gscbFields.Items.Assign(AnSortList);
  gscbFunctions.Items.AddStrings(AnFunctionList);
  if ShowModal = mrOk then
  begin
    TextFormula := seFormula.Text;
    Result := True;
  end;
end;

procedure TdlgInputFormulaSyn.actUndoExecute(Sender: TObject);
begin
  // Возврат введенного
  seFormula.Undo;
end;

procedure TdlgInputFormulaSyn.gscbFieldsCloseUp(Sender: TObject;
  AnIndex: Integer);
begin
  // Добавляем выбранное поле
  if AnIndex > -1 then
    seFormula.SelText :=
     ' ' + TFilterOrderBy((Sender as TgsComboButton).Items.Objects[AnIndex]).TableAlias
     + TFilterOrderBy((Sender as TgsComboButton).Items.Objects[AnIndex]).FieldName + ' ';
  if seFormula.CanFocus then
    seFormula.SetFocus;
end;

procedure TdlgInputFormulaSyn.gscbOperatorsCloseUp(Sender: TObject;
  AnIndex: Integer);
begin
  // Добавляем выбранный оператор
  if AnIndex > -1 then
    seFormula.SelText := (Sender as TgsComboButton).Items[AnIndex];
  if seFormula.CanFocus then
    seFormula.SetFocus;
end;

procedure TdlgInputFormulaSyn.actProcedureExecute(Sender: TObject);
var
  F: TdlgViewProcedure;
begin
  F := TdlgViewProcedure.Create(Self);
  try
    F.ibsqlProcedure.Database := PIBDatabase;
    F.ibsqlProcedure.Transaction := PIBTransaction;
    // Добавляем выбранную процедуру
    seFormula.SelText := F.SelectProcedure(seFormula.Text, FComponentKey);
  finally
    F.Free;
    if seFormula.CanFocus then
      seFormula.SetFocus;
  end;
end;

procedure TdlgInputFormulaSyn.btnSQLEditorClick(Sender: TObject);
begin
  {$IFDEF SYNEDIT}
  with TfrmSQLEditorSyn.Create(Self) do
  {$ELSE}
  with TfrmSQLEditor.Create(Self) do
  {$ENDIF}
  try
    FDatabase := PIBDatabase;
    ShowSQL(seFormula.SelText);
  finally
    Free;
  end;
end;

procedure TdlgInputFormulaSyn.UpdateSyncs;
begin
  if Assigned(SynManager) then
  begin
    SynManager.GetHighlighterOptions(SynSQLSyn);
    seFormula.Font.Assign(SynManager.GetHighlighterFont);
    SynManager.GetSynEditOptions(seFormula);
  end;
end;

procedure TdlgInputFormulaSyn.FormCreate(Sender: TObject);
begin
  UpdateSyncs;
end;

end.
