unit msg_dlgOpenAttachment;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Db, IBCustomDataSet, gdcBase, gdcMessage, gd_createable_form;

type
  Tfrm_msgOpenAttachment = class(TCreateableForm)
    Bevel1: TBevel;
    Image1: TImage;
    lblOpen: TLabel;
    lblFileName: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    rbOpen: TRadioButton;
    rbSave: TRadioButton;
    lblQuetion: TLabel;
    lblAttention1: TLabel;
    lblAttencion2: TLabel;
    Label1: TLabel;
    lblAttention3: TLabel;
    gdcAttachmentOpen: TgdcAttachment;
    msgOpenDataSource: TDataSource;
    SaveDialogAttachment: TSaveDialog;
    procedure rbSaveClick(Sender: TObject);
    procedure rbOpenClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FFileName: String;
    { Private declarations }
  public
    constructor CreateDialog(AOwner: TComponent; AFileName: String);
  end;

var
  frm_msgOpenAttachment: Tfrm_msgOpenAttachment;

implementation

uses
  msg_frmmain,                  msg_attachment;

{$R *.DFM}

procedure Tfrm_msgOpenAttachment.rbSaveClick(Sender: TObject);
begin
  rbOpen.Checked := not rbSave.Checked;
end;

procedure Tfrm_msgOpenAttachment.rbOpenClick(Sender: TObject);
begin
  rbSave.Checked := not rbOpen.Checked;
end;

procedure Tfrm_msgOpenAttachment.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure Tfrm_msgOpenAttachment.btnOkClick(Sender: TObject);
begin
  if rbOpen.Checked then
    gdcAttachmentOpen.OpenAttachment
  else
    begin
      SaveDialogAttachment.FileName :=  GetCurrentDir;
      if copy(SaveDialogAttachment.FileName, Length(SaveDialogAttachment.FileName), 1) = '\' then
        SaveDialogAttachment.FileName := SaveDialogAttachment.FileName + FFileName
      else
        SaveDialogAttachment.FileName := SaveDialogAttachment.FileName +
          '\' + FFileName;
      if SaveDialogAttachment.Execute then
        attSaveToFile(SaveDialogAttachment.FileName,
        gdcAttachmentOpen.FieldByName('bdata').AsString);
    end;
  ModalResult := mrOk;
  Close;
end;

procedure Tfrm_msgOpenAttachment.FormCreate(Sender: TObject);
begin
  with msg_mainform do
    begin
      gdcAttachmentOpen.Transaction := IBTransaction;
      msgOpenDataSource.DataSet := ibqMessage;
      gdcAttachmentOpen.Open;
      gdcAttachmentOpen.Locate('FileName', FFileName, [loCaseInsensitive]);
    end;
  lblFileName.Caption := FFileName; 
end;

constructor Tfrm_msgOpenAttachment.CreateDialog(AOwner: TComponent;
  AFileName: String);
begin
  inherited Create(AOwner);

  FFileName := AFileName;
  if Pos('&', FFileName) > 0 then
      Delete(FFileName, Pos('&', FFileName), 1);

end;

end.
