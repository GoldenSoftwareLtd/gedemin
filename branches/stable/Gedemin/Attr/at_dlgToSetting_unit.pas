
unit at_dlgToSetting_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, ActnList, dmDatabase_unit, IBDatabase, gdcBase,
  dbgrids, Grids, gsDBGrid, gsIBGrid, dmImages_unit, TB2Dock, TB2Toolbar,
  Db, IBCustomDataSet, gdcSetting, TB2Item, IBQuery, gdcBaseInterface,
  ExtCtrls;

type
  TdlgToSetting = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    alToSetting: TActionList;
    actOk: TAction;
    SelfTransaction: TIBTransaction;
    ibgrSetting: TgsIBGrid;
    actAddToSetting: TAction;
    actDelFromSetting: TAction;
    dsSetting: TDataSource;
    actCancel: TAction;
    qrySetting: TIBQuery;
    gdcSetting: TgdcSetting;
    ibluSetting: TgsIBLookupComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Label3: TLabel;
    Button2: TButton;
    Bevel1: TBevel;
    procedure actAddToSettingExecute(Sender: TObject);
    procedure actDelFromSettingExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actDelFromSettingUpdate(Sender: TObject);

  private
    FIsStorage: Boolean;
    FBranchName: String; //������������ ����� ��������
    FValueName: String; //������������ ��������� ����� ��������
    FgdcObject: TgdcBase;
    FBL: TBookmarkList;

    FWasChange: Boolean;

    FgdcSettingObject: TgdcBase;
    //���������� ������� ����������� ������� �� ��������
    function SetConditionsForStorage: String;
    //���������� ������� ����������� ������� �� �������� �� ���������� � ��� ����� ��������
    procedure SetConditionsForSetting;
    function GetSettingSQLByPosRUID: String;
    
    // ������� �� ��������� ������� ������� ���� ��������� ��� ���������� FgdcObject
    //   ����� �� TgdcSettingPos.AddPos
    procedure DeleteBindedObjects(const ASettingKey: TID; const WithDetail: Boolean = false);

  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    //������������� �������������� ��������� �������
    //���������� ����� Show
    procedure Setup(FromStorage: Boolean; ABranchName, AValueName: String;
      AgdcObject: TgdcBase; BL: TBookmarkList);

    //���������, ������� �� ��� �� ��������
    property IsStorage: Boolean read FIsStorage;
    //������������ ����� ��������, ���� ��� ������� �� ����� �-�, ��
    //������������ ����� = ''
    property BranchName: String read FBranchName;
    //�-�, ������� ������ ������
    property gdcObject: TgdcBase read FgdcObject;

    //������ ��� ������ � ���������� (����� ���� ���� TgdcSettingPos,
    //���� TgdcSettingStorage)
    property gdcSettingObject: TgdcBase read FgdcSettingObject;

    // ��������� ��������� �����, ���������� ��� �������� �����
    // � ������ ���������
    procedure SaveSettings; virtual;
    // ������� ��������� �����, ���������� ��� �������� �����
    // ��� � ������ ������ ��������
    procedure LoadSettings; virtual;
  end;

  procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
    AgdcObject: TgdcBase; BL: TBookmarkList);

var
  dlgToSetting: TdlgToSetting;

implementation

uses
  ibsql, gd_security, gd_ClassList, Storages
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdcEvent, contnrs, gdcMetaData, at_classes;

const
  cst_dlgCaption = '�������� � ���������';

  {$R *.DFM}

procedure AddToSetting(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);

begin
  with TdlgToSetting.Create(nil) do
  try
    Setup(FromStorage, ABranchName, AValueName, AgdcObject, BL);
    ShowModal;
  finally
    Free;
  end;
end;

{ TdlgToSetting }

destructor TdlgToSetting.Destroy;
begin
  FgdcSettingObject.Free;
  inherited;
end;

procedure TdlgToSetting.DoCreate;
begin
  inherited;
  LoadSettings;
end;

procedure TdlgToSetting.DoDestroy;
begin
  SaveSettings;
  inherited;
end;

procedure TdlgToSetting.LoadSettings;
begin
  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibgrSetting, ibgrSetting.LoadFromStream);
    ibluSetting.CurrentKeyInt := UserStorage.ReadInteger('dlgToSetting', 'CurrentSetting', -1);
  end;  
end;

procedure TdlgToSetting.SaveSettings;
begin
  if Assigned(UserStorage) then
  begin
    if ibgrSetting.SettingsModified then
      UserStorage.SaveComponent(ibgrSetting, ibgrSetting.SaveToStream);
    UserStorage.WriteInteger('dlgToSetting', 'CurrentSetting', ibluSetting.CurrentKeyInt);
  end;  
end;

procedure TdlgToSetting.Setup(FromStorage: Boolean; ABranchName, AValueName: String;
  AgdcObject: TgdcBase; BL: TBookmarkList);

var
  FXID, FDBID: TID;

begin
  Assert(FromStorage = False, '������ � ���������� ��������� ������ �������������� ����� �/�.');

  Assert(gdcBaseManager <> nil, '�� ������� gdcBaseManager');
  if not SelfTransaction.InTransaction then
    SelfTransaction.StartTransaction;

  FBL := BL;
  FBranchName := ABranchName;
  FValueName := AValueName;
  FreeAndNil(FgdcObject);

  //���� ��� ���������
  (*
  FIsStorage := FromStorage;
  if FIsStorage then
  begin
    if FValueName > '' then
      Caption := cst_DlgCaption + ' �������� ' + FValueName
    else
      Caption := cst_DlgCaption + ' ����� ��������� ' + FBranchName;

    Assert(FBranchName > '');
    //������� ������ ��� ������ �� ���������
    FgdcSettingObject := TgdcSettingStorage.CreateSubType(nil, '', 'BySetting');
    SetConditionsForSetting;

    qrySetting.Open;

    if (qrySetting.RecordCount > 0) and (ibluSetting.CurrentKeyInt = -1) then
    begin
      ibluSetting.CurrentKeyInt := qrySetting.FieldByName('id').AsInteger;
    end;

  end else *)
  begin
    Assert(AgdcObject <> nil);
    Assert(AgdcObject.RecordCount > 0);

    Caption := cst_DlgCaption + ' ������ ' + AgdcObject.GetDisplayName(AgdcObject.SubType);

    FgdcObject := AgdcObject;
    if (BL = nil) or (BL.Count = 0) then
      FgdcObject.ID := AgdcObject.ID
    else
      FgdcObject.BookMark := BL[0];

    //������� ������ ��� ������ � ��������� ��������� ���� �-�
    FgdcSettingObject := TgdcSettingPos.CreateSubType(nil, '', 'BySetting');

    gdcBaseManager.GetFullRUIDByID(FgdcObject.ID, FXID, FDBID);
   //��������� ���� ��� ������(��) ����������� �������
    qrySetting.Close;
    qrySetting.SQL.Text := GetSettingSQLByPosRUID;
    qrySetting.ParamByName('xid').AsInteger := FXID;
    qrySetting.ParamByName('dbid').AsInteger := FDBID;
    qrySetting.Open;

  end;
  FgdcSettingObject.Transaction := SelfTransaction;
  FgdcSettingObject.ReadTransaction := SelfTransaction;
  Hint := Caption;
end;

procedure TdlgToSetting.actAddToSettingExecute(Sender: TObject);
var
  NewID: Integer;
  WithDetail: Boolean;
  OldID: Integer;
begin
  FWasChange := True;
  OldID := qrySetting.FieldByName('id').AsInteger;
  NewID := ibluSetting.CurrentKeyInt;//gdcSetting.SelectObject;
  if NewID > 0 then
  begin
    qrySetting.DisableControls;
    try
      if not qrySetting.Locate('id', NewID, []) then
      begin
        FgdcSettingObject.Close;
        FgdcSettingObject.SubSet := 'BySetting';
        FgdcSettingObject.ParamByName('settingkey').AsInteger := NewID;
        FgdcSettingObject.Open;
        if FgdcSettingObject is TgdcSettingPos then
        begin
          WithDetail := (MessageBox(HWND(nil), PChar('��������� ������ ' +
            FgdcObject.GetDisplayName(FgdcObject.SubType) +  ' ' +
            FgdcObject.FieldByName(FgdcObject.GetListField(FgdcObject.SubType)).AsString +
            ' ������ � ����������?'), '��������!',
            MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES);
          (FgdcSettingObject as TgdcSettingPos).AddPos(FgdcObject, WithDetail);
        end else if FgdcSettingObject is TgdcSettingStorage then
        begin
          (FgdcSettingObject as TgdcSettingStorage).AddPos(FBranchName, FValueName);
        end;
      end
      else
        raise Exception.Create('������ ��� �������� � ��������� ' +
          qrySetting.FieldByName('name').AsString + '!');
    finally
      SetConditionsForSetting;
      qrySetting.Close;
      qrySetting.Open;
      if OldID > 0 then
        qrySetting.Locate('id', OldID, []);
      qrySetting.EnableControls;
    end;
  end;
end;

procedure TdlgToSetting.actDelFromSettingExecute(Sender: TObject);
var
  I: Integer;
//  StMessage: String;
  FXID, FDBID: TID;
  OldID: Integer;
  WithDetail: Boolean;
begin
  FWasChange := True;
  OldID := qrySetting.FieldByName('id').AsInteger;
  try
    qrySetting.DisableControls;

    {
    if (ibgrSetting.SelectedRows.Count = 0) or (ibgrSetting.SelectedRows.Count = 1) then
      StMessage := '������� ������ �� ��������� ' + qrySetting.FieldByName('name').AsString + '?'
    else
      StMessage := '������� ������ �� ' + IntToStr(ibgrSetting.SelectedRows.Count) + ' ��������?';
    }

//    if MessageBox(Handle, PChar(StMessage), '��������!', MB_ICONQUESTION or MB_YESNO) = IDYES
//    then
//    begin
      FgdcSettingObject.Close;
      if FgdcSettingObject is TgdcSettingPos then
      begin
        FgdcSettingObject.SubSet := 'BySetting,ByRUID';
        gdcBaseManager.GetFullRUIDByID(FgdcObject.ID, FXID, FDBID);
        FgdcSettingObject.ParamByName('xid').AsInteger := FXID;
        FgdcSettingObject.ParamByName('dbid').AsInteger := FDBID;
      end else if FgdcSettingObject is TgdcSettingStorage then
      begin
        FgdcSettingObject.SubSet := 'BySetting,ByCRC';
        FgdcSettingObject.ParamByName('crc').AsInteger := GetCRC32FromText(FBranchName);
        FgdcSettingObject.ExtraConditions.Add(Format('%s.%s in (%s)',
          [FgdcSettingObject.GetListTableAlias,
           FgdcSettingObject.GetKeyField(FgdcSettingObject.SubType),
           SetConditionsForStorage]));
        if FValueName > '' then
          FgdcSettingObject.ExtraConditions.Add(Format('%s.valuename = ''%s''',
            [FgdcSettingObject.GetListTableAlias, FValueName]))
        else
          FgdcSettingObject.ExtraConditions.Add(Format('%s.valuename IS NULL',
            [FgdcSettingObject.GetListTableAlias]))
      end;

      if ibgrSetting.SelectedRows.Count = 0 then
      begin
        FgdcSettingObject.ParamByName('settingkey').AsInteger :=
          qrySetting.FieldByName('id').AsInteger;
        FgdcSettingObject.Open;
        if FgdcSettingObject is TgdcSettingPos then
        begin
          WithDetail := FgdcSettingObject.FieldByName('WITHDETAIL').AsInteger = 1;
          FgdcSettingObject.Delete;
          DeleteBindedObjects(qrySetting.FieldByName('id').AsInteger, WithDetail);
        end
        else
          FgdcSettingObject.Delete;
      end
      else
        for I := 0 to ibgrSetting.SelectedRows.Count - 1 do
        begin
          qrySetting.Bookmark := ibgrSetting.SelectedRows[I];
          FgdcSettingObject.Close;
          FgdcSettingObject.ParamByName('settingkey').AsInteger :=
            qrySetting.FieldByName('id').AsInteger;
          FgdcSettingObject.Open;
          if FgdcSettingObject is TgdcSettingPos then
          begin
            WithDetail := FgdcSettingObject.FieldByName('WITHDETAIL').AsInteger = 1;
            FgdcSettingObject.Delete;
            DeleteBindedObjects(qrySetting.FieldByName('id').AsInteger, WithDetail);
          end
          else
            FgdcSettingObject.Delete;
        end;
    //end;
  finally
    SetConditionsForSetting;
    qrySetting.Close;
    qrySetting.Open;
    if OldID > 0 then
      qrySetting.Locate('id', OldID, []);
    qrySetting.EnableControls;
  end;  
end;

procedure TdlgToSetting.actCancelExecute(Sender: TObject);
begin
  if not FWasChange then
  begin
    if SelfTransaction.InTransaction then
      SelfTransaction.Rollback;
    ModalResult := mrCancel;
  end else
  begin
    if MessageBox(Handle, '�������� ��� ���������?', '��������!', MB_ICONQUESTION or MB_YESNO) = IDYES
    then
    begin
      if SelfTransaction.InTransaction then
        SelfTransaction.Rollback;
      ModalResult := mrCancel;
    end
    else
      ModalResult := mrNone;
  end;
end;

procedure TdlgToSetting.actOkExecute(Sender: TObject);
var
  I: Integer;
  StID: String; //������ ���������������
  XID, DBID: TID;
  ASettingPos: TgdcSettingPos;
  WithDetail: Boolean;
begin
  if not FWasChange then
  begin
    if SelfTransaction.InTransaction then
       SelfTransaction.Commit;

    ModalResult := mrOk;
  end else
  begin
    try
      if Assigned(FBL) and (FBL.Count > 1) then
      begin
        if MessageBox(Handle, PChar('��������� ��������� ��� ' + IntToStr(FBL.Count) +
          ' ���������� ������� ������� ' + FgdcObject.GetDisplayName(FgdcObject.SubType) +
          '?'), '��������!', MB_ICONQUESTION or MB_YESNO) = IDYES
        then
        begin
          WithDetail := (MessageBox(HWND(nil), PChar('��������� ��������� ������� ' +
            ' ������ � ����������?'), '��������!',
            MB_YESNO or MB_ICONQUESTION) = IDYES);
  {�.�. �� ����� ������� ��������� ������� ������ � �-� (����� �������� ���������� �� �����),
   �� ��� ����������� ��� �������������� �-� ���� TgdcSettingPos ��� ����������� � ��������}
          ASettingPos := TgdcSettingPos.CreateSubType(nil, '', 'BySetting');
          ASettingPos.Transaction := SelfTransaction;
          ASettingPos.ReadTransaction := SelfTransaction;
          try
            StID := '';

            //��������� � ������ ��� �������������� ��������� ��������
            qrySetting.DisableControls;
            qrySetting.First;
            while not qrySetting.Eof do
            begin
              if StID > '' then
                StID := StID + ',';
              StID := StID + qrySetting.FieldByName('id').AsString;
              qrySetting.Next;
            end;
            qrySetting.EnableControls;

            //������ �� ���� ���������, ������� �� �������,
            //� ������������� ��� ��� ��������� ������� ��������
            for I := 1 to FBL.Count - 1 do
            begin
              FgdcObject.Bookmark := FBL[I];
              gdcBaseManager.GetFullRUIDByID(FgdcObject.ID, XID, DBID);
              //�������� ������ �� ���������� ������� �� ���� ��������, ����� ���������
              if FgdcSettingObject is TgdcSettingPos then
              begin
                FgdcSettingObject.SubSet := 'ByRUID';
                FgdcSettingObject.ParamByName('xid').AsInteger := XID;
                FgdcSettingObject.ParamByName('dbid').AsInteger := DBID;
              end else if FgdcSettingObject is TgdcSettingStorage then
              begin
               //����� ��������� � ��� ���������� �� �����
              end;
              if StID > '' then
                FgdcSettingObject.ExtraConditions.Add('z.settingkey not in (' + StID + ')');
              FgdcSettingObject.Open;
              //������ ��� ������ �� ��������, ����� ���������
              while not FgdcSettingObject.Eof do
                FgdcSettingObject.Delete;

              FgdcSettingObject.ExtraConditions.Clear;
              FgdcSettingObject.Open;

              qrySetting.DisableControls;
              qrySetting.First;
              while not qrySetting.Eof do
              begin
                if not FgdcSettingObject.Locate('settingkey', qrySetting.FieldByName('id').AsInteger, []) then
                begin
                 {���� �� �� ����� ��������� ����� ������ � ���������, �� �� �������
                 �� � ��� ���������, ��������� �������������� �-� ���� TgdcSettingPos}
                  if FgdcSettingObject is TgdcSettingPos then
                  begin
                    ASettingPos.Close;
                    ASettingPos.ParamByName('settingkey').AsInteger :=
                      qrySetting.FieldByName('id').AsInteger;
                    ASettingPos.Open;
                    ASettingPos.AddPos(FgdcObject, WithDetail);
                  end else if FgdcSettingObject is TgdcSettingStorage then
                  begin
                    //����� ��������� � ��� ���������� �� �����
                  end;
                end;
                qrySetting.Next;
              end;
              qrySetting.First;
              qrySetting.EnableControls;

            end;

            if SelfTransaction.InTransaction then
              SelfTransaction.Commit;
            ModalResult := mrOk;
          finally
            ASettingPos.Free;
          end;
        end
        else
          ModalResult := mrNone;
        end
      else
        if SelfTransaction.InTransaction then
          SelfTransaction.Commit;
    except
      on E: Exception do
      begin
        MessageBox(Handle, PChar(E.Message), '������!', MB_ICONSTOP or MB_OK);
        if SelfTransaction.InTransaction then
          SelfTransaction.Rollback;

        ModalResult := mrCancel;
      end;
    end;
  end;
end;

function TdlgToSetting.SetConditionsForStorage: String;
var
  StID: String;
  ASettingStorage: TgdcSettingStorage;
begin
  StID := '';
  Result := '';
  ASettingStorage := TgdcSettingStorage.CreateSubType(nil, '', 'ByCRC') as TgdcSettingStorage;
  ASettingStorage.Transaction := SelfTransaction;
  ASettingStorage.ReadTransaction := SelfTransaction;
  try
    ASettingStorage.ParamByName('crc').AsInteger := GetCRC32FromText(FBranchName);
    ASettingStorage.Open;
    //����� �� ������ ������������ � �������� ���������� ����-����,
    //������� ���������� �������, ����� ����������������� ��������� �����
    while not ASettingStorage.Eof do
    begin
      if AnsiCompareText(ASettingStorage.FieldByName('BranchName').AsString, FBranchName) = 0 then
      begin
        if StID > '' then
          StID := StID + ',';
        StID := StID + IntToStr(ASettingStorage.ID);
      end;
      ASettingStorage.Next;
    end;
    if StID > '' then
      Result := StID
    else
      Result := '-1';

    ASettingStorage.Close;
  finally
    ASettingStorage.Free;
  end;
end;

procedure TdlgToSetting.SetConditionsForSetting;
begin
  qrySetting.Close;
  if FgdcSettingObject is TgdcSettingStorage then
  begin
    Assert(False, '������ � ���������� ��������� ������ �������������� ����� �/�');
    {
    qrySetting.SQL.Text := 'SELECT s.id, s.name FROM at_setting s ';
    if FValueName > '' then
      qrySetting.SQL.Text := qrySetting.SQL.Text + Format('WHERE EXISTS(SELECT * FROM at_setting_storage ' +
        ' WHERE settingkey = s.id AND crc = %s AND id in (%s) AND valuename = ''%s'')',
        [IntToStr(GetCRC32FromText(FBranchName)), SetConditionsForStorage, FValueName])
    else
      qrySetting.SQL.Text := qrySetting.SQL.Text + Format('WHERE EXISTS(SELECT * FROM at_setting_storage ' +
        ' WHERE settingkey = s.id AND crc = %s AND id in (%s) AND valuename IS NULL)',
        [IntToStr(GetCRC32FromText(FBranchName)), SetConditionsForStorage]);
    }
  end;
end;

function TdlgToSetting.GetSettingSQLByPosRUID: String;
begin
  if (SelfTransaction.DefaultDatabase.IsFirebirdConnect)
    and (SelfTransaction.DefaultDatabase.ServerMajorVersion >= 2) then

    Result := ' SELECT s.id, s.name ' +
      ' FROM at_setting s ' +
      ' JOIN (SELECT settingkey FROM at_settingpos WHERE xid = :xid and dbid = :dbid) pos ' +
      '   ON pos.settingkey = s.id '
  else
    Result := 'SELECT s.id, s.name FROM at_setting s WHERE ' +
      ' EXISTS(SELECT id FROM at_settingpos WHERE settingkey = s.id AND ' +
      ' xid = :xid and dbid = :dbid) ';
end;

constructor TdlgToSetting.Create(AnOwner: TComponent);
begin
  inherited;
  FWasChange := False;
end;

procedure TdlgToSetting.actDelFromSettingUpdate(Sender: TObject);
begin
  actDelFromSetting.Enabled := not qrySetting.IsEmpty;
end;

procedure TdlgToSetting.DeleteBindedObjects(const ASettingKey: TID; const WithDetail: Boolean = false);
var
  I: Integer;
  AXID, ADBID: TID;
  ibsql: TIBSQL;
  DL: TObjectList;
  C: TgdcFullClass;
  Obj: TgdcBase;
begin
  // ���� ��������� ������� ��� �����, �� ������ ����� � �������
  if (FgdcObject is TgdcEvent) and (FgdcObject.FieldByName('functionkey').AsInteger > 0) then
  begin
    gdcBaseManager.GetFullRUIDByID(FgdcObject.FieldByName('functionkey').AsInteger, AXID, ADBID);
    FgdcSettingObject.Close;
    FgdcSettingObject.ParamByName('xid').AsInteger := AXID;
    FgdcSettingObject.ParamByName('dbid').AsInteger := ADBID;
    FgdcSettingObject.ParamByName('settingkey').AsInteger := ASettingKey;
    FgdcSettingObject.Open;
    if not FgdcSettingObject.IsEmpty then
      FgdcSettingObject.Delete;
  end;

  // ���� �� ��������� ��������� ����������, �� ������ � ��������� �������
  if (FgdcObject is TgdcMetaBase) and WithDetail then
  begin
    DL := TObjectList.Create(False);
    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := SelfTransaction;

      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
        FgdcObject.GetListTable(FgdcObject.SubType), DL, True);

      for I := 0 to DL.Count - 1 do
      begin
        if TatForeignKey(DL[I]).IsSimpleKey and
          (TatForeignKey(DL[I]).ConstraintField.Field.FieldName = 'DMASTERKEY') then
        begin
          ibsql.Close;
          //�� �� ��������� ���� ������� �� �������
          //��������� ����, �.�. � ������ ����� �������
          //������ ����� �������
          ibsql.SQL.Text := Format('SELECT %s FROM %s WHERE %s = %s ',
            [TatForeignKey(DL[I]).Relation.PrimaryKey.ConstraintFields[0].FieldName,
            TatForeignKey(DL[I]).Relation.RelationName,
            TatForeignKey(DL[I]).ConstraintField.FieldName,
            FgdcObject.FieldByName(FgdcObject.GetKeyField(FgdcObject.SubType)).AsString]);
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
          begin
            //������� ������� �����
            C := GetBaseClassForRelation(TatForeignKey(DL[I]).Relation.RelationName);
            if C.gdClass <> nil then
            begin
              //������� ��� ��������� � ����� �������
              Obj := C.gdClass.CreateSingularByID(nil, gdcBaseManager.Database, SelfTransaction,
                ibsql.Fields[0].AsInteger, C.SubType);
              try
                Obj.Open;
                //������� ����� ��� ������
                C := Obj.GetCurrRecordClass;
              finally
                Obj.Free;
              end;
            end;

            //����� ������� �� �������� ����� ������ ��� ����� �������
            if C.gdClass <> nil then
            begin
              Obj := C.gdClass.CreateSubType(nil, C.SubType, 'ByID');
              try
                Obj.Database := gdcBaseManager.Database;
                Obj.Transaction := SelfTransaction;
                while not ibsql.Eof do
                begin
                  Obj.ID := ibsql.Fields[0].AsInteger;
                  Obj.Open;
                  if (Obj.RecordCount > 0) and (Obj is TgdcMetaBase) and
                    (TgdcMetaBase(Obj).IsUserDefined)
                  then
                  begin
                    //�� ����� ������� �� ��������� ������ ���������������� ����-������
                    gdcBaseManager.GetFullRUIDByID(Obj.ID, AXID, ADBID);
                    FgdcSettingObject.Close;
                    FgdcSettingObject.ParamByName('xid').AsInteger := AXID;
                    FgdcSettingObject.ParamByName('dbid').AsInteger := ADBID;
                    FgdcSettingObject.ParamByName('settingkey').AsInteger := ASettingKey;
                    FgdcSettingObject.Open;
                    if not FgdcSettingObject.IsEmpty then
                      FgdcSettingObject.Delete;
                  end;
                  Obj.Close;
                  ibsql.Next;
                end;
              finally
                Obj.Free;
              end;
            end;
          end;
        end;
      end;
    finally
      DL.Free;
      ibsql.Free;
    end;
  end;
end;

end.
