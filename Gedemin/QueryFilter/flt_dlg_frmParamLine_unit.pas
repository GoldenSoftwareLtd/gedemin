// ShlTanya, 10.03.2019

{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    flt_dlg_frmParamLine_unit.pas

  Abstract

    Gedemin project. Frame for main param window.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    20.10.01    JKL        Initial version.

--}

unit flt_dlg_frmParamLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls;

type
  TCommentHint = procedure (const AnComment: String; const X, Y: SmallInt) of object;

type
  Tdlg_frmParamLine = class(TFrame)
    lblName: TLabel;
    pmWhatIsIt: TPopupMenu;
    N1: TMenuItem;
    Bevel1: TBevel;
    procedure N1Click(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    FWinControl: TWinControl;
    FEventComment: TCommentHint;

    procedure SetComment(const AnComment: String);
    function GetComment: String;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddWinControl(AnWinControl: TWinControl);

    property WinControl: TWinControl read FWinControl;
    property Comment: String read GetComment write SetComment;
    property EventComment: TCommentHint read FEventComment write FEventComment;
  end;

const
  BLANK_SPACE_WIDTH = 8;

implementation

{$R *.DFM}

{ TfrmParamLine }

procedure Tdlg_frmParamLine.AddWinControl(AnWinControl: TWinControl);
var
  NewHeight: Integer;
begin
  FWinControl := AnWinControl;
  AnWinControl.Parent := Self;
  FrameResize(nil);
  NewHeight := FWinControl.ClientHeight + 4 + 2;
  if NewHeight > Height then Height := NewHeight;
  AnWinControl.Visible := True;
end;

constructor Tdlg_frmParamLine.Create(AOwner: TComponent);
begin
  inherited;

end;

destructor Tdlg_frmParamLine.Destroy;
begin
  FreeAndNil(FWinControl);

  inherited;
end;

function Tdlg_frmParamLine.GetComment: String;
begin
  Result := lblName.Hint;
end;

procedure Tdlg_frmParamLine.N1Click(Sender: TObject);
var
  TP: TPoint;
begin
  TP := Point(0, 0);
  TP := ClientToScreen(TP);
  if Assigned(FEventComment) then
    FEventComment(Comment, TP.x, TP.y);
end;

procedure Tdlg_frmParamLine.SetComment(const AnComment: String);
begin
  lblName.Hint := AnComment;
  if Trim(lblName.Hint) = '' then
    lblName.PopupMenu := nil;
end;

procedure Tdlg_frmParamLine.FrameResize(Sender: TObject);
begin
  if Assigned(FWinControl) then
  begin
    FWinControl.Width := (Width - BLANK_SPACE_WIDTH * 3) div 2;
    FWinControl.Left := Width - FWinControl.Width - BLANK_SPACE_WIDTH;
    FWinControl.Top := 2;
  end;
end;

end.
