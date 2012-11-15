unit at_frmIBUserList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBSQL, StdCtrls, ComCtrls, ExtCtrls, IBDatabase, ActnList, gsListView;

type
  TfrmIBUserList = class(TForm)
    lvUser: TgsListView;
    memoInfo: TMemo;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    Bevel1: TBevel;
    Label5: TLabel;
    alIBUsers: TActionList;
    actOk: TAction;
    lblCount: TLabel;
    btnRefresh: TButton;
    actRefresh: TAction;
    chbxShowNames: TCheckBox;
    btnDeleteUser: TButton;
    actDisconnect: TAction;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actRefreshUpdate(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);

  private
    procedure BuildUserList;

  public
    function CheckUsers: Boolean;
    procedure ShowUsers;
  end;

var
  frmIBUserList: TfrmIBUserList;

implementation

uses
  dmDataBase_unit, gdcBaseInterface, gd_common_functions, gd_security;

{$R *.DFM}

{ TfrmIBUserList }

function TfrmIBUserList.CheckUsers: Boolean;
begin
  BuildUserList;
  Result := (lvUser.Items.Count <= 1) or (ShowModal = mrOk);
end;

procedure TfrmIBUserList.ShowUsers;
begin
  btnCancel.Visible := False;
  memoInfo.Visible := False;

  btnOk.Caption := 'Закрыть';
  btnOk.Cancel := True;

  lvUser.Height := lvUser.Height + memoInfo.Height;

  BuildUserList;
  ShowModal;
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
      'SELECT A.MON$USER, U.NAME, U.FULLNAME, A.MON$REMOTE_ADDRESS, A.MON$TIMESTAMP, ' +
      '  A.MON$ATTACHMENT_ID ' +
      'FROM MON$ATTACHMENTS A LEFT JOIN GD_USER U ' +
      '  ON A.MON$USER = U.IBNAME ' +
      'WHERE A.MON$STATE = 1 ' +
      'ORDER BY A.MON$USER ';
    q.ExecQuery;

    while not q.EOF do
    begin
      ListItem := lvUser.Items.Add;
      ListItem.Caption := q.FieldByName('MON$USER').AsTrimString;
      ListItem.Data := TObject(q.FieldByName('MON$ATTACHMENT_ID').AsInteger);
      if q.FieldByName('NAME').IsNull then
        ListItem.SubItems.Add('Подключается...')
      else
        ListItem.SubItems.Add(q.FieldByName('NAME').AsTrimString);

      if chbxShowNames.Checked then
        ListItem.SubItems.Add(ALIPAddrToName(q.FieldByName('MON$REMOTE_ADDRESS').AsString))
      else
        ListItem.SubItems.Add(q.FieldByName('MON$REMOTE_ADDRESS').AsString);

      ListItem.SubItems.Add(q.FieldByName('MON$TIMESTAMP').AsString);

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

procedure TfrmIBUserList.actDisconnectExecute(Sender: TObject);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if MessageBox(Handle,
    'Отключить выбранного пользователя?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
  begin
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q.SQL.Text := 'DELETE FROM MON$STATEMENTS WHERE MON$ATTACHMENT_ID = :ID ';
      q.Params[0].AsInteger := Integer(lvUser.Selected.Data);
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;

      q.Close;
      q.SQL.Text := 'DELETE FROM MON$ATTACHMENTS WHERE MON$ATTACHMENT_ID = :ID ';
      q.Params[0].AsInteger := Integer(lvUser.Selected.Data);
      q.ExecQuery;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;
end;

procedure TfrmIBUserList.actDisconnectUpdate(Sender: TObject);
begin
  actDisconnect.Enabled := Assigned(lvUser.Selected)
    and Assigned(IBLogin)
    and IBLogin.IsIBUserAdmin;
end;

end.
