
{++

  Copyright (c) 1997 by Golden Software of Belarus

  Module

    xstext.pas

  Abstract

    Static text with bevel.

  Author

    Andrei Kireev (2-Aug-97)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    02-Aug-97    andreik    Initial version.

--}

unit xSText;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DB, DBTables, DBCtrls;

const
  Def_Color = clWindow;
  
type
  TxStaticText = class(TLabel)
  private
    procedure gsDoDrawText(var Rect: TRect; Flags: Word);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property AutoSize default False;
    property Height default 19;
  end;

type
  TxDBStaticText = class(TxStaticText)
  private
    FDataLink: TFieldDataLink;

    procedure DataChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetField: TField;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);

  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Field: TField read GetField;

  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
  end;

procedure Register;

implementation

uses
  ExtCtrls;

{ TxStaticText -------------------------------------------}

constructor TxStaticText.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Color := Def_Color;
  AutoSize := False;
  Height := 19;
end;

procedure TxStaticText.Paint;
const
  Alignments: array[TAlignment] of Word = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  R: TRect;
begin
  with Canvas do
  begin
    R := ClientRect;
    Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);
    if not Transparent then
    begin
      Brush.Color := Self.Color;
      Brush.Style := bsSolid;
      FillRect(R);
    end;
    Brush.Style := bsClear;
    Inc(R.Left, 2);
    Dec(R.Right, 2);
    gsDoDrawText(R, (DT_EXPANDTABS {or DT_WORDBREAK} or DT_VCENTER or DT_SINGLELINE) or
      Alignments[Alignment]);
  end;
end;

procedure TxStaticText.gsDoDrawText(var Rect: TRect; Flags: Word);
var
  Text: array[0..255] of Char;
begin
  GetTextBuf(Text, SizeOf(Text));
  if (Flags and DT_CALCRECT <> 0) and ((Text[0] = #0) or ShowAccelChar and
    (Text[0] = '&') and (Text[1] = #0)) then StrCopy(Text, ' ');
  if not ShowAccelChar then Flags := Flags or DT_NOPREFIX;
  Canvas.Font := Font;
  if not Enabled then Canvas.Font.Color := clGrayText;
  DrawText(Canvas.Handle, Text, StrLen(Text), Rect, Flags);
end;

{ TxDBStaticText -----------------------------------------}

constructor TxDBStaticText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ShowAccelChar := False;
  FDataLink := TFieldDataLink.Create;
  FDataLink.OnDataChange := DataChange;
end;

destructor TxDBStaticText.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
end;

procedure TxDBStaticText.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

function TxDBStaticText.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TxDBStaticText.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TxDBStaticText.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TxDBStaticText.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TxDBStaticText.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TxDBStaticText.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    Caption := FDataLink.Field.DisplayText
  else
    if csDesigning in ComponentState then Caption := Name else Caption := '';
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsDB', [TxStaticText]);
  RegisterComponents('gsDB', [TxDBStaticText]);
end;

end.
