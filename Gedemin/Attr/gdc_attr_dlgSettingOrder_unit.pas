// ShlTanya, 03.02.2019

unit gdc_attr_dlgSettingOrder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, gdc_dlgG_unit, ComCtrls, Menus, Db, ActnList, gdcBase,
  gdcSetting;

type
  Egdc_dlgSettingOrder = class(Exception);

  Tgdc_dlgSettingOrder = class(Tgdc_dlgG)
    bbtnUp: TBitBtn;
    bbtnDown: TBitBtn;
    lbxSetting: TListBox;
    actUp: TAction;
    actDown: TAction;
    procedure actUpExecute(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
    procedure lbxSettingMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure actOkExecute(Sender: TObject);
    procedure lbxSettingDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbxSettingDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);

  private
    IsModified: Boolean;

    //перемещает выделенные элементы на заданное (дельта) число позиций
    //если дельта < 0 , то вверх, если дельта > 0 то вниз
    procedure MoveItemsByDelta(Delta: Integer);

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
  IBSQL, IBDatabase, gd_classlist, gdcBaseInterface;

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
  lbxSetting.Selected[lbxSetting.ItemIndex] := True;
end;

procedure Tgdc_dlgSettingOrder.actDownExecute(Sender: TObject);
begin
  Self.MoveItemsByDelta(1);
  lbxSetting.Selected[lbxSetting.ItemIndex] := True;
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
  OrderList.Clear;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Database := gdcObject.Database;
    ibsql.Transaction := gdcObject.ReadTransaction;
    ibsql.SQL.Text := 'SELECT * FROM at_settingpos WHERE settingkey = :settingkey ' +
      ' ORDER BY objectorder ';
    SetTID(ibsql.ParamByName('settingkey'), gdcObject.ID);
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
  Index: Integer;
  NewValue: String;
  CorrectDelta: Integer;
begin
  if (lbxSetting.ItemIndex + Delta >= 0) and
    (lbxSetting.ItemIndex + Delta < lbxSetting.Items.Count) then
  begin
    CorrectDelta := Delta;
  end else
  begin
    if lbxSetting.ItemIndex + Delta < 0 then
      CorrectDelta := lbxSetting.ItemIndex
    else if lbxSetting.ItemIndex + Delta >= lbxSetting.Items.Count then
      CorrectDelta := lbxSetting.Items.Count - lbxSetting.ItemIndex - 1
    else
      CorrectDelta := 0;
  end;

  if CorrectDelta <> 0 then
  begin
    Index := lbxSetting.ItemIndex + CorrectDelta;
    lbxSetting.Items.Move(lbxSetting.ItemIndex, Index);
    OrderList.Move(Index - CorrectDelta, Index);
    lbxSetting.ItemIndex := Index;
    NewValue := OrderList.Values[OrderList.Names[Index]];
    OrderList.Values[OrderList.Names[Index]] :=
      OrderList.Values[OrderList.Names[Index - CorrectDelta]];
    OrderList.Values[OrderList.Names[Index - CorrectDelta]] := NewValue;
    IsModified := True;
  end;

  if lbxSetting.ItemIndex = -1 then
    lbxSetting.ItemIndex := 0;
end;

initialization
  RegisterFrmClass(Tgdc_dlgSettingOrder);

finalization
  UnRegisterFrmClass(Tgdc_dlgSettingOrder);

end.
