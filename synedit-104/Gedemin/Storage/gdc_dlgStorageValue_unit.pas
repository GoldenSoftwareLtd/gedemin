unit gdc_dlgStorageValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, ExtCtrls;

type
  Tgdc_dlgStorageValue = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbedName: TDBEdit;
    pnlValue: TPanel;
    Label2: TLabel;
    dbrgType: TDBRadioGroup;
    Label3: TLabel;
    dbedValue: TDBEdit;
    btnEdBLOB: TButton;
    actEditBLOB: TAction;
    Label4: TLabel;
    edPath: TEdit;
    Label5: TLabel;
    edStorage: TEdit;
    procedure dsgdcBaseDataChange(Sender: TObject; Field: TField);
    procedure actEditBLOBUpdate(Sender: TObject);
    procedure actEditBLOBExecute(Sender: TObject);
  private
    { Private declarations }
  public
    procedure SetupRecord; override;
  end;

var
  gdc_dlgStorageValue: Tgdc_dlgStorageValue;

implementation

{$R *.DFM}

uses
  gd_ClassList, gsStorage, gdcStorage, gdcStorage_Types, dlgEditDFM_unit;

procedure Tgdc_dlgStorageValue.dsgdcBaseDataChange(Sender: TObject;
  Field: TField);
begin
  Assert((gdcObject <> nil) and (Length(gdcObject.FieldByName('data_type').AsString) = 1));

  case gdcObject.FieldByName('data_type').AsString[1] of
    cStorageInteger, cStorageBoolean:
      dbedValue.DataField := 'int_data';
    cStorageString:
      dbedValue.DataField := 'str_data';
    cStorageCurrency:
      dbedValue.DataField := 'curr_data';
    cStorageDateTime:
      dbedValue.DataField := 'datetime_data';
  else
    dbedValue.DataField := '';
  end;
end;

procedure Tgdc_dlgStorageValue.actEditBLOBUpdate(Sender: TObject);
begin
  if (gdcObject <> nil) and (Length(gdcObject.FieldByName('data_type').AsString) = 1)
    and (gdcObject.FieldByName('data_type').AsString[1] = cStorageBLOB) then
  begin
    actEditBlob.Enabled := True;
    actEditBlob.Visible := True;
    dbedValue.Visible := False;
  end else
  begin
    actEditBlob.Enabled := False;
    actEditBlob.Visible := False;
    dbedValue.Visible := True;
  end;
end;

procedure Tgdc_dlgStorageValue.actEditBLOBExecute(Sender: TObject);
var
  S: String;
  StIn, StOut: TStringStream;
  Flag: Boolean;
begin
  S := gdcObject.FieldByName('blob_data').AsString;

  if Copy(S, 1, 4) = 'TPF0' then
  begin
    StIn := TStringStream.Create(S);
    StOut := TStringStream.Create('');
    try
      try
        ObjectBinaryToText(StIn, StOut);
        S := StOut.DataString;
        Flag := True;
      except
        S := gdcObject.FieldByName('blob_data').AsString;
        Flag := False;
      end;
    finally
      StIn.Free;
      StOut.Free;
    end;
  end else
    Flag := False;

  if EditDFM(gdcObject.ObjectName, S) then
  begin
    if Flag then
    begin
      StIn := TStringStream.Create(S);
      StOut := TStringStream.Create('');
      try
        ObjectTextToBinary(StIn, StOut);
        gdcObject.FieldByName('blob_data').AsString := StOut.DataString;
      finally
        StIn.Free;
        StOut.Free;
      end;
    end else
      gdcObject.FieldByName('blob_data').AsString := S;
  end;
end;

procedure Tgdc_dlgStorageValue.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S: String;
  SI: TgsStorageItem;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGSTORAGEVALUE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGSTORAGEVALUE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGSTORAGEVALUE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGSTORAGEVALUE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGSTORAGEVALUE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  dbrgType.Enabled := gdcObject.State = dsInsert;

  S := (gdcObject as TgdcStorage).GetPath;
  edPath.Text := Copy(S, 1, Length(S) - Length(gdcObject.ObjectName));

  if (gdcObject as TgdcStorage).FindStorageItem(SI) and (SI.Storage <> nil) then
    edStorage.Text := SI.Storage.Name
  else
    edStorage.Text := '';

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGSTORAGEVALUE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGSTORAGEVALUE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgStorageValue);

finalization
  UnRegisterFrmClass(Tgdc_dlgStorageValue);
end.
