
unit Test_gdcContact_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork;

type
  Tgs_gdcContactTest = class(TgsDBTestCase)
  published
    procedure Test_gdcContact;
  end;

  Tgs_gdcGoodTest = class(TgsDBTestCase)
  published
    procedure Test_gdcMetal;
  end;

implementation

uses
  SysUtils, IBSQL, gdcBaseInterface, gd_security, gdcContacts, gdcGood;

{ Tgs_gdcContactTest }

procedure Tgs_gdcContactTest.Test_gdcContact;
var
  C: TgdcContact;
  F: TgdcFolder;
  ID: TID;
begin
  F := TgdcFolder.Create(nil);
  C := TgdcContact.Create(nil);
  try
    F.Open;
    Check(not F.IsEmpty);

    C.Open;
    C.Insert;
    C.FieldByName('name').AsString := 'Test Name';
    C.FieldByName('surname').AsString := 'Test Surname';
    C.FieldByName('parent').AsInteger := F.ID;
    C.Post;

    ID := C.ID;

    C.Close;
    C.SubSet := 'ByID';
    C.ID := ID;
    C.Open;
    C.Next;

    Check(C.RecordCount = 1);

    C.Delete;
  finally
    C.Free;
    F.Free;
  end;
end;

{ Tgs_gdcGoodTest }

procedure Tgs_gdcGoodTest.Test_gdcMetal;
var
  M: TgdcMetal;
begin
  M := TgdcMetal.Create(nil);
  try
    M.Open;
    M.Insert;
    M.FieldByName('name').AsString := 'Золото';
    M.Post;
  finally
    M.Free;
  end;
end;

initialization
  RegisterTest('DB', Tgs_gdcContactTest.Suite);
  RegisterTest('DB', Tgs_gdcGoodTest.Suite);
end.
