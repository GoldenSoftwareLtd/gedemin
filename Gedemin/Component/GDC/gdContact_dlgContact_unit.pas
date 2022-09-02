// ShlTanya, 10.02.2019

unit gdContact_dlgContact_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, Db, IBCustomDataSet, IBQuery, ExtCtrls, Buttons,
  IBDatabase, IBUpdateSQL, DBCtrls, Mask, ShellApi,
  ActnList, ExtDlgs, Menus, Grids, Scanner, IBSQL, DBClient,
  DBGrids, xLabel;

type
  TgdContact_dlgContact = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    pcContact: TPageControl;
    tsName: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label7: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    btnGoHome: TButton;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    dbeFirstName: TDBEdit;
    dbeMiddleName: TDBEdit;
    dbeSurname: TDBEdit;
    dbeNickName: TDBEdit;
    dbmHAddress: TDBMemo;
    dbHZIP: TDBEdit;
    dbHWWW: TDBEdit;
    dbHPhone: TDBEdit;
    dbHFax: TDBEdit;
    DBEdit13: TDBEdit;
    dbCompanyname: TDBEdit;
    dbmWAddress: TDBMemo;
    dbWZIP: TDBEdit;
    Label27: TLabel;
    dbWWW: TDBEdit;
    btnGoWork: TButton;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    dbRank: TDBEdit;
    dbWDepartment: TDBEdit;
    dbWOffice: TDBEdit;
    dbWPhone: TDBEdit;
    dbWFax: TDBEdit;
    dbWPager: TDBEdit;
    dbIPPhone: TDBEdit;
    Label35: TLabel;
    Label36: TLabel;
    dbCouple: TDBEdit;
    tsGeneral: TTabSheet;
    Scanner: TScanner;
    ActionList: TActionList;
    opdContact: TOpenPictureDialog;
    dsContact: TDataSource;
    Label63: TLabel;
    dbcbHCity: TDBComboBox;
    SpeedButton2: TSpeedButton;
    dbcbHRegion: TDBComboBox;
    SpeedButton1: TSpeedButton;
    dbcbHCountry: TDBComboBox;
    SpeedButton3: TSpeedButton;
    dbcbWCity: TDBComboBox;
    SpeedButton4: TSpeedButton;
    dbcbWRegion: TDBComboBox;
    SpeedButton5: TSpeedButton;
    dbcbWCountry: TDBComboBox;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    dsEmail: TDataSource;
    dbgrEmail: TDBGrid;
    dsChildren: TDataSource;
    DBGrid1: TDBGrid;
    gddbsdsEmail: TgdDBStringDataSet;
    TabSheet8: TTabSheet;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Label70: TLabel;
    pcPhoto: TPageControl;
    tsVis1: TTabSheet;
    tsVis2: TTabSheet;
    tsPhoto: TTabSheet;
    dbiVis1: TDBImage;
    dbiVis2: TDBImage;
    dbiPhoto: TDBImage;
    gddbsdsChildren: TgdDBStringDataSet;
    dbeName: TDBEdit;
    Label37: TLabel;
    cbSex: TComboBox;
    Label38: TLabel;
    Label39: TLabel;
    dbmComentary: TDBMemo;
    xLabel1: TxLabel;
    xLabel2: TxLabel;
    xLabel3: TxLabel;
    xLabel4: TxLabel;
    xLabel5: TxLabel;
    xLabel6: TxLabel;
    mInfoFields: TMemo;
    dbcbDisabled: TDBCheckBox;
    Button1: TButton;
    Button2: TButton;
    mInfoValues: TMemo;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure dbeNameExit(Sender: TObject);
    procedure dbeNameChange(Sender: TObject);
    procedure dbeSurnameChange(Sender: TObject);

  private
    // if true -- contact name will be concatenened from
    // first and last names, as they will be entered
    FFormContactName: Boolean;

    procedure MakeCaption;
    procedure MakeInfo;

  public
    procedure SetupDialog;
  end;

var
  gdContact_dlgContact: TgdContact_dlgContact;

implementation

{$R *.DFM}

procedure TgdContact_dlgContact.btnOKClick(Sender: TObject);
begin
  if gddbsdsEmail.State in [dsEdit, dsInsert] then
    gddbsdsEmail.Post;

  if gddbsdsChildren.State in [dsEdit, dsInsert] then
    gddbsdsChildren.Post;

  (*
  if gdContact.State in [dsEdit, dsInsert] then
    gdContact.Post;
  *)

  ModalResult := mrOk;
end;

procedure TgdContact_dlgContact.btnCancelClick(Sender: TObject);
begin
  (*
  if gdContact.State in [dsInsert, dsEdit] then
    gdContact.Cancel;
  *)

  ModalResult := mrCancel;
end;

procedure TgdContact_dlgContact.SetupDialog;
begin
//  FFormContactName := gdContact.FieldByName('name').AsString = '';
  MakeCaption;
  MakeInfo;
end;

procedure TgdContact_dlgContact.Button6Click(Sender: TObject);
begin
  (*
  if not (gdContact.State in [dsInsert, dsEdit]) then
    gdContact.Edit;
  *)

  if tsVis1.Visible then
    dbiVis1.Field.Clear
  else if tsVis2.Visible then
    dbiVis2.Field.Clear
  else if tsPhoto.Visible then
    dbiPhoto.Field.Clear;
end;

procedure TgdContact_dlgContact.Button5Click(Sender: TObject);
begin
  (*
  if not (gdContact.State in [dsInsert, dsEdit]) then
    gdContact.Edit;
  *)

  if opdContact.Execute then
    if tsVis1.Visible then
      (dbiVis1.Field as TBlobField).LoadFromFile(opdContact.FileName)
    else if tsVis2.Visible then
      (dbiVis2.Field as TBlobField).LoadFromFile(opdContact.FileName)
    else if tsPhoto.Visible then
      (dbiPhoto.Field as TBlobField).LoadFromFile(opdContact.FileName);
end;

procedure TgdContact_dlgContact.dbeNameExit(Sender: TObject);
begin
  FFormContactName := dbeName.Text = '';
end;

procedure TgdContact_dlgContact.dbeNameChange(Sender: TObject);
begin
  MakeCaption;
end;

procedure TgdContact_dlgContact.dbeSurnameChange(Sender: TObject);
begin
  if FFormContactName then
    dbeName.Text :=
      dbeSurName.Text + ' ' +
      dbeFirstName.Text + ' ' +
      dbeMiddleName.Text;
end;

procedure TgdContact_dlgContact.MakeCaption;
begin
  Caption := 'Контакт: ' + dbeName.Text;
end;

procedure TgdContact_dlgContact.MakeInfo;
const
  InfoFields: array[1..40] of String = (
    'ID',
    'NAME',

    'ZIP',
    'COUNTRY',
    'REGION',
    'DISTRICT',
    'CITY',
    'ADDRESS',

    'EMAIL',
    'URL',
    'POBOX',
    'PHONE',
    'FAX',
    'parentname',

    'SURNAME',
    'FIRSTNAME',
    'MIDDLENAME',
    'NICKNAME',

    'HZIP',
    'HCOUNTRY',
    'HCITY',
    'HDISTRICT',
    'HREGION',
    'HADDRESS',
    'HPHONE',
    'HFAX',
    'HURL',

    'DEFAULTPHONE',

    'WCOMPANYNAME',
    'WDEPARTMENT',
    'WOFFICE',
    'WTITLE',
    'RANK',
    'WPAGER',
    'WHANDY',
    'IPPHONE',

    'SEX',
    'BIRTHDAY',
    'SPOUSE',
    'CHILDREN'
  );
var
  I: Integer;
begin
  mInfoFields.Clear;
  mInfoValues.Clear;
  for I := Low(InfoFields) to High(InfoFields) do
  begin
    mInfoFields.Lines.Add(InfoFields[I] + ':');
//    mInfoValues.Lines.Add(gdContact.FieldByname(InfoFields[I]).AsString);
  end;
end;

end.

