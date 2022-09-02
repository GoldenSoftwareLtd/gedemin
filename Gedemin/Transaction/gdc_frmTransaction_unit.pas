// ShlTanya, 09.03.2019

unit gdc_frmTransaction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDVTree_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, IBCustomDataSet, gdcBase, gdcTree,
  gdcAcctTransaction, gdcAcctEntryRegister, gdcBaseInterface;

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
    tbiShowAllEntries: TTBItem;
    actShowAllEntries: TAction;
    actDetailListDocument: TAction;
    tbiDetailListDocument: TTBItem;

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
    procedure actShowAllEntriesExecute(Sender: TObject);
    procedure actShowAllEntriesUpdate(Sender: TObject);
    procedure actDetailListDocumentExecute(Sender: TObject);
    procedure actDetailListDocumentUpdate(Sender: TObject);
    procedure actDetailDuplicateExecute(Sender: TObject);

  private
    procedure ShowQuantity;
    procedure EditDocument(ALine: boolean);

  protected
    procedure DoOnFilterChanged(Sender: TObject); override;

  public
    destructor Destroy; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    class function CreateAndAssignWithID(AnOwner: TComponent; AnID: TID; AnEntrySelect: TEntrySelect): TForm;

    class procedure GoToEntries(AForm: TCustomForm; AnObj: TgdcBase);
  end;

var
  gdc_frmTransaction: Tgdc_frmTransaction;

implementation

uses
  gd_ClassList, Storages, gsStorage_CompPath, gdv_frmAcctBaseForm_unit, gdcClasses,
  flt_ScriptInterface, prm_ParamFunctions_unit, gd_resourcestring, gdcClasses_interface,
  gdc_createable_form;

const
  DefaultColor = clBtnFace;
  ColorIDOnly = TColor($00C1B6FF);

{$R *.DFM}

{ Tgdc_frmTransaction }

class function Tgdc_frmTransaction.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmTransaction) then
    gdc_frmTransaction := Tgdc_frmTransaction.Create(AnOwner);

  Result := gdc_frmTransaction;
end;

class function Tgdc_frmTransaction.CreateAndAssignWithID(AnOwner: TComponent; AnID: TID; AnEntrySelect: TEntrySelect): TForm;
begin
  CreateAndAssign(AnOwner);
  if AnEntrySelect <> esAll then
  begin
    gdc_frmTransaction.tvGroup.Color := ColorIDOnly;
    gdc_frmTransaction.tbDetailToolbar.Color := ColorIDOnly;
    gdc_frmTransaction.tbDetailCustom.Color := ColorIDOnly;
    gdc_frmTransaction.tbMainInvariant.Color := ColorIDOnly;
    gdc_frmTransaction.tbMainToolbar.Color := ColorIDOnly;
    gdc_frmTransaction.tbMainMenu.Color := ColorIDOnly;
    gdc_frmTransaction.tbChooseMain.Color := ColorIDOnly;

    gdc_frmTransaction.tvGroup.Refresh;
    gdc_frmTransaction.gdcAcctViewEntryRegister.EntrySelect := AnEntrySelect;

    gdc_frmTransaction.gdcAcctViewEntryRegister.Close;
    if AnEntrySelect = esDocumentKey then
      SetTID(gdc_frmTransaction.gdcAcctViewEntryRegister.ParamByName('dk'), AnID)
    else
      SetTID(gdc_frmTransaction.gdcAcctViewEntryRegister.ParamByName('rk'), AnID);
    gdc_frmTransaction.gdcAcctViewEntryRegister.Open;
  end;
  gdc_frmTransaction.ActiveControl := gdc_frmTransaction.ibgrDetail;
  
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
      SetTID(tmpDocument.ParamByName('id'), gdcAcctViewEntryRegister.FieldByName('documentkey'))
    else
      SetTID(tmpDocument.ParamByName('id'), gdcAcctViewEntryRegister.FieldByName('masterdockey'));
    tmpDocument.Open;

    if tmpDocument.RecordCount > 0 then
      tmpDocument.EditDialog;
  finally
    tmpDocument.Free;
  end;
end;

procedure Tgdc_frmTransaction.DoOnFilterChanged(Sender: TObject);
begin
  inherited;

  if gdcDetailObject <> nil then
  begin
    cbGroupByDocument.Enabled := (not gdcDetailObject.QueryFiltered)
      or (gdcDetailObject.Filter.OrderByCount = 0);
  end;
end;

procedure Tgdc_frmTransaction.actDetailEditLineExecute(Sender: TObject);
begin
  if GetTID(gdcAcctViewEntryRegister.FieldByName('documenttypekey')) <> DefaultDocumentTypeKey then
    EditDocument(True);
end;

procedure Tgdc_frmTransaction.actDetailEditExecute(Sender: TObject);
begin
  if (ibgrDetail.SelectedRows.Count > 1)
    and (MessageBox(Handle,
      PChar(
        'Множественное редактирование записей не поддерживается. '#13#10 +
        'Будет изменена последняя выделенная запись. Продолжить?'),
      'Внимание!',
      MB_YESNO or MB_ICONWARNING or MB_TASKMODAL) = IDNO) then
    exit;

  if GetTID(gdcAcctViewEntryRegister.FieldByName('documenttypekey')) <> DefaultDocumentTypeKey then
    EditDocument(False)
  else
    inherited;
end;

procedure Tgdc_frmTransaction.actDetailEditLineUpdate(Sender: TObject);
begin
  actDetailEditLine.Enabled :=
      (GetTID(gdcAcctViewEntryRegister.FieldByName('documenttypekey')) <> DefaultDocumentTypeKey) and
      (GetTID(gdcAcctViewEntryRegister.FieldByName('id')) > 0) and
      (not cbGroupByDocument.Checked);
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

      ParamList.AddLinkParam('TRANSACTION', 'Привязать к Типовой операции', prmLinkElement,
        'AC_TRANSACTION', 'NAME', 'ID', '', '', '');
      ParamList.Params[1].Required := True;
      ParamList.Params[1].ResultValue :=
        VarArrayOf([TID2V(gdcAcctViewEntryRegister.FieldByName('TRANSACTIONKEY'))]);
      ParamList.Params[1].SortField := 'NAME';
      ParamList.Params[1].SortOrder:=1;

      ParamList.AddParam('ALL_DOC_ENTRY', 'Все проводки по документу', prmBoolean,
        'Сторнировать все проводки по документу текущей проводки');
      ParamList.Params[2].Required := False;
      ParamList.Params[2].ResultValue := False;

      ParamGlobalDlg.QueryParams(GD_PRM_SCRIPT_DLG, Self.Handle, ParamList, DialogResult);
      if DialogResult then
      begin
        try
          ParamResult := ParamList.GetVariantArray;
          if (ParamResult[0] > 0) and (ParamResult[1][0] > 0) then
          begin
            // Если параметры введены - сторнируем выбранную проводку
            gdcAcctViewEntryRegister.CreateReversalEntry(ParamResult[0], GetTID(ParamResult[1][0]), ParamResult[2]);
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
  actDoReversalEntry.Enabled := (GetTID(gdcAcctViewEntryRegister.FieldByName('id')) > 0);
end;

procedure Tgdc_frmTransaction.actShowAllEntriesExecute(Sender: TObject);
var
  Temp: TID;
begin
  LockWindowUpdate(Handle);
  try
    tvGroup.Color := clWindow;
    tbDetailToolbar.Color := DefaultColor;
    tbDetailCustom.Color := DefaultColor;
    tbMainInvariant.Color := DefaultColor;
    tbMainToolbar.Color := DefaultColor;
    tbMainMenu.Color := DefaultColor;
    tbChooseMain.Color := DefaultColor;
    Temp := gdcAcctViewEntryRegister.RecordKey;
    gdcAcctViewEntryRegister.EntrySelect := esAll;
    Invalidate;
    gdcAcctViewEntryRegister.Locate('RECORDKEY', TID2V(Temp), []);
  finally
    LockWindowUpdate(0);
  end;
end;

procedure Tgdc_frmTransaction.actShowAllEntriesUpdate(Sender: TObject);
begin
  actShowAllEntries.Enabled := gdcAcctViewEntryRegister.EntrySelect <> esAll;
end;

destructor Tgdc_frmTransaction.Destroy;
begin
  if gdc_frmTransaction = Self then
    gdc_frmTransaction := nil;
  inherited;
end;

class procedure Tgdc_frmTransaction.GoToEntries(AForm: TCustomForm; AnObj: TgdcBase);
var
  Old_Global_DisableQueryFilter: Boolean;
begin
  Assert(AnObj <> nil);
  Assert(AForm <> nil);

  if GetTID(AnObj.FieldByName('transactionkey')) > 0 then
  begin
    Old_Global_DisableQueryFilter := Global_DisableQueryFilter;
    Global_DisableQueryFilter := True;
    try
      with Tgdc_frmTransaction.CreateAndAssignWithID(Application, AnObj.ID, esDocumentKey) as Tgdc_frmTransaction do
      begin
        cbGroupByDocument.Checked := False;
        if tvGroup.GoToID(GetTID(AnObj.FieldByName('transactionkey'))) and
          gdcAcctViewEntryRegister.Active and
          gdcAcctViewEntryRegister.Locate('DOCUMENTKEY', TID2V(AnObj.ID), []) then
        begin
          Show;
        end else
          MessageBox(AForm.Handle, PChar(sEntryNotFound), PChar(sAttention),
            MB_OK or MB_ICONWARNING or MB_TASKMODAL);
      end;
    finally
      Global_DisableQueryFilter := Old_Global_DisableQueryFilter;
    end;
  end else
    MessageBox(AForm.Handle, 'По данной позиции не установлена операция.', PChar(sAttention),
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

procedure Tgdc_frmTransaction.actDetailListDocumentExecute(
  Sender: TObject);
var
  Cl: TPersistentClass;
  F: TgdcFullClass;
  FormList: TgdcCreateableForm;
begin
  if GetTID(gdcAcctViewEntryRegister.FieldByName('documenttypekey')) <> DefaultDocumentTypeKey then
  begin
    F := TgdcDocument.GetDocumentClass(GetTID(gdcAcctViewEntryRegister.FieldByName('documenttypekey')), dcpHeader);
    Cl := Classes.GetClass(F.gdClass.ClassName);
    FormList := CgdcBase(Cl).CreateViewForm(Application, '', F.SubType, False) as TgdcCreateableForm;
    if Assigned(FormList) and Assigned(FormList.gdcObject) and Assigned(FormList.gdcObject.FindField('ID')) then
    begin
      if Assigned(FormList.gdcObject.Filter) and (GetTID(FormList.gdcObject.Filter.CurrentFilter) > 0)
        and (FormList.gdcObject.Filter.FilterData.FilterText <> '') then
        MessageBox(Handle, 'Внимание! На форме включена фильтрация данных.', PChar(sAttention), mb_OK or MB_ICONWARNING or MB_TASKMODAL);
      FormList.gdcObject.Locate('ID', TID2V(gdcAcctViewEntryRegister.FieldByName('masterdockey')),[]);
     end;
    if FormList <> nil then
      FormList.Show;
  end;

end;

procedure Tgdc_frmTransaction.actDetailListDocumentUpdate(Sender: TObject);
begin
  actDetailListDocument.Enabled :=
      (GetTID(gdcAcctViewEntryRegister.FieldByName('documenttypekey')) <> DefaultDocumentTypeKey) and
      (GetTID(gdcAcctViewEntryRegister.FieldByName('id')) > 0);
     // and (not cbGroupByDocument.Checked);
end;

procedure Tgdc_frmTransaction.actDetailDuplicateExecute(Sender: TObject);
begin
  if (ibgrDetail.SelectedRows.Count > 1) then
  begin
    MessageBox(Handle,
      PChar('Множественное дублирование записей не поддерживается.'),
      'Внимание!',
      MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    exit;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmTransaction);

finalization
  UnRegisterFrmClass(Tgdc_frmTransaction);
end.
