
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Report dataset               }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DSet;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes;

type
  TRangeBegin = (rbFirst, rbCurrent);
  TRangeEnd = (reLast, reCurrent, reCount);
  TCheckEOFEvent = procedure(Sender: TObject; var Eof: Boolean) of object;

  TfrDataset = class(TComponent)
  protected
    FRangeBegin: TRangeBegin;
    FRangeEnd: TRangeEnd;
    FRangeEndCount: Integer;
    FOnFirst, FOnNext, FOnPrior: TNotifyEvent;
    FOnCheckEOF: TCheckEOFEvent;
    FRecNo: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Init; virtual;
    procedure Exit; virtual;
    procedure First; virtual;
    procedure Next; virtual;
    procedure Prior; virtual;
    function Eof: Boolean; virtual;
    property RangeBegin: TRangeBegin read FRangeBegin write FRangeBegin default rbFirst;
    property RangeEnd: TRangeEnd read FRangeEnd write FRangeEnd default reLast;
    property RangeEndCount: Integer read FRangeEndCount write FRangeEndCount default 0;
    property RecNo: Integer read FRecNo;
    property OnCheckEOF: TCheckEOFEvent read FOnCheckEOF write FOnCheckEOF;
    property OnFirst: TNotifyEvent read FOnFirst write FOnFirst;
    property OnNext: TNotifyEvent read FOnNext write FOnNext;
    property OnPrior: TNotifyEvent read FOnPrior write FOnPrior;
  end;

  TfrUserDataset = class(TfrDataset)
  published
    property RangeBegin;
    property RangeEnd;
    property RangeEndCount;
    property OnCheckEOF;
    property OnFirst;
    property OnNext;
    property OnPrior;
  end;

implementation

constructor TfrDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RangeBegin := rbFirst;
  RangeEnd := reLast;
end;

procedure TfrDataSet.Init;
begin
end;

procedure TfrDataSet.Exit;
begin
end;

procedure TfrDataSet.First;
begin
  FRecNo := 0;
  if Assigned(FOnFirst) then FOnFirst(Self);
end;

procedure TfrDataSet.Next;
begin
  Inc(FRecNo);
  if not ((FRangeEnd = reCount) and (FRecNo >= FRangeEndCount)) then
    if Assigned(FOnNext) then FOnNext(Self);
end;

procedure TfrDataSet.Prior;
begin
  Dec(FRecNo);
  if Assigned(FOnPrior) then FOnPrior(Self);
end;

function TfrDataSet.Eof: Boolean;
begin
  Result := False;
  if (FRangeEnd = reCount) and (FRecNo >= FRangeEndCount) then Result := True;
  if Assigned(FOnCheckEOF) then FOnCheckEOF(Self, Result);
end;


end.
