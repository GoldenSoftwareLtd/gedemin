// ShlTanya, 03.02.2019, #4135

unit at_frmNSRecursion_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, dmDatabase_unit, dmImages_unit, IBDatabase, Grids,
  DBGrids, gsDBGrid, gsIBGrid, TB2Dock, TB2Toolbar, ComCtrls, Db,
  IBCustomDataSet, ActnList, TB2Item;

type
  Tat_frmNSRecursion = class(TCreateableForm)
    sb: TStatusBar;
    TBDock: TTBDock;
    tb: TTBToolbar;
    gsIBGrid: TgsIBGrid;
    ibtr: TIBTransaction;
    ibds: TIBDataSet;
    ds: TDataSource;
    ActionList: TActionList;
    procedure FormCreate(Sender: TObject);
    procedure dsDataChange(Sender: TObject; Field: TField);

  private
    procedure DoOnClick(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;  
  end;

var
  at_frmNSRecursion: Tat_frmNSRecursion;

implementation

{$R *.DFM}

uses
  gdcNamespace, gdcBaseInterface;

procedure Tat_frmNSRecursion.FormCreate(Sender: TObject);
begin
  ibtr.StartTransaction;
  ibds.Open;
end;

procedure Tat_frmNSRecursion.dsDataChange(Sender: TObject; Field: TField);
var
  I: Integer;
  SL: TStringList;
  TBI: TTBItem;
begin
  for I := tb.Items.Count - 1 downto 0 do
  begin
    if tb.Items[I].Tag > 0 then
      tb.Items[I].Free;
  end;

  SL := TStringList.Create;
  try
    SL.Text := StringReplace(ibds.FieldByName('OutPath').AsString,
      ',', #13#10, [rfReplaceAll]);
    for I := 0 to Sl.Count - 2 do // last item will repeat
    begin
      TBI := TTBItem.Create(nil);
      TBI.Tag := TID2Tag(GetTID(SL.Names[I]), Name);
      TBI.Caption := SL.Values[SL.Names[I]];
      TBI.OnClick := DoOnClick;
      tb.Items.Add(TBI);
    end;
  finally
    SL.Free;
  end;
end;

procedure Tat_frmNSRecursion.DoOnClick(Sender: TObject);
var
  Obj: TgdcNamespace;
begin
  Obj := TgdcNamespace.Create(nil);
  try
    Obj.SubSet := 'ByID';
    Obj.ID := GetTID((Sender as TComponent).Tag, Name);
    Obj.Open;
    if not Obj.EOF then
      Obj.EditDialog;
  finally
    Obj.Free;
  end;
end;

constructor Tat_frmNSRecursion.Create(AnOwner: TComponent);
begin
  inherited;
  ShowSpeedButton := True;
end;

end.
