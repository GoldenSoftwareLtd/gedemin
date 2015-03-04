{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10257: IdMessageCoderMIME.pas 
{
{   Rev 1.12    05/01/2005 17:22:28  CCostelloe
{ Randomised MIME boundary.
}
{
{   Rev 1.11    8/15/04 5:25:12 PM  RLebeau
{ Rewrote ReadHeader() to handle attachments similar to how Indy 10 does now
}
{
{   Rev 1.10    8/10/04 1:28:18 PM  RLebeau
{ Updated TIdMessageDecoderMIME to support multi-part form data
}
{
{   Rev 1.9    6/4/04 12:38:34 PM  RLebeau
{ ContentTransferEncoding bug fix
}
{
{   Rev 1.8    5/28/04 12:18:42 PM  RLebeau
{ Fix for compiler error
}
{
{   Rev 1.7    25/05/2004 13:57:12  CCostelloe
{ Bug fix
}
{
{   Rev 1.6    5/1/04 3:04:52 AM  RLebeau
{ Updated TIdMessageDecoderInfoMIME.CheckForStart() to return nil if no
{ boundary is specified in the message
}
{
{   Rev 1.5    2003.09.04 5:42:50 PM  czhower
{ Update to produce lower SpamAsassin scores.
}
{
    Rev 1.4    6/14/2003 10:40:36 AM  BGooijen
  fix for the bug where the attachments are empty
}
{
{   Rev 1.2    5/23/03 9:51:04 AM  RLebeau
{ Minor tweak to previous fix.
}
{
{   Rev 1.1    5/23/03 9:43:12 AM  RLebeau
{ Fixed bugs where message body is parsed incorrectly when MIMEBoundary is
{ empty.
}
{
{   Rev 1.0    2002.11.12 10:46:04 PM  czhower
}
unit IdMessageCoderMIME;

// for all 3 to 4s:
//// TODO: Predict output sizes and presize outputs, then use move on
// presized outputs when possible, or presize only and reposition if stream

interface

uses
  Classes,
  IdMessageCoder, IdMessage;

type
  TIdMessageDecoderMIME = class(TIdMessageDecoder)
  protected
    FFirstLine: string;
    FBodyEncoded: Boolean;
    FMIMEBoundary: string;
  public
    constructor Create(AOwner: TComponent); reintroduce; overload;
    constructor Create(AOwner: TComponent; ALine: string); reintroduce; overload;
    function ReadBody(ADestStream: TStream;
      var VMsgEnd: Boolean): TIdMessageDecoder; override;
    procedure ReadHeader; override;
    class procedure SetupBoundaries;
    class function GenerateRandomChar: Char;
    //
    property MIMEBoundary: string read FMIMEBoundary write FMIMEBoundary;
    property BodyEncoded: Boolean read FBodyEncoded write FBodyEncoded;
  end;

  TIdMessageDecoderInfoMIME = class(TIdMessageDecoderInfo)
  public
    function CheckForStart(ASender: TIdMessage; ALine: string): TIdMessageDecoder; override;
  end;

  TIdMessageEncoderMIME = class(TIdMessageEncoder)
  public
    procedure Encode(ASrc: TStream; ADest: TStream); override;
  end;

  TIdMessageEncoderInfoMIME = class(TIdMessageEncoderInfo)
  public
    constructor Create; override;
    procedure InitializeHeaders(AMsg: TIdMessage); override;
  end;

var
  IndyMIMEBoundary: string;
  IndyMultiPartAlternativeBoundary: string;
  IndyMultiPartRelatedBoundary: string;

const
  {IndyMIMEBoundary = '=_MoreStuf_2zzz1234sadvnqw3nerasdf'; {do not localize}
  {IndyMultiPartAlternativeBoundary = '=_MoreStuf_2altzzz1234sadvnqw3nerasdf'; {do not localize}
  {IndyMultiPartRelatedBoundary = '=_MoreStuf_2relzzzsadvnq1234w3nerasdf'; {do not localize}
  MIMEGenericText = 'text/'; {do not localize}
  MIMEGenericMultiPart = 'multipart/'; {do not localize}
  MIME7Bit = '7bit'; {do not localize}

implementation

uses
  IdCoder, IdCoderMIME, IdException, IdGlobal, IdResourceStrings, IdCoderQuotedPrintable,
  SysUtils, IdCoderHeader;

{ TIdMessageDecoderInfoMIME }

function TIdMessageDecoderInfoMIME.CheckForStart(ASender: TIdMessage;
 ALine: string): TIdMessageDecoder;
begin
  if (ASender.MIMEBoundary.Boundary <> '') and AnsiSameText(ALine, '--' + ASender.MIMEBoundary.Boundary) then begin    {Do not Localize}
    Result := TIdMessageDecoderMIME.Create(ASender);
  end else if AnsiSameText(ASender.ContentTransferEncoding, 'base64') or    {Do not Localize}
    AnsiSameText(ASender.ContentTransferEncoding, 'quoted-printable') then begin    {Do not Localize}
      Result := TIdMessageDecoderMIME.Create(ASender, ALine);
  end else begin
    Result := nil;
  end;
end;

{ TIdCoderMIME }

constructor TIdMessageDecoderMIME.Create(AOwner: TComponent);
begin
  inherited;
  FBodyEncoded := False;
  if AOwner is TIdMessage then begin
    FMIMEBoundary := TIdMessage(AOwner).MIMEBoundary.Boundary;
    if (TIdMessage(AOwner).ContentTransferEncoding <> '') and
      (not AnsiSameText(TIdMessage(AOwner).ContentTransferEncoding, '7bit')) and
      (not AnsiSameText(TIdMessage(AOwner).ContentTransferEncoding, '8bit')) and
      (not AnsiSameText(TIdMessage(AOwner).ContentTransferEncoding, 'binary')) then
    begin
      FBodyEncoded := True;
    end;
  end;
end;

constructor TIdMessageDecoderMIME.Create(AOwner: TComponent; ALine: string);
begin
  Create(AOwner);
  FFirstLine := ALine;
end;

class function TIdMessageDecoderMIME.GenerateRandomChar: Char;
var
  LOrd: integer;
  LFloat: Double;
begin
  {Allow only digits (ASCII 48-57), uppercase letters (65-90) and lowercase
  letters (97-122), which is 62 possible chars...}
  LFloat := (Random* 61) + 1.5;  //Gives us 1.5 to 62.5
  LOrd := Trunc(LFloat)+47;  //(1..62) -> (48..109)
  if LOrd > 83 then begin
    LOrd := LOrd + 13;  {Move into lowercase letter range}
  end else if LOrd > 57 then begin
    LOrd := LOrd + 7;  {Move into uppercase letter range}
  end;
  Result := Chr(LOrd);
end;

class procedure TIdMessageDecoderMIME.SetupBoundaries;
var
  LOrd: integer;
  LN: integer;
  LFloat: Double;
begin
  IndyMIMEBoundary := '1234567890123456789012345678901234';  {do not localize}
  Randomize;
  for LN := 1 to Length(IndyMIMEBoundary) do begin
    IndyMIMEBoundary[LN] := GenerateRandomChar;
  end;
  {CC2: RFC 2045 recommends including "=_" in the boundary, insert in random location...}
  LFloat := (Random * (Length(IndyMIMEBoundary)-2)) + 1.5;  //Gives us 1.5 to Length-0.5
  LN := Trunc(LFloat);  // 1 to Length-1 (we are inserting a 2-char string)
  IndyMIMEBoundary[LN] := '=';
  IndyMIMEBoundary[LN+1] := '_';
  {The Alternative boundary is the same with a random lowercase letter added...}
  LFloat := (Random* 25) + 1.5;  //Gives us 1.5 to 26.5
  LOrd := Trunc(LFloat)+96;  //(1..26) -> (97..122)
  IndyMultiPartAlternativeBoundary := Chr(LOrd) + IndyMIMEBoundary;
  {The Related boundary is the same with a random uppercase letter added...}
  LFloat := (Random* 25) + 1.5;  //Gives us 1.5 to 26.5
  LOrd := Trunc(LFloat)+64;  //(1..26) -> (65..90)
  IndyMultiPartRelatedBoundary := Chr(LOrd) + IndyMultiPartAlternativeBoundary;
end;

function TIdMessageDecoderMIME.ReadBody(ADestStream: TStream; var VMsgEnd: Boolean): TIdMessageDecoder;
var
  s: string;
  LDecoder: TIdDecoder;
  LLine: string;
begin
  VMsgEnd := False;
  Result := nil;
  if FBodyEncoded then begin
    s := TIdMessage(Owner).ContentTransferEncoding;
  end else begin
    s := FHeaders.Values['Content-Transfer-Encoding']; {Do not Localize}
  end;
  if AnsiSameText(s, 'base64') then begin {Do not Localize}
    LDecoder := TIdDecoderMIME.Create(nil);
  end else if AnsiSameText(s, 'quoted-printable') then begin {Do not Localize}
    LDecoder := TIdDecoderQuotedPrintable.Create(nil);
  end else begin
    LDecoder := nil;
  end;
  try
    repeat
      if FFirstLine = '' then begin // TODO: Improve this. Not very efficient
        LLine := ReadLn;
      end else begin
        LLine := FFirstLine;
        FFirstLine := '';    {Do not Localize}
      end;
      if LLine = '.' then begin // Do not use ADELIM since always ends with . (standard) {Do not Localize}
        VMsgEnd := True;
        Break;
      end;
      // New boundary - end self and create new coder
      if MIMEBoundary <> '' then begin
        if AnsiSameText(LLine, '--' + MIMEBoundary) then begin    {Do not Localize}
          Result := TIdMessageDecoderMIME.Create(Owner);
          Exit;
        end;
        if AnsiSameText(LLine, '--' + MIMEBoundary + '--') then begin    {Do not Localize}
          // POP the boundary
          if Owner is TIdMessage then begin
            TIdMessage(Owner).MIMEBoundary.Pop;
          end;
          Exit;
        end;
      end;
      if LDecoder = nil then begin
        if (Length(LLine) > 0) and (LLine[1] = '.') then begin // Process . in front for no encoding    {Do not Localize}
          Delete(LLine, 1, 1);
        end;
        LLine := LLine + EOL;
        ADestStream.WriteBuffer(LLine[1], Length(LLine));
      end else begin
        //for TIdDecoderQuotedPrintable, we have
        //to make sure all EOLs are intact
        if LDecoder is TIdDecoderQuotedPrintable then begin
          LDecoder.DecodeToStream(LLine+EOL, ADestStream);
        end else if LLine <> '' then begin
          LDecoder.DecodeToStream(LLine, ADestStream);
        end;
      end;
    until False;
  finally
    FreeAndNil(LDecoder);
  end;
end;

procedure TIdMessageDecoderMIME.ReadHeader;
var
  ABoundary,
  s: string;
  LLine: string;

  function GetAttachmentFilename(AContentType, AContentDisposition: string): string;
  var
    LValue: string;
    LPos: Cardinal;
  begin
    LPos := IndyPos('FILENAME=', UpperCase(AContentDisposition));  {Do not Localize}
    if LPos > 0 then begin
      LValue := Trim(Copy(AContentDisposition, LPos + 9, MaxInt));
    end else begin
      LValue := ''; //FileName not found
    end;
    if Length(LValue) = 0 then begin
      // Get filename from Content-Type
      LPos := IndyPos('NAME=', UpperCase(AContentType)); {Do not Localize}
      if LPos > 0 then begin
        LValue := Trim(Copy(AContentType, LPos + 5, MaxInt));    {Do not Localize}
      end;
    end;
    if Length(LValue) > 0 then begin
      if LValue[1] = '"' then begin        {Do not Localize}
        // RLebeau - shouldn't this code use AnsiExtractQuotedStr() instead?
        Fetch(LValue, '"');                {Do not Localize}
        Result := Fetch(LValue, '"');      {Do not Localize}
      end else begin
        // RLebeau - just in case the name is not the last field in the line
        Result := Fetch(LValue, ';');      {Do not Localize}
      end;
      Result := DecodeHeader(Result);
    end else begin
      Result := '';
    end;
  end;

  procedure CheckAndSetType(AContentType, AContentDisposition: string);
  var
    LDisposition, LFileName: string;
  begin
    LDisposition := Fetch(AContentDisposition, ';');            {Do not Localize}

    {The new world order: Indy now defines a TIdAttachment as a part that either has
    a filename, or else does NOT have a ContentType starting with text/ or multipart/.
    Anything left is a TIdText.}

    //WARNING: Attachments may not necessarily have filenames!
    LFileName := GetAttachmentFileName(AContentType, AContentDisposition);

    // Content-Disposition: inline; - Even this we treat as attachment. It
    // can easily contain binary data which text part is not suited for.
    if AnsiSameText(LDisposition, 'attachment') or (Length(LFileName) > 0) then {Do not Localize}
    begin
      FPartType := mcptAttachment;
      FFilename := LFileName;
    end else begin
      {No filename is specified, so see what type the part is...}
      if AnsiSameText(Copy(AContentType, 1, 5), MIMEGenericText) or           
        AnsiSameText(Copy(AContentType, 1, 10), MIMEGenericMultiPart) then
      begin
        FPartType := mcptText;
      end else begin
        FPartType := mcptAttachment;
      end;
    end;
  end;

begin
  if FBodyEncoded then begin // Read header from the actual message since body parts don't exist    {Do not Localize}
    CheckAndSetType(TIdMessage(Owner).ContentType, TIdMessage(OWner).ContentDisposition);
  end else begin
    // Read header
    repeat
      LLine := ReadLn;
      if LLine = '.' then begin // TODO: abnormal situation (Masters!)    {Do not Localize}
        FPartType := mcptUnknown;
        Exit;
      end;//if
      if LLine = '' then begin
        Break;
      end;
      if LLine[1] in LWS then begin
        if FHeaders.Count > 0 then begin
          FHeaders[FHeaders.Count - 1] := FHeaders[FHeaders.Count - 1] + ' ' + Copy(LLine, 2, MaxInt);    {Do not Localize}
        end else begin
          FHeaders.Add(StringReplace(Copy(LLine, 2, MaxInt), ': ', '=', [])); {Do not Localize}
        end;
      end else begin
        FHeaders.Add(StringReplace(LLine, ': ', '=', []));    {Do not Localize}
      end;
    until False;
    s := FHeaders.Values['Content-Type'];    {Do not Localize}
    ABoundary := TIdMIMEBoundary.FindBoundary(s);
    if Length(ABoundary) > 0 then begin
      if Owner is TIdMessage then begin
        TIdMessage(Owner).MIMEBoundary.Push(ABoundary);
        // Also update current boundary
        FMIMEBoundary := ABoundary;
      end;
    end;
    CheckAndSetType(FHeaders.Values['Content-Type'],    {Do not Localize}
      FHeaders.Values['Content-Disposition']);    {Do not Localize}
  end;
end;

{ TIdMessageEncoderInfoMIME }

constructor TIdMessageEncoderInfoMIME.Create;
begin
  inherited;
  FMessageEncoderClass := TIdMessageEncoderMIME;
end;

procedure TIdMessageEncoderInfoMIME.InitializeHeaders(AMsg: TIdMessage);
begin
  if AMsg.MessageParts.RelatedPartCount > 0 then begin
    AMsg.ContentType := 'multipart/related; type="multipart/alternative"; boundary="' + {do not localize}
     IndyMultiPartRelatedBoundary + '"';    {Do not Localize}
  end else begin
    if AMsg.MessageParts.AttachmentCount > 0 then begin
      AMsg.ContentType := 'multipart/mixed; boundary="' {do not localize}
       + IndyMIMEBoundary + '"';    {Do not Localize}
    end else begin
      if AMsg.MessageParts.TextPartCount > 0 then begin
        AMsg.ContentType :=
         'multipart/alternative; boundary="' {do not localize}
         + IndyMIMEBoundary + '"';    {Do not Localize}
      end;
    end;
  end;
end;

{ TIdMessageEncoderMIME }

procedure TIdMessageEncoderMIME.Encode(ASrc, ADest: TStream);
var
  s: string;
  LEncoder: TIdEncoderMIME;
  LSPos, LSSize : Int64;
begin
  ASrc.Position := 0;
  LSPos := 0;
  LSSize := ASrc.Size;
  LEncoder := TIdEncoderMIME.Create(nil); try
    while LSPos < LSSize do begin
      s := LEncoder.Encode(ASrc, 57) + EOL;
      Inc(LSPos,57);
      ADest.WriteBuffer(s[1], Length(s));
    end;
  finally FreeAndNil(LEncoder); end;
end;

initialization
  TIdMessageDecoderList.RegisterDecoder('MIME',    {Do not Localize}
    TIdMessageDecoderInfoMIME.Create);
  TIdMessageEncoderList.RegisterEncoder('MIME',    {Do not Localize}
    TIdMessageEncoderInfoMIME.Create);
  TIdMessageDecoderMIME.SetupBoundaries;
end.
