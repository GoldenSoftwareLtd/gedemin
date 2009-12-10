unit at_frmIBUserList;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, IBSQL, StdCtrls, ComCtrls, ExtCtrls, IBDatabase,
  IBDatabaseInfo, ActnList;

type
  TfrmIBUserList = class(TForm)
    lvUser: TListView;
    memoInfo: TMemo;
    ibsqlUser: TIBSQL;
    pnlButtons: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    Bevel1: TBevel;
    Label5: TLabel;
    IBTransaction: TIBTransaction;
    IBUserTimer: TTimer;
    IBDatabaseInfo: TIBDatabaseInfo;
    alIBUsers: TActionList;
    actOk: TAction;
    actBuildUserList: TAction;
    lblCount: TLabel;

    procedure IBUserTimerTimer(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actBuildUserListExecute(Sender: TObject);

  private
    procedure BuildUserList;

  public
    function CheckUsers: Boolean;
    procedure ShowUsers;

  end;

var
  frmIBUserList: TfrmIBUserList;

implementation

uses dmDataBase_unit;

{$R *.DFM}

{ TfrmIBUserList }

function TfrmIBUserList.CheckUsers: Boolean;
begin
  if IBDatabaseInfo.UserNames.Count > 1 then
  begin
    BuildUserList;
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
  BuildUserList;
  IBUserTimer.Enabled := True;

  btnCancel.Visible := False;
  memoInfo.Visible := False;

  btnOk.Caption := 'Закрыть';
  btnOk.Cancel := True;

  lvUser.Height := lvUser.Height + memoInfo.Height;
  
  try
    ShowModal;
  finally
    IBUserTimer.Enabled := False;
  end;
end;

procedure TfrmIBUserList.BuildUserList;
var
  List: TStringList;
  I, K: Integer;
  ListItem: TListItem;
begin
  if (lvUser.Items.Count > 0) and Assigned(lvUser.Selected) then
    K := lvUser.Selected.Index
  else
    K := -1;

  with lvUser.Items do
  begin
    BeginUpdate;
    Clear;
    IBUserTimer.Enabled := False;
    List := TStringList.Create;

    try
      IBTransaction.Active := True;
      ibsqlUser.Prepare;

      List.Assign(IBDatabaseInfo.UserNames);

      ibsqlUser.Prepare;

      for I := 0 to List.Count - 1 do
      begin
        ibsqlUser.ParamByName('IBNAME').AsString := List[I];
        ibsqlUser.ExecQuery;

        ListItem := Add;
        ListItem.Caption := List[I];

        if ibsqlUser.RecordCount > 0  then
          ListItem.SubItems.Add(ibsqlUser.FieldByName('NAME').AsString)
        else
          ListItem.SubItems.Add('Пользователь подключается...');

        ibsqlUser.Close;
      end;

      lblCount.Caption := 'Всего подключено: ' + IntToStr(List.Count);

      if IBTransaction.Active then
        IBTransaction.Commit;
    finally
      IBUserTimer.Enabled := True;
      EndUpdate;
      List.Free;

      if IBTransaction.Active then
        IBTransaction.Rollback;
    end;
  end;

  if K > 0 then
  begin
    if lvUser.Items.Count > K then
      lvUser.Selected := lvUser.Items[K]
    else
      lvUser.Selected := lvUser.Items[lvUser.Items.Count - 1];

    if Assigned(lvUser.Selected) then
      lvUser.Selected.Focused := True;
  end;
end;

procedure TfrmIBUserList.IBUserTimerTimer(Sender: TObject);
begin
  actBuildUserList.Execute;
end;

procedure TfrmIBUserList.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmIBUserList.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (lvUser.Items.Count = 1) or (btnOk.Cancel);
end;

procedure TfrmIBUserList.actBuildUserListExecute(Sender: TObject);
begin
  BuildUserList;
end;

end.
