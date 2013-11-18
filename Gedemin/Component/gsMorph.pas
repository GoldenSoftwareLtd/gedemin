unit gsMorph;

{  Данный модуль реализует преобразование падежей ФИО.

  Преобразование происходит с помощью процедуры SetCase с параметрами:
  - TheWord: исходная фамилия, имя или отчество. Хвостовые пробелы
             недопустимы. Окончание должно быть набрано не заглавными
             буквами;
  - TheCase: падеж (константы csXXXX), в который будет преобразовано
             слово;
  - Gender:  род (константы gdXXXX). Обычно указывается женский или
             мужской род;
  - Name:    константы nmXXXX устанавливаются по следующей зависимости:
             для фамилии - имя собственное (nmOwn);
             для имени, отчества - имя нарицательное (nmNar);

  *** Пример ***

  Получение ФИО в родительном падеже:
  Answer := SetCase (Fam, csGenitive, Gnd, nmOwn) + ' ' +
            SetCase (Nam, csGenitive, Gnd, nmNar) + ' ' +
            SetCase (Ptn, csGenitive, Gnd, nmNar);    }

interface

const
  { Падежи }
  csNominative     = 1;    { Именительный КТО-ЧТО }
  csGenitive       = 2;    { Родительный  КОГО-ЧЕГО }
  csDative         = 3;    { Дательный    КОМУ-ЧЕМУ }
  csAccusative     = 4;    { Винительный  КОГО-ЧТО }
  csInstrumentale  = 5;    { Творительный КЕМ-ЧЕМ }
  csPreposizionale = 6;    { Предложный   О КОМ-О ЧЕМ }
  { Род }
  gdMasculine = 0;         { Мужской род }
  gdFeminine  = 1;         { Женский род }
  gdMedium    = 2;         { Средний род }
  gdPlural    = 3;         { Множественное число }
  { Имя }
  nmNar = 0;               { Имя нарицательное }
  nmOwn = 1;               { Имя собственное   }
  nmNum = 2;               { Имя числительное  }

function GetCase(TheWord: String; Gender, TheCase, Name: Word): String;
function FIOCase(LastName, FirstName, MiddleName: String; Sex, TheCase: Word): String;
function ComplexCase(TheWord: String; TheCase: Word): String;

{
  Берет целое число и три формы слова, для одного, двух и пяти объектов, и возвращает правильное слово
  Пример:
    -> 67, 'объект', 'объекта', 'объектов'
    <- объектов
    -> 51, 'объект', 'объекта', 'объектов'
    <- объект
}
function GetNumericWordForm(const ANum: Integer; const AStrForm1, AStrForm2, AStrForm5: String): String;

implementation

uses
  Sysutils, jclStrings;

type
  TNMSet = array[csNominative..csPreposizionale] of String[3];
  TNHSet = array[csNominative..csPreposizionale] of String[9];
const
  NMA: TNMSet = ('ий', 'ия', 'ию', 'ия', 'ием', 'ии');
  NMB: TNMSet = ('ай', 'ая', 'аю', 'ая', 'аем', 'ае');
  NMG: TNMSet = ('уй', 'уя', 'ую', 'уя', 'yeм', 'уе');
  NMC: TNMSet = ('ей', 'ея', 'ею', 'ея', 'еем', 'ее');
  NMD: TNMSet = ('ел', 'ла', 'лу', 'ла', 'лом', 'ле');
  NME: TNMSet = ('ь',  'я',  'ю',  'я',  'ем',  'е');
  NMF: TNMSet = ('',   'а',  'у',  'а',  'ом',  'е');
  NMH: TNMSet = ('ей', 'ья', 'ью', 'ья', 'ьём', 'ье');

  NFA: TNMSet = ('а', 'ы', 'е', 'у', 'ой', 'е');   { ...а }
  NFB: TNMSet = ('я', 'и', 'е', 'ю', 'ей', 'е');   { ..ья }
  NFC: TNMSet = ('я', 'и', 'и', 'ю', 'ей', 'и');   { ..ия }
  NFD: TNMSet = ('а', 'и', 'е', 'у', 'ой', 'е');
  NFE: TNMSet = ('а', 'и', 'е', 'у', 'ей', 'е');   { ..ша }

  OMA: TNMSet = ('ий', 'ого', 'ому', 'ого', 'им', 'ом');
  OMB: TNMSet = ('ый', 'ого', 'ому', 'ого', 'ым', 'ом');
  OMC: TNMSet = ('ой', 'ого', 'ому', 'ого', 'им', 'ом');
  OMD: TNMSet = ('',   'а',   'у',   'а',   'ым', 'е');
  OME: TNMSet = ('ь', 'и', 'и', 'ь', 'ью', 'и');
  OMF: TNMSet = ('ий', 'его', 'ему', 'его', 'им', 'ем');

  OFA: TNMSet = ('ая', 'ой', 'ой', 'ую', 'ой', 'ой');
  OFB: TNMSet = ('а',  'ой', 'ой', 'у',  'ой', 'ой');

  gl: set of Char = ['а', 'е', 'ё', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я'];
  r_sogl: set of Char = ['Ъ', 'Ь'];
  sogl: set of Char = ['б', 'в', 'г' , 'д', 'ж', 'з', 'й', 'к', 'л', 'м', 'н',
    'п', 'р', 'с', 'т', 'ф', 'х', 'ч', 'ц', 'ш', 'щ', 'ь', 'ъ'];
  n_sogl: set of Char = ['л', 'м', 'к', 'т', 'х', 'ц', 'п', 'x', 'с', 'р', 'ж', 'г', 'н', 'ш'];

  IsNumeral = ';два;три;четыре;пять;шесть;семь;восемь;девять;десять;одиннадцать' +
    ';двенадцать;тринадцать;четырнадцать;пятнадцать;шестнадцать;семнадцать;восемнадцать' +
    ';девятнадцать;двадцат ь;тридцать;сорок;пятьдесят;шестьдесят;семьдесят;восемьдесят' +
    ';девяносто;сто;двести;тристо;четыресто;пятьсот;шестьсот;семьсот;восемьсот;девятьсот';

  NA: TNMSet = ('ь', 'и', 'и', 'ь', 'ью', 'и');
  NB: TNHSet = ('десят', 'десяти', 'десяти', 'десят', 'десятью', 'десяти');
  NC: TNHSet = ('сот', 'сот', 'стам', 'сот', 'стами', 'стах');
  ND: TNHSet = ('сорок', 'сорока', 'сорока', 'сорок', 'сорока', 'сорока');
  NE: TNHSet = ('девяносто', 'девяноста', 'девяноста', 'девяносто', 'девяноста', 'девяноста');
  NF: TNHSet = ('сто', 'ста', 'ста', 'сто', 'ста', 'ста');
  NG: TNHSet = ('два', 'двух', 'двум', 'два', 'двумя', 'двух');
  NH: TNHSet = ('три', 'трех', 'трем', 'три', 'тремя', 'трех');
  NI: TNHSet = ('четыре', 'четырех', 'четырем', 'четыре', 'четырьмя', 'четырех');
  NJ: TNHSet = ('восемь', 'восьми', 'восьми', 'восемь', 'восьмью', 'восьми');



{Мужские и женские имена на -о не склоняются}

function Numeral(TheWord: String; TheCase: Word): String;   
begin
  Result := TheWord;

  if TheWord = 'сто' then
    Result := NF[TheCase]
  else if TheWord = 'сорок' then
    Result := ND[TheCase]
  else if TheWord = 'девяносто' then
    Result := NE[TheCase]
  else if TheWord = 'восемь' then
    Result := NJ[TheCase]
  else if TheWord = 'два' then
    Result := NG[TheCase]
  else if TheWord = 'три' then
    Result := NH[TheCase]
  else if TheWord = 'четыре' then
    Result := NI[TheCase]
  else if TheWord[Length(TheWord)] = 'ь' then
  begin
    Delete(Result, Length(Result), 1);
    Result := Result + NA[TheCase];
  end else
  if StrIPos('десят', TheWord) > 1 then
  begin
    Result := Numeral(Copy(TheWord, 1, Length(TheWord) - 5), TheCase) + NB[TheCase];
  end else
  if StrIPos('сот', TheWord) > 0 then
  begin
    Result := Numeral(Copy(TheWord, 1, Length(TheWord) - 3), TheCase) + NC[TheCase];
  end;
end;

function NormaLizeWord(const TheWord: String): String;
begin
  Result := Trim(TheWord);
  Result := AnsiUpperCase(Copy(Result, 1, 1)) +
    AnsiLowerCase(Copy(Result, 2, Length(Result)));
end;

function SetCase_(TheWord: String; TheCase, Gender, Name: Word): String;
var
  str2, str3: String;
  str1: Char;
begin
  Result := TheWord;
  if TheCase = csNominative then
    Exit;
  str2 := Copy(TheWord, Length(TheWord) - 1, 2);
  str3 := Copy(TheWord, Length(TheWord) - 2, 3);
  str1 := TheWord[Length(TheWord) - 2];
  case Name of
    nmNar: begin                  { Обработка имени нарицательного }
      case Gender of
        gdMasculine: begin         { Мужской род }
          { ..ий, ..ай, ..ей, ..ел, ..ь, остальные как согласная }
          if str2 = 'ий' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMA[TheCase];
          end else
          if str2 = 'ый' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = 'ой' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = 'ай' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMB[TheCase];
          end else
          if str2 = 'ей' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMC[TheCase];
          end else
          if str2 = 'ел' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMD[TheCase];
          end else
          if TheWord[Length(TheWord)] = 'ь' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NME[TheCase];
          end else
          if (TheWord[Length(TheWord)] = 'ч') and (TheCase = csInstrumentale) then begin
            TheWord := TheWord + NME[TheCase];
          end else
          if TheWord[Length(TheWord)] = 'а' then begin
            str1 := TheWord[Length(TheWord) -1];
            if str1 in sogl then
            begin
              if (TheCase = csGenitive) and
                ((str1 = 'г') or (str1 = 'к') or
                (str1 = 'х') or (str1 = 'ч') or (str1 = 'ш') or
                (str1 = 'щ') or (str1 = 'ж')) then begin

                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + 'и';
              end else
              if (TheCase = csInstrumentale) and
                ((str1 = 'ц') or (str1 = 'щ') or
                (str1 = 'ш') or (str1 = 'ч') or
                (str1 = 'ж')) then begin

                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + 'ей';
              end else begin
                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + NFA[TheCase];
              end;
            end else
              TheWord := TheWord + NMF[TheCase];
          end else
          if TheWord[Length(TheWord)] = 'я' then begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFC[TheCase];
          end else begin
            TheWord := TheWord + NMF[TheCase];
          end;
        end;
        gdFeminine: begin          { Женский род }
          { ..ь, ..а, ..ья, остальные как ..ия }
            if (str2 = 'га') or (str2 = 'ка') then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFD[TheCase];
            end else
            if str2 = 'ша' then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFE[TheCase];
            end else
            if TheWord[Length(TheWord)] = 'а' then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFA[TheCase];
            end else
            if str2 = 'ья' then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFB[TheCase];
            end else
            if TheWord[Length(TheWord)] = 'ь' then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + OME[TheCase];
            end else
            if TheWord[Length(TheWord)] in sogl then begin
              Exit;
            end else begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFC[TheCase];
            end;
        end;
      end;
    end;
    nmOwn: begin                  { Обработка имени собственного }
      case Gender of
        gdMasculine: begin         { Мужской род }
          if TheCase <> csNominative then
          begin
            if (str3 = 'нок') or (str3 = 'нек') or (str3 = 'нец') or (str3 = 'пец') or
              (str3 = 'чок') or (str3 = 'вец') or (str3 = 'ток') then
              Delete(TheWord, Length (TheWord) - 1, 1);
            if (str3 = 'лец') then
            begin
              Delete(TheWord, Length (TheWord) - 1, 1);
              Insert('ь', TheWord, Length (TheWord));
            end;
          end;
          { ..ий, ..ый, ..ой, остальные как согласная }
          if (str3 = 'ший') or (str3 = 'чий') then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMF[TheCase];
          end else
          if str2 = 'ий' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMA[TheCase];
          end else
          if str2 = 'ый' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = 'ой' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if (str2 = 'ец') and (str1 in gl) then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + 'йц' + NMF[TheCase];
          end else
          if str2 = 'ай' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMB[TheCase];
          end else
          if str2 = 'уй' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMG[TheCase];
          end else
          if str2 = 'ей' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMH[TheCase];
          end else
          if TheWord[Length(TheWord)] = 'ь' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NME[TheCase];
          end else
          if TheWord[Length(TheWord)] = 'я' then begin  //например Бетеня
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFB[TheCase];
          end else
          if (TheWord[Length(TheWord)] = 'ч') and (TheCase = csInstrumentale) then begin
            TheWord := TheWord + NME[TheCase];
          end else
          if (str2 = 'ко') or (str2 = 'их') or (str2 = 'ых') or
            (str2 = 'иа') or (str2 = 'ия') or (str2 = 'ло') or (str2 = 'но') then begin
            Exit;
          end else
          if (str3 = 'ово') or (str3 = 'аго') or (str3 = 'яго') then begin
            Exit;
          end else
          if TheWord[Length(TheWord)] = 'а' then begin
            str1 := TheWord[Length(TheWord) -1];
            if str1 in sogl then
            begin
              if (TheCase = csGenitive) and
                ((str1 = 'г') or (str1 = 'к') or
                (str1 = 'х') or (str1 = 'ч') or (str1 = 'ш') or
                (str1 = 'щ') or (str1 = 'ж')) then begin

                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + 'и';
              end else
              if (TheCase = csInstrumentale) and
                ((str1 = 'ц') or (str1 = 'щ') or
                (str1 = 'ш') or (str1 = 'ч') or
                (str1 = 'ж')) then begin

                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + 'ей';
              end else begin
                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + NFA[TheCase];
              end;
            end else
              TheWord := TheWord + NMF[TheCase];
          end else
          if TheWord[Length(TheWord)] in n_sogl then begin
            TheWord := TheWord + NMF[TheCase];
          end else begin
            TheWord := TheWord + OMD[TheCase];
          end;
        end;
        gdFeminine: begin          { Женский род }
          { ..ая, остальные как ..а }
          if str3 = 'ава' then begin
            exit;   // см. Issue 2333
          end else
          if str2 = 'ая' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OFA[TheCase];
          end else
          if (str2 = 'ко') or (str2 = 'их') or (str2 = 'ых') or
            (str2 = 'иа') or (str2 = 'ия') or (str2 = 'ло') then begin
            Exit;
          end else
          if (str3 = 'ово') or (str3 = 'аго') or (str3 = 'яго') then begin
            Exit;
          end else
          if (str3 = 'ова') or (str3 = 'eва') or  (str3 = 'ина') or
            (str3 = 'ына') or (str3 = 'ёва') then begin //Балахонова
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + OFB[TheCase];
          end else
          if TheWord[Length(TheWord)] = 'а' then begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFD[TheCase];
          end else
          if TheWord[Length(TheWord)] = 'я' then begin  //например Бетеня
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFB[TheCase];
          end else
          if TheWord[Length(TheWord)] in sogl then begin
            exit;
          end else begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + OFB[TheCase];
          end;
        end;
        else Exit;
      end;
    end;
    else Exit;
  end;
  Result := TheWord;
end;

function GetCase(TheWord: String; Gender, TheCase, Name: Word): String;
begin
  Result := TheWord;
  if TheWord <> '' then
    Result := SetCase_(NormaLizeWord(TheWord), TheCase, Gender, Name);
end;

function FIOCase(LastName, FirstName, MiddleName: String; Sex, TheCase: Word): String;
begin
  Result := Trim(GetCase(LastName, Sex, TheCase, nmOwn) + ' ' +
    GetCase(FirstName, Sex, TheCase, nmNar) + ' ' +
    GetCase(MiddleName, Sex, TheCase, nmNar));
end;

{
1. Наименование -- это одно слово или N слов, написанных через дефис.
2. Наименование из одного слова склоняется по правилам склонения.
3. В наименовании из N слов, написанных через дефис, склоняется каждое из
слов по правилам склонения.
4. В общем случае, функция принимает на вход строку следующего вида:
[[Определение] [Определение]...] Наименование [Остаток]

5. Определение -- это прилагательное: главный, старший, ведущий, главная, и
т.п. Их может быть несколько.
6. Определение склоняется.
7. Наименование склоняется.
8. Остаток не склоняется.

Определение - это прилагательное в именительном падеже, единственном числе. Т.е.
определяем его по окончаниям: -ый, -ий, -ая, -яя.

}

function SetCase(TheWord: String; TheCase, Gender, Name: Word): String;
var
  str2, str3: String;
  str1: Char;
begin
  SetCase := TheWord;
  if TheCase = csNominative then
    Exit;
  str2 := Copy(TheWord, Length(TheWord) - 1, 2);
  str3 := Copy(TheWord, Length(TheWord) - 2, 3);
  str1 := TheWord[Length(TheWord) - 2];
  Case Name of
    nmNar: begin                  { Обработка имени нарицательного }
      Case Gender of
        gdMasculine: begin         { Мужской род }
          if TheCase <> csNominative then
          begin
            if (str3 = 'нок') or (str3 = 'нек') or (str3 = 'нец') or (str3 = 'пец') or
              (str3 = 'чок') or (str3 = 'вец') or (str3 = 'ток') then
              Delete(TheWord, Length (TheWord) - 1, 1);
            if (str3 = 'лец') then
            begin
              Delete(TheWord, Length (TheWord) - 1, 1);
              Insert('ь', TheWord, Length (TheWord));
            end;
          end;
          { ..ий, ..ай, ..ей, ..ел, ..ь, остальные как согласная }
          if (str3 = 'ший') or (str3 = 'чий') then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMF[TheCase];
          end else            
          if str2 = 'ий' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMA[TheCase];
          end else
          if str2 = 'ый' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = 'ой' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = 'ай' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMB[TheCase];
          end else
          if str2 = 'ей' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMC[TheCase];
          end else
          if str2 = 'ел' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMD[TheCase];
          end else
          if (str2 = 'ец') and (str1 in gl) then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + 'йц' + NMF[TheCase];
          end else
          if TheWord [Length(TheWord)] = 'ь' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NME[TheCase];
          end else begin
            TheWord := TheWord + NMF[TheCase];
          end;
        end;
        gdFeminine: begin          { Женский род }
          { ..ь, ..а, ..ья, остальные как ..ия }
          if TheWord [Length(TheWord)] <> 'ь' then { Не склоняются }
          if (str2 = 'га') or (str2 = 'ка') then begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFD[TheCase];
          end else
          if str2 = 'ша' then begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFE[TheCase];
          end else
          if TheWord [Length(TheWord)] = 'а' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NFA[TheCase];
          end else
          if Copy(TheWord, Length(TheWord) - 1, 2) = 'ья' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NFB[TheCase];
          end else begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NFC[TheCase];
          end;
        end;
        else Exit;
      end;
    end;
    nmOwn: begin                  { Обработка имени собственного }
      Case Gender of
        gdMasculine: begin         { Мужской род }
          { ..ий, ..ый, ..ой, остальные как согласная }
          if (str3 = 'ший') or (str3 = 'чий') then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMF[TheCase];
          end else
          if str2 = 'ий' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OMA[TheCase];
          end else
          if str2 = 'ый' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = 'ой' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = 'ай' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMB[TheCase];
          end else
          if str2 = 'уй' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMG[TheCase];
          end else
          if str2 = 'ей' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMH[TheCase];
          end else
          if TheWord[Length(TheWord)] = 'ь' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NME[TheCase];
          end else begin
            TheWord := TheWord + OMD[TheCase];
          end;
        end;
        gdFeminine: begin          { Женский род }
          { ..ая, остальные как ..а }
          if str2 = 'ая' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OFA[TheCase];
          end else
          if (str3 = 'ова') or (str3 = 'eва') or  (str3 = 'ина') or
            (str3 = 'ына') or (str3 = 'ёва') then begin //Балахонова
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + OFB[TheCase];
          end else          
          if TheWord[Length(TheWord)] = 'я' then begin  //например Бетеня
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFB[TheCase];
          end else begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + OFB[TheCase];
          end;
        end;
        else Exit;
      end;
    end;
    else Exit;
  end;
  SetCase := TheWord;
end;

function NameCase(TheWord: String; TheCase: Word): String;
var
  str1: Char;
  Text, StartText, EndText: String;
  PartText: String;
  FEnd: Boolean;
  Position, StartPos :Integer;
begin
  Position := Pos('-', TheWord);
  if Position > 0 then
  begin
    StartText := TheWord;
    FEnd := False;
    StartPos := 0;
    Text := '';
    while not FEnd do
    begin
      PartText := Copy(StartText, StartPos, Position - 1);
      EndText := Copy(StartText, Position, Length(StartText) - Position + 1);
      if PartText > '' then
        str1 := PartText[Length(PartText)]
      else
        str1 := #0;
      if (str1 = 'а') or (str1 = 'я') then //женский род
        Text := Text + SetCase(PartText, TheCase, gdFeminine, nmNar)
      else if str1 in sogl then
        Text := Text + SetCase(PartText, TheCase, gdMasculine, nmNar)
      else
        Text := Text + StartText;
      //проверим окончание
      if (Pos('-', EndText) > 0) and (PartText > '') then
      begin
        Text := Text + '-';
        StartText := Copy(EndText, 2, Length(EndText)) + ' ';
        Position := Pos('-', StartText);
        if Position = 0 then
          Position := Length(StartText);
        StartPos := 0
      end else
      begin
        FEnd := True;
        Text := Text + EndText;
      end;
    end;
    Result := TrimRight(Text);
  end else
  begin
    if TheWord > '' then
    begin
      str1 := TheWord[Length(TheWord)];
      if (str1 = 'а') or (str1 = 'я') then //женский род
        Result := SetCase(TheWord, TheCase, gdFeminine, nmNar)
      else if str1 in sogl then
        Result := SetCase(TheWord, TheCase, gdMasculine, nmNar)
      else
        Result := TheWord;
    end else
      Result := TheWord;
  end;
end;

function ComplexCase(TheWord: String; TheCase: Word): String;
var
  Position, StartPos :Integer;
  str2, Text, StartText: String;
  PartText, EndText: String;
  str1: Char;
  FEnd: Boolean;
begin
  Result := TheWord;
  StartText := AnsiLowerCase(Trim(TheWord));
  //Находим определения, будем искать по пробелу и окончанию.
  Position := Pos(' ', StartText);
  if Position > 0 then
  begin
    FEnd := False;
    StartPos := 0;
    Text := '';
    while not FEnd do
    begin
      PartText := Copy(StartText, StartPos, Position - 1);

      if Length(PartText) = 1 then
      begin
        Text := TheWord;
        FEnd := True;
        continue;
      end;

      EndText := Copy(StartText, Position, Length(StartText) - Position + 1);
      str2 := Copy(PartText, Length(PartText) - 1, 2);
      if PartText > '' then
        str1 := PartText[Length(PartText)]
      else
        str1 := #0;
      if Pos(';' + PartText + ';', IsNumeral) > 0 then
        Text := Text + Numeral(PartText, TheCase) + ' '
      else if (str2 = 'ая') or (str2 = 'яя') then
        Text := Text + SetCase(PartText, TheCase, gdFeminine, nmOwn) + ' '
      else if (str2 = 'ый') or (str2 = 'ий') then
        Text := Text + SetCase(PartText, TheCase, gdMasculine, nmOwn) + ' '
      //Если наименование, то находим, копируем и выходим
      else if (str1 = 'а') or (str1 = 'я') or (str1 in sogl) then //женский род
      begin
        Text := Text + NameCase(PartText, TheCase) {+ ' '} + EndText;
        FEnd := True;
      end else
      begin
        if str1 = '.' then
        begin
          Text := TheWord;
          FEnd := True;
          continue;
        end else
        begin
          if Text > '' then
            Text := Text + ' ' + PartText
          else
            Text := PartText;
        end;
      end;

      //проверим окончание
      if (Pos(' ', EndText) > 0) and (Trim(EndText) <> '') then
      begin
        StartText := TrimLeft(EndText) + ' ';
        Position := Pos(' ', StartText);
        if Position = 0 then
          Position := Length(StartText);
        StartPos := 0
      end else
      begin
        FEnd := True;
        Text := Text + EndText;
      end;
    end;
    Result := TrimRight(Text);
  end else
  if Pos(';' + StartText + ';', IsNumeral) > 0 then
    Result := Numeral(StartText, TheCase)
  else
    Result := NameCase(StartText, TheCase);
end; 

function GetNumericWordForm(const ANum: Integer; const AStrForm1, AStrForm2, AStrForm5: String): String;
var
  Num100, Num10: Integer;
begin
  Num100 := Abs(ANum) mod 100;
  Num10 := Num100 mod 10;
  if (Num100 > 10) and (Num100 <= 20) then
    Result := AStrForm5
  else if (Num10 > 1) and (Num10 < 5) then
    Result := AStrForm2
  else if Num10 = 1 then
    Result := AStrForm1
  else
    Result := AStrForm5;
end;

end.
