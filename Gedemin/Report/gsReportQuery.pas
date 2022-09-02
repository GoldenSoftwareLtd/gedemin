// ShlTanya, 26.02.2019

unit gsReportQuery;

interface

uses
  IBQuery, Classes, DBClient, SysUtils;

type
  TgsReportQuery = class(TIBQuery)
  protected
    procedure WriteDataPacket(Stream: TStream; WriteSize: Boolean; XMLFormat: Boolean = False);
  public
    procedure SaveToStream(Stream: TStream; Format: TDataPacketFormat = dfBinary);
  end;

procedure Register;

implementation

procedure TgsReportQuery.WriteDataPacket(Stream: TStream; WriteSize: Boolean;
  XMLFormat: Boolean = False);
var
  Size: Integer;
  DataPtr: Pointer;
begin
  RCS;
  if Active then CheckBrowseMode;
{  if IsCursorOpen then
  begin
    CheckProviderEOF;
    SaveDataPacket(XMLFormat);
  end;
  if Assigned(FSavedPacket) then
  begin
    Size := DataPacketSize(FSavedPacket);
    SafeArrayAccessData(FSavedPacket, DataPtr);
    try
      if WriteSize then
        Stream.Write(Size, SizeOf(Size));
      Stream.Write(DataPtr^, Size);
    finally
      SafeArrayUnAccessData(FSavedPacket);
    end;
    if Active then ClearSavedPacket;
  end;}
end;

procedure TgsReportQuery.SaveToStream(Stream: TStream; Format: TDataPacketFormat = dfBinary);
begin
  WriteDataPacket(Stream, False, (Format=dfXML));
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsReportQuery]);
end;

end.
