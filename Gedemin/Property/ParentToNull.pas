unit ParentToNull;

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
    sqlNameList: TIBSQL;
    sqlObject: TIBSQL;
    sqlDEvent: TIBSQL;
    sqlDObject: TIBSQL;
    sqlUObject: TIBSQL;
    IBScript1: TIBScript;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
  Id: Integer;
begin
  if Edit1.Text = '' then
  begin
    MessageBox(Handle, 'Введите имя базы', '', MB_OK);
    Exit;
  end;

  DataBase.DatabaseName := Edit1.Text;
  DataBase.Connected := True;
  try
    Transaction.StartTransaction;
    try
      IBScript1.ExecuteScript;
      Transaction.Commit;
      Transaction.StartTransaction;
      sqlNameList.ExecQuery;
      while not sqlNameList.Eof do
      begin
        sqlObject.Params[0].AsString := sqlNameList.Fields[0].AsString;
        sqlObject.ExecQuery;
        //Пропускаем первую запись
        id := sqlObject.FieldByName('id').AsInteger;
        sqlObject.Next;
        while not sqlObject.Eof do
        begin
          sqlDEvent.ParamByName('id').AsInteger := sqlObject.FieldByName('id').AsInteger;
          sqlDEvent.ExecQuery;
          sqlDEvent.Close;
          sqlObject.Next;
        end;
        sqlObject.Close;
        sqlDObject.Params[0].AsString := sqlNameList.Fields[0].AsString;
        sqlDObject.Params[1].AsInteger := id;
        sqlDObject.ExecQuery;
        sqlNameList.Next;
      end;
      sqlUObject.ExecQuery;
      Transaction.Commit;
      MessageBox(Handle, 'Все хорошо', '', MB_OK);
    except
      Transaction.Rollback;
    end;
  finally
    DataBase.Connected := False;
  end;
end;

end.
