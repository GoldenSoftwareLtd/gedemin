unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, gsDBSqueezeThread_unit, gd_ProgressNotifier_unit,
  ComCtrls, DBCtrls;

type
  TgsDBSqueeze_MainForm = class(TForm, IgdProgressWatch)

    ActionList: TActionList;
    actConnect: TAction;
    actDisconnect: TAction;
    actGo: TAction;
    btnConnect: TButton;
    btnDisconnect: TButton;
    btnGo: TButton;
    cbbCompany: TComboBox;
    dtpClosingDate: TDateTimePicker;
    edDatabaseName: TEdit;
    edUserName: TEdit;
    edPassword: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl6: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    mLog: TMemo;
    rbAllOurCompanies: TRadioButton;
    rbCompany: TRadioButton;
    actCompany: TAction;
    edServer: TEdit;
    chbServer: TCheckBox;
    actServer: TAction;
    grpDatabase: TGroupBox;
    grpOptions: TGroupBox;
    

    procedure actConnectExecute(Sender: TObject);
    procedure actConnectUpdate(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);
    procedure actGoExecute(Sender: TObject);
    procedure actGoUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actCompanyUpdate(Sender: TObject);
    procedure actCompanyExecute(Sender: TObject);
    procedure actServerExecute(Sender: TObject);
    procedure actServerUpdate(Sender: TObject);

  private
    FSThread: TgsDBSqueezeThread;

    procedure SetItemsCbbEvent(const ACompanies: TStringList);
    procedure UpdateProgress(const AProgressInfo: TgdProgressInfo);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm;

implementation

{$R *.DFM}

constructor TgsDBSqueeze_MainForm.Create(AnOwner: TComponent);
begin
  inherited;
  FSThread := TgsDBSqueezeThread.Create(False);
  FSThread.ProgressWatch := Self;
  FSThread.OnSetItemsCbb := SetItemsCbbEvent;
  mLog.ReadOnly := True;
  dtpClosingDate.Date := Date;
end;

destructor TgsDBSqueeze_MainForm.Destroy;
begin
  FSThread.Free;
  inherited;
end;

procedure TgsDBSqueeze_MainForm.actConnectExecute(Sender: TObject);
begin
  if (actServer.Enabled) and (chbServer.Checked) then
    FSThread.SetDBParams(edServer.Text + ':' + edDatabaseName.Text, edUserName.Text, edPassword.Text)
  else
    FSThread.SetDBParams(edDatabaseName.Text, edUserName.Text, edPassword.Text);

  FSThread.Connect;

  btnGo.Enabled := True;
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
  cbbCompany.Clear;
  FSThread.Disconnect;
  chbServer.Checked := False;
  chbServer.Enabled := True;
end;

procedure TgsDBSqueeze_MainForm.actGoExecute(Sender: TObject);
begin
  if rbCompany.Checked then
    FSThread.SetCompanyName(cbbCompany.Text);

  FSThread.SetClosingDate(dtpClosingDate.Date);

  FSThread.SetSaldoParams(
    rbAllOurCompanies.Checked,
    rbCompany.Checked);

  btnGo.Enabled := False;
end;

procedure TgsDBSqueeze_MainForm.actGoUpdate(Sender: TObject);
begin
  actGo.Enabled := FSThread.Connected
    and (rbAllOurCompanies.Checked or rbCompany.Checked);
end;

procedure TgsDBSqueeze_MainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := not FSThread.Busy;

  if CanClose and FSThread.Connected then
    FSThread.Disconnect;
end;

procedure TgsDBSqueeze_MainForm.SetItemsCbbEvent(const ACompanies: TStringList);
begin
  if rbCompany.Checked then
  begin
    cbbCompany.Clear;
    cbbCompany.Items.AddStrings(ACompanies);
  end;  
end;

procedure TgsDBSqueeze_MainForm.UpdateProgress(
  const AProgressInfo: TgdProgressInfo);
begin
  if AProgressInfo.Message > '' then
    mLog.Lines.Add(FormatDateTime('h:nn:ss', Now) + ' -- ' + AProgressInfo.Message);
end;

procedure TgsDBSqueeze_MainForm.actCompanyUpdate(Sender: TObject);
begin
  cbbCompany.Enabled := (rbCompany.Checked) and (FSThread.Connected);
end;

procedure TgsDBSqueeze_MainForm.actCompanyExecute(Sender: TObject);
begin
  FSThread.DoSetItemsCbb;
end;


procedure TgsDBSqueeze_MainForm.actServerExecute(Sender: TObject);
begin
  //
end;

procedure TgsDBSqueeze_MainForm.actServerUpdate(Sender: TObject);
begin
  edServer.Enabled:= chbServer.Checked;
  actServer.Enabled := edServer.Text > '';
end;



end.
