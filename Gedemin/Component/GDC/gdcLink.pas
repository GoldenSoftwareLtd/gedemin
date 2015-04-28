
unit gdcLink;

interface

uses
  Classes,   Forms, gdcBase, gd_createable_form, gsStorage,
  gdcBaseInterface, Menus, ContNrs;

type
  TgdcLink = class(TgdcBase)
  private
    FLinkedObjectsMenu: TPopupMenu;
    FObjectKey: Integer;

    procedure OnMenuClick(Sender: TObject);

  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure _DoOnNewRecord; override;

  public
    destructor Destroy; override;

    class function GetDialogFormClassName(const ASubType: TgdcSubType): string; override;
    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    function CreateDialog(const ADlgClassName: String = ''): Boolean; overload; override;

    procedure FillMenu(AMenu: TMenu);
    procedure PopupMenu(const X, Y: Integer);
    procedure AddLinkedObjectDialog;
    function CreateLinkedObject(const AClassName, ASubType: String;
      const AnObjectKey, ALinkedKey: Integer): TgdcBase;

    property ObjectKey: Integer read FObjectKey write FObjectKey;
  end;

procedure Register;

implementation

uses
  Windows,         DB,                   Controls,
  IBSQL,           SysUtils,             gd_ClassList,
  gdc_frmLink_unit,gd_dlgAddLinked_unit, gdcFile
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ TgdcLink }

class function TgdcLink.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'LINKEDNAME';
end;

class function TgdcLink.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_LINK';
end;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcLink]);
end;

class function TgdcLink.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByObjectKey;';
end;

procedure TgdcLink.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByObjectKey') then
    S.Add('z.objectkey=:ObjectKey');
end;

class function TgdcLink.GetViewFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmLink';
end;


procedure TgdcLink.FillMenu(AMenu: TMenu);
var
  q: TIBSQL;
  MI: TMenuItem;
begin
  Assert(FObjectKey > 0);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM gd_link WHERE objectkey = :OK ORDER BY linkedorder, linkedname';
    q.ParamByName('OK').AsInteger := FObjectKey;
    q.ExecQuery;
    while not q.EOF do
    begin
      MI := TMenuItem.Create(Self);
      MI.Caption := q.FieldByName('linkedname').AsString;
      MI.OnClick := OnMenuClick;
      MI.Tag := q.FieldByName('id').AsInteger;
      AMenu.Items.Add(MI);

      q.Next;
    end;
  finally
    q.Free;
  end;

  MI := TMenuItem.Create(Self);
  MI.Caption := '-';
  AMenu.Items.Add(MI);

  MI := TMenuItem.Create(Self);
  MI.Caption := 'Прикрепить...';
  MI.OnClick := OnMenuClick;
  MI.Tag := -10;
  AMenu.Items.Add(MI);

  MI := TMenuItem.Create(Self);
  MI.Caption := 'Удалить прикрепление...';
  MI.OnClick := OnMenuClick;
  MI.Tag := -15;
  AMenu.Items.Add(MI);

  MI := TMenuItem.Create(Self);
  MI.Caption := 'Список прикреплений';
  MI.OnClick := OnMenuClick;
  MI.Tag := -20;
  AMenu.Items.Add(MI);
end;

procedure TgdcLink.OnMenuClick(Sender: TObject);
var
  q: TIBSQL;
  Obj: TgdcBase;
  F: TForm;
  I, R: Integer;
begin
  Assert(FObjectKey > 0);

  if Sender is TMenuItem then
  begin
    if (Sender as TMenuItem).Tag = -10 then
    begin
      AddLinkedObjectDialog;
    end
    else if (Sender as TMenuItem).Tag = -15 then
    begin
      I := TgdcLink.SelectObject(
        'Выберите прикрепление для удаления',
        'Выбор прикрепления',
        0,
        'objectkey=' + IntToStr(FObjectKey),
        -1);
      if I > 0 then
      begin
        R := MessageBox(ParentHandle,
          'Удалить сам объект из базы данных?'#13#10#13#10 +
          'Да -- удалить ссылку на объект из списка прикреплений и сам объект из базы данных.'#13#10 +
          'Нет -- удалить только ссылку на объект из списка прикреплений.',
          'Внимание',
          MB_YESNOCANCEL or MB_ICONQUESTION);
        if R = IDYES then
        begin
          q := TIBSQL.Create(nil);
          try
            q.Transaction := gdcBaseManager.ReadTransaction;
            q.SQL.Text := 'SELECT * FROM gd_link WHERE id = :AnID';
            q.ParamByName('AnID').AsInteger := I;
            q.ExecQuery;
            if not q.EOF then
            begin
              Obj := CreateLinkedObject(q.FieldByName('linkedclass').AsString,
                q.FieldByName('linkedsubtype').AsString,
                I,
                q.FieldByName('linkedkey').AsInteger);

              try
                if Obj <> nil then
                  Obj.Delete;
              finally
                Obj.Free;
              end;
            end;
          finally
            q.Free;
          end;
        end;

        if R <> IDCANCEL then
          gdcBaseManager.ExecSingleQuery(
            'DELETE FROM gd_link WHERE id = ' + IntToStr(I));
      end;
    end
    else if (Sender as TMenuItem).Tag = -20 then
    begin
      F := Tgdc_frmLink.Create(Application);
      (F.FindComponent('gdcLink') as TgdcLink).Close;
      (F.FindComponent('gdcLink') as TgdcLink).ObjectKey := FObjectKey;
      (F.FindComponent('gdcLink') as TgdcLink).SubSet := 'ByObjectKey';
      (F.FindComponent('gdcLink') as TgdcLink).ParamByName('ObjectKey').AsInteger := FObjectKey;
      (F.FindComponent('gdcLink') as TgdcLink).Open;
      F.Show;
    end
    else if (Sender as TMenuItem).Tag > 0 then
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := gdcBaseManager.ReadTransaction;
        q.SQL.Text := 'SELECT * FROM gd_link WHERE id = :AnID';
        q.ParamByName('AnID').AsInteger := (Sender as TMenuItem).Tag;
        q.ExecQuery;
        if not q.EOF then
        begin
          Obj := CreateLinkedObject(q.FieldByName('linkedclass').AsString,
            q.FieldByName('linkedsubtype').AsString,
            (Sender as TMenuItem).Tag,
            q.FieldByName('linkedkey').AsInteger);

          try
            if Obj <> nil then
              Obj.EditDialog;
          finally
            Obj.Free;
          end;
        end;
      finally
        q.Free;
      end;
    end;
  end;
end;

destructor TgdcLink.Destroy;
begin
  FLinkedObjectsMenu.Free;
  inherited;
end;

procedure TgdcLink.PopupMenu(const X, Y: Integer);
begin
  Assert(FObjectKey > 0);

  if FLinkedObjectsMenu = nil then
  begin
    FLinkedObjectsMenu := TPopupMenu.Create(nil);
  end else
    FLinkedObjectsMenu.Items.Clear;

  FillMenu(FLinkedObjectsMenu);

  FLinkedObjectsMenu.Popup(X, Y);
end;

procedure TgdcLink.AddLinkedObjectDialog;
var
  WasActive: Boolean;
  Obj: TgdcFile;
begin
  if FObjectKey <= 0 then
  begin
    if HasSubSet('ByObjectKey') then
      FObjectKey := ParamByName('ObjectKey').AsInteger;
    if FObjectKey <= 0 then
      raise Exception.Create('Прикрепление нельзя создавать само по себе.'#13#10
        + 'Используйте команду Прикрепить в просмотровой форме бизнес-объекта.');  
  end;

  with Tgd_dlgAddLinked.Create(ParentForm) do
  try
    if ShowModal = mrOk then
    begin
      WasActive := Active;
      try
        Open;
        Insert;
        try
          FieldByName('objectkey').AsInteger := FObjectKey;
          if pc.ActivePage = tsObject then
          begin
            FieldByName('linkedkey').AsInteger := iblkupObject.CurrentKeyInt;
            FieldByName('linkedclass').AsString := iblkupObject.gdClassName;
            FieldByName('linkedsubtype').AsString := iblkupObject.SubType;
          end else
          begin
            Obj := TgdcFile.Create(nil);
            try
              Obj.Open;
              Obj.Insert;
              Obj.LoadDataFromFile(edFileName.Text);
              if iblkupFolder.CurrentKey > '' then
                Obj.FieldByName('parent').AsInteger := iblkupFolder.CurrentKeyInt
              else
                Obj.FieldByName('parent').Clear;  
              Obj.Post;

              FieldByName('linkedkey').AsInteger := Obj.ID;
              FieldByName('linkedclass').AsString := Obj.ClassName;
              FieldByName('linkedsubtype').AsString := Obj.SubType;
            finally
              Obj.Free;
            end;
          end;
          FieldByName('linkedname').AsString := edLinkedName.Text;
          FieldByName('linkedusertype').AsString := edUserType.Text;
          Post;
        finally
          if State in dsEditModes then
            Cancel;
        end;
      finally
        if Active and (not WasActive) then
          Close;
      end;
    end;
  finally
    Free;
  end;
end;

class function TgdcLink.GetDialogFormClassName(
  const ASubType: TgdcSubType): string;
begin
  Result := 'Tgdc_dlgLink';
end;

procedure TgdcLink._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCLINK', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCLINK', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCLINK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCLINK',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCLINK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if FObjectKey > 0 then
    FieldByName('objectkey').AsInteger := FObjectKey;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCLINK', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCLINK', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcLink.CreateLinkedObject(const AClassName, ASubType: String;
  const AnObjectKey, ALinkedKey: Integer): TgdcBase;
var
  CE: TgdClassEntry;
begin
  Result := nil;
  CE := gdClassList.Find(AClassName, ASubType);
  if CE is TgdBaseEntry then
  begin
    try
      Result := TgdBaseEntry(CE).gdcClass.CreateSingularByID(nil,
        ALinkedKey,
        CE.SubType);
    except
      if MessageBox(ParentHandle,
        'Невозможно найти прикрепленный объект. Вероятно, он был удален из базы данных.'#13#10#13#10 +
        'Удалить запись об этом объекте из списка прикреплений?',
        'Внимание',
        MB_YESNO or MB_ICONEXCLAMATION) = IDYES then
      begin
        gdcBaseManager.ExecSingleQuery(
          'DELETE FROM gd_link WHERE id = ' + IntToStr(AnObjectKey));
      end;
    end;
  end;
end;

function TgdcLink.CreateDialog(const ADlgClassName: String): Boolean;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CREATEDIALOG('TGDCLINK', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}//  Result := False;
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCLINK', KEYCREATEDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCLINK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ADlgClassName]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCLINK',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCLINK' then
  {M}        begin
  {M}          Result := Inherited CreateDialog(ADlgClassName);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if ADlgClassName = '' then
  begin
    AddLinkedObjectDialog;
    Result := True;
  end else
    Result := Inherited CreateDialog(ADlgClassName);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCLINK', 'CREATEDIALOG', KEYCREATEDIALOG)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCLINK', 'CREATEDIALOG', KEYCREATEDIALOG);
  {M}  end;
  {END MACRO}
end;

initialization
  RegisterGDCClass(TgdcLink);

finalization
  UnregisterGdcClass(TgdcLink);
end.
