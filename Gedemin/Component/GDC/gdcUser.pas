
unit gdcUser;

interface

uses
  Forms, Classes, DB, gd_createable_form, gdcBase, gdcBaseInterface,
  Graphics, IBDatabase;

type
  TgdcUser = class(TgdcBase)
  private
    FGroups: Integer;

    function GetGroups: Integer;
    procedure SetGroups(const Value: Integer);

  protected
    FSysDBAPassword: String;

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetOrderClause: String; override;

    // настроим поля. В частности, надо снять с поля КонтактНэйм
    // флаг Обязательного наличия
    procedure CreateFields; override;

    procedure _DoOnNewRecord; override;
    // при создании новой записи генерируем имя ИБ пользователя
    // и его пароль делаем это при сохранении, чтобы перекрыть пароль и имя считанные с потока
    procedure DoBeforePost; override;

    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

    //
    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

    // Возвращает строку пригодную в качестве имени пользователя или
    // пароля. Т.е. длиной 8 символов, первая буква и остальные буквы или цифры.
    function GetRandomString: String;

    //
    procedure SyncField(Field: TField); override;

    //
    function GetCustomProcess: TgsCustomProcesses; override;

    //
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomInsert(Buff: Pointer); override;
    // после удаления пользователя из таблицы GD_USER
    // мы должны удалить с сервера соответствующего ему пользователя
    // интербейза. Если при удалении пользователя сервера
    // произошла ошибка, то исключение будет поднято и
    // запись из GD_USER удалена не будет.
    procedure CustomDelete(Buff: Pointer); override;

    // если для текущего сеанса используется не пользователь
    // SYSDBA, то необходимо отдельно запросить пароль
    // для доступа к серверу базы данных
    class procedure CheckSysDBAPassword(var ASysDBAPassword: String);

    function CheckTheSameStatement: String; override;

    function GetNotCopyField: String; override;

  public
    //
    function HideFieldsList: String; override;

    // проверяет существование в базе пользователя с таким именем
    // возвращает Истину, если есть и Ложь в противном
    // случае
    function CheckUser(const AUserName: String): Boolean;

    // проверяет существование на сервере пользователя
    // соответствующего текущей записи
    function CheckIBUser: Boolean; overload;

    // создает на сервере пользователя, соответствующего
    // текущей записи
    procedure CreateIBUser;

    // удаляет на сервере пользователя, соответствующего
    // текущей записи
    procedure DeleteIBUser;

    // данная процедура пересоздает список пользователей на сервере
    // интербейз
    procedure ReCreateAllUsers;

    // для вывода списка пользователей
    // определяем два подмножества: Все и ПоГруппе
    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    // функция проверяет наличие на сервере указанного пользователя
    class function CheckIBUser(const AUser, APassw: String): Boolean; overload;

    //
    class procedure GetClassImage(const ASizeX, ASizeY: Integer; AGraphic: TGraphic); override;

    class function Class_TestUserRights(const SS: TgdcTableInfos;
      const ST: String): Boolean; override;

    // поскольку мы имеем определенные трудности с передачей
    // значений в УДФ функцию через параметры запроса мы вводим
    // это свойство. Если надо получить подмножество пользователей
    // ограниченное по группам, то СабСет устанавливается в БайЮзерГроуп
    // далее свойству Гроупс присваивается битовый набор групп, куда
    // ДОЛЖНЫ входить пользователи и открывается датасет.
    // Если СабСет не равен БайЮзерГроуп, то данное свойство не имеет смысла.
    property Groups: Integer read GetGroups write SetGroups;

    procedure CopySettings(ibtr: TIBTransaction);
    procedure CopySettingsByUser(U: Integer; ibtr: TIBTRansaction);
  end;

  TgdcUserGroup = class(TgdcBase)
  private
    FMask: Integer;

    procedure SetMask(const Value: Integer);

  protected
    function GetSelectClause: String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGroupClause: String; override;
    function GetOrderClause: String; override;

    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

    // удаление группы требует выполнения следующей операции:
    // пройтись по всем таблицам в базе и, если в конкретной
    // таблице есть колонки с дескрипторами безопасности, -- снять
    // бит для удаляемой группы. Таким образом мы избегаем ситуации,
    // когда очередная созданная группа, которой будет присвоен номер ранее
    // существоващей группы, но затем удаленной, получит права на записи
    // которые имела та группа.
    //procedure DeleteGroup;

    //
    //procedure CustomDelete(Buff: Pointer); override;

    procedure CustomInsert(Buff: Pointer); override;
    function CheckTheSameStatement: String; override;

  public
    constructor Create(AnOwner: TComponent); override;

    // добавить пользователя, заданного идентификатором в группу
    procedure AddUser(const AnID: Integer); overload;
    procedure AddUser(AUser: TgdcUser); overload;

    //
    procedure RemoveUser(const AnID: Integer); overload;
    procedure RemoveUser(AUser: TgdcUser); overload;

    function GetGroupMask: Integer; overload;

    // количество групп ограничено в нашей системе числом бит -- 32
    // данная функция находит доступный номер группы в диапазоне
    // 7--32 (номера 1-6 заняты под системные группы) и возвращает этот
    // номер. Если свободных номеров нет, выдает исключение.
    // Increment в данном случае не играет роли.
    function GetNextID(const Increment: Boolean = True;
      const ResetCache: Boolean = False): Integer; override;

    //
    property Mask: Integer read FMask write SetMask;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    //
    class function GetGroupMask(const AGroupID: Integer): Integer; overload;
    class function GetGroupList(const AMask: Integer): String;

    // для вывода списка пользователей
    // определяем подмножества: Все, ДляПользователя
    // и ПоМаске (последнее требует задания битовой маски набора групп)
    class function GetSubSetList: String; override;

    //
    class procedure GetClassImage(const ASizeX, ASizeY: Integer; AGraphic: TGraphic); override;

    class function Class_TestUserRights(const SS: TgdcTableInfos;
      const ST: String): Boolean; override;
  end;

procedure Register;

implementation

uses
  Windows,                    IBSQL,                      IBServices,
  DBConsts,                   DBLogDlg,                   Controls,
  SysUtils,                   jclStrings,                 gdc_frmUser_unit,
  gdc_frmUserGroup_unit,      gdc_dlgUser_unit,           gdc_dlgUserGroup_unit,
  gdc_dlgAddUserToGroup_unit, gdc_dlgAddGroupToUser_unit, gd_security,
  gd_directories_const,       gd_ClassList,               dmImages_unit,
  Storages,                   gsStorage,                  gdcStorage_Types,
  at_frmIBUserList,           IB,                         IBErrorCodes
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Register;
begin
  RegisterComponents('gdc', [
    TgdcUser,
    TgdcUserGroup
  ]);
end;

{ TgdcUser }

function TgdcUser.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  I: Integer;
begin
  Result := True;

  if CD^.ClassName = 'TgdcUserGroup' then
  begin
    for I := 0 to CD^.ObjectCount - 1 do
      with TgdcUserGroup.CreateSingularByID(Self,
        Database, Transaction,
        CD^.ObjectArr[I].ID) as TgdcUserGroup do
      try
        AddUser(Self.ID);
      finally
        Free;
      end;
  end else if (CD^.ClassName = 'TgdcBaseContact') and (CD^.Obj.SubType = '2') then
  begin
    if not (State in dsEditModes) then
      Edit;
    FieldByName('contactkey').AsInteger := CD^.ObjectArr[0].ID;
    Post;
  end else
    Result := False;
end;

function TgdcUser.CheckIBUser: Boolean;
var
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Assert(Active and (not EOF));
  Result := CheckIBUser(FieldByName('ibname').AsString, FieldByName('ibpassw').AsString);

  if Result and Assigned(gdcBaseManager) and Assigned(IBLogin) and IBLogin.IsIBUserAdmin then
  begin
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q.SQL.Text := 'SELECT * FROM rdb$user_privileges WHERE rdb$privilege=''M'' ' +
        'AND rdb$relation_name=''ADMINISTRATOR'' AND rdb$user=''' + FieldByName('ibname').AsString + '''';
      q.ExecQuery;

      if q.EOF then
      begin
        q.Close;
        q.SQL.Text := 'GRANT administrator TO ' + FieldByName('ibname').AsString +
          ' WITH ADMIN OPTION';
        q.ExecQuery;
      end;

      q.Close;
      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;
end;

class function TgdcUser.CheckIBUser(const AUser, APassw: String): Boolean;
var
  SysDBAPassw: String;
  IBSS: TIBSecurityService;
begin
  Assert(IBLogin <> nil);

  Result := False;

  CheckSysDBAPassword(SysDBAPassw);
  IBSS := TIBSecurityService.Create(nil);
  try
    IBSS.ServerName := IBLogin.ServerName;
    if IBSS.ServerName > '' then
      IBSS.Protocol := TCP
    else
      IBSS.Protocol := Local;
    IBSS.LoginPrompt := False;
    IBSS.Params.Add('user_name=' + SysDBAUserName);
    IBSS.Params.Add('password=' + SysDBAPassw);
    try
      IBSS.Active := True;
      try
        IBSS.UserName := AUser;
        IBSS.DisplayUser(IBSS.UserName);
        Result := IBSS.UserInfoCount > 0;
      finally
        IBSS.Active := False;
      end;
    except
      MessageBox(0,
        'Невозможно получить доступ к учетной записи пользователя.'#13#10 +
        'Возможно пароль администратора базы данных введен неверно.',
        'Ошибка',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
      Abort;
    end;
  finally
    IBSS.Free;
  end;
end;

class procedure TgdcUser.CheckSysDBAPassword(var ASysDBAPassword: String);
var
  UserName: String;
begin
  if (ASysDBAPassword = '') and (IBLogin <> nil) then
    if IBLogin.IsIBUserAdmin then
      ASysDBAPassword := IBLogin.IBPassword
    else begin
      MessageBox(0,
        'Для получения или изменения информации об учетной записи пользователя '#13#10 +
        'на сервере необходимо ввести пароль администратора базы данных (SYSDBA).'#13#10 +
        ''#13#10 +
        'Введите его в следующем диалоговом окне.',
        'Учетная запись',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
      UserName := SysDBAUserName;
      if not LoginDialogEx(IBLogin.ServerName, UserName, ASysDBAPassword, True) then
        ASysDBAPassword := '';
    end;
end;

procedure TgdcUser.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCUSER', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('contactkey').Required := True;
  FieldByName('contactname').Required := False;
  FieldByName('contactname').ReadOnly := True;
  FieldByName('phone').Required := False;
  FieldByName('ibname').Required := False;
  FieldByName('ibpassword').Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcUser.CreateIBUser;
begin
  if Active and ((State = dsInsert) or (not EOF)) then
  begin
    try
      if not IBLogin.IsEmbeddedServer then
      begin
        ExecSingleQuery(
          'CREATE USER ' + FieldByName('ibname').AsString +
          ' PASSWORD ''' + FieldByName('ibpassword').AsString + '''');
      end;

      ExecSingleQuery(
        'GRANT administrator TO ' + FieldByName('ibname').AsString +
        ' WITH ADMIN OPTION ');
    except
      on E: EIBError do
      begin
        // подавляем исключение, если пользователь
        // с таким именем уже существует
        if E.IBErrorCode <> isc_gsec_err_rec_not_found then
          raise;
      end;
    end;
  end;
end;

procedure TgdcUser.DeleteIBUser;
begin
  if Active and (not EOF) and (not IBLogin.IsEmbeddedServer) then
  begin
    try
      ExecSingleQuery('DROP USER ' + FieldByName('ibname').AsString);
    except
      on E: EIBError do
      begin
        // подавляем исключение, если пользователя
        // с таким именем не существует
        if E.IBErrorCode <> isc_gsec_err_rec_not_found then
          raise;
      end;
    end;
  end;
end;

function TgdcUser.GetRandomString: String;
var
  I, Pr, C: Integer;
  q: TIBSQL;
begin
  q := TIBSQL.Create(Self);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;

    SetLength(Result, 8);
    repeat
      Pr := -1;
      for I := 1 to 8 do
      begin
        repeat
          C := Random(36);
        until (C <> Pr) and ((I > 1) or (C < 26));
        Pr := C;
        if C > 25 then
          Result[I] := Chr(Ord('0') + C - 26)
        else
          Result[I] := Chr(Ord('A') + C);
      end;

      q.Close;
      q.SQL.Text := 'SELECT id FROM gd_user WHERE ibname=''' + Result + '''' +
        ' OR ibpassword=''' + Result + '''';
      q.ExecQuery;
    until q.EOF;
  finally
    q.Free;
  end;
end;

procedure TgdcUser._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCUSER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited _DoOnNewRecord;
  FieldByName('lockedout').AsInteger := 0;
  FieldByName('mustchange').AsInteger := 0;
  FieldByName('passwneverexp').AsInteger := 1;
  FieldByName('cantchangepassw').AsInteger := 1;
  FieldByName('allowaudit').AsInteger := 0;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcUser.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCUSER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM gd_user z JOIN gd_contact c ON z.contactkey=c.id ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcUser.GetGroups: Integer;
begin
  Assert(HasSubSet('ByUserGroup'));
  Result := FGroups;
end;

class function TgdcUser.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcUser.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_USER';
end;

function TgdcUser.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCUSER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if sView in BaseState then
    Result := ' '
  else
    Result := 'ORDER BY z.name ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcUser.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCUSER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT ' +
    '  z.id,' +
    '  z.name,' +
    '  z.passw,' +
    '  z.ingroup,' +
    '  z.fullname,' +
    '  z.description,' +
    '  z.ibname,' +
    '  z.ibpassword,' +
    '  z.contactkey,' +
    '  z.externalkey,' +
    '  z.disabled,' +
    '  z.lockedout,' +
    '  z.mustchange,' +
    '  z.cantchangepassw,' +
    '  z.passwneverexp,' +
    '  z.expdate,' +
    '  z.workstart,' +
    '  z.workend,' +
    '  z.allowaudit,' +
    '  z.editiondate,' +
    '  z.editorkey,' +
    '  z.icon,' +
    '  z.reserved,' +
    '  c.name AS contactname,' +
    '  c.phone' +
    ' ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcUser.ReCreateAllUsers;
var
  Bm: TBookmarkStr;
  U, P: String;
begin
  CheckBrowseMode;
  DisableControls;
  Bm := Bookmark;
  try
    First;
    while not EOF do
    begin
      if FieldByName('ibname').AsString <> SysDBAUserName then
      begin
        DeleteIBUser;
        Randomize;
        repeat
          U := GetRandomString;
          P := GetRandomString;
        until not CheckIBUser(U, P);
        Edit;
        FieldByName('ibname').AsString := U;
        FieldByName('ibpassword').AsString := P;
        Post;
        CreateIBUser;
      end;
      Next;
    end;
  finally
    Bookmark := Bm;
    EnableControls;
  end;
end;

procedure TgdcUser.SetGroups(const Value: Integer);
begin
  Assert(HasSubSet('ByUserGroup'));
  if FGroups <> Value then
  begin
    if not (csLoading in ComponentState) then
      Close;
    FGroups := Value;
    FSQLInitialized := False;
  end;
end;

procedure TgdcUser.SyncField(Field: TField);
var
  q: TIBSQL;
begin
  inherited;

  if State in dsEditModes then
  begin
    if AnsiCompareText(Field.FieldName, 'contactkey') = 0 then
    begin
      if Field.AsString = '' then
        FieldByName('phone').Clear
      else
      begin
        q := TIBSQL.Create(nil);
        try
          q.Transaction := ReadTransaction;
          q.SQL.Text := 'SELECT phone FROM gd_contact WHERE id=:ID';
          q.ParamByName('id').AsInteger := Field.AsInteger;
          q.ExecQuery;
          if q.EOF or q.Fields[0].IsNull then
            FieldByName('phone').Clear
          else
            FieldByName('phone').AsString := q.Fields[0].AsString;
        finally
          q.Free;
        end;
      end;
    end;
  end;  
end;

function TgdcUser.GetCustomProcess: TgsCustomProcesses;
begin
  if FieldChanged('phone') then
    Result := [cpInsert, cpModify, cpDelete]
  else
    Result := [cpInsert, cpDelete];  
end;

procedure TgdcUser.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCUSER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if FieldChanged('phone') then
    CustomExecQuery('UPDATE gd_contact SET phone=:NEW_PHONE WHERE id=:NEW_CONTACTKEY ', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

function TgdcUser.CheckUser(const AUserName: String): Boolean;
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := ReadTransaction;

    q.SQL.Text := 'SELECT id FROM gd_user WHERE UPPER(TRIM(name))=:N ';
    q.ParamByName('N').AsString := Trim(AnsiUpperCase(AUserName));
    q.ExecQuery;

    Result := not q.EOF;
  finally
    q.Free;
  end;
end;

function TgdcUser.HideFieldsList: String;
begin
  Result := inherited HideFieldsList + 'passw;ibname;ibpassword;';
end;

class function TgdcUser.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByUserGroup;';
end;

procedure TgdcUser.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByUserGroup') then
    S.Add(Format('BIN_AND(z.ingroup, %d) <> 0', [FGroups]));
end;

procedure TgdcUser.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCUSER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  CreateIBUser;
  ExecSingleQuery(
    'INSERT INTO gd_usercompany(userkey, companykey) VALUES (' +
      IntToStr(Self.ID) + ',' +
      IntToStr(IBLogin.CompanyKey) + ') ');
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcUser.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCUSER', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if Assigned(IBLogin) and (IBLogin.UserKey = ID) then
  begin
    MessageBox(0,
      'Нельзя удалить текущего пользователя!',
      'Внимание',
      MB_OK or MB_ICONSTOP or MB_TASKMODAL);
    Abort;
  end;

  inherited;

  DeleteIBUser;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

class function TgdcUser.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmUser';
end;

class procedure TgdcUser.GetClassImage(const ASizeX, ASizeY: Integer;
  AGraphic: TGraphic);
begin
  if (ASizeX = 16) and (ASizeY = 16) and (AGraphic is Graphics.TBitmap) then
    dmImages.il16x16.GetBitmap(34, Graphics.TBitmap(AGraphic))
  else
    inherited;
end;

function TgdcUser.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCUSER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(name) = ''%s''',
      [GetKeyField(SubType), GetListTable(SubType),
       AnsiUpperCase(FieldByName('name').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcUser.CopySettings(ibtr: TIBTRansaction);
var
  U: Integer;
begin
  U := SelectObject;
  if (U <> -1) and (U <> ID) then
  begin
    CopySettingsByUser(U, ibtr);
  end;
end;

procedure TgdcUser.CopySettingsByUser(U: Integer; ibtr: TIBTransaction);
var
  DidActivate: Boolean;
  SelfTr: TIBTransaction;
  q: TIBSQL;
  US: TgsUserStorage;
  MS: TMemoryStream;
begin
  if ID = U then
    exit;

  if Assigned(ibtr) then
    SelfTr := ibtr
  else
    SelfTr := Transaction;

  MS := TMemoryStream.Create;
  try
    DidActivate := False;
    try
      DidActivate := not SelfTr.InTransaction;
      if DidActivate then
        SelfTr.StartTransaction;

      if UserStorage.ObjectKey = U then
        UserStorage.SaveToStream(MS)
      else begin
        US := TgsUserStorage.Create;
        try
          US.ObjectKey := U;
          US.SaveToStream(MS);
        finally
          US.Free;
        end;
      end;

      MS.Position := 0;

      q := TIBSQL.Create(nil);
      try
        q.Transaction := SelfTr;

        q.SQL.Text := 'DELETE FROM gd_storage_data WHERE parent IS NULL ' +
          'AND data_type = :DT AND int_data = :ID';
        q.ParamByName('DT').AsString := cStorageUser;
        q.ParamByName('ID').AsInteger := ID;
        q.ExecQuery;

        if UserStorage.ObjectKey = ID then
        begin
          UserStorage.LoadFromStream(MS);
          UserStorage.SaveToDataBase;
        end else
        begin
          US := TgsUserStorage.Create;
          try
            US.ObjectKey := ID;
            US.LoadFromStream(MS);
            US.SaveToDatabase(SelfTr);
          finally
            US.Free;
          end;
        end;

        q.SQL.Text :=
          'DELETE FROM gd_desktop WHERE userkey=:TK AND name IN ' +
          '(SELECT name FROM gd_desktop WHERE userkey=:FK) ';
        q.ParamByName('FK').AsInteger := U;
        q.ParamByName('TK').AsInteger := ID;
        q.ExecQuery;

        q.SQL.Text :=
          'INSERT INTO gd_desktop (userkey, screenres, name, saved, dtdata, reserved) ' +
          'SELECT ' + IntToStr(ID) + ', screenres, name, saved, dtdata, reserved FROM gd_desktop WHERE userkey=:FK';
        q.ParamByName('FK').AsInteger := U;
        q.ExecQuery;
      finally
        q.Free;
      end;

      if DidActivate and SelfTr.InTransaction then
        SelfTr.Commit;
    except
      if DidActivate and SelfTr.InTransaction then
        SelfTr.Rollback;
      raise;  
    end;
  finally
    MS.Free;
  end;
end;

procedure TgdcUser.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  UserID: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCUSER', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Assert(UserStorage <> nil);
  inherited;
  if Process = cpInsert then
  begin
    if (not (sLoadFromStream in BaseState))
      and (sView in BaseState) then
    begin
      if (sDialog in BaseState) and (MessageBox(ParentHandle,
        'Скопировать для нового пользователя профиль уже существующего пользователя?',
        'Создание пользователя',
        MB_TASKMODAL or MB_ICONQUESTION or MB_YESNO) = IDYES)
      then
      begin
        UserID := SelectObject;
        if UserID > 0 then
          Self.CopySettingsByUser(UserID, Transaction);
      end;
    end;
  end
  else if Process = cpModify then
  begin
    if (IBLogin.UserKey = Self.ID)
      and (IBLogin.InGroup <> Self.FieldByName('ingroup').AsInteger) then
    begin
      IBLogin.InGroup := Self.FieldByName('ingroup').AsInteger;
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcUser.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCUSER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if ((dsInsert = State) and CheckUser(FieldByName('name').AsString)) then
  begin
    FieldByName('name').FocusControl;
    DatabaseErrorFmt('Пользователь с именем "%s" уже существует.', [FieldByName('name').AsString]);
  end;

  if FieldByName('ingroup').AsInteger = 0 then
  begin
    raise EgdcException.CreateObj('Пользователь не включен ни в одну группу.', Self);
  end;

  if State = dsInsert then
  begin
    Randomize;
    with FieldByName('ibname') do
      AsString := GetRandomString;
    with FieldByName('ibpassword') do
      AsString := GetRandomString;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

function TgdcUser.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCUSER', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSER', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSER',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSER' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField + ',passw,ibname,ibpassword';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSER', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSER', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}
end;

class function TgdcUser.Class_TestUserRights(const SS: TgdcTableInfos;
  const ST: String): Boolean;
begin
  Result := inherited Class_TestUserRights(SS, ST);
  if Result and ((SS * [tiAChag, tiAFull]) <> []) then
    Result := Assigned(IBLogin) and IBLogin.IsIBUserAdmin;
end;

class function TgdcUser.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgUser';
end;

{ TgdcUserGroup }

function TgdcUserGroup.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var                          
  I: Integer;
begin
  Result := False;

  if CD^.ClassName <> 'TgdcUser' then
    exit;
                                                               
// если пустой набор (допустим, отфильтрован), то GetGroupMask кидает Assertion -  Assert(AGroupID in [1..32], 'Invalid group ID specified. Must be between 1 and 32.');
  for I := 0 to CD^.ObjectCount - 1 do
    AddUser(CD^.ObjectArr[I].ID);

  Result := True;
end;

procedure TgdcUserGroup.AddUser(const AnID: Integer);
begin
  ExecSingleQuery(Format(
      'UPDATE gd_user SET ingroup=BIN_OR(ingroup, %d) WHERE id=%d',
      [GetGroupMask(ID), AnID]));
  FDSModified := True;

  if Assigned(IBLogin) and (IBLogin.UserKey = AnId) then
    IBLogin.Ingroup := IBLogin.InGroup or GetGroupMask(ID);

  if HasSubSet('ByUser') then
    CloseOpen;
end;

procedure TgdcUserGroup.AddUser(AUser: TgdcUser);
begin
  Assert(AUser.State in dsEditModes);
  AUser.FieldByName('ingroup').AsInteger :=
    AUser.FieldByName('ingroup').AsInteger or GetGroupMask(ID);

  if Assigned(IBLogin) and (IBLogin.UserKey = AUser.FieldByName('ID').AsInteger) then
    IBLogin.Ingroup := AUser.FieldByName('ingroup').AsInteger;

end;

function TgdcUserGroup.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCUSERGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERGROUP', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERGROUP' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if FieldByName(GetKeyField(SubType)).AsInteger < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result := Format('SELECT %s FROM %s WHERE UPPER(name) = ''%s''',
      [GetKeyField(SubType), GetListTable(SubType),
       AnsiUpperCase(FieldByName('name').AsString)]);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERGROUP', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcUserGroup.Class_TestUserRights(const SS: TgdcTableInfos;
  const ST: String): Boolean;
begin
  Result := inherited Class_TestUserRights(SS, ST);
  if Result and ((SS * [tiAChag, tiAFull]) <> []) then
    Result := Assigned(IBLogin) and IBLogin.IsUserAdmin;
end;

constructor TgdcUserGroup.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  CustomProcess := [cpDelete];
end;

(*
procedure TgdcUserGroup.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCUSERGROUP', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERGROUP', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERGROUP',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERGROUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  DeleteGroup;
  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERGROUP', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERGROUP', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcUserGroup.DeleteGroup;
var
  q, qu: TIBSQL;
  Mask: Integer;
  S: String;
  DidActivate: Boolean;
  OldCursor: TCursor;
begin
  if sView in BaseState then
  try
    if frmIBUserList = nil then
      frmIBUserList := TfrmIBUserList.Create(nil);

    if not frmIBUserList.CheckUsers then
    begin
      if MessageBox(ParentHandle,
        PChar('Рекомендуется производить удаление группы только тогда,'#13#10 +
        'когда к базе данных не подключены другие пользователи.'#13#10#13#10 +
        'Удаление может занять продолжительное время. Продолжать?'),
        'Внимание',
        MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then
      begin
        Abort;
      end;
    end;
  finally
    FreeAndNil(frmIBUserList);
  end;

  Mask := (not GetGroupMask(ID)) or 1;

  OldCursor := Screen.Cursor;
  Screen.Cursor := crSQLWait;

  DidActivate := False;
  q := TIBSQL.Create(Self);
  qu := TIBSQL.Create(Self);
  try
    q.Transaction := ReadTransaction;
    qu.Transaction := Transaction;

    DidActivate := ActivateTransaction;

    // получаем список всех таблиц в базе данных у которых
    // присутствует хотябы один из дескрипторов безопасности
    q.SQL.Text := 'SELECT * FROM gd_p_gettableswithdescriptors ';

    q.ExecQuery;
    while not q.EOF do
    begin
      S := 'UPDATE ' + q.FieldByName('relationname').AsTrimString + ' SET ';
      if q.FieldByName('aview').AsInteger = 1 then
        S := Format('%s AVIEW=BIN_AND(AVIEW, %d),', [S, Mask]);
      if q.FieldByName('achag').AsInteger = 1 then
        S := Format('%s ACHAG=BIN_AND(ACHAG, %d),', [S, Mask]);
      if q.FieldByName('afull').AsInteger = 1 then
        S := Format('%s AFULL=BIN_AND(AFULL, %d)', [S, Mask]);
      if S[Length(S)] = ',' then SetLength(S, Length(S) - 1);
      S := S + ' WHERE ';
      if q.FieldByName('aview').AsInteger = 1 then
        S := Format('%s BIN_AND(AVIEW, %d) <> 0 OR', [S, GetGroupMask(ID)]);
      if q.FieldByName('achag').AsInteger = 1 then
        S := Format('%s BIN_AND(ACHAG, %d) <> 0 OR', [S, GetGroupMask(ID)]);
      if q.FieldByName('afull').AsInteger = 1 then
        S := Format('%s BIN_AND(AFULL, %d) <> 0', [S, GetGroupMask(ID)]);
      if S[Length(S)] <> '0' then SetLength(S, Length(S) - 2);

      qu.SQL.Text := S;
      qu.ExecQuery;

      q.Next;
    end;
  finally
    q.Free;
    qu.Free;

    if DidActivate then
      Transaction.Commit;

    Screen.Cursor := OldCursor;
  end;
end;
*)

procedure TgdcUserGroup.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  S, M: String;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCUSERGROUP', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERGROUP', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERGROUP',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERGROUP' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  M := IntToStr(GetGroupMask(ID));
  S :=
    'aview=BIN_OR(aview, ' + M + '),' +
    'achag=BIN_OR(achag, ' + M + '),' +
    'afull=BIN_OR(afull, ' + M + ')';
  ExecSingleQuery('UPDATE gd_command SET ' + S + ' WHERE id IN (740000, 740920)');
  ExecSingleQuery('UPDATE gd_contact SET ' + S + ' WHERE id = ' + IntToStr(IBLogin.CompanyKey));
  ExecSingleQuery('UPDATE gd_ourcompany SET ' + S + ' WHERE companykey = ' + IntToStr(IBLogin.CompanyKey));

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERGROUP', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERGROUP', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

class procedure TgdcUserGroup.GetClassImage(const ASizeX, ASizeY: Integer;
  AGraphic: TGraphic);
begin
  if (ASizeX = 16) and (ASizeY = 16) and (AGraphic is Graphics.TBitmap) then
    dmImages.il16x16.GetBitMap(35, Graphics.TBitmap(AGraphic));
end;

class function TgdcUserGroup.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgUserGroup';
end;

function TgdcUserGroup.GetGroupClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCUSERGROUP', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERGROUP', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERGROUP',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERGROUP' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERGROUP', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERGROUP', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcUserGroup.GetGroupList(const AMask: Integer): String;
var
  V: OleVariant;
  I: Integer;
begin
  Result := '';
  gdcBaseManager.ExecSingleQueryResult('SELECT id, name FROM gd_usergroup ORDER BY id',
    0, V);
  for I := VarArrayLowBound(V, 2) to VarArrayHighBound(V, 2) do
  begin
    if (GetGroupMask(V[0, I]) and AMask) <> 0 then
    begin
      Result := Result + V[1, I] + ', ';
    end;
  end;
  if Length(Result) > 2 then
    SetLength(Result, Length(Result) - 2);
end;

class function TgdcUserGroup.GetGroupMask(
  const AGroupID: Integer): Integer;
begin
  Assert(AGroupID in [1..32], 'Invalid group ID specified. Must be between 1 and 32.');
  Result := 1 shl (AGroupID - 1);
end;

function TgdcUserGroup.GetGroupMask: Integer;
begin
  Result := GetGroupMask(ID);
end;

class function TgdcUserGroup.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcUserGroup.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_USERGROUP';
end;

function TgdcUserGroup.GetNextID(const Increment: Boolean = True;
  const ResetCache: Boolean = False): Integer;
var
  q: TIBSQL;
begin
  Result := -1;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := ReadTransaction;
    q.SQL.Text :=
      'select '#13#10 +
      '  first 1 e.n '#13#10 +
      'from '#13#10 +
      '  gd_usergroup g right join ( '#13#10 +
      '    with recursive enum as ( '#13#10 +
      '      select 7 as n from rdb$database '#13#10 +
      '      union all '#13#10 +
      '      select (e.n + 1) as n from enum e '#13#10 +
      '      where e.n < 32 '#13#10 +
      '      ) '#13#10 +
      '    select '#13#10 +
      '      n '#13#10 +
      '    from '#13#10 +
      '      enum) e on e.n = g.id '#13#10 +
      'where '#13#10 +
      '  g.id is null '#13#10 +
      'order by '#13#10 +
      '  1';
    q.ExecQuery;
    if q.EOF then
      raise Exception.Create('Достигнут лимит количества групп пользователей');
    Result := q.Fields[0].AsInteger;
  finally
    q.Free;
  end;
end;

function TgdcUserGroup.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCUSERGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERGROUP', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERGROUP',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERGROUP' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if sView in BaseState then
    Result := ' '
  else
    Result := 'ORDER BY z.name ';  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcUserGroup.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCUSERGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCUSERGROUP', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCUSERGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCUSERGROUP',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCUSERGROUP' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'SELECT ' +
    '  z.id,' +
    '  z.name,' +
    '  z.description,' +
    '  z.icon,' +
    '  z.disabled,' +
    '  z.reserved' +
    ' ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCUSERGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCUSERGROUP', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcUserGroup.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByUser;ByMask;';
end;

class function TgdcUserGroup.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmUserGroup';
end;

procedure TgdcUserGroup.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByUser') then
    S.Add( ' EXISTS(SELECT * FROM gd_user u WHERE u.id=:USERID AND ' +
      '(BIN_AND(u.ingroup, BIN_SHL(1, z.id - 1)) <> 0) ) ')
  else if HasSubSet('ByMask') then
    S.Add(Format('WHERE BIN_AND(%d, BIN_SHL(1, z.id - 1)) <> 0 ', [FMask]));
end;

procedure TgdcUserGroup.RemoveUser(const AnID: Integer);
var
  R: OleVariant;
begin
  if (GetGroupMask(ID) = 1) and (AnID = ADMIN_KEY) then
    raise Exception.Create('Нельзя удалить учетную запись Administrator из группы Администраторы.');

  if (GetGroupMask(ID) = 1) and (AnID = IBLogin.UserKey) then
    raise Exception.Create('Нельзя исключить из группы Администраторы текущего пользователя.');

  ExecSingleQueryResult(Format(
      'SELECT BIN_AND(ingroup, %d) FROM gd_user WHERE id=%d',
      [not GetGroupMask(ID), AnID]), varNull, R);

  if VarIsEmpty(R) or (R[0, 0] <> 0) then
  begin
    ExecSingleQuery(Format(
        'UPDATE gd_user SET ingroup=BIN_AND(ingroup, %d) WHERE id=%d',
        [not GetGroupMask(ID), AnID]));

    if Assigned(IBLogin) and (IBLogin.UserKey = AnId) then
      IBLogin.Ingroup := IBLogin.InGroup and (not GetGroupMask(ID));

    FDSModified := True;
    if HasSubSet('ByUser') then
      CloseOpen;
  end else
  begin
    if MessageBox(ParentHandle,
      'Пользователь должен входить хотя бы в одну группу.'#13#10 +
      'Включить пользователя в группу "Пользователи"?',
      'Внимание',
      MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = IDYES then
    begin
      ExecSingleQuery(Format(
          'UPDATE gd_user SET ingroup=%d WHERE id=%d',
          [GD_UG_USERS, AnID]));

      if Assigned(IBLogin) and (IBLogin.UserKey = AnId) then
        IBLogin.Ingroup := GD_UG_USERS;

      FDSModified := True;
      if HasSubSet('ByUser') then
        CloseOpen;
    end;
  end;
end;

procedure TgdcUserGroup.RemoveUser(AUser: TgdcUser);
begin
  Assert(AUser.State in dsEditModes);

  if (GetGroupMask(ID) = 1) and (AUser.ID = ADMIN_KEY) then
    raise Exception.Create('Нельзя удалить учетную запись Администратор из группы Администраторы.');

  if (GetGroupMask(ID) = 1) and (AUser.ID = IBLogin.UserKey) then
    raise Exception.Create('Нельзя исключить из группы Администраторы текущего пользователя.');

  AUser.FieldByName('ingroup').AsInteger :=
    AUser.FieldByName('ingroup').AsInteger and (not GetGroupMask(ID));

  if Assigned(IBLogin) and (IBLogin.UserKey = AUser.FieldByName('ID').AsInteger) then
    IBLogin.Ingroup := AUser.FieldByName('ingroup').AsInteger;
end;

procedure TgdcUserGroup.SetMask(const Value: Integer);
begin
  Assert(HasSubSet('ByMask'));
  if FMask <> Value then
  begin
    if not (csLoading in ComponentState) then
      Close;
    FMask := Value;
    FSQLInitialized := False;
  end;
end;

initialization
  RegisterGDCClasses([TgdcUser, TgdcUserGroup]);

finalization
  UnRegisterGDCClasses([TgdcUser, TgdcUserGroup]);
end.
