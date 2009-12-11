unit gdc_frmTransaction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, IBCustomDataSet, gdcBase, gdcTree,
  gdcAcctTransaction, gdcAcctEntryRegister;

type
  Tgdc_frmTransaction = class(Tgdc_frmMDVTree)
    gdcAcctTransaction: TgdcBaseAcctTransaction;
    gdcAcctViewEntryRegister: TgdcAcctViewEntryRegister;
    cbGroupByDocument: TCheckBox;
    TBControlItem1: TTBControlItem;
    pnlQuantity: TPanel;
    ibgrQuantity: TgsIBGrid;
    gdcAcctQuantity: TgdcAcctQuantity;
    splQuentity: TSplitter;
    cbQuantity: TCheckBox;
    TBControlItem2: TTBControlItem;
    dsQuantity: TDataSource;
    bvlSupport: TBevel;
    actBack: TAction;
    TBItem1: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    actDetailEditLine: TAction;
    nDetailEditLine: TMenuItem;
    tbiDetailEditLine: TTBItem;
    actDoReversalEntry: TAction;
    TBItem2: TTBItem;

    procedure FormCreate(Sender: TObject);
    procedure cbGroupByDocumentClick(Sender: TObject);
    procedure cbQuantityClick(Sender: TObject);
    procedure actBackUpdate(Sender: TObject);
    procedure actBackExecute(Sender: TObject);
    procedure actDetailEditLineExecute(Sender: TObject);
    procedure actDetailEditExecute(Sender: TObject);
    procedure actDetailEditLineUpdate(Sender: TObject);
    procedure actDoReversalEntryExecute(Sender: TObject);
    procedure actDoReversalEntryUpdate(Sender: TObject);

  private
    procedure ShowQuantity;
    procedure EditDocument(ALine: boolean);
  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmTransaction: Tgdc_frmTransaction;

implementation

uses
  gd_ClassList, Storages, gsStorage_CompPath, gdv_frmAcctBaseForm_unit, gdcClasses,
  flt_ScriptInterface, prm_ParamFunctions_unit;

{$R *.DFM}

{ Tgdc_frmTransaction }

class function Tgdc_frmTransaction.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmTransaction) then
    gdc_frmTransaction := Tgdc_frmTransaction.Create(AnOwner);
  Result := gdc_frmTransaction;

end;

procedure Tgdc_frmTransaction.FormCreate(Sender: TObject);
begin
  gdcAcctViewEntryRegister.MasterSource := nil;
  
  inherited;

  gdcObject := gdcAcctTransaction;
  gdcAcctViewEntryRegister.MasterSource := dsMain;
  gdcDetailObject := gdcAcctViewEntryRegister;
  gdcAcctQuantity.Open;

  ibgrDetail.GroupFieldName := 'RECORDKEY';

  ShowQuantity;
end;

procedure Tgdc_frmTransaction.cbGroupByDocumentClick(Sender: TObject);
begin
  if cbGroupByDocument.Checked then
  begin
    gdcAcctViewEntryRegister.EntryGroup := egDocument;
    ibgrDetail.GroupFieldName := 'MASTERDOCKEY';
  end
  else
  begin
    gdcAcctViewEntryRegister.EntryGroup := egAll;
    ibgrDetail.GroupFieldName := 'RECORDKEY';
  end;
end;

procedure Tgdc_frmTransaction.cbQuantityClick(Sender: TObject);
begin
  inherited;
  ShowQuantity;
end;

procedure Tgdc_frmTransaction.ShowQuantity;
begin
  if cbQuantity.Checked then
  begin
    pnlQuantity.Visible := True
  end else
    pnlQuantity.Visible := False;
end;

procedure Tgdc_frmTransaction.LoadSettings;
var
  S: String;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMTRANSACTION', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMTRANSACTION', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMTRANSACTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMTRANSACTION',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMTRANSACTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    S := BuildComponentPath(Self);
    cbQuantity.Checked := UserStorage.ReadBoolean(S, 'ShowQuentity');
    LoadGrid(ibgrQuantity);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMTRANSACTION', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMTRANSACTION', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmTransaction.SaveSettings;
var
  S: String;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMTRANSACTION', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMTRANSACTION', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMTRANSACTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMTRANSACTION',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMTRANSACTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    S := BuildComponentPath(Self);
    UserStorage.WriteBoolean(S, 'ShowQuentity', cbQuantity.Checked);
    SaveGrid(ibgrQuantity);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMTRANSACTION', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMTRANSACTION', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmTransaction.actBackUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := AcctFormList.Count > 0;

end;

procedure Tgdc_frmTransaction.actBackExecute(Sender: TObject);
begin
  TWinControl(AcctFormList.Items[AcctFormList.Count - 1]).BringToFront;

  AcctFormList.Delete(AcctFormList.Count - 1);
end;

procedure Tgdc_frmTransaction.EditDocument(ALine: boolean);
var
  tmpDocument: TgdcDocument;
begin
  tmpDocument := TgdcDocument.Create(Self);
  try
    tmpDocument.SubSet := 'ByID';
    if ALine then
      tmpDocument.ParamByName('id').AsInteger := gdcAcctViewEntryRegister.FieldByName('documentkey').AsInteger
    else
      tmpDocument.ParamByName('id').AsInteger := gdcAcctViewEntryRegister.FieldByName('masterdockey').AsInteger;
    tmpDocument.Open;

    if tmpDocument.RecordCount > 0 then
      tmpDocument.EditDialog;
  finally
    tmpDocument.Free;
  end;
end;

procedure Tgdc_frmTransaction.actDetailEditLineExecute(Sender: TObject);
begin
  if gdcAcctViewEntryRegister.FieldByName('documenttypekey').AsInteger <> DefaultDocumentTypeKey then
    EditDocument(True);
end;

procedure Tgdc_frmTransaction.actDetailEditExecute(Sender: TObject);
begin
  if gdcAcctViewEntryRegister.FieldByName('documenttypekey').AsInteger <> DefaultDocumentTypeKey then
    EditDocument(False)
  else
    inherited;
end;

procedure Tgdc_frmTransaction.actDetailEditLineUpdate(Sender: TObject);
begin
  actDetailEditLine.Enabled :=
     (gdcAcctViewEntryRegister.FieldByName('documenttypekey').AsInteger <> DefaultDocumentTypeKey) and
      (gdcAcctViewEntryRegister.FieldByName('id').AsInteger > 0)
end;

procedure Tgdc_frmTransaction.actDoReversalEntryExecute(Sender: TObject);
var
  ParamList: TgsParamList;
  ParamResult: OleVariant;
  DialogResult: Boolean;
begin
  if Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
  begin
    ParamList := TgsParamList.Create;
    try
      // Заполнение и инициализация списка параметров
      ParamList.AddParam('STDATE', 'Дата сторно-проводки', prmDate, '');
      ParamList.Params[0].Required := True;
      ParamList.Params[0].ResultValue := Date;
      ParamList.AddLinkParam('TRANSACTION', 'Привязать к Типовой операции', prmLinkElement, 'AC_TRANSACTION', 'NAME', 'ID', '', '', '');
      ParamList.Params[1].Required := True;
      ParamList.Params[1].ResultValue :=
        VarArrayOf([gdcAcctViewEntryRegister.FieldByName('TRANSACTIONKEY').AsInteger]);

      ParamGlobalDlg.QueryParams(GD_PRM_SCRIPT_DLG, Self.Handle, ParamList, DialogResult);
      if DialogResult then
      begin
        try
          ParamResult := ParamList.GetVariantArray;
          if (ParamResult[0] > 0) and (ParamResult[1][0] > 0) then
          begin
            // Если параметры введены - сторнируем выбранную проводку
            gdcAcctViewEntryRegister.CreateReversalEntry(ParamResult[0], ParamResult[1][0]);
            gdcAcctViewEntryRegister.CloseOpen;
            Application.MessageBox('Проводка сторнирована', PChar(Self.Caption),
              MB_OK + MB_ICONINFORMATION + MB_SYSTEMMODAL);
          end;
        except
          on E: Exception do
            Application.MessageBox(PChar('Произошла ошибка при сторнировании проводки:'#13#10 + E.Message),
              PChar(Self.Caption), MB_OK + MB_ICONERROR + MB_SYSTEMMODAL);
        end;
      end;
    finally
      ParamList.Free;
    end;
  end
  else
    raise Exception.Create('Класс ParamGlobalDlg не создан');
end;

procedure Tgdc_frmTransaction.actDoReversalEntryUpdate(Sender: TObject);
begin
  actDoReversalEntry.Enabled := (gdcAcctViewEntryRegister.FieldByName('id').AsInteger > 0);
end;

initialization
  RegisterFrmClass(Tgdc_frmTransaction);



finalization
  UnRegisterFrmClass(Tgdc_frmTransaction);

end.
