// ShlTanya, 24.02.2019

unit gsComponentEmulator;

interface
uses extctrls, classes, Controls, windows;
type
  TgsComponentEmulator = class(TPanel)
  private

  protected
    FRelatedComponent: TComponent;
    FImage: TImage;
    function GetCompClass: TClass;
  public
    constructor Create(AOwner, ARelatedComponent: TComponent); reintroduce;
    destructor Destroy; override;
    property CompClass: TClass read GetCompClass;
    property RelatedComponent: TComponent read FRelatedComponent;
  end;

implementation

uses SysUtils, Forms;

{ TgsResiser_Emulator }

constructor TgsComponentEmulator.Create(AOwner, ARelatedComponent: TComponent);
begin
  Assert(Assigned(ARelatedComponent));
  inherited Create(AOwner);
  FRelatedComponent := ARelatedComponent;
  Width := 28;
  Height := 28;
  Align := alNone;
  Anchors := [];
  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;
  Constraints.MaxWidth := Width;
  Constraints.MinWidth := Width;
  Caption := '';
  Top := LongRec(FRelatedComponent.DesignInfo).Hi;
  Left := LongRec(FRelatedComponent.DesignInfo).Lo;

  if AOwner is TWinControl then
    Parent := TWinControl(AOwner);

  {JKL: commented}
//  Hint := FRelatedComponent.Name;
//  ShowHint := True;

  FImage := TImage.Create(Self);
  FImage.Align := alClient;
  FImage.Transparent := True;
  FImage.ParentShowHint := True;
  FImage.Center := True;
  FImage.Parent := Self;
  try
    if FindResource(hInstance, PChar(UpperCase(FRelatedComponent.ClassName)), RT_BITMAP) = 0 then
      try
        FImage.Picture.Bitmap.LoadFromResourceName(hInstance, 'DEFAULTCOMPONENT')
      except
      end
    else
      FImage.Picture.Bitmap.LoadFromResourceName(hInstance, UpperCase(FRelatedComponent.ClassName));
  except
  end;
  ControlStyle := ControlStyle + [csFixedWidth, csFixedHeight];
end;

destructor TgsComponentEmulator.Destroy;
begin
  FImage.Free;
  inherited;
end;

function TgsComponentEmulator.GetCompClass: TClass;
begin
  Result := FRelatedComponent.ClassType;
end;

end.
