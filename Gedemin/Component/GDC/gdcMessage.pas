
unit gdcMessage;

interface

uses
  Classes, Forms, gdcBase, gdcTree, gd_createable_form, gdcBaseInterface;

type
  TgdcMessageBox = class(TgdcLBRBTree)
  protected
    function CreateDialogForm: TCreateableForm; override;

    //
    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcBaseMessage = class(TgdcBase)
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    //
    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

    //
    procedure _DoOnNewRecord; override;

  public
    //
    function GetCurrRecordClass: TgdcFullClass; override;

    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetMessageType: Char; virtual;

    class function IsAbstractClass: Boolean; override;
  end;

  TgdcPhoneCall = class(TgdcBaseMessage)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    function CreateDialogForm: TCreateableForm; override;
    procedure _DoOnNewRecord; override;
    procedure DoBeforePost; override;

  public
    class function GetMessageType: Char; override;
    function GetDialogDefaultsFields: String; override;
    function GetNotCopyField: String; override;
  end;

  TgdcAttachment = class(TgdcBase)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    function CreateDialog(const ADlgClassName: String = ''): Boolean; override;
    procedure OpenAttachment;

    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  Windows,                      ShellAPI,
  DB,                           SysUtils,               Dialogs,
  gd_ClassList,                 gdc_msg_frmMain_unit,   gdc_msg_dlgBox_unit,
  gdc_msg_dlgPhoneCall_unit,    gd_security,            msg_attachment
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Register;
begin
  RegisterComponents('gdc', [
    TgdcMessageBox,
    TgdcBaseMessage,
    TgdcAttachment
  ]);
end;

{ TgdcMessageBox }

function TgdcMessageBox.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  I: Integer;
  LocalObj: TgdcBaseMessage;
begin
  if CD.Obj is TgdcBaseMessage then
  begin
    for I := 0 to CD.ObjectCount - 1 do
    begin
      if CD.Obj.Locate('ID', CD.ObjectArr[I].ID, []) then
      begin
        CD.Obj.Edit;
        try
          CD.Obj.FieldByName('boxkey').AsInteger := Self.ID;
          CD.Obj.Post;
        except
          CD.Obj.Cancel;
          raise;
        end;
      end else
      begin 
        { TODO : а копировать обработчики событий?? }
        LocalObj := TgdcBaseMessage.CreateWithParams(nil,
          Database,
          Transaction,
          '',
          'ByID',
          CD.ObjectArr[I].ID);
        try
          CopyEventHandlers(LocalObj, CD.Obj);
                      
          LocalObj.Open;
          if not LocalObj.EOF then
          begin
            LocalObj.Edit;
            try
              LocalObj.FieldByName('boxkey').AsInteger := Self.ID;
              LocalObj.Post;
            except         
              LocalObj.Cancel;
              raise;
            end;
          end;
        finally
          LocalObj.Free;
        end;
      end;
    end;
    Result := True;
  end else
    Result := inherited AcceptClipboard(CD);
end;

function TgdcMessageBox.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCMESSAGEBOX', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCMESSAGEBOX', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCMESSAGEBOX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCMESSAGEBOX',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCMESSAGEBOX' then
  {M}        begin
  {M}//          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_msg_dlgBox.CreateSubType(ParentForm, SubType);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCMESSAGEBOX', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCMESSAGEBOX', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

class function TgdcMessageBox.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcMessageBox.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'MSG_BOX';
end;

class function TgdcMessageBox.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := '';
end;

{ TgdcBaseMessage }

function TgdcBaseMessage.AcceptClipboard(CD: PgdcClipboardData): Boolean;
begin
  if (CD.Obj is TgdcMessageBox) and (CD.ObjectCount = 1) then
  begin
    Edit;
    FieldByName('boxkey').AsInteger := CD.ObjectArr[0].ID;
    Post;
    Result := True;
  end else
    Result := inherited AcceptClipboard(CD);
end;

function TgdcPhoneCall.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCPHONECALL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPHONECALL', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPHONECALL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPHONECALL',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPHONECALL' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_msg_dlgPhoneCall.CreateSubType(ParentForm, SubType);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPHONECALL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPHONECALL', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;

function TgdcBaseMessage.GetCurrRecordClass: TgdcFullClass;
var
  F: TField;
begin
  if System.Copy(FieldByName('msgtype').AsString, 1, 1) = 'A' then
  begin
    Result.gdClass := TgdcPhoneCall;
    Result.SubType := '';
  end else
  begin
    Result.gdClass := CgdcBase(Self.ClassType);
    Result.SubType := '';
  end;

  F := FindField('USR$ST');
  if F <> nil then
    Result.SubType := F.AsString;
  if (Result.SubType > '') and (not Result.gdClass.CheckSubType(Result.SubType)) then
    raise EgdcException.Create('Invalid USR$ST value.');
end;

function TgdcBaseMessage.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCBASEMESSAGE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEMESSAGE', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEMESSAGE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEMESSAGE',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEMESSAGE' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result :=
    'FROM msg_message z ';

  if not ARefresh then
  begin
    if HasSubSet('ByBoxLBRB') then
      Result := Result + ' JOIN msg_box b ON b.LB >= :LB AND b.RB <= :RB AND z.boxkey=b.id '
    else if HasSubSet('ByBoxID') then
      Result := Result + ' JOIN msg_box b ON b.ID=:BoxID AND z.boxkey=b.id ';

    FSQLSetup.Ignores.AddAliasName('oc');
    FSQLSetup.Ignores.AddAliasName('fc');
    FSQLSetup.Ignores.AddAliasName('tc');
  end;

  Result := Result +
    '  LEFT JOIN gd_contact oc ON oc.id=z.operatorkey ' +
    '  LEFT JOIN gd_contact fc ON fc.id=z.fromcontactkey ' +
    '  LEFT JOIN gd_contact tc ON tc.id=z.tocontactkey ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEMESSAGE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEMESSAGE', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcBaseMessage.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'subject';
end;

class function TgdcBaseMessage.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'MSG_MESSAGE';
end;

class function TgdcBaseMessage.GetMessageType: Char;
begin
{ TODO : расписать в теории что делать в таком случае }
  Result := #0;
end;

function TgdcBaseMessage.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCBASEMESSAGE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEMESSAGE', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEMESSAGE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEMESSAGE',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEMESSAGE' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  
  Result :=
    'SELECT ' +
    '  z.id, ' +
    '  z.boxkey, ' +
    '  z.msgtype, ' +
    '  z.msgstart, ' +
//    '  z.msgstartdate, ' +
//    '  z.msgstartmonth, ' +
    '  z.msgend, ' +
    '  z.subject, ' +
    '  z.header, ' +
    '  z.body, ' +
    '  z.bdata, ' +
    '  z.messageid, ' +
    '  z.fromid, ' +
    '  z.fromcontactkey, ' +
    '  z.copy, ' +
    '  z.bcc, ' +
    '  z.toid, ' +
    '  z.tocontactkey, ' +
    '  z.operatorkey, ' +
    '  z.replykey, ' +
    '  z.cost, ' +
    '  z.afull, ' +
    '  z.achag, ' +
    '  z.aview, ' +
    '  z.reserved, ' +
    '  z.attachmentcount, ' +
    '  oc.name AS operatorname, ' +
    '  fc.name AS fromcontactname, ' +
    '  tc.name AS tocontactname ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEMESSAGE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEMESSAGE', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcBaseMessage.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByBoxLBRB;ByBoxID;';
end;

procedure TgdcPhoneCall.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCPHONECALL', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPHONECALL', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPHONECALL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPHONECALL',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPHONECALL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if not (sMultiple in BaseState) then
  begin
    if (State = dsInsert) and (FieldByName('msgend').IsNull) then
      FieldByName('msgend').AsDateTime := Now;
  end;
      
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPHONECALL', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPHONECALL', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcPhoneCall.GetDialogDefaultsFields: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCPHONECALL', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPHONECALL', KEYGETDIALOGDEFAULTSFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETDIALOGDEFAULTSFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPHONECALL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPHONECALL',
  {M}          'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETDIALOGDEFAULTSFIELDS' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPHONECALL' then
  {M}        begin
  {M}          Result := Inherited GETDIALOGDEFAULTSFIELDS;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := '';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPHONECALL', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPHONECALL', 'GETDIALOGDEFAULTSFIELDS', KEYGETDIALOGDEFAULTSFIELDS);
  {M}  end;
  {END MACRO}
end;

class function TgdcPhoneCall.GetMessageType: Char;
begin
  Result := 'A';
end;

function TgdcPhoneCall.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCPHONECALL', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPHONECALL', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPHONECALL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPHONECALL',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCPHONECALL(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPHONECALL' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',' + 'msgstart' + ',' + 'msgend' +
    ',' + 'operatorkey';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPHONECALL', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPHONECALL', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcPhoneCall.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.msgtype = ''A''');
end;

class function TgdcBaseMessage.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_msg_frmMain';
end;

class function TgdcBaseMessage.IsAbstractClass: Boolean;
begin
  Result := ClassNameIs('TgdcBaseMessage');
end;

procedure TgdcBaseMessage._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCBASEMESSAGE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCBASEMESSAGE', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCBASEMESSAGE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCBASEMESSAGE',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCBASEMESSAGE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  with FgdcDataLink do
    if (DataSet is TgdcMessageBox) and DataSet.Active and FieldByName('boxkey').IsNull then
      FieldByName('boxkey').AsInteger := (DataSet as TgdcBase).ID;
  if GetMessageType <> #0 then
    FieldByName('msgtype').AsString := GetMessageType
  else
    raise EgdcException.CreateObj('Abstract base class!', Self);
  FieldByName('operatorkey').AsInteger := IBLogin.ContactKey;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCBASEMESSAGE', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCBASEMESSAGE', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcPhoneCall._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCPHONECALL', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCPHONECALL', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCPHONECALL') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCPHONECALL',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCPHONECALL' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('msgstart').AsDateTime := Now;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCPHONECALL', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCPHONECALL', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

{ TgdcAttachment }

function TgdcAttachment.CreateDialog(const ADlgClassName: String = ''): Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  od: TOpenDialog;
  S: TStringStream;
  FS: TFileStream;
begin
  {@UNFOLD MACRO INH_ORIG_CREATEDIALOG('TGDCATTACHMENT', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}//  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCATTACHMENT', KEYCREATEDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCATTACHMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCATTACHMENT',
  {M}          'CREATEDIALOG', KEYCREATEDIALOG, Params, LResult) then
  {M}          begin
  {M}            Result := False;
  {M}            if VarType(LResult) = varBoolean then
  {M}              Result := Boolean(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CREATEDIALOG' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не булевый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCATTACHMENT' then
  {M}        begin
  {M}          Result := Inherited CreateDialog(ADlgClassName);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Assert(Active);

  Result := False;
  od := TOpenDialog.Create(ParentForm);
  try
    if od.Execute then
    begin
      if not (State in dsEditModes) then
        Insert;
      S := TStringStream.Create('');
      FS := TFileStream.Create(od.FileName, fmOpenRead);
      try
        S.CopyFrom(FS, 0);
        FieldByName('bdata').AsString := S.DataString;
        FieldByName('filename').AsString := ExtractFileName(od.FileName);
      finally
        FS.Free;
        S.Free;
      end;
      Post;
      Result := True;
    end;
  finally
    od.Free;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCATTACHMENT', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCATTACHMENT', 'CREATEDIALOG', KEYCREATEDIALOG);
  {M}  end;
  {END MACRO}
end;

class function TgdcAttachment.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'FILENAME';
end;

class function TgdcAttachment.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'MSG_ATTACHMENT'
end;

class function TgdcAttachment.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByMessage;';
end;

procedure TgdcAttachment.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByMessage') then
     S.Add(Format('%s.messagekey=:MessageKey', [GetListTableAlias]));
end;

procedure TgdcAttachment.OpenAttachment;
var
//  FS: TFileStream;
//  S: TStringStream;
  Ch: array[0..1024] of Char;
  Operation: array[0..4] of Char;
  Directory: array[0..254] of Char;
  FileName: String;
begin
  Assert(Active);
  if IsEmpty then Exit;

  GetTempPath(1024, Ch);
  FileName := IncludeTrailingBackSlash(Ch) + FieldByName('filename').AsString;
  attSaveToFile(FileName, FieldByName('bdata').AsString, True);

  StrPCopy(Operation, 'open');
  StrPCopy(Directory, ExtractFilePath(FileName));
  FileName := FileName + #0;
  if ShellExecute(ParentHandle, Operation, @FileName[1], nil, Directory, SW_SHOW) <= 32 then
  begin
    MessageBox(ParentHandle,
      PChar(Format('Невозможно открыть файл %s.', [FileName])),
      'Внимание', MB_OK or MB_ICONEXCLAMATION);
  end;
end;

initialization
  RegisterGDCClass(TgdcMessageBox, ctStorage, 'Почтовый ящик');
  RegisterGDCClass(TgdcBaseMessage);
  RegisterGDCClass(TgdcPhoneCall, ctStorage, 'Телефонный звонок');
  RegisterGDCClass(TgdcAttachment);

finalization
  UnRegisterGDCClass(TgdcMessageBox);
  UnRegisterGDCClass(TgdcBaseMessage);
  UnRegisterGDCClass(TgdcPhoneCall);
  UnRegisterGDCClass(TgdcAttachment);
end.
