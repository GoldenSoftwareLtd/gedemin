// ShlTanya, 03.02.2019

unit at_frmIBUserList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBSQL, StdCtrls, ComCtrls, ExtCtrls, IBDatabase, ActnList, gsListView;

type
  TfrmIBUserList = class(TForm)
    lvUser: TgsListView;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    Bevel1: TBevel;
    lblCapt: TLabel;
    alIBUsers: TActionList;
    actOk: TAction;
    lblCount: TLabel;
    actRefresh: TAction;
    chbxShowNames: TCheckBox;
    btnDeleteUser: TButton;
    actDisconnect: TAction;
    btnDeleteAll: TButton;
    actDisconnectAll: TAction;
    btnRefresh: TButton;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actRefreshUpdate(Sender: TObject);
    procedure actDisconnectExecute(Sender: TObject);
    procedure actDisconnectUpdate(Sender: TObject);
    procedure actDisconnectAllUpdate(Sender: TObject);
    procedure actDisconnectAllExecute(Sender: TObject);

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
  lblCapt.Caption := 'Для выполнения действий необходимо отключить всех пользователей!';
  lblCapt.Color := clRed;
  actRefresh.Execute;
  Result := (lvUser.Items.Count <= 1) or (ShowModal = mrOk);
end;

procedure TfrmIBUserList.ShowUsers;
begin
  btnCancel.Visible := False;
  btnOk.Caption := 'Закрыть';
  btnOk.Cancel := True;

  actRefresh.Execute;
  ShowModal;
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
var
  I, K: Integer;
  ListItem: TListItem;
  q: TIBSQL;
  Tr: TIBTransaction;
  S, S1, CompName: String;
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

    //TODO
    //мы проверяем на системные учетные записи просто сравнивая по имени в запросе
    //потому что в ФБ 2.5 нет поля MON$SYSTEM_FLAG в таблице MON$ATTACHMENTS
    //по правильному будет добавить в IBLogin версию сервера и исходя из нее
    //добавлять проверку в запрос

    q.Transaction := Tr;
    q.SQL.Text :=
      'SELECT '#13#10 +
      '  A.MON$USER, '#13#10 +
      '  U.NAME, '#13#10 +
      '  U.FULLNAME, '#13#10 +
      '  A.MON$REMOTE_ADDRESS, '#13#10 +
      '  A.MON$TIMESTAMP, '#13#10 +
      '  A.MON$ATTACHMENT_ID, '#13#10 +
      '  ( '#13#10 +
      '    SELECT FIRST 1 TR.MON$TIMESTAMP '#13#10 +
      '    FROM MON$TRANSACTIONS TR '#13#10 +
      '    WHERE TR.MON$ATTACHMENT_ID = A.MON$ATTACHMENT_ID '#13#10 +
      '      AND TR.MON$READ_ONLY = 0 '#13#10 +
      '      AND TR.MON$TRANSACTION_ID <> CURRENT_TRANSACTION '#13#10 +
      '    ORDER BY TR.MON$TIMESTAMP DESC '#13#10 +
      '  ) AS TR_TIMESTAMP '#13#10 +
      'FROM '#13#10 +
      '  MON$ATTACHMENTS A '#13#10 +
      '  LEFT JOIN GD_USER U ON A.MON$USER = U.IBNAME '#13#10 +
      'WHERE '#13#10 +
      '  A.MON$USER <> ''Cache Writer'' AND A.MON$USER <> ''Garbage Collector'''#13#10 +
      'ORDER BY '#13#10 +
      '  U.NAME';

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

      S := q.FieldByName('MON$REMOTE_ADDRESS').AsTrimString;
      if chbxShowNames.Checked then
      begin
        S1 := S;
        if pos('/', S) > 0 then
          S1 := copy(S, 1, pos('/', S) - 1);
        CompName := ALIPAddrToName(S1);
        if (CompName > '') and (S1 <> '127.0.0.1') then
          S := CompName + ' (' + S + ')';
      end;
      ListItem.SubItems.Add(S);

      ListItem.SubItems.Add(q.FieldByName('MON$TIMESTAMP').AsString);
      ListItem.SubItems.Add(q.FieldByName('TR_TIMESTAMP').AsString);

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
      q.SQL.Text := 'DELETE FROM MON$STATEMENTS WHERE MON$ATTACHMENT_ID = :ID ' +
        ' AND MON$ATTACHMENT_ID <> CURRENT_CONNECTION';
      q.Params[0].AsInteger := Integer(lvUser.Selected.Data);
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;

      q.Close;
      q.SQL.Text := 'DELETE FROM MON$ATTACHMENTS WHERE MON$ATTACHMENT_ID = :ID ' +
        ' AND MON$ATTACHMENT_ID <> CURRENT_CONNECTION';
      q.Params[0].AsInteger := Integer(lvUser.Selected.Data);
      q.ExecQuery;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;

    actRefresh.Execute;
  end;
end;

procedure TfrmIBUserList.actDisconnectUpdate(Sender: TObject);
begin
  actDisconnect.Enabled := Assigned(lvUser.Selected)
    and (lvUser.Items.Count > 1)
    and Assigned(IBLogin)
    and IBLogin.IsIBUserAdmin;
end;

procedure TfrmIBUserList.actDisconnectAllUpdate(Sender: TObject);
begin
  actDisconnectAll.Enabled := (lvUser.Items.Count > 1)
    and Assigned(IBLogin)
    and IBLogin.IsIBUserAdmin;
end;

procedure TfrmIBUserList.actDisconnectAllExecute(Sender: TObject);
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  if MessageBox(Handle,
    'Отключить всех пользователей?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
  begin
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q.SQL.Text := 'DELETE FROM MON$STATEMENTS WHERE MON$ATTACHMENT_ID <> CURRENT_CONNECTION';
      q.ExecQuery;

      Tr.Commit;
      Tr.StartTransaction;

      q.Close;
      q.SQL.Text := 'DELETE FROM MON$ATTACHMENTS WHERE MON$ATTACHMENT_ID <> CURRENT_CONNECTION';
      q.ExecQuery;

      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;

    actRefresh.Execute;
  end;
end;

end.
