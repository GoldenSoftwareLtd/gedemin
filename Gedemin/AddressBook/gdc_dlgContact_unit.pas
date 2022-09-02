// andreik, 15.01.2019

{++
    Форма ввода и редактирования контактов

   История

     ver    date           who   what
     1.00 - 18.06.2000 -   sai - Первая версия

 --}

unit gdc_dlgContact_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, gdc_dlgTRPC_unit, Db, IBCustomDataSet, gdcBase,
  gdcContacts, at_Container, DBCtrls, ExtCtrls, Mask, xDateEdits, StdCtrls,
  gsIBLookupComboBox, ActnList, Menus, IBDatabase;

type
  Tgdc_dlgContact = class(Tgdc_dlgTRPC)
    TabSheet2: TTabSheet;
    Label12: TLabel;
    Label15: TLabel;
    dbHZIP: TDBEdit;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label7: TLabel;
    Label3: TLabel;
    dbeFirstName: TDBEdit;
    dbeMiddleName: TDBEdit;
    dbeSurname: TDBEdit;
    dbeNickName: TDBEdit;
    dbcbName: TDBComboBox;
    dbcbDisabled: TDBCheckBox;
    gsibluFolder: TgsIBLookupComboBox;
    Label36: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    gsIBLookupComboBox2: TgsIBLookupComboBox;
    dbmAddress: TDBMemo;
    Label31: TLabel;
    dbWPhone: TDBEdit;
    Label32: TLabel;
    dbWFax: TDBEdit;
    Label43: TLabel;
    DBEdit7: TDBEdit;
    Label16: TLabel;
    DBEdit5: TDBEdit;
    Label21: TLabel;
    DBEdit6: TDBEdit;
    Label44: TLabel;
    DBEdit8: TDBEdit;
    Label22: TLabel;
    gsIBLookupComboBox1: TgsIBLookupComboBox;
    Label14: TLabel;
    dbmAddressH: TDBMemo;
    Label25: TLabel;
    dbZIP: TDBEdit;
    Label1: TLabel;
    dbeEmail: TDBEdit;
    Label17: TLabel;
    dbHWWW: TDBEdit;
    Label39: TLabel;
    dbmComentary: TDBMemo;
    Label45: TLabel;
    Label29: TLabel;
    dbWDepartment: TDBEdit;
    Label4: TLabel;
    dbePassportNumber: TDBEdit;
    Label5: TLabel;
    Label11: TLabel;
    Label23: TLabel;
    dbePassportIssuer: TDBEdit;
    Label24: TLabel;
    dbePassportIssCity: TDBEdit;
    Label13: TLabel;
    dbePersonalNumber: TDBEdit;
    Label35: TLabel;
    dbCouple: TDBEdit;
    Label2: TLabel;
    dbeChildren: TDBEdit;
    Label38: TLabel;
    xdbeBIRTHDAY: TxDateDBEdit;
    Bevel1: TBevel;
    Label26: TLabel;
    Label18: TLabel;
    dbHPhone: TDBEdit;
    Label63: TLabel;
    gsIBlcWCompanyKey: TgsIBLookupComboBox;
    Label28: TLabel;
    gsiblkupPosition: TgsIBLookupComboBox;
    Label19: TLabel;
    Bevel2: TBevel;
    Label20: TLabel;
    Bevel3: TBevel;
    btnMakeEmployee: TButton;
    actMakeEmployee: TAction;
    DBRadioGroup1: TDBRadioGroup;
    xdbePassportExpDate: TxDateDBEdit;
    xdbePassportIssDate: TxDateDBEdit;
    procedure dbeSurnameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbeSurnameKeyPress(Sender: TObject; var Key: Char);
    procedure dbeSurnameKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tsNameEnter(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actMakeEmployeeExecute(Sender: TObject);
    procedure actMakeEmployeeUpdate(Sender: TObject);

  private
    oldName1, oldName2: String;

  protected
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;  
  end;

var
  gdc_dlgContact: Tgdc_dlgContact;

implementation

uses
  gd_ClassList,
  gdcBaseInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure Tgdc_dlgContact.dbeSurnameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if dbcbName.Items.Count > 1 then
  begin
    OldName1 := dbcbName.Items[0];
    OldName2 := dbcbName.Items[1];
  end;  
end;

procedure Tgdc_dlgContact.dbeSurnameKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = ' ' then
    SelectNext(TWinControl(Sender), True, True);
end;

procedure Tgdc_dlgContact.dbeSurnameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  OldName: string;
begin
  if dbcbName.Items.Count > 1 then
  begin
    OldName := dbcbName.Text;
    dbcbName.Items[0] := Trim(dbeSurname.Text + ' ' +
                         dbeFirstName.Text + ' ' +
                         dbeMiddleName.Text);
    dbcbName.Items[1] := Trim(dbeFirstName.Text + ' ' +
                         dbeMiddleName.Text + ' ' +
                         dbeSurname.Text);

    dbcbName.Text := OldName;
    if (dbcbName.Text = OldName1) then
      dsgdcBase.DataSet.FieldByName('Name').AsString := dbcbName.Items[0]
    else if (dbcbName.Text = OldName2) then
      dsgdcBase.DataSet.FieldByName('Name').AsString := dbcbName.Items[1];
  end;    
end;

procedure Tgdc_dlgContact.tsNameEnter(Sender: TObject);
begin
  inherited;
  dbeSurname.SetFocus;
end;

procedure Tgdc_dlgContact.actNewExecute(Sender: TObject);
begin
  inherited;

  if dbcbName.Items.Count > 1 then
  begin
    dbcbName.Items[0] := '';
    dbcbName.Items[1] := '';
  end;
end;

function Tgdc_dlgContact.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGCONTACT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGCONTACT', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGCONTACT') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGCONTACT',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGCONTACT' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if AnsiCompareText(ARelationName, 'GD_HOLDING') = 0 then
    Result := False
  else if AnsiCompareText(ARelationName, 'GD_CONTACTLIST') = 0 then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGCONTACT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGCONTACT', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgContact.actMakeEmployeeExecute(Sender: TObject);
var
  ID, Dep: TID;
begin
  if MessageBox(Handle,
    'Сделать данное физическое лицо сотрудником организации?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    BeforePost;
    if TestCorrect then
    begin
      ID := TgdcCompany.SelectObject('Организация:',
        'Выбор организации',
        0,
        '',
        GetTID(gdcObject.FieldByName('wcompanykey')));
      if ID <> -1 then
      begin
        Dep := TgdcDepartment.SelectObject('Подразделение:', 'Выбор подразделения',
          0,
          Format('lb > (SELECT c.lb FROM gd_contact c WHERE c.id = %d) ' +
            'AND rb <= (SELECT c2.rb FROM gd_contact c2 WHERE c2.id = %d) ', [TID264(ID), TID264(ID)]));

        if Dep <> -1 then
        begin
          SetTID(gdcObject.FieldByName('parent'), Dep);

          gdcObject.ExecSingleQuery('UPDATE OR INSERT INTO gd_employee (contactkey) ' +
            'VALUES (' + TID2S(gdcObject.ID) + ') MATCHING (contactkey)');

          ModalResult := mrOk;
        end;  
      end;
    end;
  end;
end;

procedure Tgdc_dlgContact.actMakeEmployeeUpdate(Sender: TObject);
begin
  actMakeEmployee.Enabled := Assigned(gdcObject)
    and (gdcObject.State = dsEdit);
end;

initialization
  RegisterFrmClass(Tgdc_dlgContact);

finalization
  UnRegisterFrmClass(Tgdc_dlgContact);
end.


