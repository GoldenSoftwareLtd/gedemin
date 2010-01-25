unit tr_dlgChooseTransaction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, contnrs, tr_Type_unit, ActnList;

type
  TdlgChooseTransaction = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    lvTransaction: TListView;
    ActionList1: TActionList;
    actOk: TAction;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function SetupDialog(ListTransaction: TObjectList): TTransaction;
  end;

var
  dlgChooseTransaction: TdlgChooseTransaction;

implementation

{$R *.DFM}

{ TdlgChooseTransaction }

function TdlgChooseTransaction.SetupDialog(
  ListTransaction: TObjectList): TTransaction;
var
  i: Integer;
  ListItem: TListItem;
begin
  Result := nil;
  for i:= 0 to ListTransaction.Count - 1 do
  begin
    ListItem := lvTransaction.Items.Add;
    ListItem.Caption := TTransaction(ListTransaction[i]).TransactionName;
    ListItem.SubItems.AddObject(TTransaction(ListTransaction[i]).Description,
      ListTransaction[i]);
  end;
  if ShowModal = mrOk then
  begin
    Result := TTransaction(lvTransaction.Selected.SubItems.Objects[0]);
  end;
end;

procedure TdlgChooseTransaction.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TdlgChooseTransaction.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := lvTransaction.Selected <> nil;
end;

end.
