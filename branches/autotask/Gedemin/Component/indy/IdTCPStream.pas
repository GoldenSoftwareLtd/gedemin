{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10369: IdTCPStream.pas 
{
{   Rev 1.0    2002.11.12 10:55:28 PM  czhower
}
unit IdTCPStream;

interface

uses
  Classes,
  IdTCPConnection;

type
  TIdTCPStream = class(TStream)
  protected
    FConnection: TIdTCPConnection;
    FWriteBuffering: Boolean;
    FWriteThreshold: Integer;
  public
    constructor Create(AConnection: TIdTCPConnection; const AWriteThreshold: Integer = 0); reintroduce;
    destructor Destroy; override;
    function Read(var ABuffer; ACount: Longint): Longint; override;
    function Write(const ABuffer; ACount: Longint): Longint; override;
    function Seek(AOffset: Longint; AOrigin: Word): Longint; override;
    //
    property Connection: TIdTCPConnection read FConnection;
  end;

implementation

{ TIdTCPStream }

constructor TIdTCPStream.Create(AConnection: TIdTCPConnection; const AWriteThreshold: Integer = 0);
begin
  inherited Create;
  FConnection := AConnection;
  FWriteThreshold := AWriteThreshold;
end;

destructor TIdTCPStream.Destroy;
begin
  if FWriteBuffering then begin
    Connection.CloseWriteBuffer;
  end;
  inherited Destroy;
end;

function TIdTCPStream.Read(var ABuffer; ACount: Integer): Longint;
begin
  Connection.ReadBuffer(ABuffer, ACount);
  Result := ACount;
end;

function TIdTCPStream.Seek(AOffset: Integer; AOrigin: Word): Longint;
begin
  Result := -1;
end;

type
  TIdTCPConnectionAccess = class(TIdTCPConnection)
  end;

function TIdTCPStream.Write(const ABuffer; ACount: Integer): Longint;
begin
  if (not FWriteBuffering) and (FWriteThreshold > 0) and
     (TIdTCPConnectionAccess(Connection).FWriteBuffer = nil) then
  begin
    Connection.OpenWriteBuffer(FWriteThreshold);
    FWriteBuffering := True;
  end;
  Connection.WriteBuffer(ABuffer, ACount);
  Result := ACount;
end;

end.
