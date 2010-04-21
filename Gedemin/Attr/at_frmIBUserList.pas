unit at_frmIBUserList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBSQL, StdCtrls, ComCtrls, ExtCtrls, IBDatabase, ActnList;

type
  TfrmIBUserList = class(TForm)
    lvUser: TListView;
    memoInfo: TMemo;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    Bevel1: TBevel;
    Label5: TLabel;
    IBUserTimer: TTimer;
    alIBUsers: TActionList;
    actOk: TAction;
    lblCount: TLabel;
    btnRefresh: TButton;
    actRefresh: TAction;
    chbxShowNames: TCheckBox;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IBUserTimerTimer(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actRefreshUpdate(Sender: TObject);

  private
    FNotBuilt: Boolean;

    procedure BuildUserList;

  public
    function CheckUsers: Boolean;
    procedure ShowUsers;
  end;

var
  frmIBUserList: TfrmIBUserList;

implementation

uses
  dmDataBase_unit, gdcBaseInterface, WinSock;

{$R *.DFM}

function ALIPAddrToName(IPAddr : String): String;
var SockAddrIn: TSockAddrIn;
    HostEnt: PHostEnt;
    WSAData: TWSAData;
begin
  WSAData.wVersion := 0;
  WSAStartup(MAKEWORD(2,2), WSAData);
  Try
    SockAddrIn.sin_addr.s_addr:= inet_addr(PChar(IPAddr));
    HostEnt:= gethostbyaddr(@SockAddrIn.sin_addr.S_addr, 4, AF_INET);
    if HostEnt<>nil then result:=StrPas(Hostent^.h_name)
    else result:='';
  finally
    if WSAData.wVersion = 2 then WSACleanup;
  end;
end;

{ TfrmIBUserList }

function TfrmIBUserList.CheckUsers: Boolean;
begin
  if FNotBuilt then
  begin
    BuildUserList;
    FNotBuilt := False;
  end;

  if lvUser.Items.Count > 1 then
  begin
    IBUserTimer.Enabled := True;
    try
      Result := ShowModal = mrOk;
    finally
      IBUserTimer.Enabled := False;
    end;
  end else
    Result := True;
end;

procedure TfrmIBUserList.ShowUsers;
begin
  btnCancel.Visible := False;
  memoInfo.Visible := False;

  btnOk.Caption := 'Закрыть';
  btnOk.Cancel := True;

  lvUser.Height := lvUser.Height + memoInfo.Height;

  IBUserTimer.Enabled := True;
  try
    ShowModal;
  finally
    IBUserTimer.Enabled := False;
  end;
end;

procedure TfrmIBUserList.BuildUserList;
var
  I, K: Integer;
  ListItem: TListItem;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if (lvUser.Items.Count > 0) and Assigned(lvUser.Selected) then
    K := lvUser.Selected.Index
  else
    K := -1;

  lvUser.Items.BeginUpdate;
  q := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    I := 0;
    lvUser.Items.Clear;

    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT A.MON$USER, U.NAME, U.FULLNAME, A.MON$REMOTE_ADDRESS ' +
      'FROM MON$ATTACHMENTS A LEFT JOIN GD_USER U ' +
      '  ON A.MON$USER = U.IBNAME ' +
      'WHERE A.MON$STATE = 1 ';
    q.ExecQuery;

    while not q.EOF do
    begin
      ListItem := lvUser.Items.Add;
      ListItem.Caption := q.FieldByName('MON$USER').AsTrimString;

      if q.FieldByName('NAME').IsNull then
        ListItem.SubItems.Add('Подключается...')
      else
        ListItem.SubItems.Add(q.FieldByName('NAME').AsTrimString);

      if chbxShowNames.Checked then
        ListItem.SubItems.Add(ALIPAddrToName(q.FieldByName('MON$REMOTE_ADDRESS').AsString))
      else
        ListItem.SubItems.Add('<имя не определено>');

      Inc(I);
      q.Next;
    end;

    lblCount.Caption := 'Всего подключено: ' + IntToStr(I);
  finally
    q.Free;
    Tr.Free;
    lvUser.Items.EndUpdate;
  end;

  if K >= 0 then
  begin
    if lvUser.Items.Count > K then
      lvUser.Selected := lvUser.Items[K]
    else
      lvUser.Selected := lvUser.Items[lvUser.Items.Count - 1];

    if Assigned(lvUser.Selected) then
      lvUser.Selected.Focused := True;
  end;
end;

procedure TfrmIBUserList.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmIBUserList.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (lvUser.Items.Count = 1) or btnOk.Cancel;
end;

procedure TfrmIBUserList.FormCreate(Sender: TObject);
begin
  if gdcBaseManager.Database.Connected then
  begin
    BuildUserList;
    FNotBuilt := False;
  end else
    FNotBuilt := True;
end;

procedure TfrmIBUserList.IBUserTimerTimer(Sender: TObject);
var
  D: DWORD;
begin
  D := GetTickCount;
  actRefresh.Execute;
  if GetTickCount - D >= DWORD(IBUserTimer.Interval) then
    chbxShowNames.Checked := False;
end;

procedure TfrmIBUserList.actRefreshExecute(Sender: TObject);
begin
  BuildUserList;
end;

procedure TfrmIBUserList.actRefreshUpdate(Sender: TObject);
begin
  actRefresh.Enabled := (gdcBaseManager <> nil)
    and (gdcBaseManager.Database <> nil)
    and gdcBaseManager.Database.Connected;
end;

end.
