
unit gdc_dlgExplorer_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, dmDatabase_unit,
  gsIBLookupComboBox, Mask, DBCtrls, ExtCtrls;

type
  Tgdc_dlgExplorer = class(Tgdc_dlgTR)
    dbeName: TDBEdit;
    ibcmbBranch: TgsIBLookupComboBox;
    Label1: TLabel;
    Label2: TLabel;
    iblkupFunction: TgsIBLookupComboBox;
    rbFolder: TRadioButton;
    rbClass: TRadioButton;
    rbFunction: TRadioButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    cbClasses: TComboBox;
    cbSubTypes: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    DBText1: TDBText;
    cbImages: TComboBox;
    Label7: TLabel;
    rbForm: TRadioButton;
    Bevel4: TBevel;
    edFormClass: TEdit;
    rbReport: TRadioButton;
    iblkupReport: TgsIBLookupComboBox;
    Bevel5: TBevel;
    procedure rbFolderClick(Sender: TObject);
    procedure cbClassesChange(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbImagesMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure cbImagesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);

  public
    procedure BeforePost; override;
    procedure SetupRecord; override;
    procedure SetupDialog; override;
    function TestCorrect: Boolean; override;
    procedure Post; override;
  end;

var
  gdc_dlgExplorer: Tgdc_dlgExplorer;

implementation

uses
  gdcBase, gdcBaseInterface, gd_classlist, IBSQL, gd_security, gdcExplorer,
  dmImages_unit, Storages, gsStorage, gdcAttrUserDefined, gdcClasses,
  jclStrings, gsResizerInterface, gd_directories_const
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure Tgdc_dlgExplorer.rbFolderClick(Sender: TObject);
begin
  if rbFolder.Checked then
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
    cbClasses.Enabled := False;
    cbSubTypes.Enabled := False;
    iblkupFunction.Enabled := False;
    iblkupReport.Enabled := False;
    edFormClass.Enabled := False;
  end
  else if rbClass.Checked then
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
    cbClasses.Enabled := True;
    cbSubTypes.Enabled := True;
    iblkupFunction.Enabled := False;
    iblkupReport.Enabled := False;
    edFormClass.Enabled := False;
  end
  else if rbFunction.Checked then
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_function;
    cbClasses.Enabled := False;
    cbSubTypes.Enabled := False;
    iblkupFunction.Enabled := True;
    iblkupReport.Enabled := False;
    edFormClass.Enabled := False;
  end
  else if rbReport.Checked then
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_report;
    cbClasses.Enabled := False;
    cbSubTypes.Enabled := False;
    iblkupFunction.Enabled := False;
    iblkupReport.Enabled := True;
    edFormClass.Enabled := False;
  end else
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_function;
    cbClasses.Enabled := False;
    cbSubTypes.Enabled := False;
    iblkupFunction.Enabled := False;
    iblkupReport.Enabled := False;
    edFormClass.Enabled := True;
  end;
end;

procedure Tgdc_dlgExplorer.cbClassesChange(Sender: TObject);
var
  SL: TStringList;
  C: CgdcBase;
  I: Integer;
  PC: TPersistentClass;
begin
  cbSubTypes.Items.Clear;
  SL := TStringList.Create;
  try
    PC := GetClass(cbClasses.Text);
    if (PC <> nil) and PC.InheritsFrom(TgdcBase) then
    begin
      C := CgdcBase(PC);
      C.GetSubTypeList(SL);
      for I := 0 to SL.Count - 1 do
        cbSubTypes.Items.Add(SL.Values[SL.Names[I]]);
    end;
  finally
    SL.Free;
  end;
end;

procedure Tgdc_dlgExplorer.BeforePost;
VAR
  C: CgdcBase;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGEXPLORER', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGEXPLORER', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEXPLORER',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Assert(IBLogin <> nil);
  inherited;

  if rbFunction.Checked {and (iblkupFunction.CurrentKey > '')} then
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_function;
    //CMD - РУИД функции
    gdcObject.FieldByName('cmd').AsString :=
      gdcBaseManager.GetRUIDStringByID(iblkupFunction.CurrentKeyInt);
    gdcObject.FieldByName('classname').AsString := '';
    gdcObject.FieldByName('subtype').AsString := '';
  end
  else if rbReport.Checked then
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_report;
    gdcObject.FieldByName('cmd').AsString :=
      gdcBaseManager.GetRUIDStringByID(iblkupReport.CurrentKeyInt);
    gdcObject.FieldByName('classname').AsString := '';
    gdcObject.FieldByName('subtype').AsString := '';
  end
  else if rbClass.Checked then
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
    gdcObject.FieldByName('classname').AsString := cbClasses.Text;
    gdcObject.FieldByName('subtype').AsString := cbSubTypes.Text;
    {Для пользовательских таблиц cmd = РУИД таблицы, для польз док-тов РУИД = Subtype}
    C := CgdcBase(GetClass(gdcObject.FieldByName('classname').AsString));
    if Assigned(C) then
    begin
      if C.InheritsFrom(TgdcAttrUserDefined) or C.InheritsFrom(TgdcAttrUserDefinedTree) or
        C.InheritsFrom(TgdcAttrUserDefinedLBRBTree) then
        gdcObject.FieldByName('cmd').AsString := GetRUIDForRelation(
          gdcObject.FieldByName('subtype').AsString)
      else if C.InheritsFrom(TgdcDocumentType) then
        gdcObject.FieldByName('cmd').AsString := gdcObject.FieldByName('subtype').AsString;
    end;

    if gdcObject.FieldByName('cmd').IsNull then
      gdcObject.FieldByName('cmd').AsString := RUIDToStr(gdcObject.GetRUID);
  end
  else if rbForm.Checked then
  begin
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
    gdcObject.FieldByName('cmd').AsString := RUIDToStr(gdcObject.GetRUID);
    gdcObject.FieldByName('classname').AsString := Trim(edFormClass.Text);
    gdcObject.FieldByName('subtype').AsString := '';
  end else
  begin
    //СМD - РУИД тек записи
    gdcObject.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_class;
    gdcObject.FieldByName('cmd').AsString := RUIDToStr(gdcObject.GetRUID);
    gdcObject.FieldByName('classname').AsString := '';
    gdcObject.FieldByName('subtype').AsString := '';
  end;

  if cbImages.ItemIndex = -1 then
    gdcObject.FieldByName('imgindex').Clear
  else
    gdcObject.FieldByName('imgindex').AsInteger := cbImages.ItemIndex;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXPLORER', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXPLORER', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgExplorer.actOkUpdate(Sender: TObject);
var
  E: Boolean;
begin

  if rbFunction.Checked then
    E := iblkupFunction.CurrentKey > ''
  else if rbReport.Checked then
    E := iblkupReport.CurrentKey > ''
  else
    E := True;

  if E then
  begin
    E := (dbeName.Text > '')
      and (not gdcObject.FieldByName('parent').IsNull);
  end;

  if E then
    inherited
  else
    actOk.Enabled := False;
end;

procedure Tgdc_dlgExplorer.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  PC: TPersistentClass;
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGEXPLORER', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEXPLORER',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if gdcObject.FieldByName('cmdtype').AsInteger = cst_expl_cmdtype_function then
  begin
    rbFunction.Checked := True;
    iblkupFunction.CurrentKeyInt := gdcBaseManager.GetIDByRUIDString(gdcObject.FieldByName('cmd').AsString);
  end else if gdcObject.FieldByName('cmdtype').AsInteger = cst_expl_cmdtype_report then
  begin
    rbReport.Checked := True;
    iblkupReport.CurrentKeyInt := gdcBaseManager.GetIDByRUIDString(gdcObject.FieldByName('cmd').AsString);
  end else if gdcObject.FieldByName('classname').AsString > '' then
  begin
    PC := GetClass(gdcObject.FieldByName('classname').AsString);
    if (PC <> nil) and PC.InheritsFrom(TgdcBase) then
    begin
      rbClass.Checked := True;
      cbSubTypes.Clear;
      if PC.InheritsFrom(TgdcBase) then
      begin
        cbClasses.ItemIndex := cbClasses.Items.IndexOf(gdcObject.FieldByName('classname').AsString);
        cbClassesChange(nil);
        if gdcObject.FieldByName('subtype').AsString > '' then
        begin
          I := cbSubTypes.Items.IndexOf(gdcObject.FieldByName('subtype').AsString);
          if I = -1 then
            cbSubTypes.Text := gdcObject.FieldByName('subtype').AsString
          else
            cbSubTypes.ItemIndex := I;
        end;
      end else
      begin
        cbClasses.ItemIndex :=
          cbClasses.Items.Add(gdcObject.FieldByName('classname').AsString);
      end;
    end
    else if ((PC <> nil) and PC.InheritsFrom(TCustomForm))
      or (StrIPos(USERFORM_PREFIX,
        gdcObject.FieldByName('classname').AsString) = 1) then
    begin
      rbForm.Checked := True;
      cbSubTypes.Clear;
      cbClasses.Text := '';
      edFormClass.Text := gdcObject.FieldByName('classname').AsString;
    end else
      cbClasses.Text := '';
  end else
  begin
    rbFolder.Checked := True;
  end;

  if gdcObject.FieldByName('imgindex').IsNull then
    cbImages.ItemIndex := -1
  else
    cbImages.ItemIndex := gdcObject.FieldByName('imgindex').AsInteger;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXPLORER', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgExplorer.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGEXPLORER', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGEXPLORER', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEXPLORER',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  cbClasses.Clear;
  for I := 0 to gdcClassList.Count - 1 do
  begin
    cbClasses.Items.Add(gdcClassList[I].ClassName);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXPLORER', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXPLORER', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgExplorer.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  cbImages.Items.Clear;
  for I := 0 to dmImages.il16x16.Count - 1 do
  begin
    cbImages.Items.Add(IntToStr(I));
  end;

  inherited;
end;

procedure Tgdc_dlgExplorer.cbImagesMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  Height := 20;
end;

procedure Tgdc_dlgExplorer.cbImagesDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  cbImages.Canvas.Brush.Style := bsSolid;
  if odFocused in State then
    cbImages.Canvas.Brush.Color := clHighlight
  else
    cbImages.Canvas.Brush.Color := clWindow;
  cbImages.Canvas.FillRect(Rect);  
  dmImages.il16x16.Draw(cbImages.Canvas, Rect.Left + 2, Rect.Top + 2, Index, True);
end;

function Tgdc_dlgExplorer.TestCorrect: Boolean;
var
  I: Integer;
  PC: TPersistentClass;
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGEXPLORER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGEXPLORER', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEXPLORER') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEXPLORER',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEXPLORER' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;

  if Result then
  begin
    cbSubTypes.Text := Trim(cbSubTypes.Text);

    if cbSubTypes.Enabled and (cbSubTypes.Text > '') 
      and (cbSubTypes.Items.IndexOf(cbSubTypes.Text) = -1) then
    begin
      cbSubTypes.Text := UpperCase(Trim(cbSubTypes.Text));

      for I := 1 to Length(cbSubTypes.Text) do
      begin
        if not (cbSubTypes.Text[I] in cst_sbt_Symbols) then
        begin
          MessageBox(Handle,
            'Недопустимый символ в подтипе.',
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          Result := False;
          exit;
        end;
      end;
    end;

    if cbSubTypes.Enabled and (cbSubTypes.Text > '')
      and (cbSubTypes.Items.IndexOf(cbSubTypes.Text) = -1) then
    begin
      Result := MessageBox(Handle,
        'Введен нестандартный подтип. Сохранить?',
        'Внимание',
        MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = IDYES;

      if not Result then
        cbSubTypes.Text := '';
    end;

    if edFormClass.Enabled then
    begin
      edFormClass.Text := Trim(edFormClass.Text);
      if StrIPos(USERFORM_PREFIX, edFormClass.Text) = 1 then
      begin
        if GetClass(AnsiUpperCase(GlobalStorage.ReadString(
          st_ds_NewFormPath + '\' + edFormClass.Text, st_ds_FormClass))) = nil then
        begin
          MessageBox(Handle,
            'Неверное имя класса пользовательской формы.',
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          Result := False;
          exit;
        end;
      end else
      begin
        PC := GetClass(edFormClass.Text);
        if (PC = nil) or (not PC.InheritsFrom(TCustomForm)) then
        begin
          MessageBox(Handle,
            'Неверное имя класса формы.',
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          Result := False;
          exit;
        end;
      end;
    end;

    if iblkupFunction.Enabled then
    begin
      if iblkupFunction.CurrentKey = '' then
      begin
        MessageBox(Handle,
          'Не задана скрипт-функция.',
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        Result := False;
        exit;
      end;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXPLORER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXPLORER', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;


procedure Tgdc_dlgExplorer.Post;
{var
  S: String;
  F: TgsStorageFolder;
  V: TgsStorageValue; }
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGEXPLORER', 'POST', KEYPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGEXPLORER', KEYPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGEXPLORER',
  {M}          'POST', KEYPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  {
  if cbSubTypes.Enabled and (cbSubTypes.Text > '')
    and (cbSubTypes.Items.IndexOf(cbSubTypes.Text) = -1) then
  begin
    if Assigned(GlobalStorage) then
    begin
      S := cbSubTypes.Text + '=' + cbSubTypes.Text;

      F := GlobalStorage.OpenFolder('SubTypes', False);
      try
        if F <> nil then
        begin
          V := F.ValueByName(cbClasses.Text);

          if V is TgsStringValue then
          begin
            if Pos(S + ',', V.AsString + ',') = 0 then
            begin
              V.AsString := V.AsString + ',' + S;
            end;
          end
          else if V = nil then
          begin
            F.WriteString(cbClasses.Text, S);
          end;
        end;
      finally
        GlobalStorage.CloseFolder(F);
      end;
    end;
  end;
  }

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGEXPLORER', 'POST', KEYPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGEXPLORER', 'POST', KEYPOST);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgExplorer);

finalization
  UnRegisterFrmClass(Tgdc_dlgExplorer);
end.
