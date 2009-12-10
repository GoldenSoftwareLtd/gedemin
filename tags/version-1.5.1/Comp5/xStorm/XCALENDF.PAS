{
  Additional unit for xCalend.pas
  xTools collection: c) Golden Software of Belarus
  Author: Vladimir Belyi

  version 1.21
}

unit xCalendF;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls;

type
  TNewHoliday = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Memo1: TMemo;
    Edit1: TEdit;
    Label1: TLabel;
    Bevel1: TBevel;
    This: TRadioButton;
    Every: TRadioButton;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewHoliday: TNewHoliday;

var { Phrases }
  lnTip,
  lnThis,
  lnEvery,
  lnTitle  : Integer;

implementation

{$R *.DFM}

uses xWorld;

procedure TNewHoliday.FormActivate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Memo1.lines.Add( Phrases[ lnTip ] );
  This.Caption := Phrases[ lnThis ];
  Every.Caption := Phrases[ lnEvery ];
  Caption := Phrases[ lnTitle ];
  Edit1.SetFocus;
end;


initialization

  Phrases.SetOrigin('xTools: Calendar components');

  lnTip := Phrases.AddPhrase(lEnglish,
              'You are about to mark this day as a holiday.'#13#10 +
              'Please, enter the name for the holiday.');
  Phrases.AddTranslation(lnTip, lRussian,
              'Вы хотите определить новый праздник.'#13#10 +
              'Введите ему название.');

  lnThis := Phrases.AddPhrase(lEnglish, 'Celebrate this year');
  Phrases.AddTranslation(lnThis, lRussian, 'Празднуется в этом году');

  lnEvery := Phrases.AddPhrase(lEnglish, 'Celebrate every year');
  Phrases.AddTranslation(lnEvery, lRussian, 'Празднуется каждый год');

  lnTitle := Phrases.AddPhrase(lEnglish, 'Mark a holiday');
  Phrases.AddTranslation(lnTitle, lRussian, 'Создать праздник');

  Phrases.ClearOrigin;

end.
