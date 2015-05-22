unit gdcFile;

interface
uses
  gdcBase, gdcTree, Classes, gdcBaseInterface, IBSQL,
  gd_createable_form, Sysutils, Windows, Forms, DB, FileCtrl,
  Controls;

type
  {���, ������������ �������� ��� ������������� ������}
  {��� ����������� �����:
   flAsk - ���������� � ������������
   flRewriteToDisk - �������������� ���� �� �����
   flRewriteToBase - �������������� ������ � ����}

  TflAction = (flAsk, flRewriteToDisk, flRewriteToBase);

  {������� ����� ��� ������ �� ���������� �������/�������, ��������
   ����� �������� ��� ���������� ����������}
  TgdcBaseFile = class(TgdcLBRBTree)
  private
    FibsqlFullPath: TIBSQL;

    function GetRootDirectory: String;
    procedure SetRootDirectory(const Value: String);

    function GetLength: Integer;
    function GetFullPath: String;

  protected
    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

    {������������� �� ����������� ���� �������� � ���������� ID.
     ���� AnID = -1, �� ���������������� ��� ����� � �����.
     ���� AnID > 0, �� ������ � ����� AnID �� ������, �� ����� �������� ����������}
    procedure SyncByPath(const Path: String; const AnID: Integer;
      Action: TflAction = flAsk); virtual;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    function CheckTheSameStatement: String; override;  
    function GetCurrRecordClass: TgdcFullClass; override;

    //��������� ������������ ������� ����� ����� (�������� �� ���������� ������� � �� �����)
    function CheckFileName: Boolean;

    {����� ������������� ����� ������� ���� � ��������� (�����������) ������� � ������� �� �����.
    ����� ������ ��������� ����� (��� ��� ����� � ���������� �������), ���� ��� �� ���������� ��
    �����, ��� ���������� ������������ �������� ���������� (���� data)  ���� � ����, ���� �� �����.
    ���� ������� �������� '' ( -1), �� ���������������� ��� �����. � �������� ������ -
    ���������� ����.
    ��������� ����������� ����� ����� ������ 2-�� ���������:
     -	��������� ����� �� ����� ��� ������ ���������� ���������
     -	��������� ����������� � ���� ������ ��� ������ ����������� ���������
     (���������� ����� EditDialog)
     �� ��������� (���� �� ������ ����� ChooseLocation) ����� �������������� �����,
     ��������� ���� GetFullPath.}
    // AFileName  - ���� + ��� ����� � ����
    {���������� True, ���� ������������� ������ ���������}
    function Synchronize(const AFileName: String = '';
      const ChooseLocation: Boolean = False;
      Action: TflAction = flAsk): Boolean; overload;
    function Synchronize(const AnID: Integer = -1;
      const ChooseLocation: Boolean = False;
      Action: TflAction = flAsk): Boolean; overload;

    //���������� ������ ���� � ������� ����� (�����) ��� ��������
    property FullPath: String read GetFullPath;
    {����� ������� ������ �������� �����, ������� ����� ��������� "����" ����� � �����.
    ���� ��������� ��������� �������� ������� ��, �� ��� �����������, ��� �� �� ����� ������.
    ������� ������ (���� � �������� �����) ������ ���� ����� �������� � �������� � GlobalStorage.
    �� ��������� �� �������� ����� ����� �����, � ������� ����� ����������� ���� (gedemin.exe).}
    property RootDirectory: String read GetRootDirectory write SetRootDirectory;
    {���������� ����� ������� ����� ����� (� �������� ������).
     !!! ����� ����� ������ ����������� �� ����� ����� �����, �������� �� (255 +  3 �� ���� '�:\').}
    property Length: Integer read GetLength;

    {������� ������ ����� �� ������� ������������ (��� ��������� ��������)}
    function Find(const AFileName: String): Integer;

    //���������� ���� �� �����(������������) � ��������� id
    //���� ����� ����������� ����� ������ id ���, �������� ����������
    function GetPathToFolder(AFolderID: Integer): String;

  end;

  {����� ��� ������ ��������������� � �������}
  TgdcFile = class(TgdcBaseFile)
  protected
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure SyncByPath(const Path: String; const AnID: Integer;
      Action: TflAction = flAsk); override;

    procedure SaveToStreamFromField(S: TStream; Fld: TField);
    procedure SaveToFieldFromStream(S: TStream; Fld: TField);

  public
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    {���������� ����������� �� ����� � ������� ������. ������ ������ ���������
     � ��������� �������������� ��� �������}
    procedure LoadDataFromFile(AfileName: String);
    procedure LoadDataFromStream(const Stream: TStream);
    {���������� ����������� (���� data) ������� ������ �� ����. }
    procedure SaveDataToFile(AfileName: String);
    {���������� ����������� (���� data) � ����� }
    procedure SaveDataToStream(const AStream: TStream);
    {��������� ���� �� ��������
     NeedExit - ���������, ��� ������������ ����� ������ ������� ����, ����� ���������� ������ ������
     NeedSave - ���������, ��� ����� ��������� ����� ��� ����� ��������� � ����
     �������� ������ � NeedExit}
    procedure ViewFile(const NeedExit: Boolean = True; const NeedSave: Boolean = True);
    {���������� ����, �� �������� ����� ������ ���� ��� ��������� ����������� ��}
    function GetViewFilePath: String;
    {��������� �� ������������ ���������� ���� � �����}
    function TheSame(const AFileName: String): Boolean;
  end;

  {����� ��� ������ � �������}
  TgdcFileFolder = class(TgdcBaseFile)
  protected
    procedure _DoOnNewRecord; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure SyncByPath(const Path: String; const AnID: Integer;
      Action: TflAction = flAsk); override;

  public
    class function GetRestrictCondition(const ATableName, ASubType: String): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    function FolderSize: Integer;
  end;

procedure Register;

implementation

uses
  gd_ClassList, gdc_dlgFileFolder_unit, gdc_dlgFile_unit, gdc_frmFile_unit,
  Storages, ShellAPI, gd_directories_const, gdc_dlgPath_unit,
  ZLib, jclMath, IBCustomDataSet, msg_attachment, gd_GlobalParams_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

var
  FRootDirectory: String;

const
 //������������ ����� ����� �����: 255 + 3 ������� �� ����
  cst_MaxLength = 258;
//������ ������������ ��� ������������� � ����� ����� ��������
  cst_arr_IncorrectSymbols: array[0..7] of Char = ('\', '/', ':', '*', '?', '"', '<', '>');

procedure Register;
begin
  RegisterComponents('gdcFile', [TgdcBaseFile, TgdcFile, TgdcFileFolder]);
end;

function GetFileCRC(const AFileName: String): Integer;
var
  Str: TFileStream;
  ArBt: array of Byte;
begin
  if not(FileExists(AFileName)) then
    raise Exception.Create('���� ' + AFileName + ' �� ������!');

  { TODO : � ���� ���� ����� �������? }
  Str := TFileStream.Create(AFileName, fmOpenRead);
  try
    SetLength(ArBt, Str.Size);
    Str.Position := 0;
    if Str.Size > 0 then
      Str.Read(ArBt[0], Str.Size);
    Result := Integer(Crc32(ArBt, Length(ArBt)));
  finally
    Str.Free;
  end;
end;

function GetStreamCRC(const Stream: TStream): Integer;
var
  ArBt: array of Byte;
begin
  SetLength(ArBt, Stream.Size);
  Stream.Position := 0;
  if Stream.Size > 0 then
    Stream.Read(ArBt[0], Stream.Size);
  Result := Integer(Crc32(ArBt, Length(ArBt)));
end;

{ TgdcBaseFile }

function TgdcBaseFile.CheckFileName: Boolean;
var
  I: Integer;
begin
  if Length > cst_MaxLength then
    raise Exception.Create('����� ����� ����� ��������� ����������!');
  for I := 0 to System.Length(cst_arr_IncorrectSymbols) - 1 do
  begin
    if AnsiPos(cst_arr_IncorrectSymbols[I], FieldByName('name').AsString) > 0 then
      raise Exception.Create('��� ����� �������� ������������ �������: ' +
        cst_arr_IncorrectSymbols[I] + '!');
  end;
  Result := True;
end;

constructor TgdcBaseFile.Create(AnOwner: TComponent);
begin
  inherited;
end;

destructor TgdcBaseFile.Destroy;
begin
  if Assigned(FibsqlFullPath) then
    FreeAndNil(FibsqlFullPath);
  inherited;
end;

function TgdcBaseFile.Find(const AFileName: String): Integer;
var
  S, FN: String;
  ibsql: TIBSQL;
  ParentKey: Integer;

begin
  Result := -1;
  if AFileName = '' then Exit;

  S := AnsiUpperCase(AFileName);
  ParentKey := -1;
  ibsql := CreateReadIBSQL;
  try
    if Transaction.InTransaction and (Transaction <> ReadTransaction) then
      ibsql.Transaction := Transaction;

    while S > '' do
    begin
      ibsql.Close;
      if ParentKey = -1 then
        ibsql.SQL.Text := 'SELECT * FROM gd_file WHERE parent IS NULL and UPPER(name) = :name '
      else
      begin
        ibsql.SQL.Text := 'SELECT * FROM gd_file WHERE parent = :parent and UPPER(name) = :name ';
        ibsql.ParamByName('parent').AsInteger := ParentKey;
      end;

      ibsql.ParamByName('name').AsString := FN;
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        Result := -1;
        Exit;
      end;

      Result := ibsql.FieldByName('id').AsInteger;
    end;
  finally
    ibsql.Free;
  end;
end;

function TgdcBaseFile.GetCurrRecordClass: TgdcFullClass;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := SubType;

  if FieldByName('filetype').AsString = 'D' then
    Result.gdClass := TgdcFileFolder
  else if FieldByName('filetype').AsString = 'F' then
    Result.gdClass := TgdcFile;

  FindInheritedSubType(Result);
end;

function TgdcBaseFile.GetFullPath: String;
begin
  if (RecordCount = 0) and (State <> dsInsert) then
    raise Exception.Create('�� ������� ������ ������� ' + Self.ClassName + '!');

  if not Assigned(FibsqlFullPath) then
  begin
    FibsqlFullPath := TIBSQL.Create(Self);
    FibsqlFullPath.Transaction := gdcBaseManager.ReadTransaction;
    FibsqlFullPath.SQL.Text := 'SELECT f.* FROM gd_file f ' +
      ' JOIN gd_file f1 ON f.lb <= f1.lb and f.rb >= f1.rb  ' +
      ' WHERE f1.id = :id ' +
      ' ORDER BY f.lb ASC, f.rb DESC';
    FibsqlFullPath.Prepare;
  end;

  FibsqlFullPath.Close;
  FibsqlFullPath.ParamByName('id').AsInteger := FieldByName('parent').AsInteger;
  FibsqlFullPath.ExecQuery;

  Result := '';
  while not FibsqlFullPath.Eof do
  begin
    if Result > '' then
      Result :=  Result + '\';
    Result := Result + FibsqlFullPath.FieldByName('name').AsString;
    FibsqlFullPath.Next
  end;
  if Result > '' then
    Result :=  Result + '\';
  Result := Result + FieldByName('name').AsString;
end;

function TgdcBaseFile.GetLength: Integer;
begin
  Result := System.Length(RootDirectory + FullPath);
end;

class function TgdcBaseFile.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcBaseFile.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'gd_file';
end;

function TgdcBaseFile.GetRootDirectory: String;
var
  CompName: array[0..255] of Char;
  J: DWord;
begin
  if FRootDirectory = '' then
  begin
    J := MAX_COMPUTERNAME_LENGTH + 1;
    GetComputerName(CompName, J);

    if Assigned(GlobalStorage) then
      FRootDirectory := GlobalStorage.ReadString('Options\TgdcBaseFile\RootDirectory',
        String(CompName),
        ExtractFilePath(Application.ExeName))
    else
      FRootDirectory := ExtractFilePath(Application.ExeName);
  end;
  if FRootDirectory[System.Length(FRootDirectory)] <> '\' then
    FRootDirectory := FRootDirectory + '\';
  Result := FRootDirectory;
end;

class function TgdcBaseFile.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmFile';
end;

class function TgdcBaseFile.NeedModifyFromStream(
  const SubType: String): Boolean;
begin
  Result := True;
end;

procedure TgdcBaseFile.SetRootDirectory(const Value: String);
var
  CompName: array[0..255] of Char;
  J: DWord;
begin
  if FRootDirectory <> Value then
  begin
    FRootDirectory := Value;
    if FRootDirectory[System.Length(FRootDirectory)] <> '\' then
      FRootDirectory := FRootDirectory + '\';

    J := MAX_COMPUTERNAME_LENGTH + 1;
    GetComputerName(CompName, J);

    if Assigned(GlobalStorage) then
      GlobalStorage.WriteString('Options\TgdcBaseFile\RootDirectory',
        String(CompName),
        FRootDirectory);
  end;
end;

function TgdcBaseFile.Synchronize(const AFileName: String;
  const ChooseLocation: Boolean; Action: TflAction): Boolean;
var
  AnID: Integer;
begin
  if AFileName > '' then
  begin
    AnID := Find(AFileName);
    if AnID = -1 then
      raise Exception.Create(Self.GetDisplayName(Self.SubType) + ' � ������������� ' +
        AFileName + ' �� ������(�)!');
  end else
    AnID := -1;

  Result := Synchronize(AnID, ChooseLocation);
end;

procedure TgdcBaseFile.SyncByPath(const Path: String; const AnID: Integer;
  Action: TflAction);
var
  S: String;
  ibsql: TIBSQL;
  ObjFile: TgdcFile;
  ObjFolder: TgdcFileFolder;
  AnAnswer: Integer;
begin
  if not DirectoryExists(Path) then
    if not CreateDir(Path) then
      raise Exception.Create('������ ��� �������� ���������� ' + Path + '!');

  {�� ����� ������� ������ ������������ �������� ������������� ���� ������ � �����}

  if AnID = -1 then
  begin
    ibsql := TIBSQL.Create(Self);
    ObjFile := TgdcFile.CreateSubType(Self, '', 'ByID');
    ObjFolder := TgdcFileFolder.CreateSubType(Self, '', 'ByID');
    try
      ObjFile.Open;
      ObjFolder.Open;

      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text := 'SELECT * FROM gd_file ORDER BY lb ASC, rb DESC';
      ibsql.ExecQuery;

      while not ibsql.Eof do
      begin
        if ibsql.FieldByName('filetype').AsString = 'F' then
        begin
          ObjFile.ID := ibsql.FieldByName('id').AsInteger;
          if ObjFile.RecordCount > 0 then
          begin
            S := Path + ObjFile.FullPath;
          //���� ��� ����, �� ��������� ����� ���
            if FileExists(S) then
            begin
              if not ObjFile.TheSame(S) then
              begin
                Case Action of
                  flAsk: AnAnswer := MessageBox(ParentHandle, PChar('���� ' + S + ' ��� ����������!'#13#10 +
                    '�� ������:'#13#10 +
                    'c�������� ���������� ���� �� ���� (��), '#13#10 +
                    '��������� ���������� ����� � ���� (���),'#13#10 +
                    '���������� ���� (������)'), '��������',
                    MB_YESNOCANCEL or MB_ICONEXCLAMATION or MB_TASKMODAL);
                  flRewriteToDisk: AnAnswer := IDYES;
                  flRewriteToBase: AnAnswer := IDNO
                  else
                    AnAnswer := IDCANCEL;
                End;
                Case AnAnswer of
                  IDYES: ObjFile.SaveDataToFile(S);
                  IDNO:
                  begin
                    ObjFile.Edit;
                    try
                      ObjFile.LoadDataFromFile(S);
                      ObjFile.Post;
                    except
                      ObjFile.Cancel;
                      raise;
                    end;
                  end;
                end;
              end;

            end else
              ObjFile.SaveDataToFile(S);
          end;
        end else
        //���� ��� ���������� ...
        begin
          ObjFolder.ID := ibsql.FieldByName('id').AsInteger;
          if ObjFolder.RecordCount > 0 then
          begin
            S := Path + ObjFolder.FullPath;

            if not DirectoryExists(S) then
              if not CreateDir(S) then
                raise Exception.Create('������ ��� �������� ���������� ' + S + '!');

          end;
        end;
        ibsql.Next;
      end;
    finally
      ibsql.Free;
      ObjFile.Free;
      ObjFolder.Free;
    end;
    CloseOpen;
  end;
end;

function TgdcBaseFile.Synchronize(const AnID: Integer;
  const ChooseLocation: Boolean; Action: TflAction): Boolean;
var
  Path: String;
  Obj: TgdcBaseFile;
  dlgPath: Tgdc_dlgPath;
begin
  Result := False;
  if AnID > 0 then
  begin
    Obj := TgdcBaseFile.CreateSubType(Self, '', 'ByID');
    try
      Obj.ID := AnID;
      Obj.Open;
      if Obj.RecordCount = 0 then
      begin
        raise Exception.Create(Self.GetDisplayName(Self.SubType) + ': ������� ������������ ���� = ' +
          IntToStr(AnID) + '!');
      end;

      Path := ExtractFilePath(RootDirectory + FullPath);

    finally
      Obj.Free;
    end;
  end else
    Path := RootDirectory;

  if ChooseLocation then
  begin
    dlgPath := Tgdc_dlgPath.Create(Self);
    try
      dlgPath.edFullPath.Text := FieldByName('name').AsString;
      dlgPath.edPath.Text := RootDirectory;
      if dlgPath.ShowModal = mrOk then
        Path := dlgPath.edPath.Text
      else
      begin
        MessageBox(ParentHandle, '�������� ������������� ���� ��������!',
          '��������!', MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        Exit;
      end;
    finally
      dlgPath.Free;
    end;
  end;

  if (Path > '') and (Path[System.Length(Path)] <> '\') then
    Path :=  Path + '\';

  SyncByPath(Path, AnID, Action);

  Refresh;
  Result := True;
end;

procedure TgdcBaseFile._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEFILE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEFILE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEFILE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEFILE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEFILE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('datasize').AsInteger := 0;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEFILE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEFILE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseFile.GetPathToFolder(AFolderID: Integer): String;
var
  ibsql: TIBSQL;
  Lb, Rb: Integer;
begin
  if (RecordCount = 0) and (State <> dsInsert) then
    raise Exception.Create('�� ������� ������ ������� ' + Self.ClassName + '!');

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_file WHERE id = :id AND filetype = ''D''';
    ibsql.ParamByName('id').AsInteger := AFolderID;
    ibsql.ExecQuery;

    if ibsql.RecordCount = 0 then
    begin
      raise Exception.Create('����� � id = ' + IntToStr(AFolderID) + ' �� �������!');
    end;

    //���� ��� ����� - �� ����, �� �������
    if (ID = AFolderID) and (Self.ClassType = TgdcFileFolder) then
    begin
      Result := FieldByName('name').AsString;
      Exit;
    end;

    Lb := ibsql.FieldByName('lb').AsInteger;
    Rb := ibsql.FieldByName('rb').AsInteger;

    ibsql.Close;
    ibsql.SQL.Text := 'SELECT f.* FROM gd_file f ' +
      ' JOIN gd_file f1 ON f.lb <= f1.lb and f.rb >= f1.rb  ' +
      ' WHERE f1.id = :id ' +
      ' AND f.lb >= :lb AND f.rb <= :rb ' +
      ' ORDER BY f.lb ASC, f.rb DESC';

    ibsql.Close;
    ibsql.ParamByName('id').AsInteger := FieldByName('parent').AsInteger;
    ibsql.ParamByName('lb').AsInteger := Lb;
    ibsql.ParamByName('rb').AsInteger := Rb;
    ibsql.ExecQuery;

    if ibsql.RecordCount = 0 then
      raise Exception.Create('����� � id = ' + IntToStr(AFolderID) +
        ' �� �������� � ���� ���� ' + GetListField(SubType));

    Result := '';
    while not ibsql.Eof do
    begin
      if Result > '' then
        Result :=  Result + '\';
      Result := Result + ibsql.FieldByName('name').AsString;
      ibsql.Next
    end;
    if Result > '' then
      Result :=  Result + '\';
    Result := Result + FieldByName('name').AsString;
  finally
    ibsql.Free;
  end;
end;

function TgdcBaseFile.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCBASEFILE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEFILE', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEFILE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEFILE',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('��� ������ ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' ������ ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  '�� ������� ��������� �� ��������� ���');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEFILE' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result :=
      'SELECT id FROM gd_file WHERE UPPER(name)=UPPER(:name) AND parent IS NOT DISTINCT FROM :parent'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
  begin
    if FieldByName('parent').IsNull then
      Result := Format('SELECT id FROM gd_file WHERE UPPER(name)=UPPER(''%s'') AND parent IS NULL',
        [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll])])
    else
      Result := Format('SELECT id FROM gd_file WHERE UPPER(name)=UPPER(''%s'') AND parent = %d',
        [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]),
         FieldByName('parent').AsInteger]);
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEFILE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEFILE', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcBaseFile.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEFILE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEFILE', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEFILE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEFILE',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEFILE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  CheckFileName;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEFILE', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEFILE', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

{ TgdcFileFolder }

procedure TgdcFileFolder._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCFILEFOLDER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFILEFOLDER', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFILEFOLDER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFILEFOLDER',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFILEFOLDER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('filetype').AsString := 'D';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFILEFOLDER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFILEFOLDER', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcFileFolder.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(GetRestrictCondition('', ''));
end;

class function TgdcFileFolder.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.filetype = ''D''';
end;

function TgdcFileFolder.FolderSize: Integer;
var
  ibsql: TIBSQL;

begin
  ibsql := CreateReadIBSQL;
  try
    if (Transaction.InTransaction) and (Transaction <> ReadTransaction) then
      ibsql.Transaction := Transaction;

    ibsql.SQL.Text := 'SELECT SUM(datasize) as datasize FROM gd_file WHERE datasize IS NOT NULL and parent = :parent';
    ibsql.ParamByName('parent').AsInteger := ID;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      Result := ibsql.FieldByName('datasize').AsInteger
    else
      Result := 0;
  finally
    ibsql.Free;
  end;
end;

procedure TgdcFileFolder.SyncByPath(const Path: String;
  const AnID: Integer; Action: TflAction);
var
  S: String;
  ObjFile: TgdcFile;
  ObjFolder: TgdcFileFolder;
  ibsql: TIBSQL;
  AnAnswer: Integer;
begin
  {�� ����� ������� ������ ������������ �������� ������������� ���� ������ � �����}
  if AnID = -1 then
  begin
    inherited;
  end else
  {���� ������� ���������� �����, �� �������� ������������� ������ ���� ����� �� ����� ���������� ��������}
  begin
    ibsql := TIBSQL.Create(Self);
    ObjFile := TgdcFile.CreateSubType(Self, '', 'ByID');
    ObjFolder := TgdcFileFolder.CreateSubType(Self, '', 'ByID');
    try
      ObjFile.Open;
      ObjFolder.Open;
      ObjFolder.ID := AnID;

      if ObjFolder.RecordCount > 0 then
      begin
        ibsql.Transaction := gdcBaseManager.ReadTransaction;
        ibsql.SQL.Text := 'SELECT * FROM gd_file WHERE lb >= :lb AND rb <= :rb ORDER BY lb ASC, rb DESC';
        ibsql.ParamByName('lb').AsInteger := ObjFolder.FieldByName('lb').AsInteger;
        ibsql.ParamByName('rb').AsInteger := ObjFolder.FieldByName('rb').AsInteger;
        ibsql.ExecQuery;

        while not ibsql.Eof do
        begin
          if ibsql.FieldByName('filetype').AsString = 'F' then
          begin
            ObjFile.ID := ibsql.FieldByName('id').AsInteger;
            if ObjFile.RecordCount > 0 then
            begin
              S := Path + ObjFile.GetPathToFolder(AnID);
              //���� ��� ����, �� ��������� ����� ���
              if FileExists(S) then
              begin
                if not ObjFile.TheSame(S) then
                begin
                  AnAnswer := MessageBox(ParentHandle, PChar('���� ' + S + ' ��� ����������!'#13#10 +
                    '�� ������:'#13#10 +
                    'c�������� ���������� ���� �� ���� (��), '#13#10 +
                    '��������� ���������� ����� � ���� (���),'#13#10 +
                    '���������� ���� (������)'), '��������',
                    MB_YESNOCANCEL or MB_ICONEXCLAMATION or MB_TASKMODAL);
                  Case AnAnswer of
                    IDYES: ObjFile.SaveDataToFile(S);
                    IDNO:
                    begin
                      ObjFile.Edit;
                      try
                        ObjFile.LoadDataFromFile(S);
                        ObjFile.Post;
                      except
                        ObjFile.Cancel;
                        raise;
                      end;
                    end;
                  end;
                end;
              end else
                ObjFile.SaveDataToFile(S);
            end;
          end else
          //���� ��� ���������� ...
          begin
            ObjFolder.ID := ibsql.FieldByName('id').AsInteger;
            if ObjFolder.RecordCount > 0 then
            begin
              S := Path + ObjFolder.GetPathToFolder(AnID);

              if not DirectoryExists(S) then
                if not CreateDir(S) then
                  raise Exception.Create('������ ��� �������� ���������� ' + S + '!');

            end;
          end;
          ibsql.Next;
        end;
      end;
    finally
      ibsql.Free;
      ObjFile.Free;
      ObjFolder.Free;
    end;
  end;
end;

class function TgdcFileFolder.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgFileFolder';
end;

{ TgdcFile }

procedure TgdcFile.LoadDataFromFile(AfileName: String);
var
  F: TSearchRec;
  AnAnswer: Integer;
  FS: TFileStream;
begin
  if FileExists(AFileName) then
  begin
    if not (State in dsEditModes) then
      raise Exception.Create('������ ������ ���������� � ������ ������� ��� ��������������!');
    SysUtils.FindFirst(AFileName, faAnyFile, F);
    FieldByName('datasize').AsInteger := F.Size;
    FieldByName('crc').AsInteger := GetFileCrc(AFileName);

    if Trim(FieldByName('name').AsString) = '' then
      FieldByName('name').AsString := F.Name
    else if AnsiCompareText(F.Name, FieldByName('name').AsString) <> 0 then
    begin
      AnAnswer := MessageBox(Self.ParentHandle, '��� ������������ ����� ������� �� ���������� �����.' +
        ' ��������������� ������������ ����� � ����?', '��������',
        MB_YESNOCANCEL or MB_ICONQUESTION or MB_TASKMODAL);
      case AnAnswer of
      IDYES:
        FieldByName('name').AsString := F.Name;
      IDCANCEL:
        Exit;
      end
    end;

    FS := TFileStream.Create(AFileName, fmOpenRead);
    try
      SaveToFieldFromStream(FS, FieldByName('data'));
    finally
      FS.Free;
    end;

    FieldByName('filetype').AsString := 'F';
  end;
end;


procedure TgdcFile.ViewFile(const NeedExit: Boolean = True; const NeedSave: Boolean = True);
const
  Asked: Boolean = False;
var
  Directory: array[0..254] of Char;
  Operation: array[0..4] of Char;
  FS: TStream;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  R: Cardinal;
  AppSt: array[0..1023] of Char;
  AnAnswer: Integer;
  WasBrowse: Boolean;
  S, FileName: String;
begin
  Assert((State = dsInsert) or (RecordCount > 0));

  FileName := GetViewFilePath;
  FS := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStreamFromField(FS, FieldByName('data'));
  finally
    FS.Free;
  end;

  StrPCopy(Directory, ExtractFilePath(FileName));
  StrPCopy(AppSt, '');

  S := gd_GlobalParams.GetExternalEditor(
    System.Copy(ExtractFileExt(FileName), 2, 256));

  if S = '' then
  begin
    FindExecutable(PChar(FileName), Directory , AppSt);

    if AppSt = '' then
    begin
      if MessageBox(ParentHandle,
        '� ������� ���������� ���� �� ������� �� ������ ����������.'#13#10 +
        '������������ ������� (notepad.exe) ��� ���������?',
        '��������',
        MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
      begin
        exit;
      end else
      begin
        AppSt := 'notepad.exe';
      end;
    end else
      StrPCopy(AppSt, PChar('"' + String(AppSt) + '"'));
  end else
    StrPCopy(AppSt, S);

  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);

  FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWDEFAULT;

  StrCat(AppSt, PChar(' "' + FileName + '"'));

  if not Asked then
  begin
    if NeedExit then
    begin
      MessageBox(ParentHandle,
        '��� ���� ����� ���������� �������� � ���������, �������� ���� ����� ���������.',
        '�������� �����',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    end;
    Asked := True;
  end;

  try
    if not CreateProcess(nil, AppSt, nil, nil, False,
      NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then
    begin
      StrPCopy(Operation, 'open');
      {���������� ������� ����� ShellExecute.
       ������� FindExecuteable ����������� ������������ ������, ���� � ��� ���� �������,
       � ��� ���� ��� �� ��������� � �������}
      if ShellExecute(ParentHandle, Operation, @FileName[1], nil, Directory, SW_SHOW) <= 32 then
      begin
        MessageBox(ParentHandle,
          PChar(Format('���������� ������� ���� %s.', [FileName])),
          '��������', MB_OK or MB_ICONEXCLAMATION);
      end else
      begin
        MessageBox(ParentHandle,
          PChar(Format('��� ���������, ��������� � ����� %s, �� ����� ��������� � ����!', [FileName])),
          '��������', MB_OK or MB_ICONEXCLAMATION);
      end;
    end else

    if NeedExit then
    begin
      Application.Minimize;
      Application.ProcessMessages;

      if Application.Terminated then
        exit;

      while GetExitCodeProcess(ProcessInfo.hProcess,R)
        and (R = STILL_ACTIVE) do
      begin
        Sleep(700);
      end;
      Application.Restore;

      if NeedSave and FileExists(FileName)
        and (not TheSame(FileName)) then
      begin
        AnAnswer := MessageBox(ParentHandle,
          '�� ��������� ���� �� ��������. ' +
          ' ������ ��������� ��������� � ���� ��������� � ���� ������? ',
          '��������',
          MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL);
        if AnAnswer = IDYES then
        begin
          WasBrowse := not (State in dsEditModes);
          if WasBrowse then
            Edit;
          LoadDataFromFile(FileName);
          if WasBrowse then
            Post;
        end;

        if FileExists(FileName) then
        begin
          try
            SysUtils.DeleteFile(FileName);
          except
          end;
        end;
      end;
    end;
  finally
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;

procedure TgdcFile.SaveDataToFile(AfileName: String);
var
  S: String;
  FS: TStream;
begin
  S := ExtractFilePath(AFileName);
  if not DirectoryExists(S) then
    if not CreateDir(S) then
      raise Exception.Create('������ ��� �������� ���������� ' + S);

  FS := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStreamFromField(FS, FieldByName('data'));
  finally
    FS.Free;
  end;
end;

procedure TgdcFile._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCFILE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCFILE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCFILE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCFILE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCFILE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
  FieldByName('filetype').AsString := 'F';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCFILE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCFILE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcFile.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(GetRestrictCondition('', ''));
end;

class function TgdcFile.GetRestrictCondition(const ATableName,
  ASubType: String): String;
begin
  Result := 'z.filetype = ''F''';
end;

function TgdcFile.GetViewFilePath: String;
var
  Ch: array[0..1024] of Char;
begin
  GetTempPath(1024, Ch);
  Result := IncludeTrailingBackSlash(Ch) + FieldByName('name').AsString;
end;

procedure TgdcFile.SyncByPath(const Path: String; const AnID: Integer;
  Action: TflAction);
var
  S: String;
  Obj: TgdcFile;
  AnAnswer: Integer;
begin
  {�� ����� ������� ������ ������������ �������� ������������� ���� ������ � �����}
  if AnID = -1 then
  begin
    inherited;
  end else
  begin
    Obj := TgdcFile.CreateSubType(Self, '', 'ByID');
    try
      Obj.Open;
      Obj.ID := AnID;
      if Obj.RecordCount > 0 then
      begin
        S := Path;
        if S[System.Length(S)] <> '\' then
          S := S + '\';
        S := S + Obj.FieldByName('name').AsString;
        //���� ��� ����, �� ��������� ����� ���
        if FileExists(S) then
        begin
          if not Obj.TheSame(S) then
          begin
            Case Action of
              flAsk: AnAnswer := MessageBox(ParentHandle, PChar('���� ' + S + ' ��� ����������!'#13#10 +
                '�� ������:'#13#10 +
                'c�������� ���������� ���� �� ���� (��), '#13#10 +
                '��������� ���������� ����� � ���� (���),'#13#10 +
                '���������� ���� (������)'), '��������',
                MB_YESNOCANCEL or MB_ICONEXCLAMATION or MB_TASKMODAL);
              flRewriteToDisk: AnAnswer := IDYES;
              flRewriteToBase: AnAnswer := IDNO
              else
                AnAnswer := IDCANCEL;
            End;
            
            Case AnAnswer of
              IDYES: Obj.SaveDataToFile(S);
              IDNO:
              begin
                Obj.Edit;
                try
                  Obj.LoadDataFromFile(S);
                  Obj.Post;
                except
                  Obj.Cancel;
                end;
              end;
            End;
          end;
        end else
          Obj.SaveDataToFile(S);
      end;
    finally
      Obj.Free;
    end;
  end;
end;

function TgdcFile.TheSame(const AFileName: String): Boolean;
var
  F: TSearchRec;
begin
  Result := False;
  if FileExists(AFileName) then
  begin
    if SysUtils.FindFirst(AFileName, faAnyFile, F) = 0 then
    begin
      try
        Result := (FieldByName('datasize').AsInteger = F.Size) and
          (FieldByName('crc').AsInteger = GetFileCrc(AFileName));
      except
        if sView in BaseState then
        begin
          MessageBox(ParentHandle,
            '�� ������� ������� ����. ��������, �� ������������ ������ �����������.',
            '��������',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        end;
        Result := True;
      end;
      SysUtils.FindClose(F);
    end;
  end;
end;

procedure TgdcFile.SaveDataToStream(const AStream: TStream);
begin
  SaveToStreamFromField(AStream, FieldByName('data'));
end;

procedure TgdcFile.LoadDataFromStream(const Stream: TStream);
begin
  if not (State in dsEditModes) then
    raise Exception.Create('������ ������ ���������� � ������ ������� ��� ��������������!');

  SaveToFieldFromStream(Stream, FieldByName('data'));
  FieldByName('datasize').AsInteger := Stream.Size;
  FieldByName('crc').AsInteger := GetStreamCrc(Stream);
end;

procedure TgdcFile.SaveToStreamFromField(S: TStream; Fld: TField);
var
  BS: TStream;
  DS: TZDecompressionStream;
  H: TAttachmentHeader;
  Buff: array[0..1023] of Char;
  I: Integer;
begin
  if S = nil then
    raise Exception.Create('�� ������� �����!');

  if Fld.DataType <> ftBlob then
    raise Exception.Create('�������� ���� ������������� ����!');

  BS := CreateBlobStream(Fld, bmRead);
  try
    if (BS.Read(H, SizeOf(H)) <> SizeOf(H)) or (H.Signature <> attSignature) or
      (H.Version <> attVersion) then
    begin
      // ��� ������ ������, � ��� ��� ��������� � ��� �� ���������
      S.CopyFrom(BS, 0);
    end else
    begin
      DS := TZDecompressionStream.Create(BS);
      try
        repeat
          I := DS.Read(Buff, 1024);
          if I > 0 then
            S.Write(Buff, I);
        until (I = 0);
      finally
        DS.Free;
      end;
    end;
  finally
    BS.Free;
  end;
end;

procedure TgdcFile.SaveToFieldFromStream(S: TStream; Fld: TField);
var
  CS: TZCompressionStream;
  SSH, SSD: TStringStream;
  H: TAttachmentHeader;
  I: Integer;
  Buf: array[1..1024] of Byte;
  BS: TStream;
begin
  if S = nil then
    raise Exception.Create('�� ������� �����!');

  if Fld.DataType <> ftBlob then
    raise Exception.Create('�������� ���� ������������� ����!');

  BS := CreateBlobStream(Fld, bmWrite);
  try
    S.Position := 0;
    SSH := TStringStream.Create('');
    SSD := TStringStream.Create('');
    try
      CS := TZCompressionStream.Create(SSD);
      try
        repeat
          I := S.Read(Buf, SizeOf(Buf));
          CS.Write(Buf, I);
        until I = 0;
      finally
        CS.Free;
      end;

      H.Signature := attSignature;
      H.Version := attVersion;
      H.Compression := attZLibCompression;
      H.DataType := 0;
      H.Size := S.Size;
      H.CompressedSize := SSD.Size;
      H.ReservedB := 0;
      H.ReservedL := 0;
      SSH.WriteBuffer(H, SizeOf(H));

      BS.CopyFrom(SSH, 0);
      BS.CopyFrom(SSD, 0);
    finally
      SSH.Free;
      SSD.Free;
    end;
  finally
    BS.Free;
  end;
end;

class function TgdcFile.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgFile';
end;

initialization
  RegisterGDCClass(TgdcBaseFile,   '���� (������� �����)');
  RegisterGDCClass(TgdcFile,       '����');
  RegisterGDCClass(TgdcFileFolder, '�����');
  FRootDirectory := '';

finalization
  UnregisterGdcClass(TgdcBaseFile);
  UnregisterGdcClass(TgdcFile);
  UnregisterGdcClass(TgdcFileFolder);
end.
