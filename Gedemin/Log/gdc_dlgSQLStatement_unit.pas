// ShlTanya, 24.02.2019

unit gdc_dlgSQLStatement_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Menus, Db, ActnList, StdCtrls, SynEditHighlighter,
  SynHighlighterSQL, SynEdit, SynDBEdit;

type
  Tgdc_dlgSQLStatement = class(Tgdc_dlgG)
    SynEdit: TDBSynEdit;
    SynSQLSyn: TSynSQLSyn;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgSQLStatement: Tgdc_dlgSQLStatement;

implementation

{$R *.DFM}

uses
  gd_ClassList, syn_ManagerInterface_unit;

procedure Tgdc_dlgSQLStatement.FormCreate(Sender: TObject);
begin
  inherited;
  SynManager.GetHighlighterOptions(SynSQLSyn);
end;

initialization
  RegisterFrmClass(Tgdc_dlgSQLStatement);

finalization
  UnRegisterFrmClass(Tgdc_dlgSQLStatement);
end.
