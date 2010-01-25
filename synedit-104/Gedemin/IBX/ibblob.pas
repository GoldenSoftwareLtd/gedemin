{************************************************************************}
{                                                                        }
{       Borland Delphi Visual Component Library                          }
{       InterBase Express core components                                }
{                                                                        }
{       Copyright (c) 1998-2001 Borland Software Corporation             }
{                                                                        }
{    InterBase Express is based in part on the product                   }
{    Free IB Components, written by Gregory H. Deatz for                 }
{    Hoagland, Longo, Moran, Dunst & Doukas Company.                     }
{    Free IB Components is used under license.                           }
{                                                                        }
{    The contents of this file are subject to the InterBase              }
{    Public License Version 1.0 (the "License"); you may not             }
{    use this file except in compliance with the License. You may obtain }
{    a copy of the License at http://www.borland.com/interbase/IPL.html  }
{    Software distributed under the License is distributed on            }
{    an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either              }
{    express or implied. See the License for the specific language       }
{    governing rights and limitations under the License.                 }
{    The Original Code was created by InterBase Software Corporation     }
{       and its successors.                                              }
{    Portions created by Borland Software Corporation are Copyright      }
{       (C) Borland Software Corporation. All Rights Reserved.           }
{    Contributor(s): Jeff Overcash                                       }
{                                                                        }
{************************************************************************}

unit IBBlob;

interface

uses
  SysUtils, Classes, IBHeader, IBErrorCodes, IBExternals, DB, IB, IBDatabase, IBUtils;

const
  DefaultBlobSegmentSize = 16 * 1024; 

type
  { TIBBlobStream }
  TIBBlobStream = class(TStream)
  private
    FBase: TIBBase;
    //!!!b
    FReadBase: TIBBase;
    //!!!e
    FBlobID: TISC_QUAD;
    FBlobMaxSegmentSize,
    FBlobNumSegments,
    FBlobSize: Long;
    FBlobType: Short;  { 0 = segmented, 1 = streamed }
    FBuffer: PChar;
    FBlobInitialized: Boolean;
    FHandle: TISC_BLOB_HANDLE;
    FMode: TBlobStreamMode;
    FModified: Boolean;
    FPosition: Long;
  protected
    procedure CloseBlob;
    procedure CreateBlob;
    procedure EnsureBlobInitialized;
    procedure GetBlobInfo;
    function GetDatabase: TIBDatabase;
    function GetDBHandle: PISC_DB_HANDLE;
    function GetTransaction: TIBTransaction;
    function GetTRHandle: PISC_TR_HANDLE;
    procedure OpenBlob;
    procedure SetBlobID(Value: TISC_QUAD);
    procedure SetDatabase(Value: TIBDatabase);
    procedure SetMode(Value: TBlobStreamMode);
    procedure SetTransaction(Value: TIBTransaction);
    //!!!b
    procedure SetReadTransaction(Value: TIBTransaction);
    function GetReadTransaction: TIBTransaction;
    function GetReadTRHandle: PISC_TR_HANDLE;
    //!!!e
  public
    constructor Create;
    destructor Destroy; override;
    function Call(ErrCode: ISC_STATUS; RaiseError: Boolean): ISC_STATUS;
    procedure Cancel;
    procedure CheckReadable;
    procedure CheckWritable;
    procedure Finalize;
    procedure LoadFromFile(Filename: string);
    procedure LoadFromStream(Stream: TStream);
    function Read(var Buffer; Count: Longint): Longint; override;
    procedure SaveToFile(Filename: string);
    procedure SaveToStream(Stream: TStream);
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure SetSize(NewSize: Long); override;
    procedure Truncate;
    function Write(const Buffer; Count: Longint): Longint; override;
    property Handle: TISC_BLOB_HANDLE read FHandle;
    property BlobID: TISC_QUAD read FBlobID write SetBlobID;
    property BlobMaxSegmentSize: Long read FBlobMaxSegmentSize;
    property BlobNumSegments: Long read FBlobNumSegments;
    property BlobSize: Long read FBlobSize;
    property BlobType: Short read FBlobType;
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property DBHandle: PISC_DB_HANDLE read GetDBHandle;
    property Mode: TBlobStreamMode read FMode write SetMode;
    property Modified: Boolean read FModified;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;
    property TRHandle: PISC_TR_HANDLE read GetTRHandle;
    //!!!b
    property ReadTransaction: TIBTransaction read GetReadTransaction write SetReadTransaction;
    property ReadTRHandle: PISC_TR_HANDLE read GetReadTRHandle;
    //!!!e
  end;

  procedure GetBlobInfo(hBlobHandle: PISC_BLOB_HANDLE; var NumSegments, MaxSegmentSize,
                       TotalSize: Long; var BlobType: Short);
  procedure ReadBlob(hBlobHandle: PISC_BLOB_HANDLE; Buffer: PChar; BlobSize: Long);
  procedure WriteBlob(hBlobHandle: PISC_BLOB_HANDLE; Buffer: PChar; BlobSize: Long);

implementation

uses IBIntf, IBCustomDataSet;

procedure GetBlobInfo(hBlobHandle: PISC_BLOB_HANDLE; var NumSegments, MaxSegmentSize,
                      TotalSize: Long; var BlobType: Short);
var
  items: array[0..3] of Char;
  results: array[0..99] of Char;
  i, item_length: Integer;
  item: Integer;
begin
  items[0] := Char(isc_info_blob_num_segments);
  items[1] := Char(isc_info_blob_max_segment);
  items[2] := Char(isc_info_blob_total_length);
  items[3] := Char(isc_info_blob_type);

  if isc_blob_info(StatusVector, hBlobHandle, 4, @items[0], SizeOf(results),
                    @results[0]) > 0 then
    IBDatabaseError;

  i := 0;
  while (i < SizeOf(results)) and (results[i] <> Char(isc_info_end)) do
  begin
    item := Integer(results[i]); Inc(i);
    item_length := isc_vax_integer(@results[i], 2); Inc(i, 2);
    case item of
      isc_info_blob_num_segments:
        NumSegments := isc_vax_integer(@results[i], item_length);
      isc_info_blob_max_segment:
        MaxSegmentSize := isc_vax_integer(@results[i], item_length);
      isc_info_blob_total_length:
        TotalSize := isc_vax_integer(@results[i], item_length);
      isc_info_blob_type:
        BlobType := isc_vax_integer(@results[i], item_length);
    end;
    Inc(i, item_length);
  end;
end;

procedure ReadBlob(hBlobHandle: PISC_BLOB_HANDLE; Buffer: PChar; BlobSize: Long);
var
 CurPos: Long;
 BytesRead, SegLen: UShort;
 LocalBuffer: PChar;
begin
 CurPos := 0;
 LocalBuffer := Buffer;
 SegLen := UShort(DefaultBlobSegmentSize);
 while (CurPos < BlobSize) do
 begin
   if (CurPos + SegLen > BlobSize) then
     SegLen := BlobSize - CurPos;
   if not ((isc_get_segment(StatusVector, hBlobHandle, @BytesRead, SegLen,
                            LocalBuffer) = 0) or
           (StatusVectorArray[1] = isc_segment)) then
   begin
     if StatusVectorArray[1] = isc_segstr_eof then
       exit;
     IBDatabaseError;
   end;
   Inc(LocalBuffer, BytesRead);
   Inc(CurPos, BytesRead);
   BytesRead := 0;
 end;
end;

procedure WriteBlob(hBlobHandle: PISC_BLOB_HANDLE; Buffer: PChar;
  BlobSize: Long);
var
  CurPos, SegLen: Long;
begin
  CurPos := 0;
  SegLen := DefaultBlobSegmentSize;
  while (CurPos < BlobSize) do
  begin
    if (CurPos + SegLen > BlobSize) then
      SegLen := BlobSize - CurPos;
    if isc_put_segment(StatusVector, hBlobHandle, SegLen,
         PChar(@Buffer[CurPos])) > 0 then
      IBDatabaseError;
    Inc(CurPos, SegLen);
  end;
end;


{ TIBBlobStream }
constructor TIBBlobStream.Create;
begin
  inherited Create;
  FBase := TIBBase.Create(Self);
  //!!!b
  FReadBase := TIBBase.Create(Self);
  //!!!e
  FBuffer := nil;
  FBlobSize := 0;
end;

destructor TIBBlobStream.Destroy;
begin
  if (FHandle <> nil) and
     (Call(isc_close_blob(StatusVector, @FHandle), False) > 0) then
    IBDataBaseError;
  FBase.Free;
  //!!!b
  FReadBase.Free;
  //!!!e
  SetSize(0);
  inherited Destroy;
end;

function TIBBlobStream.Call(ErrCode: ISC_STATUS; RaiseError: Boolean): ISC_STATUS;
begin
  result := 0;
  if Transaction <> nil then
    result := Transaction.Call(ErrCode, RaiseError)
  else
    if RaiseError and (ErrCode > 0) then
      IBDataBaseError;
end;

procedure TIBBlobStream.CheckReadable;
begin
  if FMode = bmWrite then
    IBError(ibxeBlobCannotBeRead, [nil]);
end;

procedure TIBBlobStream.CheckWritable;
begin
  if FMode = bmRead then
    IBError(ibxeBlobCannotBeWritten, [nil]);
end;

procedure TIBBlobStream.CloseBlob;
begin
  Finalize;
  if (FHandle <> nil) and
     (Call(isc_close_blob(StatusVector, @FHandle), False) > 0) then
    IBDataBaseError;
end;

procedure TIBBlobStream.CreateBlob;
begin
  CheckWritable;
  FBlobID.gds_quad_high := 0;
  FBlobID.gds_quad_low := 0;
  Truncate;
end;

procedure TIBBlobStream.EnsureBlobInitialized;
begin
  if not FBlobInitialized then
    case FMode of
      bmWrite:
        CreateBlob;
      bmReadWrite: begin
        if (FBlobID.gds_quad_high = 0) and
           (FBlobID.gds_quad_low = 0) then
          CreateBlob
        else
          OpenBlob;
      end;
      else
        OpenBlob;
    end;
  FBlobInitialized := True;
end;

procedure TIBBlobStream.Finalize;
begin
  if (not FBlobInitialized) or (FMode = bmRead) then
    exit;
  { need to start writing to a blob, create one }
  Call(isc_create_blob2(StatusVector, DBHandle, TRHandle, @FHandle, @FBlobID,
                       0, nil), True);
  IBBlob.WriteBlob(@FHandle, FBuffer, FBlobSize);
  Call(isc_close_blob(StatusVector, @FHandle), True);
  FModified := False;
end;

procedure TIBBlobStream.GetBlobInfo;
var
  iBlobSize: Long;
begin
  IBBlob.GetBlobInfo(@FHandle, FBlobNumSegments, FBlobMaxSegmentSize,
    iBlobSize, FBlobType);
  SetSize(iBlobSize);
end;

function TIBBlobStream.GetDatabase: TIBDatabase;
begin
  result := FBase.Database;
end;

function TIBBlobStream.GetDBHandle: PISC_DB_HANDLE;
begin
  result := FBase.DBHandle;
end;

function TIBBlobStream.GetTransaction: TIBTransaction;
begin
  result := FBase.Transaction;
end;

function TIBBlobStream.GetTRHandle: PISC_TR_HANDLE;
begin
  result := FBase.TRHandle;
end;

procedure TIBBlobStream.LoadFromFile(Filename: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TIBBlobStream.LoadFromStream(Stream: TStream);
begin
  CheckWritable;
  EnsureBlobInitialized;
  Stream.Position := 0;
  SetSize(Stream.Size);
  if FBlobSize <> 0 then
    Stream.ReadBuffer(FBuffer^, FBlobSize);
  FModified := True;
end;

procedure TIBBlobStream.OpenBlob;
begin
  CheckReadable;
  Call(isc_open_blob2(StatusVector, DBHandle, ReadTRHandle, @FHandle,
                     @FBlobID, 0, nil), True);
  try
    GetBlobInfo;
    SetSize(FBlobSize);
    IBBlob.ReadBlob(@FHandle, FBuffer, FBlobSize);
  except
    Call(isc_close_blob(StatusVector, @FHandle), False);
    raise;
  end;
  Call(isc_close_blob(StatusVector, @FHandle), True);
end;

function TIBBlobStream.Read(var Buffer; Count: Longint): Longint;
begin
  CheckReadable;
  EnsureBlobInitialized;
  if (Count <= 0) then
  begin
    result := 0;
    exit;
  end;
  if (FPosition + Count > FBlobSize) then
    result := FBlobSize - FPosition
  else
    result := Count;
  Move(FBuffer[FPosition], Buffer, result);
  Inc(FPosition, Result);
end;

procedure TIBBlobStream.SaveToFile(Filename: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TIBBlobStream.SaveToStream(Stream: TStream);
begin
  CheckReadable;
  EnsureBlobInitialized;
  if FBlobSize <> 0 then
  begin
    Seek(0, soFromBeginning);
    Stream.WriteBuffer(FBuffer^, FBlobSize);
  end;
end;

function TIBBlobStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  EnsureBlobInitialized;
  case Origin of
    soFromBeginning     : FPosition := Offset;
    soFromCurrent	: Inc(FPosition, Offset);
    soFromEnd           : FPosition := FBlobSize + Offset;
  end;
  result := FPosition;
end;

procedure TIBBlobStream.SetBlobID(Value: TISC_QUAD);
begin
  System.Move(Value, FBlobID, SizeOf(TISC_QUAD));
  FBlobInitialized := False;
end;

procedure TIBBlobStream.SetDatabase(Value: TIBDatabase);
begin
  FBase.Database := Value;
  FBlobInitialized := False;
end;

procedure TIBBlobStream.SetMode(Value: TBlobStreamMode);
begin
  FMode := Value;
  FBlobInitialized := False;
end;

procedure TIBBlobStream.SetSize(NewSize: Long);
begin
  if (NewSize <> FBlobSize) then
  begin
    ReallocMem(FBuffer, NewSize);
    FBlobSize := NewSize;
    if NewSize = 0 then
      FBuffer := nil;
    if FPosition > FBlobSize then
      FPosition := FBlobSize;  
  end;
end;

procedure TIBBlobStream.SetTransaction(Value: TIBTransaction);
begin
  FBase.Transaction := Value;
  if FReadBase.Transaction = nil then
    FReadBase.Transaction := Value;
  FBlobInitialized := False;
end;

procedure TIBBlobStream.Truncate;
begin
  SetSize(0);
end;

function TIBBlobStream.Write(const Buffer; Count: Longint): Longint;
begin
  CheckWritable;
  EnsureBlobInitialized;
  result := Count;
  if Count <= 0 then
    exit;
  if (FPosition + Count > FBlobSize) then
    SetSize(FPosition + Count);
  Move(Buffer, FBuffer[FPosition], Count);
  Inc(FPosition, Count);
  FModified := True;
end;

procedure TIBBlobStream.Cancel;
begin
  if (not FBlobInitialized) or (FMode = bmRead) then
    exit;
  if FModified then
    OpenBlob;
  FModified := False;
end;

function TIBBlobStream.GetReadTransaction: TIBTransaction;
begin
  result := FReadBase.Transaction;
end;

function TIBBlobStream.GetReadTRHandle: PISC_TR_HANDLE;
begin
  result := FReadBase.TRHandle;
end;

procedure TIBBlobStream.SetReadTransaction(Value: TIBTransaction);
begin
  FReadBase.Transaction := Value;
  FBlobInitialized := False;
end;

end.
