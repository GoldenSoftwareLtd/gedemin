
{ version 1.05 }

unit Part;

interface

uses
  WinTypes, WinProcs, Controls, Forms, SysUtils, Classes, Buttons;

{
  Every part must define unique integer constant PART_XXXX,
  where XXXX means part name, and sets property PartTag to
  this value at creation time.
}

type
  TPart = class(TForm)
  private
    FPartTag: Integer;

  protected
    procedure CreateParams(var Params: TCreateParams); override;

  public
    AssociatedButton: TSpeedButton;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure ChangeOption; virtual;

    property PartTag: Integer read FPartTag write FPartTag
      stored False;
  end;

  TPartClass = class of TPart;

implementation

{ TPart --------------------------------------------------}

constructor TPart.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  AssociatedButton := nil;
end;

procedure TPart.ChangeOption;
begin
end;

destructor TPart.Destroy;
begin
  { must precede call to inherited destructor }
  try
    if AssociatedButton <> nil then
      AssociatedButton.Down := False;
  except
    on Exception do ;
    else ;
    { AssociatedButton is invalid }
  end;

  inherited Destroy;
end;

procedure TPart.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  Params.Style := WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;
  if Owner is TWinControl then
    Params.WndParent := TWinControl(Owner).Handle
  else if Owner is TApplication then
    Params.WndParent := TApplication(Owner).MainForm.Handle
  else
    raise Exception.Create('Parent must be TWinControl');

  Params.WindowClass.hbrBackground := 0;
end;

initialization

//  ShowMessage('User');


end.
