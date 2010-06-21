unit gp_dlgchoosepricevar_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, IBDatabase, IBSQL, dmDatabase_unit;

type
  TdlgChoosePriceVar = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    IBSQL: TIBSQL;
    IBTransaction: TIBTransaction;
    lvVariable: TListView;
    ibsqlCur: TIBSQL;
    procedure FormCreate(Sender: TObject);
  private
    function GetVariable: String;
    { Private declarations }
  public
    { Public declarations }
    function SetupDialog(const aFieldName: String): Boolean;
    property Variable: String read GetVariable;
  end;

var
  dlgChoosePriceVar: TdlgChoosePriceVar;

implementation

{$R *.DFM}

procedure TdlgChoosePriceVar.FormCreate(Sender: TObject);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;
end;

function TdlgChoosePriceVar.GetVariable: String;
begin
  if Assigned(lvVariable.Selected) then
    Result := lvVariable.Selected.SubItems[0]
  else
    Result := '';  
end;

function TdlgChoosePriceVar.SetupDialog(const aFieldName: String): Boolean;
var
  ListItem: TListItem;
begin
  ibsql.Prepare;
  ibsql.ParamByName('FN').AsString := aFieldName;
  ibsql.ExecQuery;
  while not ibsql.EOF do
  begin
    ListItem := lvVariable.Items.Add;
    ListItem.Caption := ibsql.FieldByName('lname').AsString;
    ListItem.SubItems.Add(ibsql.FieldByName('lshortname').AsString);
    ListItem.SubItems.Add(ibsql.FieldByName('fieldname').AsString);
    ibsql.Next;
  end;
  ibsql.Close;

  ibsqlCur.ExecQuery;
  while not ibsqlCur.EOF do
  begin
    ListItem := lvVariable.Items.Add;
    ListItem.Caption := ' урс по ' + ibsqlCur.FieldByName('shortname').AsString;
    ListItem.SubItems.Add(' урс_' + ibsqlCur.FieldByName('sign').AsString);
    ListItem.SubItems.Add(ibsqlCur.FieldByName('name').AsString);
    ibsqlCur.Next;
  end;
  ibsqlCur.Close;
  Result := ShowModal = mrOk;
end;

end.
