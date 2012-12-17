unit gd_dlgInitialInfo_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList, IBDatabase, gsIBLookupComboBox, gdcContacts, Db,
  IBCustomDataSet, gdcBase, gdcTree, IBSQL, gdcUser;

type
  Tgd_dlgInitialInfo = class(TForm)
    btnOk: TButton;
    Post: TActionList;
    actOk: TAction;
    Label20: TLabel;
    gbCompany: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    edName: TEdit;
    edPhone: TEdit;
    edTaxID: TEdit;
    cbCountry: TComboBox;
    edZIP: TEdit;
    edArea: TEdit;
    edCity: TEdit;
    edAddress: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    edDirector: TEdit;
    edAccountant: TEdit;
    gbBank: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label21: TLabel;
    iblkupCurr: TgsIBLookupComboBox;
    ibTr: TIBTransaction;
    gbLogin: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    edBankName: TEdit;
    edBankCode: TEdit;
    edAccount: TEdit;
    edBankArea: TEdit;
    edBankCity: TEdit;
    edBankAddress: TEdit;
    cbBankCountry: TComboBox;
    edUser: TEdit;
    edLogin: TEdit;
    edPassword: TEdit;
    edPassword2: TEdit;
    Label24: TLabel;
    edBankZIP: TEdit;
    btnCancel: TButton;
    actCancel: TAction;
    gdcCompany: TgdcCompany;
    gdcEmployee: TgdcEmployee;
    q: TIBSQL;
    Label25: TLabel;
    edDistrict: TEdit;
    gdcFolder: TgdcFolder;
    gdcDepartment: TgdcDepartment;
    gdcUser: TgdcUser;
    gdcBank: TgdcBank;
    Label26: TLabel;
    edBankDistrict: TEdit;
    procedure actOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_dlgInitialInfo: Tgd_dlgInitialInfo;

implementation

{$R *.DFM}

procedure Tgd_dlgInitialInfo.actOkExecute(Sender: TObject);

  procedure SetFieldValue(F: TField; const V: String; const Def: String);
  begin
    if Trim(V) = '' then
      F.AsString := Def
    else
      F.AsString := Copy(V, 1, F.Size);
  end;

var
  DirID, AccountantID, UserID: Integer;
begin
  gdcCompany.Open;

  gdcCompany.Insert;
  gdcCompany.FieldByName('parent').AsInteger := 650001;
  SetFieldValue(gdcCompany.FieldByName('name'), edName.Text, '<Название не указано>');
  gdcCompany.FieldByName('fullname').AsString := gdcCompany.FieldByName('name').AsString;
  SetFieldValue(gdcCompany.FieldByName('phone'), edPhone.Text, '<Номер не указан>');
  SetFieldValue(gdcCompany.FieldByName('taxid'), edTaxID.Text, '<УНП не указан>');
  SetFieldValue(gdcCompany.FieldByName('zip'), edZip.Text, '<Индекс не указан>');
  SetFieldValue(gdcCompany.FieldByName('country'), cbCountry.Text, '<Не указано>');
  SetFieldValue(gdcCompany.FieldByName('district'), edDistrict.Text, '<Не указано>');
  SetFieldValue(gdcCompany.FieldByName('area'), edArea.Text, '<Не указано>');
  SetFieldValue(gdcCompany.FieldByName('city'), edCity.Text, '<Не указано>');
  SetFieldValue(gdcCompany.FieldByName('address'), edAddress.Text, '<Адрес не указан>');
  gdcCompany.Post;

  gdcDepartment.Open;
  gdcDepartment.Insert;
  gdcDepartment.FieldByName('parent').AsInteger := gdcCompany.ID;
  gdcDepartment.FieldByName('name').AsString := 'Офис';
  gdcDepartment.Post;

  gdcEmployee.Open;

  if Trim(edDirector.Text) > '' then
  begin
    gdcEmployee.Insert;
    gdcEmployee.FieldByName('parent').AsInteger := gdcDepartment.ID;
    SetFieldValue(gdcEmployee.FieldByName('name'), edDirector.Text, '');
    SetFieldValue(gdcEmployee.FieldByName('surname'), edDirector.Text, '');
    SetFieldValue(gdcEmployee.FieldByName('nickname'), edDirector.Text, '');
    gdcEmployee.Post;
    DirID := gdcEmployee.ID;
  end else
    DirID := -1;

  if Trim(edAccountant.Text) > '' then
  begin
    gdcEmployee.Insert;
    gdcEmployee.FieldByName('parent').AsInteger := gdcDepartment.ID;
    SetFieldValue(gdcEmployee.FieldByName('name'), edAccountant.Text, '');
    SetFieldValue(gdcEmployee.FieldByName('surname'), edAccountant.Text, '');
    SetFieldValue(gdcEmployee.FieldByName('nickname'), edAccountant.Text, '');
    gdcEmployee.Post;
    AccountantID := gdcEmployee.ID;
  end else
    AccountantID := -1;

  if Trim(edLogin.Text) > '' then
  begin
    if Trim(edUser.Text) > '' then
    begin
      if AnsiCompareText(Trim(edUser.Text), Trim(edDirector.Text)) = 0 then
        UserID := DirID
      else if AnsiCompareText(Trim(edUser.Text), Trim(edAccountant.Text)) = 0 then
        UserID := AccountantID
      else begin
        gdcEmployee.Insert;
        gdcEmployee.FieldByName('parent').AsInteger := gdcDepartment.ID;
        SetFieldValue(gdcEmployee.FieldByName('name'), edUser.Text, '');
        SetFieldValue(gdcEmployee.FieldByName('surname'), edUser.Text, '');
        SetFieldValue(gdcEmployee.FieldByName('nickname'), edUser.Text, '');
        gdcEmployee.Post;
        UserID := gdcEmployee.ID;
      end;
    end else
      UserID := 650002;

    gdcUser.Open;
    gdcUser.Insert;
    SetFieldValue(gdcUser.FieldByName('name'), edLogin.Text, '');
    SetFieldValue(gdcUser.FieldByName('passw'), edPassword.Text, '');
    if UserID > -1 then
      gdcUser.FieldByName('contactkey').AsInteger := UserID;
    gdcUser.Post;
  end;

  

  if ibTr.InTransaction then
    ibTr.Commit;

  ModalResult := mrOk;
end;

procedure Tgd_dlgInitialInfo.FormCreate(Sender: TObject);
begin
  ibtr.StartTransaction;
end;

procedure Tgd_dlgInitialInfo.actCancelExecute(Sender: TObject);
begin
  if ibTr.InTransaction then
    ibTr.Rollback;
  ModalResult := mrCancel;
end;

end.
