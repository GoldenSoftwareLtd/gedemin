unit tr_dlgChooseAnalyze_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, dmDatabase_unit, Grids, DBGrids, gsDBGrid, gsIBGrid,
  StdCtrls;

type
  TdlgChooseAnalyze = class(TForm)
    ibdsAnalyze: TIBDataSet;
    dsAnalyze: TDataSource;
    gsIBGrid1: TgsIBGrid;
    Button1: TButton;
    Button2: TButton;
  private
    FReferencyField: String;

    function GetAnalyzeKey: Integer;
    function GetAnalyzeName: String;
  public
    { Public declarations }
    function SetupDialog(const ReferencyName, ReferencyField: String): Boolean;

    property AnalyzeKey: Integer read GetAnalyzeKey;
    property AnalyzeName: String read GetAnalyzeName;
  end;

var
  dlgChooseAnalyze: TdlgChooseAnalyze;

implementation

{$R *.DFM}

{ TdlgChooseAnalyze }

function TdlgChooseAnalyze.GetAnalyzeKey: Integer;
begin
  Result := ibdsAnalyze.FieldByName('ID').AsInteger;
end;

function TdlgChooseAnalyze.GetAnalyzeName: String;
begin
  Result := ibdsAnalyze.FieldByName(FReferencyField).AsString;
end;

function TdlgChooseAnalyze.SetupDialog(const ReferencyName,
  ReferencyField: String): Boolean;
begin
  FReferencyField := ReferencyField;
  ibdsAnalyze.QSelect.SQL.Text :=
    Format('SELECT ID, %S FROM %S ORDER BY %S',
    [ReferencyField, ReferencyName, ReferencyField]);
  ibdsAnalyze.Open;
  ibdsAnalyze.FieldByName('ID').Visible := False;
  Result := ShowModal = mrOk;
end;

end.
