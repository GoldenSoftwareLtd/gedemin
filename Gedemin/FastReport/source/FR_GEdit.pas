
{******************************************}
{                                          }
{             FastReport v2.53             }
{              Picture editor              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_GEdit;

interface

{$I FR.inc}

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, FR_Class, FR_Const;

type
  TfrGEditorForm = class(TfrObjEditorForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    GroupBox1: TGroupBox;
    Button3: TButton;
    Button4: TButton;
    ScrollBox1: TScrollBox;
    PB1: TPaintBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PB1Paint(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    function ShowEditor(View: TfrView): TModalResult; override;
  end;


implementation

{$R *.DFM}

uses FR_Desgn, ClipBrd, FR_Utils {$IFDEF OPENPICTUREDLG} , ExtDlgs {$ENDIF};

function TfrGEditorForm.ShowEditor(View: TfrView): TModalResult;
begin
  Image1.Picture.Assign((View as TfrPictureView).Picture);
  Result := ShowModal;
  if Result = mrOk then
  begin
    frDesigner.BeforeChange;
    (View as TfrPictureView).Picture.Assign(Image1.Picture);
  end;
end;

procedure TfrGEditorForm.BitBtn1Click(Sender: TObject);
var
{$IFDEF OPENPICTUREDLG}
  OpenDlg: TOpenPictureDialog;
{$ELSE}
  OpenDlg: TOpenDialog;
{$ENDIF}
begin
{$IFDEF OPENPICTUREDLG}
  OpenDlg := TOpenPictureDialog.Create(nil);
{$ELSE}
  OpenDlg := TOpenDialog.Create(nil);
{$ENDIF}
  OpenDlg.Options := [ofHideReadOnly];
  OpenDlg.Filter := frLoadStr(SPictFile) +
    ' (*.bmp '{$IFDEF JPEG}+'*.jpg '{$ENDIF}
              {$IFDEF RX}+'*.gif '{$ENDIF}
              +'*.ico *.wmf *.emf)|*.bmp;'{$IFDEF JPEG}+'*.jpg;'{$ENDIF}
                                          {$IFDEF RX}+'*.gif;'{$ENDIF}
              +'*.ico;*.wmf;*.emf|'+
    frLoadStr(SAllFiles) + '|*.*';
  if OpenDlg.Execute then
    Image1.Picture.LoadFromFile(OpenDlg.FileName);
  OpenDlg.Free;
  PB1Paint(nil);
end;

procedure TfrGEditorForm.Button4Click(Sender: TObject);
begin
  Image1.Picture.Assign(nil);
  PB1Paint(nil);
end;

procedure TfrGEditorForm.Localize;
begin
  Caption := frLoadStr(frRes + 460);
  Button3.Caption := frLoadStr(frRes + 462);
  Button4.Caption := frLoadStr(frRes + 463);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrGEditorForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrGEditorForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Key = vk_Insert) and (ssShift in Shift)) or
     ((Chr(Key) = 'V') and (ssCtrl in Shift)) then
    Image1.Picture.Assign(Clipboard);
  PB1Paint(nil);
end;

procedure TfrGEditorForm.PB1Paint(Sender: TObject);
var
  dx, dy: Integer;
begin
  with PB1.Canvas do
  begin
    Brush.Color := clWindow;
    FillRect(Rect(0, 0, PB1.Width, PB1.Height));
    if (Image1.Picture.Graphic = nil) or Image1.Picture.Graphic.Empty then
      TextOut((PB1.Width - TextWidth(frLoadStr(SNotAssigned))) div 2, 100, frLoadStr(SNotAssigned))
    else
    begin
      dx := Image1.Picture.Width;
      dy := Image1.Picture.Height;
      if (dx > PB1.Width) or (dy > PB1.Height) then
        StretchDraw(Rect(0, 0, PB1.Width, PB1.Height), Image1.Picture.Graphic) else
        Draw((PB1.Width - dx) div 2, (PB1.Height - dy) div 2, Image1.Picture.Graphic);
    end;
  end;
end;

end.

