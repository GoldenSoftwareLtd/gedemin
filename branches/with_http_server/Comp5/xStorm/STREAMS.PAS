{$DEFINE xTool}

{*******************************************************}
{                                                       }
{       xTool - Component Collection (non-visual)       }
{                                                       }
{       Copyright (c) 1995,96 Stefan Bother             }
{                                                       }
{*******************************************************}

{++

  Copyright (c) 1996 by Golden Software of Belarus

  Module

    streams.pas

  Abstract

    Streams to create multivolume packed binary files.

  Author

     Vladimir Belyi (1-March-1996)

  Contact address

    goldsoft%swatogor.belpak.minsk.by@demos.su

  Revisions history

    2.00  17-Jun-1996   Belyi   Adopted for 32-bit Delphi
                                (now both versions are supported)
    2.01   2-Jul-1996   Belyi   Modifications in Seek method
    2.02  30-Aug-1996   Belyi   Kill destructor added.
    2.02  30-Aug-1996   Belyi   Sender in all events.

--}


unit Streams;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, FileCtrl,
  FileList, Packers;

const
  VFSize = 20;
  VolumeFileID = 'Belarus';
  MaxVolumes = 100;

const
  vsAuto = 0; { Automatically arrange file size }

type
  TVolumeFile = record
    case boolean of
      true: (ID: string[7]; Vol: integer; IsLast: Boolean);
      false: (Bytes: Array[1..VFSize] of byte);
  end;

  TVolumes = record
    Count: integer;
    Sizes: array[0..MaxVolumes] of LongInt;
  end;

  TChangeVolume = procedure(Sender: TObject; Vol: integer;
    var FileName: string; var Continue: Boolean) of object;
  TCannotChangeVolume = procedure(Sender: TObject; Vol: integer;
    var FileName: string; var RunError: Boolean) of object;
  TReplaceVolume = procedure(Sender: TObject; Vol: integer;
    var FileName: string; var Replace: Boolean; var Continue: Boolean) of object;
  TAccessDenied = procedure(Sender: TObject; Filename: string;
    var RunError: boolean) of object;

type
  TVolumeStream = class(TStream)
  private
    CurrentVolume: TVolumeFile;
    CurrentPos: LongInt;
    GlobalPos: LongInt;
    CreationCompleted: Boolean;
    CreationMode: Word;

    Killing: Boolean;

    FHandle: integer;
    FVolumesSize: LongInt;
    Volumes: TVolumes;
    DiskFile: string; { current volume file name }
    VolumesName: string; { Name for the first (main) volume. By default,
                           further volumes will differ only by extension. }
    FOnOpenVolume: TChangeVolume;
    FOnCannotOpenVolume: TCannotChangeVolume;
    FOnCreateVolume: TChangeVolume;
    FOnCannotCreateVolume: TCannotChangeVolume;
    WorkMode: Word;
    FOnReplaceVolume: TReplaceVolume;
    FOnAccessDenied: TAccessDenied;
    FAutoReplaceVolumes: Boolean;

    procedure CreateVolume(Vol: integer);
    procedure OpenVolume(Vol: integer);
    procedure SetVolExt(Vol: integer);
    procedure CompleteCreate;
    procedure UpdateSizes;

  protected

  public
    constructor Create(const FileName: string; Mode: Word; VolSize: LongInt);
    destructor Destroy; override;
    procedure Kill; dynamic; { destroys a stream and erases file }

    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;

    property Handle: integer read FHandle;
    property VolumesSize: LongInt read FVolumesSize;
    property AutoReplaceVolumes: Boolean read FAutoReplaceVolumes
      write FAutoReplaceVolumes;
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
    property OnAccessDenied: TAccessDenied read FOnAccessDenied
      write FOnAccessDenied;
  end;


type
  TPackMethods = (pkNo, pkLZW);

const
  PackBufSize = 10000;

type
  TPackStream = class(TVolumeStream)
  private
    Pack: TPacker;
    SwapBuffer: ^ByteArray;
    SwapBufferHave: Word;
    HaveSwap: boolean;
    DataWasWritten: Boolean;
    FPackMethod: TPackMethods;
    procedure SetPackMethod(AMethod: TPackMethods);
    procedure WritePackBuffer(Sender: TObject; const Buffer; Count: word);
    procedure ReadPackBuffer(Sender: TObject; var Buffer; Count: word;
      var WasRead: Word);
  protected
  public
    constructor Create(const FileName: string; Mode: Word; VolSize: LongInt);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    property PackMethod: TPackMethods read FPackMethod
      write SetPackMethod;
  end;

type
  EVolumeError = class(Exception);
  EVolReadError = class(EVolumeError);
  EVolWriteError = class(EVolumeError);
  EVolCreateError = class(EVolumeError);
  EVolOpenError = class(EVolumeError);
  EVolInitError = class(EVolumeError);

  EPackError = class(EVolumeError);
  EPackOpenError = class(EPackError);
  EPackWriteError = class(EPackError);
  EPackReadError = class(EPackError);

  ETerminated = class(Exception);
  EVolExiststermination = class(ETerminated);


implementation

{ ---------------------- TVolStream --------------- }

constructor TVolumeStream.Create(const FileName: string; Mode: Word;
  VolSize: LongInt);
begin
  FAutoReplaceVolumes := false;
  Killing := false;
  WorkMode := Mode;
  FHandle := -1;
  if (VolSize<>vsAuto) and (VolSize < VFSize + 5) then
    raise EVolInitError.Create('Cannot work with volumes less than ' +
      IntToStr(VFSize + 5));
  FVolumesSize := VolSize;
  FillChar(Volumes, SizeOf(Volumes), 0);
  VolumesName := FileName;
  DiskFile := FileName;
  CreationCompleted := false;
  CreationMode := Mode;
  case Mode of
    fmCreate: ;
    fmOpenRead: ;
    else raise EVolInitError.Create('TVolumeStream supports only '+
                                    'fmCreate and fmOpenRead');
  end;
  GlobalPos := 0;
end;

procedure TVolumeStream.CompleteCreate;
begin
  CreationCompleted := true;
  case CreationMode of
    fmCreate: CreateVolume(0);
    fmOpenRead: OpenVolume(0);
    else raise EVolInitError.Create('TVolumeStream supports only '+
                                    'fmCreate and fmOpenRead');
  end;
  GlobalPos := 0;

end;

procedure TVolumeStream.SetVolExt(Vol: integer);
var
  s: string;
  i: Integer;
begin
  str(Vol:3, s);
  for i:=1 to 3 do
    if s[i]=' ' then s[i]:='0';
  DiskFile := ChangeFileExt(VolumesName, '.' + s);
  if Vol = 0 then DiskFile := VolumesName;
end;

procedure TVolumeStream.OpenVolume(Vol: integer);
var
  AHeader: TVolumeFile;
  OldHandle: Integer;
  OldFile: string;
  CanExit: Boolean;
  FirstCycle: Boolean;
  RaiseException: Boolean;
  ReadHeader: integer;
  Continue: Boolean;
begin
  CanExit := true;
  FirstCycle := true;
  RaiseException := false;
  OldFile := DiskFile;
  OldHandle := FHandle;
  repeat
    try
      if FirstCycle then
        begin
          SetVolExt(Vol);
          Continue := true;
          if Assigned(FOnOpenVolume) then
            FOnOpenVolume(self, Vol, DiskFile, Continue);
          if not Continue then
            begin
              DiskFile := '';
              raise ETerminated.Create('User termination');
            end;
          FirstCycle := false;
        end;
      FHandle := FileOpen(DiskFile, fmOpenRead);
      if FHandle < 0 then
        raise EVolOpenError.Create('Cannot open file ' + DiskFile);
      ReadHeader := FileRead(FHandle, AHeader, VFSize);
      if (ReadHeader <> SizeOf(AHeader)) or
         (AHeader.ID <> VolumeFileID) or
         (AHeader.Vol <> Vol) then
        raise EVolOpenError.Create('File is corrupted.');
      if OldHandle >= 0 then FileClose(OldHandle);
      CanExit := true;
      CurrentVolume := AHeader;
      CurrentPos := 0;
      if Vol > Volumes.Count then
        begin
          Volumes.Count := Vol;
          Volumes.Sizes[Vol] := FileGetSize(DiskFile) - VFSize;
        end;
    except
      on EVolumeError do
        begin
          CanExit := false;
          if FHandle >= 0 then FileClose(FHandle);
          RaiseException := true;
          if Assigned(FOnCannotOpenVolume) then
            FOnCannotOpenVolume(self, Vol, DiskFile, RaiseException);
          if RaiseException then
            begin
              DiskFile := OldFile;
              if FHandle >= 0 then FileClose(FHandle);
              FHandle := OldHandle;
              raise;
            end;
          FHandle := OldHandle;
        end;
    end;
  until CanExit;
end;

procedure TVolumeStream.CreateVolume(Vol: integer);
var
  AHeader: TVolumeFile;
  OldFile: string;
  CanExit: Boolean;
  FirstCycle: Boolean;
  RaiseException: Boolean;
  Written: LongInt;
  ReplaceIt: Boolean;
  Continue: Boolean;
begin
  CanExit := true;
  FirstCycle := true;
  RaiseException := false;
  OldFile := DiskFile;
  if FHandle >= 0 then
    begin
      FileClose(FHandle);
      Volumes.Sizes[CurrentVolume.Vol] := FileGetSize(OldFile) - VFSize;
    end;
  repeat
    try
      if FirstCycle then
        begin
          if (CurrentPos = 0) and (Vol <> 0)
           then if Assigned(FOnCannotCreateVolume) then
             begin
               Dec(Vol);
               {$IFDEF VER90} { Some problems with Delphi 2.0 were found: }
                DeleteFile(PChar(OldFile));
               {$ELSE}
                DeleteFile(OldFile);
               {$ENDIF}
               RaiseException := true;
               FOnCannotCreateVolume(self, Vol, DiskFile, RaiseException);
               if RaiseException then
                raise EVolCreateError.Create('Error writing to file ' +
                  DiskFile);
             end else
           else
             begin
               SetVolExt(Vol);
               Continue := true;
               if Assigned(FOnCreateVolume) and (Vol > 0) then
                 FOnCreateVolume(self, Vol, DiskFile, Continue);
               if not Continue then
                 begin
                   OldFile := '';
                   raise ETerminated.Create('User termination');
                 end;
             end;
          FirstCycle := false;
        end;
      ReplaceIt := AutoreplaceVolumes;
      if Assigned(FOnReplaceVolume) then
        while FileExists(DiskFile) and not(ReplaceIt) do
          begin
            ReplaceIt := true;
            Continue := true;
            FOnReplaceVolume(self, Vol, DiskFile, ReplaceIt, Continue);
            if not Continue then
              begin
                OldFile := '';
                raise EVolExistsTermination.Create('User termination');
              end;
          end;
      FHandle := FileCreate(DiskFile);
      if FHandle < 0 then
        raise EVolCreateError.Create('Cannot create file ' + DiskFile);
      AHeader.ID := VolumeFileID;
      AHeader.Vol := Vol;
      AHeader.IsLast :=false;
      Written := FileWrite(FHandle, AHeader, VFSize);
      if Written <> SizeOf(AHeader) then
        raise EVolCreateError.Create('Error writing to file ' + DiskFile);
      CanExit := true;
      CurrentVolume := AHeader;
      CurrentPos := 0;
      if Vol > Volumes.Count then
        begin
          Volumes.Count := Vol;
          Volumes.Sizes[Vol] := 0;
        end;
    except
      on EVolumeError do
        begin
          CanExit := false;
          if FHandle >= 0 then FileClose(FHandle);
          {$IFDEF VER90}
          DeleteFile(PChar(DiskFile));
          {$ELSE}
          DeleteFile(DiskFile);
          {$ENDIF}
          RaiseException := true;
          if Assigned(FOnCannotCreateVolume) then
            FOnCannotCreateVolume(self, Vol, DiskFile, RaiseException);
          if RaiseException then
            begin
              if FHandle >= 0 then FileClose(FHandle);
              DiskFile := OldFile;
              FHandle := FileOpen(DiskFile, fmOpenWrite);
              if FHandle >= 0 then FileSeek(FHandle,2,0);
              raise;
            end;
        end;
      on ETerminated do
        begin
          CanExit := false;
          DiskFile := OldFile;
          FHandle := FileOpen(DiskFile, fmOpenWrite);
          if FHandle >= 0 then FileSeek(FHandle,2,0);
          raise;
        end;
    end;
  until CanExit;
end;

destructor TVolumeStream.Destroy;
var
  RunError: Boolean;
  CanExit: Boolean;
begin
  if FHandle >= 0 then
    begin
      RunError := false;
      CanExit := false;
      if WorkMode = fmCreate then
        repeat
          CurrentVolume.IsLast := true;
          FileSeek(FHandle, 0, 0);
          if FileWrite(Handle, CurrentVolume, VFSize)<>VFSize
            then RunError := true else CanExit := true;
          if RunError and Assigned(FOnAccessDenied) then
            FOnAccessDenied(self, DiskFile, RunError);
        until CanExit or RunError;
      FileClose(FHandle);
      if RunError then
        raise EVolWriteError.Create('Cannot write to file ' + DiskFile);
    end;
  inherited destroy;
end;

procedure TVolumeStream.Kill;
begin
  Killing := true;
  if FHandle > 0 then
    begin
      FileClose(FHandle);
      FHandle := -1;
    end;
  if DiskFile <> '' then
    begin
      {$IFDEF VER90}
        DeleteFile(PChar(DiskFile));
      {$ELSE}
        DeleteFile(DiskFile);
      {$ENDIF}
    end;
  Free;
end;

procedure TVolumeStream.UpdateSizes;
begin
  Volumes.Sizes[CurrentVolume.Vol] := FileGetSize(DiskFile) - VFSize;
end;

function SizeOfFile(AHandle: Integer):LongInt;
var
  OldPos: LongInt;
begin
  OldPos := FileSeek(AHandle, 0, 1);
  if OldPos >= 0 then
    begin
      Result := FileSeek(AHandle, 0, 2);
      FileSeek(AHandle, OldPos, 0);
    end
  else Result := OldPos;
end;

function TVolumeStream.Read(var Buffer; Count: Longint): Longint;
var
  BufBytes: array[0..$ffff-1] of byte absolute Buffer;
  {ToRead, }WasRead: Longint;
  ForceExit: boolean;
  CanExit, RunError: Boolean;
  APos, ASize: LongInt;
begin
  if Killing then exit;
  if not CreationCompleted then CompleteCreate;
  WasRead := 0;
  ForceExit := false;
  Result := 0;
  while (WasRead < Count) and not ForceExit do
    begin
      repeat
        CanExit := false;
        RunError := false;
        Result := FileRead(Handle, BufBytes[WasRead], Count - WasRead);
        if Result = Count - WasRead then CanExit := true
          else RunError := true;
        APos := FileSeek(FHandle, 0, 1);
        ASize := SizeOfFile(FHandle);
        if RunError and (APos = ASize) then
          begin
            CanExit := true;
            RunError := false;
          end;
        if RunError and
           ((ASize < 0) or (APos < ASize)) and
           Assigned(FOnAccessDenied)
          then FOnAccessDenied(self, DiskFile, RunError);
      until RunError or CanExit;
      if Result = -1 then Result := 0;
      GlobalPos := GlobalPos + Result;
      try
        if (Result < Count - WasRead) then
          if not RunError then
            if CurrentVolume.IsLast then ForceExit := true
              else OpenVolume(CurrentVolume.Vol+1)
          else raise EVolReadError.Create('Access denied')
        else ;
      except
        on EVolumeError do
          begin
            CurrentPos := CurrentPos + Result;
            Result := WasRead + Result;
            raise;
          end;
      end;
      WasRead := WasRead + Result;
    end;
  CurrentPos := CurrentPos + Result;
  Result := WasRead;
end;

function TVolumeStream.Write(const Buffer; Count: Longint): Longint;
var
  BufBytes: array[0..$ffff-1] of byte absolute Buffer;
  ToWrite, Written: Longint;
  thisWrite: LongInt;
  CanExit: Boolean;
  RunError: Boolean;
begin
  if Killing then exit;
  if not CreationCompleted then CompleteCreate;
  if FHandle<0 then
     CreateVolume(CurrentVolume.Vol + 1);
  if FVolumesSize = vsAuto then
    begin
      Written := 0;
      while Written < Count do
        begin
          ThisWrite := FileWrite(Handle, BufBytes[Written], Count - Written);
          UpdateSizes;
          if ThisWrite = -1 then ThisWrite := 0;
          Written := Written + ThisWrite;
          CurrentPos := CurrentPos + thisWrite;
          if Written < count then
            CreateVolume(CurrentVolume.Vol + 1);
        end;
      Result := Written;
      GlobalPos := GlobalPos + Written;
    end
  else
    begin
      Result := 0;
      Written := 0;
      while Written < Count do
        begin
          ToWrite := FVolumesSize * 1024 - VFSize - CurrentPos;
          if ToWrite > Count - Written then ToWrite := Count - Written;
          RunError := false;
          CanExit := false;
          if ToWrite > 0 then
            repeat
              Result := FileWrite(Handle, BufBytes[Written], ToWrite);
              UpdateSizes;
              if Result = -1 then Result := 0;
              CurrentPos := CurrentPos + Result;
              GlobalPos := GlobalPos + Result;
              Written := Written + Result;
              if Result < ToWrite then RunError := true
                else CanExit := true;
              if RunError and Assigned(FOnAccessDenied) then
                FOnAccessDenied(self, DiskFile, RunError);
            until RunError or CanExit;
          result := Written;
          if RunError then
            raise EVolWriteError.Create('Cannot write to file ' + DiskFile);
          if written < Count then CreateVolume(CurrentVolume.Vol+1);
        end;
    end;
end;

function TVolumeStream.Seek(Offset: Longint; Origin: Word): Longint;
var
 i: integer;
 l: LongInt; 
begin { does not performs real seek }
  if not CreationCompleted then CompleteCreate;
  l := 0;
  for i:=0 to Volumes.Count do
    l := l + Volumes.Sizes[i];
  case Origin of
     0: { from begining }
       Result := Offset;
     1: { from current pos }
       Result := Globalpos + Offset;
     2: { from end }
       Result := l + Offset;
  end;
{  Seek := GlobalPos;}
end;

{-------------------------- TPackStream --------------------}
constructor TPackStream.Create(const FileName: string; Mode: Word; VolSize: LongInt);
begin
  inherited Create(FileName, Mode, VolSize);
  DataWasWritten := false;
  if Mode = fmOpenRead then
    begin
      if inherited read(FPackMethod, SizeOf(FPackMethod)) <>
         SizeOf(FPackMethod) then
        raise EPackReadError.Create('File is corrupted');
    end
  else
    FPackMethod := pkNo;
  Pack := nil;
  SetPackMethod(FPackMethod);
end;

destructor TPackStream.Destroy;
begin
  try
    Pack.Free;
  except
  end;
  inherited Destroy;
end;

procedure TPackStream.SetPackMethod(AMethod: TPackMethods);
begin
  if DataWasWritten then
    raise EPackError.Create('Cannot change packing method during packing');
  if (AMethod<>FPackMethod) or (Pack = nil) then
    begin
      FPackMethod := AMethod;
      if Pack<>nil then Pack.destroy;
      case AMethod of
        pkNo: Pack := TPacker.create(nil);
        pkLZW: Pack := TLZWPacker.create(nil);
        else Pack := TPacker.create(nil);
      end;
    end;
  Pack.BufferSize := PackBufSize;
  Pack.OnBufferFull := WritePackBuffer;
  Pack.OnBufferEmpty := ReadPackBuffer;
end;

procedure TPackStream.WritePackBuffer(Sender: TObject; const Buffer; Count: word);
var
  WasWritten: LongInt;
begin
  if not dataWasWritten then
    begin
      WasWritten := inherited Write(FPackMethod, SizeOf(FPackMethod));
      if WasWritten <> SizeOf(FPackMethod)  then
        raise EPackWriteError.Create('Data couldn''t be written');
      DataWasWritten := true;
    end;

  WasWritten := inherited Write(Buffer, Count);
  if WasWritten <> Count then
    raise EPackWriteError.Create('Data couldn''t be written');
end;

procedure TPackStream.ReadPackBuffer(Sender: TObject; var Buffer;
  Count: word; var WasRead: Word);
begin
  WasRead := inherited Read(Buffer, Count);
end;

function TPackStream.Read(var Buffer; Count: Longint): Longint;
begin
  Read := Pack.Decompress(Buffer, count);
end;

function TPackStream.Write(const Buffer; Count: Longint): Longint;
begin
  Pack.Compress(Buffer, Count);
  Result := Count;
end;


end.

{

Comments to the code:
  1) Seek in TVolumesStream does not performs real seek although it
     returns usually correct values (end of stream equals to the end of
     last used volume)

}
