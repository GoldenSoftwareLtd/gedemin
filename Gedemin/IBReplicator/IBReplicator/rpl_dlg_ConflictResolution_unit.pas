unit rpl_dlg_ConflictResolution_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, CheckTreeView, XPTreeView, ExtCtrls, XPButton,
  rpl_frameTable_unit, rpl_frameTableData_unit, DB, DBClient, Contnrs,
  XPEdit, StdCtrls, XPComboBox, rpl_BaseTypes_unit, rpl_const,
  rpl_ReplicationManager_unit, rpl_mnRelations_unit, IBCustomDataSet,
  ActnList, rpl_ResourceString_unit;

type
  TdlgConflictResolution = class(TForm)
    Panel1: TPanel;
    Bevel1: TBevel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    frameTable: TframeTable;
    Splitter2: TSplitter;
    Panel7: TPanel;
    Panel8: TPanel;
    frameTableData: TframeTableData;
    ClientDataSet: TClientDataSet;
    pTop: TPanel;
    lError: TLabel;
    cbErrors: TXPComboBox;
    Panel2: TPanel;
    XPButton2: TXPButton;
    XPButton1: TXPButton;
    ActionList: TActionList;
    actSaveAndExit: TAction;
    actCancelAndExit: TAction;
    ActionList1: TActionList;
    actAdd: TAction;
    actChange: TAction;
    actDelete: TAction;
    actSetConf: TAction;
    actApply: TAction;
    Panel3: TPanel;
    Label1: TLabel;
    cbActions: TXPComboBox;
    XPButton3: TXPButton;
    actViewEvtData: TAction;
    lblDescAction: TLabel;
    procedure cbErrorsSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actSaveAndExitExecute(Sender: TObject);
    procedure actCancelAndExitExecute(Sender: TObject);
    procedure actApplyUpdate(Sender: TObject);
    procedure cbActionsDropDown(Sender: TObject);
    procedure cbActionsSelect(Sender: TObject);
    procedure actApplyExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actChangeExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actSetConfExecute(Sender: TObject);
    procedure frameTableDatatcTypeViewChange(Sender: TObject);
    procedure frameTableDataactAddExecute(Sender: TObject);
    procedure actViewEvtDataExecute(Sender: TObject);
  private
    FErrorList: TObjectList;
    FCurrentError: TrpError;
    FCortege: TrpCortege;
    FEvent: TrpEvent;
    FRelation: TmnRelation;
    FAutoConflictResolution: TNotifyEvent;
    procedure SetErrorList(const Value: TObjectList);
    procedure SetAutoConflictResolution(const Value: TNotifyEvent);
  protected
    procedure OpenDataSets;
    procedure Loaded; override;
    procedure CopyFieldsValue(CopyPrimeKey: Boolean);
    procedure Succes;
    procedure Conformity;
  public
    property ErrorList: TObjectList read FErrorList write SetErrorList;
    property Cortege: TrpCortege read FCortege write FCortege;
    property Event: TrpEvent read FEvent write FEvent;

    property AutoConflictResolution: TNotifyEvent read FAutoConflictResolution write SetAutoConflictResolution;
  end;

var
  dlgConflictResolution: TdlgConflictResolution;

implementation

{$R *.dfm}

{ TdlgConflictResolution }

procedure TdlgConflictResolution.SetErrorList(const Value: TObjectList);
var
  E: TrpError;
  Ev: TrpEvent;
  Rel: TmnRelation;
  I: Integer;
  s: string;
begin
  FErrorList := Value;
  cbErrors.Items.BeginUpdate;
  Ev:= TrpEvent.Create;
  try
    cbErrors.Items.Clear;
    if FErrorList <> nil then
    begin
      for I := 0 to FErrorList.Count - 1 do
      begin
        E := TrpError(FErrorList[I]);
        E.Data.Position := 0;
        Ev.LoadFromStream(E.Data);
        Rel:= TmnRelation(ReplicationManager.Relations.Relations[Ev.RelationKey]);
        s:= Format(ErrorOnAction + ': ', [ReplTypeStr(Ev.ReplType), Rel.RelationName]);
        cbErrors.Items.AddObject(s + E.ErrorDescription, E);
//        cbErrors.Items.AddObject(E.ErrorDescription, E);
      end;
      if FErrorList.Count  > 0 then
      begin
        cbErrors.ItemIndex := 0;
        FCurrentError := TrpError(FErrorList[0]);
        cbErrorsSelect(cbErrors);
      end else
        ModalResult := mrOk;
    end;
  finally
    cbErrors.Items.EndUpdate;
    Ev.Free;
  end;
end;

procedure TdlgConflictResolution.cbErrorsSelect(Sender: TObject);
begin
  with cbErrors do
  begin
    if ItemIndex > - 1 then
    begin
      FCurrentError := TrpError(Items.Objects[ItemIndex]);
    end else
    begin
      raise Exception.Create('sdfsd');
    end;
  end;

  FCurrentError.Data.Position := 0;
  if FCurrentError.Data.Size > 0 then
  begin
    FEvent.LoadFromStream(FCurrentError.Data);
    FCortege.RelationKey := FEvent.RelationKey;
    if FEvent.ReplType <> atDelete then
      FCortege.LoadFromStream(FCurrentError.Data);

{    edtRUIDs.Text:= '';
    for i:= 0 to FCortege.FieldsData.Count - 1 do begin
      if FCortege.FieldsData[i].ValueRUID <> '' then
        edtRUIDs.Text:= edtRUIDs.Text + ' ' + FCortege.FieldsData[i].Field.FieldName + ':' + FCortege.FieldsData[i].ValueRUID;
    end;
    edtSeqNo.Text:= IntToStr(FEvent.Seqno);
    edtNewKey.Text:= FEvent.NewKey;}

    FRelation := TmnRelation(ReplicationManager.Relations.Relations[FEvent.RelationKey]);
    frameTable.RelationName := FRelation.RelationName;
    frameTableData.RelationName := FRelation.RelationName;

    cbErrors.Left := lError.Left + lError.Width + 3;
    cbErrors.Width := cbErrors.Parent.ClientWidth - cbErrors.Left;
  end;

  OpenDataSets;
end;


procedure TdlgConflictResolution.OpenDataSets;
var
  I: Integer;
  DS: TIBDataSet;
begin
  frameTable.UpdateVisible;

  if ClientDataSet.Active then
  begin
    ClientDataSet.Close;
    ClientDataSet.FieldDefs.Clear;
  end;

  DS := TIBDataSet.Create(nil);
  try
    DS.Transaction := ReplDataBase.Transaction;
    DS.BufferChunks := 1;
    DS.SelectSQL.Text := Format('SELECT * FROM %s', [FRelation.RelationName]);
    DS.Open;
    
    for I := 0 to DS.FieldCount - 1 do
    begin
      //Свойство required создаваемого поля устанавливаем в false
      //т.к. для нот нул поля могло передаться нул значение
      //и поэтому при посте возникнит ошибка 
      ClientDataSet.FieldDefs.Add(DS.Fields[I].FieldName,
        DS.Fields[I].DataType, DS.Fields[I].Size,
        False{DS.Fields[I].Required});
    end;

    ClientDataSet.CreateDataSet;
    ClientDataSet.Open;
    ClientDataSet.Insert;
    FCortege.SaveToDataSet(ClientDataSet);
    ClientDataSet.Post;
  finally
    DS.Free;
  end;
end;

procedure TdlgConflictResolution.FormCreate(Sender: TObject);
begin
  frameTable.Transaction := ReplDataBase.Transaction;
  frameTableData.Transaction := ReplDataBase.Transaction;
end;

procedure TdlgConflictResolution.Loaded;
begin
  inherited;
  cbErrors.Width := cbErrors.Parent.ClientWidth - cbErrors.Left;
end;

procedure TdlgConflictResolution.actSaveAndExitExecute(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TdlgConflictResolution.actCancelAndExitExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgConflictResolution.actApplyUpdate(Sender: TObject);
begin
  Taction(Sender).Enabled := cbActions.ItemIndex > - 1;
end;

procedure TdlgConflictResolution.cbActionsDropDown(Sender: TObject);
var
  Items: TStrings;
  I: Integer;
begin
  Items := cbActions.Items;
  if Items.Count = 0 then
  begin
    Items.BeginUpdate;
    try
      Items.Clear;
      for I := 0 to ActionList1.ActionCount - 1 do
      begin
        Items.AddObject(TCustomAction(ActionList1.Actions[I]).Caption, ActionList1.Actions[I]);
      end;
    finally
      Items.EndUpdate;
    end;
  end;
end;

procedure TdlgConflictResolution.cbActionsSelect(Sender: TObject);
begin
  if cbActions.ItemIndex > - 1 then
  begin
    cbActions.ShowHint := True;
    cbActions.Hint := TCustomAction(cbActions.Items.Objects[cbActions.ItemIndex]).Hint;
    lblDescAction.Caption:= cbActions.Hint;
  end
  else begin
    lblDescAction.Caption:= '';
    cbActions.ShowHint := False;
  end;
end;

procedure TdlgConflictResolution.actApplyExecute(Sender: TObject);
begin
  try
    TAction(cbActions.Items.Objects[cbActions.ItemIndex]).Execute;
    Succes;
  except
    on E: Exception do
    begin
      ShowErrorMessage(E.Message);
    end;
  end;
end;

procedure TdlgConflictResolution.actAddExecute(Sender: TObject);
begin
  frameTable.DataSet.Insert;
  CopyFieldsValue(True);
  try
    frameTable.DataSet.Post;
    //Регестрируем изменения
    FEvent.ReplType := atInsert;
    FEvent.ActionTime := Now;
    ReplDataBase.Log.Log(FEvent);
  except
    frameTable.DataSet.Cancel;
    raise;
  end;
end;

procedure TdlgConflictResolution.CopyFieldsValue(CopyPrimeKey: Boolean);
var
  I: Integer;
  F: TmnField;
begin
  for I := 0 to FRelation.Fields.Count - 1 do
  begin
    F := TmnField(FRelation.Fields[I]);
    if not F.IsPrimeKey or CopyPrimeKey then
    begin
      frameTable.DataSet.FieldByName(F.FieldName).Value :=
        ClientDataSet.FieldByName(F.FieldName).Value
    end;
  end;
end;

procedure TdlgConflictResolution.Succes;
var
  Index: Integer;
begin
  Index := cbErrors.ItemIndex;
  FErrorList.Delete(Index);
  cbErrors.Items.Delete(Index);
  //Делаем попытку автоматического разрешения конфликтов
  if Assigned(AutoConflictResolution) then
    AutoConflictResolution(Self);

  if FErrorList.Count > 0 then
  begin
    cbErrors.ItemIndex := 0;
    cbErrorsSelect(cbErrors);
  end else
  begin
     ShowInfoMessage(ALL_CONFLICT_RESOLUTION);
     ModalResult := mrOK;
  end;
end;

procedure TdlgConflictResolution.actChangeExecute(Sender: TObject);
begin
  Conformity;
  frameTable.DataSet.Edit;
  CopyFieldsValue(False);
  try
    frameTable.DataSet.Post;
    //Регестрируем изменения
    FEvent.ReplType := atUpdate;
    FEvent.ActionTime := Now;
    ReplDataBase.Log.Log(FEvent);
  except
    frameTable.DataSet.Cancel;
    raise;
  end;
end;

procedure TdlgConflictResolution.actDeleteExecute(Sender: TObject);
begin
  //
end;

procedure TdlgConflictResolution.Conformity;
var
  RelationKey, ReplKey: Integer;
  PID, SID: Integer;
  I: Integer;
  F: TmnField;
begin
  RelationKey := FRelation.RelationKey;
  ReplKey := TrpError(cbErrors.Items.Objects[cbErrors.ItemIndex]).ReplKey;
  for I := 0 to FRelation.Fields.Count - 1 do
  begin
    F := TmnField(FRelation.Fields[I]);
    {$IFNDEF INTKEY}
    ...
    {$ENDIF}
    if F.IsKey and (F.FieldType = tfInteger) and
      (F.FieldSubType = istFieldType) then
    begin
      PID := frameTable.DataSet.FieldByName(F.FieldName).AsInteger;
      SID := ClientDataSet.FieldByName(F.FieldName).AsInteger;
      ReplDataBase.RUIDManager.RUIDConf.Conformity(PID, SID, RelationKey, ReplKey);
    end;
  end;
end;

procedure TdlgConflictResolution.actSetConfExecute(Sender: TObject);
begin
  Conformity;
end;

procedure TdlgConflictResolution.SetAutoConflictResolution(
  const Value: TNotifyEvent);
begin
  FAutoConflictResolution := Value;
end;

procedure TdlgConflictResolution.frameTableDatatcTypeViewChange(
  Sender: TObject);
begin
  frameTableData.tcTypeViewChange(Sender);

end;

procedure TdlgConflictResolution.frameTableDataactAddExecute(
  Sender: TObject);
begin
  frameTableData.actAddExecute(Sender);

end;

procedure TdlgConflictResolution.actViewEvtDataExecute(Sender: TObject);
begin
{  pnlEvtData.Visible:= not pnlEvtData.Visible;
  if pnlEvtData.Visible then
    Panel3.Height:= 72
  else
    Panel3.Height:= 23;}
end;

end.
