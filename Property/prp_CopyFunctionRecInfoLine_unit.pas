unit prp_CopyFunctionRecInfoLine_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, Grids, DBGrids, StdCtrls, ExtCtrls, IBDataBase;

type
  TCopyFunctionRecInfoLine = class(TFrame)
    Panel1: TPanel;
    stTableName: TStaticText;
    DBGrid: TDBGrid;
    IBDataSet: TIBDataSet;
    DataSource: TDataSource;
  private
    FTransaction: TIBTransaction;
    procedure SetTransaction(const Value: TIBTransaction);
    { Private declarations }
  public
    { Public declarations }
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;

implementation

{$R *.DFM}
procedure TCopyFunctionRecInfoLine.SetTransaction(
  const Value: TIBTransaction);
begin
  if FTransaction <> Value then
  begin
    FTransaction := Value;
    IBDataSet.Transaction := Transaction;
  end;
end;

end.
