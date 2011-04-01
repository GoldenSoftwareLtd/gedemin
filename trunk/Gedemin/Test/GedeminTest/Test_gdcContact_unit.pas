
unit Test_gdcContact_unit;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork, gdcContacts;

type
  Tgs_gdcContactTest = class(TgsDBTestCase)
  published
    procedure Test_gdcContact;
  end;

implementation

uses
  SysUtils, gdcBaseInterface;

{ Tgs_gdcContactTest }

procedure Tgs_gdcContactTest.Test_gdcContact;
var
  C: TgdcContact;
  F: TgdcFolder;
  ID: TID;
begin
  Check(gdcBaseManager.Database <> nil);
  Check(gdcBaseManager.Database.Connected);

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

initialization
  RegisterTest('DB', Tgs_gdcContactTest.Suite);
end.
