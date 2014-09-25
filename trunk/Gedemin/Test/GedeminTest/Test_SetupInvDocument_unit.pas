unit Test_SetupInvDocument_unit;

interface

uses
  TestFrameWork, gsTestFrameWork, IBDatabase, gdcBase, classes;

type
  TgsInvSetupDocuments = class(TgsDBTestCase)
  protected 
    FCompanyID1, FCompanyID2, FGoodId1, FGoodId2: Integer;
    FDeptID1, FDeptID2: Integer;
    FCurrRemainsDept1, FCurrRemainsDept2: Integer;
    FDocID: TStringList;

    procedure SetUp; override;
    procedure TearDown; override;

    procedure MakeOldTriggerInvDocument;
    procedure AddNewInvDocument;

  published
    procedure DoTest;
  end;

implementation

uses
  gdcInvDocument_unit, gdcInvMovement, Db,
  gdcBaseInterface, Forms, Sysutils, windows;

{ TgsInvSetupDocuments }

procedure TgsInvSetupDocuments.AddNewInvDocument;
var
  gdcInvDocumentType: TgdcInvDocumentType;
begin
  gdcInvDocumentType := TgdcInvDocumentType.Create(nil);
  try
    gdcInvDocumentType.Append;
    gdcInvDocumentType.Post;
  finally
  end;
end;

procedure TgsInvSetupDocuments.DoTest;
begin
  MakeOldTriggerInvDocument;
end;

procedure TgsInvSetupDocuments.MakeOldTriggerInvDocument;
var
  gdcInvDocumentType: TgdcInvDocumentType;
begin
  gdcInvDocumentType := TgdcInvDocumentType.Create(nil);
  try
    gdcInvDocumentType.ExtraConditions.Text = 'classname = ''TgdcInvDocumentType''';
    gdcInvDocumentType.Open;
    gdcInvDocumentType.First;
    while not gdcInvDocumentType.EOF do
    begin
      gdcInvDocumentType.Edit;
      gdcInvDocumentType.Post;
      gdcInvDocumentType.Next;
    end;
  finally
    gdcInvDocumentType.Free;
  end;
end;

procedure TgsInvSetupDocuments.SetUp;
begin
  inherited;

end;

procedure TgsInvSetupDocuments.TearDown;
begin
  inherited;

end;

initialization
  RegisterTest('DB', TgsInvSetupDocuments.Suite);

end.
