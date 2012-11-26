
unit Test_Indy_unit;

interface

uses
  Classes, SysUtils, TestFrameWork;

type
  TgsIndyTest = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure Test;
    procedure Test_FLFlags;
    procedure Test_FLCollection;
    procedure Test_FLCollectionXML;
    procedure Test_CompareVersionStrings;
  end;

implementation

uses
  Forms, gd_WebClientControl_unit, gd_FileList_unit;

procedure TgsIndyTest.SetUp;
begin
  inherited;
end;

procedure TgsIndyTest.TearDown;
begin
  inherited;
end;

procedure TgsIndyTest.Test;
begin
  Check(gdWebClientThread.gdWebServerURL > '');
end;

procedure TgsIndyTest.Test_CompareVersionStrings;
begin
  Check(TFLItem.CompareVersionStrings('1.1.1.1', '1.1.1.1') = 0);
  Check(TFLItem.CompareVersionStrings('1.1.1.2', '1.1.1.1') > 0);
  Check(TFLItem.CompareVersionStrings('1.1.1.2', '1.1.2.1') < 0);
  Check(TFLItem.CompareVersionStrings('01.001.0001.00001', '1.1.1.1') = 0);
  Check(TFLItem.CompareVersionStrings('01.001.0001.00001', '1.9.1.1') < 0);
  Check(TFLItem.CompareVersionStrings('1.1.111.111', '1.1.111.1111') < 0);
  Check(TFLItem.CompareVersionStrings('8.8.888', '8.8.888.8888') < 0);
  Check(TFLItem.CompareVersionStrings('8.8.888.', '8.8.888.8888') < 0);
  Check(TFLItem.CompareVersionStrings('9', '8.8.888.8888') > 0);
  Check(TFLItem.CompareVersionStrings('...4', '0000.0000.0000.0005') < 0);

  Check(TFLItem.CompareVersionStrings('1.1.1.2', '1.1.1.1', 3) = 0);
  Check(TFLItem.CompareVersionStrings('1.1.1.1.5', '1.1.1.1.6') = 0);
  Check(TFLItem.CompareVersionStrings('1.1.1.1.5', '1.1.1.1.6', 5) < 0);
end;

procedure TgsIndyTest.Test_FLCollection;
var
  LocalFiles: TFLCollection;
  Item: TFLItem;
  I: Integer;
begin
  LocalFiles := TFLCollection.Create;
  try
    LocalFiles.BuildEtalonFileSet;

    for I := 0 to LocalFiles.Count - 1 do
    begin
      Item := LocalFiles.Items[I] as TFLItem;
      Check(Item.Exists, Item.FullName);
    end;
  finally
    LocalFiles.Free;
  end;
end;

procedure TgsIndyTest.Test_FLCollectionXML;
var
  S: String;
  C1, C2: TFLCollection;
  StS, StF: TStream;
begin
  C1 := TFLCollection.Create;
  C2 := TFLCollection.Create;
  try
    C1.BuildEtalonFileSet;
    S := C1.GetXML;
    Check(S > '');

    StF := TFileStream.Create(ExtractFileDrive(Application.EXEName) + ':\temp\test.xml', fmCreate);
    StS := TStringStream.Create(S);
    try
      StF.CopyFrom(StS, 0);
    finally
      StS.Free;
      StF.Free;
    end;

    C2.ParseXML(S);
    Check(S = C2.GetXML);
  finally
    C1.Free;
    C2.Free;
  end;
end;

procedure TgsIndyTest.Test_FLFlags;
var
  F: TFLFlag;
  FS: TFLFlags;
begin
  FS := [];
  Check(TFLItem.Str2Flags(TFLItem.Flags2Str(FS)) = FS);

  for F := Low(TFLFlag) to High(TFLFlag) do
  begin
    Include(FS, F);
    Check(TFLItem.Str2Flags(TFLItem.Flags2Str(FS)) = FS);
  end;
end;

initialization
  RegisterTest('Internals/Indy', TgsIndyTest.Suite);
end.

