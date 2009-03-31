unit AddIDUnit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBScript, StdCtrls, IBDatabase, Db, IBSQL;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    Button1: TButton;
    IBSQL1: TIBSQL;
    IBSQL2: TIBSQL;
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
begin
  IBDatabase1.DatabaseName := Edit1.Text;
  IBDatabase1.Connected := True;
  try
    IBTransaction1.StartTransaction;
    try
      IBSQL1.ExecQuery;
      if IBSQL1.Fields[0].AsInteger = 0 then
      begin
//        IBScript1.ExecuteScript;
        try
          IBSQL2.SQL.Text := 'ALTER TABLE evt_objectevent DROP CONSTRAINT EVT_PK_OBJECTEVENT';
          IBSQL2.ExecQuery;
          IBTransaction1.Commit;
        except
          IBTransaction1.RollBack;
          Exit;
        end;
        IBTransaction1.StartTransaction;
        try
          IBSQL2.SQL.Text := 'ALTER TABLE EVT_OBJECTEVENT ADD ID DINTKEY';
          IBSQL2.ExecQuery;
          IBTransaction1.Commit;
        except
          IBTransaction1.RollBack;
          Exit;
        end;
        IBTransaction1.StartTransaction;
        try
          IBSQL2.SQL.Text := 'UPDATE evt_objectevent SET ID = ' +
            'GEN_ID(GD_G_UNIQUE, 1) + GEN_ID(GD_G_OFFSET, 0) WHERE ID IS NULL';
          IBSQL2.ExecQuery;
          IBTransaction1.Commit;
        except
          IBTransaction1.RollBack;
          Exit;
        end;
        IBTransaction1.StartTransaction;
        try
          IBSQL2.SQL.Text := 'ALTER TABLE EVT_OBJECTEVENT ADD CONSTRAINT EVT_PK_OBJECTEVENT_ID PRIMARY KEY (ID)';
          IBSQL2.ExecQuery;
          IBTransaction1.Commit;
        except
          IBTransaction1.RollBack;
          Exit;
        end;
        IBTransaction1.StartTransaction;
        try
          IBSQL2.SQL.Text := 'CREATE UNIQUE INDEX EVT_IDX_OBJECTEVENT ON EVT_OBJECTEVENT (EVENTNAME, OBJECTKEY)';
          IBSQL2.ExecQuery;
          IBTransaction1.Commit;
        except
          IBTransaction1.RollBack;
          Exit;
        end;
        IBTransaction1.StartTransaction;
        MessageBox(Handle, 'Добавление поля прошло успешно','', MB_Ok)
      end else
        MessageBox(Handle, 'Поле уже существует','', MB_Ok);
      IBTransaction1.Commit;
    except
      IBTransaction1.RollBack;
    end;
  finally
    IBDatabase1.Connected := False;
  end;
end;

end.
