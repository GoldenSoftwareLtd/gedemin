// ShlTanya, 24.02.2019

unit gdc_frmSQLStatement_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcSQLStatement,
  gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, ComCtrls;

type
  Tgdc_frmSQLStatement = class(Tgdc_frmSGR)
    gdcSQLStatement: TgdcSQLStatement;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmSQLStatement: Tgdc_frmSQLStatement;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmSQLStatement.FormCreate(Sender: TObject);
begin
  gdcObject := gdcSQLStatement;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmSQLStatement);

finalization
  UnRegisterFrmClass(Tgdc_frmSQLStatement);
end.
