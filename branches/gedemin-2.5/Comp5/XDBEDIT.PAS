{
  Allow to use more Edit controls.

  1.00    21-Jan-98    DuzhV    Initial version.
}

unit Xdbedit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Mask, DBCtrls;

type
  TxEdit = class(TEdit)
  private
    { Private declarations }
    HEditDS: THandle;
  protected
    { Protected declarations }
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  public
    { Public declarations }
  published
    { Published declarations }
  end;

(*
   Extebded TDBEdit control
*)
type
  TxDBEdit = class(TDBEdit)
  private
    { Private declarations }
    HEditDS: THandle;
  protected
    { Protected declarations }
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

{---------TxEdit }
procedure TxEdit.CreateWindowHandle(const Params: TCreateParams);
begin
  HEditDS := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT or GMEM_SHARE, 256);
  if HEditDS = 0 then HEditDS := HInstance;
  with Params do
  begin
    WindowHandle := CreateWindowEx(ExStyle, WinClassName, '', Style,
      X, Y, Width, Height, WndParent, 0, HEditDS, Param);
    SendMessage(WindowHandle, WM_SETTEXT, 0, Longint(Caption));
  end;
end;

{---------TxDBEdit }
procedure TxDBEdit.CreateWindowHandle(const Params: TCreateParams);
begin
  HEditDS := GlobalAlloc(GMEM_MOVEABLE or GMEM_ZEROINIT or GMEM_SHARE, 256);
  if HEditDS = 0 then HEditDS := HInstance;
  with Params do
  begin
    WindowHandle := CreateWindowEx(ExStyle, WinClassName, '', Style,
      X, Y, Width, Height, WndParent, 0, HEditDS, Param);
    SendMessage(WindowHandle, WM_SETTEXT, 0, Longint(Caption));
  end;
end;

procedure Register;
begin
  RegisterComponents('xTool-3', [TxEdit]);
  RegisterComponents('xTool-3', [TxDBEdit]);
end;

end.
