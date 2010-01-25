{******************************************}
{                                          }
{           FastReport v2.52               }
{             debug module                 }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit fr_debug;

interface

{$I fr.inc}

uses
  Windows, Classes, SysUtils, Contnrs;

type
  TfrLog = class (TObject)
  private
    f: TFileStream;
    idnt: integer;
    s: string;
    tstart, tend: integer;
    delta: double;
    DeltaStack: TStack;
    t: ^Integer;
    procedure Open;
    procedure Close;
    procedure Write(const str : string);
  public
    filename: string;
    constructor Create;
    destructor Destroy; override;
    procedure Event(const mess: string);
    procedure Error(const mess: string);
    procedure DeltaStart(const name: string);
    procedure DeltaStop;
  end;

implementation

{ TfrLog }

constructor TfrLog.Create;
begin
  filename := GetCurrentDir + '\debug.log';
  DeltaStack := TStack.Create;
  idnt := 0;
  Event('----');
end;

destructor TfrLog.Destroy;
begin
  Close;
  while DeltaStack.Count > 0 do
    FreeMem(DeltaStack.Pop);
  DeltaStack.Free;
  inherited;
end;

procedure TfrLog.DeltaStart(const name: string);
begin
  tstart := GetTickCount;
  t := AllocMem(SizeOf(Integer));
  t^ := tstart;
  DeltaStack.Push(t);
  Open;
  s := StringOfChar(' ', idnt) + IntToStr(tstart) + ' Start ' + name + #13;
  Write(s);
  Close;
  idnt := idnt + 2;
end;

procedure TfrLog.DeltaStop;
begin
  if DeltaStack.Count > 0 then
  begin
    tend := GetTickCount;
    t := DeltaStack.Pop;
    delta := (tend - t^) / 1000;
    FreeMem(t);
    if idnt > 0 then
      idnt := idnt - 2;
    Open;
    s := StringOfChar(' ', idnt) + IntToStr(tend) + ' Stop ' + FloatToStrF(delta, ffFixed, 4, 5) + #13;
    Write(s);
    Close;
  end;
end;

procedure TfrLog.Error(const mess: string);
begin
  Open;
  s := StringOfChar(' ', idnt) + IntToStr(GetTickCount) + ' ERROR ' + ': ' + mess + #13;
  Write(s);
  Close;
end;

procedure TfrLog.Event(const mess: string);
begin
  Open;
  s := StringOfChar(' ', idnt) + IntToStr(GetTickCount) + ' ' + mess + #13;
  Write(s);
  Close;
end;

procedure TfrLog.Close;
begin
  if Assigned(f) then
  begin
     f.Free;
     f := nil;
  end;
end;

procedure TfrLog.Open;
begin
  Close;
  if FileExists(filename) then
  begin
    f := TFileStream.Create(filename, fmOpenWrite);
    f.Seek(0, soFromEnd)
  end
  else
    f := TFileStream.Create(filename, fmCreate);
end;

procedure TfrLog.Write(const str: string);
begin
  f.Write(str[1], Length(str));
end;

end.
