unit gd_dlgQuantityEntryEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ImgList, ActnList, Buttons, ToolWin,
  gsIBLookupComboBox, gdcBase, contnrs;

type
  TdlgQuantityEntryEdit = class(TForm)
    pnlButton: TPanel;
    btnOk: TButton;
    bntCancel: TButton;
    pnlMain: TPanel;
    lvQuantity: TListView;
    tbMain: TToolBar;
    btnAdd: TSpeedButton;
    btnDelete: TSpeedButton;
    alMain: TActionList;
    actAdd: TAction;
    actDelete: TAction;
    ilMain: TImageList;
    gbQSetting: TGroupBox;
    rgUnit: TRadioGroup;
    cbValueKey: TComboBox;
    gbQuantity: TGroupBox;
    mmQuantity: TMemo;
    cbQHead: TComboBox;
    btnAddQHead: TBitBtn;
    cbStandart: TComboBox;
    procedure actAddExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure rgUnitClick(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure btnAddQHeadClick(Sender: TObject);
    procedure btnAddQLineClick(Sender: TObject);
    procedure lvQuantitySelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure mmQuantityChange(Sender: TObject);
    procedure cbStandartChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FgdcBaseHead: TgdcBase;
    FgdcBaseline: TgdcBase;
    FValueKeyList: TList;

    procedure EnableQSetting(EnableFlag: Boolean);
    procedure FillQNFields;
    procedure SetgdcBaseHead(const Value: TgdcBase);
    procedure SetgdcBaseline(const Value: TgdcBase);
    procedure SetupFields;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    function ShowQuantity(const QuantList: TObjectList): Integer; overload;
    procedure FillQuantList(const QuantList: TObjectList);

    property gdcBaseHead: TgdcBase read FgdcBaseHead write SetgdcBaseHead;
    property gdcBaseline: TgdcBase read FgdcBaseline write SetgdcBaseline;
  end;

var
  dlgQuantityEntryEdit: TdlgQuantityEntryEdit;

implementation

uses
  IBSQL, gdcBaseInterface, gd_dlgEntryFunctionEdit, gdcClasses_interface,
  at_classes, gd_dlgEntryFunctionWizard
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure TdlgQuantityEntryEdit.actAddExecute(Sender: TObject);
var
  li: TListItem;
begin
  lvQuantity.Selected := nil;
  if lvQuantity.Items.Count = 0 then
    EnableQSetting(True);

  li := lvQuantity.Items.Add;
  li.ImageIndex := 2;
  li.Selected := True;
  li.Focused := True;
  li.Data := TQuantObject.Create;

  cbStandart.ItemIndex := -1;
  cbValueKey.ItemIndex := -1;
  mmQuantity.Lines.Text := '';
  cbQHead.ItemIndex := -1;
end;

procedure TdlgQuantityEntryEdit.actDeleteExecute(Sender: TObject);
var
  Obj: TObject;
begin
  if (lvQuantity.Selected <> nil) and
    (lvQuantity.Items.IndexOf(lvQuantity.Selected) > -1) then
  begin
    if lvQuantity.Selected.Data <> nil then
    begin
      Obj := TObject(lvQuantity.Selected.Data);
      lvQuantity.Selected.Data := nil;
      Obj.Free;
    end;
    lvQuantity.Items.Delete(lvQuantity.Items.IndexOf(lvQuantity.Selected));
  end;
  if lvQuantity.Items.Count = 0 then
    EnableQSetting(False)
  else
    lvQuantity.ItemFocused.Selected := True;
end;

procedure TdlgQuantityEntryEdit.rgUnitClick(Sender: TObject);
begin
  case rgUnit.ItemIndex of
    0:
    begin
      cbStandart.Enabled := True;
      cbValueKey.Enabled := False;
    end;
    1:
    begin
      cbStandart.Enabled := False;
      cbValueKey.Enabled := True;
    end;
  end;
end;

procedure TdlgQuantityEntryEdit.actDeleteUpdate(Sender: TObject);
begin
  if lvQuantity.Items.Count = 0 then
  begin
    if actDelete.Enabled then
    begin
      actDelete.Enabled := False;
      EnableQSetting(False);
    end
  end else
    if not actDelete.Enabled then
    begin
      actDelete.Enabled := True;
      EnableQSetting(True);
    end;
end;

procedure TdlgQuantityEntryEdit.EnableQSetting(EnableFlag: Boolean);

  procedure EnableControls(const AControl: TWinControl);
  var
    i: Integer;
  begin
    for i := 0 to AControl.ControlCount - 1 do
    begin
      if EnableFlag and ((AControl.Controls[i] = cbStandart) or
        (AControl.Controls[i] = cbValueKey)) then
        rgUnitClick(nil);

      AControl.Controls[i].Enabled := EnableFlag;
      if AControl.Controls[i].InheritsFrom(TWinControl) then
        EnableControls(TWinControl(AControl.Controls[i]));
    end;
  end;
begin
  EnableControls(gbQSetting);
end;

procedure TdlgQuantityEntryEdit.SetgdcBaseHead(const Value: TgdcBase);
begin
  FgdcBaseHead := Value;
end;

procedure TdlgQuantityEntryEdit.SetgdcBaseline(const Value: TgdcBase);
begin
  FgdcBaseline := Value;
end;

constructor TdlgQuantityEntryEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FValueKeyList := TList.Create;

  rgUnitClick(nil);
end;

procedure TdlgQuantityEntryEdit.btnAddQHeadClick(Sender: TObject);
begin
  mmQuantity.SelText := GetFieldFromCB(cbQHead.Text);
end;

procedure TdlgQuantityEntryEdit.btnAddQLineClick(Sender: TObject);
begin
  AddFieldText(mmQuantity, cbQHead.Text, dcpLine);
end;

procedure TdlgQuantityEntryEdit.lvQuantitySelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    mmQuantity.Text := Item.Caption;
    cbStandart.ItemIndex := -1;
    cbValueKey.ItemIndex := -1;
  end;
end;

procedure TdlgQuantityEntryEdit.SetupFields;
var
  ibsql: TIBSQL;
const
  csUnit = '%s(%s)';
begin
  cbStandart.Clear;
  cbValueKey.Clear;
  FValueKeyList.Clear;
  cbQHead.Clear;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_value ORDER BY name';
    ibsql.ExecQuery;
    with ibsql do
      while not Eof do
      begin
        cbStandart.Items.Add(Format(csUnit,
          [FieldByName('name').AsString,
          FieldByName('description').AsString]));
        FValueKeyList.Add(Pointer(FieldByName('id').AsInteger));
        ibsql.Next;
      end;
  finally
    ibsql.Free;
  end;

  if FgdcBaseHead <> nil then
  begin
    AddDocList(cbQHead, FgdcBaseHead, dcpHeader);
  end;
  if FgdcBaseline <> nil then
  begin
    AddDocList(cbQHead, FgdcBaseline, dcpLine);
  end;

  FillQNFields;
  rgUnitClick(rgUnit);
end;

function TdlgQuantityEntryEdit.ShowQuantity(const QuantList: TObjectList): Integer;
var
  I, K: Integer;
  li: TListItem;
  Recovery: Boolean;
begin
  SetupFields;

  lvQuantity.Items.Clear;
  Recovery := True;
  for I := 0 to QuantList.Count - 1 do
  begin
    if (Length(Trim(TQuantObject(QuantList[I]).Quant)) = 0) or
      (Length(Trim(TQuantObject(QuantList[I]).UnitStr)) = 0) then
      Continue;

    li := lvQuantity.Items.Add;
    li.Caption := TQuantObject(QuantList[I]).Quant;
    case TQuantObject(QuantList[I]).UnitType of
      utRUID:
      begin
        K := FValueKeyList.IndexOf(Pointer(gdcBaseManager.GetIDByRUIDString(TQuantObject(QuantList[I]).UnitStr)));
        if K = -1 then
        begin
          Recovery := False;
          li.SubItems.Add(' ');
        end else
          li.SubItems.Add(cbStandart.Items[K]);
      end;
      utKey:
      begin
        li.SubItems.Add(TQuantObject(QuantList[I]).UnitStr);
      end;
    end;
    li.Data := TQuantObject.Create;
    li.ImageIndex := 2;
    TQuantObject(li.Data).Assign(TQuantObject(QuantList[I]));
  end;

  if not Recovery then
    MessageBox(Self.Handle, 'Количественные показатели восстанвлены с ошибками.',
      'Ошибка', MB_OK or MB_TOPMOST or MB_TASKMODAL or MB_ICONERROR);

  Result := ShowModal;
end;

procedure TdlgQuantityEntryEdit.mmQuantityChange(Sender: TObject);
begin
  if lvQuantity.Selected = nil then
    Exit;
    
  lvQuantity.Selected.Caption := Trim(mmQuantity.Text);
  if lvQuantity.Selected.Data = nil then
    lvQuantity.Selected.Data := TQuantObject.Create;
  TQuantObject(lvQuantity.Selected.Data).Quant := lvQuantity.Selected.Caption;

end;

procedure TdlgQuantityEntryEdit.cbStandartChange(Sender: TObject);
var
  I: Integer;
  Str: String;
  Obj: TObject;
begin
  if lvQuantity.Selected = nil then
    Exit;

  if lvQuantity.Selected.SubItems.Count = 0 then
    lvQuantity.Selected.SubItems.Add(' ');
  case rgUnit.ItemIndex of
    0:
    begin
      if lvQuantity.Selected.Data = nil then
        lvQuantity.Selected.Data := TQuantObject.Create;
      try
      I := cbStandart.Items.IndexOf(cbStandart.Text);
      if I > -1 then
      begin
        Str := gdcBaseManager.GetRUIDStringByID(Integer(FValueKeyList[I]));
        if Str <> '' then
          TQuantObject(lvQuantity.Selected.Data).UnitStr := Str
        else
          raise Exception.Create('Для данной единицы измерения не создан RUID.'#13#10 + 'Присвоение не возможно.');
        TQuantObject(lvQuantity.Selected.Data).UnitType := utRUID;
        lvQuantity.Selected.SubItems[0] := cbStandart.Text;
      end;
      except
        if lvQuantity.Selected.Data <> nil then
        begin
          Obj := TObject(lvQuantity.Selected.Data);
          lvQuantity.Selected.Data := nil;
          Obj.Free;
        end;
        raise;
      end;
    end;
    1:
    begin
      lvQuantity.Selected.SubItems[0] := GetFieldFromCB(cbValueKey.Text);
      if lvQuantity.Selected.Data = nil then
        lvQuantity.Selected.Data := TQuantObject.Create;

      TQuantObject(lvQuantity.Selected.Data).UnitStr := lvQuantity.Selected.SubItems[0];
      TQuantObject(lvQuantity.Selected.Data).UnitType := utKey;
    end;
  end;
end;

procedure TdlgQuantityEntryEdit.FillQNFields;
var
  RFDoc: TatRelationField;
  atForeignKey: TatForeignKey;
  Str: String;
const
  cValueTable = 'GD_VALUE';

  procedure AddValueFields(const gdcDoc: TgdcBase);
  var
    AI: Integer;

  begin
    for AI := 0 to gdcDoc.Fields.Count - 1 do
    begin
      try
        Str := gdcDoc.RelationByAliasName(gdcDoc.Fields[AI].FieldName);
      except
      end;
      if Length(Str) = 0 then
        Continue;
      RFDoc := atDatabase.FindRelationField(Str,
        GetOriginFieldName(gdcDoc.Fields[AI].Origin));
      if (RfDoc = nil) or (RFDoc.ForeignKey = nil) then
        Continue;

      while RFDoc.ForeignKey <> nil do
      begin
        atForeignKey := RFDoc.ForeignKey;
        RFDoc := atForeignKey.ReferencesField;
      end;

      if AnsiUpperCase(atForeignKey.ReferencesRelation.RelationName) = cValueTable then
      begin
        if gdcDoc = FgdcBaseHead then
          Str := Format(cCurrStr, [cwHeader, gdcDoc.Fields[AI].DisplayName, gdcDoc.Fields[AI].FieldName])
        else
          if gdcDoc = FgdcBaseLine then
            Str := Format(cCurrStr, [cwLine, gdcDoc.Fields[AI].DisplayName, gdcDoc.Fields[AI].FieldName]);
        cbValueKey.Items.Add(Str);
      end;
    end;
  end;

begin
  cbValueKey.Text := '';
  cbValueKey.Items.Clear;

  if FgdcBaseHead <> nil then
    AddValueFields(FgdcBaseHead);
  if FgdcBaseLine <> nil then
    AddValueFields(FgdcBaseLine);
end;

destructor TdlgQuantityEntryEdit.Destroy;
var
  I: Integer;
  Obj: TObject;
begin
  for I := 0 to lvQuantity.Items.Count - 1 do
    if lvQuantity.Items[I].Data <> nil then
    begin
      Obj := TObject(lvQuantity.Items[I].Data);
      lvQuantity.Items[I].Data := nil;
      Obj.Free;
    end;

  FValueKeyList.Free;

  inherited;
end;

procedure TdlgQuantityEntryEdit.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  I: Integer;
begin
  if ModalResult = idOk then
  begin
    for I := 0 to lvQuantity.Items.Count - 1 do
      if lvQuantity.Items[I].Data <> nil then
      with TQuantObject(lvQuantity.Items[I].Data) do
      begin
        if (Length(Trim(Quant)) > 0) and (Length(Trim(UnitStr)) = 0) then
        begin
          lvQuantity.Items[I].Selected := True;
          raise Exception.Create('Не задано значение единицы измерения.');
        end;
        if (Length(Trim(Quant)) = 0) and (Length(Trim(UnitStr)) > 0) then
        begin
          lvQuantity.Items[I].Selected := True;
          raise Exception.Create('Не задано значение количества.');
        end;
      end;
  end;
end;

procedure TdlgQuantityEntryEdit.FillQuantList(
  const QuantList: TObjectList);
begin
  while QuantList.Count > 0 do
    QuantList.Delete(QuantList.Count - 1);

  while lvQuantity.Items.Count > 0 do
  begin
    if lvQuantity.Items[lvQuantity.Items.Count - 1].Data <> nil then
    begin
      QuantList.Add(lvQuantity.Items[lvQuantity.Items.Count - 1].Data);
    end;
    lvQuantity.Items.Delete(lvQuantity.Items.Count - 1);
  end;
end;

end.
