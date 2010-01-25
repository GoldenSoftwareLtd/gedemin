
{++

  Copyright (c) 1996-98 by Golden Software

  Module name

    xtable.pas

  Abstract

    Delphi non-visual component.

  Author

    Michael Shoihet (21-Dec-96)

  Contact address

    gs.minsk.by

  Revisions history

    1.00    21-Dec-96    michael    Initial version.
    1.01    18-Aug-98    andreik    Ported to Delphi4.
    1.02    27-Sep-98    andreik    Slightly modified.

--}

unit xTable;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables;

type
  TxTable = class(TTable)
  private
    FUseOEMFormat: Boolean;

    procedure ANSIGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure ANSISetText(Sender: TField; const Text: string);

  protected
    procedure OpenCursor(InfoQuery: Boolean);
      override;

  public
    constructor Create(AOwner: TComponent); override;

  published
    property UseOEMFormat: Boolean read FUseOEMFormat write FUseOEMFormat
      default True;
  end;

  TxQuery = class(TQuery)
  private
    FUseOEMFormat: Boolean;

    procedure ANSIGetText(Sender: TField; var Text: string; DisplayText: Boolean);
    procedure ANSISetText(Sender: TField; const Text: string);

  protected
    procedure OpenCursor(InfoQuery: Boolean);
      override;

  public
    constructor Create(AOwner: TComponent); override;

  published
    property UseOEMFormat: Boolean read FUseOEMFormat write FUseOEMFormat
      default True;
  end;

procedure Register;

implementation

{
  ****************************
  ***    TxTable Class    ****
  ****************************
}

constructor TxTable.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUseOEMFormat:= True;
end;

procedure TxTable.OpenCursor;
var
  I: Integer;
begin
  inherited OpenCursor(InfoQuery);
  if FUseOEMFormat then
  begin
    for I := 0 to FieldCount - 1 do
    begin
      if Fields[i] is TStringField then
      begin
        TStringField(Fields[i]).Transliterate := False;
        TStringField(Fields[i]).OnGetText := ANSIGetText;
        TStringField(Fields[i]).OnSetText := ANSISetText;
      end;
    end;
  end;
end;

procedure TxTable.ANSIGetText(Sender: TField; var Text: string; DisplayText: Boolean);
var
  Temp: array[0..255] of Char;
begin
  if Length(Sender.AsString) <= 255 then
  begin
    StrPCopy(Temp, Sender.AsString);
    OemToANSI(Temp, Temp);
    Text:= StrPas(Temp);
  end else
    raise Exception.Create('Field value too long');
end;

procedure TxTable.ANSISetText(Sender: TField; const Text: string);
var
  Temp: array[0..255] of Char;
begin
  if Length(Text) <= 255 then
  begin
    StrPCopy(Temp, Text);
    ANSIToOem(Temp, Temp);
    Sender.AsString:= StrPas(Temp);
  end else
    raise Exception.Create('Field value too long');
end;

{
  ****************************
  ***    TxQuery Class    ****
  ****************************
}

constructor TxQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUseOEMFormat:= True;
end;

procedure TxQuery.OpenCursor;
var
  I: Integer;
begin
  inherited OpenCursor(InfoQuery);
  if FUseOEMFormat then
  begin
    for I := 0 to FieldCount - 1 do
    begin
      if Fields[i] is TStringField then
      begin
        TStringField(Fields[i]).Transliterate := False;
        TStringField(Fields[i]).OnGetText := ANSIGetText;
        TStringField(Fields[i]).OnSetText := ANSISetText;
      end;
    end;
  end;
end;

procedure TxQuery.ANSIGetText(Sender: TField; var Text: string; DisplayText: Boolean);
var
  Temp: array[0..255] of Char;
begin
  if Length(Sender.AsString) <= 255 then
  begin
    StrPCopy(Temp, Sender.AsString);
    OemToANSI(Temp, Temp);
    Text:= StrPas(Temp);
  end else
    raise Exception.Create('Field value too long');
end;

procedure TxQuery.ANSISetText(Sender: TField; const Text: string);
var
  Temp: array[0..255] of Char;
begin
  if Length(Text) <= 255 then
  begin
    StrPCopy(Temp, Text);
    ANSIToOem(Temp, Temp);
    Sender.AsString:= StrPas(Temp);
  end else
    raise Exception.Create('Field value too long');
end;

// Registration -------------------------------------------

procedure Register;
begin
  RegisterComponents('gsDB', [TxTable]);
end;

end.

