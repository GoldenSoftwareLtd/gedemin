// ShlTanya, 20.02.2019

unit dp_dlgImportExportOptions_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Ternaries;

type
  TdlgImportExportOptions = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    edDirectoryPayment: TEdit;
    Bevel2: TBevel;
    Label3: TLabel;
    edExtensionPayment: TEdit;
    Label4: TLabel;
    edTemplatePayment: TEdit;
    cbDivideEnter: TCheckBox;
    Bevel3: TBevel;
    Label2: TLabel;
    edDirectoryStatement: TEdit;
    sbOpenPayment: TSpeedButton;
    Bevel1: TBevel;
    Label5: TLabel;
    edExtensionStatement: TEdit;
    Label6: TLabel;
    edTemplateStatement: TEdit;
    sbOpenPaymentTemplate: TSpeedButton;
    sbOpenStatement: TSpeedButton;
    sbOpenStatementTemplate: TSpeedButton;
    OpenDialog: TOpenDialog;
    cbToday: TCheckBox;
    procedure sbOpenStatementClick(Sender: TObject);
    procedure sbOpenPaymentClick(Sender: TObject);
    procedure sbOpenStatementTemplateClick(Sender: TObject);
    procedure sbOpenPaymentTemplateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    procedure LoadParams;
    procedure SaveParams;
  public
  end;

var
  dlgImportExportOptions: TdlgImportExportOptions;

implementation

{$R *.DFM}

uses
  FileCtrl, Storages;

procedure TdlgImportExportOptions.sbOpenStatementClick(Sender: TObject);
var
  S: String;
begin
  S := edDirectoryStatement.Text;
  if SelectDirectory(S, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then
    edDirectoryStatement.Text := S;
end;

procedure TdlgImportExportOptions.sbOpenPaymentClick(Sender: TObject);
var
  S: String;
begin
  S := edDirectoryPayment.Text;
  if SelectDirectory(S, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then
    edDirectoryPayment.Text := S;
end;

procedure TdlgImportExportOptions.sbOpenStatementTemplateClick(
  Sender: TObject);
begin
  OpenDialog.FileName := edTemplateStatement.Text;
  if OpenDialog.Execute then
    edTemplateStatement.Text := OpenDialog.FileName;
end;

procedure TdlgImportExportOptions.sbOpenPaymentTemplateClick(
  Sender: TObject);
begin
  OpenDialog.FileName := edTemplatePayment.Text;
  if OpenDialog.Execute then
    edTemplatePayment.Text := OpenDialog.FileName;
end;

procedure TdlgImportExportOptions.SaveParams;
begin
	Assert(GlobalStorage <> nil, 'Не подключены настройки');

  with UserStorage.OpenFolder('DepartmentImport') do
  begin
    WriteString('DirectoryPayment', edDirectoryPayment.Text);
    WriteString('DirectoryStatement', edDirectoryStatement.Text);
    WriteString('TemplatePayment', edTemplatePayment.Text);
    WriteString('TemplateStatement', edTemplateStatement.Text);
    WriteString('ExtensionPayment', edExtensionPayment.Text);
    WriteString('ExtensionStatemet', edExtensionStatement.Text);
    WriteInteger('DivideEnter', Ternary(cbDivideEnter.Checked, 1, 0));
    WriteInteger('Today', Ternary(cbToday.Checked, 1, 0));
  end;
end;

procedure TdlgImportExportOptions.LoadParams;
begin
	Assert(GlobalStorage <> nil, 'Не подключений настройки');

  with UserStorage.OpenFolder('DepartmentImport') do
  begin
    edDirectoryPayment.Text := ReadString('DirectoryPayment', '');
    edDirectoryStatement.Text := ReadString('DirectoryStatement', '');
    edTemplatePayment.Text := ReadString('TemplatePayment', '');
    edTemplateStatement.Text := ReadString('TemplateStatement', '');
    edExtensionPayment.Text := ReadString('ExtensionPayment', 'txt');
    edExtensionStatement.Text := ReadString('ExtensionStatemet', 'out');
    cbDivideEnter.Checked := ReadInteger('DivideEnter', 1) = 1;
    cbToday.Checked := ReadInteger('Today', 1) = 1;
  end;
end;

procedure TdlgImportExportOptions.FormCreate(Sender: TObject);
begin
  LoadParams;
end;

procedure TdlgImportExportOptions.btnOkClick(Sender: TObject);
begin
  SaveParams;
end;

end.
