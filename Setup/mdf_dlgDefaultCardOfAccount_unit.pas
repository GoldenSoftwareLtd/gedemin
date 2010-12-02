unit mdf_dlgDefaultCardOfAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IBDatabase, ExtCtrls, IBSQL;

type
  TdlgCardOfAccount = class(TForm)
    Label1: TLabel;
    Panel1: TPanel;
    Transaction: TIBTransaction;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    procedure ComboBox1DropDown(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FDb: TIBDataBase;
    procedure SetDb(const Value: TIBDataBase);
    function GetCardOfAccount: Integer;
    { Private declarations }
  public
    { Public declarations }
    property Db: TIBDataBase  read FDb write SetDb;
    property CardOFAccount: Integer read GetCardOfAccount;
  end;

var
  dlgCardOfAccount: TdlgCardOfAccount;

implementation

{$R *.DFM}

{ TdlgCardOfAccount }

procedure TdlgCardOfAccount.SetDb(const Value: TIBDataBase);
begin
  FDb := Value;
  Transaction.DefaultDatabase := FDb 
end;

procedure TdlgCardOfAccount.ComboBox1DropDown(Sender: TObject);
var
  SQL: TIBSQL;
begin
  Transaction.StartTransaction;
  try
    SQL := TIBSQl.Create(nil);
    try
      SQL.Transaction := Transaction;
      SQL.SQL.Text := 'SELECT * FROM ac_account WHERE accounttype = ''C''';
      SQL.ExecQuery;
      Combobox1.Items.Clear;
      while not SQL.Eof do
      begin
        Combobox1.Items.AddObject(SQL.FieldByName('alias').AsString,
          Pointer(SQL.FieldByName('id').AsInteger));
        SQL.Next;
      end;
    finally
      SQl.Free;
    end;
  finally
    Transaction.Commit;
  end;
end;

procedure TdlgCardOfAccount.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (modalresult = mrCancel) or ((ModalResult = mrOk) and (ComboBox1.ItemIndex > - 1));
end;

function TdlgCardOfAccount.GetCardOfAccount: Integer;
begin
  Result := - 1;
  if ComboBox1.ItemIndex > - 1 then
    Result := Integer(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
end;

end.
