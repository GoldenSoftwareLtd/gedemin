
 {++
   Project GEDEMIN
   Copyright © 2000- 2001 by Golden Software

   Модуль

     gdc_dlgCustomCompany_unit

   Описание

     Окно для работы с компанией

   Автор

     Anton

   История

     ver    date    who    what
     1.00 - 25.06.2001 - anton - Первая версия

 --}


unit gdc_dlgCustomCompany_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, Db, at_Container, ComCtrls, ToolWin, ExtCtrls, gsDBGrid,
  gsDBTreeView, DBCtrls, gsIBLookupComboBox, StdCtrls, Grids, DBGrids,
  Mask, Buttons, ActnList, IBCustomDataSet,
  gdcBase, gdcContacts, gsIBGrid, Menus, 
  IBDatabase, gdcTree, TB2Item, TB2Dock, TB2Toolbar, gdc_dlgTR_unit;

type
  Tgdc_dlgCustomCompany = class(Tgdc_dlgTRPC)
    gdcAccount: TgdcAccount;
    dsAccount: TDataSource;
    actAddAccount: TAction;
    actEditAccount: TAction;
    actDelAccount: TAction;
    actAddSubDepartment: TAction;
    actAccountReduction: TAction;
    Label8: TLabel;
    dbeName: TDBEdit;
    Label4: TLabel;
    dbcbCompanyType: TDBComboBox;
    Label6: TLabel;
    dbeFullName: TDBEdit;
    Label66: TLabel;
    dbePhone: TDBEdit;
    Label67: TLabel;
    dbeFax: TDBEdit;
    Label5: TLabel;
    dbeTaxid: TDBEdit;
    Label63: TLabel;
    gsibluFolder: TgsIBLookupComboBox;
    TabSheet3: TTabSheet;
    Label7: TLabel;
    dbePbox: TDBEdit;
    dbeZIP: TDBEdit;
    Label10: TLabel;
    dbmAddress: TDBMemo;
    Label9: TLabel;
    gsiblkupAddress: TgsIBLookupComboBox;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label13: TLabel;
    actRefreshBank: TAction;
    pnAccount: TPanel;
    Label23: TLabel;
    btnNewBank: TButton;
    btnEditBank: TButton;
    btnDeleteBank: TButton;
    dbgAccount: TgsIBGrid;
    btnRefreshBank: TButton;
    Bevel2: TBevel;
    dbcbDisabled: TDBCheckBox;
    Label31: TLabel;
    Label11: TLabel;
    dbeEmail: TDBEdit;
    Label17: TLabel;
    dbedWWW: TDBEdit;
    Label29: TLabel;
    Bevel1: TBevel;
    gsiblkupMainAccount: TgsIBLookupComboBox;
    Bevel3: TBevel;
    Label19: TLabel;
    dbeSOATO: TDBEdit;
    Label18: TLabel;
    dbeOKNH: TDBEdit;
    Label27: TLabel;
    dbeLICENCE: TDBEdit;
    Label22: TLabel;
    dbeLegalNummer: TDBEdit;
    Label20: TLabel;
    dbeSOOU: TDBEdit;
    Label12: TLabel;
    dbmNote: TDBMemo;
    Label21: TLabel;
    gsIBlcHeadCompany: TgsIBLookupComboBox;
    btnAccRed: TButton;
    btnSaveRec: TButton;
    gsiblkupChiefAccountant: TgsIBLookupComboBox;
    gsiblkupDirector: TgsIBLookupComboBox;
    Label14: TLabel;
    Label15: TLabel;
    Label28: TLabel;
    dbeOKPO: TDBEdit;
    dbeOkulp: TDBEdit;
    Label16: TLabel;
    procedure actAddAccountExecute(Sender: TObject);
    procedure actEditAccountExecute(Sender: TObject);
    procedure actDelAccountExecute(Sender: TObject);
    procedure dbeNameExit(Sender: TObject);
    procedure actAccountReductionExecute(Sender: TObject);
    procedure actRefreshBankExecute(Sender: TObject);
    procedure actRefreshBankUpdate(Sender: TObject);
    procedure gdcAccountBeforeShowDialog(Sender: TObject;
      DlgForm: TCustomForm);
    procedure gsiblkupMainAccountCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);
    procedure actAccountReductionUpdate(Sender: TObject);
    procedure actDelAccountUpdate(Sender: TObject);
    procedure actEditAccountUpdate(Sender: TObject);
    procedure gsiblkupDirectorCreateNewObject(Sender: TObject;
      ANewObject: TgdcBase);

  protected
    //Указывает необходимо ли отображать страницу
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;

    //Указывает нестандартный базовый класс для Choose по имени таблицы
    function GetgdcClass(ARelationName: String): String; override;

    //Указывает сабсет для компонента выбора для Choose по имени таблицы
    function GetChooseSubSet(ARelationName: String): String; override;


  public

    procedure SetupRecord; override;
    procedure SetupDialog; override;

    function TestCorrect: Boolean; override;
    procedure BeforePost; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_dlgCustomCompany: Tgdc_dlgCustomCompany;

implementation

{$R *.DFM}

uses
  Storages,
  gd_keyAssoc,
  gd_ClassList,
  gdcBaseInterface,
  IBSQL
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgdc_dlgCustomCompany.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMCOMPANY', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMCOMPANY', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMCOMPANY',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(dbgAccount, dbgAccount.LoadFromStream);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMCOMPANY', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMCOMPANY', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomCompany.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMCOMPANY', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMCOMPANY', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMCOMPANY',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(UserStorage) then
  begin
    UserStorage.SaveComponent(dbgAccount, dbgAccount.SaveToStream);
  end;  

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMCOMPANY', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMCOMPANY', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomCompany.actAddAccountExecute(Sender: TObject);
begin
  if gdcAccount.CreateDialog
    and (gsiblkupMainAccount.CurrentKey = '') then
  begin
    gsiblkupMainAccount.CurrentKeyInt := gdcAccount.ID;
  end;
end;

procedure Tgdc_dlgCustomCompany.actEditAccountExecute(Sender: TObject);
begin
  if gdcAccount.EditDialog
    and (gdcAccount.ID = gsiblkupMainAccount.CurrentKeyInt) then
  begin
    gsiblkupMainAccount.CurrentKeyInt := gdcAccount.ID;
  end;
end;

procedure Tgdc_dlgCustomCompany.actDelAccountExecute(Sender: TObject);
begin
  if gdcAccount.ID = gdcObject.FieldByName('companyaccountkey').AsInteger then
  begin
    gdcObject.FieldByName('companyaccountkey').Clear;
    gdcAccount.DeleteMultiple(nil);
  end else
    gdcAccount.DeleteMultiple(nil);
end;

procedure Tgdc_dlgCustomCompany.dbeNameExit(Sender: TObject);
begin
  if Trim(gdcObject.FieldByName('fullname').AsString) = '' then
  begin
    gdcObject.FieldByName('fullname').AsString :=
      Trim(gdcObject.FieldByName('name').AsString);
  end;
end;

procedure Tgdc_dlgCustomCompany.actAccountReductionExecute(
  Sender: TObject);
begin
  gdcAccount.Reduction(dbgAccount.SelectedRows);
end;

procedure Tgdc_dlgCustomCompany.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Res: OleVariant;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMCOMPANY', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMCOMPANY', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMCOMPANY',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  gsiblkupDirector.Params.Clear;
  gsiblkupDirector.Params.Add('cc_id=' + IntToStr(gdcObject.ID));
  gsiblkupChiefAccountant.Params.Clear;
  gsiblkupChiefAccountant.Params.Add('cc_id=' + IntToStr(gdcObject.ID));

  inherited;

  if gdcObject.State = dsInsert then
  begin
    gsiblkupMainAccount.gdClassName := '';
    pnAccount.Visible := False;
  end else
  begin
    gdcBaseManager.ExecSingleQueryResult('SELECT id FROM gd_contact WHERE id=' +
      IntToStr(gdcObject.ID), varNull, Res);

    if not VarIsEmpty(Res) then
    begin
      gsiblkupMainAccount.gdClassName := 'TgdcAccount';
      pnAccount.Visible := True;
    end else
    begin
      gsiblkupMainAccount.gdClassName := '';
      pnAccount.Visible := False;
    end;
  end;

  gsiblkupMainAccount.Condition := 'companykey = ' + IntToStr(gdcObject.ID);
  {gdcAccount.Close;
  gdcAccount.Open;}

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMCOMPANY', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMCOMPANY', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomCompany.actRefreshBankExecute(Sender: TObject);
begin
  gdcAccount.Close;
  gdcAccount.Open;
end;

procedure Tgdc_dlgCustomCompany.actRefreshBankUpdate(Sender: TObject);
begin
  actRefreshBank.Enabled := gdcAccount.State = dsBrowse;
end;

procedure Tgdc_dlgCustomCompany.gdcAccountBeforeShowDialog(Sender: TObject;
  DlgForm: TCustomForm);
begin
  inherited;

  if DlgForm.FindComponent('gsibluCompany') is TControl then
    TControl(DlgForm.FindComponent('gsibluCompany')).Visible := False;

  if DlgForm.FindComponent('lblCompany') is TControl then
    TControl(DlgForm.FindComponent('lblCompany')).Visible := False;
end;

function Tgdc_dlgCustomCompany.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGCUSTOMCOMPANY', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGCUSTOMCOMPANY', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMCOMPANY') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMCOMPANY',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMCOMPANY' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if (AnsiCompareText(ARelationName, 'GD_HOLDING') = 0) then
  begin
    if ((gdcObject.ClassType = TgdcCompany) or (gdcObject.ClassType = TgdcOurCompany))
    then
      Result := True
    else
      Result := False
  end
  else if (AnsiCompareText(ARelationName, 'GD_CONTACTLIST') = 0) then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMCOMPANY', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMCOMPANY', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgCustomCompany.TestCorrect: Boolean;
const
  ArrCount = 41;
  Arr: array[1..ArrCount] of String = (
    'ООО',
    'КУП',
    'ЗАО',
    'ТОО',
    'ГП',
    'ОАО',
    'МВП',
    'ПКП',
    'НВП',
    'К-З',
    'ИМ.',
    'ЧП',
    'МП',
    'З-Д',
    'АО',
    'ФИРМА',
    'КОМБИНАТ',
    'АОЗТ',
    'ЗАВОД',
    'ФАБРИКА',
    'ЛЕСПРОМХОЗ',
    'СП',
    'НПП',
    'НВФ',
    'АГЕНТСТВО',
    'ПАЛАТА',
    'ИНСТИТУТ',
    'Ф-КА',
    'УПП',
    'КБ',
    'ЦЕНТР',
    'ПРЕД',
    'АКБ',
    'ОБЪЕДИНЕНИЕ',
    'Г.',
    ' ',
    '"',
    '-',
    ',',
    '.',
    '''');
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  q: TIBSQL;
  S: String;
  I, C: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGCUSTOMCOMPANY', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGCUSTOMCOMPANY', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMCOMPANY') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMCOMPANY',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMCOMPANY' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result
    and (not (sMultiple in gdcObject.BaseState))
    and Assigned(GlobalStorage)
    and GlobalStorage.ReadBoolean('Options', 'Duplicates', True) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;

      if (gdcObject.FieldByName('taxid').AsString > '')
        and (GlobalStorage.ReadBoolean('Options', 'CheckUNN', True)) then
      begin
        q.SQL.Text :=
          'SELECT cc.companykey, c.name FROM gd_companycode cc JOIN gd_contact c ON c.id = cc.companykey ' +
          'WHERE cc.taxid = :TI AND cc.companykey <> :ID';
        q.Prepare;
        q.ParamByName('ID').AsInteger := gdcObject.ID;
        q.ParamByName('TI').AsString := gdcObject.FieldByName('taxid').AsString;
        q.ExecQuery;
        if not q.EOF then
        begin
          if MessageBox(Handle,
            PChar(
            'Организация с таким УНП(ИНН) уже существует в базе данных!'#13#10#13#10 +
            'Наименование: ' + q.FieldByName('name').AsString + #13#10 +
            'Идентификатор: ' + q.FieldByName('companykey').AsString + #13#10#13#10 +
            'Ввод дублирующихся записей не рекомендован.'#13#10 +
            'Отключить данную проверку Вы можете в окне "Опции" пункта "Сервис" главного меню.'#13#10#13#10 +
            'Вернуться к редактированию организации?'#13#10#13#10 +
            'Нажмите "Да" для того, чтобы вернуться в окно редактирования и ввести другой УНП(ИНН).'#13#10 +
            'Нажмите "Нет" для того, чтобы сохранить запись с дублирующимся УНП(ИНН) в базе данных.'),
            'Внимание',
            MB_YESNO or MB_ICONEXCLAMATION) = IDYES then
          begin
            Result := False;
            exit;
          end;
        end;
      end;

      if GlobalStorage.ReadBoolean('Options', 'CheckName', True) then
      begin
        S := _AnsiUpperCase(Trim(gdcObject.FieldByName('name').AsString));

        for I := 1 to ArrCount do
        begin
          S := StringReplace(S, Arr[I], '%', [rfReplaceAll, rfIgnoreCase]);
        end;

        S := '%' + S + '%';

        while Pos('%%', S) > 0 do
        begin
          S := StringReplace(S, '%%', '%', [rfReplaceAll]);
        end;

        if Length(StringReplace(S, '%', '', [rfReplaceAll])) > 4 then
        begin
          q.Close;
          q.SQL.Text :=
            'SELECT c.name FROM gd_contact c JOIN gd_company co ON c.id=co.contactkey WHERE UPPER(c.name) LIKE ''' + S + ''' AND c.id <> :ID' ;
          q.Prepare;
          q.ParamByName('ID').AsInteger := gdcObject.ID;
          q.ExecQuery;
          if not q.EOF then
          begin
            S := '';
            C := 0;
            while (not q.EOF) and (C < 10) do
            begin
              S := S + q.Fields[0].AsString + #13#10;
              Inc(C);
              q.Next;
            end;

            if not q.EOF then
              S := S + 'и другие...' + #13#10;

            if MessageBox(Handle,
              PChar('Организация(и) с похожим наименованием уже есть в базе данных:'#13#10 + S + #13#10 +
              'Ввод дублирующихся записей не рекомендован.'#13#10 +
              'Отключить данную проверку Вы можете в окне "Опции" пункта "Сервис" главного меню.'#13#10#13#10 +
              'Вернуться к редактированию организации?'#13#10#13#10 +
              'Нажмите Да для того, чтобы вернуться в окно редактирования и ввести другое наименование.'#13#10 +
              'Нажмите Нет для того, чтобы сохранить запись с таким наименованием в базе данных.'
              ),
              'Внимание',
              MB_YESNO or MB_ICONEXCLAMATION) = IDYES then
            begin
              Result := False;
              exit;
            end;
          end;
        end;
      end;
    finally
      q.Free;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMCOMPANY', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMCOMPANY', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomCompany.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMCOMPANY', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMCOMPANY', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMCOMPANY',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMCOMPANY', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMCOMPANY', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomCompany.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGCUSTOMCOMPANY', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGCUSTOMCOMPANY', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCUSTOMCOMPANY') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCUSTOMCOMPANY',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCUSTOMCOMPANY' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  gsiblkupMainAccount.Transaction := gdcObject.Transaction;
  gsiblkupDirector.Transaction := gdcObject.Transaction;
  gsiblkupChiefAccountant.Transaction := gdcObject.Transaction;

  {TODO: убрать после проведения модифая на всех базах}
  if Assigned(gdcObject.FindField('OKULP')) then
    dbeOkulp.DataSource := dsgdcBase;

  inherited;

  gdcAccount.MasterSource := dsgdcBase;
  ActivateTransaction(gdcObject.Transaction);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCUSTOMCOMPANY', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCUSTOMCOMPANY', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgCustomCompany.gsiblkupMainAccountCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  ANewObject.FieldByName('companykey').AsInteger := gdcObject.ID;
end;

procedure Tgdc_dlgCustomCompany.actAccountReductionUpdate(Sender: TObject);
begin
  actAccountReduction.Enabled := not gdcAccount.IsEmpty;
end;

procedure Tgdc_dlgCustomCompany.actDelAccountUpdate(Sender: TObject);
begin
  actDelAccount.Enabled := not gdcAccount.IsEmpty;
end;

procedure Tgdc_dlgCustomCompany.actEditAccountUpdate(Sender: TObject);
begin
  actEditAccount.Enabled := not gdcAccount.IsEmpty;
end;

procedure Tgdc_dlgCustomCompany.gsiblkupDirectorCreateNewObject(
  Sender: TObject; ANewObject: TgdcBase);
begin
  if ANewObject.Transaction <> gdcObject.Transaction then
  begin
    ANewObject.Cancel;
    ANewObject.Close;
    ANewObject.ReadTransaction := gdcObject.Transaction;
    ANewObject.Transaction := gdcObject.Transaction;
    ANewObject.Open;
    ANewObject.Insert;
  end;  
  ANewObject.FieldByName('wcompanykey').AsInteger :=
    gdcObject.ID;
  ANewObject.FieldByName('wcompanykey').ReadOnly := True;
end;

function Tgdc_dlgCustomCompany.GetgdcClass(ARelationName: String): String;
begin
  if AnsiCompareText(ARelationName, 'GD_HOLDING') = 0 then
    Result := 'TgdcCompany'
  else
    Result := inherited GetgdcClass(ARelationName);
end;

function Tgdc_dlgCustomCompany.GetChooseSubSet(
  ARelationName: String): String;
begin
  if AnsiCompareText(ARelationName, 'GD_HOLDING') = 0 then
    Result := 'OnlyCompany'
  else
    Result := inherited GetChooseSubSet(ARelationName);

end;

initialization
  RegisterFrmClass(Tgdc_dlgCustomCompany);

finalization
  UnRegisterFrmClass(Tgdc_dlgCustomCompany);

end.
