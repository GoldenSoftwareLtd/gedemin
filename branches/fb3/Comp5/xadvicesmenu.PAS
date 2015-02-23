unit xAdvicesMenu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type

  TClickLineEvent = procedure(Sender: TObject; LineIndex: Integer) of object;

  TxAdviceMenuPanel = class(TCustomControl)
  private
    FOnClick: TClickLineEvent;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LButtonUp;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure ShowMenu;

  public
    constructor Create(AnOwner: TComponent); override;
    property OnClick: TClickLineEvent read FOnClick write FOnClick;
  end;

  TxAdvicesMenu = class(TComponent)
  private
    FColor: TColor;
    xAdviceMenuPanel: TxAdviceMenuPanel;
    FOnClick: TClickLineEvent;
  protected
  public
    constructor Create(AnOwner: TComponent); override;
    procedure ShowMenu(Control: TWinControl; L, T: Integer);
  published
    property Color: TColor read FColor write FColor;
    property OnClick: TClickLineEvent read FOnClick write FOnClick;
  end;

procedure Register;

implementation

{$R XADVICESMENU.RES}

{TxAdviceMenuPanel ---------------------------------------}

constructor TxAdviceMenuPanel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Width := 176;
  Height := 223;
  Visible := False;
end;

procedure TxAdviceMenuPanel.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := ws_Popup;
end;

procedure TxAdviceMenuPanel.Paint;
var
  BMP: TBitmap;
begin
  BMP := TBitmap.Create;
  BMP.LoadFromResourceName(hInstance, 'ADVICESMENUBMP');
  try
    Canvas.Draw(0, 0, BMP);
  finally
    BMP.Free;
  end;
end;

procedure TxAdviceMenuPanel.ShowMenu;
begin
  MouseCapture := True;
  Show;
end;

procedure TxAdviceMenuPanel.WMLButtonUp(var Message: TWMLButtonUp);
var
  Line: Integer;
begin
  inherited;
  Hide;
  if (Message.XPos > 0) and (Message.XPos < Width) and
     (Message.YPos > 0) and (Message.YPos < Height) then
  begin
    Line := Trunc(Message.YPos / Height * 5);
    if Assigned(FOnclick) then
      FOnClick(Self, Line);
  end;
  MouseCapture := False;
end;

{TxAdvicesMenu -------------------------------------------}

constructor TxAdvicesMenu.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Color := clBtnFace;
  xAdviceMenuPanel := nil;
end;

procedure TxAdvicesMenu.ShowMenu(Control: TWinControl; L, T: Integer);
begin
  if (xAdviceMenuPanel = nil) then
    xAdviceMenuPanel := TxAdviceMenuPanel.Create(Self);
  xAdviceMenuPanel.OnClick := OnClick;
  xAdviceMenuPanel.Parent := Control;
  xAdviceMenuPanel.Left := L;
  xAdviceMenuPanel.Top := T;
  xAdviceMenuPanel.ShowMenu;
{  Application.OnActivate := DoOnActi;
  Application.OnDeActivate;}
end;

procedure Register;
begin
  RegisterComponents('Advices', [TxAdvicesMenu]);
end;

end.
