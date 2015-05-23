{++

  Components for multilangual support.
  Copyright c) 1996 - 97 by Golden Software

  Module

    xWorld.pas

  Abstract

    Additions for creating multilangual applications and components.

  Author

    Vlasdimir Belyi (August, 1996)

  Contact address

    andreik@gs.minsk.by

  Uses

    Units:

    Forms:

    Other files:

  Revisions history

    1.00  26-Aug-1996  belyi  Initial pre-release version.
    1.01   1-Sep-1996  belyi  Initial version.
    1.02  13-Sep-1996  belyi  Icon added.
    1.03  16-mar-1997  belyi  Some new properties and functions.

  Known bugs
   
    -

  Wishes

    -

  Notes / comments

    -

--}

unit xWorld;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

const
  WM_LANGUAGECHANGE  = 4846; { This mesage is sent when language is changed.
                               Your component should just catch it and
                               react. }

type
  TPhrase = class
    Lang: Integer;
    Text: string;
    Rescue: string; { to have a chance of UNDO }
    Next: TPhrase;
  end;

type
  TSingleMessage = class
    ID: Integer;
    Phrase: TPhrase;
    Origin: string; { name of source component (if any) }
    Distinction: string; { string to distinguish different phrases (used for
                           the phrases being modified throgh TxWorld in
                           Component Designer and saved in .dfm file) }
    WasChanged: Boolean; { true if any translation have been modified in
                           Component Designer }
    Next: TSingleMessage;
    constructor Create;
    destructor Destroy; override;
  end;

type
  TPhrases = class
    List: TSingleMessage;
    FLanguage: Integer;
    LNames: TStringList;
    Origin: string;

  private
    function GetItem(ID: Integer): string;
    function GetCount: Integer;
    procedure SetLanguage(Value: Integer);
    function GetLanguagesCount: Integer;
    function GetLanguages(Index: Integer): string;
    function GetLanguageName: string;
    procedure SetLanguageName(Value: string);

  public
    constructor Create;
    destructor Destroy; override;
    function RegisterLanguage(Name: string): Integer;
    function RegisterRussian: Integer;
    function RegisterEnglish: Integer;
    function FindLanguage(Name: string): Integer;

    procedure SetOrigin(Name: string);
    procedure ClearOrigin;
    function GetPhraseOrigin(ID: Integer): string;
    function GetPhrase(ID: Integer; Lang: Integer): string;
    function GetRescuePhrase(ID: Integer; Lang: Integer): string;
    function FindID(ID: Integer): TSingleMessage;
    function FindPhraseID(Origin, Distinction: string): integer;
    function AddPhrase(Lang: Integer; S: string): Integer;
    procedure AddTranslation(ID: Integer; Lang: Integer; S: string);

    property LanguagesCount: Integer read GetLanguagesCount;
    property Languages[Index: Integer]: string read GetLanguages;
    property Language: Integer read FLanguage write SetLanguage;
    property LanguageName: string read GetLanguageName write SetLanguageName;
    property Items[ID: Integer]:string read GetItem; default;
    property Count: Integer read GetCount;
  end;

var
  Phrases: TPhrases;

type
  TxWorld = class(TComponent)
  private
    { Private declarations }
    FOnChange: TNotifyEvent;

    function GetLanguage: string;
    procedure SetLanguage(Value: string);
    function GetEditMessages: string;
    procedure SetEditMessages(Value: string);

  protected
    { Protected declarations }
    procedure Change; dynamic;
    procedure WMLanguageChange(var Message: TMessage);
      message WM_LANGUAGECHANGE;

    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadChanges(Reader: TReader);
    procedure WriteChanges(Writer: TWriter);
    procedure ReadLanguages(Reader: TReader);
    procedure WriteLanguages(Writer: TWriter);
    procedure ReadLanguage(Reader: TReader);
    procedure WriteLanguage(Writer: TWriter);

  public
    { Public declarations }

  published
    { Published declarations }
    property Language: string read GetLanguage write Setlanguage
      stored false;
    property EditMessages: string read GetEditMessages write SetEditMessages
      stored false;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

var { default languages (they are always registered) }
  lEnglish,
  lRussian : Integer;


type
  ELanguages = class(Exception);

implementation

uses
  xwo_edit;

{ ========= TSingleMessage ===========}
constructor TSingleMessage.Create;
begin
  inherited Create;
  Next := nil;
  ID := -1;
  Phrase := TPhrase.Create;
  Distinction := '';
  WasChanged := false;
end;

destructor TSingleMessage.Destroy;
var
  T, T1: TPhrase;
begin
  T := Phrase;
  while T <> nil do
    begin
      T1 := T.Next;
      T.Destroy;
      T := T1;
    end;
  inherited Destroy;
end;


{ ========= TPhrases ===========}
constructor TPhrases.Create;
begin
  inherited Create;
  List := TSingleMessage.Create;
  FLanguage := lEnglish;
  LNames := TStringList.Create;
end;

destructor TPhrases.Destroy;
var
  M, M1: TSingleMessage;
begin
  M := List;
  while M <> nil do
    begin
      M1 := M.Next;
      M.Destroy;
      M := M1;
    end;
  LNames.Destroy;
  inherited Destroy;
end;

function TPhrases.GetCount: Integer;
var
  M: TSingleMessage;
begin
  M := List;
  if M.ID <> -1 then
    while M.Next <> nil do M := M.Next;
  Result := M.ID + 1;
end;

function TPhrases.AddPhrase(Lang: Integer; S: string): Integer;
var
  M: TSingleMessage;
  LastID: Integer;
  i: Integer;
  Distinction: string;
begin
  M := List;
  LastID := -1;
  if M.ID <> -1 then
    begin
      while M.Next <> nil do
        M := M.Next;
      LastID := M.ID;
      M.Next := TSingleMessage.Create;
      M := M.Next;
    end;
  M.ID := LastID + 1;
  Result := M.ID;
  i := 0;
  repeat
    if i = 0 then
      Distinction := s
    else
      Distinction := s + IntToStr(i);
    inc(i);
  until FindPhraseID(Origin, Distinction) = -1;
  M.Distinction := Distinction;
  M.Phrase.Lang := Lang;
  M.Origin := Origin;
  M.Phrase.Text := s;
  M.Phrase.Rescue := s;
  M.Phrase.Next := nil;
end;

function TPhrases.FindID(ID: Integer): TSingleMessage;
var
  M: TSingleMessage;
begin
  M := List;
  While (M <> nil) and (M.ID <> ID) do M := M.Next;
  if M = nil then
    raise Elanguages.Create('Phrase ID not found');
  Result := M;
end;

function TPhrases.FindPhraseID(Origin, Distinction: string): integer;
var
  M: TSingleMessage;
begin
  M := List;
  While (M <> nil) and
        ((M.Origin <> Origin) or (M.Distinction <> Distinction)) do
    M := M.Next;
  if M = nil then
    Result := -1
  else
    Result := M.ID;
end;

procedure TPhrases.AddTranslation(ID: Integer; Lang: Integer; S: string);
var
  M: TSingleMessage;
  T: TPhrase;
begin
  M := FindID(ID);
  T := M.Phrase;
  while (T.Lang <> Lang) and (T.Next <> nil) do T := T.Next;
  if T.Lang <> Lang then
    begin
      T.Next := TPhrase.Create;
      T := T.Next;
      T.Lang := Lang;
      T.Rescue := s;
    end;
  T.Text := s;
end;

function TPhrases.GetItem(ID: Integer): string;
begin
  Result := GetPhrase(ID, Language);
end;

function TPhrases.GetPhraseOrigin(ID: Integer): string;
begin
  Result := FindID(ID).Origin;
end;

procedure TPhrases.SetOrigin(Name: string);
begin
  Origin := Name;
end;

procedure TPhrases.ClearOrigin;
begin
  Origin := '';
end;

procedure TPhrases.SetLanguage(Value: Integer);

  const
    Msg: TMessage = ( Msg:WM_LanguageChange );

  procedure Send(Comp: TComponent);
  var
    i: integer;
    AMsg: TMessage;
  begin
    for i := 0 to Comp.ComponentCount - 1 do
      Send( Comp.Components[i] );
    if Comp is TWinControl then
     begin
       AMsg := Msg;
       Comp.Dispatch(AMsg);
     end;
  end;

begin
  if (Value > LNames.Count - 1) or (Value < 0) then
    raise ELanguages.Create('Language ID out of bounds');
  if Value <> FLanguage then
    begin
      FLanguage := Value;
      Send( Application );
    end;
end;

function TPhrases.GetPhrase(ID: Integer; Lang: Integer): string;
var
  M: TSingleMessage;
  T: TPhrase;
begin
  M := FindID(ID);
  T := M.Phrase;
  while (T.Lang <> Lang) and (T.Next <> nil) do T := T.Next;
  if T.Lang <> Lang then
    Result := M.Phrase.Text
  else
    Result := T.Text;
end;

function TPhrases.GetRescuePhrase(ID: Integer; Lang: Integer): string;
var
  M: TSingleMessage;
  T: TPhrase;
begin
  M := FindID(ID);
  T := M.Phrase;
  While (T.Lang <> Lang) and (T.Next <> nil) do T := T.Next;
  if T.Lang <> Lang then
    Result := M.Phrase.Rescue
  else
    Result := T.rescue;
end;

function TPhrases.RegisterLanguage(Name: string): Integer;
begin
  Result := LNames.IndexOf(Name);
  if Result = -1 then
    Result := LNames.Add(Name);
end;

function TPhrases.FindLanguage(Name: string): Integer;
begin
  Result := LNames.IndexOf(Name);
end;

function TPhrases.RegisterRussian: Integer;
begin
  Result := RegisterLanguage('Russian');
end;

function TPhrases.RegisterEnglish: Integer;
begin
  Result := RegisterLanguage('English');
end;

function TPhrases.GetLanguagesCount: Integer;
begin
  Result := LNames.Count;
end; 

function TPhrases.GetLanguages(Index: Integer): string;
begin
  Result := LNames[Index];
end; 

function TPhrases.GetLanguageName: string;
begin
  Result := GetLanguages(Language);
end;

procedure TPhrases.SetLanguageName(Value: string);
begin
  SetLanguage(FindLanguage(Value));
end;

{ ========= TxWorld ========== }
function TxWorld.GetLanguage: string;
begin
  Result := Phrases.LNames[Phrases.Language];
end;

procedure TxWorld.SetLanguage(Value: string);
var
  i: Integer;
begin
  for i := 0 to Phrases.LNames.Count - 1 do
    if CompareText(Phrases.LNames[i], Value) = 0 then
      begin
        Phrases.Language := i;
        Change;
        exit;
      end;
end;

procedure TxWorld.Change;
begin
  if Assigned(FOnChange) then FOnChange(self);
end;

procedure TxWorld.WMLanguageChange(var Message: TMessage);
begin
  Change;
end;

function TxWorld.GetEditMessages: string;
begin
  Result := 'Double-click...';
end;

procedure TxWorld.SetEditMessages(Value: string);
begin
end;

procedure TxWorld.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('Languages', ReadLanguages, WriteLanguages, true);
  Filer.DefineProperty('Changes', ReadChanges, WriteChanges, true);
  Filer.DefineProperty('Language', ReadLanguage, WriteLanguage, true);
end;

procedure TxWorld.ReadChanges(Reader: TReader);
var
  Origin: string;
  Distinction: string;
  Lang, Text: string;
  ID: integer;
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do
    begin
      Origin := Reader.ReadString;
      Distinction := Reader.ReadString;
      ID := Phrases.FindPhraseID(Origin, Distinction);
      Reader.ReadListBegin;
      while not Reader.EndOfList do
        begin
          Lang := Reader.ReadString;
          Text := Reader.ReadString;
{          Rescue := Reader.ReadString;}
          if ID <> -1 then
            Phrases.AddTranslation(ID, Phrases.FindLanguage(Lang), Text);
        end;
      Reader.ReadListEnd;
    end;
  Reader.ReadListEnd;
end;

procedure TxWorld.WriteChanges(Writer: TWriter);
var
  i: integer;
  T: TPhrase;
begin
  Writer.WriteListBegin;
  for i := 0 to Phrases.Count - 1 do
    if Phrases.FindID(i).WasChanged then
      begin
        Writer.WriteString( Phrases.FindID(i).Origin );
        Writer.WriteString( Phrases.FindID(i).Distinction );
        Writer.WriteListBegin;
        T := Phrases.FindID(i).Phrase;
        repeat
          Writer.WriteString( Phrases.LNames[T.Lang] );
          Writer.WriteString( T.Text );
{          Writer.WriteString( T.Rescue );}
          T := T.Next;
        until T = nil;
        Writer.WriteListEnd;
      end;
  Writer.WriteListEnd;
end;

procedure TxWorld.ReadLanguages(Reader: TReader);
begin
  Reader.ReadListBegin;
  while not Reader.EndOfList do
    Phrases.RegisterLanguage( Reader.ReadString );
  Reader.ReadListEnd;
end;

procedure TxWorld.WriteLanguages(Writer: TWriter);
var
  i: integer;
begin
  Writer.WriteListBegin;
  for i := 0 to Phrases.LNames.Count - 1 do
    Writer.WriteString(Phrases.LNames[i]);
  Writer.WriteListEnd;
end;

procedure TxWorld.ReadLanguage(Reader: TReader);
begin
  Language := Reader.ReadString;
end;

procedure TxWorld.WriteLanguage(Writer: TWriter);
begin
  Writer.WriteString( Language );
end;



initialization
  Phrases := TPhrases.Create;
  lEnglish := Phrases.RegisterEnglish;
  lRussian := Phrases.RegisterRussian;

end.
