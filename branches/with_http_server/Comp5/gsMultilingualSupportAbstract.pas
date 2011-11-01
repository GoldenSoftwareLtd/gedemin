{
  ���������:

  ������: 1. ���������� �������� ���������� ISCollation � ������
  ������: 2. ����� ����� ���������� ��� �������� � ���� LofFile:
     - ����
     - �����
     - ��� ��������
     - ������� ��������
     - �������

  ������: 3. ����� ��� ��������������
  ������: 4. ������������ ���������� ��������� ������
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

unit gsMultilingualSupportAbstract;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExList;

type
  TTranslateContextAbstract = class
  private

  protected
    function GetArticleCount: Integer; virtual; abstract;
    function GetArticle(AnIndex: Integer): TStringList; virtual; abstract;

    function GetContext: String; virtual; abstract;
    procedure SetContext(const Value: String); virtual; abstract;

  public
    procedure SortContext(const LangIndex: Integer; Low, High: Integer); virtual; abstract;
    procedure AddArticle(AnArticle: TStringList); virtual; abstract;

    // ������������ ���������
    property Context: String read GetContext write SetContext;
    // ���������� ������ �� ���������
    property ArticleCount: Integer read GetArticleCount;
    // ������ �� �������
    property Article[Index: Integer]: TStringList read GetArticle; default;

  end;

type
  TgsMultilingualBaseAbstract = class(TComponent)
  private

  protected
    function GetLangIndex(const LangText: String; var LangIndex: Integer): Boolean; virtual; abstract;

    function GetContextCount: Integer; virtual; abstract;
    function GetTranslateContext(AnIndex: Integer): TTranslateContextAbstract; virtual; abstract;
    function GetTranslateToLang: Integer; virtual; abstract;
    function GetCurrentCharset: TFontCharset; virtual; abstract;
    function GetCharSetFile: TFileName; virtual; abstract;
    function GetDebugMode: Boolean; virtual; abstract;
    function GetEnabled: Boolean; virtual; abstract;
    procedure SetEnabled(const Value: Boolean); virtual; abstract;
    function GetLanguage: String; virtual; abstract;
    procedure SetLanguage(const Value: String); virtual; abstract;
    function GetLogFile: TFileName; virtual; abstract;
    function GetUseParams: Boolean; virtual; abstract;
    function GetVocFile: TFileName; virtual; abstract;

    procedure SetVocFile(const Value: TFileName); virtual; abstract;
    procedure SetCharSetFile(const Value: TFileName); virtual; abstract;
    procedure SetLogFile(const Value: TFileName); virtual; abstract;

    procedure SetUseParams(const Value: Boolean); virtual; abstract;
    procedure SetDebugMode(const Value: Boolean); virtual; abstract;


  public
    procedure LoadFiles; virtual; abstract;
    function FindContext(const ContextName: String; var Context: TTranslateContextAbstract): Boolean; virtual; abstract;

    function TranslateText(
      const FromLang, Context: String;
      Text: String;
      var Translation: String;
      const CustomContext: TTranslateContextAbstract = nil;
      const CustomFromLang: Integer = -1;
      const NoAmpersants: Boolean = False): Boolean; virtual; abstract;

    // ���-�� ����������
    property ContextCount: Integer read GetContextCount;
    // �������� �� �������
    property Vocabulary[Index: Integer]: TTranslateContextAbstract read GetTranslateContext;
    // ������ �����, �� ������� ���������� ���������� �������
    property TranslateToLang: Integer read GetTranslateToLang;
    // ���������� ������� ��������� �������
    property Charset: TFontCharset read GetCurrentCharset;

  published
    // �������� �� ���������� ��������
    property Enabled: Boolean read GetEnabled write SetEnabled;
    // ����, �� ������� ����� �������������� �������
    property Language: String read GetLanguage write SetLanguage;
    // ���� � ����� �������
    property VocFile: TFileName read GetVocFile write SetVocFile;
    // ���� � ����� charset-��
    property CharSetFile: TFileName read GetCharSetFile write SetCharSetFile;
    // ������������ �� ������ ���������� ��� ������ ����� ��������
    property UseParams: Boolean read GetUseParams write SetUseParams;
    // ���������� �� ������������ ����� � LogFile
    property DebugMode: Boolean read GetDebugMode write SetDebugMode;
    // ����, ���� ������������ �������
    property LogFile: TFileName read GetLogFile write SetLogFile;

  end;

type
  TgsMultilingualSupportAbstract = class(TComponent)
  private

  protected
    function GetTranslateFromLang: Integer; virtual; abstract;
    function GetTranslateToLang: Integer; virtual; abstract;
    function GetCharset: TFontCharset; virtual; abstract;
    function GetTranslateToCharset: TFontCharset; virtual; abstract;
    function GetIBCollation: String; virtual; abstract;
    function GetContext: String; virtual; abstract;
    procedure SetContext(const Value: String); virtual; abstract;
    procedure SetEnabled(const Value: Boolean); virtual; abstract;
    function GetEnabled: Boolean; virtual; abstract;
    function GetLanguage: String; virtual; abstract;
    procedure SetLanguage(const Value: String); virtual; abstract;

  public
    procedure Translate(const Lang: String); virtual; abstract;
    procedure ForceTranslate; virtual; abstract;
    procedure TranslateComponent(Component: TComponent; const Lang: String); virtual; abstract;
    function TranslateWord(const Text, Lang: String): String; virtual; abstract;

    // ������ �����, � �������� ���������� ���������� �������
    property TranslateFromLang: Integer read GetTranslateFromLang;
    // ����, �� ������� �� ���������
    property TranslateToLang: Integer read GetTranslateToLang;
    // ���������� ��������� �������, ������� ���������� ���������� ����� ��������
    property Charset: TFontCharset read GetCharset;
    // ���������� ������� �����, �� ������� ����� ����������
    property TranslateToCharset: TFontCharset read GetTranslateToCharset;
    // ���������� ��� ��������� ��� Interbase
    property IBCollation: String read GetIBCollation;

  published
    // ������� �� ����������
    property Enabled: Boolean read GetEnabled write SetEnabled;
    // ����, �� ������� �������� ������
    property Language: String read GetLanguage write SetLanguage;
    // �������� �����
    property Context: String read GetContext write SetContext;

  end;

//procedure Register;

var
  // ������ �� ����������, ���������� ��������
  // ��������� � ������ ��� ���������
  TranslateBase: TgsMultilingualBaseAbstract;

function TranslateText(S: String): String;
function GetCurrentLang: String;
function TranslatePChar(P: PChar; S: String): PChar;
function MessageBoxStr(Handle: hWnd; Text, Caption: String; Params: Integer): Integer;
function ChangeCollate(SQL: String; OldCollate, NewCollate: String): String;

implementation

// ���������� ������� ������
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

// ���������� ������� ����
function GetCurrentLang: String;
begin
  if TranslateBase <> nil then
    Result := TranslateBase.Language
  else
    Result := 'rus';
end;

// ��������� ������ � ������ � PChar
function TranslatePChar(P: PChar; S: String): PChar;
begin
  Result := StrPCopy(P, TranslateText(S));
end;

// ������ ������ PChar
function MessageBoxStr(Handle: hWnd; Text, Caption: String; Params: Integer): Integer;
var
  P: array[0..250] of char;
begin
  Result := Windows.MessageBox(
    Handle,
    StrPCopy(P, TranslateText(Text)),
    StrPCopy(P, TranslateText(Caption)), Params);
end;

// ������������� ����� IB Collate
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

// ���������� ����� ������� ����� � ������
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

end.

