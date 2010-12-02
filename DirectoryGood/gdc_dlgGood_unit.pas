{
  Диалоговое окно "Товар"
  gdcGood

  Revisions history

    1.00    01.11.01    sai        Initial version.
}
unit gdc_dlgGood_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, ActnList, gd_security, Db, IBCustomDataSet,
  IBUpdateSQL, IBQuery, IBStoredProc, ComCtrls,
  ExtCtrls, IBDatabase, dmDatabase_unit, gsIBLookupComboBox,
  Grids, DBGrids, gsDBGrid, gsIBGrid, IBSQL, Buttons, 
  at_sql_setup, gsIBCtrlGrid, xDateEdits, gdc_dlgG_unit, gdcBase, gdcGood,
  at_Container, gdc_dlgTRPC_unit, Menus, gdc_dlgTR_unit, gdcBaseInterface;
                                       
type
  Tgdc_dlgGood = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    dbeName: TDBEdit;
    dbmDescription: TDBMemo;
    dbeBarCode: TDBEdit;
    dbeAlias: TDBEdit;
    dblcbTNVD: TgsIBLookupComboBox;
    dbcbSet: TDBCheckBox;
    Label6: TLabel;
    dblcbValue: TgsIBLookupComboBox;
    dbcbDisabled: TDBCheckBox;
    Label8: TLabel;
    dbedShortName: TDBEdit;
    Label9: TLabel;
    gdiblGoodGroup: TgsIBLookupComboBox;
    dbrgDiscipline: TDBRadioGroup;
    Label5: TLabel;
    tshBarCode: TTabSheet;
    Panel2: TPanel;
    btnNewBarCode: TButton;
    btnEditBarCode: TButton;
    btnDelBarCode: TButton;
    gdibgrBarCode: TgsIBGrid;
    gdcGoodBarCode: TgdcGoodBarCode;
    dsBarCode: TDataSource;
    btnBarIndex: TButton;
    actBarIndex: TAction;
    procedure actNewBarCodeExecute(Sender: TObject);
    procedure actEditBarCodeExecute(Sender: TObject);
    procedure actDelBarcodeExecute(Sender: TObject);
    procedure dbcbSetClick(Sender: TObject);
    procedure tshBarCodeEnter(Sender: TObject);
    procedure actBarIndexExecute(Sender: TObject);

  protected
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;

  public
    procedure SetupDialog; override;
    procedure SaveSettings; override;
    procedure LoadSettings; override;

  end;

var
  gdc_dlgGood: Tgdc_dlgGood;

implementation

{$R *.DFM}

uses                  
  Storages, gd_ClassList;

procedure Tgdc_dlgGood.actNewBarCodeExecute(Sender: TObject);
begin
  gdcGoodBarCode.CreateDialog;
end;

procedure Tgdc_dlgGood.actEditBarCodeExecute(Sender: TObject);
begin
  gdcGoodBarCode.EditDialog;
end;

procedure Tgdc_dlgGood.actDelBarcodeExecute(Sender: TObject);
begin
  gdcGoodBarCode.DeleteMultiple(gdibgrBarCode.SelectedRows);
end;

function Tgdc_dlgGood.NeedVisibleTabSheet(const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGGOOD', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGGOOD', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGGOOD') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGGOOD',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGGOOD' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  if AnsiCompareText(ARelationName, 'GD_GOODSET') = 0 then
    Result := dbcbSet.Checked
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGGOOD', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGGOOD', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgGood.dbcbSetClick(Sender: TObject);
begin
  inherited;
  ShowTabSheet;
end;

procedure Tgdc_dlgGood.tshBarCodeEnter(Sender: TObject);
begin
  inherited;
  if not gdcGoodBarCode.Active then
    gdcGoodBarCode.Open;
end;

procedure Tgdc_dlgGood.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGGOOD', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGGOOD', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGGOOD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGGOOD',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGGOOD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if gdcObject.State = dsEdit then
  begin
    Caption := Caption + gdcObject.FieldByName('name').AsString;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGGOOD', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGGOOD', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure TGDC_DLGGOOD.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGGOOD', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGGOOD', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGGOOD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGGOOD',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGGOOD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  UserStorage.LoadComponent(gdibgrBarCode, gdibgrBarCode.LoadFromStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGGOOD', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGGOOD', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure TGDC_DLGGOOD.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGGOOD', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGGOOD', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGGOOD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGGOOD',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGGOOD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if gdibgrBarCode.SettingsModified then
    UserStorage.SaveComponent(gdibgrBarCode, gdibgrBarCode.SaveToStream);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGGOOD', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGGOOD', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgGood.actBarIndexExecute(Sender: TObject);
var
  S: String;
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  if IBLogin.IsIBUserAdmin then
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      q.Transaction := Tr;
      Tr.StartTransaction;

      q.SQL.Text := 'SELECT rdb$index_name FROM rdb$indices ' +
        'WHERE (rdb$index_name = ''GD_X_GOOD_BARCODE'') ' +
        'OR (rdb$index_name = ''GD_X_GOODBARCODE_BARCODE'') ';
      q.ExecQuery;

      if q.EOF then
      begin
        MessageBox(Handle,
          'Индексы отсутствуют. Обновите структуру базы данных.',
          'Внимание',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
        exit;
      end;

      case
        MessageBox(Handle,
          'Активировать индексы по штрих-кодам в справочнике товаров?',
          'Внимание',
          MB_ICONQUESTION or MB_YESNOCANCEL or MB_TASKMODAL) of
        IDYES: S := 'ACTIVE';
        IDNO:  S := 'INACTIVE';
      else
        S := '';
      end;

      if S > '' then
      begin
        q.Close;
        q.SQL.Text := 'ALTER INDEX gd_x_good_barcode ' + S;
        q.ExecQuery;
        q.SQL.Text := 'ALTER INDEX gd_x_goodbarcode_barcode ' + S;
        q.ExecQuery;
        Tr.Commit;
      end;
    finally
      q.Free;
      Tr.Free;
    end;
  end else
  begin
    MessageBox(Handle,
      'Настройка индексов возможна только под учетной записью Администратор.',
      'Внимание',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
  end;
end;

initialization
  RegisterFrmClasses([Tgdc_dlgGood]);

finalization
  UnRegisterFrmClasses([Tgdc_dlgGood]);
end.


