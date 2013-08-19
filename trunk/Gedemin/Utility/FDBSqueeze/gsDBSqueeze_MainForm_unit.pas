unit gsDBSqueeze_MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, gsDBSqueezeThread_unit, gd_ProgressNotifier_unit,
  ComCtrls, DBCtrls, Buttons, ExtCtrls;

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
    btnDatabaseBrowse: TButton;
    pnl1: TPanel;
    lbl7: TLabel;
    actDatabaseBrowse: TAction;
    grpDBProperties: TGroupBox;
    txt1: TStaticText;
    txt2: TStaticText;
    txt3: TStaticText;
    txt4: TStaticText;
    txt5: TStaticText;
    txt6: TStaticText;
    txt7: TStaticText;
    txt8: TStaticText;
    txt9: TStaticText;
    txt11: TStaticText;
    txt12: TStaticText;
    txt13: TStaticText;
    txt14: TStaticText;
    txt15: TStaticText;
    txt10: TStaticText;
    btnGetStatistics: TButton;
    actGet: TAction;
    actUpdate: TAction;
    btnStop: TButton;

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
    procedure actDatabaseBrowseExecute(Sender: TObject);
    procedure actGetExecute(Sender: TObject);
    procedure actGetUpdate(Sender: TObject);

  private
    FSThread: TgsDBSqueezeThread;

    procedure SetItemsCbbEvent(const ACompanies: TStringList);
    procedure GetDBSizeEvent(const AnDBSize: String);
    procedure GetStatisticsEvent(const AGdDoc: String; const AnAcEntry: String; const AnInvMovement: String);
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
  FSThread.OnGetDBSize := GetDBSizeEvent;
  FSThread.OnGetStatistics := GetStatisticsEvent;
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

  FSThread.DoGetDBSize;

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

  FSThread.DoGetDBSize;
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

procedure TgsDBSqueeze_MainForm.FormCloseQuery(Sender: TObject;                  ///TODO: доработать
  var CanClose: Boolean);
var
  MsgStr: String;
begin
  MsgStr:= 'Do you really want to close?';
  ///CanClose := not FSThread.Busy;
  if MessageDlg(MsgStr, mtConfirmation, [mbOk, mbCancel], 0) = mrCancel then
    CanClose := False;

  if CanClose and FSThread.Connected then
    FSThread.Disconnect;
end;

procedure TgsDBSqueeze_MainForm.GetDBSizeEvent(const AnDBSize: String);
begin
  if Trim(txt9.Caption) = '' then
    txt9.Caption := AnDBSize
  else
   txt12.Caption := AnDBSize;
end;

procedure TgsDBSqueeze_MainForm.GetStatisticsEvent(const AGdDoc: String; const AnAcEntry: String; const AnInvMovement: String);
begin
  if (Trim(txt6.Caption) = '') and (Trim(txt7.Caption) = '') and (Trim(txt8.Caption) = '') then
  begin
    txt6.Caption := AGdDoc;
    txt7.Caption := AnAcEntry;
    txt8.Caption := AnInvMovement;
  end
  else
  begin
    txt13.Caption := AGdDoc;
    txt14.Caption := AnAcEntry;
    txt15.Caption := AnInvMovement;
  end;
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

procedure TgsDBSqueeze_MainForm.actDatabaseBrowseExecute(Sender: TObject);
var
  openDialog : TOpenDialog;
begin
  openDialog := TOpenDialog.Create(Self);
  try
    openDialog.InitialDir := GetCurrentDir;
    openDialog.Options := [ofFileMustExist];
    openDialog.Filter := 'Firebird Database File (*.FDB)|*.fdb|InterBase Database File (*.GDB)|*.gdb|All Files|*.*';
    openDialog.FilterIndex := 1;

    if openDialog.Execute then
      edDatabaseName.Text := openDialog.FileName;
  finally
    openDialog.Free;
  end;
end;


procedure TgsDBSqueeze_MainForm.actGetExecute(Sender: TObject);
begin
  FSThread.DoGetStatistics;
end;

procedure TgsDBSqueeze_MainForm.actGetUpdate(Sender: TObject);
begin
      //
end;

end.
