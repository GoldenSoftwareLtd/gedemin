{ initialization unit for xCalend }
unit xCalInit;

interface

uses
  SysUtils, xWorld;

var { for phrases }
  lnAddHoliday,
  lnRemoveHoliday,
  lnInfoHoliday,
  lnAlreadyHoliday,
  lnDeleteEvery,
  lnDeleteSingle,
  lnDeleteFault,
  lnNotAHoliday,
  lnIsNamed,
  lnEveryYear,
  lnThisYear,
  lnWeekend,
  lnWorkingDay,
  lnNotValidDate,
  lnDateAfter,
  lnDateBefore
  : Integer;

var
  lnLongMonthNames: array[1..12] of Integer;
  lnShortMonthNames: array[1..12] of Integer;
  lnShortDayNames: array[0..6] of Integer;

implementation

initialization

  Phrases.SetOrigin('xTools: Calendar components');

  { long names for months }
  lnLongMonthNames[ 1] := Phrases.AddPhrase(lEnglish, 'January');
  lnLongMonthNames[ 2] := Phrases.AddPhrase(lEnglish, 'February');
  lnLongMonthNames[ 3] := Phrases.AddPhrase(lEnglish, 'March');
  lnLongMonthNames[ 4] := Phrases.AddPhrase(lEnglish, 'April');
  lnLongMonthNames[ 5] := Phrases.AddPhrase(lEnglish, 'May');
  lnLongMonthNames[ 6] := Phrases.AddPhrase(lEnglish, 'June');
  lnLongMonthNames[ 7] := Phrases.AddPhrase(lEnglish, 'July');
  lnLongMonthNames[ 8] := Phrases.AddPhrase(lEnglish, 'August');
  lnLongMonthNames[ 9] := Phrases.AddPhrase(lEnglish, 'September');
  lnLongMonthNames[10] := Phrases.AddPhrase(lEnglish, 'October');
  lnLongMonthNames[11] := Phrases.AddPhrase(lEnglish, 'November');
  lnLongMonthNames[12] := Phrases.AddPhrase(lEnglish, 'December');
  Phrases.AddTranslation(lnLongMonthNames[ 1], lRussian, 'Январь');
  Phrases.AddTranslation(lnLongMonthNames[ 2], lRussian, 'Февраль');
  Phrases.AddTranslation(lnLongMonthNames[ 3], lRussian, 'Март');
  Phrases.AddTranslation(lnLongMonthNames[ 4], lRussian, 'Апрель');
  Phrases.AddTranslation(lnLongMonthNames[ 5], lRussian, 'Май');
  Phrases.AddTranslation(lnLongMonthNames[ 6], lRussian, 'Июнь');
  Phrases.AddTranslation(lnLongMonthNames[ 7], lRussian, 'Июль');
  Phrases.AddTranslation(lnLongMonthNames[ 8], lRussian, 'Август');
  Phrases.AddTranslation(lnLongMonthNames[ 9], lRussian, 'Сентябрь');
  Phrases.AddTranslation(lnLongMonthNames[10], lRussian, 'Октябрь');
  Phrases.AddTranslation(lnLongMonthNames[11], lRussian, 'Ноябрь');
  Phrases.AddTranslation(lnLongMonthNames[12], lRussian, 'Декабрь');

  { short names of months }
  lnShortMonthNames[ 1] := Phrases.AddPhrase(lEnglish, 'Jan');
  lnShortMonthNames[ 2] := Phrases.AddPhrase(lEnglish, 'Feb');
  lnShortMonthNames[ 3] := Phrases.AddPhrase(lEnglish, 'Mar');
  lnShortMonthNames[ 4] := Phrases.AddPhrase(lEnglish, 'Apr');
  lnShortMonthNames[ 5] := Phrases.AddPhrase(lEnglish, 'May');
  lnShortMonthNames[ 6] := Phrases.AddPhrase(lEnglish, 'Jun');
  lnShortMonthNames[ 7] := Phrases.AddPhrase(lEnglish, 'Jul');
  lnShortMonthNames[ 8] := Phrases.AddPhrase(lEnglish, 'Aug');
  lnShortMonthNames[ 9] := Phrases.AddPhrase(lEnglish, 'Sep');
  lnShortMonthNames[10] := Phrases.AddPhrase(lEnglish, 'Oct');
  lnShortMonthNames[11] := Phrases.AddPhrase(lEnglish, 'Nov');
  lnShortMonthNames[12] := Phrases.AddPhrase(lEnglish, 'Dec');
  Phrases.AddTranslation(lnShortMonthNames[ 1], lRussian, 'Янв');
  Phrases.AddTranslation(lnShortMonthNames[ 2], lRussian, 'Фев');
  Phrases.AddTranslation(lnShortMonthNames[ 3], lRussian, 'Мар');
  Phrases.AddTranslation(lnShortMonthNames[ 4], lRussian, 'Апр');
  Phrases.AddTranslation(lnShortMonthNames[ 5], lRussian, 'Май');
  Phrases.AddTranslation(lnShortMonthNames[ 6], lRussian, 'Июн');
  Phrases.AddTranslation(lnShortMonthNames[ 7], lRussian, 'Июл');
  Phrases.AddTranslation(lnShortMonthNames[ 8], lRussian, 'Авг');
  Phrases.AddTranslation(lnShortMonthNames[ 9], lRussian, 'Сен');
  Phrases.AddTranslation(lnShortMonthNames[10], lRussian, 'Окт');
  Phrases.AddTranslation(lnShortMonthNames[11], lRussian, 'Ноя');
  Phrases.AddTranslation(lnShortMonthNames[12], lRussian, 'Дек');

  { short names for days of week }
  lnShortDayNames[0] := Phrases.AddPhrase(lEnglish, 'Su');
  lnShortDayNames[1] := Phrases.AddPhrase(lEnglish, 'Mo');
  lnShortDayNames[2] := Phrases.AddPhrase(lEnglish, 'Tu');
  lnShortDayNames[3] := Phrases.AddPhrase(lEnglish, 'We');
  lnShortDayNames[4] := Phrases.AddPhrase(lEnglish, 'Th');
  lnShortDayNames[5] := Phrases.AddPhrase(lEnglish, 'Fr');
  lnShortDayNames[6] := Phrases.AddPhrase(lEnglish, 'Sa');
  Phrases.AddTranslation(lnShortDayNames[0], lRussian, 'Вс');
  Phrases.AddTranslation(lnShortDayNames[1], lRussian, 'Пн');
  Phrases.AddTranslation(lnShortDayNames[2], lRussian, 'Вт');
  Phrases.AddTranslation(lnShortDayNames[3], lRussian, 'Ср');
  Phrases.AddTranslation(lnShortDayNames[4], lRussian, 'Чт');
  Phrases.AddTranslation(lnShortDayNames[5], lRussian, 'Пт');
  Phrases.AddTranslation(lnShortDayNames[6], lRussian, 'Сб');

  { for popup menu }
  lnAddHoliday := Phrases.AddPhrase(lEnglish, LoadStr(19600){'Add holiday'});
  lnRemoveHoliday := Phrases.AddPhrase(lEnglish, LoadStr(19601){'Remove holiday'});
  lnInfoHoliday := Phrases.AddPhrase(lEnglish, LoadStr(19602){'Information'});
  Phrases.AddTranslation(lnAddHoliday, lRussian, LoadStr(19603){'Новый праздник'});
  Phrases.AddTranslation(lnRemoveHoliday, lRussian, LoadStr(19604){'Удалить праздник'});
  Phrases.AddTranslation(lnInfoHoliday, lRussian, LoadStr(19605){'Информация'});

  lnAlreadyHoliday := Phrases.AddPhrase(lEnglish, LoadStr(19606){' is already a holiday'});
  Phrases.AddTranslation(lnAlreadyHoliday, lRussian, LoadStr(19607){' уже праздник'});

  lnDeleteEvery := Phrases.AddPhrase(lEnglish, LoadStr(19608)
    {'Do you really want to delete every-year holiday '});
  Phrases.AddTranslation(lnDeleteEvery, lRussian, LoadStr(19609)
    {'Вы действительно хотите удалить ежегодный праздник '});

  lnDeleteSingle := Phrases.AddPhrase(lEnglish, LoadStr(19610)
    {'Do you really want to delete holiday '});
  Phrases.AddTranslation(lnDeleteSingle, lRussian, LoadStr(19611)
    {'Вы действительно хотите удалить праздник '});

  lnDeleteFault := Phrases.AddPhrase(lEnglish, LoadStr(19612)
    {'Could not delete holiday.'});
  Phrases.AddTranslation(lnDeleteFault, lRussian, LoadStr(19613)
    {'Невозможно удалить праздник.'});

  lnNotAHoliday := Phrases.AddPhrase(lEnglish, LoadStr(19614){' is not a holiday'});
  Phrases.AddTranslation(lnNotAHoliday, lRussian, LoadStr(19615){' не является праздником'});

  lnIsNamed := Phrases.AddPhrase(lEnglish, 'It is named: ');
  Phrases.AddTranslation(lnIsNamed, lRussian, 'Он называется: ');

  lnEveryYear := Phrases.AddPhrase(lEnglish, ' is every-year holiday. ');
  Phrases.AddTranslation(lnEveryYear, lRussian, ' - ежегодный праздник. ');

  lnThisYear := Phrases.AddPhrase(lEnglish, ' is this-year holiday. ');
  Phrases.AddTranslation(lnThisYear, lRussian, ' - праздник на этот год. ');

  lnWeekend := Phrases.AddPhrase(lEnglish, 'Weekend');
  Phrases.AddTranslation(lnWeekend, lRussian, 'Уикэнд');

  lnWorkingDay := Phrases.AddPhrase(lEnglish, 'Working day');
  Phrases.AddTranslation(lnWorkingDay, lRussian, 'Рабочий день');

  lnNotValidDate := Phrases.AddPhrase(lEnglish, ' is not a valid date.');
  Phrases.AddTranslation(lnNotValidDate, lRussian, ' не правильная дата.');

  lnDateAfter := Phrases.AddPhrase(lEnglish, 'Enter date after ');
  Phrases.AddTranslation(lnDateAfter, lRussian, 'Введите дату после ');

  lnDateBefore := Phrases.AddPhrase(lEnglish, 'Enter date before ');
  Phrases.AddTranslation(lnDateBefore, lRussian, 'Введите дату до ');

  Phrases.ClearOrigin;

end.
