{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/
Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynHighlighterProlog.pas, the Initial
Author of this file is Zhou Kan.
All Rights Reserved.

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

$Id: SynHighlighterProlog.pas,v 1.00 2005/01/24 17:58:27 Kan Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}
{
@abstract(Provides a Prolog highlighter for SynEdit)
@author(Zhou Kan [textrush@tom.com])
@created(June 2004)
@lastmod(2005-01-24)
The SynHighlighterProlog unit provides SynEdit with a Prolog (*.pl;*.pro) highlighter.
The highlighter formats Prolog source code highlighting keywords, strings, numbers and characters.
}

unit SynHighlighterProlog;

{$I SynEdit.inc}

interface

uses
  SysUtils, Classes, Graphics, SynEditHighlighter, SynEditTypes, SynEditStrConst;

Type
  TtkTokenKind = (tkComment, tkDirective, tkIdentifier, tkKey,
    tkNull, tkNumber, tkSpace, tkString, tkSymbol, tkUnknown);

  TRangeState = (rsAnsiC, rsUnKnown);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function: TtkTokenKind of object;

type
  TSynPrologSyn = class(TSynCustomHighlighter)
  private
    fRange: TRangeState;
    fLine: PChar;
    fLineNumber: Integer;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fTokenPos: Integer;
    fTokenID: TtkTokenKind;
    fIdentFuncTable: array[0..332] of TIdentFuncTableFunc;
    fCommentAttri: TSynHighlighterAttributes;
    fDirectiveAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fNumberAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fSymbolAttri: TSynHighlighterAttributes;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: string): Boolean;
    function Func6: TtkTokenKind;
    function Func25: TtkTokenKind;
    function Func26: TtkTokenKind;
    function Func27: TtkTokenKind;
    function Func28: TtkTokenKind;
    function Func29: TtkTokenKind;
    function Func30: TtkTokenKind;
    function Func32: TtkTokenKind;
    function Func33: TtkTokenKind;
    function Func34: TtkTokenKind;
    function Func35: TtkTokenKind;
    function Func36: TtkTokenKind;
    function Func37: TtkTokenKind;
    function Func38: TtkTokenKind;
    function Func39: TtkTokenKind;
    function Func40: TtkTokenKind;
    function Func41: TtkTokenKind;
    function Func42: TtkTokenKind;
    function Func44: TtkTokenKind;
    function Func45: TtkTokenKind;
    function Func47: TtkTokenKind;
    function Func48: TtkTokenKind;
    function Func50: TtkTokenKind;
    function Func51: TtkTokenKind;
    function Func52: TtkTokenKind;
    function Func53: TtkTokenKind;
    function Func54: TtkTokenKind;
    function Func55: TtkTokenKind;
    function Func56: TtkTokenKind;
    function Func57: TtkTokenKind;
    function Func59: TtkTokenKind;
    function Func60: TtkTokenKind;
    function Func61: TtkTokenKind;
    function Func62: TtkTokenKind;
    function Func63: TtkTokenKind;
    function Func64: TtkTokenKind;
    function Func65: TtkTokenKind;
    function Func66: TtkTokenKind;
    function Func67: TtkTokenKind;
    function Func68: TtkTokenKind;
    function Func69: TtkTokenKind;
    function Func70: TtkTokenKind;
    function Func71: TtkTokenKind;
    function Func72: TtkTokenKind;
    function Func73: TtkTokenKind;
    function Func74: TtkTokenKind;
    function Func75: TtkTokenKind;
    function Func76: TtkTokenKind;
    function Func77: TtkTokenKind;
    function Func78: TtkTokenKind;
    function Func79: TtkTokenKind;
    function Func80: TtkTokenKind;
    function Func81: TtkTokenKind;
    function Func82: TtkTokenKind;
    function Func83: TtkTokenKind;
    function Func85: TtkTokenKind;
    function Func86: TtkTokenKind;
    function Func87: TtkTokenKind;
    function Func88: TtkTokenKind;
    function Func89: TtkTokenKind;
    function Func90: TtkTokenKind;
    function Func91: TtkTokenKind;
    function Func92: TtkTokenKind;
    function Func93: TtkTokenKind;
    function Func94: TtkTokenKind;
    function Func96: TtkTokenKind;
    function Func97: TtkTokenKind;
    function Func98: TtkTokenKind;
    function Func99: TtkTokenKind;
    function Func100: TtkTokenKind;
    function Func101: TtkTokenKind;
    function Func103: TtkTokenKind;
    function Func104: TtkTokenKind;
    function Func106: TtkTokenKind;
    function Func107: TtkTokenKind;
    function Func108: TtkTokenKind;
    function Func109: TtkTokenKind;
    function Func110: TtkTokenKind;
    function Func111: TtkTokenKind;
    function Func112: TtkTokenKind;
    function Func114: TtkTokenKind;
    function Func115: TtkTokenKind;
    function Func116: TtkTokenKind;
    function Func117: TtkTokenKind;
    function Func119: TtkTokenKind;
    function Func120: TtkTokenKind;
    function Func121: TtkTokenKind;
    function Func122: TtkTokenKind;
    function Func123: TtkTokenKind;
    function Func124: TtkTokenKind;
    function Func125: TtkTokenKind;
    function Func127: TtkTokenKind;
    function Func128: TtkTokenKind;
    function Func129: TtkTokenKind;
    function Func130: TtkTokenKind;
    function Func131: TtkTokenKind;
    function Func132: TtkTokenKind;
    function Func133: TtkTokenKind;
    function Func135: TtkTokenKind;
    function Func136: TtkTokenKind;
    function Func137: TtkTokenKind;
    function Func138: TtkTokenKind;
    function Func139: TtkTokenKind;
    function Func140: TtkTokenKind;
    function Func141: TtkTokenKind;
    function Func143: TtkTokenKind;
    function Func145: TtkTokenKind;
    function Func146: TtkTokenKind;
    function Func147: TtkTokenKind;
    function Func148: TtkTokenKind;
    function Func149: TtkTokenKind;
    function Func150: TtkTokenKind;
    function Func152: TtkTokenKind;
    function Func153: TtkTokenKind;
    function Func154: TtkTokenKind;
    function Func155: TtkTokenKind;
    function Func156: TtkTokenKind;
    function Func157: TtkTokenKind;
    function Func158: TtkTokenKind;
    function Func159: TtkTokenKind;
    function Func161: TtkTokenKind;
    function Func163: TtkTokenKind;
    function Func164: TtkTokenKind;
    function Func165: TtkTokenKind;
    function Func166: TtkTokenKind;
    function Func168: TtkTokenKind;
    function Func169: TtkTokenKind;
    function Func170: TtkTokenKind;
    function Func173: TtkTokenKind;
    function Func174: TtkTokenKind;
    function Func175: TtkTokenKind;
    function Func176: TtkTokenKind;
    function Func178: TtkTokenKind;
    function Func179: TtkTokenKind;
    function Func181: TtkTokenKind;
    function Func182: TtkTokenKind;
    function Func183: TtkTokenKind;
    function Func184: TtkTokenKind;
    function Func186: TtkTokenKind;
    function Func187: TtkTokenKind;
    function Func188: TtkTokenKind;
    function Func189: TtkTokenKind;
    function Func190: TtkTokenKind;
    function Func191: TtkTokenKind;
    function Func192: TtkTokenKind;
    function Func194: TtkTokenKind;
    function Func195: TtkTokenKind;
    function Func196: TtkTokenKind;
    function Func198: TtkTokenKind;
    function Func199: TtkTokenKind;
    function Func201: TtkTokenKind;
    function Func203: TtkTokenKind;
    function Func205: TtkTokenKind;
    function Func206: TtkTokenKind;
    function Func207: TtkTokenKind;
    function Func208: TtkTokenKind;
    function Func209: TtkTokenKind;
    function Func210: TtkTokenKind;
    function Func211: TtkTokenKind;
    function Func213: TtkTokenKind;
    function Func215: TtkTokenKind;
    function Func218: TtkTokenKind;
    function Func222: TtkTokenKind;
    function Func223: TtkTokenKind;
    function Func225: TtkTokenKind;
    function Func226: TtkTokenKind;
    function Func227: TtkTokenKind;
    function Func228: TtkTokenKind;
    function Func231: TtkTokenKind;
    function Func233: TtkTokenKind;
    function Func235: TtkTokenKind;
    function Func237: TtkTokenKind;
    function Func242: TtkTokenKind;
    function Func243: TtkTokenKind;
    function Func244: TtkTokenKind;
    function Func246: TtkTokenKind;
    function Func250: TtkTokenKind;
    function Func254: TtkTokenKind;
    function Func262: TtkTokenKind;
    function Func264: TtkTokenKind;
    function Func271: TtkTokenKind;
    function Func275: TtkTokenKind;
    function Func279: TtkTokenKind;
    function Func284: TtkTokenKind;
    function Func301: TtkTokenKind;
    function Func332: TtkTokenKind;
    procedure AndSymbolProc;
    procedure AsciiCharProc;
    procedure BackSlashProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure CRProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure DotProc;
    procedure EqualProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure InfoProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure ModSymbolProc;
    procedure NullProc;
    procedure OrSymbolProc;
    procedure PlusProc;
    procedure PointProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure SepcialString;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure StarProc;
    procedure StringProc;
    procedure TildeProc;
    procedure UnknownProc;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
    procedure AnsiCProc; //Kan    
  protected
    function GetIdentChars: TSynIdentChars; override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
      override;
    function GetEOL: Boolean; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber: Integer); override;
    function GetToken: String; override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
    function GetRange: Pointer; override;
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri write fCommentAttri;
    property DirectiveAttri: TSynHighlighterAttributes read fDirectiveAttri write fDirectiveAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TSynHighlighterAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TSynHighlighterAttributes read fSymbolAttri write fSymbolAttri;
  end;

implementation

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable : array[#0..#255] of Integer;

procedure MakeIdentTable;
var
  I: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
      else Identifiers[I] := False;
    end;
    Case I in ['_', 'A'..'Z', 'a'..'z'] of
      True:
        begin
          if (I > #64) and (I < #91) then 
            mHashTable[I] := Ord(I) - 64 
          else
            if (I > #96) then mHashTable[I] := Ord(I) - 95;
        end;
      else mHashTable[I] := 0;
    end;
  end;
end;

procedure TSynPrologSyn.InitIdent;
var
  I: Integer;
  pF: PIdentFuncTableFunc;
begin
  pF := PIdentFuncTableFunc(@fIdentFuncTable);
  for I := Low(fIdentFuncTable) to High(fIdentFuncTable) do 
  begin
    pF^ := AltFunc;
    Inc(pF);
  end;
  fIdentFuncTable[6] := Func6;
  fIdentFuncTable[25] := Func25;
  fIdentFuncTable[26] := Func26;
  fIdentFuncTable[27] := Func27;
  fIdentFuncTable[28] := Func28;
  fIdentFuncTable[29] := Func29;
  fIdentFuncTable[30] := Func30;
  fIdentFuncTable[32] := Func32;
  fIdentFuncTable[33] := Func33;
  fIdentFuncTable[34] := Func34;
  fIdentFuncTable[35] := Func35;
  fIdentFuncTable[36] := Func36;
  fIdentFuncTable[37] := Func37;
  fIdentFuncTable[38] := Func38;
  fIdentFuncTable[39] := Func39;
  fIdentFuncTable[40] := Func40;
  fIdentFuncTable[41] := Func41;
  fIdentFuncTable[42] := Func42;
  fIdentFuncTable[44] := Func44;
  fIdentFuncTable[45] := Func45;
  fIdentFuncTable[47] := Func47;
  fIdentFuncTable[48] := Func48;
  fIdentFuncTable[50] := Func50;
  fIdentFuncTable[51] := Func51;
  fIdentFuncTable[52] := Func52;
  fIdentFuncTable[53] := Func53;
  fIdentFuncTable[54] := Func54;
  fIdentFuncTable[55] := Func55;
  fIdentFuncTable[56] := Func56;
  fIdentFuncTable[57] := Func57;
  fIdentFuncTable[59] := Func59;
  fIdentFuncTable[60] := Func60;
  fIdentFuncTable[61] := Func61;
  fIdentFuncTable[62] := Func62;
  fIdentFuncTable[63] := Func63;
  fIdentFuncTable[64] := Func64;
  fIdentFuncTable[65] := Func65;
  fIdentFuncTable[66] := Func66;
  fIdentFuncTable[67] := Func67;
  fIdentFuncTable[68] := Func68;
  fIdentFuncTable[69] := Func69;
  fIdentFuncTable[70] := Func70;
  fIdentFuncTable[71] := Func71;
  fIdentFuncTable[72] := Func72;
  fIdentFuncTable[73] := Func73;
  fIdentFuncTable[74] := Func74;
  fIdentFuncTable[75] := Func75;
  fIdentFuncTable[76] := Func76;
  fIdentFuncTable[77] := Func77;
  fIdentFuncTable[78] := Func78;
  fIdentFuncTable[79] := Func79;
  fIdentFuncTable[80] := Func80;
  fIdentFuncTable[81] := Func81;
  fIdentFuncTable[82] := Func82;
  fIdentFuncTable[83] := Func83;
  fIdentFuncTable[85] := Func85;
  fIdentFuncTable[86] := Func86;
  fIdentFuncTable[87] := Func87;
  fIdentFuncTable[88] := Func88;
  fIdentFuncTable[89] := Func89;
  fIdentFuncTable[90] := Func90;
  fIdentFuncTable[91] := Func91;
  fIdentFuncTable[92] := Func92;
  fIdentFuncTable[93] := Func93;
  fIdentFuncTable[94] := Func94;
  fIdentFuncTable[96] := Func96;
  fIdentFuncTable[97] := Func97;
  fIdentFuncTable[98] := Func98;
  fIdentFuncTable[99] := Func99;
  fIdentFuncTable[100] := Func100;
  fIdentFuncTable[101] := Func101;
  fIdentFuncTable[103] := Func103;
  fIdentFuncTable[104] := Func104;
  fIdentFuncTable[106] := Func106;
  fIdentFuncTable[107] := Func107;
  fIdentFuncTable[108] := Func108;
  fIdentFuncTable[109] := Func109;
  fIdentFuncTable[110] := Func110;
  fIdentFuncTable[111] := Func111;
  fIdentFuncTable[112] := Func112;
  fIdentFuncTable[114] := Func114;
  fIdentFuncTable[115] := Func115;
  fIdentFuncTable[116] := Func116;
  fIdentFuncTable[117] := Func117;
  fIdentFuncTable[119] := Func119;
  fIdentFuncTable[120] := Func120;
  fIdentFuncTable[121] := Func121;
  fIdentFuncTable[122] := Func122;
  fIdentFuncTable[123] := Func123;
  fIdentFuncTable[124] := Func124;
  fIdentFuncTable[125] := Func125;
  fIdentFuncTable[127] := Func127;
  fIdentFuncTable[128] := Func128;
  fIdentFuncTable[129] := Func129;
  fIdentFuncTable[130] := Func130;
  fIdentFuncTable[131] := Func131;
  fIdentFuncTable[132] := Func132;
  fIdentFuncTable[133] := Func133;
  fIdentFuncTable[135] := Func135;
  fIdentFuncTable[136] := Func136;
  fIdentFuncTable[137] := Func137;
  fIdentFuncTable[138] := Func138;
  fIdentFuncTable[139] := Func139;
  fIdentFuncTable[140] := Func140;
  fIdentFuncTable[141] := Func141;
  fIdentFuncTable[143] := Func143;
  fIdentFuncTable[145] := Func145;
  fIdentFuncTable[146] := Func146;
  fIdentFuncTable[147] := Func147;
  fIdentFuncTable[148] := Func148;
  fIdentFuncTable[149] := Func149;
  fIdentFuncTable[150] := Func150;
  fIdentFuncTable[152] := Func152;
  fIdentFuncTable[153] := Func153;
  fIdentFuncTable[154] := Func154;
  fIdentFuncTable[155] := Func155;
  fIdentFuncTable[156] := Func156;
  fIdentFuncTable[157] := Func157;
  fIdentFuncTable[158] := Func158;
  fIdentFuncTable[159] := Func159;
  fIdentFuncTable[161] := Func161;
  fIdentFuncTable[163] := Func163;
  fIdentFuncTable[164] := Func164;
  fIdentFuncTable[165] := Func165;
  fIdentFuncTable[166] := Func166;
  fIdentFuncTable[168] := Func168;
  fIdentFuncTable[169] := Func169;
  fIdentFuncTable[170] := Func170;
  fIdentFuncTable[173] := Func173;
  fIdentFuncTable[174] := Func174;
  fIdentFuncTable[175] := Func175;
  fIdentFuncTable[176] := Func176;
  fIdentFuncTable[178] := Func178;
  fIdentFuncTable[179] := Func179;
  fIdentFuncTable[181] := Func181;
  fIdentFuncTable[182] := Func182;
  fIdentFuncTable[183] := Func183;
  fIdentFuncTable[184] := Func184;
  fIdentFuncTable[186] := Func186;
  fIdentFuncTable[187] := Func187;
  fIdentFuncTable[188] := Func188;
  fIdentFuncTable[189] := Func189;
  fIdentFuncTable[190] := Func190;
  fIdentFuncTable[191] := Func191;
  fIdentFuncTable[192] := Func192;
  fIdentFuncTable[194] := Func194;
  fIdentFuncTable[195] := Func195;
  fIdentFuncTable[196] := Func196;
  fIdentFuncTable[198] := Func198;
  fIdentFuncTable[199] := Func199;
  fIdentFuncTable[201] := Func201;
  fIdentFuncTable[203] := Func203;
  fIdentFuncTable[205] := Func205;
  fIdentFuncTable[206] := Func206;
  fIdentFuncTable[207] := Func207;
  fIdentFuncTable[208] := Func208;
  fIdentFuncTable[209] := Func209;
  fIdentFuncTable[210] := Func210;
  fIdentFuncTable[211] := Func211;
  fIdentFuncTable[213] := Func213;
  fIdentFuncTable[215] := Func215;
  fIdentFuncTable[218] := Func218;
  fIdentFuncTable[222] := Func222;
  fIdentFuncTable[223] := Func223;
  fIdentFuncTable[225] := Func225;
  fIdentFuncTable[226] := Func226;
  fIdentFuncTable[227] := Func227;
  fIdentFuncTable[228] := Func228;
  fIdentFuncTable[231] := Func231;
  fIdentFuncTable[233] := Func233;
  fIdentFuncTable[235] := Func235;
  fIdentFuncTable[237] := Func237;
  fIdentFuncTable[242] := Func242;
  fIdentFuncTable[243] := Func243;
  fIdentFuncTable[244] := Func244;
  fIdentFuncTable[246] := Func246;
  fIdentFuncTable[250] := Func250;
  fIdentFuncTable[254] := Func254;
  fIdentFuncTable[262] := Func262;
  fIdentFuncTable[264] := Func264;
  fIdentFuncTable[271] := Func271;
  fIdentFuncTable[275] := Func275;
  fIdentFuncTable[279] := Func279;
  fIdentFuncTable[284] := Func284;
  fIdentFuncTable[301] := Func301;
  fIdentFuncTable[332] := Func332;
end;

function TSynPrologSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    Inc(Result, mHashTable[ToHash^]);
    Inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end;

function TSynPrologSyn.KeyComp(const aKey: String): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if Temp^ <> aKey[i] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end 
  else Result := False;
end;

function TSynPrologSyn.Func6: TtkTokenKind;
begin
  if KeyComp('e') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func25: TtkTokenKind;
begin
  if KeyComp('abs') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func26: TtkTokenKind;
begin
  if KeyComp('tab') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func27: TtkTokenKind;
begin
  if KeyComp('pi') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func28: TtkTokenKind;
begin
  if KeyComp('nl') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func29: TtkTokenKind;
begin
  if KeyComp('arg') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func30: TtkTokenKind;
begin
  if KeyComp('flag') then Result := tkKey else
    if KeyComp('is') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func32: TtkTokenKind;
begin
  if KeyComp('see') then Result := tkKey else
    if KeyComp('call') then Result := tkKey else
      if KeyComp('read') then Result := tkKey else
        if KeyComp('fail') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func33: TtkTokenKind;
begin
  if KeyComp('ceil') then Result := tkDirective else
    if KeyComp('op') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func34: TtkTokenKind;
begin
  if KeyComp('make') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func35: TtkTokenKind;
begin
  if KeyComp('get0') then Result := tkKey else
    if KeyComp('mod') then Result := tkDirective else
      if KeyComp('get') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func36: TtkTokenKind;
begin
  if KeyComp('bagof') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func37: TtkTokenKind;
begin
  if KeyComp('log') then Result := tkDirective else
    if KeyComp('name') then Result := tkKey else
      if KeyComp('log10') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func38: TtkTokenKind;
begin
  if KeyComp('tan') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func39: TtkTokenKind;
begin
  if KeyComp('rem') then Result := tkDirective else
    if KeyComp('min') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func40: TtkTokenKind;
begin
  if KeyComp('catch') then Result := tkKey else
    if KeyComp('cos') then Result := tkDirective else
      if KeyComp('real') then Result := tkDirective else
        if KeyComp('atan') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func41: TtkTokenKind;
begin
  if KeyComp('max') then Result := tkDirective else
    if KeyComp('once') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func42: TtkTokenKind;
begin
  if KeyComp('edit') then Result := tkKey else
    if KeyComp('acos') then Result := tkDirective else
      if KeyComp('break') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func44: TtkTokenKind;
begin
  if KeyComp('var') then Result := tkKey else
    if KeyComp('debug') then Result := tkKey else
      if KeyComp('seek') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func45: TtkTokenKind;
begin
  if KeyComp('nth0') then Result := tkKey else
    if KeyComp('nth1') then Result := tkKey else
      if KeyComp('sin') then Result := tkDirective else
        if KeyComp('halt') then Result := tkKey else
          if KeyComp('help') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func47: TtkTokenKind;
begin
  if KeyComp('asin') then Result := tkDirective else
    if KeyComp('chdir') then Result := tkKey else
      if KeyComp('seen') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func48: TtkTokenKind;
begin
  if KeyComp('exp') then Result := tkDirective else
    if KeyComp('block') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func50: TtkTokenKind;
begin
  if KeyComp('succ') then Result := tkKey else
    if KeyComp('leash') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func51: TtkTokenKind;
begin
  if KeyComp('time') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func52: TtkTokenKind;
begin
  if KeyComp('trace') then Result := tkKey else
    if KeyComp('not') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func53: TtkTokenKind;
begin
  if KeyComp('tell') then Result := tkKey else
    if KeyComp('sign') then Result := tkDirective else
      if KeyComp('erase') then Result := tkKey else
        if KeyComp('atom') then Result := tkKey else
          if KeyComp('merge') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func54: TtkTokenKind;
begin
  if KeyComp('open') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func55: TtkTokenKind;
begin
  if KeyComp('told') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func56: TtkTokenKind;
begin
  if KeyComp('last') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func57: TtkTokenKind;
begin
  if KeyComp('delete') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func59: TtkTokenKind;
begin
  if KeyComp('close') then Result := tkKey else
    if KeyComp('float') then Result := tkDirective else
      if KeyComp('skip') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func60: TtkTokenKind;
begin
  if KeyComp('put') then Result := tkKey else
    if KeyComp('xor') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func61: TtkTokenKind;
begin
  if KeyComp('shell') then Result := tkKey else
    if KeyComp('abort') then Result := tkKey else
      if KeyComp('index') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func62: TtkTokenKind;
begin
  if KeyComp('append') then Result := tkKey else
    if KeyComp('sleep') then Result := tkKey else
      if KeyComp('exit') then Result := tkKey else
        if KeyComp('member') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func63: TtkTokenKind;
begin
  if KeyComp('spy') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func64: TtkTokenKind;
begin
  if KeyComp('please') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func65: TtkTokenKind;
begin
  if KeyComp('findall') then Result := tkKey else
    if KeyComp('char_code') then Result := tkKey else
      if KeyComp('seeing') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func66: TtkTokenKind;
begin
  if KeyComp('ceiling') then Result := tkDirective else
    if KeyComp('get_code') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func67: TtkTokenKind;
begin
  if KeyComp('clause') then Result := tkKey else
    if KeyComp('dde_poke') then Result := tkKey else
      if KeyComp('atomic') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func68: TtkTokenKind;
begin
  if KeyComp('at_halt') then Result := tkKey else
    if KeyComp('true') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func69: TtkTokenKind;
begin
  if KeyComp('get_char') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func70: TtkTokenKind;
begin
  if KeyComp('forall') then Result := tkKey else
    if KeyComp('setof') then Result := tkKey else
      if KeyComp('select') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func71: TtkTokenKind;
begin
  if KeyComp('repeat') then Result := tkKey else
    if KeyComp('random') then Result := tkDirective else
      if KeyComp('recorda') then Result := tkKey else
        if KeyComp('floor') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func72: TtkTokenKind;
begin
  if KeyComp('unix') then Result := tkKey else
    if KeyComp('peek_code') then Result := tkKey else
      if KeyComp('plus') then Result := tkKey else
        if KeyComp('length') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func73: TtkTokenKind;
begin
  if KeyComp('phrase') then Result := tkKey else
    if KeyComp('abolish') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func74: TtkTokenKind;
begin
  if KeyComp('ignore') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func75: TtkTokenKind;
begin
  if KeyComp('include') then Result := tkKey else
    if KeyComp('apply') then Result := tkKey else
      if KeyComp('peek_char') then Result := tkKey else
        if KeyComp('nodebug') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func76: TtkTokenKind;
begin
  if KeyComp('setarg') then Result := tkKey else
    if KeyComp('dynamic') then Result := tkKey else
      if KeyComp('sort') then Result := tkKey else
        if KeyComp('module') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func77: TtkTokenKind;
begin
  if KeyComp('is_set') then Result := tkKey else
    if KeyComp('round') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func78: TtkTokenKind;
begin
  if KeyComp('same_file') then Result := tkKey else
    if KeyComp('sqrt') then Result := tkDirective else
      if KeyComp('compare') then Result := tkKey else
        if KeyComp('union') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func79: TtkTokenKind;
begin
  if KeyComp('number') then Result := tkKey else
    if KeyComp('format') then Result := tkKey else
      if KeyComp('getenv') then Result := tkKey else
        if KeyComp('tracing') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func80: TtkTokenKind;
begin
  if KeyComp('write') then Result := tkKey else
    if KeyComp('recorded') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func81: TtkTokenKind;
begin
  if KeyComp('between') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func82: TtkTokenKind;
begin
  if KeyComp('threads') then Result := tkKey else
    if KeyComp('read_link') then Result := tkKey else
      if KeyComp('print') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func83: TtkTokenKind;
begin
  if KeyComp('notrace') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func85: TtkTokenKind;
begin
  if KeyComp('ground') then Result := tkKey else
    if KeyComp('integer') then Result := tkDirective else
      if KeyComp('debugging') then Result := tkKey else
        if KeyComp('flatten') then Result := tkKey else
          if KeyComp('visible') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func86: TtkTokenKind;
begin
  if KeyComp('telling') then Result := tkKey else
    if KeyComp('get_time') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func87: TtkTokenKind;
begin
  if KeyComp('writef') then Result := tkKey else
    if KeyComp('memberchk') then Result := tkKey else
      if KeyComp('time_file') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func88: TtkTokenKind;
begin
  if KeyComp('assert') then Result := tkKey else
    if KeyComp('profile') then Result := tkKey else
      if KeyComp('tmp_file') then Result := tkKey else
        if KeyComp('explain') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func89: TtkTokenKind;
begin
  if KeyComp('prolog') then Result := tkKey else
    if KeyComp('gensym') then Result := tkKey else
      if KeyComp('throw') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func90: TtkTokenKind;
begin
  if KeyComp('msort') then Result := tkKey else
    if KeyComp('nonvar') then Result := tkKey else
      if KeyComp('asserta') then Result := tkKey else
        if KeyComp('win_exec') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func91: TtkTokenKind;
begin
  if KeyComp('setenv') then Result := tkKey else
    if KeyComp('get_byte') then Result := tkKey else
      if KeyComp('put_code') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func92: TtkTokenKind;
begin
  if KeyComp('retract') then Result := tkKey else
    if KeyComp('access_file') then Result := tkKey else
      if KeyComp('read_term') then Result := tkKey else
        if KeyComp('load_files') then Result := tkKey else
          if KeyComp('subset') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func93: TtkTokenKind;
begin
  if KeyComp('delete_file') then Result := tkKey else
    if KeyComp('string') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func94: TtkTokenKind;
begin
  if KeyComp('cputime') then Result := tkDirective else
    if KeyComp('is_list') then Result := tkKey else
      if KeyComp('nospy') then Result := tkKey else
        if KeyComp('put_char') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func96: TtkTokenKind;
begin
  if KeyComp('recordz') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func97: TtkTokenKind;
begin
  if KeyComp('import') then Result := tkKey else
    if KeyComp('listing') then Result := tkKey else
      if KeyComp('peek_byte') then Result := tkKey else
        if KeyComp('maplist') then Result := tkKey else
          if KeyComp('autoload') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func98: TtkTokenKind;
begin
  if KeyComp('writeq') then Result := tkKey else
    if KeyComp('rename_file') then Result := tkKey else
      if KeyComp('qcompile') then Result := tkKey else
        if KeyComp('sub_atom') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func99: TtkTokenKind;
begin
  if KeyComp('size_file') then Result := tkKey else
    if KeyComp('reverse') then Result := tkKey else
      if KeyComp('checklist') then Result := tkKey else
        if KeyComp('on_signal') then Result := tkKey else
          if KeyComp('sformat') then Result := tkKey else
            if KeyComp('read_clause') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func100: TtkTokenKind;
begin
  if KeyComp('require') then Result := tkKey else
    if KeyComp('merge_set') then Result := tkKey else
      if KeyComp('hash_term') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func101: TtkTokenKind;
begin
  if KeyComp('code_type') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func103: TtkTokenKind;
begin
  if KeyComp('dwim_match') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func104: TtkTokenKind;
begin
  if KeyComp('export') then Result := tkKey else
    if KeyComp('prompt1') then Result := tkKey else
      if KeyComp('prompt') then Result := tkKey else
        if KeyComp('file_base_name') then Result := tkKey else
          if KeyComp('functor') then Result := tkKey else
            if KeyComp('char_type') then Result := tkKey else
              if KeyComp('volatile') then Result := tkKey else
                if KeyComp('atom_codes') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func106: TtkTokenKind;
begin
  if KeyComp('dde_execute') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func107: TtkTokenKind;
begin
  if KeyComp('atom_chars') then Result := tkKey else
    if KeyComp('apropos') then Result := tkKey else
      if KeyComp('compiling') then Result := tkKey else
        if KeyComp('swritef') then Result := tkKey else
          if KeyComp('profiler') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func108: TtkTokenKind;
begin
  if KeyComp('write_ln') then Result := tkKey else
    if KeyComp('thread_self') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func109: TtkTokenKind;
begin
  if KeyComp('sublist') then Result := tkKey else
    if KeyComp('compound') then Result := tkKey else
      if KeyComp('expand_goal') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func110: TtkTokenKind;
begin
  if KeyComp('truncate') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func111: TtkTokenKind;
begin
  if KeyComp('consult') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func112: TtkTokenKind;
begin
  if KeyComp('subtract') then Result := tkKey else
    if KeyComp('nth_clause') then Result := tkKey else
      if KeyComp('resource') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func114: TtkTokenKind;
begin
  if KeyComp('thread_join') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func115: TtkTokenKind;
begin
  if KeyComp('set_tty') then Result := tkKey else
    if KeyComp('atom_concat') then Result := tkKey else
      if KeyComp('assertz') then Result := tkKey else
        if KeyComp('concat_atom') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func116: TtkTokenKind;
begin
  if KeyComp('multifile') then Result := tkKey else
    if KeyComp('put_byte') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func117: TtkTokenKind;
begin
  if KeyComp('foreign_file') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func119: TtkTokenKind;
begin
  if KeyComp('unknown') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func120: TtkTokenKind;
begin
  if KeyComp('thread_create') then Result := tkKey else
    if KeyComp('retractall') then Result := tkKey else
      if KeyComp('keysort') then Result := tkKey else
        if KeyComp('exception') then Result := tkKey else
          if KeyComp('portray') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func121: TtkTokenKind;
begin
  if KeyComp('style_check') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func122: TtkTokenKind;
begin
  if KeyComp('line_count') then Result := tkKey else
    if KeyComp('nospyall') then Result := tkKey else
      if KeyComp('protocol') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func123: TtkTokenKind;
begin
  if KeyComp('source_file') then Result := tkKey else
    if KeyComp('copy_term') then Result := tkKey else
      if KeyComp('predsort') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func124: TtkTokenKind;
begin
  if KeyComp('protocola') then Result := tkKey else
    if KeyComp('use_module') then Result := tkKey else
      if KeyComp('thread_exit') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func125: TtkTokenKind;
begin
  if KeyComp('garbage_collect') then Result := tkKey else
    if KeyComp('atom_length') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func127: TtkTokenKind;
begin
  if KeyComp('limit_stack') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func128: TtkTokenKind;
begin
  if KeyComp('tty_put') then Result := tkKey else
    if KeyComp('unsetenv') then Result := tkKey else
      if KeyComp('dde_request') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func129: TtkTokenKind;
begin
  if KeyComp('tty_goto') then Result := tkKey else
    if KeyComp('set_stream') then Result := tkKey else
      if KeyComp('message_hook') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func130: TtkTokenKind;
begin
  if KeyComp('expand_term') then Result := tkKey else
    if KeyComp('thread_signal') then Result := tkKey else
      if KeyComp('number_codes') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func131: TtkTokenKind;
begin
  if KeyComp('prolog_edit') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func132: TtkTokenKind;
begin
  if KeyComp('set_input') then Result := tkKey else
    if KeyComp('wildcard_match') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func133: TtkTokenKind;
begin
  if KeyComp('interactor') then Result := tkKey else
    if KeyComp('mutex_lock') then Result := tkKey else
      if KeyComp('make_fat_filemap') then Result := tkKey else
        if KeyComp('number_chars') then Result := tkKey else
          if KeyComp('meta_predicate') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func135: TtkTokenKind;
begin
  if KeyComp('fileerrors') then Result := tkKey else
    if KeyComp('ensure_loaded') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func136: TtkTokenKind;
begin
  if KeyComp('free_variables') then Result := tkKey else
    if KeyComp('int_to_atom') then Result := tkKey else
      if KeyComp('current_flag') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func137: TtkTokenKind;
begin
  if KeyComp('atom_prefix') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func138: TtkTokenKind;
begin
  if KeyComp('sub_string') then Result := tkKey else
    if KeyComp('exists_file') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func139: TtkTokenKind;
begin
  if KeyComp('ttyflush') then Result := tkKey else
    if KeyComp('current_op') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func140: TtkTokenKind;
begin
  if KeyComp('write_term') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func141: TtkTokenKind;
begin
  if KeyComp('get_single_char') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func143: TtkTokenKind;
begin
  if KeyComp('expand_file_name') then Result := tkKey else
    if KeyComp('numbervars') then Result := tkKey else
      if KeyComp('trim_stacks') then Result := tkKey else
        if KeyComp('dwim_predicate') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func145: TtkTokenKind;
begin
  if KeyComp('file_search_path') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func146: TtkTokenKind;
begin
  if KeyComp('mutex_create') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func147: TtkTokenKind;
begin
  if KeyComp('thread_at_exit') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func148: TtkTokenKind;
begin
  if KeyComp('list_to_set') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func149: TtkTokenKind;
begin
  if KeyComp('attach_console') then Result := tkKey else
    if KeyComp('statistics') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func150: TtkTokenKind;
begin
  if KeyComp('atom_to_term') then Result := tkKey else
    if KeyComp('current_key') then Result := tkKey else
      if KeyComp('term_to_atom') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func152: TtkTokenKind;
begin
  if KeyComp('with_mutex') then Result := tkKey else
    if KeyComp('default_module') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func153: TtkTokenKind;
begin
  if KeyComp('noprotocol') then Result := tkKey else
    if KeyComp('read_history') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func154: TtkTokenKind;
begin
  if KeyComp('at_end_of_stream') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func155: TtkTokenKind;
begin
  if KeyComp('string_concat') then Result := tkKey else
    if KeyComp('convert_time') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func156: TtkTokenKind;
begin
  if KeyComp('rl_read_init_file') then Result := tkKey else
    if KeyComp('expand_answer') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func157: TtkTokenKind;
begin
  if KeyComp('show_profile') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func158: TtkTokenKind;
begin
  if KeyComp('print_message') then Result := tkKey else
    if KeyComp('proper_list') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func159: TtkTokenKind;
begin
  if KeyComp('current_atom') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func161: TtkTokenKind;
begin
  if KeyComp('expand_query') then Result := tkKey else
    if KeyComp('write_canonical') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func163: TtkTokenKind;
begin
  if KeyComp('intersection') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func164: TtkTokenKind;
begin
  if KeyComp('qsave_program') then Result := tkKey else
    if KeyComp('character_count') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func165: TtkTokenKind;
begin
  if KeyComp('goal_expansion') then Result := tkKey else
    if KeyComp('rl_add_history') then Result := tkKey else
      if KeyComp('stack_parameter') then Result := tkKey else
        if KeyComp('string_length') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func166: TtkTokenKind;
begin
  if KeyComp('set_prolog_flag') then Result := tkKey else
    if KeyComp('open_resource') then Result := tkKey else
      if KeyComp('profile_count') then Result := tkKey else
        if KeyComp('set_output') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func168: TtkTokenKind;
begin
  if KeyComp('current_thread') then Result := tkKey else
    if KeyComp('protocolling') then Result := tkKey else
      if KeyComp('export_list') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func169: TtkTokenKind;
begin
  if KeyComp('line_position') then Result := tkKey else
    if KeyComp('format_predicate') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func170: TtkTokenKind;
begin
  if KeyComp('mutex_unlock') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func173: TtkTokenKind;
begin
  if KeyComp('thread_get_message') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func174: TtkTokenKind;
begin
  if KeyComp('current_signal') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func175: TtkTokenKind;
begin
  if KeyComp('copy_stream_data') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func176: TtkTokenKind;
begin
  if KeyComp('absolute_file_name') then Result := tkKey else
    if KeyComp('open_shared_object') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func178: TtkTokenKind;
begin
  if KeyComp('char_conversion') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func179: TtkTokenKind;
begin
  if KeyComp('preprocessor') then Result := tkKey else
    if KeyComp('thread_peek_message') then Result := tkKey else
      if KeyComp('reset_profiler') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func181: TtkTokenKind;
begin
  if KeyComp('close_shared_object') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func182: TtkTokenKind;
begin
  if KeyComp('initialization') then Result := tkKey else
    if KeyComp('current_module') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func183: TtkTokenKind;
begin
  if KeyComp('string_to_atom') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func184: TtkTokenKind;
begin
  if KeyComp('source_location') then Result := tkKey else
    if KeyComp('thread_send_message') then Result := tkKey else
      if KeyComp('wait_for_input') then Result := tkKey else
        if KeyComp('context_module') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func186: TtkTokenKind;
begin
  if KeyComp('term_expansion') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func187: TtkTokenKind;
begin
  if KeyComp('portray_clause') then Result := tkKey else
    if KeyComp('make_library_index') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func188: TtkTokenKind;
begin
  if KeyComp('current_stream') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func189: TtkTokenKind;
begin
  if KeyComp('discontiguous') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func190: TtkTokenKind;
begin
  if KeyComp('flush_output') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func191: TtkTokenKind;
begin
  if KeyComp('current_input') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func192: TtkTokenKind;
begin
  if KeyComp('prolog_list_goal') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func194: TtkTokenKind;
begin
  if KeyComp('current_mutex') then Result := tkKey else
    if KeyComp('string_to_list') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func195: TtkTokenKind;
begin
  if KeyComp('prolog_file_type') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func196: TtkTokenKind;
begin
  if KeyComp('current_predicate') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func198: TtkTokenKind;
begin
  if KeyComp('mutex_unlock_all') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func199: TtkTokenKind;
begin
  if KeyComp('mutex_trylock') then Result := tkKey else
    if KeyComp('open_null_stream') then Result := tkKey else
      if KeyComp('file_directory_name') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func201: TtkTokenKind;
begin
  if KeyComp('mutex_destroy') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func203: TtkTokenKind;
begin
  if KeyComp('float_integer_part') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func205: TtkTokenKind;
begin
  if KeyComp('at_initialization') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func206: TtkTokenKind;
begin
  if KeyComp('is_absolute_file_name') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func207: TtkTokenKind;
begin
  if KeyComp('file_name_extension') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func208: TtkTokenKind;
begin
  if KeyComp('clause_property') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func209: TtkTokenKind;
begin
  if KeyComp('prolog_skip_level') then Result := tkKey else
    if KeyComp('load_foreign_library') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func210: TtkTokenKind;
begin
  if KeyComp('dde_current_service') then Result := tkKey else
    if KeyComp('current_functor') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func211: TtkTokenKind;
begin
  if KeyComp('tty_get_capability') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func213: TtkTokenKind;
begin
  if KeyComp('dde_register_service') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func215: TtkTokenKind;
begin
  if KeyComp('expand_file_search_path') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func218: TtkTokenKind;
begin
  if KeyComp('library_directory') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func222: TtkTokenKind;
begin
  if KeyComp('print_message_lines') then Result := tkKey else
    if KeyComp('call_with_depth_limit') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func223: TtkTokenKind;
begin
  if KeyComp('stream_property') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func225: TtkTokenKind;
begin
  if KeyComp('current_output') then Result := tkKey else
    if KeyComp('current_prolog_flag') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func226: TtkTokenKind;
begin
  if KeyComp('arithmetic_function') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func227: TtkTokenKind;
begin
  if KeyComp('float_fractional_part') then Result := tkDirective else Result := tkIdentifier;
end;

function TSynPrologSyn.Func228: TtkTokenKind;
begin
  if KeyComp('exists_directory') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func231: TtkTokenKind;
begin
  if KeyComp('predicate_property') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func233: TtkTokenKind;
begin
  if KeyComp('prolog_load_context') then Result := tkKey else
    if KeyComp('module_transparent') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func235: TtkTokenKind;
begin
  if KeyComp('prolog_to_os_filename') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func237: TtkTokenKind;
begin
  if KeyComp('open_dde_conversation') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func242: TtkTokenKind;
begin
  if KeyComp('close_dde_conversation') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func243: TtkTokenKind;
begin
  if KeyComp('prolog_current_frame') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func244: TtkTokenKind;
begin
  if KeyComp('dde_current_connection') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func246: TtkTokenKind;
begin
  if KeyComp('unload_foreign_library') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func250: TtkTokenKind;
begin
  if KeyComp('dde_unregister_service') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func254: TtkTokenKind;
begin
  if KeyComp('set_stream_position') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func262: TtkTokenKind;
begin
  if KeyComp('prolog_frame_attribute') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func264: TtkTokenKind;
begin
  if KeyComp('call_shared_object_function') then Result := tkKey else
    if KeyComp('unify_with_occurs_check') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func271: TtkTokenKind;
begin
  if KeyComp('redefine_system_predicate') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func275: TtkTokenKind;
begin
  if KeyComp('current_format_predicate') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func279: TtkTokenKind;
begin
  if KeyComp('current_foreign_library') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func284: TtkTokenKind;
begin
  if KeyComp('current_char_conversion') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func301: TtkTokenKind;
begin
  if KeyComp('prolog_trace_interception') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.Func332: TtkTokenKind;
begin
  if KeyComp('current_arithmetic_function') then Result := tkKey else Result := tkIdentifier;
end;

function TSynPrologSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TSynPrologSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 333 then 
    Result := fIdentFuncTable[HashKey] 
  else 
    Result := tkIdentifier;
end;

procedure TSynPrologSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '&': fProcTable[I] := AndSymbolProc;
      #39: fProcTable[I] := AsciiCharProc;
      '\': fProcTable[I] := BackSlashProc;
      '}': fProcTable[I] := BraceCloseProc;
      '{': fProcTable[I] := BraceOpenProc;
      #13: fProcTable[I] := CRProc;
      ':': fProcTable[I] := ColonProc;
      ',': fProcTable[I] := CommaProc;
      '`': fProcTable[I] := DotProc;
      '=': fProcTable[I] := EqualProc;
      '>': fProcTable[I] := GreaterProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
      '!': fProcTable[I] := InfoProc;
      #10: fProcTable[I] := LFProc;
      '<': fProcTable[I] := LowerProc;
      '-': fProcTable[I] := MinusProc;
      '%': fProcTable[I] := ModSymbolProc;
      #0: fProcTable[I] := NullProc;
      '|': fProcTable[I] := OrSymbolProc;
      '+': fProcTable[I] := PlusProc;
      '.': fProcTable[I] := PointProc;
      '(': fProcTable[I] := RoundOpenProc;
      ')': fProcTable[I] := RoundCloseProc;
      ';': fProcTable[I] := SemiColonProc;
      '/': fProcTable[I] := SlashProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      ']': fProcTable[I] := SquareCloseProc;
      '[': fProcTable[I] := SquareOpenProc;
      '*': fProcTable[I] := StarProc;
      #34: fProcTable[I] := StringProc;
      '$': fProcTable[I] := SepcialString;
      '~': fProcTable[I] := TildeProc;
      else fProcTable[I] := UnknownProc;
    end;
end;

constructor TSynPrologSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
  fCommentAttri := TSynHighLighterAttributes.Create(SYNS_AttrComment);
  fCommentAttri.Foreground := clGreen;
  AddAttribute(fCommentAttri);
  
  fDirectiveAttri := TSynHighLighterAttributes.Create(SYNS_AttrDirective);
  fDirectiveAttri.Foreground := $00C05000;
  AddAttribute(fDirectiveAttri);
  
  fIdentifierAttri := TSynHighLighterAttributes.Create(SYNS_AttrIdentifier);
  fIdentifierAttri.Foreground := clWindowText;
  AddAttribute(fIdentifierAttri);
  
  fKeyAttri := TSynHighLighterAttributes.Create(SYNS_AttrReservedWord);
  fKeyAttri.Foreground := clBlue;
  AddAttribute(fKeyAttri);
  
  fNumberAttri := TSynHighLighterAttributes.Create(SYNS_AttrNumber);
  fNumberAttri.Foreground := clPurple;
  AddAttribute(fNumberAttri);
  
  fSpaceAttri := TSynHighLighterAttributes.Create(SYNS_AttrWhiteSpace);
  AddAttribute(fSpaceAttri);
  
  fStringAttri := TSynHighLighterAttributes.Create(SYNS_AttrString);
  fStringAttri.Foreground := clMaroon;
  AddAttribute(fStringAttri);
  
  fSymbolAttri := TSynHighLighterAttributes.Create(SYNS_AttrSymbol);
  fSymbolAttri.Foreground := clNavy;
  AddAttribute(fSymbolAttri);
  
  SetAttributesOnChange(DefHighlightChange);
  InitIdent;
  MakeMethodTables;
end;

procedure TSynPrologSyn.SetLine(NewValue: string; LineNumber: Integer);
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end;

function TSynPrologSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

procedure TSynPrologSyn.ReSetRange;
begin
  fRange := rsUnknown;
end;

procedure TSynPrologSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

procedure TSynPrologSyn.AndSymbolProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.AsciiCharProc;
begin
  fTokenID := tkString;
  repeat
    case FLine[Run] of
      #0, #10, #13: Break;
    end;
    inc(Run);
  until FLine[Run] = #39;
  if FLine[Run] <> #0 then Inc(Run);
end;

procedure TSynPrologSyn.BackSlashProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.BraceCloseProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.BraceOpenProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: Inc(Run, 2);
  else Inc(Run);
  end;
end;

procedure TSynPrologSyn.ColonProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.CommaProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.DotProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.EqualProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.GreaterProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  Inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do Inc(Run);
end;

procedure TSynPrologSyn.InfoProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.LFProc;
begin
  fTokenID := tkSpace;
  Inc(Run);
end;

procedure TSynPrologSyn.LowerProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.MinusProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.ModSymbolProc;
begin
  Inc(Run);
  fTokenId := tkComment;
end;

procedure TSynPrologSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TSynPrologSyn.OrSymbolProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.PlusProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.PointProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.RoundCloseProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.RoundOpenProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.SemiColonProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.AnsiCProc; //Comment handle   //Kan
begin
  fTokenID := tkComment;
  case FLine[Run] of
    #0:
      begin
        NullProc;
        Exit;
      end;
    #10:
      begin
        LFProc;
        Exit;
      end;
    #13:
      begin
        CRProc;
        Exit;
      end;
  end;

  while FLine[Run] <> #0 do
    case FLine[Run] of
      '*':
        if fLine[Run + 1] = '/' then
        begin
          Inc(Run, 2);
          fRange := rsUnKnown;
          Break;
        end
        else 
          Inc(Run);
        #10: Break;
      #13: Break;
      else 
        Inc(Run);
    end;
end;

procedure TSynPrologSyn.SlashProc;
begin
  if FLine[Run + 1] = '*' then
  begin
    fTokenID := tkComment;
    fRange   := rsAnsiC;
    Inc(Run);
    while fLine[Run] <> #0 do
      case fLine[Run] of
        '*':
          if fLine[Run + 1] = '/' then
          begin
            Inc(Run, 2);
            fRange := rsUnknown;
            Break;
          end
          else 
            Inc(Run);
        #10: Break;
        #13: Break;
        else 
          Inc(Run);
      end;
  end
  else
  begin
    Inc(Run);
    fTokenID := tkSymbol;
  end;
end;

procedure TSynPrologSyn.SpaceProc;
begin
  Inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do
    Inc(Run);
end;

procedure TSynPrologSyn.SquareCloseProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.SquareOpenProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.StarProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.StringProc;
begin
  fTokenID := tkString;
  if (FLine[Run + 1] = #34) and (FLine[Run + 2] = #34) then
    Inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: Break;
      #92:
        if FLine[Run + 1] = #10 then Inc(Run);
    end;
    inc(Run);
  until FLine[Run] = #34;
  if FLine[Run] <> #0 then Inc(Run);
end;

procedure TSynPrologSyn.SepcialString;
begin
  fTokenID := tkString;
  repeat
    case FLine[Run] of
      #0, #10, #13: Break;
    end;
    Inc(Run);
  until FLine[Run] = '$';
  if FLine[Run] <> #0 then Inc(Run);
end;

procedure TSynPrologSyn.TildeProc;
begin
  Inc(Run);
  fTokenId := tkSymbol;
end;

procedure TSynPrologSyn.UnknownProc;
begin
  {$IFDEF SYN_MBCSSUPPORT}
  if FLine[Run] in LeadBytes then 
    Inc(Run, 2)
  else
  {$ENDIF}
    Inc(Run);
  fTokenID := tkUnknown;
end;

procedure TSynPrologSyn.Next;
begin
  fTokenPos := Run;
  case fRange of
    rsAnsiC: AnsiCProc;
    else
      begin
        fRange := rsUnknown;
        fProcTable[fLine[Run]];
      end;
  end;  
end;

function TSynPrologSyn.GetDefaultAttribute(Index: integer): TSynHighLighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT   : Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD   : Result := fKeyAttri;
    SYN_ATTR_STRING    : Result := fStringAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
    else Result := nil;
  end;
end;

function TSynPrologSyn.GetEOL: Boolean;
begin
  Result := fTokenID = tkNull;
end;

function TSynPrologSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TSynPrologSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TSynPrologSyn.GetTokenAttribute: TSynHighLighterAttributes;
begin
  case GetTokenID of
    tkComment: Result := fCommentAttri;
    tkDirective: Result := fDirectiveAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fIdentifierAttri;
    else Result := nil;
  end;
end;

function TSynPrologSyn.GetTokenKind: integer;
begin
  Result := Ord(fTokenId);
end;

function TSynPrologSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

function TSynPrologSyn.GetIdentChars: TSynIdentChars;
begin
  Result := ['_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

initialization
  MakeIdentTable;
  {$IFNDEF SYN_CPPB_1}  
  RegisterPlaceableHighlighter(TSynPrologSyn);
  {$ENDIF}  
end.
