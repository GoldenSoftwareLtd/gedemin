
{******************************************}
{                                          }
{     FastReport v2.5 - DB components      }
{              Lookup control              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_DBLookupCtl;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, FR_Class, StdCtrls,
  Controls, Forms, Menus, Dialogs, DB, DBCtrls, FR_DCtrl;

type
  TfrDBLookupControl = class(TfrStdControl)
  private
    FLookup: TDBLookupComboBox;
    FListSource: String;
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefineProperties; override;
    procedure Loaded; override;
  end;


implementation

uses FR_Utils, FR_DBRel, FR_DBUtils, FR_Const
{$IFDEF Delphi6}
, Variants
{$ENDIF};

//{$R FR_DCtrl.RES}

{ TfrDBLookupControl }

constructor TfrDBLookupControl.Create;
begin
  inherited Create;
  FLookup := TDBLookupComboBox.Create(nil);
  FLookup.Parent := frDialogForm;
  AssignControl(FLookup);
  BaseName := 'DBLookupComboBox';
  dx := 145; dy := 21;
end;

destructor TfrDBLookupControl.Destroy;
begin
  FLookup.Free;
  inherited Destroy;
end;

procedure TfrDBLookupControl.DefineProperties;

  function GetFields: String;
  var
    i: Integer;
    sl: TStringList;
    ds: TDataSet;
  begin
    Result := '';
    if (FLookup.ListSource = nil) or (FLookup.ListSource.DataSet = nil) then Exit;
    ds := FLookup.ListSource.DataSet;
    sl := TStringList.Create;
    frGetFieldNames(TfrTDataSet(ds), sl);
    for i := 0 to sl.Count - 1 do
      Result := Result + sl[i] + ';';
    sl.Free;
  end;

  function GetListSource: String;
  var
    i: Integer;
    sl: TStringList;
  begin
    Result := '';
    sl := TStringList.Create;
    frGetComponents(frDialogForm, TDataSet, sl, nil);
    sl.Sort;
    for i := 0 to sl.Count - 1 do
      Result := Result + sl[i] + ';';
    sl.Free;
  end;

begin
  inherited DefineProperties;
  AddEnumProperty('KeyField', GetFields, [Null]);
  AddEnumProperty('ListField', GetFields, [Null]);
  AddEnumProperty('ListSource', GetListSource, [Null]);
  AddProperty('Text', [], nil);
end;

procedure TfrDBLookupControl.SetPropValue(Index: String; Value: Variant);
var
  d: TDataset;
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'TEXT' then
    FLookup.KeyValue := Value
  else if Index = 'KEYFIELD' then
    FLookup.KeyField := Value
  else if Index = 'LISTFIELD' then
    FLookup.ListField := Value
  else if Index = 'LISTSOURCE' then
  begin
    d := frFindComponent(frDialogForm, Value) as TDataSet;
    FLookup.ListSource := frGetDataSource(frDialogForm, d);
  end;
  FLookup.DropDownAlign := daLeft;
end;

function TfrDBLookupControl.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'TEXT' then
    Result := FLookup.KeyValue
  else if Index = 'KEYFIELD' then
    Result := FLookup.KeyField
  else if Index = 'LISTFIELD' then
    Result := FLookup.ListField
  else if Index = 'LISTSOURCE' then
    Result := frGetDataSetName(frDialogForm, FLookup.ListSource)
end;

procedure TfrDBLookupControl.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  FListSource := frReadString(Stream);
  Prop['ListSource'] := FListSource;
  Prop['KeyField'] := frReadString(Stream);
  Prop['ListField'] := frReadString(Stream);
end;

procedure TfrDBLookupControl.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  frWriteString(Stream, Prop['ListSource']);
  frWriteString(Stream, Prop['KeyField']);
  frWriteString(Stream, Prop['ListField']);
end;

procedure TfrDBLookupControl.Loaded;
begin
  Prop['ListSource'] := FListSource;
  inherited Loaded;
end;

var
  Bmp: TBitmap;

initialization
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_DBLOOKUPCONTROL');
  frRegisterControl(TfrDBLookupControl, Bmp, IntToStr(SInsertDBLookup));

finalization
  frUnRegisterObject(TfrDBLookupControl);
  Bmp.Free;

end.

