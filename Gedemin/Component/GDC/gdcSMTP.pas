unit gdcSMTP;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcBaseInterface, gd_ClassList;

type
  TgdcSMTP = class(TgdcBase)
  protected
    procedure DoBeforePost; override;

  public
    function HideFieldsList: String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gdc_frmSMTP_Unit, gdc_dlgSMTP_Unit, gd_common_functions;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcSMTP]);
end;

{ TgdcSMTP }

procedure TgdcSMTP.DoBeforePost;
  VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  PassHex, S: String;
  Len: Integer;
  I: Integer;
  B: Byte;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCSMTP', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCSMTP', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCSMTP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCSMTP',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCSMTP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FieldChanged('PASSW') then
  begin
    S := FieldByName('PASSW').AsString;
    Len := Length(S);
    PassHex := '';
    I := 1;
    while I <= Len do
    begin
      B := Byte(S[I]);
      B := B xor (1 shl 4);
      S[I] := Chr(B);
      PassHex := PassHex + AnsiCharToHex(S[I]);
      Inc(I);
    end;
    FieldByName('PASSW').AsString := PassHex;
  end;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCSMTP', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCSMTP', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcSMTP.HideFieldsList: String;
begin
  Result := inherited HideFieldsList + 'passw;';
end;

class function TgdcSMTP.GetViewFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmSMTP';
end;

class function TgdcSMTP.GetDialogFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgSMTP';
end;

class function TgdcSMTP.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_SMTP';
end;

class function TgdcSMTP.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

initialization
  RegisterGDCClass(TgdcSMTP, 'Почтовый ящик');

finalization
  UnregisterGdcClass(TgdcSMTP);

end.
