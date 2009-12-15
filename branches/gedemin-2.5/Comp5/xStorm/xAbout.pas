{++

  About window form and support
  Copyright c) 1996 - 97 by Golden Software

  Module

    xAbout.pas

  Abstract

    Support for about window and its form.

  Author

    Vladimir Belyi (December-1996)

  Contact address

    andreik@gs.minsk.by

  Uses

    xPtyDesk
    Bkground

  Revisions history

    1.00   5-jan-1997  belyi   Initial version

  Known bugs

    -

  Wishes

    -

  Notes / comments

    -

--}

unit xAbout;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, TabNotBk, Bkground, ExtCtrls, xPtyDesk, StdCtrls, Buttons,
  DsgnIntF, ComCtrls;

type
  TxAboutForm = class(TForm)
    xPrettyDesktop1: TxPrettyDesktop;
    GradientFill1: TGradientFill;
    TabbedNotebook1: TTabbedNotebook;
    AboutMemo: TMemo;
    OkBtn: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormResize(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TxAbout = class(TStringList) { for the property in the object inspector }
  end;

var
  xAboutForm: TxAboutForm;

procedure Register;


implementation

{$R *.DFM}

procedure TxAboutForm.FormResize(Sender: TObject);
begin
  OkBtn.Left := (Width - OkBtn.Width) div 2;
  OkBtn.Top := Height - OkBtn.height - 70;
  AboutMemo.Height := OkBtn.Top - 10;
end;

procedure TxAboutForm.OkBtnClick(Sender: TObject);
begin
  Close;
end;


type
  TxAboutProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;

procedure TxAboutProperty.Edit;
var
  Form: TxAboutForm;
  p: Pointer;
begin
  Application.CreateForm(TxAboutForm, Form);
  try
    p := Pointer(GetOrdValue);
    Form.AboutMemo.Lines.Assign( TStringList(p) );
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

function TxAboutProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

function TxAboutProperty.GetValue: string;
begin
  Result := 'Click for help';
end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TxAbout), nil, '', TxAboutProperty);
end;

end.
