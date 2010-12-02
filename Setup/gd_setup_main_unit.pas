
unit gd_setup_main_unit;

interface

uses
  Windows,   Messages,   SysUtils, Classes,    Graphics,        Controls,     Forms, Dialogs,
  IBInstall, IBServices, Db,       IBDatabase, IBCustomDataSet, IBStoredProc,
  Bkground,  StdCtrls,   xLabel,   ExtCtrls,   gd_boDBUpgrade;

type
  TfrmMain = class(TForm)
    IBInstall: TIBInstall;
    IBDatabase: TIBDatabase;
    OpenDialog: TOpenDialog;
    IBTransaction: TIBTransaction;
    ibspGetDBVersion: TIBStoredProc;
    Background: TBackground;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    IBRestoreService: TIBRestoreService;
    Panel1: TPanel;
    mProgress: TMemo;
    boDBUpgrade: TboDBUpgrade;
    function IBInstallStatusChange(Sender: TObject;
      StatusComment: String): TStatusResult;
    procedure boDBUpgradeLogRecord(ASender: TObject;
      const AString: String);
    procedure boDBUpgrade1LogRecord(ASender: TObject;
      const AString: String);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

procedure AddMessage(const AMessage: String);  

implementation

{$R *.DFM}
uses
  gd_setup_dlgIBInstall_progress;

procedure AddMessage(const AMessage: String);
begin
  frmMain.mProgress.Lines.Add(AMessage);
  Application.ProcessMessages;
end;

function TfrmMain.IBInstallStatusChange(Sender: TObject;
  StatusComment: String): TStatusResult;
begin
  Result := srContinue;
  dlgIBSetupProgress.ProgressBar.Value := IBInstall.Progress;
  dlgIBSetupProgress.Label1.Caption := StatusComment;

  // Update billboards and other stuff as necessary
  mProgress.Lines.Add(StatusComment);
  Application.ProcessMessages;
end;

procedure TfrmMain.boDBUpgradeLogRecord(ASender: TObject;
  const AString: String);
begin
  mProgress.Lines.Add(AString);
  Application.ProcessMessages;
end;

procedure TfrmMain.boDBUpgrade1LogRecord(ASender: TObject;
  const AString: String);
begin
  AddMessage(AString);
end;

end.
