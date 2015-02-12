unit ExtMenuItem;

interface

uses
  Classes, menus, TB2Item;

type
  {TExtMenuItem = Class(TMenuItem)
  private
    FObj: Tobject;
    FAsChildren: Boolean;

  public
    constructor Create(AOwner: TComponent); override;

    property Obj: Tobject read FObj write FObj;
    property AsChildren: Boolean read FAsChildren write FAsChildren;
  end;}

  TTBExtItem = Class(TTBItem)
  private
    FObj: Tobject;
    FAsChildren: Boolean;

  public
    constructor Create(AOwner: TComponent); override;

    property Obj: Tobject read FObj write FObj;
    property AsChildren: Boolean read FAsChildren write FAsChildren;
  end;

  {TTBExtSubmenuItem = class(TTBSubmenuItem)
  private
    function GetSubMenuStyle: Boolean;
    procedure SetSubMenuStyle(Value: Boolean);

  public
    property SubMenuStyle: Boolean read GetSubMenuStyle write SetSubMenuStyle;
  end;}

implementation

{ TExtMenuItem }

{constructor TExtMenuItem.Create(AOwner: TComponent);
begin
  inherited;
  FAsChildren := False;
  FObj := nil;
end;}

{ TTBExtItem }

constructor TTBExtItem.Create(AOwner: TComponent);
begin
  inherited;
  FAsChildren := False;
  FObj := nil;
end;

{procedure TTBExtSubmenuItem.SetSubMenuStyle(Value: Boolean);
begin
  if (tbisSubMenu in ItemStyle) <> Value then begin
    if Value then
      ItemStyle := ItemStyle + [tbisSubMenu]
    else
      ItemStyle := ItemStyle - [tbisSubMenu];
  end;
end;

function TTBExtSubmenuItem.GetSubMenuStyle: Boolean;
begin
  Result := tbisSubMenu in ItemStyle;
end;}

end.
