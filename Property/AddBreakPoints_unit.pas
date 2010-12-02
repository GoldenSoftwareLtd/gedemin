unit AddBreakPoints_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IBDatabase, Db, IBSQL;

type
  TForm1 = class(TForm)
    IBSQL1: TIBSQL;
    Label1: TLabel;
    Edit1: TEdit;
    IBSQL2: TIBSQL;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    Button1: TButton;
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
        try
          IBSQL2.SQL.Text := 'ALTER TABLE GD_FUNCTION ADD BREAKPOINTS DBLOB80';
          IBSQL2.ExecQuery;
          IBTransaction1.Commit;
        except
          IBTransaction1.RollBack;
          Exit;
        end;
        IBTransaction1.StartTransaction;
        try
          IBSQL2.SQL.Text := 'ALTER TABLE GD_FUNCTION ADD USEDEBUGINFO DBOOLEAN';
          IBSQL2.ExecQuery;
          IBTransaction1.Commit;
        except
          IBTransaction1.RollBack;
          Exit;
        end;
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
