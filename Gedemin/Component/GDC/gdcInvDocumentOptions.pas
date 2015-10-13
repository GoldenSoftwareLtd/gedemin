unit gdcInvDocumentOptions;

interface

uses
  Classes, gdcBaseInterface, gdcBase;

type
  TgdcInvDocumentTypeOptions = class(TgdcBase)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;
    
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    function CheckTheSameStatement: String; override;
  end;

procedure Register;

implementation

uses
  SysUtils, DB, gd_directories_const, gd_ClassList, gdcClasses_Interface;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcInvDocumentTypeOptions]);
end;

{ TgdcInvDocumentTypeOptions }

class function TgdcInvDocumentTypeOptions.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'OPTION_NAME';
end;

class function TgdcInvDocumentTypeOptions.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'GD_DOCUMENTTYPE_OPTION';
end;

class function TgdcInvDocumentTypeOptions.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByDocumentType;';
end;

procedure TgdcInvDocumentTypeOptions.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByDocumentType') then
    S.Add('z.dtkey = :DocumentTypeKey');
end;

function TgdcInvDocumentTypeOptions.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCINVDOCUMENTTYPEOPTIONS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTTYPEOPTIONS', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTTYPEOPTIONS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTTYPEOPTIONS',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTTYPEOPTIONS' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result := 'SELECT id FROM gd_documenttype_option WHERE dtkey=:dtkey AND option_name=:option_name ' +
      'AND relationfieldkey IS NOT DISTINCT FROM :relationfieldkey AND contactkey IS NOT DISTINCT FROM :contactkey'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT id FROM gd_documenttype_option WHERE dtkey=%d ' +
      'AND option_name=%s AND COALESCE(relationfieldkey, 0)=%d AND COALESCE(contactkey, 0)=%d',
      [FieldByName('dtkey').AsInteger, StringReplace(FieldByName('option_name').AsString, '''', '''''', [rfReplaceAll]),
      FieldByName('relationfieldkey').AsInteger, FieldByName('contactkey').AsInteger]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTTYPEOPTIONS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTTYPEOPTIONS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvDocumentTypeOptions.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  DE: TgdDocumentEntry;
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCINVDOCUMENTTYPEOPTIONS', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVDOCUMENTTYPEOPTIONS', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVDOCUMENTTYPEOPTIONS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVDOCUMENTTYPEOPTIONS',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVDOCUMENTTYPEOPTIONS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  DE := gdClassList.FindDocByTypeID(FieldByName('dtkey').AsInteger, dcpHeader);
  if DE <> nil then
    DE.Invalid := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVDOCUMENTTYPEOPTIONS', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVDOCUMENTTYPEOPTIONS', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGdcClass(TgdcInvDocumentTypeOptions, 'Параметры типа складского документа');

finalization
  UnregisterGdcClass(TgdcInvDocumentTypeOptions);
end.
