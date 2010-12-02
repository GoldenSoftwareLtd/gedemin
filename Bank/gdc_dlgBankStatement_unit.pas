
unit gdc_dlgBankStatement_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgHGR_unit, Db, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  gsIBCtrlGrid, ComCtrls, ToolWin, ExtCtrls, StdCtrls, IBSQL, DBCtrls,
  Mask, xDateEdits, gsIBLookupComboBox, gd_security_OperationConst, gdcClasses,
  gdcBase, gd_security, gd_security_body, gsTransaction,
  gsTransactionComboBox, gdcContacts, IBCustomDataSet, IBQuery, gdcStatement,
  FrmPlSvr, TB2Item, TB2Dock, TB2Toolbar, IBDatabase, gdcTree, Menus,
  xCalculatorEdit;

type
  Tgdc_dlgBankStatement = class(Tgdc_dlgHGR)
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    ibcmbAccount: TgsIBLookupComboBox;
    edtDocDate: TxDateDBEdit;
    edtDocNumber: TDBEdit;
    Label4: TLabel;
    IBSQL: TIBSQL;
    Label5: TLabel;
    edCompany: TEdit;
    edCurrency: TEdit;
    Label6: TLabel;
    xdbcRate: TxDBCalculatorEdit;
    cbDontRecalc: TCheckBox;
    procedure ibcmbAccountCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    NotDoFieldChange: Boolean;
    OldBeforePost: TDataSetNotifyEvent;

    procedure SetCurrency;
    procedure gdcBaseLineBeforePost(DataSet: TDataSet);

  public
    constructor Create(AnOwner: TComponent); override;

    procedure SyncField(Field: TField; SyncList: TList); override;
    function CallSyncField(const Field: TField; const SyncList: TList): Boolean; override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

  end;

var
  gdc_dlgBankStatement: Tgdc_dlgBankStatement;

implementation

{$R *.DFM}

uses
  Storages,  gd_ClassList, gdcCurr, Gedemin_TLB, gsStorage_CompPath
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgdc_dlgBankStatement.gdcBaseLineBeforePost(DataSet: TDataSet);
begin
  if Assigned(OldBeforePost) then
    OldBeforePost(DataSet);
  (DataSet as TgdcBaseLine).SetCompanyAccount;
end;

procedure Tgdc_dlgBankStatement.ibcmbAccountCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  inherited;
  aNewObject.FieldByName('companykey').AsInteger := IBLogin.CompanyKey;
end;

procedure Tgdc_dlgBankStatement.SetCurrency;
begin
  ibsql.Close;
  if ibsql.Transaction <> gdcObject.ReadTransaction then
    ibsql.Transaction := gdcObject.ReadTransaction;
  ibsql.SQL.Text := 'SELECT c.name, c.sign FROM gd_companyaccount a ' +
    ' JOIN gd_curr c ON a.currkey = c.id ' +
    ' WHERE a.id = :id ';
  ibsql.ParamByName('id').AsInteger := gdcObject.FieldByName('accountkey').AsInteger;
  ibsql.ExecQuery;
  if ibsql.RecordCount > 0 then
  begin
    edCurrency.Text := ibsql.FieldByName('name').AsString + ', ' +
      ibsql.FieldByName('sign').AsString;
  end else
    edCurrency.Text := 'не указана';

  ibsql.Close;

end;

procedure Tgdc_dlgBankStatement.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBANKSTATEMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBANKSTATEMENT', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKSTATEMENT',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKSTATEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  ActivateTransaction(gdcObject.Transaction);

  FgdcDetailObject := nil;
  for I := 0 to gdcObject.DetailLinksCount - 1 do
    if gdcObject.DetailLinks[I] is TgdcBaseStatementLine then
    begin
      FgdcDEtailObject := gdcObject.DetailLinks[I];
      Break;
    end;

  if not Assigned(FgdcDetailObject) then
  begin
    FgdcDetailObject := TgdcBankStatementLine.CreateSubType(Self, '', 'ByParent');
    FgdcDetailObject.Close;
    FgdcDetailObject.MasterSource := dsgdcBase;
    FgdcDetailObject.MasterField := 'id';
    FgdcDetailObject.DetailField := 'parent';
    FgdcDetailObject.Transaction := gdcObject.Transaction;
    FgdcDetailObject.ReadTransaction := gdcObject.Transaction;
    FgdcDetailObject.ParamByName('parent').AsInteger := gdcObject.ID;
    FgdcDetailObject.Open;
  end;

  dsDetail.DataSet := FgdcDetailObject;

  OldBeforePost := FgdcDetailObject.BeforePost;
  FgdcDetailObject.BeforePost := gdcBaseLineBeforePost;

  ibcmbAccount.Condition := 'CompanyKey = ' + IntToStr(IBLogin.CompanyKey);

  edCompany.Text := IBLogin.CompanyName;

  SetupGrid;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKSTATEMENT', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKSTATEMENT', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgBankStatement.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
var
  ibsql1: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBANKSTATEMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBANKSTATEMENT', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKSTATEMENT',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKSTATEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  ActivateTransaction(gdcObject.Transaction);
  SetCurrency;

  {Обработка курса для валютный счетов}
  ibsql1 := TIBSQL.Create(Self);
  try
    ibsql1.Transaction := gdcObject.ReadTransaction;
    ibsql1.SQL.Text := 'SELECT ca.*, c.isncu FROM gd_companyaccount ca LEFT JOIN gd_curr c ON c.id = ca.currkey ' +
      ' WHERE ca.id = :id ';
    ibsql1.ParamByName('id').AsInteger := gdcObject.FieldByName('accountkey').AsInteger;
    ibsql1.ExecQuery;

    if (ibsql1.FieldByName('currkey').AsInteger = 0) or
      (ibsql1.FieldByName('isncu').AsInteger = 1)
    then
    begin
      xdbcRate.Enabled := False;
    end else
    begin
      xdbcRate.Enabled := True;
      if (ibsql1.FieldByName('currkey').AsInteger > 0) and
         (ibsql1.FieldByName('isncu').AsInteger <> 1) and
         (gdcObject.State = dsInsert) and gdcObject.FieldByName('rate').IsNull
      then
        gdcObject.FieldByName('rate').AsCurrency :=
          gdcCurr.gs_GetCurrRate(gdcObject.FieldByName('documentdate').AsDateTime,
          ibsql1.FieldByName('currkey').AsInteger, gdcObject.ReadTransaction);

    end;
  finally
    ibsql1.Free;
  end;



  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKSTATEMENT', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKSTATEMENT', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgBankStatement.SyncField(Field: TField; SyncList: TList);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

  var
    ARate: Currency; //Курс из справочника валют
    ibsql1: TIBSQL;
    RateWasChanged: Boolean; //Мы изменили курс => пересчитаем позиции
    gdcBSLine: TgdcBase;

begin
  {@UNFOLD MACRO INH_DLGG_SYNCFIELD('TGDC_DLGBANKSTATEMENT', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGBANKSTATEMENT', KEYSYNCFIELD);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSYNCFIELD]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKSTATEMENT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf(
  {M}        [GetGdcInterface(Self), GetGdcInterface(Field) as IgsFieldComponent,
  {M}         GetGdcInterface(SyncList) as IgsList]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKSTATEMENT',
  {M}        'SYNCFIELD', KEYSYNCFIELD, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKSTATEMENT' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;

  {Мы изменили курс и он ненулевой или мы изменили ключ счета
  Плюс к этим условиям проверяется, что ключ счета непустой и введена дата}
  if (((Field.FieldName = 'RATE') and (gdcObject.FieldByName('rate').AsCurrency > 0))
     or (Field.FieldName = 'ACCOUNTKEY'))
     and (gdcObject.FieldByName('accountkey').AsInteger > 0)
     and (not gdcObject.FieldByName('documentdate').IsNull)
     and (Field.DataSet = gdcObject)
  then
  begin
    {Если мы изменили счет, перечитаем валюту}
    if (Field.FieldName = 'ACCOUNTKEY') then SetCurrency;

    RateWasChanged := (Field.FieldName = 'RATE');
    ibsql1 := TIBSQL.Create(Self);
    try
      ibsql1.Transaction := gdcObject.ReadTransaction;
      ibsql1.SQL.Text := 'SELECT ca.*, c.isncu FROM gd_companyaccount ca LEFT JOIN gd_curr c ON c.id = ca.currkey ' +
        ' WHERE ca.id = :id ';
      ibsql1.ParamByName('id').AsInteger := gdcObject.FieldByName('accountkey').AsInteger;
      ibsql1.ExecQuery;

      if (ibsql1.FieldByName('currkey').AsInteger = 0) or
        (ibsql1.FieldByName('isncu').AsInteger = 1)
      then
      begin
        NotDoFieldChange := True;
        try
          gdcObject.FieldByName('rate').Clear;
        finally
          NotDoFieldChange := False;
        end;

        xdbcRate.Enabled := False;
        Exit;
      end;

      xdbcRate.Enabled := True;

      {Курс из справочника}
      ARate := gdcCurr.gs_GetCurrRate(gdcObject.FieldByName('documentdate').AsDateTime,
        ibsql1.FieldByName('currkey').AsInteger, gdcObject.ReadTransaction);

      if gdcObject.FieldByName('rate').IsNull or ((ARate <> gdcObject.FieldByName('rate').AsCurrency)  and
         (MessageBox(0, PChar(Format('Введенный курс %g не соответствует курсу справочника %g.'#13#10 +
          'Изменить курс на курс из справочника?', [gdcObject.FieldByName('rate').AsCurrency,
          ARate])), 'Внимание', MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL or MB_DEFBUTTON2) = IDYES))
      then
      begin
        NotDoFieldChange := True;
        try
          gdcObject.FieldByName('rate').AsCurrency := ARate;
          RateWasChanged := True;
        finally
          NotDoFieldChange := False;
        end;
      end;

    finally
      ibsql1.Free;
    end;

    if RateWasChanged and (gdcObject.FieldByName('rate').AsCurrency > 0) then
    begin
      //Поищем позицию выписки

      gdcBSLine := gdcDetailObject;
      Assert(Assigned(gdcBSLine));
      if Assigned(gdcBSLine) and Assigned(gdcBSLine.Filter) and
        (gdcBSLine.Filter.ConditionCount > 0)
      then
        raise EgdcIBError.Create('Пересчет позиций невозможен: на детальном объекте применен фильтр!');

      if gdcBSLine.State in dsEditModes then gdcBSLine.Post;
      gdcBSLine.First;

      {Пробежимся по позициям и пересчитаем суммы, исходя из валютной}
      while not gdcBSLine.Eof do
      begin
        gdcBSLine.Edit;

        if not gdcBSLine.FieldByName('dsumcurr').IsNull then
          gdcBSLine.FieldByName('dsumncu').AsCurrency :=
            gdcBSLine.FieldByName('dsumcurr').AsCurrency *
            gdcObject.FieldByName('rate').AsCurrency;

        if not gdcBSLine.FieldByName('csumcurr').IsNull then
          gdcBSLine.FieldByName('csumncu').AsCurrency :=
            gdcBSLine.FieldByName('csumcurr').AsCurrency *
            gdcObject.FieldByName('rate').AsCurrency;

        gdcBSLine.Post;
        gdcBSLine.Next;
      end;
    end;
  end

  else if ((Field.FieldName = 'ACCOUNT') or (Field.FieldName = 'BANKCODE')) and
    (Field.DataSet = gdcDetailObject) and
    (gdcDetailObject.FieldByName('account').AsString > '') and
    (gdcDetailObject.FieldByName('bankcode').AsString > '') and
    (gdcDetailObject.FieldByName('companykeyline').IsNull)
  then
  begin
    //Если мы изменили р/с или код банка, и у нас не подставлена компания, то подставим компанию
    ibsql.Close;
    if ibsql.Transaction <> gdcObject.ReadTransaction then
      ibsql.Transaction := gdcObject.ReadTransaction;
    ibsql.SQL.Text := 'SELECT ca.companykey FROM gd_companyaccount ca ' +
      ' JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
      ' WHERE b.bankcode = :bc AND ca.account = :account ';
    ibsql.ParamByName('bc').AsString := gdcDetailObject.FieldByName('bankcode').AsString;
    ibsql.ParamByName('account').AsString := gdcDetailObject.FieldByName('account').AsString;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      gdcDetailObject.FieldByName('companykeyline').AsInteger :=
        ibsql.FieldByName('companykey').AsInteger
    end;
    ibsql.Close;
  end else if  (Field.FieldName = 'COMPANYKEYLINE') and
    (Field.Dataset = gdcDetailObject) and
    (gdcDetailObject.FieldByName('account').AsString = '') and
    (gdcDetailObject.FieldByName('bankcode').AsString = '') and
    (not gdcDetailObject.FieldByName('companykeyline').IsNull)
  then
  begin
    //Если мы подставили компанию, то выберем по умолчанию код банка и счет
    ibsql.Close;
    if ibsql.Transaction <> gdcDetailObject.ReadTransaction then
      ibsql.Transaction := gdcDetailObject.ReadTransaction;
    ibsql.SQL.Text := 'SELECT ca.account, b.bankcode FROM gd_company c ' +
      ' LEFT JOIN gd_companyaccount ca ON c.companyaccountkey = ca.id ' +
      ' LEFT JOIN gd_bank b ON b.bankkey = ca.bankkey ' +
      ' WHERE c.contactkey = :ck ';
    ibsql.ParamByName('ck').AsInteger := gdcDetailObject.FieldByName('companykeyline').AsInteger;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      gdcDetailObject.FieldByName('account').AsString :=
        ibsql.FieldByName('account').AsString;
      gdcDetailObject.FieldByName('bankcode').AsString :=
        ibsql.FieldByName('bankcode').AsString;
    end;
    ibsql.Close;
  end

  else if (Field.DataSet = gdcDetailObject) and
    ((Field.FieldName = 'DSUMNCU') OR (Field.FieldName = 'DSUMCURR') OR
     (Field.FieldName = 'CSUMNCU') OR (Field.FieldName = 'CSUMCURR')) and
    (gdcObject.FieldByName('RATE').AsCurrency > 0) and
    (Field.AsCurrency > 0) and
    (not cbDontRecalc.Checked)
  then begin
  {Пересчет валютных/рублевых сумм}
    if (Field.FieldName = 'DSUMNCU') and
      (SyncList.IndexOf(gdcDetailObject.FieldByName('dsumcurr')) = -1) then
      gdcDetailObject.FieldByName('dsumcurr').AsCurrency :=
        Field.AsCurrency / gdcObject.FieldByName('rate').AsCurrency;

    if (Field.FieldName = 'CSUMNCU') and
       (SyncList.IndexOf(gdcDetailObject.FieldByName('csumcurr')) = -1) then
      gdcDetailObject.FieldByName('csumcurr').AsCurrency :=
        Field.AsCurrency / gdcObject.FieldByName('rate').AsCurrency;

    if (Field.FieldName = 'CSUMCURR') and
      (SyncList.IndexOf(gdcDetailObject.FieldByName('csumncu')) = -1) then
      gdcDetailObject.FieldByName('csumncu').AsCurrency :=
        Field.AsCurrency * gdcObject.FieldByName('rate').AsCurrency;

    if (Field.FieldName = 'DSUMCURR') and
      (SyncList.IndexOf(gdcDetailObject.FieldByName('dsumncu')) = -1) then
      gdcDetailObject.FieldByName('dsumncu').AsCurrency :=
        Field.AsCurrency * gdcObject.FieldByName('rate').AsCurrency;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKSTATEMENT', 'SYNCFIELD', KEYSYNCFIELD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKSTATEMENT', 'SYNCFIELD', KEYSYNCFIELD);
  {M}end;
  {END MACRO}

end;

procedure Tgdc_dlgBankStatement.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//Вернем старый ивент
  FgdcDetailObject.BeforePost := OldBeforePost;
  inherited;
end;

constructor Tgdc_dlgBankStatement.Create(AnOwner: TComponent);
begin
  inherited;
  NotDoFieldChange := False;
end;

procedure Tgdc_dlgBankStatement.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}var
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBANKSTATEMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBANKSTATEMENT', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKSTATEMENT',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKSTATEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    cbDontRecalc.Checked := UserStorage.ReadBoolean(BuildComponentPath(cbDontRecalc),
      'DontRecalc', False);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKSTATEMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKSTATEMENT', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgBankStatement.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBANKSTATEMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBANKSTATEMENT', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBANKSTATEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBANKSTATEMENT',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBANKSTATEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.WriteBoolean(BuildComponentPath(cbDontRecalc),
      'DontRecalc', cbDontRecalc.Checked);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBANKSTATEMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBANKSTATEMENT', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;


function Tgdc_dlgBankStatement.CallSyncField(const Field: TField;
  const SyncList: TList): Boolean;
begin
  Result := inherited CallSyncField(Field, SyncList) or
    ((Field.DataSet = gdcDetailObject) and
      ((Field.FieldName = 'ACCOUNT') or
        (Field.FieldName = 'BANKCODE') or
        (Field.FieldName = 'COMPANYKEYLINE') or
        (Field.FieldName = 'CSUMNCU') or
        (Field.FieldName = 'CSUMCURR') or
        (Field.FieldName = 'DSUMNCU') or
        (Field.FieldName = 'DSUMCURR'))) or
    ((Field.DataSet = gdcObject) and
      ((Field.FieldName = 'ACCOUNTKEY') or
        (Field.FieldName = 'RATE')));
end;

initialization
  RegisterFrmClass(Tgdc_dlgBankStatement);

finalization
  UnRegisterFrmClass(Tgdc_dlgBankStatement);

end.
