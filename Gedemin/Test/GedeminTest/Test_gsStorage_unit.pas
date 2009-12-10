
unit Test_gsStorage_unit;

interface

uses
  Classes, TestFrameWork;

type
  TgsStorageTest = class(TTestCase)
  published
    procedure TestLoadFromStream;
    procedure TestStorage;
  end;

implementation

uses
  SysUtils, gsStorage;

type
  TTestRec = record
    FileName: String;
    FC: Integer;
    VC: Integer;
    DataSize: Integer;
  end;

const
  TestCount = 5;
  TestData: array[1..TestCount] of TTestRec = (
   (FileName: 'gs_comp_data.dat';    FC:    7; VC:    3; DataSize:       9),
   (FileName: 'gs_global_data.dat';  FC:  173; VC:  929; DataSize: 2140950),
   (FileName: 'gs_admin_data.dat';   FC: 3008; VC: 4385; DataSize: 1379750),
   (FileName: 'ber_global_data.dat'; FC:  256; VC: 1457; DataSize: 3475475),
   (FileName: 'ber_admin_data.dat';  FC: 1708; VC: 4524; DataSize:  693951)
  );
  TestFolder = 'data';

procedure TgsStorageTest.TestLoadFromStream;

  procedure CountItems(F: TgsStorageFolder; var AFC, AVC: Integer);
  var
    I: Integer;
  begin
    Inc(AFC);
    Inc(AVC, F.ValuesCount);
    for I := 0 to F.FoldersCount - 1 do
      CountItems(F.Folders[I], AFC, AVC);
  end;

var
  S: TgsStorage;
  FS: TFileStream;
  FC, VC: Integer;
  F: TgsStorageFolder;
  I: Integer;
begin
  for I := 1 to TestCount do
  begin
    Check(FileExists(TestFolder + '\' + TestData[I].FileName),
      'Файл "' + TestData[I].FileName + '" с тестовыми данными не найден.');
    FS := TFileStream.Create(TestFolder + '\' + TestData[I].FileName, fmOpenRead);
    try
      S := TgsIBStorage.Create;
      try
        S.LoadFromStream(FS);

        FC := 0;
        VC := 0;
        F := S.OpenFolder('\', False, False);
        try
          CountItems(F, FC, VC);
        finally
          S.CloseFolder(F, False);
        end;

        Check(FC = TestData[I].FC, 'Неверное количество папок в тесте ' + TestData[I].FileName);
        Check(VC = TestData[I].VC, 'Неверное количество значений в тесте ' + TestData[I].FileName);
      finally
        S.Free;
      end;
    finally
      FS.Free;
    end;
  end;
end;

procedure TgsStorageTest.TestStorage;
var
  S: TgsStorage;
  F: TgsStorageFolder;

  procedure CheckValues(const AFolder: String);
  var
    SS: TStringStream;
  begin
    SS := TStringStream.Create('Test');
    try
      S.WriteString(AFolder, 'String', 'String');
      S.WriteInteger(AFolder, 'Integer', -1);
      S.WriteCurrency(AFolder, 'Currency', 5.1892);
      S.WriteBoolean(AFolder, 'Boolean', True);
      S.WriteDateTime(AFolder, 'DateTime', EncodeDate(2800, 12, 12));
      S.WriteStream(AFolder, 'Stream', SS);

      Check(S.ReadString(AFolder, 'String', AFolder) = 'String');
      Check(S.ReadInteger(AFolder, 'Integer', 0) = -1);
      Check(S.ReadCurrency(AFolder, 'Currency', 0) = 5.1892);
      Check(S.ReadBoolean(AFolder, 'Boolean', False) = True);
      Check(S.ReadDateTime(AFolder, 'DateTime', 0) = EncodeDate(2800, 12, 12));
      S.ReadStream(AFolder, 'Stream', SS);
      Check(SS.DataString = 'Test');
    finally
      SS.Free;
    end;
  end;

begin
  S := TgsStorage.Create;
  try
    F := S.OpenFolder('');
    try
      Check((F.FoldersCount = 0) and (F.ValuesCount = 0));

      CheckValues('');
      CheckValues('Folder');
      CheckValues('FolderA\FolderB\FolderC');

      Check(F.OpenFolder('FolderA\FolderB\FolderC', False).ValuesCount = 6);
      Check(F.OpenFolder('FolderA\FolderB', False).ValuesCount = 0);
      Check(F.OpenFolder('FolderA\FolderB', False).FoldersCount = 1);
      F.OpenFolder('FolderA\FolderB\FolderC', False).Drop;
      Check(F.OpenFolder('FolderA\FolderB', False).FoldersCount = 0);
      F.OpenFolder('FolderA', False).DeleteFolder('FolderB');
      Check(F.OpenFolder('FolderA', False).FoldersCount = 0);
      F.OpenFolder('Folder', False).DeleteValue('String');
      Check(F.OpenFolder('Folder', False).ValuesCount = 5);

      S.Clear;
      Check((F.FoldersCount = 0) and (F.ValuesCount = 0));
    finally
      S.CloseFolder(F);
    end;
  finally
    S.Free;
  end;
end;

initialization
  RegisterTest('', TgsStorageTest.Suite);
end.
