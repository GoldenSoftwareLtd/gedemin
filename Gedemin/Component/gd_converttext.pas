// ShlTanya, 20.02.2019

unit gd_converttext;

interface

{

  ‘ункци€ переключает клавиатуру на следующую раскладку в пор€дке
  живой очереди и перекодирует строку в соответствии с новой
  раскладкой клавиатуры.

  ‘ункци€ примен€етс€, например, в лукапе, где выполн€етс€ по
  нажатию на клавишу ‘12.

  ≈сли пользователь хотел ввести Golden Software, но
  случайно сделал это на русской раскладке клавиатуры, то
  вместо того, чтобы переключать раскладку, удал€ть введенную
  абракадабру и вводить текст заново, ему достаточно нажать ‘12.
  –аскладка будет переключена на английскую а текст перекодирован
  так, как будто он был введен на английской раскладке.

}

function ConvertText(const S: String): String;

implementation

uses
  SysUtils, Windows;

const
  ArrRus = 'Є"є;:?йцукенгшщзхъфывапролджэ€чсмитьбю.®…÷” ≈Ќ√Ўў«’Џ‘џ¬јѕ–ќЋƒ∆Ёя„—ћ»“№Ѕё.';
  ArrEng = '`@#$^&qwertyuiop[]asdfghjkl;''zxcvbnm,./~QWERTYUIOP[]ASDFGHJKL;''ZXCVBNM,./';
  ArrBel = 'Є"є;:?йцукенгшҐзх''фывапролджэ€чсм≥тьбю.®…÷” ≈Ќ√Ў°«’''‘џ¬јѕ–ќЋƒ∆Ёя„—ћ≤“№Ѕё.';

function ConvertText(const S: String): String;
var
  Ch: array[0..KL_NAMELENGTH] of Char;
  Kl, I, J: Integer;
  SFrom, STo: String;
begin
  Result := S;

  GetKeyboardLayoutName(Ch);
  KL := StrToInt('$' + StrPas(Ch));

  case (KL and $3ff) of
    LANG_BELARUSIAN: SFrom := ArrBel;
    LANG_RUSSIAN: SFrom := ArrRus;
    LANG_ENGLISH: SFrom := ArrEng;
  else
    exit;
  end;

  ActivateKeyBoardLayout(HKL_NEXT, 0);
  GetKeyboardLayoutName(Ch);
  KL := StrToInt('$' + StrPas(Ch));

  case (KL and $3ff) of
    LANG_BELARUSIAN: STo := ArrBel;
    LANG_RUSSIAN: STo := ArrRus;
    LANG_ENGLISH: STo := ArrEng;
  else
    exit;
  end;

  for I := 1 to Length(Result) do
  begin
    J := AnsiPos(Result[I], SFrom);
    if J > 0 then
      Result[I] := STo[J];
  end;
end;


end.
 