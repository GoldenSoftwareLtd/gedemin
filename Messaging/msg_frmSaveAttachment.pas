unit msg_frmSaveAttachment;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  StdCtrls, Db, IBCustomDataSet, gdcBase, gdcMessage, Grids, DBGrids,
  IBDatabase, gd_createable_form, ExtCtrls;

type
  TfrmSaveAttachment = class(TCreateableForm)
    Label1: TLabel;
    BtnSave: TButton;
    BtnCancel: TButton;
    BtnSelectAll: TButton;
    Label2: TLabel;
    EditDirectory: TEdit;
    BtnView: TButton;
    LstBxSaveAtt: TListBox;
    msgSaveAttDataSource: TDataSource;
    gdcAttachmentSave: TgdcAttachment;
    msgMessageDataSource: TDataSource;
    Panel1: TPanel;
    procedure BtnViewClick(Sender: TObject);
    procedure BtnSelectAllClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);


  private
    { Private declarations }

  protected
    procedure DoDestroy; override;

  public
    { Public declarations }
  end;

var
  frmSaveAttachment: TfrmSaveAttachment;

implementation

uses
  msg_frmmain,          gdc_dlgG_unit,
  msg_attachment,       FileCtrl;

{$R *.DFM}

procedure TfrmSaveAttachment.BtnViewClick(Sender: TObject);
var
  LocDirectory: String;
//  LocFrmSelectDirectory: TfrmSelectDirectory;
begin
  SelectDirectory('Выбор каталога для сохранения вложений', '', LocDirectory);
  EditDirectory.Text := LocDirectory;
{
  LocFrmSelectDirectory := TfrmSelectDirectory.Create(Self);
  with LocFrmSelectDirectory do
  try
    if ShowModal = mrOk then
      EditDirectory.Text := DirectoryListBox1.Directory;
  finally
    Free;
  end;
  }
end;

procedure TfrmSaveAttachment.BtnSelectAllClick(Sender: TObject);
var
  Index: Integer;
begin
  for Index := 0 to LstBxSaveAtt.Items.Count - 1 do
    LstBxSaveAtt.Selected[Index] := True;
end;

procedure TfrmSaveAttachment.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmSaveAttachment.BtnSaveClick(Sender: TObject);
var
  Index: Integer;
begin
  if not DirectoryExists(EditDirectory.Text) then
  begin
    MessageBox(0, 'Указанный путь не существует,' + #10#13 + 'или к нему нет доступа!', 'ОШИБКА', MB_OK or MB_ICONERROR);
    exit;
  end;
  gdcAttachmentSave.First;
  for Index := 0 to LstBxSaveAtt.Items.Count - 1 do
  begin
    if LstBxSaveAtt.Selected[Index] then
    begin
      gdcAttachmentSave.Locate('FileName', LstBxSaveAtt.Items[Index], [loCaseInsensitive]);
      attSaveToFile(EditDirectory.Text + '\' + LstBxSaveAtt.Items[Index],
        gdcAttachmentSave.FieldByName('bdata').AsString);
      LstBxSaveAtt.Selected[Index] := False;
    end;
  end;
end;

procedure TfrmSaveAttachment.FormCreate(Sender: TObject);
begin
  with msg_mainform do
    begin
      gdcAttachmentSave.Transaction := IBTransaction;
      msgMessageDataSource.DataSet := ibqMessage;
      gdcAttachmentSave.Open;
      while not gdcAttachmentSave.EOF do
      begin
        LstBxSaveAtt.Items.Add(gdcAttachmentSave.FieldByName('filename').AsString);
        gdcAttachmentSave.Next;
    end;
  end;
  EditDirectory.Text := GetCurrentDir;
end;

procedure TfrmSaveAttachment.FormShow(Sender: TObject);
begin
  BtnSelectAllClick(Sender);
end;

procedure TfrmSaveAttachment.DoDestroy;
begin
  inherited;

  try
    gdcAttachmentSave.Close;
  except
    Application.HandleException(Self);
  end;
end;

end.
