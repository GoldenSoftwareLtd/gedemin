{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    UserDlg.pas

  Abstract

    Диалог для регистрации программы.

--}

unit Userdlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, xBulbBtn, StdCtrls, xYellabl, ExtCtrls, xBmpEff, Buttons,
  xMsgBox;

type
  TfrmUser = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    Panel1: TPanel;
    bitbtnPrev: TBitBtn;
    bitbtnNext: TBitBtn;
    bitbtnOk: TBitBtn;
    bitbtnCancel: TBitBtn;
    Notebook: TNotebook;
    Label1: TLabel;
    xstparametr: TLabel;
    xBitmapEffect: TxBitmapEffect;
    EvenImage: TImage;
    OddImage: TImage;
    edCode: TEdit;
    xYellowLabel1: TxYellowLabel;
    xylInformation: TxYellowLabel;
    procedure FormActivate(Sender: TObject);
    procedure bitbtnOkClick(Sender: TObject);
    procedure bitbtnNextClick(Sender: TObject);
    procedure bitbtnPrevClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    // Методы движение по Wizard
    procedure DoOnCreate;
    procedure DoOnNext;
    procedure DoOnPrev;

  public
    Version: Integer;
    ProductID: Integer;
    function GetCurrentCode: String;

  end;

var
  frmUser: TfrmUser;

implementation

uses
  MakeRgn;

{$R *.DFM}

// Получение текущего кода для сравнения с введенным

function TfrmUser.GetCurrentCode: String;
var
  TempParametr, ProductIDStr: String;
begin
  case Version of
    1:
    begin
      GetParametrs(TempParametr);
      Str(ProductID, ProductIDStr);
      Result := MakeRegCodeV1(TempParametr, ProductIDStr);
    end;
  end;
end;

// При активизации окна считываем, кодируем и выводим на экран параметры компьютера

procedure TfrmUser.FormActivate(Sender: TObject);
var
  ResParametr, VersionStr, ProductIDStr: String;

begin
  GetParametrs(ResParametr);
  Str(Version, VersionStr);
  ResParametr := ResParametr[1] + VersionStr + Copy(ResParametr, 2, Length(ResParametr));
  Str(ProductID, ProductIDStr);
  ConvertedValue(ResParametr, ProductIDStr, True);
  TurnStr(ResParametr);
  xstParametr.Caption := ResParametr;
end;

procedure TfrmUser.bitbtnOkClick(Sender: TObject);
begin
  if edCode.Text = GetCurrentCode then
    ModalResult := mrOk
  else
  begin
    ModalResult := mrNone;
    MessageBox(Handle, 'Неверный код, попробуйте еще раз.', 'Внимание !!!',
                 mb_Ok + 48)
  end;
end;

procedure TfrmUser.DoOnCreate;
begin
  Notebook.PageIndex := 0;

  if Notebook.Pages.Count = 0 then
    raise Exception.Create('Notebook must has at least one page');

  bitbtnPrev.Enabled := False;

  if Notebook.Pages.Count = 1 then
  begin
    bitbtnOk.Enabled := True;
    bitbtnNext.Enabled := False;
    bitbtnOk.Default := True;
  end else
  begin
    bitbtnOk.Enabled := False;
    bitbtnNext.Enabled := True;
    bitbtnOk.Default := False;
    bitbtnPrev.Default := False;
    bitbtnNext.Default := True;
  end;
  xBitmapEffect.Bitmap := EvenImage.Picture.Bitmap;
end;

procedure TfrmUser.DoOnNext;
begin
  Notebook.PageIndex := Notebook.PageIndex + 1;

  bitbtnPrev.Enabled := True;

  if Notebook.PageIndex = Notebook.Pages.Count - 1 then
  begin
    bitbtnNext.Enabled := False;
    bitbtnOk.Enabled := True;
    bitbtnNext.Default := False;
    bitbtnPrev.Default := False;
    bitbtnOk.Default := True;
  end
  else
  begin
    bitbtnNext.Enabled := True;
    bitbtnOk.Enabled := False;
    bitbtnPrev.Default := False;
    bitbtnOk.Default := False;
    bitbtnNext.Default := True;
  end;

  if Odd(Notebook.PageIndex) then
    xBitmapEffect.Bitmap := OddImage.Picture.Bitmap
  else
    xBitmapEffect.Bitmap := EvenImage.Picture.Bitmap;
end;

procedure TfrmUser.DoOnPrev;
begin
  Notebook.PageIndex := Notebook.PageIndex - 1;

  bitbtnNext.Enabled := True;

  if Notebook.PageIndex = 0 then
  begin
    bitbtnPrev.Enabled := False;
    bitbtnOk.Default := False;
    bitbtnPrev.Default := False;
    bitbtnNext.Default := True;
  end
  else
  begin
    bitbtnOk.Enabled := False;
    bitbtnOk.Default := False;
    bitbtnNext.Default := False;
    bitbtnPrev.Default := True;
  end;

  if Odd(Notebook.PageIndex) then
    xBitmapEffect.Bitmap := OddImage.Picture.Bitmap
  else
    xBitmapEffect.Bitmap := EvenImage.Picture.Bitmap;

end;

procedure TfrmUser.bitbtnNextClick(Sender: TObject);
begin
  DoOnNext;
end;

procedure TfrmUser.bitbtnPrevClick(Sender: TObject);
begin
  DoOnPrev;
end;

procedure TfrmUser.FormCreate(Sender: TObject);
begin
  DoOnCreate;
end;

end.
