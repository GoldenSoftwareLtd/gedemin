unit gdcUserGroup_dlgSetRights_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls;

type
  TgdcUserGroup_dlgSetRights = class(TForm)
    Label1: TLabel;
    lblGroupName: TLabel;
    rgCommand: TRadioGroup;
    rgTable: TRadioGroup;
    rgDoc: TRadioGroup;
    Button1: TButton;
    Button2: TButton;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    rgObjects: TRadioGroup;
    Panel1: TPanel;
    Label2: TLabel;
    edTables: TEdit;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);

  public
    FGroupMask: Integer;
  end;

var
  gdcUserGroup_dlgSetRights: TgdcUserGroup_dlgSetRights;

implementation

{$R *.DFM}

uses
  IBDatabase, IBSQL, gdcBaseInterface, at_classes, gd_security;

procedure TgdcUserGroup_dlgSetRights.actOkExecute(Sender: TObject);
var
  q: TIBSQL;
  Tr: TIBTransaction;
  SL: TStringList;
  I: Integer;

  procedure SetSQL(const ATableName: String; const AnAllow: Boolean);
  var
    R: TatRelation;
  begin
    R := atDatabase.Relations.ByRelationName(ATableName);
    if R = nil then
    begin
      MessageBox(Handle,
        PChar('Неверное имя таблицы: ' + ATableName),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      exit;
    end;

    if (R.RelationFields.ByFieldName('AFULL') <> nil)
      and (R.RelationFields.ByFieldName('ACHAG') <> nil)
      and (R.RelationFields.ByFieldName('AVIEW') <> nil) then
    begin
      if AnAllow then
      begin
        q.SQL.Text :=
          Format('UPDATE %s SET afull=BIN_OR(afull, %1:d), achag=BIN_OR(achag, %1:d), aview=BIN_OR(aview, %1:d) ',
          [ATableName, FGroupMask]);
      end else
      begin
        q.SQL.Text :=
          Format('UPDATE %s SET afull=BIN_AND(afull, %1:d), achag=BIN_AND(achag, %1:d), aview=BIN_AND(aview, %1:d) ',
          [ATableName, not FGroupMask]);
      end;
      q.ExecQuery;
    end;
  end;

begin
  if not IBLogin.IsIBUserAdmin then
  begin
    MessageBox(Handle,
      'Выполнять настройку прав доступа можно только под учетной записью Administrator.',
      'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    exit;
  end;

  if (IBLogin.ServerName > '') then
  begin
    MessageBox(Handle,
      'Одновременная работа других пользователей может привести к'#13#10 +
      'конфликтам обновления данных. При возникновении таковых, дождитесь'#13#10 +
      'пока другие пользователи отключатся от базы и повторите операцию.',
      'Внимание',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
  end;

  SL := TStringList.Create;
  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    SL.CommaText := edTables.Text;
    for I := 0 to SL.Count - 1 do
      SL.Objects[I] := Pointer(rgObjects.ItemIndex);
    SL.AddObject('gd_command', Pointer(rgCommand.ItemIndex));
    SL.AddObject('at_relations', Pointer(rgTable.ItemIndex));
    SL.AddObject('at_relation_fields', Pointer(rgTable.ItemIndex));
    SL.AddObject('gd_document', Pointer(rgDoc.ItemIndex));

    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;

    for I := 0 to SL.Count - 1 do
    begin
      if Integer(SL.Objects[I]) in [0, 1] then
        SetSQL(Trim(SL[I]), Integer(SL.Objects[I]) = 0);
    end;

    Tr.Commit;
  finally
    SL.Free;
    q.Free;
    Tr.Free;
  end;

  Close;
end;

procedure TgdcUserGroup_dlgSetRights.actCancelExecute(Sender: TObject);
begin
  Close;
end;

end.
