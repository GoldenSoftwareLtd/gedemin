unit gs_frmFDBExtractData_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FDBExtractData_unit, StdCtrls, ExtCtrls, Buttons, ActnList;

type
  Tgs_frmFDBExtractData = class(TForm)
    Panel: TPanel;
    eDatabase: TEdit;
    lDatabase: TLabel;
    sbSelectDB: TSpeedButton;
    ActionList: TActionList;
    actSeletDB: TAction;
    eUser: TEdit;
    lUser: TLabel;
    lPassword: TLabel;
    ePassword: TEdit;
    Label1: TLabel;
    eSave: TEdit;
    sbSelectOutPutFile: TSpeedButton;
    btnExtract: TButton;
    actSelectOutPutFile: TAction;
    actExtract: TAction;
    mIgnoreFields: TMemo;
    procedure actSeletDBExecute(Sender: TObject);
    procedure actSelectOutPutFileExecute(Sender: TObject);
    procedure actExtractExecute(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  gs_frmFDBExtractData: Tgs_frmFDBExtractData;

implementation

{$R *.DFM}

uses
  FileCtrl;

procedure Tgs_frmFDBExtractData.actSeletDBExecute(Sender: TObject);
begin
  with TOpenDialog.Create(nil) do
  try
    Options := [ofPathMustExist, ofFileMustExist, ofEnableSizing];
    DefaultExt := 'fdb';
    Filter :=  'Database files only|*.fdb';
    FileName := Trim(eDatabase.Text);
    if Execute then
      eDatabase.Text := FileName;
  finally
    Free;
  end;
end;

procedure Tgs_frmFDBExtractData.actSelectOutPutFileExecute(Sender: TObject);
begin
  with TSaveDialog.Create(nil) do
  try
    Options := [ofOverwritePrompt,ofHideReadOnly,ofPathMustExist,
      ofNoReadOnlyReturn,ofEnableSizing];
    DefaultExt := 'txt';
    Filter := 'Txt files|*.txt';
    FileName := Trim(eSave.Text);
    if Execute then
      eSave.Text := FileName;
  finally
    Free;
  end;
end;

procedure Tgs_frmFDBExtractData.actExtractExecute(Sender: TObject);
var
  FDBExtractData: TgsDBExtractData;
begin
  FDBExtractData := TgsDBExtractData.Create;
  try
    FDBExtractData.DatabaseName := eDatabase.Text;
    FDBExtractData.UserName := eUser.Text;
    FDBExtractData.Password := ePassword.Text;
    FDBExtractData.Connect;
    FDBExtractData.ExtractData(eSave.Text, mIgnoreFields.Lines);
  finally
    FDBExtractData.Free;
  end;
end;

end.
