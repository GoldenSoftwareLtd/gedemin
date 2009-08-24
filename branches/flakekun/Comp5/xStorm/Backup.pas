{++

  Components: TBackup, TFullBackup
  Classes: TCustomBackup
  Copyright (c) 1996 by Golden Software of Belarus

  Module

    Backup.pas

  Abstract

    Components for creating multi-volume packed backup-files.

  Author

     Vladimir Belyi (1-March-1996)

  Contact address

    andreik%gs.minsk.by

  Revisions history

    1.xx               belyi   This versions are not commented here...
    2.00  17-Jun-1996  Belyi   Adopted for 32-bit Delphi
                               (now both versions are supported)
    2.01  20-Jun-1996  Belyi   Multilangual support
    2.02  23-Jun-1996  Belyi   Minor changes
    2.03  29-Jun-1996  Belyi   Minor changes
    2.04  31-Aug-1996  Belyi   TBackupResult type added.
                               Waste files are deleted (due to termination).
                               Sender parameter added to all events.
                               Terminate button added to all windows.
    2.05  14-Sep-1996  Belyi   bkStr unit deleted. Instead connection to
                               xWorld component is added (for common xTools
                               multilangual support).
                               Bug with saved drive letters deleted.
                               And two other minor bugs as well.
    2.06   7-Dec-1996  belyi   Delphi raised Compiler Error 18: Too many files.
                               This involved some minor changes.

  Known bugs

    -

  Wishes

    - comprasion ratio would be usefull

--}

unit Backup;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, FileCtrl,

  { xTools components }
  FileList, Streams, xWorld;

const
  BackupFileHeader = 'Golden Software Backup File';
  CurrentVersion = 2; { File format version }
  SupportedVersions = [1, 2]; { which files can be extracted }

const
  BackupBufSize = 10000;

type
  TFilesType = (ftNew,         { that is not present in Backup }
                ftFresher);    { that is not present in Backup or fresher}

const
  HeaderSize = 10;

const
  BufSize = 10000;

type
  TBackupFileHeader = record
    case boolean of
      true: (Version: word);
      false: (Bytes: array[1..HeaderSize] of byte);
  end;

type
  TBackupStoreOption = (bkSaveFullNames, bkAlwaysRefreshList,
    bkAutoReplaceVolumes);
  TBackupStoreOptions = set of TBackupStoreOption;

  TBackupRestoreOption = (bkAutoCreateDir, bkAutoReplace, bkUseSavedDrives);
  TBackupRestoreOptions = set of TBackupRestoreOption;

type
  TCreateDir = procedure(Sender: TObject; var TheFile: string;
    var SkipIt: boolean; var Continue: Boolean) of object;
  TReplaceFile = procedure(Sender: TObject; var TheFile: string;
    var SkipIt: boolean; var Continue: Boolean) of object;
  TCannotOpenFile = procedure(Sender: TObject; var TheFile: string;
    var SkipIt: boolean; var Continue: Boolean) of object;
  TShowProgress = procedure(Sender: TObject; CurrentFile: String;
    FilePos, FileSize: LongInt;
    Copied, TotalSize: LongInt;
    var Continue: Boolean) of object;
  TCheckComment = procedure(Sender: TObject; AComment: string;
    var Cancel: Boolean) of object;

type
  TFileInfo = record
    FileName: string;
    Attr: byte;
    Time: LongInt;
    Size: LongInt;
  end;

type
  TBKState = (bkWaiting, bkCreating, bkExtracting, bkUpdating,
    bkExtractingList);
  TBKStates = set of TBKState;

type { most methods have this type as a type of the result }
  TBackupResult = (brOk, brTerminated, brNoExtractFile, brError);
  { brError is more for internal use, cause it is accompanied by
    exception. }

type
  TCustomBackup = class(TComponent)
  private
    { Private declarations }
    WriteFileHeader: TBackupFileHeader;
    ReadFileHeader: TBackupFileHeader;
    InStream: TPackStream;
    OutStream: TPackStream;
    BackupWriter: TWriter;
    BackupReader: TReader;
    SwapList: TStringlist;

    { for properties }
    FBackupFileName: string;
    FComment: string;
    FTargetDir: string;
    FList: TFileList;
    FStoreOptions: TBackupStoreOptions;
    FRestoreOptions: TBackupRestoreOptions;
    FonCreateDir: TCreateDir;
    FOnReplaceFile: TReplaceFile;
    FVolumesSize: LongInt;
    FOnCheckComment: TCheckComment;
    FOnOpenVolume: TChangeVolume;
    FOnCannotOpenVolume: TCannotChangeVolume;
    FOnCreateVolume: TChangeVolume;
    FOnCannotCreateVolume: TCannotChangeVolume;
    FState: TBkState;
    FOnReplaceVolume: TReplaceVolume;
    FPackMethod: TPackMethods;
    FOnShowProgress: TShowProgress;
    FOnAccessDenied: TAccessDenied;
    FOnCannotOpenFile: TCannotOpenFile;
    procedure SetTargetDir(ADir: string);

    procedure CreateBegin(FileName: string);
    function NextSource(Name, FullName: string;
      var Source: TFileStream): Boolean;
    procedure CreateEnd(KillArchive: Boolean);

    procedure ExtractBegin(FileName: string);
    procedure CheckFile(var TheFile: string; var SkipIt: boolean);
    procedure ExtractEnd;
    procedure ExtractOne(var Name: TFileInfo; WriteIt: Boolean;
      Buffer: pointer);
    function DeleteOlder(Names, FullNames: TStringList;InBackup: TFileinfo;
      Types: TFilesType): Boolean;
    function InList(Names: TStringList; AFile: string): Boolean;

    procedure RememberList(L: TStringList);

  protected
    { Protected declarations }
    procedure CheckFree; virtual;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CreateBackup: TBackupResult; dynamic;
    function ExtractBackup: TBackupResult; dynamic;
    function UpdateBackup(SourceFile: string; Types: TFilesType):
      TBackupResult; dynamic;
    function ExtractList: TStringList; virtual;
    function NewInList(Types: TFilesType): TStringList; dynamic;

    property State: TBKState read FState;

    property BackupFileName: string read FBackupFileName
      write FBackupFileName;
    property Comment: string read FComment write FComment;
    property TargetDir: string read FTargetDir write SetTargetDir;
    property ListOfFiles: TFileList read FList write Flist;
    property StoreOptions: TBackupStoreOptions read FStoreOptions
      write FStoreOptions;
    property RestoreOptions: TBackupRestoreOptions read FRestoreOptions
      write FRestoreOptions;
    property VolumesSize: LongInt read FVolumesSize write FVolumesSize;
    property FilesInBackup: TStringList read ExtractList;
    property PackMethod: TPackMethods read FPackMethod
      write FPackMethod;

    property OnCreateDir: TCreateDir read FOnCreateDir write FOnCreateDir;
    property OnReplaceFile: TReplaceFile read FOnReplaceFile write FOnReplaceFile;
    property OnOpenVolume: TChangeVolume
      read FOnOpenVolume write FOnOpenVolume;
    property OnCannotOpenVolume: TCannotChangeVolume
      read FOnCannotOpenVolume write FOnCannotOpenVolume;
    property OnCreateVolume: TChangeVolume
      read FOnCreateVolume write FOnCreateVolume;
    property OnCannotCreateVolume: TCannotChangeVolume
      read FOnCannotCreateVolume write FOnCannotCreateVolume;
    property OnReplaceVolume: TReplaceVolume read FOnReplaceVolume
      write FOnReplaceVolume;
    property OnShowProgress: TShowProgress read FOnShowProgress
      write FOnShowProgress;
    property OnAccessDenied: TAccessDenied read FOnAccessDenied
      write FOnAccessDenied;
    property OnCannotOpenFile: TCannotOpenFile read FOnCannotOpenFile
      write FOnCannotOpenFile;
    property OnCheckComment: TCheckComment read FOnCheckComment
      write FOnCheckComment;
  end;


  TBackup = class(TCustomBackup)
  published
    { Published declarations }
    property BackupFileName;
    property TargetDir;
    property ListOfFiles;
    property StoreOptions;
    property RestoreOptions;
    property VolumesSize;
    property PackMethod;

    property OnCreateDir;
    property OnReplaceFile;
    property OnOpenVolume;
    property OnCannotOpenVolume;
    property OnCreateVolume;
    property OnCannotCreateVolume;
    property OnReplaceVolume;
    property OnShowProgress;
    property OnAccessDenied;
    property OnCannotOpenFile;
    property OnCheckComment;
  end;



  TFullBackup = class(TCustomBackup)
  protected
    ForceDirs: boolean;
    ForceReplace: boolean;
    procedure CannotOpenFile(Sender: TObject; var TheFile: string;
      var SkipIt: boolean; var Continue: Boolean);
    procedure ChangeVolume(Sender: TObject; Vol: integer;
      var FileName: string; var Continue: Boolean);
    procedure CannotChangeVolume(Sender: TObject; Vol: integer; var FileName: string;
      var RunError: Boolean);
    procedure ReplaceVolume(Sender: TObject; Vol: integer; var FileName: string;
      var Replace: Boolean; var Continue: Boolean);
    procedure AccessDenied(Sender: TObject; Filename: string; var RunError: boolean);
    procedure ShowProgress(Sender: TObject; CurrentFile: String;
      FilePos, FileSize: LongInt;
      Copied, TotalSize: LongInt;
      var Continue: Boolean);
    procedure CreateDir(Sender: TObject; var TheFile: string;
      var SkipIt: boolean; var Continue: Boolean);
    procedure ReplaceFile(Sender: TObject; var TheFile: string;
      var SkipIt: boolean; var Continue: Boolean);
    procedure CheckComment(Sender: TObject; AComment: string;
      var Cancel: Boolean);

    procedure SetInclude(List: TStringList);
    procedure SetExclude(List: TStringList);
    procedure SetSorting(ASort: TSorting);
    procedure SetGoSubDirs(AGo: Boolean);
    function GetInclude: TStringList;
    function GetExclude: TStringList;
    function GetSorting: TSorting;
    function GetGoSubDirs: Boolean;

  public
    constructor Create(AOwner: TComponent); override;
    function CreateBackup: TBackupResult; override;
    function ExtractBackup: TBackupResult; override;
    procedure ExtractList; dynamic; { don't override }
    procedure CompleteCreate;
    procedure Execute;

  published
    property Include: TStringList read GetInclude write SetInclude;
    property Exclude: TStringList read GetExclude write SetExclude;
    property Sorting: TSorting read GetSorting write SetSorting;
    property GoSubDirs: Boolean read GetGoSubDirs write SetGoSubDirs;

    property BackupFileName;
    property TargetDir;
    property StoreOptions;
    property RestoreOptions;
    property VolumesSize;
    property PackMethod;
  end;

type
  EBackupError = class(Exception);
  EBackupOpenError = class(EBackupError);
  EBackupListError = class(EBackupError);
  EBackupUpdateError = class(EBackupError);
  EBackupTerminated = class(EBackupError);

var { codes for all messages }
  lnTerminate     ,
  lnSkipFile      ,
  lnBrowse        ,
  lnCreateAll     ,
  lnCreate        ,
  lnOverwrite     ,
  lnOverwriteAll  ,
  lnSetComment    ,
  lnGetComment1   ,
  lnGetComment2   ,
  lnCreateMsg     ,
  lnCurrentFile   ,
  lnTotallyCopied ,
  lnScaning       ,
  lnFinalCreate   ,
  lnStop          ,
  lnReading       ,
  lnArcName       ,
  lnExtractDir    ,
  lnREadMsg       ,
  lnReadFinal     ,
  lnPack          ,
  lnExtract       ,
  lnList          ,
  lnOperation     ,
  lnNoDir         ,
  lnNextVol       ,
  lnAccessError   ,
  lnReplaceMsg    ,
  lnOverWriteMsg  ,
  lnExtrlist      ,
  lnFilesIn       ,
  lnLZW           ,
  lnNoPack        ,
  lnVolSize       ,
  lnRecurse       ,
  lnIncludeMask   ,
  lnExcludeMask   ,
  lnNoExtractFile ,
  lnAccessDenied  ,
  lnCannotOpen    ,
  lnUser          ,
  lnNoFile        ,
  lnWasTerminated ,
  lnHExtrL        ,
  lnHExtr         ,
  lnHCreating     ,
  lnHComment      ,
  lnHCreate       ,
  lnHCreateDir    ,
  lnHBackup       ,
  lnHReadList     ,
  lnHExtract      ,
  lnHCreated      ,
  lnHExtracted    ,
  lnHFiles        ,
  lnHOver         ,
  lnHOptions      ,
  lnHVol          ,
  lnHVolEr        ,
  lnHVolExists    : Integer;

  procedure Register;

implementation

uses
  { windows for TFullBackup }
  BKVol1, BKVol2, BKVol3, BKCreate, BKFinal, BKDir, BKOver, BKSave, BKRead,
  BKExtr, BKFinal1, BKList, BKExtrL, BKExec, BKPreCr, BKCmnt1, BKCmnt2;

{ ---------------------- TCustomBackup ------------------ }
constructor TCustomBackup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SwapList := TStringList.Create;
  FState := bkWaiting;
  FBackupFileName := '';
  FRestoreOptions := [bkAutoCreateDir];
  FStoreOptions := [bkAlwaysRefreshList];
  FVolumesSize := vsAuto;
  FPackMethod := pkLZW;
  FComment := '';
end;

destructor TCustomBackup.Destroy;
begin
  SwapList.Destroy;
  inherited destroy;
end;

procedure TCustomBackup.RememberList(L: TStringList);
begin
  SwapList.Free;
  SwapList := L;
end;

procedure TCustomBackup.CheckFree;
begin
  if FState<>bkWaiting then
    raise EBackupError.Create('Backup is working at the moment...');
end;

procedure TCustomBackup.SetTargetDir(ADir: string);
begin
  if ( Length(ADir) > 0 ) and ( ADir[ Length(ADir) ] <> '\' ) then
    ADir := ADir + '\';
  FTargetDir := ADir;
end;

procedure TCustomBackup.CreateBegin(FileName: string);
begin
  if FList = nil then
    raise EBackupListError.Create('No list of files found');

  OutStream := TPackStream.Create(FileName, fmCreate, FVolumesSize);
  OutStream.AutoReplaceVolumes := bkAutoReplaceVolumes in StoreOptions;
  OutStream.OnOpenVolume := FOnOpenVolume;
  OutStream.OnCannotOpenVolume := FOnCannotOpenVolume;
  OutStream.OnCreateVolume := FOnCreateVolume;
  OutStream.OnCannotCreateVolume := FOnCannotCreateVolume;
  OutStream.OnReplaceVolume := FOnReplaceVolume;
  OutStream.PackMethod := FPackMethod;
  OutStream.OnAccessDenied := FOnAccessDenied;
  BackupWriter := TWriter.Create(OutStream, BackupBufSize);

  BackupWriter.WriteString(BackupFileHeader);
  WriteFileHeader.Version := CurrentVersion;
  BackupWriter.Write(WriteFileHeader, SizeOf(WriteFileHeader));
  BackupWriter.WriteString(Comment);
end;

function TCustomBackup.NextSource(Name, FullName: string;
  var Source: TFileStream): Boolean;
var
  CanExit: Boolean;
  SkipIt: Boolean;
  FileAttr: integer;
  Continue: Boolean;
begin
  NextSource := false;
  FileAttr := FileGetAttr(FullName);
  CanExit := true;
  SkipIt := false;
  repeat
    try
      Source := TFileStream.Create(FullName, fmOpenRead);
    except
      on EFopenError do
        begin
          CanExit := false;
          SkipIt := true;
          Continue := true;
          if Assigned(FOnCannotOpenFile) then
            FOnCannotOpenFile(self, FullName, SkipIt, Continue);
          if not Continue then
            raise EBackupTerminated.Create(Phrases[lnUser]);
        end;
    end;
  until CanExit or SkipIt;

  if SkipIt then exit;

  try
    if bkSaveFullNames in FStoreOptions
      then BackupWriter.WriteString(FullName)
      else BackupWriter.WriteString(ExtractFileName(Name));{ Add ExtractFileName function }
    BackupWriter.WriteInteger(FileAttr);
    BackupWriter.WriteInteger(FileGetDate(Source.Handle));
    BackupWriter.WriteInteger(Source.Size);
  except
    on E: Exception do
      begin
        Source.Free;
        raise;
      end;
  end;
  NextSource := true;
end;

procedure TCustomBackup.CreateEnd(KillArchive: Boolean);
begin
  if KillArchive then
    begin
      try
        BackupWriter.Free;
      except
      end;
      OutStream.Kill;
    end
  else
    begin
      BackupWriter.Free;
      OutStream.Free;
    end;
end;

function TCustomBackup.CreateBackup: TBackupResult;
var
  i: Integer;
  Source: TFileStream;
  Buffer: pointer;
  BufHave: LongInt;
  HaveCopied: LongInt;
  FileCopied: LongInt;
  Continue: Boolean;
  DeleteSwap: Boolean;
begin
  Result := brError;

  CheckFree;
  FState := bkCreating;
  try
    if bkAlwaysRefreshList in StoreOptions then
      FList.ListIsFresh := false;
    DeleteSwap := true;
    CreateBegin(FBackupFileName);
    try
      try
        BackupWriter.WriteListBegin;
        GetMem(Buffer, BufSize);
        HaveCopied := 0;
        try
          for i:=0 to FList.Count-1 do
            begin
              if NextSource(FList.Names[i], FList.Fullnames[i], Source) then
                try
                  FileCopied := 0;
                  repeat
                    BufHave := Source.Read(Buffer^, BufSize);
                    BackupWriter.Write(Buffer^, BufHave);
                    HaveCopied := HaveCopied + BufHave;
                    FileCopied := FileCopied + BufHave;
                    Continue := true;
                    if Assigned(FOnShowProgress) then
                      FOnShowProgress(self, FList.FullNames[i],
                                      FileCopied, Source.Size,
                                      HaveCopied, FList.FilesSize,
                                      Continue);
                    if not Continue then
                      raise EBackupTerminated.Create(Phrases[lnUser]);
                  until BufHave < BufSize;
                finally
                  Source.Free;
                end
              else
                try
                  HaveCopied := HaveCopied + FileGetSize(FList.FullNames[i]);
                except
                  on EInOutError do;
                end;
            end;
        finally
          FreeMem(Buffer, BufSize);
        end;

        BackupWriter.WriteListEnd;

        result := brOk;

      except
        on EBackupTerminated do Result := brTerminated;
        on EVolExistsTermination do
          begin
            Result := brTerminated;
            DeleteSwap := false;
          end;
        on ETerminated do Result := brTerminated;
        else
          begin
            Result := brError;
            raise;
          end;
      end;

    finally
      CreateEnd( (Result <> brOk) and DeleteSwap );
    end;

  finally
    FState := bkWaiting;
  end;
end;

procedure TCustomBackup.CheckFile(var TheFile: string; var SkipIt: boolean);
var
  TheDir: string;
  Continue: Boolean;
begin
  SkipIt := false;
  TheDir := ExtractFilePath(TheFile);

  if not DirectoryExists(TheDir) then
    begin
      SkipIt := false;
      if not (bkAutoCreateDir in FRestoreOptions) then
        if Assigned(FOnCreateDir) then
          begin
            Continue := true;
            FOnCreateDir(self, TheFile, SkipIt, Continue);
            if not Continue then
              raise EBackupTerminated.Create(Phrases[lnUser]);
          end
        else
          begin
            SkipIt:=true;
            TheFile := TargetDir + ExtractFileName(TheFile);
            if not DirectoryExists(TargetDir) then
              ForceDirectories(TargetDir);
          end;
      if not SkipIt then ForceDirectories(TheDir);
    end;

  if (not SkipIt) and FileExists(TheFile) then
    begin
      if not (bkAutoReplace in FRestoreOptions) then
        begin
          Continue := true;
          if Assigned(FOnReplaceFile) then
            FOnReplaceFile(self, TheFile, SkipIt, Continue);
          if not Continue then
            raise EBackupTerminated.Create(Phrases[lnUser]);
        end;
    end;
end;

procedure TCustomBackup.ExtractBegin(FileName: string);
var
  AHeaderStr: string;
  AComment: string;
  Cancel: Boolean;
begin
  try
    InStream := TPackStream.Create(FileName, fmOpenRead, FVolumesSize);
  except
    raise EBackupOpenError.Create('Could not open file ' + FileName);
  end;
  InStream.OnOpenVolume := FOnOpenVolume;
  InStream.OnCannotOpenVolume := FOnCannotOpenVolume;
  InStream.OnCreateVolume := FOnCreateVolume;
  InStream.OnCannotCreateVolume := FOnCannotCreateVolume;
  InStream.OnReplaceVolume := FOnReplaceVolume;
  InStream.OnAccessDenied := FOnAccessDenied;

  BackupReader := TReader.Create(InStream, BackupBufSize);

  AHeaderStr := BackupReader.ReadString;
  if AHeaderStr <> BackupFileHeader then
    raise EBackupOpenError.Create('Incorrect file');
  BackupReader.Read(ReadFileHeader, SizeOf(ReadFileHeader));
  if not(ReadFileHeader.Version in SupportedVersions) then
    raise EBackupOpenError.Create('Incorrect file version');

  if ReadFileHeader.Version > 1 then
    begin
      AComment := BackupReader.ReadString;
      Cancel := false;
      if Assigned(FOnCheckComment) then
        FOnCheckComment(self, AComment, Cancel);
      if Cancel then
        raise EBackupTerminated.Create(Phrases[lnUser]);
      Comment := AComment;
    end;

end;

procedure TCustomBackup.ExtractEnd;
begin
  BackupReader.Free;
  InStream.Free;
end;

procedure TCustomBackup.ExtractOne(var Name: TFileInfo; WriteIt: Boolean;
  Buffer: pointer);
var
  Destination: TFileStream;
  ToRead: LongInt;
  BufSaved: LongInt;
  SkipIt: Boolean;
  TillEnd: LongInt;
  Continue: Boolean;
begin
  SkipIt := true;
  if WriteIt then CheckFile(Name.FileName, SkipIt);
  Name.Attr :=BackupReader.ReadInteger;
  Name.Time := BackupReader.ReadInteger;
  Name.Size := BackupReader.ReadInteger;
  if not SkipIt then
    Destination := TFileStream.Create(Name.FileName, fmCreate);
  TillEnd := Name.Size;
  try
    repeat
      ToRead := BufSize;
      if ToRead > TillEnd then ToRead := TillEnd;
      BackupReader.Read(Buffer^, ToRead);
      if not SkipIt then
        BufSaved := Destination.Write(Buffer^, ToRead)
      else BufSaved := ToRead;
      TillEnd := TillEnd-ToRead;
      Continue := true;
      if Assigned(FOnShowProgress) then
        FOnShowProgress(self, Name.FileName,
                        Name.Size-TillEnd, Name.Size,
                        0, 0, Continue);
      if not Continue then
        raise EBackupTerminated.Create(Phrases[lnUser]);
    until (TillEnd = 0) or (BufSaved < ToRead);
    if not SkipIt then
      begin
        FileSetDate(Destination.Handle, Name.Time);
        Destination.Free;
        FileSetAttr(Name.FileName, Name.Attr);
      end;
  except
    on Exception do
      begin
        if not SkipIt then Destination.Free;
        raise;
      end;
  end;
end;

function TCustomBackup.ExtractBackup: TBackupResult;
var
  Buffer: pointer;
  TheFile: TFileInfo;
begin
  CheckFree;
  FState := bkExtracting;
  try
    try
      ExtractBegin(FBackupFileName);
      try
        BackupReader.ReadListBegin;
        GetMem(Buffer, BufSize);
        try
          while not BackupReader.EndOfList do
            begin
              TheFile.FileName := BackupReader.ReadString;
              if TheFile.FileName[1] = '%' then
                TheFile.FileName := GetDiskFileName(TheFile.FileName)
              else
                begin
                  if (copy(TheFile.FileName, 2, 1) = ':') then
                    begin
                      if (bkUseSavedDrives in FRestoreOptions) then
                        TheFile.FileName := TheFile.FileName
                      else
                        begin
                          delete(TheFile.FileName, 1, 3);
                          TheFile.FileName := DeleteRef(TargetDir) +
                            TheFile.FileName;
                        end;
                    end
                  else
                    begin
                      if TheFile.FileName[1] = '\' then
                        delete( TheFile.FileName, 1, 1 );
                      TheFile.FileName := DeleteRef(TargetDir) +
                        TheFile.FileName;
                    end;
                end;
              ExtractOne(TheFile, True, Buffer);
            end;
        finally
          FreeMem(Buffer, BufSize);
        end;

        BackupReader.ReadListEnd;

      finally
        ExtractEnd;
      end;

      Result := brOk;

    except
      on EBackupTerminated do Result := brTerminated;
      on EBackupOpenError do Result := brNoExtractFile;
      else
        begin
          Result := brError;
          raise;
        end;
    end;
  finally
    FState := bkWaiting;
  end;
end;

function TCustomBackup.ExtractList: TStringList;
var
  Buffer: pointer;
  TheFile: TFileInfo;
begin
  CheckFree;
  FState := bkExtractingList;
  try
    ExtractBegin(FBackupFileName);
    Result := TStringList.Create;
    try
      BackupReader.ReadListBegin;
      GetMem(Buffer, BufSize);
      try
        while not BackupReader.EndOfList do
          begin
            TheFile.FileName := BackupReader.ReadString;
            Result.Add(TheFile.FileName);
            ExtractOne(TheFile, False, Buffer);
          end;
      finally
        FreeMem(Buffer, BufSize);
      end;

      BackupReader.ReadListEnd;


    finally
      RememberList(Result);
      ExtractEnd;
    end;

  finally
    FState := bkWaiting;
  end;
end;

function TCustomBackup.DeleteOlder(Names, FullNames: TStringList;
  InBackup: TFileinfo; Types: TFilesType): Boolean;
var
  CheckFile: TFileStream;
  CheckDate: LongInt;
  j: Integer;
  HaveMatch: Boolean;
  Which: Integer;
begin
  j:=0;
  HaveMatch := false;
  Which := -1;
  While (j <= Names.Count-1) and not HaveMatch do
    begin
      if CompareStr(FullNames.strings[j], InBackup.FileName) = 0 then
        begin
          CheckFile := TFileStream.Create(GetDiskFileName(FullNames.strings[j]),
            fmOpenRead);
          CheckDate := FileGetDate(CheckFile.Handle);
          CheckFile.Free;
          Which := j;
          case Types of
            ftNew: HaveMatch := true;
            ftFresher: if CheckDate <= InBackup.Time then HaveMatch := true;
          end;
        end;
      inc(j);
    end;
  if HaveMatch then
    begin
      Names.Delete(Which);
      FullNames.Delete(Which);
      Result := true;
    end
  else Result := false;
end;

function TCustomBackup.NewInList(Types: TFilesType): TStringList;
var
  Buffer: pointer;
  TheFile: TFileInfo;
  FullNames: TStringList;
begin
  CheckFree;
  FState := bkExtractingList;
  try
    ExtractBegin(FBackupFileName);
    Result := TStringList.Create;
    try
      Result.Assign(FList.List);
      FullNames := TStringList.create;
      FullNames.Assign(FList.FullNamesList);

      BackupReader.ReadListBegin;
      GetMem(Buffer, BufSize);
      try
        while not BackupReader.EndOfList do
          begin
            TheFile.FileName := BackupReader.ReadString;
            ExtractOne(TheFile, False, Buffer);
            DeleteOlder(Result, FullNames, TheFile, Types);
          end;
      finally
        FreeMem(Buffer, BufSize);
      end;

      BackupReader.ReadListEnd;

      FullNames.Free;

    finally
      RememberList(Result);
      ExtractEnd;
    end;

  finally
    FState := bkWaiting;
  end;
end;

function TCustomBackup.InList(Names: TStringList; AFile: string): Boolean;
var
  j: Integer;
begin
  j := 0;
  While (j <= Names.Count-1) and
    (CompareStr(ExpandFileName(Names.strings[j]),ExpandFileName(AFile)) <> 0)
    do inc(j);
  Result := j <= Names.Count-1;
end;

function TCustomBackup.UpdateBackup(SourceFile: string;
  Types: TFilesType): TBackupResult;
var
  i: Integer;
  Source: TFileStream;
  Buffer: pointer;
  TillEnd, ToRead: LongInt;
  BufHave: LongInt;
  Names, FullNames: TStringList;
  TheFile: TFileInfo;
  Continue: Boolean;
  DeleteSwap: Boolean;
begin
  Result := brError;

  CheckFree;
  FState := bkUpdating;
  try
    if UpperCase(ExpandFileName(SourceFile)) =
         UpperCase(ExpandFileName(BackupFileName)) then
      raise EBackupUpdateError.Create('Specify different files for reading and ' +
          'writing when updating');

    DeleteSwap := true;
    CreateBegin(FBackupFileName);
    try
      try
        ExtractBegin(SourceFile);
        try
          try
            Names := TStringList.Create;
            FullNames := TStringList.create;
            try
              Names.Assign(FList.List);
              FullNames.Assign(FList.FullNamesList);

              BackupReader.ReadListBegin;
              BackupWriter.WriteListBegin;

              GetMem(Buffer, BufSize);
              try
                while not BackupReader.EndOfList do
                  begin
                    TheFile.FileName := BackupReader.ReadString;
                    TheFile.Attr := BackupReader.ReadInteger;
                    TheFile.Time := BackupReader.ReadInteger;
                    TheFile.Size := BackupReader.ReadInteger;
                    DeleteOlder(Names, FullNames, TheFile, Types);
                    if not InList(FullNames, TheFile.FileName) then
                      begin
                        BackupWriter.WriteString(TheFile.FileName);
                        BackupWriter.WriteInteger(TheFile.Attr);
                        BackupWriter.WriteInteger(TheFile.Time);
                        BackupWriter.WriteInteger(TheFile.Size);
                        TillEnd := TheFile.Size;
                        repeat
                          ToRead := BufSize;
                          if ToRead > TillEnd then ToRead := TillEnd;
                          BackupReader.Read(Buffer^, ToRead);
                          BackupWriter.Write(Buffer^, ToRead);
                          TillEnd := TillEnd - ToRead;
                        until TillEnd = 0;
                      end
                    else
                      begin
                        TillEnd := TheFile.Size;
                        repeat
                          ToRead := BufSize;
                          if ToRead > TillEnd then ToRead := TillEnd;
                          BackupReader.Read(Buffer^, ToRead);
                          TillEnd := TillEnd - ToRead;
                          Continue := true;
                          FOnShowProgress(self, TheFile.FileName,
                                          TheFile.Size-TillEnd, TheFile.Size,
                                          0, 0, Continue);
                          if not Continue then
                                  raise EBackupTerminated.Create(Phrases[lnUser]);
                        until TillEnd = 0;
                      end
                  end;
                for i:=0 to FullNames.Count-1 do
                  begin
                    if NextSource(Names.strings[i], FullNames.strings[i], Source) then
                      try
                        repeat
                          BufHave := Source.Read(Buffer^, BufSize);
                          BackupWriter.Write(Buffer^, BufHave);
                        until BufHave<BufSize;
                      finally
                        Source.Free;
                      end;
                  end;
              finally
                FreeMem(Buffer, BufSize);
              end;

              BackupReader.ReadListEnd;
              BackupWriter.WriteListEnd;

            finally
              FullNames.Free;
              Names.Free;
            end;

            Result:= brOk;

          except
            on EBackupTerminated do Result := brTerminated;
            on EBackupTerminated do
              begin
                DeleteSwap := false;
                Result := brTerminated;
              end;
            on ETerminated do Result := brTerminated;
            else
              begin
                result := brError;
                raise;
              end;
          end;

        finally
          ExtractEnd;
        end;

      except
        on EBackupOpenError do Result := brNoExtractFile
        else
          begin
            result := brError;
            raise;
          end;
      end;

    finally
      CreateEnd( (Result <> brOk) and DeleteSwap );
    end;

  finally
    FState := bkWaiting;
  end;
end;


{------------------------- TFullBackup -------------------- }
constructor TFullBackup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ListOfFiles := FileList.TFilelist.Create(self);
  RestoreOptions := [];
  OnCannotOpenFile := CannotOpenFile;
  OnOpenVolume := ChangeVolume;
  OnCreateVolume := ChangeVolume;
  OnCannotOpenVolume := CannotChangeVolume;
  OnCannotCreateVolume := CannotChangeVolume;
  OnReplaceVolume := ReplaceVolume;
  OnAccessDenied := AccessDenied;
  OnCreateDir := CreateDir;
  OnReplaceFile := ReplaceFile;
  OnShowProgress := ShowProgress;
  OnCheckComment := CheckComment;
end;

function TFullBackup.CreateBackup: TBackupResult;
begin
  Result := brError;
  
  CheckFree;
  Application.CreateForm(TCreateDlg, CreateDlg);
  try
    CreateDlg.Edit1.Text := BackupFileName;
    if CreateDlg.ShowModal = mrOk then
      begin
        Application.CreateForm(TNewComment, NewComment);
        try
          NewComment.Edit1.text := Comment;
          if NewComment.ShowModal <> mrCancel then
            begin
              Comment := NewComment.Edit1.Text;
              BackupFileName := CreateDlg.Edit1.Text;
              Application.CreateForm(TSaveDlg, SaveDlg);
              try
                SaveDlg.Show;
                SaveDlg.terminate := false;
                Application.ProcessMessages;
                Result := inherited CreateBackup;
              finally
                SaveDlg.Free;
              end;
              if Result = brOk then
                begin
                  Application.CreateForm(TFinalDlg, FinalDlg);
                  try
                    FinalDlg.ShowModal;
                  finally
                    FinalDlg.Free;
                  end;
                end
              else if Result = brTerminated then
                MessageDlg( Phrases[lnWasTerminated], mtError, [mbOk], 0);
            end;
        finally
          NewComment.Free;
        end;
      end;
  finally
    CreateDlg.Free;
  end;
end;

function TFullBackup.ExtractBackup: TBackupResult;
begin
  CheckFree;
  ForceReplace := false;
  Application.CreateForm(TExtractDlg, ExtractDlg);
  try
    repeat
      ExtractDlg.Edit1.Text := BackupFileName;
      ExtractDlg.Edit2.Text := TargetDir;
      Result := brTerminated;
      if ExtractDlg.ShowModal = mrOk then
        begin
          BackupFileName := ExtractDlg.Edit1.Text;
          TargetDir := ExtractDlg.Edit2.Text;
          Application.CreateForm(TReadDlg, ReadDlg);
          try
            ReadDlg.Caption := Phrases[lnHExtr];
            ReadDlg.Show;
            ReadDlg.terminate := false;
            Application.ProcessMessages;
            Result := brError;
            Result := inherited ExtractBackup;
          finally
            ReadDlg.Free;
          end;
        end;
      if Result = brNoExtractFile then
        begin
          if MessageDlg( Phrases[lnNoFile], mtError,
             [mbOk, mbCancel], 0) = mrCancel then
            Result := brTerminated;
        end;
    until Result in [brOk, brTerminated];
    if Result = brOk then
      begin
        Application.CreateForm(TFinal1Dlg, Final1Dlg);
        try
          Final1Dlg.ShowModal;
        finally
          Final1Dlg.Free;
        end;
      end;
  finally
    ExtractDlg.Free;
  end;
end;

procedure TFullBackup.ExtractList;
begin
  CheckFree;
  ForceDirs := false;
  Application.CreateForm(TExtractListDlg, ExtractListDlg);
  try
    ExtractListDlg.Edit1.Text := BackupFileName;
    if ExtractListDlg.ShowModal = mrOk then
      begin
        BackupFileName := ExtractListDlg.Edit1.Text;
        Application.CreateForm(TReadDlg, ReadDlg);
        try
          ReadDlg.Caption := Phrases[lnHExtrL];
          ReadDlg.Show;
          ReadDlg.terminate := false;
          Application.ProcessMessages;
          Application.CreateForm(TListDlg, ListDlg);
          try
            ListDlg.Edit1.Text := BackupFileName;
            ListDlg.Memo1.Lines := inherited ExtractList;
            ReadDlg.Hide;
            ListDlg.ShowModal;
          finally
{            if ListDlg<>nil then}
              ListDlg.Free;
          end;
        finally
          ReadDlg.Free;
        end;
      end;
  finally
    ExtractListDlg.Free;
  end;
end;

procedure TFullBackup.CompleteCreate;
begin
  CheckFree;
  Application.CreateForm(TPreCreateDlg, PreCreateDlg);
  try
    PreCreateDlg.MemoIn.Lines := Include;
    PreCreateDlg.MemoEx.Lines := Exclude;
    PreCreateDlg.VolSize.Value := VolumesSize;
    if PreCreateDlg.ShowModal = mrOk then
      begin
        GoSubDirs := PreCreateDlg.SubDirs.Checked;
        if PreCreateDlg.LZW.Checked then
          PackMethod := pkLZW
        else
          PackMethod := pkNO;
        VolumesSize := PreCreateDlg.VolSize.value;
        Include.Assign(PreCreateDlg.MemoIn.Lines);
        Exclude.Assign(PreCreateDlg.MemoEx.Lines);
        CreateBackup;
      end;
  finally
    PreCreateDlg.Free;
  end;
end;

procedure TFullBackup.Execute;
begin
  CheckFree;
  Application.CreateForm(TExecuteDlg, ExecuteDlg);
  try
    ExecuteDlg.OCreate.Checked := true;
    if ExecuteDlg.ShowModal = mrOk then
      begin
        if ExecuteDlg.OCreate.Checked then CompleteCreate
        else if ExecuteDlg.OExtract.Checked then ExtractBackup
        else if ExecuteDlg.OList.Checked then ExtractList;
      end;
  finally
    ExecuteDlg.Free;
  end;
end;

procedure TFullBackup.CannotOpenFile(Sender: TObject; var TheFile: string;
  var SkipIt: boolean; var Continue: Boolean);
begin
  SkipIt := MessageDlg(Format(Phrases[lnCannotOpen], [TheFile]),
    mtConfirmation, [mbYes, mbRetry], 0) = mrYes;
end;

procedure TFullBackup.ChangeVolume(Sender: TObject; Vol: integer;
  var FileName: string; var Continue: Boolean);
var
  MResult: integer;
begin
  Application.CreateForm(TVolumeDlg, VolumeDlg);
  try
    VolumeDlg.Edit.text := FileName;
    MResult := VolumeDlg.ShowModal;
    if MResult = mrAbort then
      Continue := false
    else
      FileName := VolumeDlg.Edit.Text;
  finally
    VolumeDlg.Free;
  end;
end;

procedure TFullBackup.CannotChangeVolume(Sender: TObject; Vol: integer;
  var FileName: string; var RunError: Boolean);
begin
  Application.CreateForm(TVolumeErDlg, VolumeErDlg);
  try
    VolumeErDlg.Edit.text := FileName;
    RunError := false;
    if VolumeErDlg.ShowModal<>mrCancel then
      FileName := VolumeErDlg.Edit.Text
    else RunError := true;
  finally
    VolumeErDlg.Free;
  end;
end;

procedure TFullBackup.ReplaceVolume(Sender: TObject; Vol: integer;
  var FileName: string; var Replace: Boolean; var Continue: Boolean);
var
  MResult: Integer;
begin
  if bkAutoReplaceVolumes in StoreOptions then
    begin
      Replace := true;
      exit;
    end;
  Application.CreateForm(TVolumeRpDlg, VolumeRpDlg);
  try
    VolumeRpDlg.Edit.text := FileName;
    Replace := false;
    MResult := VolumeRpDlg.ShowModal;
    if MResult = mrAbort then
      Continue := false
    else if MResult <> mrRetry then
      Replace := true;
    FileName := VolumeRpDlg.Edit.Text
  finally
    VolumeRpDlg.Free;
  end;
end;

procedure TFullBackup.AccessDenied(Sender: TObject; Filename: string;
  var RunError: boolean);
begin
  RunError := MessageDlg(Format(Phrases[lnAccessDenied], [FileName]),
    mtError, [mbRetry, mbCancel], 0) = mrCancel;
end;

procedure TFullBackup.ShowProgress(Sender: TObject; CurrentFile: String;
    FilePos, FileSize: LongInt;
    Copied, TotalSize: LongInt;
    var Continue: Boolean);
begin
  if State = bkCreating then
    begin
      SaveDlg.Edit1.Text := CurrentFile;
      if FileSize>1000 then
        begin
          SaveDlg.Gauge1.MaxValue := 100;
          SaveDlg.Gauge1.Progress := FilePos div (FileSize div 100);
        end
      else
        begin
          SaveDlg.Gauge1.MaxValue := FileSize;
          SaveDlg.Gauge1.Progress := FilePos;
        end;
      if TotalSize>1000 then
        begin
          SaveDlg.Gauge2.MaxValue := 100;
          SaveDlg.Gauge2.Progress := Copied div (TotalSize div 100);
        end
      else
        begin
          SaveDlg.Gauge2.MaxValue := TotalSize;
          SaveDlg.Gauge2.Progress := Copied;
        end;
      Application.ProcessMessages;
      if SaveDlg.terminate then
        begin
          if MessageDlg(Phrases[lnStop], mtConfirmation,
            [mbYes, mbNo], 0) = mrYes then
            Continue := false
          else
            SaveDlg.Terminate := false;
        end;
    end
  else if State in [bkExtracting, bkExtractingList] then
    begin
      ReadDlg.Edit1.Text := CurrentFile;
      if FileSize>1000 then
        begin
          ReadDlg.Gauge1.MaxValue := 100;
          ReadDlg.Gauge1.Progress := FilePos div (FileSize div 100);
        end
      else
        begin
          ReadDlg.Gauge1.MaxValue := FileSize;
          ReadDlg.Gauge1.Progress := FilePos;
        end;
      Application.ProcessMessages;
      if ReadDlg.terminate then
        begin
          if MessageDlg(Phrases[lnStop], mtConfirmation,
            [mbYes, mbNo], 0) = mrYes then
            Continue := false
          else
            ReadDlg.Terminate := false;
        end;
    end
end;

procedure TFullBackup.CreateDir(Sender: TObject; var TheFile: string;
  var SkipIt: boolean; var Continue: Boolean);
var
  MResult: integer;
begin
  if ForceDirs then
    begin
      SkipIt := false;
      exit;
    end;
  Application.CreateForm(TCreateDirDlg, CreateDirDlg);
  try
    CreateDirDlg.Edit1.text := TheFile;
    MResult := CreateDirDlg.ShowModal;
    Continue := MResult <> mrYes;
    SkipIt := MResult = mrCancel;
    if Continue and not SkipIt then
      begin
        TheFile := CreateDirDlg.Edit1.Text;
        if MResult = mrAll then
          ForceDirs := true;
      end;
  finally
    CreateDirDlg.Free;
  end;
end;

procedure TFullBackup.ReplaceFile(Sender: TObject; var TheFile: string;
  var SkipIt: boolean; var Continue: Boolean);
var
  MResult: Integer;
begin
  if ForceReplace then
    begin
      SkipIt := false;
      exit;
    end;
  Application.CreateForm(TOverDlg, OverDlg);
  try
    OverDlg.Edit1.text := TheFile;
    MResult := OverDlg.ShowModal;
    SkipIt := MResult in [mrOk, mrAll];
    if MResult = mrAll then ForceReplace := true
    else if MResult = mrAbort then Continue := false;
    TheFile := OverDlg.Edit1.Text
  finally
    OverDlg.Free;
  end;
end;

const
  ShortMonths: array[1..12] of string[10] = ('Янв', 'Фев', 'Мар',
    'Апр', 'Май', 'Июн', 'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек');

function GiveDateStr(Date: TDateTime): string;
var
  y, m, d: word;
begin
  decodeDAte(Date, y, m, d);
  Result := IntToStr(d) + '-' + ShortMonths[m] + '-' + IntToStr(y);
end;

procedure TFullBackup.CheckComment(Sender: TObject; AComment: string; var
  Cancel: Boolean);
begin
  Application.CreateForm(TSeeComment, SeeComment);
  try
    SeeComment.Edit1.text := AComment;
    if Phrases.language = lEnglish then
      SeeComment.Label3.Caption :=
        FormatDateTime('dddddd', GetFilesDate(BackupFileName))
    else if Phrases.Language = lRussian then
      SeeComment.Label3.Caption :=
        GiveDateStr( GetFilesDate(BackupFileName) );
    Cancel := SeeComment.ShowModal = mrCancel;
  finally
    SeeComment.Free;
  end;
end;

procedure TFullBackup.SetInclude(List: TStringList);
begin
  ListOfFiles.Include := List;
end;

procedure TFullBackup.SetExclude(List: TStringList);
begin
  ListOfFiles.Exclude := List;
end;

procedure TFullBackup.SetSorting(ASort: TSorting);
begin
  ListOfFiles.Sorting := ASort;
end;

procedure TFullBackup.SetGoSubDirs(AGo: Boolean);
begin
  ListOfFiles.GoSubDirs := AGo;
end;

function TFullBackup.GetInclude: TStringList;
begin
  result := ListOfFiles.Include;
end;

function TFullBackup.GetExclude: TStringList;
begin
  Result := ListOfFiles.Exclude;
end;

function TFullBackup.GetSorting: TSorting;
begin
  Result := ListOfFiles.Sorting;
end;

function TFullBackup.GetGoSubDirs: Boolean;
begin
  Result := ListOfFiles.GoSubDirs;
end;


{ ---------------------- resistering ------------------ }
procedure Register;
begin
  RegisterComponents('xStorm', [TBackup, TFullBackup]);
end;


initialization

  Phrases.SetOrigin('xTools: Backup components');

  { english messages }
  
  lnTerminate := Phrases.AddPhrase(lEnglish, 'Terminate');
  lnSkipFile := Phrases.AddPhrase(lEnglish, 'Skip file');
  lnBrowse := Phrases.AddPhrase(lEnglish, 'Browse');
  lnCreateAll := Phrases.AddPhrase(lEnglish, 'Create All');
  lnCreate := Phrases.AddPhrase(lEnglish, 'Create');
  lnOverwrite := Phrases.AddPhrase(lEnglish, 'Overwrite');
  lnOverwriteAll := Phrases.AddPhrase(lEnglish, 'Overwrite All');

  lnSetComment := Phrases.AddPhrase(lEnglish,
    'Here you may enter a string which will be stored in your archive as '+
    'a comment. It may help you when you will restore data from this archive.');
  lnGetComment1 := Phrases.AddPhrase(lEnglish, 'This archieve was created on');
  lnGetComment2 := Phrases.AddPhrase(lEnglish, 'It is commented as');
  lnCreateMsg := Phrases.AddPhrase(lEnglish, 'You are about to create a ' +
    'backup copy of your data. Please, enter '+
    'archive name at the bottom of the window. '#13#10#13#10+
    'NOTE: it is strongly recomended that your archieves are stored on '+
    'floppy disks - this may prevent data loss in the case of system crash.');
  lnCurrentFile := Phrases.AddPhrase(lEnglish, 'Current file');
  lnTotallyCopied := Phrases.AddPhrase(lEnglish, 'Totaly copied');
  lnScaning := Phrases.AddPhrase(lEnglish, 'Scaning files for archieving. ' +
    'Please, wait a moment...');
  lnFinalCreate := Phrases.AddPhrase(lEnglish, 'Your archieve was ' +
    'successfully created.'#13#10#13#10'Remember, that it is better to ' +
    'keep your archieves on floppy disks. '+
    'One day your system may crash and only floppy disks will rescue you '+
    'and your data in the case.');
  lnStop := Phrases.AddPhrase(lEnglish, 'Do you really want to ' +
    'terminate the process?');
  lnReading := Phrases.AddPhrase(lEnglish, 'Reading backup file header...');
  lnArcName := Phrases.AddPhrase(lEnglish, 'Archieve name');
  lnExtractDir := Phrases.AddPhrase(lEnglish, 'Directory to extract to');
  lnReadMsg := Phrases.AddPhrase(lEnglish, 'You are about to extract ' +
    'files from your backup file. Please, enter archive name and ' +
    'directory to extract files.');
  lnreadFinal := Phrases.AddPhrase(lEnglish, 'Your archieve was ' +
    'successfully extracted. NOTE: Don''t hurry to erase '+
    'your old archive. One day your system may crash and only archives '+
    'will rescue you and your data.');
  lnPack := Phrases.AddPhrase(lEnglish, 'Create archive');
  lnExtract := Phrases.AddPhrase(lEnglish, 'Extract files from archive');
  lnList := Phrases.AddPhrase(lEnglish, 'Read list of files in archive');
  lnOperation := Phrases.AddPhrase(lEnglish, 'Operation');
  lnNoDir := Phrases.AddPhrase(lEnglish, 'Directory not found. Choose ' +
    'Create button to create it or enter new file name.');
  lnNextVol := Phrases.AddPhrase(lEnglish, 'Replace disk or enter/confirm ' +
    'name for the next volume');
  lnAccessError := Phrases.AddPhrase(lEnglish, 'Cannot access volume. ' +
    'Try another disk or change volume name.');
  lnReplaceMsg := Phrases.AddPhrase(lEnglish, 'Volume file already ' +
    'exists. Enter another name or press '+
    'Replace button  to replace existing file.');
  lnOverwriteMsg := Phrases.AddPhrase(lEnglish, 'File already exists. ' +
    'Would you like to overwrite it (if not then change its name or '+
    'press Skip button).');
  lnExtrList := Phrases.AddPhrase(lEnglish, 'You are about to read ' +
    'names of files in your backup file. Please, enter archive name at ' +
    'the bottom of the window.');
  lnFilesIn := Phrases.AddPhrase(lEnglish, 'Files in:');
  lnLZW := Phrases.AddPhrase(lEnglish, 'LZW compression');
  lnNoPack := Phrases.AddPhrase(lEnglish, 'No packing');
  lnVolSize := Phrases.AddPhrase(lEnglish, 'Volume size (in Kb)');
  lnRecurse := Phrases.AddPhrase(lEnglish, 'Recurse subdirectories');
  lnIncludeMask := Phrases.AddPhrase(lEnglish, 'Include mask');
  lnExcludeMask := Phrases.AddPhrase(lEnglish, 'Exclude mask');
  lnNoExtractFile := Phrases.AddPhrase(lEnglish, 'File to extract not found. ' +
    'Check file name.');
  lnAccessDenied := Phrases.AddPhrase(lEnglish, 'Access to file %s was denied:');
  lnCannotOpen := Phrases.AddPhrase(lEnglish, 'File %s cannot be opened. ' +
    'Skip it?');
  lnUser := Phrases.AddPhrase(lEnglish, 'User termination');
  lnNoFile := Phrases.AddPhrase(lEnglish, 'File to extract not found or ' +
    'is corrupted.');
  lnWasTerminated := Phrases.AddPhrase(lEnglish, 'Your archive was ' +
    'not created.');
  lnHExtrL := Phrases.AddPhrase(lEnglish, '');
  lnHCreating := Phrases.AddPhrase(lEnglish, '');
  lnHExtrL := Phrases.AddPhrase(lEnglish, 'Extracting list of files');
  lnHExtr := Phrases.AddPhrase(lEnglish, 'Extracting files from backup');
  lnHCreating := Phrases.AddPhrase(lEnglish, 'Creating backup');
  lnHComment := Phrases.AddPhrase(lEnglish, 'Backup comment');
  lnHCreate := Phrases.AddPhrase(lEnglish, 'Create backup');
  lnHCreateDir := Phrases.AddPhrase(lEnglish, 'Create directory');
  lnHBackup := Phrases.AddPhrase(lEnglish, 'Backup');
  lnHReadList := Phrases.AddPhrase(lEnglish, 'Extract list of files in backup');
  lnHExtract := Phrases.AddPhrase(lEnglish, 'Extract files from backup');
  lnHCreated := Phrases.AddPhrase(lEnglish, 'Backup is created');
  lnHExtracted := Phrases.AddPhrase(lEnglish, 'Backup is extracted');
  lnHFiles := Phrases.AddPhrase(lEnglish, 'List of files in Backup');
  lnHOver := Phrases.AddPhrase(lEnglish, 'Overwrite file');
  lnHOptions := Phrases.AddPhrase(lEnglish, 'Set options for future archive');
  lnHVol := Phrases.AddPhrase(lEnglish, 'Change volume');
  lnHVolEr := Phrases.AddPhrase(lEnglish, 'Could not change volume');
  lnHVolExists := Phrases.AddPhrase(lEnglish, 'Volume file already exists');

  { russian messages }

  Phrases.AddTranslation(lnTerminate , lRussian, 'Прервать');
  Phrases.AddTranslation(lnSkipFile , lRussian, 'Пропустить');
  Phrases.AddTranslation(lnBrowse , lRussian, 'Пролистать...');
  Phrases.AddTranslation(lnCreateAll , lRussian, 'Создать все');
  Phrases.AddTranslation(lnCreate , lRussian, 'Создать');
  Phrases.AddTranslation(lnOverwrite , lRussian, 'Переписать');
  Phrases.AddTranslation(lnOverwriteAll , lRussian, 'Переписать все');
  Phrases.AddTranslation(lnSetComment , lRussian, 'Ниже вы можете ' +
    'ввести комментарий к архиву. Он может '+
    'оказаться полезным при распаковке архива через некоторое время.');
  Phrases.AddTranslation(lnGetComment1 , lRussian, 'Дата создания архива:');
  Phrases.AddTranslation(lnGetComment1 , lRussian, 'Комментарий:');
  Phrases.AddTranslation(lnCreateMsg , lRussian, 'Создание архивной ' +
    'копии данных. Введите, пожалуйста, имя файла архива, где '+
    'будут сохранены данные. '#13#10#13#10+
    'ЗАМЕЧАНИЕ: архивы лучше хранить на гибких дисках в надежном месте, ' +
    'так как только они помогут вам спасти ваши данные при их ' +
    'порче на винчестере.');
  Phrases.AddTranslation(lnCurrentFile , lRussian, 'Текущий файл:');
  Phrases.AddTranslation(lnTotallyCopied , lRussian, 'Всего скопировано:');
  Phrases.AddTranslation(lnScaning , lRussian, 'Идет считывание списка ' +
    'файлов. Пожалуйста, подождите...');
  Phrases.AddTranslation(lnFinalCreate , lRussian, 'Создание архива ' +
    'успешно завершено.'#13#10#13#10 +
    'Помните, что архивы лучше хранить на гибких дисках в безопасном месте. '+
    'Это поможет предотвратить потерю данных если по какой-либо причине '+
    'файлы на жестком диске будут уничтожены.');
  Phrases.AddTranslation(lnStop , lRussian, 'Вы действительно хотите ' +
    'прервать работу архиватора?');
  Phrases.AddTranslation(lnReading , lRussian, 'Считывание заголовка ' +
    'архива...');
  Phrases.AddTranslation(lnArcName , lRussian, 'Имя архива:');
  Phrases.AddTranslation(lnExtractDir , lRussian, 'Путь для распаковки:');
  Phrases.AddTranslation(lnReadMsg , lRussian, 'Восстановление данных ' +
    'из архивного файла. Пожалуйста, введите имя '+
    'архива и путь, куда будут записаны восстановленные файлы.');
  Phrases.AddTranslation(lnReadFinal , lRussian, 'Архив успешно распакован.'+
    #13#10#13#10'ЗАМЕЧАНИЕ: Не спешите стирать свои старые архивы. ' +
    'Это единственное, что может спасти ваши данные при их уничтожении ' +
    'на винчестере.');
  Phrases.AddTranslation(lnPack , lRussian, 'Создать архив');
  Phrases.AddTranslation(lnExtract , lRussian, 'Распаковать файлы из архива');
  Phrases.AddTranslation(lnList , lRussian, 'Считать список файлов в архиве');
  Phrases.AddTranslation(lnOperation , lRussian, 'Операция');
  Phrases.AddTranslation(lnNoDir , lRussian, 'Путь не найден. ' +
    'Введите новое имя файла или нажмите кнопку Создать, ' +
    'для создания директории.');
  Phrases.AddTranslation(lnNextVol , lRussian, 'Вставьте следующий диск ' +
    'или введите путь к следующему тому.');
  Phrases.AddTranslation(lnAccessError , lRussian, 'Ошибка открытия тома. ' +
    'Замените диск или введите правильный путь к файлу.');
  Phrases.AddTranslation(lnReplaceMsg , lRussian, 'Архивный том с таким ' +
    'именем уже существует. Введите другое имя '+
    'или подтвердите перезапись существующего файла.');
  Phrases.AddTranslation(lnOverwriteMsg , lRussian, 'Файл уже существует. ' +
    'Вы можете распаковать файл под другим именем или перезаписать ' +
    'существующий.');
  Phrases.AddTranslation(lnExtrList , lRussian, 'Чтение списка файлов в ' +
    'архиве. Укажите имя архива, список файлов из которого надо прочитать.');
  Phrases.AddTranslation(lnFilesIn , lRussian, 'Архив:');
  Phrases.AddTranslation(lnLZW , lRussian, 'LZW упаковка');
  Phrases.AddTranslation(lnNoPack , lRussian, 'Без упаковки');
  Phrases.AddTranslation(lnVolSize , lRussian, 'Размер тома (в Кб)');
  Phrases.AddTranslation(lnRecurse , lRussian, 'Заходить в поддиректории');
  Phrases.AddTranslation(lnIncludeMask , lRussian, 'Включить');
  Phrases.AddTranslation(lnExcludeMask , lRussian, 'Исключить');
  Phrases.AddTranslation(lnNoExtractFile , lRussian, 'Файл для распаковки ' +
    'не найден. Проверьте имя.');
  Phrases.AddTranslation(lnAccessDenied , lRussian, 'Доступ к файлу %s ' +
    'закрыт.');
  Phrases.AddTranslation(lnCannotOpen , lRussian, 'Невозможно открыть файл '+
    '%s. Пропустить?');
  Phrases.AddTranslation(lnUser , lRussian, 'Прерывание пользователя');
  Phrases.AddTranslation(lnNoFile , lRussian, 'Файл для распаковки не ' +
    'найден или испорчен.');
  Phrases.AddTranslation(lnWasterminated , lRussian, 'Создание архива ' +
    'не было завершено');
  Phrases.AddTranslation(lnHExtrL , lRussian, 'Считывание списка файлов ' +
    'в архиве');
  Phrases.AddTranslation(lnHExtr , lRussian, 'Распаковка файлов из архива');
  Phrases.AddTranslation(lnHCreating , lRussian, 'Архивное копирование');
  Phrases.AddTranslation(lnHComment , lRussian, 'Архивное копирование');
  Phrases.AddTranslation(lnHCreate , lRussian, 'Архивное копирование');
  Phrases.AddTranslation(lnHCreateDir , lRussian, 'Создать директорий');
  Phrases.AddTranslation(lnHBackup , lRussian, 'Backup');
  Phrases.AddTranslation(lnHreadlist , lRussian, 'Считать список файлов ' +
    'в архиве');
  Phrases.AddTranslation(lnHExtract , lRussian, 'Распаковать файлы в архиве');
  Phrases.AddTranslation(lnHCreated , lRussian, 'Архив создан');
  Phrases.AddTranslation(lnHExtracted , lRussian, 'Архив распакован');
  Phrases.AddTranslation(lnHFiles , lRussian, 'Список файлов в архиве');
  Phrases.AddTranslation(lnHOver , lRussian, 'Перезаписать файл');
  Phrases.AddTranslation(lnHOptions , lRussian, 'Опции для будущего архива');
  Phrases.AddTranslation(lnHVol , lRussian, 'Заменить том');
  Phrases.AddTranslation(lnHVolEr , lRussian, 'Невозможно создать/' +
    'считать том');
  Phrases.AddTranslation(lnHVolExists , lRussian, 'Том уже существует');

  { finalizing the process of registering backup messages }

  Phrases.ClearOrigin;

end.

