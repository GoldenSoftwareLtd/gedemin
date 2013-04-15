unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, gsDBSqueezeThread_unit, gd_ProgressNotifier_unit;

type
  TgsDBSqueeze_MainForm = class(TForm, IgdProgressWatch)
    edDatabaseName: TEdit;
    edUserName: TEdit;
    edPassword: TEdit;
    btnConnect: TButton;
    ActionList: TActionList;
    actConnect: TAction;
    actDisconnect: TAction;
    btnDisconnect: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    mLog: TMemo;
    lblLog: TLabel;

    procedure actConnectExecute(Sender: TObject);
    procedure actConnectUpdate(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

  private
    FSThread: TgsDBSqueezeThread;

    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm;

implementation

{$R *.DFM}

procedure TgsDBSqueeze_MainForm.actConnectExecute(Sender: TObject);
begin
  FSThread.SetDBParams(edDatabaseName.Text, edUserName.Text,
    edPassword.Text);
  FSThread.Connect;
end;

constructor TgsDBSqueeze_MainForm.Create(AnOwner: TComponent);
begin
  inherited;
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
end;

destructor TgsDBSqueeze_MainForm.Destroy;
begin
  FSThread.Free;
  inherited;
end;

procedure TgsDBSqueeze_MainForm.actConnectUpdate(Sender: TObject);
begin
  actConnect.Enabled := (not FSThread.Connected)
    and (edDatabaseName.Text > '')
    and (edUserName.Text > '')
    and (edPassword.Text > '');
end;

procedure TgsDBSqueeze_MainForm.actDisconnectUpdate(Sender: TObject);
begin
  actDisconnect.Enabled := FSThread.Connected;
end;

procedure TgsDBSqueeze_MainForm.actDisconnectExecute(Sender: TObject);
begin
  FSThread.Disconnect;
end;

procedure TgsDBSqueeze_MainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not FSThread.Busy;
end;

procedure TgsDBSqueeze_MainForm.UpdateProgress(
  const AProgressInfo: TgdProgressInfo);
begin
  if AProgressInfo.Message > '' then
    mLog.Lines.Add(FormatDateTime('h:nn:ss', Now) + ' -- ' + AProgressInfo.Message);
end;

end.
