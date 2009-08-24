unit gd_dlgEntryFunctionEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Buttons, StdCtrls, gdcBase, ActnList, gdcClasses, at_classes;

const
  feFieldSynt = '[%s.%s]';
  prHead = 'H';
  prLine = 'L';

  fwBDecl = '[';
  fwEDecl = ']';
  fwPoint = '.';
  fw13    = #13;
  fw10    = #10;

  efServFields =
     ('ID'#13#10'ACHAG'#13#10'AFULL'#13#10'AVIEW'#13#10'DESCRIPTION'#13#10'RESERVED');

type
  TdlgEntryFunctionEdit = class(TForm)
    pnlMain: TPanel;
    pnlButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    mmFunction: TMemo;
    lblName: TLabel;
    cbHeadDocField: TComboBox;
    lblDocHeadFields: TLabel;
    btnInsertHeadField: TSpeedButton;
    Label1: TLabel;
    Bevel1: TBevel;
    procedure btnInsertHeadFieldClick(Sender: TObject);
    procedure actInsertHeadFieldUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FgdcBaseHead: TgdcBase;
    FgdcBaseline: TgdcBase;

    function  GetFunctionText: String;

    procedure FillHeadDocList;
    procedure FillLineDocList;
    procedure SetFunctionText(const Value: String);
    procedure SetgdcBaseHead(const Value: TgdcBase);
    procedure SetgdcBaseline(const Value: TgdcBase);
  public
    constructor Create(AOwner: TComponent); override;
    { Public declarations }
    property gdcBaseHead: TgdcBase read FgdcBaseHead write SetgdcBaseHead;
    property gdcBaseline: TgdcBase read FgdcBaseline write SetgdcBaseline;
    property FunctionText: String read GetFunctionText write SetFunctionText;
  end;

  function  CheckRF(const RF1, RF2: TatRelationField): Boolean;
  function  GetOriginFieldName(FieldName: String): String;
  procedure AddFieldText(const FieldEdit: TMemo; const FullField: string; DocType: TgdcDocumentClassPart);
  procedure AddDocList(const CB: TComboBox; const gdcDoc: TgdcBase;
    const DocPart: TgdcDocumentClassPart);

var
  ServFields: TStrings;

implementation

uses
  IBHeader, DB, gd_dlgEntryFunctionWizard;

{$R *.DFM}

const
  cbFieldText = '%s(%s)';

procedure AddFieldText(const FieldEdit: TMemo;
  const FullField: string; DocType: TgdcDocumentClassPart);
var
  EPos, I: Integer;
  InsStr: String;
begin
  if FieldEdit = nil then
    Exit;

  InsStr := Trim(FullField);
  if Length(InsStr) = 0 then
    Exit;

  EPos := 0;
  for I := Length(InsStr) downto 1 do
  begin
    if (EPos = 0) and (InsStr[I] = ')') then
      EPos := I;
    if InsStr[I] = '(' then
    begin
      if EPos > I + 1 then
        InsStr := Copy(InsStr, I + 1, EPos - I - 1)
      else
        Exit;
      Break;
    end;
  end;
  case DocType of
    dcpHeader:
      InsStr := Format(feFieldSynt, [prHead, InsStr]);
    dcpLine:
      InsStr := Format(feFieldSynt, [prLine, InsStr]);
  end;

  FieldEdit.SelText := InsStr;
end;

function GetOriginFieldName(
  FieldName: String): String;
var
  GI: Integer;
begin
  Result := Copy(FieldName, Pos(fwPoint, FieldName) + 1, Length(FieldName));
  for GI := 1 to Length(Result) do
    if Result[GI] = '"' then
      Result[GI] := ' ';
  Result := Trim(Result);
end;


function CheckRF(const RF1, RF2: TatRelationField): Boolean;
begin
  Result := False;
  if (RF1 = nil) or (RF2 = nil) then
    Exit;
  if ((RF1.ForeignKey = nil) and (RF2.ForeignKey <> nil)) or
    (RF1.ForeignKey <> nil) and (RF2.ForeignKey = nil) then
    Exit;
  // если форейн-кей, то проверяем на ссылочность
  if (RF1.ForeignKey <> nil) and (RF2.ForeignKey <> nil) then
  begin
    if (RF1.ForeignKey.ReferencesField.FieldName =
      RF2.ForeignKey.ReferencesField.FieldName) and
     (RF1.ForeignKey.ReferencesRelation.RelationName =
      RF2.ForeignKey.ReferencesRelation.RelationName) then
    begin
      Result := True;
      Exit;
    end else
      begin
        if (RF1.ForeignKey.ReferencesField.ForeignKey <> nil) and
          (RF2.ForeignKey.ReferencesField.ForeignKey <> nil) then
          Result := CheckRF(RF1.ForeignKey.ReferencesField,
            RF2.ForeignKey.ReferencesField)
        else
          if (RF1.ForeignKey.ReferencesField.ForeignKey <> nil) then
            Result := CheckRF(RF1.ForeignKey.ReferencesField,
              RF2)
          else
            if (RF2.ForeignKey.ReferencesField.ForeignKey <> nil) then
              Result := CheckRF(RF1,
                RF2.ForeignKey.ReferencesField);
      end;
  end else
    begin
      if RF1.SQLType = RF2.SQLType then
        Result := True;
    end;
end;

procedure AddDocList(const CB: TComboBox;
  const gdcDoc: TgdcBase; const DocPart: TgdcDocumentClassPart);
var
  I: Integer;
  Str: String;
  RF: TatRelationField;
begin
  for I := 0 to gdcDoc.Fields.Count - 1 do
  begin
    if ServFields.IndexOf(gdcDoc.Fields[I].FieldName) = -1 then
    begin
      try
        str := gdcDoc.RelationByAliasName(gdcDoc.Fields[I].FieldName)
      except
        Str := '';
      end;

      RF := nil;
      if Length(Str) > 0 then
      begin
        RF := atDatabase.FindRelationField(Str,
          GetOriginFieldName(gdcDoc.Fields[I].Origin));
      end;

      if (RF <> nil) and (RF.ForeignKey = nil) and
        (not (gdcDoc.Fields[I].DataType in
        [ftUnknown, ftString, ftBoolean, ftDate, ftTime, ftDateTime,
        ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary,
        ftCursor, ftFixedChar, ftWideString, ftADT, ftArray, ftReference, ftDataSet,
        ftOraBlob, ftOraClob, ftVariant, ftInterface, ftIDispatch, ftGuid]))
      then
        case DocPart of
          dcpHeader:
            CB.Items.Add(
              Format(cCurrStr, [cwHeader, gdcDoc.Fields[I].DisplayName, gdcDoc.Fields[I].FieldName]));
          dcpLine:
            CB.Items.Add(
              Format(cCurrStr, [cwLine, gdcDoc.Fields[I].DisplayName, gdcDoc.Fields[I].FieldName]));
        end;
    end;
  end;
end;


procedure TdlgEntryFunctionEdit.btnInsertHeadFieldClick(Sender: TObject);
begin
  mmFunction.SelText := GetFieldFromCB(cbHeadDocField.Text);
end;

procedure TdlgEntryFunctionEdit.SetgdcBaseHead(const Value: TgdcBase);
begin
  FgdcBaseHead := Value;
  if FgdcBaseHead <> nil then
    FillHeadDocList;
end;

constructor TdlgEntryFunctionEdit.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TdlgEntryFunctionEdit.FillHeadDocList;
begin
  AddDocList(cbHeadDocField, FgdcBaseHead, dcpHeader);
end;

procedure TdlgEntryFunctionEdit.SetFunctionText(const Value: String);
begin
  mmFunction.Text := Value;
end;

function TdlgEntryFunctionEdit.GetFunctionText: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to mmFunction.Lines.Count - 1 do
  begin
    Result := Result + mmFunction.Lines[I];
  end;
end;

procedure TdlgEntryFunctionEdit.actInsertHeadFieldUpdate(Sender: TObject);
begin
  if Length(Trim(cbHeadDocField.Text)) = 0 then
    btnInsertHeadField.Enabled := False
  else
    btnInsertHeadField.Enabled := True;
end;

procedure TdlgEntryFunctionEdit.SetgdcBaseline(const Value: TgdcBase);
begin
  FgdcBaseLine := Value;
  if FgdcBaseLine <> nil then
    FillLineDocList;
end;

procedure TdlgEntryFunctionEdit.FillLineDocList;
begin
  AddDocList(cbHeadDocField, FgdcBaseLine, dcpLine);
end;

procedure TdlgEntryFunctionEdit.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult = idOk) and (Length(Trim(mmFunction.Text)) = 0) then
    raise Exception.Create('Необходимо задать функцию.');
end;

end.
