// ShlTanya, 09.03.2019

unit wiz_dlgTrExpressionEditorForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_ExpressionEditorForm_unit, ActnList, StdCtrls, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, Menus, SynEditHighlighter, SynHighlighterVBScript,
  SynEdit, SynMemo;

type
  TdlgTrExpressionEditorForm = class(TExpressionEditorForm)
    actAddField: TAction;
    TBItem1: TTBItem;
    pmAddField: TPopupMenu;
    procedure FormDestroy(Sender: TObject);
    procedure actAddFieldUpdate(Sender: TObject);
    procedure actAddFieldExecute(Sender: TObject);
    procedure pmAddFieldPopup(Sender: TObject);
    
  private
    FRefFields: TStrings;
    FCurrFields: TStrings;
    FDateFields: TStrings;
    FOtherFields: TStrings;
    FDocumentFields: TStrings;

    procedure CheckDocumentFields;
    procedure ClickField(Sender: TObject);
    function GetCurrFields: TStrings;
    function GetDateFields: TStrings;
    function GetOtherFields: TStrings;
    function GetRefFields: TStrings;

  public
    property RefFields: TStrings read GetRefFields;
    property CurrFields: TStrings read GetCurrFields;
    property DateFields: TStrings read GetDateFields;
    property OtherFields: TStrings read GetOtherFields;
  end;

var
  dlgTrExpressionEditorForm: TdlgTrExpressionEditorForm;

implementation

{$R *.DFM}

{ TdlgTrExpressionEditorForm }

procedure TdlgTrExpressionEditorForm.FormDestroy(Sender: TObject);
begin
  FRefFields.Free;
  FCurrFields.Free;
  FDateFields.Free;
  FOtherFields.Free;
  FDocumentFields.Free;
  
  inherited;
end;

procedure TdlgTrExpressionEditorForm.actAddFieldUpdate(Sender: TObject);
begin
  CheckDocumentFields;
  TAction(Sender).Enabled := FRefFields.Count +  FCurrFields.Count +
    FDateFields.Count + FOtherFields.Count > 0;
end;

procedure TdlgTrExpressionEditorForm.CheckDocumentFields;
begin
  if FRefFields = nil then
    FRefFields := TStringList.Create;
  if FCurrFields = nil then
    FCurrFields := TStringList.Create;
  if FDateFields = nil then
    FDateFields := TStringList.Create;
  if FOtherFields = nil then
    FOtherFields := TStringList.Create;

  if FDocumentFields = nil then
    FDocumentFields := TStringList.Create;
end;

procedure TdlgTrExpressionEditorForm.actAddFieldExecute(Sender: TObject);
var
  R: TRect;
begin
  with tbtMain do
  begin
    R := View.Find(TBItem1).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;

  pmAddField.Popup(R.Left, R.Bottom);
end;

procedure TdlgTrExpressionEditorForm.pmAddFieldPopup(Sender: TObject);
var
  I: Integer;
  MI, M: TMenuItem;
begin
  CheckDocumentFields;
  pmAddField.Items.Clear;
  FDocumentFields.Clear;

  if FRefFields.Count > 0 then
  begin
    M := TMenuItem.Create(pmAddField);
    M.Caption := 'Ссылки и ключи';
    pmAddField.Items.Add(M);
    for I := 0 to FRefFields.Count - 1 do
    begin
      MI := TMenuItem.Create(pmAddField);
      MI.Caption := FRefFields.Names[I];
      MI.Tag := FDocumentFields.Add(FRefFields[I]);
      MI.OnClick := ClickField;

      M.Add(MI);
    end;
  end;
  if FCurrFields.Count > 0 then
  begin
    M := TMenuItem.Create(pmAddField);
    M.Caption := 'Числовые';
    pmAddField.Items.Add(M);
    for I := 0 to FCurrFields.Count - 1 do
    begin
      MI := TMenuItem.Create(pmAddField);
      MI.Caption := FCurrFields.Names[I];
      MI.Tag := FDocumentFields.Add(FCurrFields[I]);
      MI.OnClick := ClickField;

      M.Add(MI);
    end;
  end;
  if FDateFields.Count > 0 then
  begin
    M := TMenuItem.Create(pmAddField);
    M.Caption := 'Даты';
    pmAddField.Items.Add(M);
    for I := 0 to FDateFields.Count - 1 do
    begin
      MI := TMenuItem.Create(pmAddField);
      MI.Caption := FDateFields.Names[I];
      MI.Tag := FDocumentFields.Add(FDateFields[I]);
      MI.OnClick := ClickField;

      M.Add(MI);
    end;
  end;
  if FOtherFields.Count > 0 then
  begin
    M := TMenuItem.Create(pmAddField);
    M.Caption := 'Прочие';
    pmAddField.Items.Add(M);
    for I := 0 to FOtherFields.Count - 1 do
    begin
      MI := TMenuItem.Create(pmAddField);
      MI.Caption := FOtherFields.Names[I];
      MI.Tag := FDocumentFields.Add(FOtherFields[I]);
      MI.OnClick := ClickField;

      M.Add(MI);
    end;
  end;
end;

procedure TdlgTrExpressionEditorForm.ClickField(Sender: TObject);
begin
  mExpression.SelText := Format('%s',
    [FDocumentFields.Values[FDocumentFields.Names[TMenuItem(Sender).Tag]]]);
end;

function TdlgTrExpressionEditorForm.GetCurrFields: TStrings;
begin
  CheckDocumentFields;
  Result := FCurrFields
end;

function TdlgTrExpressionEditorForm.GetDateFields: TStrings;
begin
  CheckDocumentFields;
  Result := FDateFields
end;

function TdlgTrExpressionEditorForm.GetOtherFields: TStrings;
begin
  CheckDocumentFields;
  Result := FOtherFields
end;

function TdlgTrExpressionEditorForm.GetRefFields: TStrings;
begin
  CheckDocumentFields;
  Result := FRefFields
end;

end.
