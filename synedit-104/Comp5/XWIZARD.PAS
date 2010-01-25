
{ version 1.00 24-Jul-96 }
{ version 1.01 19-Feb-97 }

unit xWizard;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, xBmpEff;

type
  TxWizardForm = class(TForm)
    Panel2: TPanel;
    Bevel1: TBevel;
    Panel1: TPanel;
    bitbtnPrev: TBitBtn;
    bitbtnNext: TBitBtn;
    bitbtnOk: TBitBtn;
    bitbtnCancel: TBitBtn;
    Panel3: TPanel;
    Panel4: TPanel;
    Notebook: TNotebook;
    xBitmapEffect: TxBitmapEffect;
    OddImage: TImage;
    EvenImage: TImage;
    procedure bitbtnNextClick(Sender: TObject);
    procedure bitbtnPrevClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    procedure DoOnCreate;
    procedure DoOnNext;
    procedure DoOnPrev;
  end;

var
  xWizardForm: TxWizardForm;

implementation

{$R *.DFM}

procedure TxWizardForm.bitbtnNextClick(Sender: TObject);
begin
  DoOnNext;
end;

procedure TxWizardForm.bitbtnPrevClick(Sender: TObject);
begin
  DoOnPrev;
end;

procedure TxWizardForm.FormCreate(Sender: TObject);
begin
  DoOnCreate;
end;

procedure TxWizardForm.DoOnCreate;
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

procedure TxWizardForm.DoOnNext;
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

procedure TxWizardForm.DoOnPrev;
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

end.
