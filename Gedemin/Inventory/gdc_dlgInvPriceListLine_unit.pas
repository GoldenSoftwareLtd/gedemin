unit gdc_dlgInvPriceListLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, ExtCtrls,
  at_Container, gdcInvPriceList_unit;

type
  TdlgInvPriceLine = class(Tgdc_dlgTR)
    pnlAttributes: TPanel;
    atAttributes: TatContainer;
    Bevel1: TBevel;
    procedure atAttributesRelationNames(Sender: TObject; Relations,
      FieldAliases: TStringList);
  private
    FDocument: TgdcInvPriceList;

    function GetDocument: TgdcInvPriceList;
    function GetDocumentLine: TgdcInvPriceListLine;

  public
    constructor Create(AnOwner: TComponent); override;

    property Document: TgdcInvPriceList read GetDocument;
    property DocumentLine: TgdcInvPriceListLine read GetDocumentLine;
  end;

var
  dlgInvPriceLine: TdlgInvPriceLine;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcClasses, at_classes, gdcBase, IBSQL, gdcBaseInterface;

{ TdlgInvPriceLine }

procedure TdlgInvPriceLine.atAttributesRelationNames(Sender: TObject;
  Relations, FieldAliases: TStringList);
var
  I: Integer;
  F: TatRelationField;
begin
  for I := 0 to DocumentLine.FieldCount - 1 do
    if
      not DocumentLine.Fields[I].Calculated and
      (
        (AnsiCompareText(
          DocumentLine.RelationByAliasName(DocumentLine.Fields[I].FieldName),
          'INV_PRICELINE') = 0)
      )
    then begin
      F := atDatabase.FindRelationField(
        DocumentLine.RelationByAliasName(DocumentLine.Fields[I].FieldName),
        DocumentLine.FieldNameByAliasName(DocumentLine.Fields[I].FieldName));

      if Assigned(F) and F.IsUserDefined then
        FieldAliases.Add(DocumentLine.Fields[I].FieldName);
    end;

  FieldAliases.Add('GOODKEY');
end;

function TdlgInvPriceLine.GetDocument: TgdcInvPriceList;
begin
  if Assigned(DocumentLine.MasterSource) and Assigned(DocumentLine.MasterSource.DataSet) then
    Result := DocumentLine.MasterSource.DataSet as TgdcInvPriceList
  else
  begin
    if not Assigned(FDocument) then
    begin
      FDocument := TgdcInvPriceList.Create(Self);
      FDocument.SubType := DocumentLine.SubType;
      FDocument.SubSet := 'ByID';
      FDocument.ID := GetTID(DocumentLine.FieldByName('parent'));
      FDocument.Open;
    end;
    Result := FDocument;
  end;
end;

function TdlgInvPriceLine.GetDocumentLine: TgdcInvPriceListLine;
begin
  Result := gdcObject as TgdcInvPriceListLine;
end;

constructor TdlgInvPriceLine.Create(AnOwner: TComponent);
begin
  inherited;
  FDocument := nil;
end;

initialization
  RegisterFrmClass(TdlgInvPriceLine).AbstractBaseForm := True;

finalization
  UnRegisterFrmClass(TdlgInvPriceLine);
end.
