
{++

  Copyright (c) 1995-97 by Golden Software of Belarus

  Module

    aboutdlg.pas

  Abstract

    Delphi component. About dialog box with credits.

  Author

    Andrei Kireev (25-Oct-95)

  Revisions history

    1.00    25-Oct-95    andreik    Initial version.
    1.01    20-Oct-97    andreik    Ported to Delphi32.

--}

unit AboutDlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, Credit;

type
  TAboutBox = class(TForm)
  public
    constructor CreateNew(AnOwner: TComponent; ACaption: String;
      ACredit: TCredit; AMargin: Integer); reintroduce;
  end;

const
  DefMargin = 12;

type
  TAboutDialog = class(TComponent)
  private
    FCaption: String;
    FMargin: Integer;

    FSplash: TBitmap;
    FCreditText: TStringList;
    FCreditSpeed: Word;
    FCreditTextColor: TColor;
    FCreditBkColor: TColor;
    FCreditShadowColor: TColor;
    FCreditStep: Word;
    FCreditDepth: Word;
    FFrame: Boolean;
    FClickActivate: Boolean;
    FCreditFont: TFont;
    FHint: String;

    procedure SetSplash(ASplash: TBitmap);
    procedure SetCreditText(AText: TStringList);
    procedure SetCreditFont(AFont: TFont);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Execute;

  published
    property Caption: String read FCaption write FCaption;
    property Margin: Integer read FMargin write FMargin
      default DefMargin;

    property Splash: TBitmap read FSplash write SetSplash;
    property CreditText: TStringList read FCreditText
      write SetCreditText;
    property CreditSpeed: Word read FCreditSpeed write FCreditSpeed
      default DefSpeed;
    property CreditTextColor: TColor read FCreditTextColor
      write FCreditTextColor default DefTextColor;
    property CreditBkColor: TColor read FCreditBkColor
      write FCreditBkColor default DefBackgroundColor;
    property CreditShadowColor: TColor read FCreditShadowColor
      write FCreditShadowColor default DefShadowColor;
    property CreditStep: Word read FCreditStep write FCreditStep
      default DefStep;
    property CreditDepth: Word read FCreditDepth write FCreditDepth
      default DefDepth;
    property Frame: Boolean read FFrame write FFrame default True;
    property ClickActivate: Boolean read FClickActivate
      write FClickActivate default DefClickActivate;
    property CreditFont: TFont read FCreditFont write SetCreditFont;
    property Hint: String read FHint write FHint;
  end;

procedure Register;

implementation

{ TAboutDialog -------------------------------------------}

constructor TAboutDialog.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FCaption := '';
  FMargin := DefMargin;

  FSplash := TBitmap.Create;
  FCreditText := TStringList.Create;
  FCreditSpeed := DefSpeed;
  FCreditTextColor := DefTextColor;
  FCreditBkColor := DefBackgroundColor;
  FCreditShadowColor := DefShadowColor;
  FCreditStep := DefStep;
  FCreditDepth := DefDepth;
  FFrame := True;
  FClickActivate := DefClickActivate;
  FCreditFont := TFont.Create;
  FHint := '';
end;

destructor TAboutDialog.Destroy;
begin
  FSplash.Free;
  FCreditText.Free;
  FCreditFont.Free;
  inherited Destroy;
end;

procedure TAboutDialog.Execute;
var
  Credit: TCredit;
  AboutBox: TAboutBox;
begin
  Credit := TCredit.Create(Self);
  try
    Credit.AdjustToSplash := True;
    Credit.Text3D := True;
    Credit.DblClickActivate := True;

    Credit.Splash := FSplash;
    Credit.Text := FCreditText;
    Credit.Speed := FCreditSpeed;
    Credit.TextColor := FCreditTextColor;
    Credit.BackgroundColor := FCreditBkColor;
    Credit.ShadowColor := FCreditShadowColor;
    Credit.Step := FCreditStep;
    Credit.Depth := FCreditDepth;
    Credit.Frame := FFrame;
    Credit.ClickActivate := FClickActivate;
    Credit.Font := FCreditFont;

    if FHint <> '' then
    begin
      Credit.Hint := FHint;
      Credit.ShowHint := True;
    end else
      Credit.ShowHint := False;

    AboutBox := TAboutBox.CreateNew(Self, FCaption, Credit, FMargin);
    try
      AboutBox.ShowModal;
    finally
      AboutBox.Free;
    end;
  finally
    Credit.Free;
  end;
end;

procedure TAboutDialog.SetSplash(ASplash: TBitmap);
begin
  FSplash.Assign(ASplash);
end;

procedure TAboutDialog.SetCreditText(AText: TStringList);
begin
  FCreditText.Assign(AText);
end;

procedure TAboutDialog.SetCreditFont(AFont: TFont);
begin
  FCreditFont.Assign(AFont);
end;

{ TAboutBox ----------------------------------------------}

constructor TAboutBox.CreateNew(AnOwner: TComponent; ACaption: String;
  ACredit: TCredit; AMargin: Integer);
var
  Credit: TCredit;
  Button: TBitBtn;
begin
  inherited CreateNew(AnOwner);

  Credit := TCredit.Create(Self);
  Credit.Parent := Self;
  Credit.Assign(ACredit);
  Credit.Left := AMargin;
  Credit.Top := AMargin;

  Button := TBitBtn.Create(Self);
  Button.Parent := Self;
  Button.Kind := bkOk;
  Button.Left := AMargin + (Credit.Width - Button.Width) div 2;
  Button.Top := AMargin + Credit.Height + AMargin;

  BorderStyle := bsDialog;
  Caption := ACaption;
  Position := poScreenCenter;
  Width := GetSystemMetrics(SM_CXBORDER) * 4 + AMargin * 2 + Credit.Width;
  Height := GetSystemMetrics(SM_CYCAPTION) + AMargin * 3 + Credit.Height
    + Button.Height + GetSystemMetrics(SM_CYBORDER) * 3;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsDlg', [TAboutDialog]);
end;

end.

