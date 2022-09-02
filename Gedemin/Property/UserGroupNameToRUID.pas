// ShlTanya, 26.02.2019

unit UserGroupNameToRUID;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBSQL, IBDatabase, Db, StdCtrls, IBScript;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Database: TIBDatabase;
    Transaction: TIBTransaction;
    sqlDObject: TIBSQL;
    IBSQL1: TIBSQL;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FDBID: Integer;
    function GetDBId: Integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  SQL, uSQL: TIBSQL;
begin
  if Edit1.Text = '' then
  begin
    MessageBox(Handle, '¬ведите им€ базы', '', MB_OK);
    Exit;
  end;

  DataBase.DatabaseName := Edit1.Text;
  DataBase.Connected := True;
  try
    Transaction.StartTransaction;
    try
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := Transaction;
        SQL.SQL.Text := 'SELECT g.id, e.eventname FROM gd_function g, evt_objectevent e ' +
          'WHERE g.id = e.functionkey and g.module = ''EVENTS''';
        SQL.ExecQuery;
        uSQL := TIBSQL.Create(nil);
        try
          uSQL.Transaction := Transaction;
          uSQl.SQL.Text := 'UPDATE gd_function SET event = :event WHERE id = :id';
          while not SQL.Eof do
          begin
            uSQL.Params[0].AsString := SQL.Fields[1].AsString;
            SetTID(uSQL.Params[1], SQL.Fields[0]);
            uSQL.ExecQuery;
            uSQL.Close;
            SQL.Next;
          end;
          uSQL.SQL.Text := 'DELETE FROM gd_function WHERE module = ''EVENTS'' and event is null';
          uSQL.ExecQuery;
          Transaction.Commit;
        finally
          USQL.Free;
        end;
      finally
        SQl.Free;
      end;
    except
      Transaction.Rollback;
    end;
  finally
    DataBase.Connected := False;
  end;
end;

function TForm1.GetDBId: Integer;
var
  SQL: TIBSQL;
begin
  if FDBID = 0 then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Text := 'SELECT gen_id(GD_G_DBID, 0) AS dbid ' +
        'FROM RDB$DATABASE';
      SQL.ExecQuery;
      FDBID := SQL.Fields[0].AsInteger;
    finally
      SQL.Free;
    end;
  end;
  Result := FDBID;
end;

end.
