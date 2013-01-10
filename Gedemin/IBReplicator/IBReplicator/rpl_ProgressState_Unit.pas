unit rpl_ProgressState_Unit;

interface
type
  TProgressAction = (paBefore, paSucces, paError);

  TCustomProgressState = class
  private
    FMaxMinor: Integer;
  protected
    procedure SetMaxMinor(const Value: Integer); virtual;
  public
    procedure MajorProgress(Sender: TObject; ProgressAction: TProgressAction); virtual; abstract;
    procedure MinorProgress(Sender: TObject); virtual; abstract;
    procedure OnError(Sender: TObject; ErrorMessage: string); virtual;
    procedure Log(S: string); virtual;

    property MaxMinor: Integer read FMaxMinor write SetMaxMinor;
  end;

  TSimpleProgressState = class(TCustomProgressState)
  public
    procedure MajorProgress(Sender: TObject; ProgressAction: TProgressAction); override;
    procedure MinorProgress(Sender: TObject); override;
  end;

var
  ProgressState: TCustomProgressState;

implementation
{ TCustomProgressState }

procedure TCustomProgressState.Log(S: string);
begin

end;

procedure TCustomProgressState.OnError(Sender: TObject;
  ErrorMessage: string);
begin

end;

procedure TCustomProgressState.SetMaxMinor(const Value: Integer);
begin
  FMaxMinor := Value;
end;

{ TSimpleProgressState }

procedure TSimpleProgressState.MajorProgress(Sender: TObject;
  ProgressAction: TProgressAction);
begin
end;

procedure TSimpleProgressState.MinorProgress(Sender: TObject);
begin
end;

end.
