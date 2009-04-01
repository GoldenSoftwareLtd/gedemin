unit rp_dlgRegistryForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Mask, xDateEdits, IBDatabase, ActnList, IBCustomDataSet, IBUpdateSQL,
  gd_security, Db, IBQuery, StdCtrls, DBCtrls, ExtCtrls, gsIBLookupComboBox,
  IBSQL, Buttons;

type
  TdlgRegistryForm = class(TForm)
    dbeName: TDBEdit;
    alNew: TActionList;
    IBTransaction: TIBTransaction;
    Label2: TLabel;
    dsRegistry: TDataSource;
    qryRegistry: TIBQuery;
    ibusRegistry: TIBUpdateSQL;
    OpenDialog: TOpenDialog;
    gbRTF: TGroupBox;
    rbFile: TRadioButton;
    dbeFileName: TDBEdit;
    btnAccess: TButton;
    Bevel1: TBevel;
    btnOk: TButton;
    btnCancel: TButton;
    rbData: TRadioButton;
    btnAddData: TButton;            
    bntEditRTF: TButton;
    btnAddFile: TButton;
    actAddFile: TAction;
    actAddData: TAction;
    actEditRTF: TAction;
    dbcbRegistry: TDBCheckBox;
    dbcbIsQuick: TDBCheckBox;
    dbcbPrintPreview: TDBCheckBox;
    procedure btnOkClick(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure actAddFileUpdate(Sender: TObject);
    procedure actAddDataUpdate(Sender: TObject);
    procedure actEditRTFUpdate(Sender: TObject);
    procedure actAddFileExecute(Sender: TObject);
    procedure actAddDataExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actEditRTFExecute(Sender: TObject);
  private
    FParent: Integer;
    FISQuick: Integer;

    procedure Append;
    procedure SetFile;
  public
    function Add(const AParent, AnIsQuick: Integer): Integer;
    function Edit(Key: Integer): Boolean;
  end;

var
  dlgRegistryForm: TdlgRegistryForm;

implementation

{$R *.DFM}

uses
  gd_security_OperationConst, msg_Attachment, ShellAPI,
  rp_Common, gd_setDataBase;

const
  CST_RTFFile = 'RTF files (*.RTF)|*.RTF';
  CST_RPTFile = 'RPT files (*.RPT)|*.RPT';

procedure TdlgRegistryForm.SetFile;
begin
  if qryRegistry.FieldByName('isquick').AsInteger = 1 then
    OpenDialog.Filter := CST_RPTFile
  else
    OpenDialog.Filter := CST_RTFFile;
end;

procedure TdlgRegistryForm.Append;
begin
  qryRegistry.Insert;
  qryRegistry.FieldByName('ID').AsInteger := GetUniqueKey(qryRegistry.Database,
   qryRegistry.Transaction);

  qryRegistry.FieldByName('Parent').AsInteger := FParent;

  qryRegistry.FieldByName('isquick').AsInteger := FIsQuick;

  qryRegistry.FieldByName('afull').AsInteger := -1;
  qryRegistry.FieldByName('achag').AsInteger := -1;
  qryRegistry.FieldByName('aview').AsInteger := -1;

  qryRegistry.FieldByName('isregistry').AsInteger := 1;
  rbFile.Checked := True;
end;

function TdlgRegistryForm.Add(const AParent, AnIsQuick: Integer): Integer;
begin
  FParent := AParent;
  FIsQuick := AnIsQuick;

  if not qryRegistry.Transaction.InTransaction then
    qryRegistry.Transaction.StartTransaction;

  qryRegistry.Open;
  Append;

  if ShowModal <> mrOk then
    Result := -1
  else
    Result := qryRegistry.FieldByName('id').AsInteger;
end;

function TdlgRegistryForm.Edit(Key: Integer): Boolean;
begin
  qryRegistry.ParamByName('id').AsInteger := Key;
  qryRegistry.Open;

  rbFile.Checked := not qryRegistry.FieldByName('FileName').IsNull;
  rbData.Checked := not rbFile.Checked;

  FIsQuick := qryRegistry.FieldByName('isQuick').AsInteger;

  qryRegistry.Edit;

  Result := ShowModal = mrOk;
end;

procedure TdlgRegistryForm.btnOkClick(Sender: TObject);
begin
  if rbFile.Checked then
  begin
    qryRegistry.FieldByName('Template').Clear;
    if qryRegistry.FieldByName('FileName').IsNull then
    begin
      ModalResult := mrNone;
      dbeFileName.SetFocus;
      ShowMessage('Привяжите файл.');
      exit;
    end;
  end
  else
  begin
    qryRegistry.FieldByName('FileName').Clear;
    if qryRegistry.FieldByName('Template').IsNull then
    begin
      ModalResult := mrNone;
      dbeFileName.SetFocus;
      ShowMessage('Подключите шаблон.');
      exit;
    end;
  end;

  qryRegistry.Post;
  qryRegistry.Transaction.CommitRetaining;
end;

procedure TdlgRegistryForm.actNewExecute(Sender: TObject);
begin
  ModalResult := mrOk;
  btnOkClick(btnOk);
  if qryRegistry.State in [dsInsert] then
    exit;
  ModalResult := mrNone;
  Append;
  dbeName.SetFocus;
end;

procedure TdlgRegistryForm.SpeedButton1Click(Sender: TObject);
begin
  OpenDialog.FileName := qryRegistry.FieldByName('filename').AsString;
  if OpenDialog.Execute then
    qryRegistry.FieldByName('filename').AsString := OpenDialog.FileName;
end;

procedure TdlgRegistryForm.actAddFileUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := rbFile.Checked;
  dbeFileName.Enabled := rbFile.Checked;
end;

procedure TdlgRegistryForm.actAddDataUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := rbData.Checked;
end;

procedure TdlgRegistryForm.actEditRTFUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := rbData.Checked and
    not qryRegistry.FieldByName('TEMPLATE').IsNull;
end;

procedure TdlgRegistryForm.actAddFileExecute(Sender: TObject);
begin
  SetFile;
  OpenDialog.FileName := qryRegistry.FieldByname('FileName').AsString;
  if OpenDialog.Execute then
   qryRegistry.FieldByname('FileName').AsString :=
     OpenDialog.FileName;
end;

procedure TdlgRegistryForm.actAddDataExecute(Sender: TObject);
begin
  SetFile;
  if OpenDialog.Execute then
    qryRegistry.FieldByName('template').AsString :=
      attLoadFromFile(OpenDialog.FileName);
end;

procedure TdlgRegistryForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
    IBTransaction.Rollback;
end;

procedure TdlgRegistryForm.actEditRTFExecute(Sender: TObject);
var
  S: String;
begin
  S := qryRegistry.FieldByName('Template').AsString;
  if EditBlobFile(S) then
    qryRegistry.FieldByName('Template').AsString := S;
end;

end.
