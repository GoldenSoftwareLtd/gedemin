
{++

  Copyright (c) 1996-99 by Golden Software of Belarus

  Module

    xFileList.pas

  Abstract

    Generates list of files according to masks.

  Author

     Vladimir Belyi (1-March-1996)

  Contact address

    http://gs.open.by

  Revisions history

    2.00  14-June-1996  Vladimir Belyi   Support for Delphi 2.0 and
                                         long file names
    2.01  29-June-1996  Vladimir Belyi   Minor changes
    2.02  30-June-1999  Andreik          Added application process messages calls. 

--}

unit xFileList;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, xBasics;

type
  TCheckFile = procedure(FileName: string; CanAdd: Boolean) of object;
  TListReady = procedure(var ShortList, FullList: TStringList) of object;

type
  TSorting = (srNO, srName, srExt);
  TTextCases = (csDefault, csUpper, csLower);

const
  DefaultMask = '*.*';

type
  TxFileList = class(TComponent)
  private
    { Private declarations }
    Items: TStringList;
    FullItems: TStringList;
    DirChanged: Boolean;
    SizeChanged: Boolean;

    { for properties }
    FActive: Boolean;
    FInclude: TStringList;
    FExclude: TStringList;
    FOnCheckFile: TCheckFile;
    FSorting: TSorting;
    FTextCase: TTextCases;
    FGoSubDirs: Boolean;
    FOnListReady: TListReady;
    FFilesSize: LongInt;
    function GetNames(index: Integer): string;
    function GetFullNames(index: Integer): string;
    function GetList: TStringList;
    function GetFullNamesList: TStringList;
    procedure SetInclude(List: TStringList);
    procedure SetExclude(List: TStringList);
    procedure SetSorting(ASort: TSorting);
    procedure SetGoSubDirs(AGo: Boolean);
    function GetCount: Integer;
    procedure SetAnyList(AList: TStringList);
    procedure SetTextCase(ACase: TTextCases);
    function GetFilesSize: LongInt;

    procedure SomeListChanged(Sender: TObject);
    procedure CalcFilesSize;
    function CompareFiles(s1, s2: string): integer;
    procedure QuickSort(List: TStringList; L, R: Integer);
    procedure ReadDirectory(Dir: string; Mask: string; MainDirLen: Integer);
    procedure ReadFiles(Dir: string; Mask: string; MainDirLen: Integer{
     MainDir: string});
    procedure AddFile(FileName: string; MainDirLen: Integer); virtual;
    function ExpandInclude:TStringList;
    function ExpandExclude(InclList: TStringList):TStringList;
    function GetListIsfresh: Boolean;
    procedure SetListIsfresh(State: Boolean);
    procedure SetActive(const Value: Boolean);

  protected
    { Protected declarations }
    procedure ListIsRead; virtual;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateList; virtual;
    procedure Refresh;
    property Names[index: Integer]: string read GetNames; default;
    property FullNames[index: Integer]: string read GetFullNames;
    procedure Open;
    procedure Close;

  published
    { Published declarations }
    property Active: Boolean read FActive write SetActive;
    property ListIsFresh: Boolean read GetListIsFresh write SetListIsFresh
      stored false;
    property Count: integer read GetCount;
    property List: TStringList read GetList write SetAnyList;
    property FullNamesList: TStringList read GetFullNamesList write SetAnyList;
    property Include: TStringList read FInclude write SetInclude;
    property Exclude: TStringList read FExclude write SetExclude;
    property Sorting: TSorting read FSorting write SetSorting;
    property GoSubDirs: Boolean read FGoSubDirs write SetGoSubDirs;
    property TextCase: TTextCases read FTextCase write SetTextCase;
    property FilesSize: LongInt read GetFilesSize;
    property OnCheckFile: TCheckFile read FOnCheckFile write FOnCheckFile;
    property OnListReady: TListReady read FOnListReady write FOnListReady;
  end;

type
  EFileListError = class(Exception);

procedure Register;

function FileGetSize(AFile: string): LongInt;
function GetFilesDate(AFile: string): TDateTime;
function DeleteRef(s: string): string;
function GetDiskFileName(s: string): string;

implementation

function FileGetSize(AFile: string): LongInt;
var
  FileRec: TSearchRec;
begin
  if FindFirst(AFile, faAnyFile, FileRec)<>0 then
    raise EInOutError.Create('File not found.');
  FileGetSize := FileRec.Size;
end;

function GetFilesDate(AFile: string): TDateTime;
var
  FileRec: TSearchRec;
begin
  if FindFirst(AFile, faAnyFile, FileRec)<>0 then
    raise EInOutError.Create('File not found.');
  Result := FileDateToDateTime(FileRec.Time);
end;

{ usage of RealFileName function is recommended (see xBasics unit) }
function DeleteRef(s: string): string;
var
  d, d1: pchar;
begin
  Result := s;

  if Length(S) = 0 then
    exit;

  d := StrAlloc(1000);
  d1 := StrNew('x');
  try
    if s[1] = '%' then
      begin
        if length(s) = 2 then s := s + '\';
        case UpCase(s[2]) of
          'S': begin
                 GetSystemDirectory(d, 1000);
                 Result := StrPas(d);
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
          'W': begin
                 GetWindowsDirectory(d, 1000);
                 Result := StrPas(d);
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
      {$IFDEF VER80}
          'T': begin
                 GetTempFileName(GetTempDrive(#0), d1, 23, d);
                 Result := ExtractFilePath(StrPas(d));
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
      {$ELSE}
          'T': begin
                 GetTempPath(1000, d);
                 Result := StrPas(d);
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
      {$ENDIF}
          'D': begin
                 Result := ExtractFilePath(Application.ExeName);
                 if Result[ length(result) ] = '\' then
                    delete(Result, length(result), 1);
                 Result := Result + copy( s, 3, length(s)-2 );
               end;
        end;
      end;
  finally
    StrDispose(d);
    StrDispose(d1);
  end;
end;

function GetDiskFileName(s: string): string;
begin
  Result := DeleteRef(s);
  Result := ExpandFileName(Result);
end;

{---------------------- TxFileList ----------------------}
constructor TxFileList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSorting := srNo;
  FGoSubDirs := false;
  FTextCase := csDefault;
  Items := TStringList.Create;
  FullItems := TStringList.Create;
  FExclude := TStringList.Create;
  FExclude.OnChange := SomeListChanged;
  FInclude := TStringList.Create;
  FInclude.OnChange := SomeListChanged;
{  GetDir(0, CurDir);
  FInclude.Add(CurDir);}
  DirChanged := true;
  FActive := true;
  SizeChanged := true;
  FFilesSize := 0;
  FOnCheckFile := nil;
end;

destructor TxFileList.Destroy;
begin
  Items.Destroy;
  FullItems.Destroy;
  FExclude.Destroy;
  FInclude.Destroy;
  inherited Destroy;
end;

procedure TxFileList.SomeListChanged(Sender: TObject);
begin
  DirChanged := true;
end;

function TxFileList.GetListIsfresh: Boolean;
begin
  Result := (not DirChanged);
end;

procedure TxFileList.SetListIsfresh(State: Boolean);
begin
  DirChanged := not State;
end;

procedure TxFileList.AddFile(FileName: string; MainDirLen: Integer);
var
  CanAdd: Boolean;
  ShortName: string;
begin
  CanAdd:=true;
  if Assigned(FOnCheckFile) then
    FOnCheckFile(FileName, CanAdd);
  if not CanAdd then exit;

  ShortName := FileName;
{ ShortName := copy(FileName, MainDirLen+1,
    Length(FileName)-MainDirLen);}

  case TextCase of
    csDefault: begin
                 Items.Add(ShortName);
                 FullItems.Add(GetDiskFileName(FileName));
               end;
    csUpper: begin
               Items.Add(UpperCase(ShortName));
               FullItems.Add(UpperCase(GetDiskFileName(FileName)));
             end;
    csLower: begin
               Items.Add(LowerCase(ShortName));
               FullItems.Add(LowerCase(GetDiskFileName(FileName)));
             end;
  end;
end;

function TxFileList.CompareFiles(s1, s2: string): integer;
var
  cmp: Integer;
begin
  Result := 0;
  case FSorting of
    srName: CompareFiles := CompareText(s1, s2);
    srExt: begin
             cmp := CompareText(ExtractFileExt(s1),
                                ExtractFileExt(s2));
             if cmp=0 then CompareFiles := CompareText(s1, s2)
              else CompareFiles := cmp;
           end;
  end;
end;

procedure TxFileList.QuickSort(List: TStringList; L, R: Integer);
var
  I, J: Integer;
  Average: string;
begin
  I := L;
  J := R;
  Average := List[(L + R) shr 1];
  repeat
    while CompareFiles(List[I], Average) < 0 do Inc(I);
    while CompareFiles(List[J], Average) > 0 do Dec(J);
    if I <= J then
    begin
      List.Exchange(I, J);
      Inc(I);
      Dec(J);
    end;
  until I > J;
  if L < J then QuickSort(List, L, J);
  if I < R then QuickSort(List, I, R);
end;

procedure TxFileList.ReadFiles(Dir: string; Mask: string;
                              MainDirlen: Integer);
var
  Status: Integer;
  SearchRec: TSearchRec;
  TheDir: TStringlist;
  i: Integer;
begin
  TheDir := TStringList.Create;
  Status := FindFirst(DeleteRef(Dir) + Mask, faAnyFile, SearchRec);
  while Status = 0 do
   begin
     if (SearchRec.Attr and (faDirectory or faVolumeID) = 0) then
       TheDir.Add(Dir+Searchrec.Name);
     Status := FindNext(SearchRec);
   end;
  SysUtils.FindClose(SearchRec);
  if (FSorting<>srNo) and (TheDir.Count>0) then
    QuickSort(TheDir, 0, TheDir.Count-1);
  for i:=0 to TheDir.Count-1 do
    AddFile(TheDir[i], MainDirLen);
  TheDir.Destroy;
end;

procedure TxFileList.ReadDirectory(Dir: string; Mask: string;
                                  MainDirLen: integer);
var
  Status: Integer;
  TempName: string;
  SearchRec: TSearchRec;
  TheDir: TStringList;
  i: Integer;
begin
  TheDir := TStringList.Create;
  ReadFiles(Dir, Mask, MainDirLen);
  if FGoSubDirs then
    begin
      Status := FindFirst(DeleteRef(Dir) + DefaultMask, faDirectory, SearchRec);
      while Status = 0 do
       begin
         if (SearchRec.Attr and faDirectory = faDirectory) then
          begin
            TempName := SearchRec.Name;
            if (TempName <> '.') and (TempName <> '..') then
              TheDir.Add(Dir + TempName);
          end;
          Status := FindNext(SearchRec);
       end;
      SysUtils.FindClose(SearchRec);
    end;
  if (FSorting<>srNo) and (TheDir.Count>0) then
    QuickSort(TheDir, 0, TheDir.Count-1);
  for i:=0 to TheDir.Count-1 do
    ReadDirectory(TheDir[i] + '\', Mask, MainDirLen);
  TheDir.Destroy;
end;

procedure TxFileList.CreateList;
var
  i, j: Integer;
  ExcFull: TStringlist;
  SwapInclude: TStringList;
  SwapExclude: TStringList;
begin
  SizeChanged := True;

  SwapInclude := ExpandInclude;
  SwapExclude := ExpandExclude(SwapInclude);

  Items.Clear;
  FullItems.Clear;
  for i:=0 to FExclude.Count-1 do
  begin
    ReadDirectory(ExtractFilePath(SwapExclude.Strings[i]),
                  ExtractFileName(SwapExclude.Strings[i]),
                  Length(ExtractFilePath(SwapExclude.Strings[i])));
    //              
    Application.ProcessMessages;
  end;
  ExcFull := FullItems;
  SwapExclude.Destroy;

  FullItems := TStringList.Create;
  Items.Clear;
  FullItems.Clear;
  for i:=0 to FInclude.Count-1 do
  begin
    ReadDirectory(ExtractFilePath(SwapInclude.Strings[i]),
                  ExtractFileName(SwapInclude.Strings[i]),
                  Length(ExtractFilePath(SwapInclude.Strings[i])));

    //              
    Application.ProcessMessages;
  end;
  SwapInclude.Destroy;

  for i:=0 to ExcFull.Count-1 do
    begin
      ExcFull.strings[i] :=
        UpperCase(ExcFull.strings[i]);
      j:=0;
      while j<=Items.Count-1 do
        begin
          if UpperCase(FullItems.strings[j])=
               ExcFull.strings[i] then
            begin
              FullItems.delete(j);
              Items.delete(j);
            end
          else inc(j);
        end;
    end;
  ExcFull.Destroy;
  DirChanged:=false;
  ListIsRead;
end;

procedure TxFileList.ListIsRead;
begin
  if Assigned(FOnListReady) then FOnListReady(Items, FullItems);
  if Items.Count <> FullItems.Count then
    raise EFileListError.Create('Error in event-handler OnListReady');
end;

procedure TxFileList.SetActive(const Value: Boolean);
begin
  FActive := Value;
  if DirChanged and Active then CreateList;
end;

function TxFileList.GetNames(Index: integer): String;
begin
  if DirChanged and Active then CreateList;
  GetNames:=Items.Strings[index];
end;

function TxFileList.GetFullNames(Index: integer): String;
begin
  if DirChanged and Active then CreateList;
  GetFullNames:=FullItems.Strings[index];
end;

function TxFileList.GetList: TStringList;
begin
  if DirChanged and Active then CreateList;
  GetList:=Items;
end;

function TxFileList.GetFullNamesList: TStringList;
begin
  if DirChanged and Active then CreateList;
  GetFullNamesList := FullItems;
end;

procedure TxFileList.SetAnyList(AList: TStringList);
begin
{ nothing to be done by this routine (it is used to prevent errors
  created by Delphi when you press Ok button in list view window)
  for read-only lists}
end;

function TxFileList.GetCount: Integer;
begin
  if DirChanged and Active then CreateList;
  GetCount:=Items.Count;
end;

function TxFileList.ExpandInclude:TStringList;
var
  SwapList: TStringList;
  i: Integer;
  Attr: Integer;
begin
  SwapList := TStringList.Create;
  SwapList.Assign(FInclude);
  for i := 0 to SwapList.Count - 1 do
   with SwapList do
    begin
      if LastChar(Strings[i]) = ':' then
         Strings[i] := Strings[i] + '\';

      if LastChar(Strings[i]) <> '\' then
        begin
          Attr := FileGetAttr(Strings[i]);
          if Attr > 0 then
            if Attr and faDirectory <> 0 then
              Strings[i] := Strings[i] + '\';
        end;
      if LastChar(Strings[i]) = '\' then
         Strings[i] := Strings[i] + DefaultMask;
    end;
  Result := SwapList;
end;

function TxFileList.ExpandExclude(InclList: TStringList):TStringList;
var
  SwapList: TStringList;
  i, j: Integer;
  Attr: Integer;
  ADir: string;
begin
  SwapList := TStringList.Create;
  for i:=0 to InclList.Count-1 do
    begin
      ADir := ExtractFilePath(InclList.strings[i]);
      for j:=0 to FExclude.Count-1 do
        if (Length(FExclude[j])<2) or (FExclude[j][2]<>':') then
          if FExclude[j][1]='\' then
            SwapList.Add(copy(ADir, 1, Length(ADir) - 1) +
              FExclude[j])
          else
            SwapList.Add(ADir + FExclude[j])
    end;
  for j:=0 to FExclude.Count-1 do
    if (Length(FExclude[j])>2) and (FExclude[j][2]=':') then
      SwapList.Add(FExclude[j]);
  for i:=0 to SwapList.Count-1 do
   with SwapList do
    begin
      if Strings[i][Length(Strings[i])] = ':' then
         Strings[i] := Strings[i] + '\';
      if Strings[i][Length(Strings[i])] <> '\' then
        begin
          Attr := FileGetAttr(Strings[i]);
          if Attr > 0 then
            if Attr and faDirectory <> 0 then
              Strings[i] := Strings[i] + '\';
        end;
      if Strings[i][Length(Strings[i])] = '\' then
         Strings[i] := Strings[i] + DefaultMask;
    end;
  Result := SwapList;
end;

procedure TxFileList.SetInclude(List: tStringlist);
begin
  FInclude.Assign(List);
  DirChanged := true;
end;

procedure TxFileList.SetExclude(List: tStringlist);
begin
  FExclude.Assign(List);
  DirChanged := true;
end;

procedure TxFileList.SetSorting(ASort: TSorting);
begin
  if ASort<>FSorting then
    begin
      FSorting := ASort;
      DirChanged := true;
    end;
end;

procedure TxFileList.SetTextCase(ACase: TTextCases);
begin
  if ACase<>FTextCase then
    begin
      FTextCase := ACase;
      DirChanged := true;
    end;
end;

procedure TxFileList.SetGoSubDirs(AGo: Boolean);
begin
  if AGo<>FGoSubDirs then
    begin
      FGoSubDirs := AGo;
      DirChanged := true;
    end;
end;

procedure TxFileList.CalcFilesSize;
var
  i: integer;
begin
  FFilesSize := 0;
  for i:=0 to FullItems.Count-1 do
    begin
      FFilesSize := FFilesSize + FilegetSize(FullItems[i]);
    end;
  SizeChanged := false;
end;

function TxFileList.GetFilesSize: LongInt;
begin
  if DirChanged and Active then CreateList;
  if SizeChanged then CalcFilesSize;
  GetFilesSize := FFilesSize;
end;

procedure TxFileList.Refresh;
begin
  CreateList;
end;

procedure TxFileList.Open;
begin
  Active := true;
end;

procedure TxFileList.Close;
begin
  Active := false;
end;

{---------------------- Registration ----------------------}

procedure Register;
begin
  RegisterComponents('gsNV', [TxFileList]);
end;

end.

