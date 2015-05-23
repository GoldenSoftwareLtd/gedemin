unit wiz_frEditFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs,
  wiz_FunctionBlock_unit, StdCtrls, ComCtrls, Forms, BtnEdit, Menus,
  gdcBaseInterface, AcctUtils, Math, wiz_Strings_unit;

type
  TfrEditFrame = class(TFrame)
    PageControl: TPageControl;
    tsGeneral: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    lLocalName: TLabel;
    cbName: TComboBox;
    mDescription: TMemo;
    eLocalName: TEdit;
  private
    function GetBlockCaption: string;
  protected
    FBlock: TVisualBlock;
    FActiveEdit: TBtnEdit;

    { Private declarations }
  protected
    procedure SetBlock(const Value: TVisualBlock); virtual;
    procedure beClick(Sender: TObject; PopupMenu: TPopupMenu);

    function SetAccount(Account: string; out AccountID: Integer): string;
    function GetAccount(Account: string; AccountId: Integer): string;

    procedure ShowCheckOkMessage(const S: string);
    
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override;
    function CheckOk: Boolean; virtual;
    procedure SaveChanges; virtual;
    property Block: TVisualBlock read FBlock write SetBlock;
    property BlockCaption: string read GetBlockCaption;
  end;

implementation

{$R *.DFM}

  {$IFDEF LOCALIZATION}
uses
  {must be placed after Windows unit!}
  gd_localization_stub
  ;
  {$ENDIF}

{ TfrEditFrame }

procedure TfrEditFrame.beClick(Sender: TObject; PopupMenu: TPopupMenu);
var
  Point: TPoint;
begin
  if Sender is TEditSButton then
  begin
    Point.x := 0;
    Point.y := TEditSButton(Sender).Height - 1;
    Point := TEditSButton(Sender).ClientToScreen(Point);
    FActiveEdit := TEditSButton(Sender).Edit;
    PopupMenu.Popup(Point.X, Point.Y);
  end;
end;

function TfrEditFrame.CheckOk: Boolean;
begin
  Result := True;
  if FBlock <> nil then
  begin
    Result := CheckValidName(cbName.Text);
    if not Result then
    begin
      ShowCheckOkMessage(MSG_INVALID_NAME);
    end;
  end;
end;

constructor TfrEditFrame.Create(AOwner: TComponent);
begin
  inherited;
  PageControl.ActivePageIndex := 0;
end;

function TfrEditFrame.GetAccount(Account: string;
  AccountId: Integer): string;
begin
  if AccountId > 0 then
    Result := gdcBaseManager.GetRUIDStringById(AccountId)
  else
    Result := Account;
end;

function TfrEditFrame.GetBlockCaption: string;
begin
  if eLocalName.Text <> '' then
    Result := eLocalName.Text
  else
    Result := cbName.Text  
end;

procedure TfrEditFrame.Loaded;
var
  I: Integer;
  H: Integer;
begin
  inherited;
  H := 0;
  for I := 0 to ComponentCount - 1 do
  begin
    if (Components[I] is TControl) and (TControl(Components[I]).Align = alNone) then
    begin
      H := Max(H, TControl(Components[i]).Top + TControl(Components[I]).Height);
    end;
  end;
  Height := H + 5
end;

procedure TfrEditFrame.SaveChanges;
begin
  inherited;
  FBlock.BlockName := cbName.Text;
  FBlock.Description := mDescription.Lines.Text;
  FBlock.LocalName := eLocalName.Text;
end;

function TfrEditFrame.SetAccount(Account: string;
  out AccountID: Integer): string;
begin
  if CheckRUID(Account) then
    AccountId := gdcBaseManager.GetIDByRUIDString(Account)
  else
    AccountId := 0;

  if AccountId > 0 then
    Result := GetAlias(AccountId)
  else
    Result := Account;
end;

procedure TfrEditFrame.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
  cbName.Text := Value.BlockName;
  mDescription.Lines.Text := Value.Description;
  eLocalName.Text := Value.LocalName;
end;

procedure TfrEditFrame.ShowCheckOkMessage(const S: string);
begin
  MessageBox(Handle,
    PChar(S),
    'Внимание',
    MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
end;

end.
