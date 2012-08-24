{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynHighlighterMulti.pas, released 2000-06-23.
The Original Code is based on mwMultiSyn.pas by Willo van der Merwe, part of the
mwEdit component suite.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynHighlighterMulti.pas,v 1.10 2001/10/25 14:10:37 harmeister Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}
{
@abstract(Provides a Multiple-highlighter syntax highlighter for SynEdit)
@author(Willo van der Merwe <willo@wack.co.za>, converted to SynEdit by David Muir <dhm@dmsoftware.co.uk>)
@created(1999, converted to SynEdit 2000-06-23)
@lastmod(2000-06-23)
The SynHighlighterMulti unit provides SynEdit with a multiple-highlighter syntax highlighter.
This highlighter can be used to highlight text in which several languages are present, such as HTML.
For example, in HTML as well as HTML tags there can also be JavaScript and/or VBScript present.
}
unit SynHighlighterMulti;

{$I SynEdit.inc}

interface

uses
  Classes, SynEditTypes, SynEditHighlighter;                                    //LAD 2000-08-21

type
  TgmScheme = class(TCollectionItem)
  private
    FCaseSensitive: Boolean;                                                    //AC 2001-10-25
    FEndExpr: string;
    FStartExpr: string;
    FHighlighter: TSynCustomHighLighter;
    FMarkerAttri: TSynHighlighterAttributes;
    FSchemeName: TComponentName;
    function ConvertExpression(const Value: string): string;                    //AC 2001-10-25
    procedure SetMarkerAttri(const Value: TSynHighlighterAttributes);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;   //AC 2001-10-25
    property StartExpr: string read FStartExpr write FStartExpr;
    property EndExpr: string read FEndExpr write FEndExpr;
    property Highlighter: TSynCustomHighLighter read FHighlighter
      write FHighlighter;
    property MarkerAttri: TSynHighlighterAttributes read FMarkerAttri
      write SetMarkerAttri;
    property SchemeName: TComponentName read FSchemeName write FSchemeName;
  end;

  TgmSchemeClass = class of TgmScheme;

  TSynMultiSyn = class;

  TgmSchemes = class(TCollection)
  private
    fOwner: TSynMultiSyn;
    function GetItems(Index: integer): TgmScheme;
    procedure SetItems(Index: integer; const Value: TgmScheme);
{$IFDEF SYN_COMPILER_3_UP}
  protected
    function GetOwner: TPersistent; override;
{$ENDIF}
  public
    constructor Create(aOwner: TSynMultiSyn);
    property Items[Index: integer]: TgmScheme read GetItems write SetItems;
      default;
  end;

  TgmMarker = class
  protected
    fOwnerScheme: integer;
    fScheme: integer;
    fStartPos: integer;
    fMarkerLen: integer;
    fMarkerText: string;
    fIsOpenMarker: boolean;
  public
    constructor Create(aOwnerScheme, aScheme, aStartPos, aMarkerLen: integer;
      aIsOpenMarker: boolean; aMarkerText: string);
  end;

  TSynMultiSyn = class(TSynCustomHighLighter)
  protected
    fSchemes: TgmSchemes;
    fCurrScheme: integer;
    fLine: string;
    fLine_tmp1: string; //These Ref counts are getting me down :(
    fLine_tmp2: string; //These Ref counts are getting me down :(
    FDefault: TSynCustomHighLighter;
    fLineNumber: Integer;
    fRun, fLastRun: Integer;
    fMarkers: TList;
    fMarker: TgmMarker;

    procedure SetSchemes(const Value: TgmSchemes);
    procedure ClearMarkers;
    function FindMarker(MarkerPos, OwnerScheme: integer): TgmMarker;
    function FindNextMarker(MarkerPos, OwnerScheme: integer): TgmMarker;
    function GetIdentChars: TSynIdentChars; override;                           //LAD 2000-08-21
  protected    
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
  public
{$IFNDEF SYN_CPPB_1} class {$ENDIF}
    function GetLanguageName: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetToken: string; override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
    procedure SetLine(NewValue: string; LineNumber: Integer); override;
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
    property CurrScheme: integer read fCurrScheme write fCurrScheme;
  published
    property Schemes: TgmSchemes read fSchemes write SetSchemes;
    property DefaultHighlighter: TSynCustomHighLighter read FDefault
      write FDefault;
  end;

implementation

uses
  SynRegExpr, Graphics, SysUtils, SynEditStrConst;

function cmpMarker(Item1, Item2: Pointer): Integer;
begin
  if TgmMarker(Item1).fStartPos < TgmMarker(Item2).fStartPos then
    Result := -1
  else if TgmMarker(Item1).fStartPos > TgmMarker(Item2).fStartPos then
    Result := 1
  else
    Result := 0;
end;

function cmpMarkerPos(Item1: Pointer; Pos: integer): Integer;
begin
  if TgmMarker(Item1).fStartPos < Pos then
    Result := -1
  else if TgmMarker(Item1).fStartPos > Pos then
    Result := 1
  else
    Result := 0;
end;

{ TgmMarker }

constructor TgmMarker.Create(aOwnerScheme, aScheme, aStartPos,
  aMarkerLen: integer; aIsOpenMarker: boolean; aMarkerText: string);
begin
  fOwnerScheme := aOwnerScheme;
  fScheme := aScheme;
  fStartPos := aStartPos;
  fMarkerLen := aMarkerLen;
  fIsOpenMarker := aIsOpenMarker;
  fMarkerText := aMarkerText;
end;

{ TSynMultiSyn }

procedure TSynMultiSyn.ClearMarkers;
var
  i: integer;
begin
  for i := 0 to fMarkers.Count - 1 do
    TObject(fMarkers[i]).Free;
  fMarkers.Clear;
end;

constructor TSynMultiSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fSchemes := TgmSchemes.Create(Self);
  fCurrScheme := -1;
  fMarker := nil;
  fMarkers := TList.Create;
end;

destructor TSynMultiSyn.Destroy;
begin
  fSchemes.Free;
  ClearMarkers;
  fMarkers.Free;
  inherited Destroy;
end;

function TSynMultiSyn.FindMarker(MarkerPos, OwnerScheme: integer): TgmMarker;
var
  L, H, I, C: Integer;
begin
  Result := nil;
  L := 0;
  H := fMarkers.Count - 1;
  while L <= H do begin
    I := (L + H) shr 1;
    C := cmpMarkerPos(fMarkers[I], MarkerPos);
    if C < 0 then
      L := I + 1
    else begin
      H := I - 1;
      if (C = 0) then begin
        if fCurrScheme >= 0 then begin
          while ((I < fMarkers.Count) and
            (TgmMarker(fMarkers[I]).fOwnerScheme <> OwnerScheme) and
            (cmpMarkerPos(fMarkers[I], MarkerPos) = 0)) do
            inc(I);
          if (I < fMarkers.count) and
            (TgmMarker(fMarkers[I]).fOwnerScheme = OwnerScheme) then
            Result := fMarkers[I];
        end
        else if (I < fMarkers.count) and
          TgmMarker(fMarkers[I]).fIsOpenMarker then
          Result := fMarkers[I];
        break;
      end;
    end;
  end;
end;

function TSynMultiSyn.FindNextMarker(MarkerPos, OwnerScheme: integer): TgmMarker;
var
  L, H, I, C: Integer;
begin
  Result := nil;
  I := -1;
  L := 0;
  H := fMarkers.Count - 1;
  while L <= H do begin
    I := (L + H) shr 1;
    C := cmpMarkerPos(fMarkers[I], MarkerPos);
    if C < 0 then
      L := I + 1
    else begin
      H := I - 1;
      if C = 0 then
        break;
    end;
  end;
  if (I >= 0) then begin
    if (cmpMarkerPos(fMarkers[I], MarkerPos) < 0) then
      inc(I);
    while I < fMarkers.Count do
      if TgmMarker(fMarkers[I]).fIsOpenMarker or
        (TgmMarker(fMarkers[I]).fOwnerScheme = OwnerScheme) then begin
        Result := fMarkers[I];
        break;
      end else
        inc(I);
  end;
end;

function TSynMultiSyn.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
var
  HL: TSynCustomHighlighter;
begin
  if not Assigned(fDefault) then
    Result := nil
  else
  begin
    if (fCurrScheme >= 0) then
      HL := TgmScheme(fSchemes[fCurrScheme]).Highlighter
    else
      HL := fDefault;
    case Index of
      SYN_ATTR_COMMENT: Result := HL.CommentAttribute;
      SYN_ATTR_IDENTIFIER: Result := HL.IdentifierAttribute;
      SYN_ATTR_KEYWORD: Result := HL.KeywordAttribute;
      SYN_ATTR_STRING: Result := HL.StringAttribute;
      SYN_ATTR_SYMBOL: Result := HL.SymbolAttribute;
      SYN_ATTR_WHITESPACE: Result := HL.WhitespaceAttribute;
    else
      Result := nil;
    end;
  end;
end;

function TSynMultiSyn.GetEol: Boolean;
begin
  if assigned(fMarker) then
    Result := false
  else if (fCurrScheme >= 0) then
    Result := TgmScheme(fSchemes[fCurrScheme]).Highlighter.GetEol
  else if DefaultHighlighter <> nil then
    Result := DefaultHighlighter.GetEol
  else
    Result := true;
end;

{begin}                                                                         //LAD 2000-08-21
function TSynMultiSyn.GetIdentChars: TSynIdentChars;
begin
  Result := ['0'..'9', 'a'..'z', 'A'..'Z'] + TSynSpecialChars;
end;
{end}                                                                           //LAD 2000-08-21

{$IFNDEF SYN_CPPB_1} class {$ENDIF}
function TSynMultiSyn.GetLanguageName: string;
begin
  Result := SYNS_LangGeneralMulti;
end;

function TSynMultiSyn.GetRange: Pointer;
var
  lResult: longint;
begin
  if (fCurrScheme < 0) then
    if DefaultHighlighter <> nil then
      Result := DefaultHighlighter.GetRange
    else
      Result := nil
  else begin
    lResult := ((fCurrScheme + 1) shl 16) or
      (integer(fSchemes[fCurrScheme].Highlighter.GetRange) and $0000FFFF);
    Result := pointer(lResult);
  end;
end;

function TSynMultiSyn.GetToken: string;
begin
  if assigned(fMarker) then
    Result := fMarker.fMarkerText
  else if (fCurrScheme >= 0) then
    Result := fSchemes[fCurrScheme].Highlighter.GetToken
  else if DefaultHighlighter <> nil then
  begin
    if fLastRun >= 0 then
      Result := copy(DefaultHighlighter.GetToken, 1, fRun - fLastRun)
    else
      Result := DefaultHighlighter.GetToken;
  end
  else
    Result := fLine;
end;

function TSynMultiSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  if assigned(fMarker) then
    Result := Schemes[fMarker.fScheme].MarkerAttri
  else if (fCurrScheme >= 0) then
    Result := fSchemes[fCurrScheme].Highlighter.GetTokenAttribute
  else if DefaultHighlighter <> nil then
    Result := DefaultHighlighter.GetTokenAttribute
  else
    Result := nil;
end;

function TSynMultiSyn.GetTokenKind: integer;
begin
  if (fCurrScheme >= 0) then
    Result := fSchemes[fCurrScheme].Highlighter.GetTokenKind
  else if DefaultHighlighter <> nil then
    Result := DefaultHighlighter.GetTokenKind
  else
    Result := 0;
end;

function TSynMultiSyn.GetTokenPos: Integer;
begin
  if assigned(fMarker) then begin                                               //DDH 10/19/01 moved per Dmitri Dmitrienko's suggestion to remove an AV
    Result := fMarker.fStartPos - 1;
    exit;
  end;

  Result := 0;

  if (fCurrScheme >= 0) then
    Result := fRun + fSchemes[fCurrScheme].Highlighter.GetTokenPos -
      length(fSchemes[fCurrScheme].Highlighter.GetToken)
  else if DefaultHighlighter <> nil then
  begin
    if fLastRun >= 0 then
      Result := fLastRun + DefaultHighlighter.GetTokenPos
    else
      Result := fRun + DefaultHighlighter.GetTokenPos -
        length(DefaultHighlighter.GetToken);
  end;
end;

procedure TSynMultiSyn.Next;
var
  i, mx: integer;
  tok: string;
begin
  if DefaultHighlighter = nil then
    exit;

  fMarker := FindMarker(fRun + 1, fCurrScheme);
  if assigned(fMarker) then begin
    if (fMarker.fIsOpenMarker) then
      if fCurrScheme = -1 then
        fCurrScheme := fMarker.fScheme
      else
        fMarker := nil
    else
      fCurrScheme := -1;
    if assigned(fMarker) then begin
      inc(fRun, fMarker.fMarkerLen);
      exit;
    end;
  end;
  fMarker := FindNextMarker(fRun + 1, fCurrScheme);
  if assigned(fMarker) and
    not fMarker.fIsOpenMarker then
    mx := fMarker.fStartPos - 1
  else
    mx := length(fLine);

  if (fCurrScheme < 0) then begin
    fLine_tmp1 := copy(fLine, fRun + 1, mx - fRun);
    DefaultHighlighter.SetLine(fLine_tmp1, fLineNumber);
    tok := DefaultHighlighter.GetToken;
  end
  else begin
    fLine_tmp1 := copy(fLine, fRun + 1, mx - fRun);
    fSchemes[fCurrScheme].Highlighter.SetLine(fLine_tmp1, fLineNumber);
    tok := fSchemes[fCurrScheme].Highlighter.GetToken;
  end;
  fMarker := nil;
  for i := 1 to length(tok) do begin
    fMarker := FindMarker(fRun + i, fCurrScheme);
    if assigned(fMarker) then begin
      if (fMarker.fIsOpenMarker) then
        if fCurrScheme = -1 then
          {fCurrScheme := fMarker.fScheme}
        else
          fMarker := nil
      else
        fCurrScheme := -1;
      break;
    end;
  end;
  fLastRun := fRun;
  if assigned(fMarker) then
    inc(fRun, i - 1)
  else
    inc(fRun, length(tok));

  if assigned(fMarker) then begin
      if (fMarker.fIsOpenMarker) then
        {if fCurrScheme = -1 then
        begin
          fCurrScheme := fMarker.fScheme;
          fMarker := nil;
        end
        else}
          fMarker := nil
      else
        fCurrScheme := -1;
  end
  else
    fLastRun := -1;
end;

procedure TSynMultiSyn.ReSetRange;
begin
  fCurrScheme := -1;
end;

procedure TSynMultiSyn.SetLine(NewValue: string; LineNumber: Integer);
var
  i, j, k: integer;
  r: TRegExpr;
  tmp: string;
begin
  ClearMarkers;

  r := TRegExpr.Create;
  try
    for i := 0 to fSchemes.Count - 1 do begin
      r.Expression := fSchemes[i].ConvertExpression(fSchemes[i].StartExpr);     //AC 2001-10-25
      tmp := NewValue;
      k := 0;
      while tmp <> '' do
        if r.exec(fSchemes[i].ConvertExpression(tmp)) then                      //AC 2001-10-25
          for j := 0 to r.MatchCount - 1 do begin
            fMarkers.Add(TgmMarker.Create(i, i, r.MatchPos[j] + k, r.MatchLen[j],
              true, copy(tmp, r.MatchPos[j], r.MatchLen[j])));

            delete(tmp, 1, r.MatchPos[j] + r.MatchLen[j]);
            inc(k, r.MatchPos[j] + r.MatchLen[j]);
          end
        else
          tmp := ''
    end;
    for i := 0 to fSchemes.Count - 1 do begin
      r.Expression := fSchemes[i].ConvertExpression(fSchemes[i].EndExpr);       //AC 2001-10-25
      tmp := NewValue;
      k := 0;
      while tmp <> '' do
        if r.exec(fSchemes[i].ConvertExpression(tmp)) then                      //AC 2001-10-25
          for j := 0 to r.MatchCount - 1 do begin
            fMarkers.Add(TgmMarker.Create(i, i, r.MatchPos[j] + k, r.MatchLen[j],
              false, copy(tmp, r.MatchPos[j], r.MatchLen[j])));
            delete(tmp, 1, r.MatchPos[j] + r.MatchLen[j]);
            inc(k, r.MatchPos[j] + r.MatchLen[j]);
          end
        else
          tmp := ''
    end;
  finally
    r.Free;
  end;

  fMarkers.Sort(cmpMarker);

  // We have to check if Markers "overlap" to avoid drawing errors (blank characters!)
  for i := 0 to fMarkers.Count - 2 do begin
    with TgmMarker(fMarkers[i]) do
    begin
      // Allright, there is an open marker but the next marker is not a closing marker
      if fIsOpenMarker and (fOwnerScheme <> TgmMarker(fMarkers[i + 1]).fOwnerScheme) and
         (TgmMarker(fMarkers[i + 1]).fIsOpenMarker) then
      begin
        fMarkers.Insert(i, TgmMarker.Create(fOwnerScheme, fScheme, TgmMarker(fMarkers[i + 1]).fStartPos,
                0, false, ''));
      end
      // Hmm, we got two close markers, insert an open marker after first one
      else
      if (not fIsOpenMarker) and (not TgmMarker(fMarkers[i + 1]).fIsOpenMarker) and
         (fOwnerScheme <> TgmMarker(fMarkers[i + 1]).fOwnerScheme) then
      begin
        fMarkers.Insert(i, TgmMarker.Create(TgmMarker(fMarkers[i + 1]).fOwnerScheme,
                TgmMarker(fMarkers[i + 1]).fScheme, fStartPos + fMarkerLen, 0, true, ''));
      end;
    end;
  end;

{  tmp := '';
  if fMarkers.Count > 2 then
    for i := 0 to fMarkers.Count - 2 do begin
      with TgmMarker(fMarkers[i]) do
      begin
        tmp := tmp + fMarkerText + #13 + 'sp:'+inttostr(fstartpos) +#13+'len:'+inttostr(fmarkerlen)+#13;
        if fIsopenmarker then
          tmp := tmp + 'IsOpenMarker'
        else
          tmp := tmp +'Is not OpenMarker';
         tmp := tmp + '------';
      end;
    end;

  tmp := tmp + ';';}

  fLineNumber := LineNumber;
  fLine := NewValue;
  fMarker := nil;
  fRun := 0;
  Next;
end;

procedure TSynMultiSyn.SetRange(Value: Pointer);
begin
  fCurrScheme := (Integer(Value) shr 16) - 1;
  if DefaultHighlighter <> nil then begin
    if (fCurrScheme < 0) then
      DefaultHighlighter.SetRange(pointer(Integer(Value) and $0000FFFF))
    else
      fSchemes[fCurrScheme].Highlighter.SetRange(pointer(Integer(Value) and $0000FFFF));
  end;
end;

procedure TSynMultiSyn.SetSchemes(const Value: TgmSchemes);
begin
  fSchemes.Assign(Value);
end;

{ TgmSchemes }

constructor TgmSchemes.Create(aOwner: TSynMultiSyn);
begin
  inherited Create(TgmScheme);
  fOwner := aOwner;
end;

function TgmSchemes.GetItems(Index: integer): TgmScheme;
begin
  Result := inherited Items[Index] as TgmScheme;
end;

{$IFDEF SYN_COMPILER_3_UP}
function TgmSchemes.GetOwner: TPersistent;
begin
  Result := fOwner;
end;
{$ENDIF}

procedure TgmSchemes.SetItems(Index: integer; const Value: TgmScheme);
begin
  inherited Items[Index] := Value;
end;

{ TgmScheme }

constructor TgmScheme.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FCaseSensitive := True;
  FMarkerAttri := TSynHighlighterAttributes.Create(SYNS_AttrMarker);
{  with (FMarkerAttri) do begin                                                 //AC 2001-10-25
    Background := clYellow;
    Style := [fsBold];
  end;}
end;

destructor TgmScheme.Destroy;
begin
  FMarkerAttri.Free;
  inherited Destroy;
end;

function TgmScheme.ConvertExpression(const Value: String): String;              //AC 2001-10-25
begin
  if not FCaseSensitive then
    Result := AnsiUpperCase(Value)
  else
    Result := Value;
end; { ConvertExpression }

procedure TgmScheme.SetMarkerAttri(const Value: TSynHighlighterAttributes);
begin
  FMarkerAttri.Assign(Value);
end;

end.


