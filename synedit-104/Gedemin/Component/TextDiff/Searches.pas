unit Searches;

//------------------------------------------------------------------------------
// Components        TSearch & TFileSearch                                     .
// Version:          2.1                                                       .
// Date:             16 March 2003                                             .
// Compilers:        Delphi 3 - Delphi 7                                       .
// Author:           Angus Johnson - angusj-AT-myrealbox-DOT-com               .
// Copyright:        © 2001 -2003  Angus Johnson                               .
//                                                                             .
// Description:      Delphi implementation of the                              .
//                   Boyer-Moore-Horspool search algorithm.                    .
//------------------------------------------------------------------------------

interface

uses
  windows, sysutils, classes;

type

  TBaseSearch = class(TComponent)
  private
     fPos            : pchar;
     fEnd            : pchar;
     fPattern        : string;
     fPatLen         : integer;
     fPatInitialized : boolean;
     fCaseSensitive  : boolean;
     JumpShift       : integer;
     Shift           : array[#0..#255] of integer;
     CaseBlindTable  : array[#0..#255] of char;
     procedure InitPattern;
     procedure MakeCaseBlindTable;
     procedure SetCaseSensitive(CaseSens: boolean);
     procedure SetPattern(const Pattern: string);
     function  FindCaseSensitive: integer;
     function  FindCaseInsensitive: integer;
  protected
     fStart          : pchar;
     fDataLength     : integer;
     procedure ClearData;
     procedure SetData(Data: pchar; DataLength: integer); virtual;
  public
     constructor Create(aowner: tcomponent); override;
     destructor  Destroy; override;
     //The following Find functions return the 0 based offset of Pattern
     //else POSITION_EOF (-1) if the Pattern is not found  ...
     function  FindFirst: integer;
     function  FindNext: integer;
     function  FindFrom(StartPos: integer): integer;
  published
     property CaseSensitive: boolean read fCaseSensitive write SetCaseSensitive;
     property  Pattern: string read fPattern write SetPattern;
  end;

  TSearch = class(TBaseSearch)
  public
    //Changes visibility of base SetData() method to public ...
    //Note: TSearch does NOT own the data. To avoid the overhead of
    //copying it, it just gets a pointer to it.
    procedure SetData(Data: pchar; DataLength: integer); override;
  end;

  TFileSearch = class(TBaseSearch)
  private
    fFilename: string;
    procedure SetFilename(const Filename: string);
    procedure Closefile;
  public
    destructor Destroy; override;
  published
    //Assigning 'Filename' creates a memory map of the named file.
    //This memory mapping will be closed when either the Filename property is
    //assigned to '' or the FileSearch object is destroyed.
    property Filename: string read fFilename write SetFilename;
  end;

procedure Register;

const
  POSITION_EOF = -1;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TSearch, TFileSearch]);
end;

//------------------------------------------------------------------------------
// TBaseSearch methods ...
//------------------------------------------------------------------------------

procedure TBaseSearch.MakeCaseBlindTable;
var
  i: char;
begin
  for i:= #0 to #255 do
     CaseBlindTable[i]:= ansilowercase(i)[1];
end;
//------------------------------------------------------------------------------

constructor TBaseSearch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fStart := nil;
  fPattern := '';
  fPatLen := 0;
  MakeCaseBlindTable;
  fCaseSensitive := false;      //Default to case insensitive searches.
  fPatInitialized := false;
end;
//------------------------------------------------------------------------------

destructor TBaseSearch.Destroy;
begin
  ClearData;
  inherited Destroy;
end;
//------------------------------------------------------------------------------

procedure TBaseSearch.ClearData;
begin
  fStart := nil;
  fPos := nil;
  fEnd := nil;
  fDataLength := 0;
end;
//------------------------------------------------------------------------------

procedure TBaseSearch.SetPattern(const Pattern: string);
begin
  if fPattern = Pattern then exit;
  fPattern := Pattern;
  fPatLen := length(Pattern);
  fPatInitialized := false;
end;
//------------------------------------------------------------------------------
procedure TBaseSearch.SetData(Data: pchar; DataLength: integer);
begin
  ClearData;
  if (Data = nil) or (DataLength < 1) then exit;
  fStart := Data;
  fDataLength := DataLength;
  fEnd := fStart + fDataLength;
end;
//------------------------------------------------------------------------------

procedure TBaseSearch.SetCaseSensitive(CaseSens: boolean);
begin
  if fCaseSensitive = CaseSens then exit;
  fCaseSensitive := CaseSens;
  fPatInitialized := false;
end;
//------------------------------------------------------------------------------

procedure TBaseSearch.InitPattern;
var
  j: integer;
  i: char;
begin
  if fPatLen = 0 then exit;
  for i := #0 to #255 do Shift[i]:= fPatLen;
  if fCaseSensitive then
  begin
    for j := 1 to fPatLen-1 do
      Shift[fPattern[j]]:= fPatLen - j;
    JumpShift := Shift[fPattern[fPatLen]];
    Shift[fPattern[fPatLen]] := 0;
  end else
  begin
    for j := 1 to fPatLen-1 do
      Shift[CaseBlindTable[fPattern[j]]]:= fPatLen - j;
    JumpShift := Shift[CaseBlindTable[fPattern[fPatLen]]];
    Shift[CaseBlindTable[fPattern[fPatLen]]] := 0;
  end;
  fPatInitialized := true;
end;
//------------------------------------------------------------------------------

function TBaseSearch.FindFirst: integer;
begin
  fPos := fStart+fPatLen-1;
  result := FindNext;
end;
//------------------------------------------------------------------------------

function TBaseSearch.FindFrom(StartPos: integer): integer;
begin
  if StartPos < fPatLen-1 then  //ie: StartPos must never be less than fPatLen-1
    fPos := fStart+fPatLen-1 else   
    fPos := fStart+StartPos;
  result := FindNext;
end;
//------------------------------------------------------------------------------

function TBaseSearch.FindNext: integer;
begin
  if not fPatInitialized then InitPattern;
  if (fPatLen = 0) or (fPatLen > fDataLength) or (fPos >= fEnd) then //2003.05.07
  begin
     fPos := fEnd;
     result := POSITION_EOF;
     exit;
  end;
  if fCaseSensitive then
    result := FindCaseSensitive else
    result := FindCaseInsensitive;
end;
//------------------------------------------------------------------------------

function TBaseSearch.FindCaseSensitive: integer;
var
  i: integer;
  j: pchar;
begin
  result:= POSITION_EOF;
  while fPos < fEnd do
  begin
    i := Shift[fPos^];        //test last character first
    if i <> 0 then            //last char does not match
      inc(fPos,i)
    else
    begin                     //last char matches at least
      i := 1;
      j := fPos - fPatLen;
      while (i < fPatLen) and (fPattern[i] = (j+i)^) do inc(i);
      if (i = fPatLen) then
      begin
         result:= fPos-fStart-fPatLen+1;
         inc(fPos,fPatLen);
         break;               //FOUND!
      end
      else
        inc(fPos,JumpShift);
    end;
  end;
end;
//------------------------------------------------------------------------------

function TBaseSearch.FindCaseInsensitive: integer;
var
  i: integer;
  j: pchar;
begin
  result:= POSITION_EOF;
  while fPos < fEnd do
  begin
    i := Shift[CaseBlindTable[fPos^]];   //test last character first
    if i <> 0 then                       //last char does not match
      inc(fPos,i)
    else
    begin                                //last char matches at least
      i := 1;
      j := fPos - fPatLen;
      while (i < fPatLen) and
            (CaseBlindTable[fPattern[i]] = CaseBlindTable[(j+i)^]) do inc(i);
      if (i = fPatLen) then
      begin
         result:= fPos-fStart-fPatLen+1;
         inc(fPos,fPatLen);
         break;                          //FOUND!
      end
      else
        inc(fPos,JumpShift);
    end;
  end;
end;

//------------------------------------------------------------------------------
// TSearch methods ...
//------------------------------------------------------------------------------

procedure TSearch.SetData(Data: pchar; DataLength: integer);
begin
  inherited; //changes visibility of base method from protected to public
end;

//------------------------------------------------------------------------------
// TFileSearch methods ...
//------------------------------------------------------------------------------

destructor TFileSearch.Destroy;
begin
  CloseFile;
  inherited Destroy;
end;
//------------------------------------------------------------------------------

procedure TFileSearch.SetFilename(const Filename: string);
var
   filehandle: integer;
   filemappinghandle: thandle;
   size, highsize: integer;
begin
  if (csDesigning in ComponentState) then
  begin
    fFilename := Filename;
    exit;
  end;
  CloseFile;
  if (Filename = '') or not FileExists(Filename) then exit;
  filehandle := sysutils.FileOpen(Filename, fmopenread or fmsharedenynone);
  if filehandle = 0 then exit; 		       //error
  size := GetFileSize(filehandle, @highsize);
  if (size <= 0) or (highsize <> 0) then      //nb: files >2 gig not supported
  begin
     CloseHandle(filehandle);
     exit;
  end;
  filemappinghandle := CreateFileMapping(filehandle, nil, page_readonly, 0, 0, nil);
  if GetLastError = error_already_exists then filemappinghandle := 0;
  if filemappinghandle <> 0 then
    SetData(MapViewOfFile(filemappinghandle,file_map_read,0,0,0),size);
  if fStart <> nil then fFilename := Filename;
  CloseHandle(filemappinghandle);
  CloseHandle(filehandle);
end;
//------------------------------------------------------------------------------

procedure TFileSearch.CloseFile;
begin
   if (csDesigning in ComponentState) then exit;
   if (fStart <> nil) then UnmapViewOfFile(fStart);
   fFilename := '';
   ClearData;
end;
//------------------------------------------------------------------------------

end.
