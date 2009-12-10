
(*

  * Гэты файл змяшчае кампанэнты шматмоўнай падтрымкі дастасаваньняў
    Яго магчымасьці дазваляюць пад час выкананьня
    праграмы (па выбару карыстальніка, у залежнасьці ад параметраў
    каманднага радка і г.д.) перакладаць тэксты экранных элементаў
    (меткі, радкі рэдактаваньня, кнопкі, табліцы і г.д.) на іншыя мовы.

  * Акрамя гэтага кампанэнты дазваляюць:
      1) змяняць char-set шрыфтоў
         экранных элементаў пад час выкананьня ў адпаведнасці з абранай мовай.

      2) Змяняць парадак сартыроўкі ў SQL запытах пад час выкананьня ў адпаведнасці
         з абранай мовай.

  * Кожная мова мае свой ідэнтыфікатар. Гэта трохлітарнае скарачэньне
    на ангельскай мове. Напрыклад: bel, rus, eng, ger, ita, fra і г.д.

  * Механізм перакладу аснованы на дзвюх кампанэнтах:
    gsMultilingualSupport, gsMultilingualBase

  * першая ставіцца на форму і мае ўласцівасці:

    Уласцівасць                                                                 Значэнне па ўмалчанню
    ===============================================================================================
    -- Enabled   -- будзе працаваць ці не (будзе перекладаць ці не)             True
    -- Language  -- бягучая мова (на якой зараз выводзяцца тэксты контралаў)    rus
    -- Charset   -- бягучы чарсэт, які выкарыстоўваецца ў контралах             RUSSIAN_CHARSET
    -- Context   -- бягучы кантэкст (па ўмалчанню імя формы)                    <form name>

  * другая ставіцца адна на ўвесь праект і мае ўласцівасці:

    Уласцівасць                                                                 Значэнне па ўмалчанню
    ===============================================================================================
    -- Enabled   -- будзе працаваць ці не                                       True
    -- Language  -- мова праграмы (на якую будзе перакладацца)                  rus
    -- CharSet   -- чарсэт, які будзе выкарыстоўвацца                           RUSSIAN_CHARSET
    -- VocFile   -- файл слоўніка (з метазьменнымі)                             %d\mls.voc
    -- CharSetFile  -- файл чарсэтаў (з метазьменнымі)                          %d\mls.chr
    -- IBCollation  --                                                          PXW_CYRL
    -- UseParams    -- ці выкарыстоўваць парамэтры каманднага радка             True
    -- DebugMode --                                                             False
    -- LogFile   --                                                             %d\mls.log

  * як працуе пераклад:

    на форму, для якой неабходна падтрымка шматмоўя, распрацоўшчык
    кладзе кампанэнт TgsMultilingualSupport. У ім уласцівасцям Language і
    CharSet прысвойваюцца адпаведна мова і кодавая табліца, на якой распрацавана
    форма.

    Пры стварэньні гэтай формы кампанэнт актывізуецца. Па першае, ён правярае ўласцівасці
    Enabled каб удасканаліцца, што пераклад дазволены. Далей, ён правярае глябальную
    зьменную gsMultilingualBase. Гэта зьменная аб'яўляецца ў файле gsMultilingualBase_unit.pas
    і прысвайваецца пад час стварэньня кампанэнта gsMultilingualSupport на галоўнай форме.
    Калі пераклад дазволены і наяўная мова формы (мова уласцівасці Language) адрозніваецца
    ад мовы ў кампанэнце gsMultilingualBase, то адбываецца пераклад усіх контралаў.
    Аналагічна ж і з чар сэтам. Пасьля гэтага ўласцівасць Language прымае новае значэньне
    (CharSet таксама). Пераклад адбываецца пад час выкліку падзеі OnShow.

    Пры перакладзе, спачатку шукаецца слова з кантэкстам, як у кампанэнта gsMultilingualSupport.
    Калі пад такім кантэкстам слова няма, то шукаецца ў сьпісе слоў з глябальным кантэкстам.
    Калі слова не найдзена, то -- пакідаецца без перакладу. Калі ўласцівасьць DebugMode
    глябальнай зьменнай gsMultilingualSupport раўняецца True, то неперакладзеннае слова (тэкст)
    запісваецца ў файл LogFile.

    на галоўную форму праекту кладзецца кампанэнт тыпу TgsMultilingualBase. Пры яго стварэньні
    ініцыялізуецца зьменная gsMultilingualBase.

    Каб змяніць мову праекту (г.з. перакласці ўсе экранныя элементы) неабходна прысвоіць
    уласцівасцям глябальнай зьменнай gsMultilingualBase новыя значэньні Language і CharSet.
    Пасьля гэтага кожная ствараемая (альбо вывадзімая на экран) форма будзе перакладзена на
    наяўную мову. Змяніць мову можна ў любым месцы праграмы, у любы час выкананьня.

  * Фармат файла слоўніка:

    файл складаецца са строк, кожная з якіх можа быць:

    -- каментарам -- пачынаецца з "//"
    -- пачаткам кантэксту -- мае фармат "CONTEXT=nnn", дзе nnn -- імя кантэксту. -1 кантэкст
       па ўмалчанню.
    -- пачаткам слоўнікавай стацці -- "^A<text>", дзе <text> -- тэкст слоўнікавай стацці
    -- працягам слоўнікавай стацці -- <text>
    -- пустой стракой

    тэкст слоўнікавай стацці мае наступны фармат:
    [lll]ttt[bbb]aaa....

    дзе lll -- трохлітарны ідэнтыфікатар мовы, ttt -- тэкст на гэтай мове,
      bbb -- ідэнтыфікатар мовы, aaa -- тэкст, і г.д.

    тэкст на выбранай мове -- павольны тэкст, можа ўтрымліваць прабелы.
      пачаткам тэксту лічыцца зачыняючая квадратовая скобка ідэнтыфікатара
      мовы. Канчаткам тэксту лічыцца: 1) адчыняючая квадратовая скобка наступнага
      ідэнтыфікатару мовы; 2) пачатак наступнай слоўнікавай стацьці; 3) пачатак
      наступнага кантэксту; 4) камянтар; 5) канец файла.

  * шлях да файла слоўніка захоўваецца ў адпаведнай уласцівасці глябальнай зьменнай
    gsMultilingualBase. Калі гэтая ўласцівасць пустая, то праграма будзе спрабаваць
    знайсці шлях у рэестры пад ключом: HKEY_CURRENT_USER\Software\Golden Software\Shared\MLSVocabulary
    і адпаведна файл з чар-сэтамі пад ключом -- HKEY_CURRENT_USER\Software\Golden Software\Shared\MLSCharSet

    MLS азначае MultilingualSupport

  * Калі ўласцівасці UseParams глябальнай зьменнай gsMultilingualSupport прымае значэньне True
    кампанэнт правярае параметры каманднага радка праграмы і калі ёсці ключ /lang:<lng> дзе
    <lng> адпаведны трохлітарны ідэнтыфікатар мовы, то значэньне ўласцівасці Language
    прысваіваецца ў адпаведны ідэнтыфікатар.

*)

{
  Доработки:

  Готово: 1. Необходимо добавить считывание ISCollation в список
  Готово: 2. Также нужно сбрасывать все переводы в файл LofFile:
     - дата
     - Форма
     - Имя контрола
     - прошлое значение
     - перевод

  Готово: 3. Нужно все протестировать
  Готово: 4. ипользование параметров командной строки
}

{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    gsMultilingualSupport.pas

  Abstract

    A non-visual component that translates interface text data between different
    languages.

  Author

    Andrei Kireev (27-Jul-99)

  Contact address

    a_kireev@yahoo.com

  Revisions history

    1.00   27-Jul-99    andreik      Initial version.
    1.01   11-Aug-99    andreik      Interbase collations added.
    2.00   11-Aug-99    dennis       Andrew's code destroyed. Project restarted.
    3.00   11-Aug-99    dennis       A big half is ready. Classes should be added.
    3.10   14-Aug-99    dennis       Vocabulary can be loaded in memory.
    3.20   15-Aug-99    dennis       Now you should use [rus] of [eng] instead of [1] or [2].
                                     [...] or [..] supported.
    3.30   16-Aug-99    dennis       Buggs fixed. Params supported.

    4.00   29-Aug-99    dennis       Everything's destroyed again. Project restarted
                                     and complited for beta testing.

    4.00   27-Oct-99    dennis, JKL  Some bugs fixed.
--}

unit gsMultilingualSupport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExList;

type
  TTranslateContext = class
  private
    FContext: String; // Наименование контекста
    FArticles: TExList; // Список статей по контексту
    FSorted: Boolean;

    function GetArticleCount: Integer;
    function GetArticle(AnIndex: Integer): TStringList;

  public
    constructor Create;
    destructor Destroy; override;

    procedure SortContext(const LangIndex: Integer; Low, High: Integer);
    procedure AddArticle(AnArticle: TStringList);

    // Наименование контекста
    property Context: String read FContext write FContext;
    // Количество статей по контексту
    property ArticleCount: Integer read GetArticleCount;
    // Статья по индексу
    property Article[Index: Integer]: TStringList read GetArticle; default;

  end;

type
  TgsMultilingualBase = class(TComponent)
  private
    FEnabled: Boolean; // Является ли компонента активной
    FLanguage: String; // Язык, на который будет осуществляться перевод
    FVocFile: TFileName; // Путь к файлу словаря
    FCharSetFile: TFileName; // Путь к файлу charset-ов
    FUseParams: Boolean; // Использовать ли строку параметров для выбора языка перевода
    FDebugMode: Boolean; // Записывать ли переведенный текст в LogFile
    FLogFile: TFileName; // Файл, куда сбрасывается перевод

    FVocabulary: TExList; // Словарь
    FCharsets: TList; // Список символьных таблиц
    FLangNames: TStringList; // Наименования языков
    FCollations: TStringList; // Список Collation от Interbase

    procedure LoadCharsetsAndCollations;
    procedure LoadVocabulary;

    function GetLangIndex(const LangText: String; var LangIndex: Integer): Boolean;

    function GetContextCount: Integer;
    function GetTranslateContext(AnIndex: Integer): TTranslateContext;
    function GetTranslateToLang: Integer;
    function GetCurrentCharset: TFontCharset;

    function FindCharSet(CharsetLanguage: Integer; var CharSet: TFontCharset): Boolean;
    function FindIBCollation(IBLanguage: Integer; var TheCollation: String): Boolean;

    procedure SetVocFile(const Value: TFileName);
    procedure SetCharSetFile(const Value: TFileName);
    procedure SetLogFile(const Value: TFileName);

  protected
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadFiles;
    function FindContext(const ContextName: String; var Context: TTranslateContext): Boolean;

    function TranslateText(
      const FromLang, Context: String;
      Text: String;
      var Translation: String;
      const CustomContext: TTranslateContext = nil;
      const CustomFromLang: Integer = -1;
      const NoAmpersants: Boolean = False): Boolean;

    // Кол-во контекстов
    property ContextCount: Integer read GetContextCount;
    // Контекст по индексу
    property Vocabulary[Index: Integer]: TTranslateContext read GetTranslateContext;
    // Индекс языка, на который необходимо произвести перевод
    property TranslateToLang: Integer read GetTranslateToLang;
    // Возвращает текущую сивольную таблицу
    property Charset: TFontCharset read GetCurrentCharset;

  published
    // Является ли компонента активной
    property Enabled: Boolean read FEnabled write FEnabled;
    // Язык, на который будет осуществляться перевод
    property Language: String read FLanguage write FLanguage;
    // Путь к файлу словаря
    property VocFile: TFileName read FVocFile write SetVocFile;
    // Путь к файлу charset-ов
    property CharSetFile: TFileName read FCharSetFile write SetCharSetFile;
    // Использовать ли строку параметров для выбора языка перевода
    property UseParams: Boolean read FUseParams write FUseParams;
    // Записывать ли переведенный текст в LogFile
    property DebugMode: Boolean read FDebugMode write FDebugMode;
    // Файл, куда сбрасывается перевод
    property LogFile: TFileName read FLogFile write SetLogFile;

  end;

type
  TgsMultilingualSupport = class(TComponent)
  private
    FEnabled: Boolean; // Активна ли компонента
    FLanguage: String; // Язык, на котором работает проект
    FContext: String; // Контекст формы

    FTranslateList: TList; // Список компонент, которые необходимо перевести
    OldOnShow: TNotifyEvent; // Событие пользователя

    procedure CreateTranslateList;
    procedure ProceedTranslation(const ShouldCreateList: Boolean = True);
    procedure DoOnShow(Sender: TObject);

    function GetTranslateFromLang: Integer;
    function GetTranslateToLang: Integer;
    function GetCharset: TFontCharset;
    function GetTranslateToCharset: TFontCharset;
    function GetIBCollation: String;

  protected
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Translate(const Lang: String);
    procedure ForceTranslate;
    procedure TranslateComponent(Component: TComponent; const Lang: String);
    function TranslateWord(const Text, Lang: String): String;

    // Индекс языка, с которого необходимо произвести перевод
    property TranslateFromLang: Integer read GetTranslateFromLang;
    // Язык, на который мы переводим
    property TranslateToLang: Integer read GetTranslateToLang;
    // Возвращает сивольную таблицу, которую необходимо установить после перевода
    property Charset: TFontCharset read GetCharset;
    // Символьная таблица языка, на который нужно переводить
    property TranslateToCharset: TFontCharset read GetTranslateToCharset;
    // Возвращает вид сорировки для Interbase
    property IBCollation: String read GetIBCollation;

  published
    // Активна ли компонента
    property Enabled: Boolean read FEnabled write FEnabled;
    // Язык, на котором работает проект
    property Language: String read FLanguage write FLanguage;
    // Контекст формы
    property Context: String read FContext write FContext;

  end;

//procedure Register;

var
  // Ссылка на компоненту, содержащую основные
  // параметры и данные для переводов
  TranslateBase: TgsMultilingualBase;

function TranslateText(S: String): String;
function GetCurrentLang: String;
function TranslatePChar(P: PChar; S: String): PChar;
function MessageBoxStr(Handle: hWnd; Text, Caption: String; Params: Integer): Integer;
function ChangeCollate(SQL: String; OldCollate, NewCollate: String): String;

implementation

uses
  StdCtrls, Grids, DBGrids, Registry, xDBLookU, xDBLookupStored,
  DBCtrls, ExtCtrls, Buttons, mBitButton, xBulbBtn,
  Menus, ActnList, xBasics, mmTopPanel, mmStateMenu, mTabSetVer,
  mTabSetHor, ComCtrls, DB, xLglPad, CheckLst, xYellabl, xColorTabSet, xHint,
  mmRadioButtonEx, ColCB;


// Классы, которые необходимо обрабатывать:
const
  TranslateClassCount = 39;
  TranslateClassTypes: array[0..TranslateClassCount - 1] of TClass =
  (
    TForm,
    TButton,
    TBitBtn,
    TmBitButton,
    TxBulbButton,
    TxYellowLabel,
    TxColorTabSet,
    TPanel,
    TLabel,
    TEdit,
    TDBEdit,
    TStringGrid,
    TDBGrid,
    TCustomListBox,
    TCustomComboBox,
    TMemo,
    TRadioGroup,
    TmmRadioGroup,
    TGroupBox,
    TRadioButton,
    TCheckBox,
    TDBCheckBox,
    TxDBLookUpCombo,
    TxDBLookUpCombo2,
    TMenuItem,
    TAction,
    TmmTopPanel,
    TmmStateMenu,
    TmTabSetVer,
    TmTabSetHor,
    TNotebook,
    TListView,
    TDataSet,
    TxLegalPad,
    TSpeedButton,
    TxHint,
    TColorComboBox,
    TTabSheet,
    TStaticText
  );


// Текстовыя константы
const
  STR_COMMENT = '//';
  STR_ARTICLE = '^A';
  STR_CONTEXT = 'CONTEXT=';
  STR_DEFAULTCONTEXT = '-1';

{
  **********************************
  ***   Registration procedure   ***
  **********************************
}

{procedure Register;
begin
  RegisterComponents('gsNV', [TgsMultilingualBase]);
  RegisterComponents('gsNV', [TgsMultilingualSupport]);
end;}

// Производит перевод текста
function TranslateText(S: String): String;
var
  Translation: String;
begin
  if (TranslateBase <> nil) and
    TranslateBase.TranslateText('rus', '-1', S, Translation)
  then
    Result := Translation
  else
    Result := S;
end;

// Возвращает текущий язык
function GetCurrentLang: String;
begin
  if TranslateBase <> nil then
    Result := TranslateBase.Language
  else
    Result := 'rus';
end;

// Переводит строку и делает е PChar
function TranslatePChar(P: PChar; S: String): PChar;
begin
  Result := StrPCopy(P, TranslateText(S));
end;

// строка вместо PChar
function MessageBoxStr(Handle: hWnd; Text, Caption: String; Params: Integer): Integer;
var
  P: array[0..250] of char;
begin
  Result := Windows.MessageBox(
    Handle,
    StrPCopy(P, TranslateText(Text)),
    StrPCopy(P, TranslateText(Caption)), Params);
end;

// Устанавливает новый IB Collate
function ChangeCollate(SQL: String; OldCollate, NewCollate: String): String;
var
  I: Integer;
begin
  if AnsiCompareText(OldCollate, NewCollate) = 0 then
  begin
    Result := SQL;
    Exit;
  end;

  repeat
    I := AnsiPos(OldCollate, SQL);

    if I > 0 then
      SQL :=
        Copy(SQL, 1, I - 1) +
        NewCollate +
        Copy(SQL, I + Length(OldCollate), Length(SQL));
  until I = 0;

  Result := SQL
end;

// Производит поиск индекса языка в статье
function FindLangIndex(const LangIndexToFind: Integer; TheArticle: TStringList;
  var FoundIndex: Integer): Boolean;
var
  K: Integer;
begin
  for K := 0 to TheArticle.Count - 1 do
    if Integer(TheArticle.Objects[K]) = LangIndexToFind then
    begin
      Result := True;
      FoundIndex := K;
      Exit;
    end;

  Result := False;
end;

// Подсчитывает количество пробелов
function CountBeforeSpaces(S: String): Integer;
begin
  Result := 0;

  if Length(S) > 0 then
    while
      (Result < Length(S))
        and
      (S[Result + 1] = ' ')
    do
      Inc(Result);
end;

// Подсчитывает количество пробелов
function CountAfterSpaces(S: String): Integer;
var
  Z: Integer;
begin
  Z := Length(S);

  while
    (Z > 0)
      and
    (S[Z] = ' ')
  do
    Dec(Z);

  Result := Length(S) - Z;
end;

// Удаляем всякую гадасть
function DeleteSpaces(S: String): String;
var
  Z: Integer;
begin
  Z := 1;

  while Z <= Length(S) do
  begin
    if S[Z] in [' ', #13, #10, #9] then
      S := Copy(S, 1, Z - 1) + Copy(S, Z + 1, Length(S))
    else
      Inc(Z);
  end;

  Result := S;
end;

// Удаляет знак амперсанта
function DeleteAmpersants(S: String): String;
var
  Z: Integer;
begin
  repeat
    Z := AnsiPos('&', S);

    if Z > 0 then
      S := Copy(S, 1, Z - 1) + Copy(S, Z + 1, Length(S));
  until Z = 0;

  Result := S;
end;

{
  ----------------------------------------------------
  ---                                              ---
  ---   TContext Class - раздел словарных статей   ---
  ---                                              ---
  ----------------------------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TTranslateContext.Create;
begin
  FArticles := TExList.Create;
  FContext := STR_DEFAULTCONTEXT;
  FSorted := False;
end;

{
  Делаем конечные установки.
}

destructor TTranslateContext.Destroy;
begin
  FArticles.Free;

  inherited Destroy;
end;

{
  Добавляет новую словарную статью
}

procedure TTranslateContext.AddArticle(AnArticle: TStringList);
begin
  FArticles.Add(AnArticle);
end;

{
  Сортирует контекст.
}

procedure TTranslateContext.SortContext
(
  const LangIndex: Integer; Low, High: Integer
);

var
  I, J: Integer;
  P, T: TStringList;

  // Производит сортировку
  function SortArticles(Item1, Item2: TStringList): Integer;
  var
    LanguageIndex: Integer;
    Text1, Text2: String;
  begin
    if FindLangIndex(LangIndex, Item1, LanguageIndex) then
    begin
      Text1 := DeleteSpaces(Item1[LanguageIndex]);

      if FindLangIndex(LangIndex, Item2, LanguageIndex) then
      begin
        Text2 := DeleteSpaces(Item2[LanguageIndex]);
        Result := AnsiCompareText(Text1, Text2);
      end else
        raise Exception.Create('Ошибка');
    end else
      raise Exception.Create('Ошибка');
  end;

begin

  repeat
    I := Low;
    J := High;
    P := FArticles[(Low + High) shr 1];
    repeat
      while SortArticles(FArticles[I], P) < 0 do Inc(I);
      while SortArticles(FArticles[J], P) > 0 do Dec(J);
      if I <= J then
      begin
        T := FArticles[I];
        FArticles[I] := FArticles[J];
        FArticles[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if Low < J then SortContext(LangIndex, Low, J);
    Low := I;
  until I >= High;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Возвращает кол-во словарных статей по контексту.
}

function TTranslateContext.GetArticleCount: Integer;
begin
  Result := FArticles.Count;
end;

{
  Возвращает словарную статью по индексу.
}

function TTranslateContext.GetArticle(AnIndex: Integer): TStringList;
begin
  Result := FArticles[AnIndex];
end;

{
  ------------------------------------
  ---                              ---
  ---   TgsMultilingualBase Class  ---
  ---                              ---
  ------------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TgsMultilingualBase.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  TranslateBase := Self;

  // Начальные установки переменным
  FEnabled := True;
  FLanguage := 'rus';
  FVocFile := '';
  FCharSetFile := '';
  FUseParams := True;
  FDebugMode := False;
  FLogFile := '';

  FVocabulary := TExList.Create;
  FLangNames := TStringList.Create;
  FCharsets := TList.Create;
  FCollations := TStringList.Create;
end;

{
  Делаем конечные установки.
}

destructor TgsMultilingualBase.Destroy;
begin
  TranslateBase := nil;

  FVocabulary.Free;
  FLangNames.Free;
  FCharsets.Free;
  FCollations.Free;

  inherited Destroy;
end;

{
  Производит загрузку словаря и символьной таблицы.
}

procedure TgsMultilingualBase.LoadFiles;
begin
  LoadCharsetsAndCollations;
  LoadVocabulary;
end;

{
  Производит поиск контекста в словаре.
}

function TgsMultilingualBase.FindContext(const ContextName: String;
  var Context: TTranslateContext): Boolean;
var
  I: Integer;
begin
  for I := 0 to ContextCount - 1 do
    if AnsiCompareText(Vocabulary[I].Context, ContextName) = 0 then
    begin
      Result := True;
      Context := Vocabulary[I];
      Exit;
    end;

  Result := False;
end;

{
  Производит перевод текста.
  FromLang - язык, с которого будем переводить

  Context - контекст формы ( -1 - по умолчанию )

  Text - текст для перевода

  Translation - переведенный текст

  CustomContext - если пользователь хочет, чтобы метод не производил
  поиск контекста для каждого нового слова к переводу, он может
  самостоятельно найти контекст и передовать его в этот метод
  данным параметром
}

function TgsMultilingualBase.TranslateText(
  const FromLang, Context: String;
  Text: String;
  var Translation: String;
  const CustomContext: TTranslateContext = nil;
  const CustomFromLang: Integer = -1;
  const NoAmpersants: Boolean = False): Boolean;
var
  I: Integer;
  Dots: Integer;
  CurrContext: TTranslateContext;
  FromLangIndex: Integer;
  CurrArticle: TStringList;
  LanguageIndex, TranslateIndex: Integer;
  BeforeSpaces, AfterSpaces: Integer;
  Low, High: Integer;
  Current: Integer;
  CompareResult: Integer;
begin
  Result := False;
  if Text = '' then Exit;

  // Подсчитываем пробелы
  BeforeSpaces := CountBeforeSpaces(Text);
  AfterSpaces := CountAfterSpaces(Text);
  Text := DeleteSpaces(Text);

  if NoAmpersants then
    Text := DeleteAmpersants(Text);

  // Если используется пользовательский индекс языка
  if CustomFromLang >= 0 then
    FromLangIndex := CustomFromLang
  else
    // Если не найден индекс языка, то выходим из процедуры
    if not GetLangIndex(FromLang, FromLangIndex) then
      Exit;

  // Если язык, с которого переводим, равняется языку, на который пеерводим,
  // то выходим из метода
  if FromLangIndex = TranslateToLang then Exit;

  // Если пользовательский контекст задан, то используем его
  if CustomContext <> nil then
    CurrContext := CustomContext
  else
    CurrContext := nil;

  // Производим поиск необходимого контекста, если он не задан
  if (CurrContext <> nil) or FindContext(Context, CurrContext) then
  begin
    // Если контекст не отсортирован, то сортируем его
    if not CurrContext.FSorted then
    begin
      for I := CurrContext.FArticles.Count - 1 downto 0 do
        if not FindLangIndex(FromLangIndex, CurrContext.FArticles[I], LanguageIndex) then
          CurrContext.FArticles.Delete(I);

      CurrContext.SortContext(FromLangIndex, 0, CurrContext.FArticles.Count - 1);
      CurrContext.FSorted := True;
    end;

    Low := 0;
    High := CurrContext.ArticleCount - 1;

    CompareResult := 0;

    while Low <= High do
    begin
      Current := (Low + High) shr 1;
      CurrArticle := CurrContext.Article[Current];

      // Если в статье найден индекс языка, с которого нужно переводить
      if FindLangIndex(FromLangIndex, CurrArticle, LanguageIndex) then
      begin
        CompareResult := AnsiCompareText(Text, DeleteSpaces(CurrArticle[LanguageIndex]));

        // Обычное сравнение текста
        if CompareResult = 0 then
        begin
          // Производим поиск в статье кода языка, на который необходимо произвести перевод
          if FindLangIndex(TranslateToLang, CurrArticle, TranslateIndex) then
          begin
            Result := True;
            Translation := CurrArticle[TranslateIndex];
            Break;
          end;
        end else begin
          // Проверка на ...
          Dots := AnsiPos('...', Text);

          if (Dots > 0) and (AnsiCompareText(Copy(Text, 1, Dots - 1),
            DeleteSpaces(CurrArticle[LanguageIndex])) = 0) then
          begin
            // Производим поиск в статье кода языка, на который необходимо произвести перевод
            if FindLangIndex(TranslateToLang, CurrArticle, TranslateIndex) then
            begin
              Result := True;
              Translation := CurrArticle[TranslateIndex] + '...';
              Break;
            end;
          end else begin
            // Проверка на ..
            Dots := AnsiPos('..', Text);

            if (Dots > 0) and (AnsiCompareText(Copy(Text, 1, Dots - 1),
              DeleteSpaces(CurrArticle[LanguageIndex])) = 0) then
            begin
              // Производим поиск в статье кода языка, на который необходимо произвести перевод
              if FindLangIndex(TranslateToLang, CurrArticle, TranslateIndex) then
              begin
                Result := True;
                Translation := CurrArticle[TranslateIndex] + '..';
                Break;
              end;

            // Если последний символ не является текстом, то пробуем отсекать его
            end else if
              (Length(Text) > 0)
                and
              (Text[Length(Text)] in ['!', '.', ':', '?', ','])
                and
              (AnsiCompareText(Copy(Text, 1, Length(Text) - 1),
                DeleteSpaces(CurrArticle[LanguageIndex])) = 0)
            then begin
              // Производим поиск в статье кода языка, на который необходимо произвести перевод
              if FindLangIndex(TranslateToLang, CurrArticle, TranslateIndex) then
              begin
                Result := True;
                Translation := CurrArticle[TranslateIndex] + Text[Length(Text)];
                Break;
              end;
            end;
          end;
        end;
      end else begin
        // Если в записи нет индкса языка, то удаляем ее
        FVocabulary.Remove(CurrContext);

        Low := 0;
        High := CurrContext.ArticleCount - 1;

        Continue;
      end;

      if CompareResult < 0 then
        High := Current - 1
      else
        Low := Current + 1;
    end;
  end;


  if not Result and not NoAmpersants then
    Result := TranslateText(FromLang, Context, Text, Translation,
      CustomContext, CustomFromLang, True);

  // Если не нашлось перевода в контексте, то производим поиск его
  // в контексте по умолчанию
  if Assigned(CurrContext) and not Result and
    (AnsiCompareText(CurrContext.Context, STR_DEFAULTCONTEXT) <> 0)
  then
    Result := TranslateText(FromLang, STR_DEFAULTCONTEXT, Text, Translation, nil,
      CustomFromLang, NoAmpersants);

  // Добавляем пробелы, сокотрые были отсечены от начала текста
  if Result then
  begin
    for I := 1 to BeforeSpaces do Translation := ' ' + Translation;
    for I := 1 to AfterSpaces do Translation := Translation + ' ';
  end;
end;

{
function TgsMultilingualBase.TranslateText(
  const FromLang, Context: String;
  Text: String;
  var Translation: String;
  const CustomContext: TTranslateContext = nil;
  const CustomFromLang: Integer = -1;
  const NoAmpersants: Boolean = False): Boolean;
var
  I: Integer;
  Dots: Integer;
  CurrContext: TTranslateContext;
  FromLangIndex: Integer;
  CurrArticle: TStringList;
  LanguageIndex, TranslateIndex: Integer;
  BeforeSpaces, AfterSpaces: Integer;
  Low, High: Integer;
  Current: Integer;
  CompareResult: Integer;
begin
  Result := False;
  if Text = '' then Exit;

  // Подсчитываем пробелы
  BeforeSpaces := CountBeforeSpaces(Text);
  AfterSpaces := CountAfterSpaces(Text);
  Text := DeleteSpaces(Text);

  if NoAmpersants then
    Text := DeleteAmpersants(Text);

  // Если используется пользовательский индекс языка
  if CustomFromLang >= 0 then
    FromLangIndex := CustomFromLang
  else
    // Если не найден индекс языка, то выходим из процедуры
    if not GetLangIndex(FromLang, FromLangIndex) then
      Exit;

  // Если язык, с которого переводим, равняется языку, на который пеерводим,
  // то выходим из метода
  if FromLangIndex = TranslateToLang then Exit;

  // Если пользовательский контекст задан, то используем его
  if CustomContext <> nil then
    CurrContext := CustomContext
  else
    CurrContext := nil;

  // Производим поиск необходимого контекста, если он не задан
  if (CurrContext <> nil) or FindContext(Context, CurrContext) then
  begin
    for I := 0 to CurrContext.ArticleCount - 1 do
    begin
      CurrArticle := CurrContext.Article[I];

      // Если в статье найден индекс языка, с которого нужно переводить
      if FindLangIndex(FromLangIndex, CurrArticle, LanguageIndex) then
      begin
        // Обычное сравнение текста
        if AnsiCompareText(Text, DeleteSpaces(CurrArticle[LanguageIndex])) = 0 then
        begin
          // Производим поиск в статье кода языка, на который необходимо произвести перевод
          if FindLangIndex(TranslateToLang, CurrArticle, TranslateIndex) then
          begin
            Result := True;
            Translation := CurrArticle[TranslateIndex];
            Break;
          end;
        end else begin
          // Проверка на ...
          Dots := AnsiPos('...', Text);

          if (Dots > 0) and (AnsiCompareText(Copy(Text, 1, Dots - 1),
            DeleteSpaces(CurrArticle[LanguageIndex])) = 0) then
          begin
            // Производим поиск в статье кода языка, на который необходимо произвести перевод
            if FindLangIndex(TranslateToLang, CurrArticle, TranslateIndex) then
            begin
              Result := True;
              Translation := CurrArticle[TranslateIndex] + '...';
              Break;
            end;
          end else begin
            // Проверка на ..
            Dots := AnsiPos('..', Text);

            if (Dots > 0) and (AnsiCompareText(Copy(Text, 1, Dots - 1),
              DeleteSpaces(CurrArticle[LanguageIndex])) = 0) then
            begin
              // Производим поиск в статье кода языка, на который необходимо произвести перевод
              if FindLangIndex(TranslateToLang, CurrArticle, TranslateIndex) then
              begin
                Result := True;
                Translation := CurrArticle[TranslateIndex] + '..';
                Break;
              end;

            // Если последний символ не является текстом, то пробуем отсекать его
            end else if
              (Length(Text) > 0)
                and
              (Text[Length(Text)] in ['!', '.', ':', '?', ','])
                and
              (AnsiCompareText(Copy(Text, 1, Length(Text) - 1),
                DeleteSpaces(CurrArticle[LanguageIndex])) = 0)
            then begin
              // Производим поиск в статье кода языка, на который необходимо произвести перевод
              if FindLangIndex(TranslateToLang, CurrArticle, TranslateIndex) then
              begin
                Result := True;
                Translation := CurrArticle[TranslateIndex] + '..';
                Break;
              end;
            end;
          end;
        end;
      end;
    end;
  end;


  if not Result and not NoAmpersants then
    Result := TranslateText(FromLang, Context, Text, Translation,
      CustomContext, CustomFromLang, True);

  // Если не нашлось перевода в контексте, то производим поиск его
  // в контексте по умолчанию
  if Assigned(CurrContext) and not Result and
    (AnsiCompareText(CurrContext.Context, STR_DEFAULTCONTEXT) <> 0)
  then
    Result := TranslateText(FromLang, STR_DEFAULTCONTEXT, Text, Translation, nil,
      CustomFromLang, NoAmpersants);

  // Добавляем пробелы, сокотрые были отсечены от начала текста
  if Result then
  begin
    for I := 1 to BeforeSpaces do Translation := ' ' + Translation;
    for I := 1 to AfterSpaces do Translation := Translation + ' ';
  end;
end;
}

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  После загрузки свойств компоненты производим
  загрузку словаря и символьных таблиц
}

procedure TgsMultilingualBase.Loaded;
var
  I: Integer;
  P: Integer;
  LangRegistry: TRegistry;
begin
  inherited Loaded;

  // Загрузка символьной таблицы и словаря
  if not (csDesigning in ComponentState) then
  begin
    LoadFiles;

    // Если используем параметры для выбора языка перевода
    if FUseParams then
    begin
      for I := 1 to ParamCount do
      begin
        P := AnsiPos('/lang:', ParamStr(I));

        if P > 0 then
          FLanguage := Trim(Copy(ParamStr(I), P + 6, Length(ParamStr(I))))
        else begin
          // Установка дебагера
          P := AnsiPos('/debug', ParamStr(I));
          if P > 0 then FDebugMode := True;
        end;
      end;
    end else begin
      // Если язык был установлен в Registry, то считываем его
      LangRegistry := TRegistry.Create;
      LangRegistry.RootKey := HKEY_CURRENT_USER;

      if LangRegistry.OpenKey('Software\Golden Software\Shared\MLSVocabulary', True) then
      begin
        // Проверка на первый запуск программы сегодня
        if LangRegistry.ValueExists('Language') then FLanguage := LangRegistry.ReadString ('Operator');
      end;    
    end;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Загружаем файл символьных таблиц.
}

procedure TgsMultilingualBase.LoadCharsetsAndCollations;
var
  CSFile: TextFile; // Файл символьных таблиц
  Line: String; // Строка текущая в файле
  Space, EqualPos, CommaPos: Integer; // Позиции в строке
  Index: Integer; // Индекс языка
  TheResult: Integer; // Результато открытия файла
begin
  TheResult := 0;
  
  // Если имя файла не указано, то выходим
  if FCharSetFile = '' then Exit;

  try
    // Производим подсоединение и открытие файла
    {$I-}
    AssignFile(CSFile, FCharSetFile);
    Reset(CSFile);
    TheResult := IOResult;
    {$I+}

    if TheResult <> 0 then Exit;

    while not EOF(CSFile) do
    begin
      // Считываем строку
      Readln(CSFile, Line);
      // Удаляем пробелы
      Line := Trim(Line);

      // Производим поиск комментария в строке
      Space := AnsiPos(STR_COMMENT, Line);
      // Если комментарий есть, то отсекаем его
      if Space > 0 then Line := Copy(Line, 1, Space - 1);

      EqualPos := AnsiPos('=', Line);
      CommaPos := AnsiPos(',', Line);

      // Если знак равно найден
      if EqualPos > 0 then
      begin
        try
          // Итендификатор языка
          if GetLangIndex(Copy(Line, 1, EqualPos - 1), Index) then
          begin
            // Добавляем итендификатор языка
            FCharSets.Add(Pointer(Index));

            // Итендификатор символьной таблицы
            if CommaPos = 0 then // Ели в строке нет запятой
              FCharSets.Add(
                Pointer
                (
                  StrToInt(Copy(Line, EqualPos + 1, Length(Line)))
                ))
            else begin
              FCharSets.Add(
                Pointer
                (
                  StrToInt(Copy(Line, EqualPos + 1, CommaPos - EqualPos - 1))
                ));

              // Добавляем Interbase Collation
              FCollations.Add(Copy(Line, CommaPos + 1, Length(Line)));
              FCollations.Objects[FCollations.Count - 1] := Pointer(Index);
            end;
          end;

        except
          raise Exception.Create('Ошибка в структуре файла символьных таблиц!');
        end;
      end;
    end;
  finally
    // Закрываем файл
    if TheResult = 0 then
    begin
    {$I-}
    CloseFile(CSFile);
    {$I+}
    end;
  end;  
end;

{
  Загружаем словарь.
}

procedure TgsMultilingualBase.LoadVocabulary;
var
  Voc: TextFile; // Файл словаря
  Line: String; // Текущая строка
  ArticleLine: String; // Текущая словарная статья
  CurrContext: TTranslateContext; // Текущий контекст
  ArticlePos, ContextPos, Space: Integer;
  ArticleStarted: Boolean; // Начали ли собирать новую статью
  TheResult: Integer; // Результат открытия файла

  // Производит анализ статьи
  procedure AnalizeCurrArticle(ArticleText: String);
  var
    NewArticle: TStringList;
    I, J: Integer;
    LangIndex: Integer; // Язык

    function ReplaceNewLineSigns(const T: String): String;
    var
      P: Integer;
    begin
      Result := T;

      repeat
        P := AnsiPos('\n', Result);

        if P > 0 then
          Result := Copy(Result, 1, P - 1)
            +
          #13#10
            +
          Copy(Result, P + 2, Length(Result));

      until P = 0;
    end;

  begin
    // Создаем новую статью
    NewArticle := TStringList.Create;
    // В начале ставим нулевой индекс
    LangIndex := -1;

    repeat
      I := Pos('[', ArticleText);

      // Если знак открытия названия языка найден
      if I > 0 then
      begin
        // Если язык уже был найден, то работаем над статьей
        if LangIndex >= 0 then
        begin
          NewArticle.Add(ReplaceNewLineSigns(Copy(ArticleText, 1, I - 1)));
          NewArticle.Objects[NewArticle.Count - 1] := Pointer(LangIndex);
          LangIndex := -1;
        end;

        J := AnsiPos(']', ArticleText);

        // Если знак закрытия названия языка найден
        if J > 0 then
        begin
          // Если не получаем код языка, то переходим в начало цикла
          if not GetLangIndex(Copy(ArticleText, I + 1, J - I - 1), LangIndex) then
          begin
            LangIndex := -1;
            Break;
          end;

          // Оставшаяся строка
          ArticleText := Copy(ArticleText, J + 1, Length(ArticleText));
        end else // Иначе выходим из цикла
          Break;
      end else begin // Иначе выходим из цикла
        // Если язык все же был найден, то работаем над статьей
        if LangIndex >= 0 then
        begin
          NewArticle.Add(ReplaceNewLineSigns(ArticleText));
          NewArticle.Objects[NewArticle.Count - 1] := Pointer(LangIndex);
        end;

        Break;
      end;
    until ArticleText = '';

    // Если строка содержит хотя бы один перевод, то сохраняем ее в словаре
    if NewArticle.Count > 1 then
      CurrContext.AddArticle(NewArticle)
    else // если же нет, то - удаляем
      NewArticle.Free;
  end;

begin
  TheResult := 0;

  // Если имя файла не указано, то выходим
  if FVocFile = '' then Exit;

  // Начальные установки для переменных
  ArticleLine := '';
  ArticleStarted := False;
  CurrContext := nil;

  try
    // Производим соединение с файлом словаря на диске по указанному пути
    {$I-}
    AssignFile(Voc, FVocFile);
    Reset(Voc);
    TheResult := IOREsult;
    {$I+}
    if TheResult <> 0 then Exit;

    while not EOF(Voc) do
    begin
      // Считываем строку
      Readln(Voc, Line);

      // Убираем пробелы
      Line := Trim(Line);

      // Производим поиск комментария в строке
      Space := AnsiPos(STR_COMMENT, Line);
      // Если комментарий есть, то отсекаем его
      if Space > 0 then Line := Copy(Line, 1, Space - 1);

      // Если строка не пуста
      if Length(Line) > 0 then
      begin
        // Производим поиск знака контекста
        ContextPos := AnsiPos(STR_CONTEXT, Line);

        // Если знак контекста найден
        if ContextPos > 0 then
        begin
          // Все содерживае в строке, в которой находится новый контекст игнорируем
          // как содержимое словарной статьи
          if ArticleStarted then
          begin
            // Анализируем статью и добавляем ее в словарь
            AnalizeCurrArticle(ArticleLine);
            ArticleStarted := False;
          end;

          // Если по контексту была создана хотя бы одна статья, то сохраняем его
          if (CurrContext <> nil) and (CurrContext.ArticleCount > 0) then
            FVocabulary.Add(CurrContext)
          else // если нет - удаляем его
            CurrContext.Free;

          // Добавляем его в словарь
          CurrContext := TTranslateContext.Create;
          CurrContext.Context := Trim(Copy(Line, ContextPos + Length(STR_CONTEXT) + 1, Length(Line)));

        end else begin // Если же знак контекста не найден
          // Определяем позицию начала статьи
          ArticlePos := AnsiPos(STR_ARTICLE, Line);

          if ArticlePos = 0 then // Если нет новой статьи в строке
          begin
            // Если статья уже была начата
            if ArticleStarted then
            begin
              // Добавляем пробел, если был переход на новую строку
              if (Length(ArticleLine) > 0) and not (Line[1] in ['[', ']']) and not
                (ArticleLine[Length(ArticleLine)] in ['[', ']'])
              then
                ArticleLine := ArticleLine + ' ';

              // Дописываем строку
              ArticleLine := ArticleLine + Line;
            end;

            Continue;
          end else begin // Если новая статья все же есть

            // Если статья до этого уже была начата
            if ArticleStarted then
            begin
              // Добавляем пробел, если был переход на новую строку
              if (Length(ArticleLine) > 0) and not (Line[1] in ['[', ']']) and (ArticlePos > 1) and not
                (ArticleLine[Length(ArticleLine)] in ['[', ']'])
              then
                ArticleLine := ArticleLine + ' ';

              // Дописываем строку
              ArticleLine := ArticleLine + Copy(Line, 1, ArticlePos - 1);

              // Анализируем статью и добавляем ее в словарь
              AnalizeCurrArticle(ArticleLine);

              // Собираем новую статью
              ArticleLine := Copy(Line, ArticlePos + 2, Length(Line));
            end else begin // Если это первая словарная статья
              ArticleStarted := True;

              // Собираем новую статью
              ArticleLine := Copy(Line, ArticlePos + 2, Length(Line));
            end;
          end;
        end;
      end;
    end;

    // После завершения цикла заканчиваем обработку данных
    if ArticleStarted then
    begin
      // Анализируем статью и добавляем ее в словарь
      AnalizeCurrArticle(ArticleLine);
    end;

    // Если по контексту была создана хотя бы одна статья, то сохраняем его
    if (CurrContext <> nil) and (CurrContext.ArticleCount > 0) then
      FVocabulary.Add(CurrContext)
    else // если нет - удаляем его
      CurrContext.Free;

  finally
    // Закрываем связь с файлом
    if (TheResult = 0) then
    begin
      {$I-}
      CloseFile(Voc);
      {$I+}
    end;
  end;
end;

{
  Возвращает индекс языка.
  На каждый язык один раз создается уникальный индекс, который в последствии
  используется для перевода.
}

function TgsMultilingualBase.GetLangIndex(const LangText: String; var LangIndex: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;

  // Производим поиск наименования языка в списке языков
  for I := 0 to FLangNames.Count -1 do
    if AnsiCompareText(LangText, FLangNames[I]) = 0 then
    begin
      Result := True;
      LangIndex := Integer(FLangNames.Objects[I]);
      Break;
    end;

  // Если такого языка в списке нет, то добавляем его и присваиваем
  // уникальный индекс
  if not Result and (LangText <> '') then
  begin
    FLangNames.Add(LangText);

    if FLangNames.Count > 1 then
      FLangNames.Objects[FLangNames.Count - 1] :=
        Pointer(Integer(FLangNames.Objects[FLangNames.Count - 2]) + 1)
    else
      FLangNames.Objects[FLangNames.Count - 1] := Pointer(1);

    LangIndex := Integer(FLangNames.Objects[FLangNames.Count - 1]);

    Result := True;
  end;
end;

{
  Возвращает кол-во контекстов.
}

function TgsMultilingualBase.GetContextCount: Integer;
begin
  Result := FVocabulary.Count;
end;

{
  Возвращает контекст по индексу.
}

function TgsMultilingualBase.GetTranslateContext(AnIndex: Integer): TTranslateContext;
begin
  Result := FVocabulary[AnIndex];
end;

{
  Возвращает индекс языка, на который необходимо произвести перевод
}

function TgsMultilingualBase.GetTranslateToLang: Integer;
begin
  // Если индекс языка не найден, то делаем его нулевым
  if not GetLangIndex(FLanguage, Result) then
    Result := -1;
end;

{
  Возвращает текущую символьную таблицу.
}

function TgsMultilingualBase.GetCurrentCharset: TFontCharset;
begin
  if not FindCharSet(TranslateToLang, Result) then
    Result := DEFAULT_CHARSET;
end;

{
  Производит поиск необходимой символьной таблицы для данного итендификатора языка.
}

function TgsMultilingualBase.FindCharSet(CharsetLanguage: Integer; var CharSet: TFontCharset): Boolean;
var
  K: Integer;
begin
  K := 0;
  Result := False;

  while K <= FCharSets.Count - 1 do
  begin
    if Integer(FCharSets[K]) = CharsetLanguage then
    begin
      CharSet := TFontCharset(FCharSets[K + 1]);
      Result := True;
      Break;
    end;

    Inc(K, 2);
  end;
end;

{
  По индексу языка возвращает Interbase Collation.
}

function TgsMultilingualBase.FindIBCollation(IBLanguage: Integer; var TheCollation: String): Boolean;
var
  I: Integer;
begin
  for I := 0 to FCollations.Count - 1 do
    if Integer(FCollations.Objects[I]) = IBLanguage then
    begin
      Result := True;
      TheCollation := FCollations[I];
      Exit;
    end;

  Result := False;
end;

{
  Устаналивается новый путь к файлу словаря.
}

procedure TgsMultilingualBase.SetVocFile(const Value: TFileName);
begin
  if FVocFile <> Value then
  begin
    FVocFile := Value;
    
    if not (csDesigning in ComponentState) and (Pos('%d', FVocFile) = 1) then
      FVocFile := RealFileName(FVocFile);
  end;
end;

{
  Устанавливается новый путь к файлу Charset-ов.
}

procedure TgsMultilingualBase.SetCharSetFile(const Value: TFileName);
begin
  if FCharSetFile <> Value then
  begin
    FCharSetFile := Value;

    if not (csDesigning in ComponentState) and (Pos('%d', FCharSetFile) = 1) then
      FCharSetFile := RealFileName(FCharSetFile);
  end;
end;

{
  Устанавливает новый путь к файлу, в котором скапливаются
  данные по переводу текста.
}

procedure TgsMultilingualBase.SetLogFile(const Value: TFileName);
begin
  if FLogFile <> Value then
  begin
    FLogFile := Value;

    if not (csDesigning in ComponentState) and (Pos('%d', FLogFile) = 1) then
      FLogFile := RealFileName(FLogFile);
  end;
end;

{
  ---------------------------------------
  ---                                 ---
  ---   TgsMultilingualSupport Class  ---
  ---                                 ---
  ---------------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TgsMultilingualSupport.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // Начальные установки
  FEnabled := True;
  FLanguage := 'rus';
  FContext := Owner.ClassName;
  OldOnShow := nil;

  FTranslateList := TList.Create;
end;

{
  Делаем конечные установки.
}

destructor TgsMultilingualSupport.Destroy;
begin
  FTranslateList.Free;

  inherited Destroy;
end;

{
  Вызывает перевод вручную.
}

procedure TgsMultilingualSupport.Translate(const Lang: String);
begin
  // Если изменился язык базовой компоненты, то необходимо изменить
  // язык в форме, в которой находится компонента поддержки языка
  if Assigned(TranslateBase) then
  begin
    FLanguage := Lang;
    ProceedTranslation;
  end;
end;

{
  Принудительный перевод формы.
}

procedure TgsMultilingualSupport.ForceTranslate;
begin
  DoOnShow(Self);
end;

{
  Производитперевод компоненты.
}

procedure TgsMultilingualSupport.TranslateComponent(Component: TComponent; const Lang: String);
var
  OldLang: String;
begin
  if Assigned(TranslateBase) then
  begin
    OldLang := FLanguage;
    FLanguage := Lang;
    FTranslateList.Clear;
    FTranslateList.Add(Component);
    ProceedTranslation(False);
    FTranslateList.Clear;
    FLanguage := OldLang;
  end;
end;

{
  Производит перевод слова.
}

function TgsMultilingualSupport.TranslateWord(const Text, Lang: String): String;
var
  TranslatedText: String;
begin
  if TranslateBase.TranslateText(Lang, FContext, Text, TranslatedText) then
    Result := TranslatedText
  else
    Result := Text;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  После загрузки свойств делаем свои установки.
}

procedure TgsMultilingualSupport.Loaded;
begin
  inherited Loaded;

  // Перехватываем событие
  if not (csDesigning in ComponentState) and (Owner is TForm) then
  begin
    OldOnShow := (Owner as TForm).OnShow;
    (Owner as TForm).OnShow := DoOnShow;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Создает список компонент к переводу.
}

procedure TgsMultilingualSupport.CreateTranslateList;

  // Проверяет наличие элемента в списке
  function IsInList(List: TList; Comp: TComponent): Boolean;
  var
    I: Integer;
  begin
    for I := 0 to List.Count - 1 do
      if List[I] = Comp then
      begin
        Result := True;
        Exit;
      end;

    Result := False;
  end;

  // Производит поиск необходимых компонентов
  procedure FindComponents(Comp: TComponent);
  var
    I, K: Integer;
  begin
    for I := 0 to Comp.ComponentCount - 1 do
    begin
      // Сравниваем классы, если они совпадают, то вносим их в список
      for K := 0 to TranslateClassCount - 1 do
        if
          (Comp.Components[I] is TranslateClassTypes[K])
            and not
          IsInList(FTranslateList, Comp.Components[I])
        then begin
          FTranslateList.Add(Comp.Components[I]);
          Break;
        end;

      FindComponents(Comp.Components[I]);
    end;
  end;
begin
  FTranslateList.Clear;
  FTranslateList.Add(Owner);
  FindComponents(Owner as TComponent);
end;

{
  Производит перевод.
}

procedure TgsMultilingualSupport.ProceedTranslation(const ShouldCreateList: Boolean = True);
var
  I, M: Integer;
  Old: Integer;
  Component: TComponent;
  TranslatedText: String;
  CurrCharSet: TFontCharSet;
  CharSetFound: Boolean;
  CurrContext: TTranslateContext;
  LGFile: TextFile;
  WriteToFile: Boolean;

//     - дата
//     - Форма
//     - Имя контрола
//     - прошлое значение
//     - перевод

begin
  // Создаем список компонент к переводу
  if ShouldCreateList then CreateTranslateList;

  // Получаем символьную таблицу
  CharSetFound := TranslateBase.FindCharSet(TranslateBase.TranslateToLang, CurrCharSet);

  CurrContext := nil;

  // Получаем контекст
  if not TranslateBase.FindContext(FContext, CurrContext) and not
    TranslateBase.FindContext(STR_DEFAULTCONTEXT, CurrContext)
  then // Если контексты не найдены ввобще, то выходим из метода
    Exit;

  if TranslateBase.DebugMode and (TranslateBase.LogFile <> '') then
  begin
    // Производим подсоединение и открытие файла
    {$I-}
    AssignFile(LGFile, TranslateBase.LogFile);

    // Если файла нет, то создаем его
    if FileExists(TranslateBase.LogFile) then
      Append(LGFile)
    else
      Rewrite(LGFile);

    WriteToFile := IOResult = 0;
    {$I+}
  end else
    WriteToFile := False;

  try
    if WriteToFile then
    begin
      Writeln(LGFile, '=============================');
      Writeln(LGFile, 'Language:' + FLanguage);
      Writeln(LGFile, 'TranslateLanguage:' + TranslateBase.Language);
      Writeln(LGFile, '');
      Writeln(LGFile, 'Form:' + (Owner as TComponent).Name);
      Writeln(LGFile, 'Date: ' + DateToStr(Date) + ' Time: ' + TimeToStr(Time));
    end;

    for I := 0 to FTranslateList.Count - 1 do
    begin
      Component := FTranslateList[I];

      if Component is TControl then
      begin
        if TranslateBase.TranslateText('', FContext, (Component as TControl).Hint, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TControl).Hint + '=' + TranslatedText);

          (Component as TControl).Hint := TranslatedText;
        end;
      end;


      if Component is TButton then
      begin
        if CharSetFound then
          (Component as TButton).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TButton).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TButton).Caption + '=' + TranslatedText);

          (Component as TButton).Caption := TranslatedText;
        end;
      end else

      if Component is TBitBtn then
      begin
        if CharSetFound then
          (Component as TBitBtn).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TBitBtn).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TBitBtn).Caption + '=' + TranslatedText);

          (Component as TBitBtn).Caption := TranslatedText;
        end;
      end else

      if Component is TmBitButton then
      begin
        if CharSetFound then
          (Component as TmBitButton).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TmBitButton).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TmBitButton).Caption + '=' + TranslatedText);

          (Component as TmBitButton).Caption := TranslatedText;
        end;
      end else

      if Component is TxBulbButton then
      begin
        if CharSetFound then
          (Component as TxBulbButton).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TxBulbButton).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TxBulbButton).Caption + '=' + TranslatedText);

          (Component as TxBulbButton).Caption := TranslatedText;
        end;
      end else

      if Component is TxYellowLabel then
      begin
        if CharSetFound then
          (Component as TxYellowLabel).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TxYellowLabel).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TxYellowLabel).Caption + '=' + TranslatedText);

          (Component as TxYellowLabel).Caption := TranslatedText;
        end;

        if TranslateBase.TranslateText('', FContext, (Component as TxYellowLabel).Lines.Text, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TxYellowLabel).Lines.Text + '=' + TranslatedText);

          (Component as TxYellowLabel).Lines.Text := TranslatedText;
        end;
      end else


      if Component is TStaticText then
      begin
        if CharSetFound then
          (Component as TStaticText).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TStaticText).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TStaticText).Caption + '=' + TranslatedText);

          (Component as TStaticText).Caption := TranslatedText;
        end;
      end else

      if Component is TLabel then
      begin
        if CharSetFound then
          (Component as TLabel).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TLabel).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TLabel).Caption + '=' + TranslatedText);

          (Component as TLabel).Caption := TranslatedText;
        end;
      end else

      if Component is TForm then
      begin
        if CharSetFound then
          (Component as TForm).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TForm).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TForm).Caption + '=' + TranslatedText);

          (Component as TForm).Caption := TranslatedText;
        end;
      end else

      if (Component is TmmTopPanel) and CharSetFound then
      begin
        (Component as TmmTopPanel).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TmmTopPanel).PartitionName, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TmmTopPanel).PartitionName + '=' + TranslatedText);

          (Component as TmmTopPanel).PartitionName := TranslatedText;
        end;

        if TranslateBase.TranslateText('', FContext, (Component as TmmTopPanel).ChapterName, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TmmTopPanel).ChapterName + '=' + TranslatedText);

          (Component as TmmTopPanel).ChapterName := TranslatedText;
        end;
      end else


      if Component is TmmStateMenu then
      begin
        if CharSetFound then
          (Component as TmmStateMenu).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TmmStateMenu).Prefix, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TmmStateMenu).Prefix + '=' + TranslatedText);

          (Component as TmmStateMenu).Prefix := TranslatedText;
        end;
      end else

      if (Component is TxColorTabSet) and CharSetFound then
      begin
        (Component as TxColorTabSet).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TxColorTabSet).Tabs, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TxColorTabSet).Tabs + '=' + TranslatedText);

          (Component as TxColorTabSet).Tabs := TranslatedText;
        end;
      end else

      if (Component is TPanel) and CharSetFound then
      begin
        (Component as TPanel).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TPanel).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TPanel).Caption + '=' + TranslatedText);

          (Component as TPanel).Caption := TranslatedText;
        end;
      end else

      if (Component is TEdit) and CharSetFound then
      begin
        (Component as TEdit).Font.Charset := CurrCharSet;
      end else

      if (Component is TDBEdit) and CharSetFound then
      begin
        (Component as TDBEdit).Font.Charset := CurrCharSet;
      end else

      if (Component is TStringGrid) and CharSetFound then
      begin
        (Component as TStringGrid).Font.Charset := CurrCharSet;
      end else

      if (Component is TDBGrid) and CharSetFound then
      begin
        (Component as TDBGrid).Font.Charset := CurrCharSet;
        (Component as TDBGrid).TitleFont.Charset := CurrCharSet;

        if Assigned((Component as TDBGrid).DataSource)
          and Assigned((Component as TDBGrid).DataSource.DataSet)
          and ((Component as TDBGrid).DataSource.DataSet.Active)
        then
          for M := 0 to (Component as TDBGrid).DataSource.DataSet.FieldCount - 1 do
            if TranslateBase.TranslateText('', FContext,
              (Component as TDBGrid).DataSource.DataSet.Fields[M].DisplayLabel, TranslatedText,
              CurrContext, TranslateFromLang) then
            begin
              if WriteToFile then
                Writeln(LGFile, Component.Name + ':' +
                  (Component as TDBGrid).DataSource.DataSet.Fields[M].DisplayLabel + '=' + TranslatedText);

              (Component as TDBGrid).DataSource.DataSet.Fields[M].DisplayLabel := TranslatedText;
            end;

        for M := 0 to (Component as TDBGrid).Columns.Count - 1 do
        begin
          (Component as TDBGrid).Columns[M].Font.Charset := CurrCharSet;
          (Component as TDBGrid).Columns[M].Title.Font.Charset := CurrCharSet;
        end;
      end else

      if (Component is TDataSet) and (Component as TDataSet).Active and CharSetFound then
      begin
        for M := 0 to (Component as TDataSet).FieldCount - 1 do
          if TranslateBase.TranslateText('', FContext,
            (Component as TDataSet).Fields[M].DisplayLabel, TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' +
                (Component as TDataSet).Fields[M].DisplayLabel + '=' + TranslatedText);

            (Component as TDataSet).Fields[M].DisplayLabel := TranslatedText;
          end;
      end else

      if (Component is TCustomListBox) and CharSetFound then
      begin
        if Component is TListBox then
          (Component as TListBox).Font.Charset := CurrCharSet
        else if Component is TCheckListBox then
          (Component as TCheckListBox).Font.Charset := CurrCharSet;

        for M := 0 to (Component as TCustomListBox).Items.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TCustomListBox).Items[M], TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TCustomListBox).Items[M] + '=' + TranslatedText);

            (Component as TCustomListBox).Items[M] := TranslatedText;
          end;
        end;
      end else

      if (Component is TComboBox) and CharSetFound then
      begin
        Old := (Component as TComboBox).ItemIndex;

        (Component as TComboBox).Font.Charset := CurrCharSet;

        for M := 0 to (Component as TComboBox).Items.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TComboBox).Items[M], TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TComboBox).Items[M] + '=' + TranslatedText);

            (Component as TComboBox).Items[M] := TranslatedText;
          end;
        end;

        (Component as TComboBox).ItemIndex := Old;
      end else

      if (Component is TMemo) and CharSetFound then
      begin
        (Component as TMemo).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TMemo).Lines.Text, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TMemo).Lines.Text + '=' + TranslatedText);

          (Component as TMemo).Lines.Text := TranslatedText;
        end;
      end else

      if (Component is TRadioGroup) and CharSetFound then
      begin
        (Component as TRadioGroup).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TRadioGroup).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TRadioGroup).Caption + '=' + TranslatedText);

          (Component as TRadioGroup).Caption := TranslatedText;
        end;

        for M := 0 to (Component as TRadioGroup).Items.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TRadioGroup).Items[M], TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TRadioGroup).Items[M] + '=' + TranslatedText);

            (Component as TRadioGroup).Items[M] := TranslatedText;
          end;
        end;
      end else

      if (Component is TmmRadioGroup) and CharSetFound then
      begin
        (Component as TmmRadioGroup).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TmmRadioGroup).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TmmRadioGroup).Caption + '=' + TranslatedText);

          (Component as TmmRadioGroup).Caption := TranslatedText;
        end;
      end else

      if (Component is TGroupBox) and CharSetFound then
      begin
        (Component as TGroupBox).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TGroupBox).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TGroupBox).Caption + '=' + TranslatedText);

          (Component as TGroupBox).Caption := TranslatedText;
        end;
      end else

      if (Component is TmTabSetVer) and CharSetFound then
      begin
        (Component as TmTabSetVer).Font.Charset := CurrCharSet;

        for M := 0 to (Component as TmTabSetVer).Tabs.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TmTabSetVer).Tabs[M], TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TmTabSetVer).Tabs[M] + '=' + TranslatedText);

            (Component as TmTabSetVer).Tabs[M] := TranslatedText;
          end;
        end;
      end else

      if (Component is TNoteBook) and CharSetFound then
      begin
        (Component as TNoteBook).Font.Charset := CurrCharSet;

        for M := 0 to (Component as TNoteBook).Pages.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TNoteBook).Pages[M], TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TNoteBook).Pages[M] + '=' + TranslatedText);

            (Component as TNoteBook).Pages[M] := TranslatedText;
          end;
        end;
      end else

      if (Component is TListView) and CharSetFound then
      begin
        (Component as TListView).Font.Charset := CurrCharSet;

        for M := 0 to (Component as TListView).Columns.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TListView).Columns[M].Caption, TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TListView).Columns[M].Caption + '=' + TranslatedText);

            (Component as TListView).Columns[M].Caption := TranslatedText;
          end;
        end;

        for M := 0 to (Component as TListView).Items.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TListView).Items[M].Caption, TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TListView).Items[M].Caption + '=' + TranslatedText);

            (Component as TListView).Items[M].Caption := TranslatedText;
          end;
        end;
      end else

      if (Component is TmTabSetHor) and CharSetFound then
      begin
        (Component as TmTabSetHor).Font.Charset := CurrCharSet;

        for M := 0 to (Component as TmTabSetHor).Tabs.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TmTabSetHor).Tabs[M], TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TmTabSetHor).Tabs[M] + '=' + TranslatedText);

            (Component as TmTabSetHor).Tabs[M] := TranslatedText;
          end;
        end;
      end else

      if (Component is TRadioButton) and CharSetFound then
      begin
        (Component as TRadioButton).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TRadioButton).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TRadioButton).Caption + '=' + TranslatedText);

          (Component as TRadioButton).Caption := TranslatedText;
        end;
      end else

      if Component is TCheckBox then
      begin
        if CharSetFound then
          (Component as TCheckBox).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TCheckBox).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TCheckBox).Caption + '=' + TranslatedText);

          (Component as TCheckBox).Caption := TranslatedText;
        end;
      end else

      if Component is TDBCheckBox then
      begin
        if CharSetFound then
          (Component as TDBCheckBox).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TDBCheckBox).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TDBCheckBox).Caption + '=' + TranslatedText);

          (Component as TDBCheckBox).Caption := TranslatedText;
        end;
      end else

      if (Component is TxDBLookupCombo) and CharSetFound then
      begin
        (Component as TxDBLookupCombo).Font.Charset := CurrCharSet;
      end else

      if (Component is TxDBLookupCombo2) and CharSetFound then
      begin
        (Component as TxDBLookupCombo2).Font.Charset := CurrCharSet;
      end else

      if (Component is TMenuItem) and CharSetFound then
      begin
        if TranslateBase.TranslateText('', FContext, (Component as TMenuItem).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TMenuItem).Caption + '=' + TranslatedText);

          (Component as TMenuItem).Caption := TranslatedText;
        end;

        if TranslateBase.TranslateText('', FContext, (Component as TMenuItem).Hint, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TMenuItem).Hint + '=' + TranslatedText);

          (Component as TMenuItem).Hint := TranslatedText;
        end;
      end else

      if (Component is TAction) and CharSetFound then
      begin
        if TranslateBase.TranslateText('', FContext, (Component as TAction).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TAction).Caption + '=' + TranslatedText);

          (Component as TAction).Caption := TranslatedText;
        end;

        if TranslateBase.TranslateText('', FContext, (Component as TAction).Hint, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TAction).Hint + '=' + TranslatedText);

          (Component as TAction).Hint := TranslatedText;
        end;
      end else

      if (Component is TxLegalPad) and CharSetFound then
      begin
        (Component as TxLegalPad).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TxLegalPad).Title, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TxLegalPad).Title + '=' + TranslatedText);

          (Component as TxLegalPad).Title := TranslatedText;
        end;

        for M := 0 to (Component as TxLegalPad).Items.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext,
            Copy((Component as TxLegalPad).Items[M], 1,
            Pos('|', (Component as TxLegalPad).Items[M])),
            TranslatedText, CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TxLegalPad).Items[M] + '=' + TranslatedText);

            (Component as TxLegalPad).Items[M] := TranslatedText +
              Copy((Component as TxLegalPad).Items[M],
              Pos('|', (Component as TxLegalPad).Items[M]) + 1,
              Length((Component as TxLegalPad).Items[M]) -
              Pos('|', (Component as TxLegalPad).Items[M]));
          end;
        end;

        for M := 0 to (Component as TxLegalPad).MarkLabel.Count - 1 do
        begin
          if TranslateBase.TranslateText('', FContext, (Component as TxLegalPad).MarkLabel[M], TranslatedText,
            CurrContext, TranslateFromLang) then
          begin
            if WriteToFile then
              Writeln(LGFile, Component.Name + ':' + (Component as TxLegalPad).MarkLabel[M] + '=' + TranslatedText);

            (Component as TxLegalPad).MarkLabel[M] := TranslatedText;
          end;
        end;

      end else

      if (Component is TSpeedButton) and CharSetFound then
      begin
        (Component as TSpeedButton).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TSpeedButton).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TSpeedButton).Caption + '=' + TranslatedText);

          (Component as TSpeedButton).Caption := TranslatedText;
        end;
      end else

      if (Component is TxHint) and CharSetFound then
      begin
        (Component as TxHint).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TxHint).MenuItemName, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TxHint).MenuItemName + '=' + TranslatedText);

          (Component as TxHint).MenuItemName := TranslatedText;
        end;
      end else

      if (Component is TColorComboBox) and CharSetFound then
      begin
        (Component as TColorComboBox).ColorButtonFont.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TColorComboBox).ColorButtonText, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TColorComboBox).ColorButtonText + '=' + TranslatedText);

          (Component as TColorComboBox).ColorButtonText := TranslatedText;
        end;
      end else

      if (Component is TTabSheet) and CharSetFound then
      begin
        (Component as TTabSheet).Font.Charset := CurrCharSet;

        if TranslateBase.TranslateText('', FContext, (Component as TTabSheet).Caption, TranslatedText,
          CurrContext, TranslateFromLang) then
        begin
          if WriteToFile then
            Writeln(LGFile, Component.Name + ':' + (Component as TTabSheet).Caption + '=' + TranslatedText);

          (Component as TTabSheet).Caption := TranslatedText;
        end;
      end;

    end;
  finally
    if WriteToFile then
    begin
      Writeln(LGFile, '=============================');
      {$I-}
      CloseFile(LGFile);
      {$I+}
    end;

    // Устанавливаем текущий язык
    FLanguage := TranslateBase.Language;
  end;
end;

{
  По появлению формы на экране производим перевод текста,
  если это необходимо.
}
procedure TgsMultilingualSupport.DoOnShow(Sender: TObject);
begin
  // Если изменился язык базовой компоненты, то необходимо изменить
  // язык в форме, в которой находится компонента поддержки языка
  if FEnabled and Assigned(TranslateBase) and (TranslateBase.Language <> Language) then
    ProceedTranslation;
end;

{
  Возвращает код языка, с которого должен производиться перевод.
}

function TgsMultilingualSupport.GetTranslateFromLang: Integer;
begin
  // Если код языка не найден, то делаем его нулевым
  if not TranslateBase.GetLangIndex(FLanguage, Result) then
    Result := -1;
end;

{
  Код языка, на который производим перевод.
}

function TgsMultilingualSupport.GetTranslateToLang: Integer;
begin
  if TranslateBase <> nil then
    Result := TranslateBase.TranslateToLang
  else
    Result := TranslateFromLang;  
end;

{
  Возвращает символьную таблицу, которая будет установлена при переводе
  текста.
}

function TgsMultilingualSupport.GetCharset: TFontCharset;
begin
  // Если не найден charset, то устанавливаем его по умолчанию
  if not TranslateBase.FindCharSet(TranslateFromLang, Result) then
    Result := DEFAULT_CHARSET;
end;

{
  Charset языка, на кторый будем переводить.
}

function TgsMultilingualSupport.GetTranslateToCharset: TFontCharset;
begin
  // Если не найден charset, то устанавливаем его по умолчанию
  if Assigned(TranslateBase) then
    Result := TranslateBase.Charset
  else
    Result := DEFAULT_CHARSET;
end;

{
  Возвращает Interbase Collation.
}

function TgsMultilingualSupport.GetIBCollation: String;
begin
  if not Assigned(TranslateBase) or
    not TranslateBase.FindIBCollation(TranslateToLang, Result)
  then
    Result := 'PXW_CYRL';
end;

initialization

  TranslateBase := nil;

end.

