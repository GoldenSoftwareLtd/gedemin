unit rp_dlgViewResult_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, contnrs, DBGrids, DB;

type
  TdlgViewResult = class(TForm)
    pcDataSet: TPageControl;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
    FGridList: TObjectList;
    FPageList: TObjectList;

    procedure Clear;
    function GetPageCount: Integer;
  public
    property PageCount: Integer read GetPageCount;

    procedure AddPage(const AnDataSet: TDataSet); virtual;
  end;

var
  dlgViewResult: TdlgViewResult;

implementation

uses rp_frmGrid_unit;

{$R *.DFM}

function TdlgViewResult.GetPageCount: Integer;
begin
  Result := FPageList.Count;
end;

procedure TdlgViewResult.AddPage(const AnDataSet: TDataSet);
var
  I, J: Integer;
begin
  J := FPageList.Add(TTabSheet.Create(nil));
  TTabSheet(FPageList.Items[J]).Caption := AnDataSet.Name;
  TTabSheet(FPageList.Items[J]).PageControl := pcDataSet;
  TTabSheet(FPageList.Items[J]).Visible := True;
  TTabSheet(FPageList.Items[J]).TabVisible := True;

  I := FGridList.Add(TfrmGrid.Create(nil));
  TfrmGrid(FGridList.Items[I]).dsSource.DataSet := AnDataSet;
  TfrmGrid(FGridList.Items[I]).Parent := TTabSheet(FPageList.Items[J]);
  if I = 0 then
    TfrmGrid(FGridList.Items[I]).ViewForm := Self;
end;

procedure TdlgViewResult.FormCreate(Sender: TObject);
begin
  FGridList := TObjectList.Create;
  FPageList := TObjectList.Create;
end;

procedure TdlgViewResult.FormDestroy(Sender: TObject);
begin
  FGridList.Free;
  FPageList.Free;
end;

procedure TdlgViewResult.Clear;
begin
  FGridList.Clear;
  FPageList.Clear;
end;

end.
