unit wiz_dlgQunatyForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, ExtCtrls, StdCtrls, BtnEdit, wiz_FunctionBlock_unit, gdcConstants,
  wiz_DocumentInfo_unit, Menus, at_classes, wiz_Strings_unit, gdcBaseInterface,
  IBSQL, gdc_frmAnalyticsSel_unit, wiz_dlgEditForm_unit;

type
  TdlgQuantiyForm = class(TdlgBaseEditForm)
    pBottom: TPanel;
    bCancel: TButton;
    bOK: TButton;
    Bevel1: TBevel;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    lfactor: TLabel;
    beUnit: TBtnEdit;
    Label1: TLabel;
    beQuantity: TBtnEdit;
    pmUnit: TPopupMenu;
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure beUnitBtnOnClick(Sender: TObject);
    procedure beQuantityBtnOnClick(Sender: TObject);
    procedure pmUnitPopup(Sender: TObject);
    procedure beUnitChange(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
  private
    FDocumentHead: TDocumentInfo;
    FDocumentLine: TDocumentLineInfo;
    FAccountKey: Integer;

    procedure SetQuantity(const Value: string);
    procedure SetQUnit(const Value: string);
    function GetQUnit: string;
    function GetQuantity: string;
    function GetQUnitName: string;
    procedure SetAccountKey(const Value: Integer);
  protected
    FUnitKey: Integer;

    procedure CheckDocumentInfo;
    procedure ClickUnit(Sender: TObject);
    procedure ClickExpression(Sender: TObject);
    procedure ClickDocumentUnit(Sender: TObject);
  public
    { Public declarations }
    property QUnit: string read GetQUnit write SetQUnit;
    property UnitName: string read GetQUnitName;
    property Quantity: string read GetQuantity write SetQuantity;
    property AccountKey: Integer read FAccountKey write SetAccountKey;
  end;

var
  dlgQuantiyForm: TdlgQuantiyForm;

implementation

{$R *.DFM}

procedure TdlgQuantiyForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel

end;

procedure TdlgQuantiyForm.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TdlgQuantiyForm.CheckDocumentInfo;
begin
  Assert((MainFunction <> nil) and (MainFunction is TTrEntryFunctionBlock), 'Ошибочный тип основной функции');

  FDocumentHead := TTrEntryFunctionBlock(MainFunction).DocumentHead;

  FDocumentLine := TTrEntryFunctionBlock(MainFunction).DocumentLine
end;

procedure TdlgQuantiyForm.beUnitBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmUnit);
end;

procedure TdlgQuantiyForm.beQuantityBtnOnClick(Sender: TObject);
begin
  beQuantity.Text := FBlock.EditExpression(beQuantity.Text, FBlock);
end;

procedure TdlgQuantiyForm.pmUnitPopup(Sender: TObject);
var
  MI: TMenuItem;
  List: Tlist;
  I: Integer;
  Field: TatRelationField;
begin
  pmUnit.Items.Clear;

  Field := atDataBase.FindRelationField(AC_QUANTITY, fnValueKey);
  if Field.References = nil then
  begin
    raise Exception.Create(RUS_NO_FOREIGN_KEY_ON_AC_QUANTITY);
  end;

  if (Field <> nil) then
  begin
    MI := TmenuItem.Create(pmUnit);
    MI.Caption := 'Выражение...';
    MI.OnClick := ClickExpression;
    pmUnit.Items.Add(MI);

    MI := TmenuItem.Create(pmUnit);
    MI.Caption := 'Единица измерения...';
    MI.OnClick := ClickUnit;
    pmUnit.Items.Add(MI);

    if (MainFunction <> nil) and (MainFunction is TTrEntryFunctionBlock) and
      (Field.References <> nil) then
    begin
      with MainFunction as TTrEntryFunctionBlock do
      begin
        List := TList.Create;
        try
          if DocumentHead <> nil then
          begin
            DocumentHead.ForeignFields(Field.References.RelationName, List)
          end;
          if DocumentLine <> nil then
          begin
            DocumentLine.ForeignFields(Field.References.RelationName, List)
          end;

          if List.Count > 0 then
          begin
            MI := TmenuItem.Create(Self.pmUnit);
            MI.Caption := '-';
            Self.pmUnit.Items.Add(MI);

            for I := 0 to List.Count - 1 do
            begin
              MI := TmenuItem.Create(Self.pmUnit);
              MI.Caption := TDocumentField(List[I]).DisplayName;
              MI.OnClick := ClickDocumentUnit;
              MI.Tag := Integer(List[I]);
              Self.pmUnit.Items.Add(MI);
            end;
          end;
        finally
          List.Free;
        end;
      end;
    end;
  end;
end;

procedure TdlgQuantiyForm.ClickDocumentUnit(Sender: TObject);
begin
  beUnit.Text := TDocumentField(TMenuItem(Sender).Tag).Script;
  FUnitKey := 0;
end;

procedure TdlgQuantiyForm.ClickUnit(Sender: TObject);
var
  D: TfrmAnalyticSel;
  Field: TatRelationField;
begin
  Field := atDataBase.FindRelationField(AC_QUANTITY, fnValueKey);

  if Field <> nil then
  begin
    D := TfrmAnalyticSel.Create(nil);
    try
      D.DataField := Field;

{      if FAccountKey > 0 then
      begin
        D.Condition := Format(' EXISTS(SELECT av.id FROM AC_ACCVALUE av WHERE av.accountkey = %d)', [FAccountKey]);
      end;}

      if D.ShowModal = mrOk then
      begin
        beUnit.Text := D.AnalyticAlias;
        FUnitKey := D.AnalyticsKey;
      end;
    finally
      D.Free;
    end;
  end;
end;

procedure TdlgQuantiyForm.SetQuantity(const Value: string);
begin
  beQuantity.Text := Value;
end;

procedure TdlgQuantiyForm.SetQUnit(const Value: string);
var
  SQL: TIBSQL;
  ID: Integer;
begin
  beUnit.Text := '';
  try
    ID := gdcBaseManager.GetIDByRUIDString(Value);
  except
    ID := 0;
  end;
  if ID > 0 then
  begin
    SQL := TIBSQl.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQl.SQl.Text := 'SELECT name FROM gd_value WHERE id = :id';
      SQL.ParamByName(fnId).AsInteger := ID;
      SQL.ExecQuery;
      if SQL.RecordCount > 0 then
        beUnit.Text := SQL.FieldByName(fnName).AsString;
    finally
      SQL.Free;
    end;
  end else
    beUnit.Text := Value;
  FUnitKey := Id;
end;

function TdlgQuantiyForm.GetQUnit: string;
begin
  if FUnitKey > 0 then
  begin
    Result := gdcBaseManager.GetRuidStringById(FUnitKey);
  end else
    Result := beUnit.Text
end;

procedure TdlgQuantiyForm.beUnitChange(Sender: TObject);
begin
  FUnitKey := 0;
end;

function TdlgQuantiyForm.GetQuantity: string;
begin
  Result := beQuantity.Text
end;

function TdlgQuantiyForm.GetQUnitName: string;
begin
  Result := beUnit.Text;
end;

procedure TdlgQuantiyForm.actOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (Trim(beUnit.Text) > '') and (Trim(beQuantity.Text) > '')
end;

procedure TdlgQuantiyForm.ClickExpression(Sender: TObject);
begin
  beUnit.Text := FBlock.EditExpression(beUnit.Text, FBlock);
end;

procedure TdlgQuantiyForm.SetAccountKey(const Value: Integer);
begin
  FAccountKey := Value;
end;

end.
