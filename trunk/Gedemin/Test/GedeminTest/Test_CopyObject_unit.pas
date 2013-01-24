
unit Test_CopyObject_unit;

interface

uses
  TestFrameWork, gsTestFrameWork;

type
  TTestCopyObject = class(TgsDBTestCase)
  published
    procedure TestCopySimpleObject;
    procedure TestCopyInheritedObject;
    procedure TestCopyProcedure;
  end;

implementation

uses
  gdcBase, gdcBaseInterface, IBDatabase, Classes, SysUtils,
  db, gdcAttrUserDefined, gdcWgPosition, gdcContacts,
  gdcMetadata, ibsql, at_frmSQLProcess;

procedure TTestCopyObject.TestCopySimpleObject;
var
  gdcObject: TgdcBase;
  OrigID: TID;
begin
  gdcObject := TgdcWgPosition.Create(nil);
  try
    gdcObject.Open;

    gdcObject.Insert;
    gdcObject.FieldByName('NAME').AsString := 'test_pos';
    gdcObject.Post;

    OrigID := gdcObject.ID;
    Check(OrigID > -1);

    gdcObject.CopyObject(False, False);

    Check(gdcObject.ID > -1);
    Check(OrigID <> gdcObject.ID);

    gdcObject.Delete;
    Check(gdcObject.Locate('id', OrigID, []));
    gdcObject.Delete;
  finally
    gdcObject.Free;
  end;
end;

procedure TTestCopyObject.TestCopyInheritedObject;
var
  gdcBaseContact, gdcCompany, gdcFolder: TgdcBase;
  OrigID, FolderID: TID;
begin
  gdcFolder := TgdcFolder.Create(nil);
  try
    gdcFolder.Open;
    Check(not gdcFolder.EOF);
    FolderID := gdcFolder.ID;
  finally
    gdcFolder.Free;
  end;

  gdcCompany := TgdcCompany.Create(nil);
  try
    gdcCompany.Open;
    gdcCompany.Insert;
    gdcCompany.FieldByName('parent').AsInteger := FolderID;
    gdcCompany.FieldByName('name').AsString := 'COMPANY';
    gdcCompany.FieldByName('fullname').AsString := 'COMPANY';
    gdcCompany.Post;

    OrigID := gdcCompany.ID;
  finally
    gdcCompany.Free;
  end;

  gdcBaseContact := TgdcBaseContact.Create(nil);
  try
    gdcBaseContact.Open;
    Check(gdcBaseContact.Locate('id', OrigID, []));
    gdcBaseContact.CopyObject(False, False);
    Check(gdcBaseContact.ID > -1);
    Check(OrigID <> gdcBaseContact.ID);

    gdcBaseContact.Delete;
    Check(gdcBaseContact.Locate('id', OrigID, []));
    gdcBaseContact.Delete;
  finally
    gdcBaseContact.Free;
  end;
end;

procedure TTestCopyObject.TestCopyProcedure;
var
  gdcObject: TgdcBase;
  OrigID: TID;
  OrigProcName: String;
begin
  gdcObject := TgdcStoredProc.Create(nil);
  try
    gdcObject.Open;

    Check(gdcObject.Locate('procedurename', 'USR$', [loPartialKey]),
      'В базе данных отсутствуют пользовательские процедуры');

    OrigID := gdcObject.ID;
    OrigProcName := gdcObject.FieldByName('procedurename').AsString;

    gdcObject.CopyObject(False, False);

    Check(gdcObject.ID > -1);
    Check(OrigID <> gdcObject.ID);
    Check(gdcObject.FieldByName('procedurename').AsString > '');
    Check(gdcObject.FieldByName('procedurename').AsString <> OrigProcName);

    gdcObject.Delete;
  finally
    gdcObject.Free;
  end;

  if frmSQLProcess <> nil then
    Check(not frmSQLProcess.IsError);
end;

initialization
  RegisterTest('DB', TTestCopyObject.Suite);
end.

