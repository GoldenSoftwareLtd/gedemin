unit gdc_attr_dlgSettingOrder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, gdc_dlgG_unit, ComCtrls, Menus, Db, ActnList, gdcBase,
  gdcSetting, ImgList, TB2Item, TB2Dock, TB2Toolbar, ExtCtrls;

type
  Egdc_dlgSettingOrder = class(Exception);

  Tgdc_dlgSettingOrder = class(Tgdc_dlgG)
    bbtnUp: TBitBtn;
    bbtnDown: TBitBtn;
    lbxSetting: TListBox;
    actUp: TAction;
    actDown: TAction;
    pnlMain: TPanel;
    lvSetting: TListView;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    actTop: TAction;
    actBottom: TAction;
    TBSeparatorItem1: TTBSeparatorItem;
    TBSeparatorItem2: TTBSeparatorItem;
    procedure actUpExecute(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
    procedure lbxSettingMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure actOkExecute(Sender: TObject);
    procedure lbxSettingDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbxSettingDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure actTopExecute(Sender: TObject);
    procedure actBottomExecute(Sender: TObject);
    procedure lvSettingDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lvSettingMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    IsModified: Boolean;

    //перемещает выделенные элементы на заданное (дельта) число позиций
    //если дельта < 0 , то вверх, если дельта > 0 то вниз
    procedure MoveItemsByDelta(Delta: Integer);

    procedure MoveListViewItem(AIndexFrom, AIndexTo: Word);
    procedure MoveStringListItem(AIndexFrom, AIndexTo: Word);

  protected
    OrderList: TStringList;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupDialog; override;
  end;

var
  gdc_dlgSettingOrder: Tgdc_dlgSettingOrder;

implementation
uses
  IBSQL, IBDatabase, gd_classlist;

{$R *.DFM}

{ Tgdc_dlgSettingOrder }

constructor Tgdc_dlgSettingOrder.Create(AnOwner: TComponent);
begin
  inherited;
  OrderList := TStringList.Create;
  IsModified := False;
end;

destructor Tgdc_dlgSettingOrder.Destroy;
begin
  OrderList.Free;
  inherited;
end;

procedure Tgdc_dlgSettingOrder.actUpExecute(Sender: TObject);
begin
  Self.MoveItemsByDelta(-1);
end;

procedure Tgdc_dlgSettingOrder.actDownExecute(Sender: TObject);
begin
  Self.MoveItemsByDelta(1);
end;

procedure Tgdc_dlgSettingOrder.actTopExecute(Sender: TObject);
begin
  Self.MoveItemsByDelta(-OrderList.Count);
end;

procedure Tgdc_dlgSettingOrder.actBottomExecute(Sender: TObject);
begin
  Self.MoveItemsByDelta(OrderList.Count);
end;

procedure Tgdc_dlgSettingOrder.lbxSettingMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if lbxSetting.Items.Count > 0 then
    lbxSetting.Hint := lbxSetting.Items[lbxSetting.ItemIndex]
  else
    lbxSetting.Hint := '';
end;

procedure Tgdc_dlgSettingOrder.actOkExecute(Sender: TObject);
var
  I: Integer;
  DidActivate: Boolean;
  ibsql: TIBSQL;

  function ActivateObjectTransaction(ATransaction: TIBTransaction): Boolean;
  begin
    if ATransaction.InTransaction then
      Result := False
    else
    begin
      ATransaction.StartTransaction;
      Result := True;
    end;
  end;

begin
  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    DidActivate := ActivateObjectTransaction(gdcObject.Transaction);
    ibsql.Database := gdcObject.Database;
    ibsql.Transaction := gdcObject.Transaction;
    ibsql.SQL.Text := 'UPDATE at_settingpos SET objectorder = :new_objectorder ' +
      ' WHERE id = :old_id ';
    for I := 0 to OrderList.Count - 1 do
    begin
      if IsModified then
      begin
        ibsql.Close;
        ibsql.ParamByName('new_objectorder').AsString := IntToStr(I);
        ibsql.ParamByName('old_id').AsString := OrderList.Names[I];
        ibsql.ExecQuery;
      end;
    end;
  finally
    ibsql.Free;
    if DidActivate and gdcObject.Transaction.InTransaction then
      try
        gdcObject.Transaction.Commit;
      except
        gdcObject.Transaction.Rollback;
        raise Egdc_dlgSettingOrder.Create('При сохранении изменений произошла ошибка!');
      end;
  end;
  ModalResult := mrOk;
end;

procedure Tgdc_dlgSettingOrder.lbxSettingDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  I, K, Index: Integer;
  ACount: Integer;
  IsUp: Boolean;

begin
  if Sender is TListBox then
  begin
    I := lbxSetting.ItemAtPos(Point(X, Y), False);
    if I = lbxSetting.Items.Count then
      Dec(I);

    Index := I;
    ACount := 0;
    IsUp := True;
    
    for K := 0 to lbxSetting.Items.Count - 1 do
    begin
      while lbxSetting.Selected[K] do
      begin
        Inc(ACount);
        lbxSetting.ItemIndex := K;
        if I = lbxSetting.ItemIndex then
          Break
        else if I < lbxSetting.ItemIndex then
        begin
          MoveItemsByDelta(I - lbxSetting.ItemIndex);
          I := I + 1;
        end
        else
        begin
          MoveItemsByDelta(I - lbxSetting.ItemIndex);
          IsUp := False;
        end;
      end;
    end;
    if not IsUp then
    begin
      Index := Index - ACount + 1;
    end;

    if (Index < 0) or (Index >= lbxSetting.Items.Count) then
      Index := 0;

    for I := 0 to ACount - 1 do
    begin
      if Index + I >= lbxSetting.Items.Count then
        break
      else
        lbxSetting.Selected[Index + I] := True;
    end;
    lbxSetting.ItemIndex := Index;
  end;
end;

procedure Tgdc_dlgSettingOrder.lbxSettingDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Sender is TListBox) and (lbxSetting.ItemAtPos(Point(X, Y), False) <> lbxSetting.ItemIndex) then
    Accept := True
  else
    Accept := False;

end;

procedure Tgdc_dlgSettingOrder.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
  ListItem: TListItem;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSETTINGORDER', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSETTINGORDER', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSETTINGORDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSETTINGORDER',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSETTINGORDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  lbxSetting.Items.Clear;
  lvSetting.Items.Clear;
  OrderList.Clear;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Database := gdcObject.Database;
    ibsql.Transaction := gdcObject.ReadTransaction;
    ibsql.SQL.Text :=
      ' SELECT ' +
      '   s.id, s.objectorder, s.mastername, s.objectname, s.category, s.mastercategory ' +
      ' FROM ' +
      '   at_settingpos s ' +
      ' WHERE ' +
      '   s.settingkey = :settingkey ' +
      ' ORDER BY ' +
      '   s.objectorder ';
    ibsql.ParamByName('settingkey').AsInteger := gdcObject.ID;
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      if ibsql.FieldByName('mastername').AsString > '' then
        lbxSetting.Items.Add(ibsql.FieldByName('objectname').AsString + '(' +
          ibsql.FieldByName('category').AsString + ') '  + ibsql.FieldByName('mastercategory').AsString +
          ' ' + ibsql.FieldByName('mastername').AsString)
      else
        lbxSetting.Items.Add(ibsql.FieldByName('objectname').AsString + '(' +
          ibsql.FieldByName('category').AsString + ')');

      ListItem := lvSetting.Items.Add;
      ListItem.Caption := ibsql.FieldByName('objectname').AsString;
      ListItem.SubItems.Add(ibsql.FieldByName('category').AsString);

      //Список содержит сопоставление предыдущего порядка настройки и текущего
      OrderList.Add(ibsql.FieldByName('id').AsString + '=' + ibsql.FieldByName('objectorder').AsString);
      ibsql.Next;
    end;
  finally
    ibsql.Free;
  end;
  lbxSetting.ItemIndex := 0;
  IsModified := False;
  lbxSetting.Selected[0] := True; 

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSETTINGORDER', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSETTINGORDER', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgSettingOrder.MoveItemsByDelta(Delta: Integer);
var
  OldIndex, NewIndex: Integer;
  CorrectDelta: Integer;
begin
  // Если выбран какой-нибудь элемент списка
  if Assigned(lvSetting.Selected) then
  begin
    // Получим правильное смещение элемента учитывая границы списка
    if (lvSetting.Selected.Index + Delta >= 0)
       and (lvSetting.Selected.Index + Delta < lvSetting.Items.Count) then
    begin
      CorrectDelta := Delta;
    end
    else
    begin
      if lvSetting.Selected.Index + Delta < 0 then
        CorrectDelta := 0 - lvSetting.Selected.Index
      else if lvSetting.Selected.Index + Delta >= lvSetting.Items.Count then
        CorrectDelta := lvSetting.Items.Count - lvSetting.Selected.Index - 1
      else
        CorrectDelta := 0;
    end;

    if CorrectDelta <> 0 then
    begin
      OldIndex := lvSetting.Selected.Index;
      // Сформируем индекс в который необходимо переместить элемент
      NewIndex := OldIndex + CorrectDelta;
      // Переместим элемент в визуальном элементе
      MoveListViewItem(OldIndex, NewIndex);
      lvSetting.Selected := lvSetting.Items[NewIndex];
      // Переместим элемент в рабочем списке
      MoveStringListItem(OldIndex, NewIndex);

      IsModified := True;
    end;
  end;
end;

procedure Tgdc_dlgSettingOrder.MoveListViewItem(AIndexFrom, AIndexTo: Word);
var
  Source, Target: TListItem;
begin
  if AIndexTo > AIndexFrom then
    Inc(AIndexTo);

  lvSetting.Items.BeginUpdate;
  try
    Source := lvSetting.Items[AIndexFrom];
    Target := lvSetting.Items.Insert(AIndexTo);
    Target.Assign(Source);
    FreeAndNil(Source);
  finally
    lvSetting.Items.EndUpdate;
  end;
end;

procedure Tgdc_dlgSettingOrder.MoveStringListItem(AIndexFrom, AIndexTo: Word);
var
  NewValue: String;
begin
  OrderList.Move(AIndexFrom, AIndexTo);
  NewValue := OrderList.Values[OrderList.Names[AIndexTo]];
  OrderList.Values[OrderList.Names[AIndexTo]] := OrderList.Values[OrderList.Names[AIndexFrom]];
  OrderList.Values[OrderList.Names[AIndexFrom]] := NewValue;
end;

procedure Tgdc_dlgSettingOrder.lvSettingDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Sender is TListView) and (lvSetting.GetItemAt(X, Y) <> TListView(Sender).Selected) then
    Accept := True
  else
    Accept := False;
end;

procedure Tgdc_dlgSettingOrder.lvSettingMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  UnderCursorItem: TListItem;
begin
  inherited;

  UnderCursorItem := lvSetting.GetItemAt(X, Y);
  if Assigned(UnderCursorItem) then
    lvSetting.Hint := Format('%s (%s)', [UnderCursorItem.Caption, UnderCursorItem.SubItems.Commatext])
  else
    lvSetting.Hint := '';
end;

initialization
  RegisterFrmClass(Tgdc_dlgSettingOrder);

finalization
  UnRegisterFrmClass(Tgdc_dlgSettingOrder);

end.
