unit Test_OverrideMethods_unit;

interface

uses
  TestFrameWork, gsTestFrameWork, IBDatabase, gdcBase, gdcClasses,
  gdcDelphiObject, gdcFunction, gdcBaseInterface, gdcEvent;

const
  ClassMethodList: array[0..7] of String = (
//  'BEFOREDESTRUCTION',
//  'CHECKSUBSET',
//  'CHECKTHESAMESTATEMENT',
//  'COPYDIALOG',
//  'CREATEDIALOG',
//  'CREATEDIALOGFORM',
//  'CREATEFIELDS',
//  'CUSTOMDELETE',
//  'CUSTOMINSERT',
//  'CUSTOMMODIFY',
//  'DOAFTERCANCEL',
//  'DOAFTERCUSTOMPROCESS',
//  'DOAFTERDELETE',
//  'DOAFTEREDIT',
//  'DOAFTEREXTRACHANGED',
//  'DOAFTERINSERT',
  'DOAFTEROPEN',
//  'DOAFTERPOST',
//  'DOAFTERSCROLL',
//  'DOAFTERSHOWDIALOG',
//  'DOAFTERTRANSACTIONEND',
  'DOBEFORECLOSE',
//  'DOBEFOREDELETE',
//  'DOBEFOREEDIT',
//  'DOBEFOREINSERT',
  'DOBEFOREOPEN',
//  'DOBEFOREPOST',
//  'DOBEFORESCROLL',
//  'DOBEFORESHOWDIALOG',
//  'DOFIELDCHANGE',
//  'DOONFILTERCHANGED',
//  'DOONREPORTCLICK',
//  'DOONREPORTLISTCLICK',
//  'EDITDIALOG',
//  'GETCURRRECORDSUBTYPE',
//  'GETDIALOGDEFAULTSFIELDS',
  'GETFROMCLAUSE',
  'GETGROUPCLAUSE',
//  'GETNOTCOPYFIELD',
  'GETORDERCLAUSE',
  'GETSELECTCLAUSE',
  'GETWHERECLAUSE'//,
//  '_DOONNEWRECORD');
  );
  path = 'c:\temp\override.txt';
type
  TgdcUserDocumentTest = class(TgsDBTestCase)
  private
    FDocId: Array[0..3] of Integer;
    FDocFullName: Array[0..3] of TgdcFullClassName;

    function GetObjectKey(AFullClassName: TgdcFullClassName): Integer;
    procedure NewTextFile;
    function RemakeScript(AScript: String; AFullClassName: TgdcFullClassName;
      const AMethodName: String): String;
    procedure FillLVL(ALevel: Integer);
    procedure ClearLVL(ALevel: Integer);
    procedure ExecTest(ALevel: Integer);
    procedure ExecTestAll;

  protected
    procedure AddDocuments;
    procedure RemoveDocuments;
    procedure AddMethod(AFullClassName: TgdcFullClassName; const AMethodName: String);
    procedure RemoveMethod(AFullClassName: TgdcFullClassName; const AMethodName: String);
    procedure InsertClass(AFullClassName: TgdcFullClassName);
    procedure TestLVL(ALevel: Integer);
    procedure TestAllLVL;

  published
    procedure DoTest; virtual;

  end;
  
implementation

uses
  Db, gd_ClassList,
  Forms, Sysutils, windows, Classes;
  
{ TgdcUserDocumentTest }

procedure TgdcUserDocumentTest.TestAllLVL;
var
  I: Integer;
begin
   //заполнить уровени
  for I := 0 to 3 do
    FillLVL(I);
  //запустить тест
  Reconnect;

  ExecTestAll;
  //освободить уровени
  for I := 3 downto 0 do
    ClearLVL(I);
end;

procedure TgdcUserDocumentTest.ExecTestAll;
var
  Obj: TgdcUserDocument;
  I, J, K: Integer;
  SL :TStringList;
begin
  for I := 0 to 3 do
  begin
    NewTextFile;
    Obj := TgdcUserDocument.CreateSubType(nil, FDocFullName[I].SubType);
    Obj.Open;
    Obj.Close;

    SL := TStringList.Create;
    try
      SL.LoadFromFile(path);

      for J := Low(ClassMethodList) to High(ClassMethodList) do
      begin
        for K := 0 to SL.Count - 1 do
        begin

        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

procedure TgdcUserDocumentTest.ExecTest(ALevel: Integer);
var
  Obj: TgdcUserDocument;
  I, J, K: Integer;
  BeforeIndex: Integer;
  AfterIndex: Integer;
  SL :TStringList;
begin
  for I := 0 to 3 do
  begin
    NewTextFile;
    Obj := TgdcUserDocument.CreateSubType(nil, FDocFullName[I].SubType);
    Obj.Open;
    Obj.Close;

    SL := TStringList.Create;
    try
      SL.LoadFromFile(path);

      Check((I < ALevel) or (SL.Count > 0), 'Ошибка перекрытия метода');

      if I >= ALevel then
      begin
        for J := Low(ClassMethodList) to High(ClassMethodList) do
        begin
          BeforeIndex := -1;
          AfterIndex := -1;
          for K := 0 to SL.Count - 1 do
          begin
            if SL[K] = 'BEFOREINHERITED,' + FDocFullName[ALevel].gdClassName + ','
              + FDocFullName[ALevel].SubType + ',' + ClassMethodList[J] then
            begin
              BeforeIndex := K;
            end;

            if SL[K] = 'AFTERINHERITED,' + FDocFullName[ALevel].gdClassName + ','
              + FDocFullName[ALevel].SubType + ',' + ClassMethodList[J] then
            begin
              AfterIndex := K;
            end;
          end;

          Check(BeforeIndex <> -1, 'Ошибка перекрытия метода');
          Check(AfterIndex <> -1, 'Ошибка перекрытия метода');
          Check(AfterIndex > BeforeIndex, 'Ошибка перекрытия метода');
        end;
      end;

    finally
      SL.Free;
    end;
  end;

end;

procedure TgdcUserDocumentTest.FillLVL(ALevel: Integer);
var
  I: Integer;
begin
  for I := Low(ClassMethodList) to High(ClassMethodList) do
  begin
    AddMethod(FDocFullName[ALevel], ClassMethodList[I]);
  end;
end;

procedure TgdcUserDocumentTest.ClearLVL(ALevel: Integer);
var
  I: Integer;
begin
  for I := Low(ClassMethodList) to High(ClassMethodList) do
  begin
    RemoveMethod(FDocFullName[ALevel], ClassMethodList[I]);
  end;
end;

procedure TgdcUserDocumentTest.TestLVL(ALevel: Integer);
begin
  //заполнить уровень
  FillLVL(ALevel);

  Reconnect;
  //запустить тест
  ExecTest(ALevel);
  //освободить уровень
  ClearLVL(ALevel);
end;

function TgdcUserDocumentTest.RemakeScript(AScript: String; AFullClassName: TgdcFullClassName;
  const AMethodName: String): String;
var
  P1: Integer;
  P2: Integer;
  Funct: Boolean;
begin
  P1 := AnsiPos('''*** Данный код необходим для вызова кода определенного в gdc-классе.***', AScript);
  Assert(P1 <> 0);
  Result := Result + Copy(AScript, 1, P1 - 1);
  Result := Result +  #13#10 +
    'Dim fso, f' +  #13#10 +
    'Const ForAppending = 8' +  #13#10 +
    'Set fso = CreateObject("Scripting.FileSystemObject")' +  #13#10 +
    'Set f = fso.OpenTextFile("' + path + '", ForAppending, True)' +  #13#10 +
    'f.WriteLine("' + 'BEFOREINHERITED,' + AFullClassName.gdClassName + ','
      + AFullClassName.SubType + ',' + AMethodName + '")' +  #13#10 +
    'f.Close' +  #13#10;

  Funct := False;
  P2 := AnsiPos('End Sub', AScript);
  if P2 = 0 then
  begin
    P2 := AnsiPos('End function', AScript);
    Funct := True;
  end;
  Assert(P2 <> 0);
  
  Result := Result + Copy(AScript, P1, P2 - P1 - 1);
  Result := Result +  #13#10 +
    'Set f = fso.OpenTextFile("' + path + '", ForAppending, True)' +  #13#10 +
    'f.WriteLine("' + 'AFTERINHERITED,' + AFullClassName.gdClassName + ','
      + AFullClassName.SubType + ',' + AMethodName + '")' +  #13#10 +
    'f.Close' +  #13#10;
  if Funct then
    Result := Result + 'End function'
  else
    Result := Result + 'End Sub';
end;

procedure TgdcUserDocumentTest.NewTextFile;
var
  f: TextFile;
begin
  AssignFile (f, 'c:\temp\override.txt');
  Rewrite (f);
  CloseFile (f);
end;

function TgdcUserDocumentTest.GetObjectKey(AFullClassName: TgdcFullClassName): Integer;
begin
  Result := -1;
  FQ.Close;
  FQ.SQL.Text :=
    'SELECT * FROM evt_object WHERE UPPER(classname) = :name AND UPPER(subtype) = :subtype';
  FQ.Params[0].AsString := UpperCase(AFullClassName.gdClassName);
  FQ.Params[1].AsString := UpperCase(AFullClassName.SubType);
  FQ.ExecQuery;
  if not FQ.EoF then
    Result := FQ.FieldByName('id').AsInteger;
end;

procedure TgdcUserDocumentTest.AddMethod(AFullClassName: TgdcFullClassName;
  const AMethodName: String);
var
  ObjectKey: Integer;
  gdcFunction: TgdcFunction;
begin
  gdcFunction := TgdcFunction.Create(nil);
  gdcFunction.Open;
  try
    ObjectKey := GetObjectKey(AFullClassName);
    if ObjectKey <> -1 then
      gdcFunction.AddMethodFunction(ObjectKey, AMethodName, AFullClassName);
    gdcFunction.Edit;
    gdcFunction.FieldByName('Script').AsString :=
      RemakeScript(gdcFunction.FieldByName('Script').AsString, AFullClassName, AMethodName);
    gdcFunction.Post;
  finally
    gdcFunction.Free;
  end;
end;

procedure TgdcUserDocumentTest.RemoveMethod(AFullClassName: TgdcFullClassName; const AMethodName: String);
var
  gdcEvent: TgdcEvent;
  gdcFunction: TgdcFunction;
begin
  gdcFunction := TgdcFunction.Create(nil);
  gdcFunction.Open;
  try
    if gdcFunction.Locate('Name',
      AFullClassName.gdClassName + AFullClassName.SubType + AMethodName, [loCaseInsensitive]) then
    begin
      gdcEvent := TgdcEvent.Create(nil);
      try
        gdcEvent.Open;
        if gdcEvent.Locate('Functionkey', gdcFunction.FieldByName('Id').AsInteger, [loCaseInsensitive]) then
          gdcEvent.Delete;
        gdcEvent.Close;
      finally
        gdcEvent.Free;
      end;

      gdcFunction.Delete;
    end
    else
      Check(False, 'Функция не найдена.');

    gdcFunction.Close;
  finally
    gdcFunction.Free;
  end;
end;

procedure TgdcUserDocumentTest.InsertClass(AFullClassName: TgdcFullClassName);
var
  gdcDelphiObject: TgdcDelphiObject;
begin
  gdcDelphiObject := TgdcDelphiObject.Create(nil);
  try
    gdcDelphiObject.AddClass(AFullClassName);
  finally
    gdcDelphiObject.Free;
  end;
end;

procedure TgdcUserDocumentTest.AddDocuments;
var
  gdcUserDocumentType: TgdcUserDocumentType;
  ParentId: integer;
  I: Integer;
  ParentHeaderrelkey: Integer;
  ParentLinerelkey: Integer;
begin
  ParentId := 801000;

  gdcUserDocumentType := TgdcUserDocumentType.Create(nil);
  try
    gdcUserDocumentType.Open;
    gdcUserDocumentType.Insert;
    gdcUserDocumentType.FieldbyName('name').AsString := IntToStr(1000000 + Random(100000));
    gdcUserDocumentType.FieldbyName('parent').AsInteger := ParentId;
    FQ.Close;
    FQ.SQL.Text :=
      'SELECT id FROM at_relations where relationname = ''AC_RECORD''';
    FQ.ExecQuery;
    if not FQ.EoF then
      gdcUserDocumentType.FieldbyName('headerrelkey').AsInteger := FQ.FieldByName('id').AsInteger
    else
      Check(False, 'Не найдена таблица AC_ENTRY.');

    FQ.Close;
    FQ.SQL.Text :=
      'SELECT id FROM at_relations where relationname = ''AC_ENTRY''';
    FQ.ExecQuery;
    if not FQ.EoF then
      gdcUserDocumentType.FieldbyName('linerelkey').AsInteger := FQ.FieldByName('id').AsInteger
    else
      Check(False, 'Не найдена таблица AC_ENTRY.');

    gdcUserDocumentType.Post;

    FDocFullName[0].gdClassName := 'TgdcUserDocument';
    FDocFullName[0].SubType := gdcUserDocumentType.FieldbyName('ruid').AsString;
    FDocId[0] := gdcUserDocumentType.FieldbyName('id').AsInteger;

    for I := 1 to 3 do
    begin
      ParentId := gdcUserDocumentType.FieldbyName('id').AsInteger;
      ParentHeaderrelkey := gdcUserDocumentType.FieldbyName('headerrelkey').AsInteger;
      ParentLinerelkey := gdcUserDocumentType.FieldbyName('linerelkey').AsInteger;
      gdcUserDocumentType.Insert;
      gdcUserDocumentType.FieldbyName('name').AsString := IntToStr(1000000 + Random(100000));
      gdcUserDocumentType.FieldbyName('parent').AsInteger := ParentId;
      gdcUserDocumentType.FieldbyName('headerrelkey').AsInteger := ParentHeaderrelkey;
      gdcUserDocumentType.FieldbyName('linerelkey').AsInteger := ParentLinerelkey;
      gdcUserDocumentType.Post;
      FDocFullName[I].gdClassName := 'TgdcUserDocument';
      FDocFullName[I].SubType := gdcUserDocumentType.FieldbyName('ruid').AsString;
      FDocId[I] := gdcUserDocumentType.FieldbyName('id').AsInteger;
    end;
  finally
    gdcUserDocumentType.Free;
  end;

  InsertClass(FDocFullName[3]);
end;

procedure TgdcUserDocumentTest.RemoveDocuments;
var
  gdcUserDocumentType: TgdcUserDocumentType;
  I: Integer;
begin
  gdcUserDocumentType := TgdcUserDocumentType.Create(nil);
  try
    gdcUserDocumentType.Open;
      for I := 3 downto 0 do
      begin
        if gdcUserDocumentType.Locate('id', FDocId[I], []) then
        begin
          gdcUserDocumentType.Delete;
        end;
      end;
  finally
    gdcUserDocumentType.Free;
  end;
end;

procedure TgdcUserDocumentTest.DoTest;
begin
  AddDocuments;
  TestLVL(0);
  TestLVL(1);
  TestLVL(2);
  TestLVL(3);
  TestAllLVL;
  RemoveDocuments;
end; 

initialization
  RegisterTest('OM', TgdcUserDocumentTest.Suite);
  Randomize;

end.