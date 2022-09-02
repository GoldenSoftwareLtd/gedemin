// ShlTanya, 03.02.2019

unit gdc_attr_dlgSetToTxt_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  Tgdc_attr_dlgSetToTxt = class(TForm)
    edFile: TEdit;
    Label1: TLabel;
    Button1: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    chbxSaveDependencies: TCheckBox;
    chbxUseRUID: TCheckBox;
    chbxDontSave: TCheckBox;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    SD: TSaveDialog;
    chbxDontSaveBLOB: TCheckBox;
    chbxOnlyDup: TCheckBox;
    chbxOnlyDiff: TCheckBox;
    Label2: TLabel;
    edCompare: TEdit;
    Button2: TButton;
    OD: TOpenDialog;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_attr_dlgSetToTxt: Tgdc_attr_dlgSetToTxt;

implementation

{$R *.DFM}

uses
  FileCtrl;

procedure Tgdc_attr_dlgSetToTxt.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgdc_attr_dlgSetToTxt.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgdc_attr_dlgSetToTxt.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (Trim(edFile.Text) > '')
    and DirectoryExists(EXtractFilePath(edFile.Text))
    and (ExtractFileName(edFile.Text) > '');
end;

procedure Tgdc_attr_dlgSetToTxt.Button1Click(Sender: TObject);
begin
  if SD.Execute then
  begin
    edFile.Text := SD.FileName;
  end;
end;

procedure Tgdc_attr_dlgSetToTxt.Button2Click(Sender: TObject);
begin
  if OD.Execute then
  begin
    edCompare.Text := OD.FileName;
  end;
end;

end.
