// ShlTanya, 24.02.2019

unit gdc_msg_dlgPhoneCall_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, gsIBLookupComboBox, dmDatabase_unit, Mask, xDateEdits,
  IBCustomDataSet, gdcBase, gdcTree, gdcContacts, gsDBTreeView, gd_KeyAssoc,
  gdcMessage, Grids, DBGrids, gsDBGrid, gsIBGrid, Menus;

type
  Tgdc_msg_dlgPhoneCall = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    lkFrom: TgsIBLookupComboBox;
    Label2: TLabel;
    dbedSubject: TDBEdit;
    dbreBody: TDBRichEdit;
    Label3: TLabel;
    Label4: TLabel;
    xDateDBEdit1: TxDateDBEdit;
    xDateDBEdit2: TxDateDBEdit;
    tsAttachment: TTabSheet;
    gsIBGrid1: TgsIBGrid;
    gdcAttachment: TgdcAttachment;
    dsAttachment: TDataSource;
    Button1: TButton;
    Button2: TButton;
    lkFolder: TgsIBLookupComboBox;
    lkTo: TgsIBLookupComboBox;
    Label5: TLabel;
    Label6: TLabel;
    lbPhone: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure lkFromChange(Sender: TObject);
    procedure gsIBGrid1DblClick(Sender: TObject);

  protected
    //”казывает нестандартный базовый класс дл€ Choose по имени таблицы
    function GetgdcClass(ARelationName: String): String; override;
    //”казывает сабсет дл€ компонента выбора дл€ Choose по имени таблицы
    function GetChooseSubSet(ARelationName: String): String; override;

    //
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; override;

  public
    procedure Setup(AnObject: TObject); override;
    procedure BeforePost; override;
  end;

var
  gdc_msg_dlgPhoneCall: Tgdc_msg_dlgPhoneCall;

implementation

{$R *.DFM}

uses
  IBSQL, gd_security, gd_directories_const,  gd_ClassList,
  gdcBaseInterface;

procedure Tgdc_msg_dlgPhoneCall.Setup(AnObject: TObject);
//var
//  CK: Integer;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_MSG_DLGPHONECALL', 'SETUP', KEYSETUP)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_MSG_DLGPHONECALL', KEYSETUP);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUP]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_MSG_DLGPHONECALL') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_MSG_DLGPHONECALL',
  {M}        'SETUP', KEYSETUP, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_MSG_DLGPHONECALL' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;

  // мы предусматриваем возможность задани€ одной компании, как
  // базовой дл€ ввода звонков
  // таким образом мы сможем одновременно вводить звонки и
  // переключатьс€ между бухгалтери€ми нескольких компаний
  //CK := GlobalStorage.ReadInteger(st_ms_OptionsPath, st_ms_CompanyKey, IBLogin.CompanyKey);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_MSG_DLGPHONECALL', 'SETUP', KEYSETUP)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_MSG_DLGPHONECALL', 'SETUP', KEYSETUP);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_msg_dlgPhoneCall.Button1Click(Sender: TObject);
begin
  gdcAttachment.CreateDialog;
end;

procedure Tgdc_msg_dlgPhoneCall.Button2Click(Sender: TObject);
begin
  gdcAttachment.OpenAttachment;
end;

procedure Tgdc_msg_dlgPhoneCall.BeforePost;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_MSG_DLGPHONECALL', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_MSG_DLGPHONECALL', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_MSG_DLGPHONECALL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_MSG_DLGPHONECALL',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_MSG_DLGPHONECALL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  with gdcObject do
    if (FieldByName('subject').AsString = '') and (dbreBody.Lines.Count > 0) then
      FieldByName('subject').AsString := TrimRight(dbreBody.Lines[0]);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_MSG_DLGPHONECALL', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_MSG_DLGPHONECALL', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

function Tgdc_msg_dlgPhoneCall.GetChooseSubSet(ARelationName: String): String;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_GETCHOOSESUBSET('TGDC_MSG_DLGPHONECALL', 'GETCHOOSESUBSET', KEYGETCHOOSESUBSET)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_MSG_DLGPHONECALL', KEYGETCHOOSESUBSET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETCHOOSESUBSET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_MSG_DLGPHONECALL') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_MSG_DLGPHONECALL',
  {M}        'GETCHOOSESUBSET', KEYGETCHOOSESUBSET, Params, LResult) then
  {M}      begin
  {M}        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}          Result := String(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_MSG_DLGPHONECALL' then
  {M}      begin
  {M}        Result := Inherited GetChooseSubSet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  if AnsiCompareText(ARelationName, 'MSG_TARGET') = 0 then
    Result := 'AllPeople'
  else
    Result := inherited GetChooseSubSet(ARelationName);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_MSG_DLGPHONECALL', 'GETCHOOSESUBSET', KEYGETCHOOSESUBSET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_MSG_DLGPHONECALL', 'GETCHOOSESUBSET', KEYGETCHOOSESUBSET);
  {M}end;
  {END MACRO}
end;

function Tgdc_msg_dlgPhoneCall.GetgdcClass(ARelationName: String): String;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_GETGDCCLASS('TGDC_MSG_DLGPHONECALL', 'GETGDCCLASS', KEYGETGDCCLASS)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_MSG_DLGPHONECALL', KEYGETGDCCLASS);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGDCCLASS]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_MSG_DLGPHONECALL') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_MSG_DLGPHONECALL',
  {M}        'GETGDCCLASS', KEYGETGDCCLASS, Params, LResult) then
  {M}      begin
  {M}        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}          Result := ShortString(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_MSG_DLGPHONECALL' then
  {M}      begin
  {M}        Result := Inherited GetgdcClass(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  if AnsiCompareText(ARelationName, 'MSG_TARGET') = 0 then
    Result := 'TgdcDepartment'
  else
    Result := inherited GetChooseSubSet(ARelationName);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_MSG_DLGPHONECALL', 'GETGDCCLASS', KEYGETGDCCLASS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_MSG_DLGPHONECALL', 'GETGDCCLASS', KEYGETGDCCLASS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_msg_dlgPhoneCall.lkFromChange(Sender: TObject);
const
  K: TID = -1;
  N: String = '';
var
  q: TIBSQL;
begin
  if Assigned(gdcBaseManager) and (lkFrom.CurrentKey > '') then
  begin
    if lkFrom.CurrentKeyInt = K then
      lbPhone.Caption := N
    else begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := gdcBaseManager.ReadTransaction;
        q.SQL.Text := 'SELECT phone FROM gd_contact WHERE id=:ID';
        SetTID(q.ParamByName('ID'), lkFrom.CurrentKeyInt);
        q.ExecQuery;
        lbPhone.Caption := q.Fields[0].AsString;
        K := lkFrom.CurrentKeyInt;
        N := q.Fields[0].AsString;
      finally
        q.Free;
      end;
    end;
  end else
    lbPhone.Caption := '';  
end;

function Tgdc_msg_dlgPhoneCall.NeedVisibleTabSheet(
  const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_MSG_DLGPHONECALL', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_MSG_DLGPHONECALL', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_MSG_DLGPHONECALL') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_MSG_DLGPHONECALL',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_MSG_DLGPHONECALL' then
  {M}      begin
  {M}        Result := Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := False;

  {
  if AnsiCompareText(ARelationName, 'MSG_TARGET') = 0 then
    Result := False
  else
    Result := inherited NeedVisibleTabSheet(ARelationName);
  }

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_MSG_DLGPHONECALL', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_MSG_DLGPHONECALL', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_msg_dlgPhoneCall.gsIBGrid1DblClick(Sender: TObject);
begin
  gdcAttachment.OpenAttachment;
end;

initialization
  RegisterFrmClass(Tgdc_msg_dlgPhoneCall);

finalization
  UnRegisterFrmClass(Tgdc_msg_dlgPhoneCall);
end.
