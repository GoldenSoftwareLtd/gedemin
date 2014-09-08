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

    class procedure RegisterClassHierarchy; override;

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

class procedure TdlgInvPriceLine.RegisterClassHierarchy;

  procedure ReadFromDocumentType(ACE: TgdClassEntry);
  var
    CurrCE: TgdClassEntry;
    ibsql: TIBSQL;
    LSubType: string;
    LComment: String;
    LParentSubType: string;
  begin
    if ACE.Initialized then
      exit;

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text :=
        'SELECT '#13#10 +
        '  dt.name AS comment, '#13#10 +
        '  dt.classname AS classname, '#13#10 +
        '  dt.ruid AS subtype, '#13#10 +
        '  dt1.ruid AS parentsubtype '#13#10 +
        'FROM gd_documenttype dt '#13#10 +
        'LEFT JOIN gd_documenttype dt1 '#13#10 +
        '  ON dt1.id = dt.parent '#13#10 +
        '  AND dt1.documenttype = ''D'' '#13#10 +
        'WHERE '#13#10 +
        '  dt.documenttype = ''D'' '#13#10 +
        '  and dt.classname = ''TgdcInvPriceListType'' '#13#10 +  
        'ORDER BY dt.parent';

      ibsql.ExecQuery;

      while not ibsql.EOF do
      begin
        LSubType := ibsql.FieldByName('subtype').AsString;
        LComment := ibsql.FieldByName('comment').AsString;
        LParentSubType := ibsql.FieldByName('parentsubtype').AsString;

        CurrCE := gdClassList.Add(ACE.TheClass, LSubType, LComment, LParentSubType);

        CurrCE.Initialized := True;
        ibsql.Next;
      end;
    finally
      ibsql.Free;
    end;

    ACE.Initialized := True;
  end;

var
  CEBase: TgdClassEntry;

begin
  CEBase := gdClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromDocumentType(CEBase);
end;

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
{        (AnsiCompareText(
          DocumentLine.RelationByAliasName(DocumentLine.Fields[I].FieldName),
          'GD_GOOD') = 0)
          or                    }
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
      FDocument.ID := DocumentLine.FieldByName('parent').AsInteger;
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
  RegisterFrmClass(TdlgInvPriceLine);

finalization
  UnRegisterFrmClass(TdlgInvPriceLine);

end.
