{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gsKeyStokes.pas

  Abstract

    Gedemin project. TgsKeyStokes.

  Author

    Karpuk Alexander

  Revisions history

    1.00    02.09.02    tiptop        Initial version.
--}
unit gsKeyStrokes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  SynEditKeyCmds;

type
  TgsKeyStrokes = class(TComponent)
  private
    FKeyStrokes: TSynEditKeyStrokes;
    procedure SetKeyStrokes(const Value: TSynEditKeyStrokes);
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property KeyStrokes: TSynEditKeyStrokes read FKeyStrokes write
      SetKeyStrokes;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SynEdit', [TgsKeyStrokes]);
end;

{ TgsKeyStokes }

constructor TgsKeyStrokes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FKeyStrokes := TSynEditKeyStrokes.Create(Self);
  FKeyStrokes.ResetDefaults;
end;

destructor TgsKeyStrokes.Destroy;
begin
  FKeyStrokes.Free;
  inherited;
end;

procedure TgsKeyStrokes.SetKeyStrokes(const Value: TSynEditKeyStrokes);
begin
  if Value = nil then
    FKeystrokes.Clear
  else
    FKeystrokes.Assign(Value);
end;

end.
 