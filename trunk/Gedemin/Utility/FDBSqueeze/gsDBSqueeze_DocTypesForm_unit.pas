unit gsDBSqueeze_DocTypesForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ComCtrls;

type
  TgsDBSqueeze_DocTypesForm = class(TForm)
    strngrdIgnoreDocTypes: TStringGrid;
    mIgnoreDocTypes: TMemo;
    tvDocTypes: TTreeView;
    txt5: TStaticText;
    txt1: TStaticText;
    btnOK: TButton;
    btnCancel: TButton;
    procedure strngrdIgnoreDocTypesDblClick(Sender: TObject);
    procedure strngrdIgnoreDocTypesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FRowsSelectBits: TBits;
    FDocTypesList: TStringList;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetDocTypes(const ADocTypes: TStringList);
    procedure UpdateDocTypesMemo;
    procedure ClearData;
    procedure GridRepaint(SelectedDocTypes: TStringList);
    function GetSelectedDocTypes: TStringList;
    function GetDocTypeMemoText: String;
  end;

var
  gsDBSqueeze_DocTypesForm: TgsDBSqueeze_DocTypesForm;

implementation

{$R *.DFM}

constructor TgsDBSqueeze_DocTypesForm.Create(AnOwner: TComponent);
var
  I: Integer;
  CharsetList: TStringList;
begin
  inherited;

  FRowsSelectBits := TBits.Create;
  FDocTypesList := TStringList.Create;
end;
//---------------------------------------------------------------------------
destructor TgsDBSqueeze_DocTypesForm.Destroy;
begin
  FRowsSelectBits.Free;
  FDocTypesList.Free;
  
  inherited;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.SetDocTypes(const ADocTypes: TStringList);
var
  I: Integer;
begin
  FreeAndNil(FRowsSelectBits);
  FRowsSelectBits := TBits.Create;

  FRowsSelectBits.Size := ADocTypes.Count;
  strngrdIgnoreDocTypes.ColCount := 2;
  strngrdIgnoreDocTypes.RowCount :=  ADocTypes.Count;

  for I:=0 to ADocTypes.Count-1 do
  begin
    strngrdIgnoreDocTypes.Cells[0, I] := ADocTypes.Values[ADocTypes.Names[I]];  // имя типа дока
    strngrdIgnoreDocTypes.Cells[1, I] := ADocTypes.Names[I];                    // id типа
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.UpdateDocTypesMemo;
var
  I: Integer;
  Str: String;
  Delimiter: String;
begin
  for I:=0 to FRowsSelectBits.Size-1 do
  begin
    if FRowsSelectBits[I] then
    begin
      if Str <> '' then
        Delimiter := ', '
      else
        Delimiter := '';
      Str := Str + Delimiter + strngrdIgnoreDocTypes.Cells[0, I] + ' (' + strngrdIgnoreDocTypes.Cells[1, I] + ')';
    end;
  end;
  mIgnoreDocTypes.Clear;
  mIgnoreDocTypes.Text := Str;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.strngrdIgnoreDocTypesDblClick(
  Sender: TObject);
begin
  if Sender = strngrdIgnoreDocTypes then
  begin
    if not FRowsSelectBits[(Sender as TStringGrid).Row] then
      FRowsSelectBits[(Sender as TStringGrid).Row] := True
    else begin
      FRowsSelectBits[(Sender as TStringGrid).Row] := False;
    end;
    (Sender as TStringGrid).Repaint;

    UpdateDocTypesMemo;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.strngrdIgnoreDocTypesDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  AGrid : TStringGrid;
begin
  AGrid:=TStringGrid(Sender);

   if not FRowsSelectBits[ARow] then
     AGrid.Canvas.Brush.Color := clWhite
   else
     AGrid.Canvas.Brush.Color := $0088AEFF;

   if (gdSelected in State) then
   begin
     if not FRowsSelectBits[ARow] then
     begin
       AGrid.Canvas.Brush.Color := $0088AEFF;
     end
     else
       AGrid.Canvas.Brush.Color := $001F67FC;
   end;
    AGrid.Canvas.FillRect(Rect);  //paint the backgorund color
    AGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, AGrid.Cells[ACol, ARow]);
end;

procedure TgsDBSqueeze_DocTypesForm.ClearData;
var
  I: Integer;
begin
  with strngrdIgnoreDocTypes do
  for I:=0 to ColCount-1 do
    Cols[I].Clear;

  mIgnoreDocTypes.Clear;
  FDocTypesList.Clear;  
end;

function TgsDBSqueeze_DocTypesForm.GetSelectedDocTypes: TStringList;
var
  I: Integer;
begin
  for I:=0 to FRowsSelectBits.Size-1 do
  begin
    if FRowsSelectBits[I] then
      FDocTypesList.Append(Trim(strngrdIgnoreDocTypes.Cells[1, I]));
  end;

  Result := FDocTypesList;
end;

function TgsDBSqueeze_DocTypesForm.GetDocTypeMemoText: String;
begin
  Result := mIgnoreDocTypes.Text;
end;

procedure  TgsDBSqueeze_DocTypesForm.GridRepaint(SelectedDocTypes: TStringList);
var
  I: Integer;
begin
  for I:=0 to FRowsSelectBits.Size-1 do
    FRowsSelectBits[I] := False;

  for I:=0 to strngrdIgnoreDocTypes.RowCount-1 do
    FRowsSelectBits[I] := (SelectedDocTypes.IndexOf(Trim(strngrdIgnoreDocTypes.Cells[1, I])) <> -1);
  strngrdIgnoreDocTypes.Repaint;

  UpdateDocTypesMemo;
end;

procedure TgsDBSqueeze_DocTypesForm.btnOKClick(Sender: TObject);
begin
  Self.ModalResult := mrOK;
end;

procedure TgsDBSqueeze_DocTypesForm.btnCancelClick(Sender: TObject);
begin
  Self.ModalResult := mrNone;
  Self.Close;
end;

end.
