{
--------------------------------------------------------------------------
Copyright (c) 2000, Chris Morris 
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. The names Chris Morris, cLabs and the names of contributors to this 
software may be used to endorse or promote products derived from this software 
without specific prior written permission. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS'' 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE 
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
-------------------------------------------------------------------------------- 
(based on BSD Open Source License) 
}
unit IncVerRcUnit;

interface

uses SysUtils, Classes;

type
  TVersionInfo = class(TObject)
  private
    FRelease: integer;
    FMajor: integer;
    FBuild: integer;
    FMinor: integer;
    function GetVersionString: string;
    procedure SetBuild(const Value: integer);
    procedure SetMajor(const Value: integer);
    procedure SetMinor(const Value: integer);
    procedure SetRelease(const Value: integer);
  public
    property Build: integer read FBuild write SetBuild;
    property Major: integer read FMajor write SetMajor;
    property Minor: integer read FMinor write SetMinor;
    property Release: integer read FRelease write SetRelease;
    property VersionString: string read GetVersionString;
  end;

  TIncVerRc = class(TObject)
  private
    FRcFileName: string;
    FVersionInfo: TVersionInfo;
    procedure SetVersionInfo(const Value: TVersionInfo);
  public
    constructor Create(ARcFileName: string);
    destructor Destroy; override;
    function IncBuild: boolean;
    property VersionInfo: TVersionInfo read FVersionInfo write SetVersionInfo;
  end;

const
  FILE_VERSION_TOKEN = 'FILEVERSION';
  PRODUCT_VERSION_TOKEN = 'PRODUCTVERSION';

implementation

{ TIncVerRc }

constructor TIncVerRc.Create(ARcFileName: string);
begin
  FRcFileName := ARcFileName;
  FVersionInfo := TVersionInfo.Create;
end;

destructor TIncVerRc.Destroy;
begin
  FVersionInfo.Free;
  inherited;
end;

function TIncVerRc.IncBuild: boolean;
var
  InFile: TextFile;
  InFileStream: TStream;
  OutFile: TextFile;
  OutFileName: string;
  InFileLn: string;
  OutFileLn: string;
  AParser: TParser;
  IntVer: array[0..3] of integer;
  IntVerInc: integer;
  BuildIntFound: boolean;
  OldBuildStrA: string;
  OldBuildStrB: string;
  NewBuildStrA: string;
  NewBuildStrB: string;
  TokenType: Char;
begin
  OutFileName := FRcFileName + '.tmp';
  if FileExists(OutFileName) then
    DeleteFile(OutFileName);

  InFileStream := TFileStream.Create(FRcFileName,
    fmOpenRead or fmShareExclusive);
  InFileStream.Seek(0, soFromBeginning);
  AParser := TParser.Create(InFileStream);
  BuildIntFound := false;
  try
    while true do
    begin
      case AParser.NextToken of
      toEOF:     break;
      toSymbol:
        begin
          if (UpperCase(AParser.TokenString) = FILE_VERSION_TOKEN) or
            (UpperCase(AParser.TokenString) = PRODUCT_VERSION_TOKEN) then
          begin
            BuildIntFound := true;
            for IntVerInc := 0 to 3 do
            begin
              repeat
                TokenType := AParser.NextToken;
              until (TokenType <= #5);
              if TokenType <> toInteger then
              begin
                BuildIntFound := false;
                break;
              end;
              IntVer[IntVerInc] := AParser.TokenInt;
            end;
            break;
          end;
        end;
      end;
    end;
  finally
    AParser.Free;
    InFileStream.Free;
  end;

  if BuildIntFound then
  begin
    FVersionInfo.Major   := IntVer[0];
    FVersionInfo.Minor   := IntVer[1];
    FVersionInfo.Release := IntVer[2];
    FVersionInfo.Build   := IntVer[3];

    OldBuildStrA := IntToStr(FVersionInfo.Major) + ', ' +
                    IntToStr(FVersionInfo.Minor) + ', ' +
                    IntToStr(FVersionInfo.Release) + ', ' +
                    IntToStr(FVersionInfo.Build);
    OldBuildStrB := IntToStr(FVersionInfo.Major) + '.' +
                    IntToStr(FVersionInfo.Minor) + '.' +
                    IntToStr(FVersionInfo.Release) + '.' +
                    IntToStr(FVersionInfo.Build);
    NewBuildStrA := IntToStr(FVersionInfo.Major) + ', ' +
                    IntToStr(FVersionInfo.Minor) + ', ' +
                    IntToStr(FVersionInfo.Release) + ', ' +
                    IntToStr(FVersionInfo.Build + 1);
    NewBuildStrB := IntToStr(FVersionInfo.Major) + '.' +
                    IntToStr(FVersionInfo.Minor) + '.' +
                    IntToStr(FVersionInfo.Release) + '.' +
                    IntToStr(FVersionInfo.Build + 1);

    AssignFile(InFile, FRcFileName);
    Reset(InFile);

    AssignFile(OutFile, OutFileName);
    Rewrite(OutFile);

    while not Eof(InFile) do
    begin
      ReadLn(InFile, InFileLn);
      OutFileLn := StringReplace(InFileLn, OldBuildStrA, NewBuildStrA,
        [rfReplaceAll, rfIgnoreCase]);
      OutFileLn := StringReplace(OutFileLn, OldBuildStrB, NewBuildStrB,
        [rfReplaceAll, rfIgnoreCase]);
      WriteLn(OutFile, OutFileLn);
    end;

    CloseFile(InFile);
    CloseFile(OutFile);

    DeleteFile(FRcFileName);
    RenameFile(OutFileName, FRcFileName);
    Result := true;
  end
  else begin
    DeleteFile(OutFileName);
    Result := false;
  end;
end;

procedure TIncVerRc.SetVersionInfo(const Value: TVersionInfo);
begin
  FVersionInfo := Value;
end;

{ TVersionInfo }

function TVersionInfo.GetVersionString: string;
begin
  Result := IntToStr(FMajor) + '.' +
            IntToStr(FMinor) + '.' +
            IntToStr(FRelease) + '.' +
            IntToStr(FBuild);
end;

procedure TVersionInfo.SetBuild(const Value: integer);
begin
  FBuild := Value;
end;

procedure TVersionInfo.SetMajor(const Value: integer);
begin
  FMajor := Value;
end;

procedure TVersionInfo.SetMinor(const Value: integer);
begin
  FMinor := Value;
end;

procedure TVersionInfo.SetRelease(const Value: integer);
begin
  FRelease := Value;
end;

end.

