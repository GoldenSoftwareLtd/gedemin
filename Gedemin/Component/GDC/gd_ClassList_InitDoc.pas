unit gd_ClassList_InitDoc;

interface

uses
  gd_ClassList, gdcClasses;

type
  TgdInitDocClassEntry = class(TgdInitClassEntry)
  public
    Obj: TgdcDocumentType;

    procedure Init(CE: TgdClassEntry); override;
  end;

implementation

uses
  gdcClasses_interface;

{ TgdInitDocClassEntry }

procedure TgdInitDocClassEntry.Init(CE: TgdClassEntry);
var
  DE: TgdDocumentEntry;
begin
  Assert(Obj is TgdcDocumentType);

  DE := CE as TgdDocumentEntry;

  DE.TypeID := Obj.ID;
  DE.IsCommon := Obj.FieldByName('iscommon').AsInteger > 0;
  DE.HeaderFunctionKey := Obj.FieldByName('headerfunctionkey').AsInteger;
  DE.LineFunctionKey := Obj.FieldByName('linefunctionkey').AsInteger;
  DE.Description := Obj.FieldByName('description').AsString;
  DE.IsCheckNumber := TIsCheckNumber(Obj.FieldByName('ischecknumber').AsInteger);
  DE.Options := ''; //Obj.FieldByName('options').AsString;
  DE.ReportGroupKey := Obj.FieldByName('reportgroupkey').AsInteger;
  DE.HeaderRelKey := Obj.FieldByName('headerrelkey').AsInteger;
  DE.LineRelKey := Obj.FieldByName('linerelkey').AsInteger;
  DE.BranchKey := Obj.FieldByName('branchkey').AsInteger;
end;

end.
