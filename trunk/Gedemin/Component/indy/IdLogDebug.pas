{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10233: IdLogDebug.pas 
{
{   Rev 1.1    8/6/04 12:21:54 AM  RLebeau
{ Removed TIdLogDebugTarget type, not used anywhere
}
{
{   Rev 1.0    2002.11.12 10:44:10 PM  czhower
}
unit IdLogDebug;

interface

uses
  Classes,
  IdLogBase;

type
  TIdLogDebug = class(TIdLogBase)
  protected
    procedure LogStatus(const AText: string); override;
    procedure LogReceivedData(const AText: string; const AData: string); override;
    procedure LogSentData(const AText: string; const AData: string); override;
  end;

implementation

uses
  IdGlobal;

{ TIdLogDebug }

procedure TIdLogDebug.LogReceivedData(const AText, AData: string);
begin
  DebugOutput('Recv ' + AText + ': ' + AData);    {Do not Localize}
end;

procedure TIdLogDebug.LogSentData(const AText, AData: string);
begin
  DebugOutput('Sent ' + AText + ': ' + AData);    {Do not Localize}
end;

procedure TIdLogDebug.LogStatus(const AText: string);
begin
  DebugOutput('Stat ' + AText);    {Do not Localize}
end;

end.
