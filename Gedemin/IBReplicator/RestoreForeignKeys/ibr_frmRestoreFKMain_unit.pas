unit ibr_frmRestoreFKMain_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPEdit, StdCtrls, XPComboBox, ExtCtrls, XPButton, jpeg, ibr_DBRegistrar_unit,
  ComCtrls, ActnList, ImgList, XPListView, IBDatabase, ibr_BaseTypes_unit, Contnrs,
  IBDatabaseInfo, Registry, ibr_Const, DateUtils, IBSQL;

type
  TProgressAction = (paBefore, paSucces, paError);

  TRestoreProcess = class
  protected
    FCount: Integer;
    FMaxMinor: Integer;
    procedure SetMaxMinor(const Value: Integer);
  public
    property MaxMinor: Integer read FMaxMinor write SetMaxMinor;
    procedure MinorProgress(Sender: TObject);
    procedure Log(S: string);
  end;

  //Список отключаемых внешних ссылок
  TrpForeignKey = class
  private
    FDropped: Boolean;
    FConstraintName: string;
    FTableName: string;
    FDeleteRule: string;
    FOnFieldName: string;
    FFieldName: string;
    FOnTableName: string;
    FUpdateRule: string;
    procedure SetConstraintName(const Value: string);
    procedure SetDeleteRule(const Value: string);
    procedure SetDropped(const Value: Boolean);
    procedure SetFieldName(const Value: string);
    procedure SetOnFieldName(const Value: string);
    procedure SetOnTableName(const Value: string);
    procedure SetTableName(const Value: string);
    procedure SetUpdateRule(const Value: string);
  public
    //Функции возвращают слк для добавления и удаления внешнего ключа
    function AddDLL: string;
    function DropDLL: string;
    function DelDLL: string;
    function SetNullDLL: string;
    //Чтение из переданного ИБСКЛ
    procedure Read(SQL: TIBSQL);
    //Функции чтения и записи в поток
    procedure SaveToStream(Stream: TStream);
    procedure ReadFromStream(Stream: TStream);

    property TableName: string read FTableName write SetTableName;
    property ConstraintName: string read FConstraintName write SetConstraintName;
    property FieldName: string read FFieldName write SetFieldName;
    property OnTableName: string read FOnTableName write SetOnTableName;
    property OnFieldName: string read FOnFieldName write SetOnFieldName;
    property DeleteRule: string read FDeleteRule write SetDeleteRule;
    property UpdateRule: string read FUpdateRule write SetUpdateRule;
    property Dropped: Boolean read FDropped write SetDropped;
  end;

  TrpForeignKeys = class(TObjectList)
  private
    function GetForeignKeys(Index: Integer): TrpForeignKey;
  protected
  public
    procedure SaveToStream(Stream: TStream);
    procedure SaveDroppedToStream(Stream: TStream);
    procedure ReadFromStream(Stream: TStream);
    function  LoadFromTextFile(AFileName: string): boolean;
    procedure AddKeys;
    procedure RestoreKeys;

    property ForeignKeys[Index: Integer]: TrpForeignKey read GetForeignKeys;
  end;

  TfrmRestoreFKMain = class(TForm)
    imgWall: TImage;
    bExit: TXPButton;
    Label1: TLabel;
    il16x16: TImageList;
    OpenDialog: TOpenDialog;
    ActionList: TActionList;
    actExit: TAction;
    actNext: TAction;
    actPrev: TAction;
    actTestConect: TAction;
    actDBOpen: TAction;
    bPrev: TXPButton;
    bNext: TXPButton;
    PageControl: TPageControl;
    tsConnect: TTabSheet;
    tsRestoreFK: TTabSheet;
    Bevel1: TBevel;
    Label10: TLabel;
    cbDBRegisterList: TXPComboBox;
    Bevel3: TBevel;
    Label2: TLabel;
    cbServerName: TXPComboBox;
    Label3: TLabel;
    cbProtocol: TXPComboBox;
    Label4: TLabel;
    cePath: TXPEdit;
    XPButton1: TXPButton;
    cbCharSet: TXPComboBox;
    Label28: TLabel;
    eUser: TXPEdit;
    Label6: TLabel;
    Label8: TLabel;
    ePassword: TXPEdit;
    Bevel2: TBevel;
    tsUserList: TTabSheet;
    tsReport: TTabSheet;
    Bevel18: TBevel;
    lvUser: TXPListView;
    mUserList: TMemo;
    DatabaseInfo: TIBDatabaseInfo;
    Bevel14: TBevel;
    lLog: TLabel;
    mLog: TXPMemo;
    Label11: TLabel;
    pbRPLProgress: TProgressBar;
    Bevel12: TBevel;
    mReport: TMemo;
    lblReport: TLabel;
    tsLoadFK: TTabSheet;
    Bevel4: TBevel;
    mFile: TXPMemo;
    edtFileName: TXPEdit;
    XPButton11: TXPButton;
    Label15: TLabel;
    actLoadFile: TAction;
    tOpenFile: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbDBRegisterListDropDown(Sender: TObject);
    procedure cbDBRegisterListChange(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actDBOpenExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actLoadFileExecute(Sender: TObject);
    procedure tOpenFileTimer(Sender: TObject);
    procedure edtFileNameChange(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
  private
    FDBRegistrar: TDBRegistrar;
    FKeys: TrpForeignKeys;
    FCanRestore: boolean;
    FReport: TStringList;
    procedure OnDBregistrarLoad(Sender: TObject);
    function  Connect: boolean;
    function  ConnectParams: string;
    function  GetLoadPath: string;
    procedure SetLoadPath(sName: string);
  public
    { Public declarations }
  end;

var
  frmRestoreFKMain: TfrmRestoreFKMain;
  ProgressState: TRestoreProcess;

implementation

{$R *.dfm}

procedure TfrmRestoreFKMain.FormCreate(Sender: TObject);
begin
  FDBRegistrar := TDBRegistrar.Create;
  FDBRegistrar.OnLoad := OnDBregistrarLoad;
  PageControl.ActivePage := tsConnect;
  FKeys:= TrpForeignKeys.Create;
  FReport:= TStringList.Create;
end;

procedure TfrmRestoreFKMain.FormDestroy(Sender: TObject);
begin
  FDBRegistrar.Free;
  FReport.Free;;
end;

procedure TfrmRestoreFKMain.actExitExecute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmRestoreFKMain.OnDBregistrarLoad(Sender: TObject);
begin
  with FDBRegistrar do
  begin
    cbServerName.Text := ServerName;
    cbProtocol.ItemIndex := cbProtocol.Items.IndexOf(Protocol);
    cePath.Text := FileName;
    eUser.Text := User;
    ePassword.Text := Password;
    cbCharSet.ItemIndex := cbCharSet.Items.IndexOf(CharSet);
  end;
end;

procedure TfrmRestoreFKMain.cbDBRegisterListDropDown(Sender: TObject);
begin
  TXPComboBox(Sender).Items.Assign(FDBRegistrar.DBAliasList);
end;

procedure TfrmRestoreFKMain.cbDBRegisterListChange(Sender: TObject);
begin
  FDBRegistrar.Alias := cbDBRegisterList.Text;
end;

procedure TfrmRestoreFKMain.actDBOpenExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    cePath.Text := OpenDialog.FileName;
  end;
end;

procedure TfrmRestoreFKMain.actPrevExecute(Sender: TObject);
begin
  if (PageControl.ActivePage = tsLoadFK) or (PageControl.ActivePage = tsUserList)
      or (PageControl.ActivePage = tsReport) then begin
    PageControl.ActivePage:= tsConnect;
    ReplDataBase.Connected := False;
  end;
end;

procedure TfrmRestoreFKMain.actPrevUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= (PageControl.ActivePage <> tsConnect) and (PageControl.ActivePage <> tsRestoreFK)
end;

procedure TfrmRestoreFKMain.actNextExecute(Sender: TObject);
var
  C: TCursor;
  P: TRestoreProcess;
begin
  C := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if PageControl.ActivePage = tsConnect then begin
      if Connect then begin
        PageControl.ActivePage:= tsLoadFK;
      end;
    end
    else if PageControl.ActivePage = tsLoadFK then begin
      P:= TRestoreProcess.Create;
      ProgressState:= P;
      FReport.Clear;
      mLog.Lines.Clear;
      try
        ProgressState.MaxMinor := FKeys.Count;
        PageControl.ActivePage:= tsRestoreFK;
        FKeys.RestoreKeys;
      finally
        P.Free;
        ProgressState:= nil;
        PageControl.ActivePage:= tsReport;
        if FReport.Count > 0 then begin
          mReport.Lines.Assign(FReport);
          lblReport.Caption:= 'Ошибка при восстановлении внешних ссылок'
        end;
      end;
    end;
  finally
    Screen.Cursor := C;
  end;
end;

procedure TfrmRestoreFKMain.actNextUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled:= (PageControl.ActivePage <> tsReport) and (PageControl.ActivePage <> tsUserList)
    and (((PageControl.ActivePage = tsUserList) and (lvUser.Items.Count <= 1))
    or ((PageControl.ActivePage = tsLoadFK) and FCanRestore)
    or (PageControl.ActivePage = tsConnect));
end;

function TfrmRestoreFKMain.Connect: boolean;
var
  Db: TIBDataBase;
begin
  Result := False;
  if FDBRegistrar.CheckRegisterInfo then
  begin
    DB := ReplDataBase;
    DB.Params.Text := ConnectParams;
    DB.LoginPrompt := False;
    DB.DatabaseName := FDBRegistrar.DataBaseName;
    try
      DB.Connected := True;
    except
      on E: Exception do
        Application.MessageBox(PChar(E.Message),
          PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
    end;
    Result := DB.Connected;
    if Result then
    begin
      ReplDataBase.ServerName := cbServerName.Text;
      ReplDataBase.FileName := cePath.Text;
      ReplDataBase.Protocol := cbProtocol.Text;

      DataBaseInfo.Database:= ReplDataBase;
    end;
  end else
    Application.MessageBox(PChar(FDBRegistrar.CheckRegisterInfoErrorMessage),
      PChar(ConnectionError), MB_OK + MB_APPLMODAL + MB_ICONERROR);
end;

function TfrmRestoreFKMain.ConnectParams: string;
begin
  Result := '';
  Result := 'user_name=' + Trim(eUser.Text) + #10#13'password=' +
    Trim(ePassword.Text) + #10#13'lc_ctype=' + Trim(cbCharSet.Text);
end;

procedure TfrmRestoreFKMain.actLoadFileExecute(Sender: TObject);
var
  O: TOpenDialog;
begin
  O := TOpenDialog.Create(nil);
  try
    O.DefaultExt:= 'txt';
    O.Filter := ReplFileFilter;
    O.FilterIndex := 0;
    O.Options := [ofHideReadOnly, ofNoNetworkButton];
    O.InitialDir:= GetLoadPath;
    if O.Execute then
    begin
      edtFileName.Text:= O.FileName;
    end;
  finally
    O.Free;
  end;
end;

function TfrmRestoreFKMain.GetLoadPath: string;
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then begin
      try
        Result:= R.ReadString(cLoadPath);
      finally
        R.CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

procedure TfrmRestoreFKMain.SetLoadPath(sName: string);
var
  R: TRegistry;
begin
  R := TRegistry.Create;
  try
    if R.OpenKey(RootPath, True) then begin
      try
        R.WriteString(cLoadPath, ExtractFilePath(sName));
      finally
        R.CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

procedure TfrmRestoreFKMain.tOpenFileTimer(Sender: TObject);
var
  i: integer;
begin
  mFile.Lines.Clear;
  if SysUtils.FileExists(edtFileName.Text) then begin
    TTimer(Sender).Enabled := False;
    FCanRestore:= FKeys.LoadFromTextFile(edtFileName.Text);
    if FCanRestore then begin
      SetLoadPath(ExtractFilePath(edtFileName.Text));
      mFile.Lines.Add(Format('%d ссылок для воостановления:', [FKeys.Count]));
      for i:= 0 to FKeys.Count - 1 do begin
        mFile.Lines.Add('   ' + FKeys.ForeignKeys[i].ConstraintName);
      end;
    end;
  end
  else begin
    mFile.Lines.Text:= cFileNotFound;
  end;
end;

procedure TfrmRestoreFKMain.edtFileNameChange(Sender: TObject);
begin
  FCanRestore:= False;
  tOpenFile.Enabled:= True;
end;

{ TFileProcess }

procedure TRestoreProcess.Log(S: string);
begin
  frmRestoreFKMain.mLog.Lines.Add(S);
end;

procedure TRestoreProcess.MinorProgress(Sender: TObject);
var
  Msg: TMsg;
begin
  frmRestoreFKMain.pbRPLProgress.Position :=
    frmRestoreFKMain.pbRPLProgress.Position + 1;
  Inc(FCount);
  if PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE) then
  begin
    Application.ProcessMessages;
  end;
end;

procedure TRestoreProcess.SetMaxMinor(const Value: Integer);
begin
  frmRestoreFKMain.pbRPLProgress.Min := 0;
  frmRestoreFKMain.pbRPLProgress.Max := Value;
  frmRestoreFKMain.pbRPLProgress.Position := 0;
  FCount := 0;
  FMaxMinor := Value;
end;

function TrpForeignKey.AddDLL: string;
var
  lOnUpDate, lOnDelete: string;
begin
  if FUpDateRule <> 'RESTRICT' then
    lOnUpDate := ' ON UPDATE ' + FUpdateRule
  else
    lOnUpDate := '';

  if FDeleteRule <> 'RESTRICT' then
    lOnDelete := ' ON DELETE ' + FDeleteRule
  else
    lOnDelete := '';

  Result := 'ALTER TABLE ' + FTableName + ' ADD CONSTRAINT ' +
    FConstraintName + ' FOREIGN KEY (' + FFieldName + ' )' +
    'REFERENCES ' + FOnTableName + '(' + FOnFieldName + ')' +
    lOnUpDate + lOnDelete;
end;

function TrpForeignKey.DelDLL: string;
begin
  Result:= 'DELETE FROM ' + FTableName + ' tbl ' +
    'WHERE tbl.' + FFieldName + ' IS NOT NULL AND NOT EXISTS (' +
    '  SELECT DISTINCT ref.' + FOnFieldName + ' FROM ' + FOnTableName + ' ref ' +
    '  WHERE ref.' + FOnFieldName + ' = tbl.' + FFieldName + ')'
end;

function TrpForeignKey.SetNullDLL: string;
begin
  Result:= 'UPDATE ' + FTableName + ' tbl ' +
    'SET tbl.' + FFieldName + ' = NULL ' +
    'WHERE tbl.' + FFieldName + ' IS NOT NULL AND NOT EXISTS (' +
    '  SELECT DISTINCT ref.' + FOnFieldName + ' FROM ' + FOnTableName + ' ref ' +
    '  WHERE ref.' + FOnFieldName + ' = tbl.' + FFieldName + ')'
end;

function TrpForeignKey.DropDLL: string;
begin
  Result := 'ALTER TABLE ' + FTableName + ' DROP CONSTRAINT ' +
    FConstraintName;
end;

procedure TrpForeignKey.Read(SQL: TIBSQL);
begin
  FTableName := UpperCase(Trim(SQL.FieldByName(fnTableName).AsString));
  FFieldName := UpperCase(Trim(SQL.FieldByName(fnFieldName).AsString));
  FConstraintName := UpperCase(Trim(SQL.FieldByName(fnConstraintName).AsString));
  FOnTableName := UpperCase(Trim(SQL.FieldByName(fnOnTableName).AsString));
  FOnFieldName := UpperCase(Trim(SQL.FieldByName(fnOnFieldName).AsString));
  FDeleteRule := Trim(SQL.FieldByName(fnOnDelete).AsString);
  FUpdateRule := Trim(SQL.FieldByName(fnOnUpdate).AsString);
  FDropped := False;
end;

procedure TrpForeignKey.ReadFromStream(Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  FConstraintName := ReadStringFromStream(Stream);
  FTableName := ReadStringFromStream(Stream);
  FFieldName := ReadStringFromStream(Stream);
  FOnTableName := ReadStringFromStream(Stream);
  FOnFieldName := ReadStringFromStream(Stream);
  FDeleteRule := ReadStringFromStream(Stream);
  FUpdateRule := ReadStringFromStream(Stream);
  Stream.ReadBuffer(FDropped, SizeOf(FDropped));
end;

procedure TrpForeignKey.SaveToStream(Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  SaveStringToStream(FConstraintName, Stream);
  SaveStringToStream(FTableName, Stream);
  SaveStringToStream(FFieldName, Stream);
  SaveStringToStream(FOnTableName, Stream);
  SaveStringToStream(FOnFieldName, Stream);
  SaveStringToStream(FDeleteRule, Stream);
  SaveStringToStream(FUpdateRule, Stream);
  Stream.WriteBuffer(FDropped, SizeOf(FDropped));
end;

procedure TrpForeignKey.SetConstraintName(const Value: string);
begin
  FConstraintName := Value;
end;

procedure TrpForeignKey.SetDeleteRule(const Value: string);
begin
  FDeleteRule := Value;
end;

procedure TrpForeignKey.SetDropped(const Value: Boolean);
begin
  FDropped := Value;
end;

procedure TrpForeignKey.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TrpForeignKey.SetOnFieldName(const Value: string);
begin
  FOnFieldName := Value;
end;

procedure TrpForeignKey.SetOnTableName(const Value: string);
begin
  FOnTableName := Value;
end;

procedure TrpForeignKey.SetTableName(const Value: string);
begin
  FTableName := Value;
end;

procedure TrpForeignKey.SetUpdateRule(const Value: string);
begin
  FUpdateRule := Value;
end;

{ TrpForeignKeys }

procedure TrpForeignKeys.AddKeys;
var
  I: Integer;
  SQL, FKSQL: TIBSQL;
  Str: TMemoryStream;
begin
  ProgressState.Log(MSG_RESTORE_FKs);
  ProgressState.MaxMinor := Count;
  Str := TMemoryStream.Create;
  try
    FKSQL := TIBSQL.Create(nil);
    try
      FKSQL.Transaction := ReplDataBase.Transaction;
      FKSQL.SQL.Text := 'UPDATE rpl$dbstate SET fk = :fk';
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := ReplDataBase.Transaction;
        for I:= 0 to Count - 1 do
        begin
          if TrpForeignKey(Items[I]).Dropped then
          begin
            ReplDataBase.Connected := True;
            ReplDataBase.Transaction.StartTransaction;

            SQL.SQL.Text := TrpForeignKey(Items[I]).AddDLL;
            try
              SQL.ExecQuery;
              SQL.Close;
              TrpForeignKey(Items[I]).Dropped := False;
              Str.Clear;
              SaveDroppedToStream(Str);
              Str.Position := 0;
              if Str.Size > 0 then
                FKSQL.ParamByName(fnFk).LoadFromStream(Str)
              else
                FKSQL.ParamByName(fnFk).Clear;
              FKSQL.ExecQuery;

              ReplDataBase.Transaction.Commit;
              ReplDataBase.Connected := False;

              ProgressState.Log(Format(MSG_RESTORE_FK, [TrpForeignKey(Items[I]).FieldName,
                TrpForeignKey(Items[I]).TableName]));
            except
              on E: Exception do
              begin
                ReplDataBase.Transaction.Rollback;
                ReplDataBase.Connected := False;
                ProgressState.Log(Format(ERR_RESTORE_FK, [TrpForeignKey(Items[I]).FieldName,
                  TrpForeignKey(Items[I]).TableName, E.Message]));
              end;
            end;
          end;
          ProgressState.MinorProgress(Self);
        end;
      finally
        SQL.Free;
      end;
    finally
      FKSQL.Free;
    end;
  finally
    Str.Free;
  end;
end;

function TrpForeignKeys.GetForeignKeys(Index: Integer): TrpForeignKey;
begin
  Result := TrpForeignKey(Items[Index]);
end;

function TrpForeignKeys.LoadFromTextFile(AFileName: string): boolean;
var
  sl: TStringList;
  i: integer;
  FK: TrpForeignKey;
begin
  Result:= False;
  if SysUtils.FileExists(AFileName) then begin
    sl:= TStringList.Create;
    try
      Clear;
      sl.LoadFromFile(AFileName);
      while Trim(sl[sl.Count - 1]) = '' do
        sl.Delete(sl.Count - 1);
      i:= 0;
      while i < sl.Count - 1 do begin
        while Trim(sl[i]) = '' do
          sl.Delete(i);
        if i + 7 > sl.Count then Exit;
        FK:= TrpForeignKey.Create;
        FK.ConstraintName:= sl[i];
        FK.TableName:= sl[i + 1];
        FK.FieldName:= sl[i + 2];
        FK.OnTableName:= sl[i + 3];
        FK.OnFieldName:= sl[i + 4];
        FK.DeleteRule:= sl[i + 5];
        FK.UpdateRule:= sl[i + 6];
        Inc(i, 7);
        Add(FK);
      end;
      Result:= True;
    finally
      sl.Free;
    end;
  end;
end;

procedure TrpForeignKeys.ReadFromStream(Stream: TStream);
var
  I: Integer;
  lCount: Integer;
  FK: TrpForeignKey;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Clear;
  Stream.ReadBuffer(lCount, SizeOf(lCount));
  for I := 0 to lCount - 1 do
  begin
    FK := TrpForeignKey.Create;
    FK.ReadFromStream(Stream);
    Add(Fk);
  end;
end;

procedure TrpForeignKeys.RestoreKeys;
var
  i: Integer;
  SQL, FKSQL: TIBSQL;
  Str: TMemoryStream;
begin
  ProgressState.Log('Начат процесс восстановления ссылок');
  SQL := TIBSQL.Create(nil);
  FKSQL := TIBSQL.Create(nil);
  try
    SQL.SQL.Text := 'SELECT * FROM rdb$relation_constraints WHERE rdb$constraint_name = :name';
    SQL.Transaction := ReplDataBase.ReadTransaction;
    FKSQL.Transaction := ReplDataBase.Transaction;
    for i := 0 to Count - 1 do begin
      ReplDataBase.Connected:= True;
      SQL.ParamByName('name').AsString:= AnsiUpperCase(ForeignKeys[i].ConstraintName);
      try
        SQL.ExecQuery;
        if SQL.Eof then begin
          ForeignKeys[I].Dropped:= True;
          ReplDataBase.Connected := False;

          ReplDataBase.Connected := True;
          ReplDataBase.Transaction.StartTransaction;

          FKSQL.SQL.Text := ForeignKeys[I].SetNullDLL;
          try
            FKSQL.ExecQuery;
          except
            FKSQL.SQL.Text := ForeignKeys[I].DelDLL;
            FKSQL.ExecQuery;
          end;
          ReplDataBase.Transaction.Commit;
          ReplDataBase.Connected := False;

          ReplDataBase.Connected := True;
          ReplDataBase.Transaction.StartTransaction;
          FKSQL.SQL.Text := ForeignKeys[I].AddDLL;
          FKSQL.ExecQuery;

          try
            ReplDataBase.Transaction.Commit;
            ForeignKeys[I].Dropped:= False;
          except
            on E: Exception do
              frmRestoreFKMain.FReport.Add(Format(ERR_RESTORE_FK, [ForeignKeys[I].FieldName,
                ForeignKeys[I].TableName, E.Message]));
          end;
        end
        else
          ForeignKeys[I].Dropped:= False;
        ProgressState.Log(ForeignKeys[I].ConstraintName);
      finally
        ReplDataBase.Connected := False;
      end;
      ProgressState.MinorProgress(self);
    end;
    SQL.SQL.Text:= SELECT_DBSTATE_FKFIELD;
    try
      ReplDataBase.Connected := True;;
      SQL.ExecQuery;
      if SQL.Eof then begin
        ProgressState.Log(MSG_ADD_FK_INFO);
        FKSQL.SQL.Text:= ADD_DBSTATE_FKFIELD;
        FKSQL.Transaction.StartTransaction;
        try
          FKSQL.ExecQuery;
          ReplDataBase.Transaction.Commit;
          ReplDataBase.Connected := False;
          ReplDataBase.Connected := True;
          FKSQL.SQL.Text := 'UPDATE rpl$dbstate SET fketalon = :fk, fk = :fk1';
          FKSQL.Transaction.StartTransaction;
          Str:= TMemoryStream.Create;
          try
            SaveToStream(Str);
            Str.Position:= 0;
            if Str.Size > 0 then
              FKSQL.ParamByName(fnFk).LoadFromStream(Str)
            else
              FKSQL.ParamByName(fnFk).Clear;
            SaveDroppedToStream(Str);
            Str.Position:= 0;
            if Str.Size > 0 then
              FKSQL.ParamByName('fk1').LoadFromStream(Str)
            else
              FKSQL.ParamByName('fk1').Clear;
            FKSQL.ExecQuery;
            ReplDataBase.Transaction.Commit;
          finally
            Str.Free;
          end;
        except
          ReplDataBase.Transaction.Rollback;
        end;
      end;
    except
    end;
  finally
    SQL.Free;
    FKSQL.Free;
  end;
end;


procedure TrpForeignKeys.SaveDroppedToStream(Stream: TStream);
var
  I, iCount: Integer;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  iCount:= 0;
  for I := 0 to Count -1 do
    if TrpForeignKey(Items[I]).Dropped then
      Inc(iCount);

  if iCount = 0 then
    Stream.Size:= 0
  else begin
    Stream.WriteBuffer(iCount, SizeOf(iCount));
    for I := 0 to Count -1 do
      if TrpForeignKey(Items[I]).Dropped then
        TrpForeignKey(Items[I]).SaveToStream(Stream);
  end;
end;

procedure TrpForeignKeys.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  Stream.WriteBuffer(Count, SizeOf(Count));
  for I := 0 to Count -1 do
    TrpForeignKey(Items[I]).SaveToStream(Stream);
end;

end.
