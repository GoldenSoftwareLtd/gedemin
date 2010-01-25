unit Xemplref;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  xEmployeeRef = class(TComponent)

  private
    { Private declarations }
    FEmplKey: LongInt;
    FWorkDate: TDateTime;

{    procedure ClearFields;}

    procedure SetEmplKey(AEmplKey: LongInt);
    procedure SetWorkDate(ADate: TDateTime);
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure ClearProperties;
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property WorkDate: TDateTime read FWorkDate write SetWorkDate;
  published
    { Published declarations }
  end;

procedure Register;

implementation

constructor xEmployeeRef.Create(Owner: TComponent);
begin
  inherited Create(Owner);
end;

destructor xEmployeeRef.Destroy;
begin
  inherited Destroy;
end;

procedure xEmployeeRef.ClearProperties;
begin
  FWorkDate := 0;
end;

procedure xEmployeeRef.SetEmplKey(AEmplkey: LongInt);
begin
  FEmplKey := AEmplKey;
  ClearProperties;
end;

procedure xEmployeeRef.SetWorkDate(ADate: TDateTime);
begin
  ClearProperties;
  FWorkDate := ADate;
end;

procedure Register;
begin
  RegisterComponents('xWage', [xEmployeeRef]);
end;

end.
