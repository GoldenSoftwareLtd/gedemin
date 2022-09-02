// ShlTanya, 09.02.2019

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
  DE.HeaderFunctionKey := GetTID(Obj.FieldByName('headerfunctionkey'));
  DE.LineFunctionKey := GetTID(Obj.FieldByName('linefunctionkey'));
  DE.Description := Obj.FieldByName('description').AsString;
  DE.IsCheckNumber := TIsCheckNumber(Obj.FieldByName('ischecknumber').AsInteger);
  DE.Options := ''; //Obj.FieldByName('options').AsString;
  DE.ReportGroupKey := GetTID(Obj.FieldByName('reportgroupkey'));
  DE.HeaderRelKey := GetTID(Obj.FieldByName('headerrelkey'));
  DE.LineRelKey := GetTID(Obj.FieldByName('linerelkey'));
  DE.BranchKey := GetTID(Obj.FieldByName('branchkey'));
end;

end.
