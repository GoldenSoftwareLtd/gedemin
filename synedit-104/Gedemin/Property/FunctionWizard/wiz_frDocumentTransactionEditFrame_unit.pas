unit wiz_frDocumentTransactionEditFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_FREDITFRAME_UNIT, StdCtrls, ComCtrls, gsIBLookupComboBox, IBDatabase,
  gdcBaseInterface, wiz_FunctionBlock_unit;

type
  TfrDocumentTransactionEditFrame = class(TfrEditFrame)
    lTransaction: TLabel;
    iblTransaction: TgsIBLookupComboBox;
    Transaction: TIBTransaction;
  private
    { Private declarations }
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frDocumentTransactionEditFrame: TfrDocumentTransactionEditFrame;

implementation

{$R *.DFM}

{ TfrDocumentTransactionEditFrame }

function TfrDocumentTransactionEditFrame.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    Result := iblTransaction.CurrentKeyInt > 0;
    if not Result then
    begin
      ShowCheckOkMessage('Необходимо указать типовую операцию');
    end;
  end;
end;

procedure TfrDocumentTransactionEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TTransactionBlock do
  begin
    TransactionRUID := gdcBaseManager.GetRUIDStringbyId(iblTransaction.CurrentKeyInt);
  end;
end;

procedure TfrDocumentTransactionEditFrame.SetBlock(
  const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TTransactionBlock do
  begin
    iblTransaction.CurrentKeyInt := gdcBaseManager.GetIdByRuidString(TransactionRUID);
  end;
end;

end.
