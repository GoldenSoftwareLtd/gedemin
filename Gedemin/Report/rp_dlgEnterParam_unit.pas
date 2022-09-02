// ShlTanya, 27.02.2019

unit rp_dlgEnterParam_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, contnrs;

type
  TdlgEnterParam = class(TForm)
    pnlButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlLabel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDefaultHeight: Integer;
    FParamList: TObjectList;
    FIsReadOnly: Boolean;
    procedure AddLine(const ParamType: Integer = 0);
    procedure FillItems(const AnArray: Variant);
  public
    function InputParams(var AnValue: Variant): Boolean;
    procedure ViewParam(const AnValue: Variant);
  end;

  function GetVariantArray(const AnArray: Variant): String;
  function ConvertVarParam(const Value: Variant): String;

var
  dlgEnterParam: TdlgEnterParam;

implementation

uses
  rp_frmParamLine_unit,
  gd_SetDatabase
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure TdlgEnterParam.FormCreate(Sender: TObject);
begin
  FDefaultHeight := Height;
  FParamList := TObjectList.Create;
end;

procedure TdlgEnterParam.FormDestroy(Sender: TObject);
begin
  FParamList.Free;
end;

procedure TdlgEnterParam.AddLine(const ParamType: Integer = 0);
var
  I: Integer;
begin
  I := FParamList.Add(TfrmParamLine.Create(nil));
  TfrmParamLine(FParamList.Items[I]).lblParamName.Caption := 'Параметр ' + IntToStr(I);
  TfrmParamLine(FParamList.Items[I]).cbType.ItemIndex := ParamType;
  TfrmParamLine(FParamList.Items[I]).Top := pnlLabel.Height + I * TfrmParamLine(FParamList.Items[I]).Height;
  TfrmParamLine(FParamList.Items[I]).Parent := Self;
  Height := FDefaultHeight + TfrmParamLine(FParamList.Items[I]).Height * (I + 1);
  if FIsReadOnly then
    TfrmParamLine(FParamList.Items[I]).Enabled := False;
end;

function TdlgEnterParam.InputParams(var AnValue: Variant): Boolean;
var
  I, Delta: Integer;
  TempValue: Variant;

  procedure SetVariantArray(var AnValue: Variant; const AnSource: String);
  const
    Separator = ';';
  var
    WorkSource: String;
    I, LocIndex: Integer;
  begin
    WorkSource := AnSource;
    AnValue := VarArrayCreate([0, Length(AnSource) - 1], varVariant);
    LocIndex := 0;
    I := AnsiPos(Separator, WorkSource);
    while I <> 0 do
    begin
      AnValue[LocIndex] := {VarAsType(}Copy(WorkSource, 1, I - 1){, varVariant)};
      WorkSource := Copy(WorkSource, I + 1, Length(WorkSource) - I);
      Inc(LocIndex);

      I := AnsiPos(Separator, WorkSource);
    end;
    if Length(WorkSource) <> 0 then
    begin
      AnValue[LocIndex] := Copy(WorkSource, 1, Length(WorkSource));
      Inc(LocIndex);
    end;
    VarArrayRedim(AnValue, LocIndex - 1);
  end;
begin
  Result := False;
  FIsReadOnly := False;
  FParamList.Clear;
  if not VarIsArray(AnValue) then
  begin
    MessageBox(Self.Handle, 'Входной параметр должен быть массивом.', 'Ошибка', MB_OK or MB_ICONERROR);
    Exit;
  end;

  FillItems(AnValue);

  if ShowModal = mrOk then
  begin
    Delta := VarArrayLowBound(AnValue, 1);
    for I := 0 to FParamList.Count - 1 do
      if TfrmParamLine(FParamList.Items[I]).cbType.ItemIndex = 0 then
        try
          AnValue[I + Delta] := StrToFloat(TfrmParamLine(FParamList.Items[I]).edValue.Text);
        except
          try
            AnValue[I + Delta] := VarAsType(TfrmParamLine(FParamList.Items[I]).edValue.Text, varDate);
          except
            AnValue[I + Delta] := TfrmParamLine(FParamList.Items[I]).edValue.Text;
          end;
        end
      else
      begin
        SetVariantArray(TempValue, TfrmParamLine(FParamList.Items[I]).edValue.Text);
        AnValue[I + Delta] := TempValue;
      end;
    Result := True;
  end;
end;

function GetVariantArray(const AnArray: Variant): String;
var
  LocI: Integer;
begin
  Result := '';
  for LocI := VarArrayLowBound(AnArray, 1) to VarArrayHighBound(AnArray, 1) do
    if VarIsArray(AnArray[LocI]) then
      Result := Result + 'array[' + GetVariantArray(AnArray[LocI]) + '];'
    else
      Result := Result + ConvertVarParam(AnArray[LocI]) + ';';
end;

procedure TdlgEnterParam.FillItems(const AnArray: Variant);
var
  I: Integer;
begin
  for I := VarArrayLowBound(AnArray, 1) to VarArrayHighBound(AnArray, 1) do
  begin
    if VarIsArray(AnArray[I]) then
    begin
      AddLine(1);
      TfrmParamLine(FParamList.Items[FParamList.Count - 1]).edValue.Text := GetVariantArray(AnArray[I]);
    end else
    begin
      AddLine;
      TfrmParamLine(FParamList.Items[FParamList.Count - 1]).edValue.Text := ConvertVarParam(AnArray[I]);
    end;
  end;
end;

procedure TdlgEnterParam.ViewParam(const AnValue: Variant);
begin
  FIsReadOnly := True;
  FParamList.Clear;
  if not VarIsArray(AnValue) then
  begin
    MessageBox(Self.Handle, 'Входной параметр должен быть массивом.', 'Ошибка', MB_OK or MB_ICONERROR);
    Exit;
  end;

  FillItems(AnValue);

  btnOk.Visible := False;
  ShowModal;
end;

function ConvertVarParam(const Value: Variant): String;
begin
  Result := Value;
{  case VarType(Value) of
    varDate: Result := IBDateTimeToStr(Value);
    varSmallint, varInteger, varSingle, varDouble:
     Result := FormatFloat('', Value);
  else
    Result := Value;
  end;}
end;

end.
