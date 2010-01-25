unit gdc_dlgBlockRule_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_ClassList, gdc_dlgTRPC_unit, IBDatabase, Menus, Db,
  ActnList, at_Container, DBCtrls, StdCtrls, ComCtrls, Mask,
  gsIBLookupComboBox, xDateEdits, ExtCtrls, IBSQL, gdcBase, CheckLst,
  at_classes, SynEdit, SynMemo, SynEditHighlighter, SynHighlighterSQL;

const
  cDateUnit: Array [0..7] of String = ('CW','CM','CQ','CY','PW','PM','PQ','PY');

type

  TCntrlOnOff = (cooOn, cooOff);
  TTreeType = (ttNotTree, ttSimpleTree, ttLRTree);

  Tgdc_dlgBlockRule = class(Tgdc_dlgTRPC)
    lblName: TLabel;                               
    dbeName: TDBEdit;
    dbcbDisabled: TDBCheckBox;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    dbmCondition: TDBMemo;
    RadioButton2: TRadioButton;
    Label2: TLabel;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    lblDateField: TLabel;
    gsiblcDateField: TgsIBLookupComboBox;
    RadioButton5: TRadioButton;
    dbeDateBlock: TxDateDBEdit;
    RadioButton6: TRadioButton;
    dbeDayNumber: TDBEdit;
    Label3: TLabel;
    ComboBox1: TComboBox;
    GroupBox3: TGroupBox;
    rbAllGroups: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    chbxGroups: TCheckListBox;
    tsTriggers: TTabSheet;
    PageControl1: TPageControl;
    tsForDocs: TTabSheet;
    tsForTable: TTabSheet;
    gsiblcTableName: TgsIBLookupComboBox;
    lblTableName: TLabel;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    mDocumentTypes: TMemo;
    Button2: TButton;
    RadioButton13: TRadioButton;
    Edit1: TEdit;
    Label1: TLabel;
    GroupBox4: TGroupBox;
    RadioButton14: TRadioButton;
    RadioButton15: TRadioButton;
    RadioButton16: TRadioButton;
    gsIBLookupComboBox1: TgsIBLookupComboBox;
    Label4: TLabel;
    tvTriggers: TTreeView;
    Splitter1: TSplitter;
    smTriggerBody: TSynMemo;
    SynSQLSyn: TSynSQLSyn;
    procedure Button2Click(Sender: TObject);
    procedure gsiblcTableNameChange(Sender: TObject);
    procedure gsiblcDateFieldChange(Sender: TObject);
    procedure gsiblcTableNameEnter(Sender: TObject);
    procedure gsiblcDateFieldEnter(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure RadioButton11Click(Sender: TObject);
    procedure RadioButton12Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure RadioButton13Click(Sender: TObject);
    procedure rbAllGroupsClick(Sender: TObject);
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton14Click(Sender: TObject);
    procedure RadioButton15Click(Sender: TObject);
    procedure RadioButton16Click(Sender: TObject);
    procedure actNextRecordUpdate(Sender: TObject);
    procedure actPrevRecordUpdate(Sender: TObject);
    procedure actFirstRecordUpdate(Sender: TObject);
    procedure actLastRecordUpdate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure tvTriggersChange(Sender: TObject; Node: TTreeNode);
    procedure tvTriggersCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    { Private declarations }

    procedure SetSomeFields;
    procedure CtrlsGroupOnOff(OnCtrls: array of TControl;
        OffCtrls: array of TControl) ;
    procedure GetUserGroups;
    procedure SetUserGroups;
    function GetTreeType(const RelationName: String): TTreeType;
    procedure ChngTblName;
    procedure GetSomeFields;
    procedure TestVisualSettings;

    function GetTypeTriggerFromTree(TreeNode: TTreeNode): Integer;
    procedure GetTriggers;
    function GetTriggerBody(const TriggerName: String): String;

  protected
    procedure BeforePost; override;

  public
    { Public declarations }
    procedure SetupRecord; override;
//    procedure SetupDialog; override;
    function TestCorrect: Boolean; override;

  end;

var
  gdc_dlgBlockRule: Tgdc_dlgBlockRule;

implementation

uses
  gdcUser, gdcBaseInterface, gdcClasses, gdcBlockRule;

{$R *.DFM}


procedure Tgdc_dlgBlockRule.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

  I: Integer;
  S:String;

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBLOCKRULE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBLOCKRULE', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBLOCKRULE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBLOCKRULE',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBLOCKRULE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

////////////////////////////////////////////////////////////////////////////////
//showmessage('SetupRecord');
{  mGroups.Lines.Text := (gdcObject as TgdcBlockRule).UserGroupStr(false);}

  mDocumentTypes.Lines.Text := (gdcObject as TgdcBlockRule).GetExcludedDocumentTypes;
  GetUserGroups;
  GetSomeFields;

  if (gsiblcTableName.Condition = '') and
     ((gdcObject as TgdcBlockRule).ExclTblLst.Count > 0) then
    begin
      S := 'RELATIONTYPE <> ''V'' AND RELATIONNAME NOT IN (';
      for I := 0 to (gdcObject as TgdcBlockRule).ExclTblLst.Count - 1 do
        begin
          S := S + ' ''' + (gdcObject as TgdcBlockRule).ExclTblLst.Strings[I] + ''', ';
        end;
      for I := 0 to cDocTableCount - 1 do
        begin
           S := S + ' ''' + cDocTable[0,I] + ''', ';
        end;
      if S > '' then
        SetLength(S, Length(S) - 2);
      S := S + ')';
      gsiblcTableName.Condition := S;
    end;

  GetTriggers;

  gsiblcDateField.Enabled := PageControl1.ActivePageIndex = 1;

  //в случае если изменится имя таблицы в существующей записи
  //необходимо удалить триггеры для предыдущей таблицы
  if not gdcObject.FieldByName('tablename').IsNull then
     (gdcObject as TgdcBlockRule).OldTableNane :=
       gdcObject.FieldByName('tablename').AsString
  else (gdcObject as TgdcBlockRule).OldTableNane := '';

////////////////////////////////////////////////////////////////////////////////

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBLOCKRULE', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBLOCKRULE', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgBlockRule.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGBLOCKRULE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGBLOCKRULE', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBLOCKRULE') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBLOCKRULE',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBLOCKRULE' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := True;

  try
    TestVisualSettings;
  except
    ModalResult := mrNone;
    raise;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBLOCKRULE', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBLOCKRULE', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgBlockRule.BeforePost;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGBLOCKRULE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGBLOCKRULE', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGBLOCKRULE') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGBLOCKRULE',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGBLOCKRULE' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

////////////////////////////////////////////////////////////////////////////////
  if gdcObject.State = dsInsert then
    begin
      gdcObject.FieldByName('ordr').AsInteger :=
        (gdcObject as TgdcBlockRule).NextOrdr;
      gdcObject.FieldByName('usergroups').AsInteger := 1;
    end;

  SetUserGroups;
  SetSomeFields;
  
  (gdcObject as TgdcBlockRule).SaveBlockDocType;

  {  if (gdcObject.FieldByName('name').AsString = '') and
     (gdcObject.FieldByName('tablename').AsString > '') then
    gdcObject.FieldByName('name').AsString :=
       gdcObject.FieldByName('tablename').AsString
  else
    gdcObject.FieldByName('name').AsString := 'Правило № ' +
    gdcObject.FieldByName('ordr').AsString;}

//TODO: Зачем делать проверку если для поля NAME по ТЗ используется домен
//      с проверкой not null ???
  (gdcObject as TgdcBlockRule).CreateBlockTriggers;

////////////////////////////////////////////////////////////////////////////////

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGBLOCKRULE', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGBLOCKRULE', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;


procedure Tgdc_dlgBlockRule.TestVisualSettings;
begin
  with gdcObject do
    begin

      if (RadioButton11.Checked or RadioButton12.Checked) and
         ((gdcObject as TgdcBlockRule).DocTypeItemCount = 0) and
         (PageControl1.ActivePageIndex = 0) then
        begin
          Button2.SetFocus;
          raise Exception.Create('Укажите типы документов для блокировки!');
        end;

      if RadioButton2.Checked and
         (FieldByName('selectcondition').IsNull) then
        begin
          dbmCondition.SetFocus;
          raise Exception.Create('Укажите условие отбора записей!');
        end;

      if RadioButton5.Checked and
         (FieldByName('blockdate').IsNull) then
        begin
          dbeDateBlock.SetFocus;
          raise Exception.Create('Укажите фиксированную дату блокировки!');
        end;

      if RadioButton6.Checked and
         (FieldByName('daynumber').AsInteger = 0) or
         (ComboBox1.ItemIndex < 0 ) then
        begin
          dbeDayNumber.SetFocus;
          raise Exception.Create('Укажите относительную дату блокировки!');
        end;

      if RadioButton13.Checked and (Edit1.Text = '') then
        begin
          Edit1.SetFocus;
          raise Exception.Create('Укажите относительную дату блокировки!');
        end;

      if (RadioButton8.Checked or RadioButton9.Checked) and
         (chbxGroups.SelCount > 0) then
        begin
          chbxGroups.SetFocus;
          raise Exception.Create('Укажите группы пользователей!');
        end;
        
    end;
end;

procedure Tgdc_dlgBlockRule.Button2Click(Sender: TObject);
begin
  mDocumentTypes.Lines.Text := (gdcObject as TgdcBlockRule).ExclDocTypesStr;
end;

function Tgdc_dlgBlockRule.GetTreeType(const RelationName: String): TTreeType;
begin
  result := ttNotTree;
  if atDatabase.Relations.ByRelationName(RelationName).IsLBRBTreeRelation then
    result := ttLRTree
  else
    if atDatabase.Relations.ByRelationName(RelationName).IsStandartTreeRelation then
      result := ttSimpleTree;
end;

procedure Tgdc_dlgBlockRule.ChngTblName;
var
  q: TIBSQL;
  tt: TTreeType;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.Close;
    q.SQL.Text := 'SELECT relationname FROM at_relations WHERE id = :ID';
    q.ParamByName('ID').AsInteger := gsiblcTableName.CurrentKeyInt;
    q.ExecQuery;
    gsiblcDateField.Condition := 'FIELDSOURCE IN (''DDATE'',''DDATE_NOTNULL'',' +
                                 '''DTIMESTAMP'',''DTIMESTAMP_NOTNULL'') AND RELATIONNAME =''';
    if q.EOF then
      begin
        gsiblcDateField.Condition := gsiblcDateField.Condition +
                                     gdcObject.FieldByName('tablename').AsString + '''';
        gsiblcTableName.KeyField := 'relationname';
        gsiblcTableName.DataField := 'tablename';
      end
    else
      begin
        gsiblcDateField.Condition := gsiblcDateField.Condition + q.Fields[0].AsString + '''';
        gdcObject.FieldByName('tablename').AsString := q.Fields[0].AsString;
        gsiblcDateField.CurrentKeyInt := -1;
      end;
  finally
    q.Free;
  end;

  if gdcObject.FieldByName('tablename').AsString <> ''  then
    begin
      gsIBLookupComboBox1.SubType := '';
      gsIBLookupComboBox1.gdClassName := '';

      if not Assigned(atDatabase) then
        atDatabase := at_Classes.atDatabase;
      tt := GetTreeType(gdcObject.FieldByName('tablename').AsString);
      case tt of
        ttNotTree:
          begin
            gsIBLookupComboBox1.ViewType := vtByClass;
            gsIBLookupComboBox1.ListTable := '';
            gsIBLookupComboBox1.KeyField := '';
            gsIBLookupComboBox1.ListField := '';
            gdcObject.FieldByName('rootkey').Clear;
            CtrlsGroupOnOff([],
                   [RadioButton14,RadioButton15,RadioButton16,gsIBLookupComboBox1]);
          end;
        ttLRTree, ttSimpleTree:
          begin
            gsIBLookupComboBox1.ViewType := vtTree;

            gsIBLookupComboBox1.ListTable :=
              gdcObject.FieldByName('tablename').AsString;
            gsIBLookupComboBox1.KeyField :=
              atDatabase.Relations.ByRelationName(gdcObject.FieldByName('tablename').AsString).PrimaryKey.ConstraintFields[0].FieldName;
            gsIBLookupComboBox1.ListField :=
              atDatabase.Relations.ByRelationName(gdcObject.FieldByName('tablename').AsString).ListField.FieldName;

            CtrlsGroupOnOff([RadioButton14,RadioButton15,RadioButton16,gsIBLookupComboBox1],
                  []);
            if tt = ttSimpleTree then
              begin
                Label4.Caption := 'Не включая вложенные уровни.';
                gdcObject.FieldByName('inclsublevels').AsInteger := 0;
              end
            else
              Label4.Caption := 'Включая вложенные уровни.';
          end;
      end;    
    end;
//  dbcbFordocs.Checked := gsiblcTableName.Text = '';
end;

procedure Tgdc_dlgBlockRule.gsiblcTableNameChange(Sender: TObject);
begin
ChngTblName;
end;

procedure Tgdc_dlgBlockRule.gsiblcDateFieldChange(Sender: TObject);
var
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.Close;
    q.SQL.Text := 'SELECT fieldname FROM at_relation_fields WHERE id = :ID';
    q.ParamByName('ID').AsInteger := gsiblcDateField.CurrentKeyInt;
    q.ExecQuery;
    if q.EOF then
      begin
        gsiblcDateField.KeyField := 'fieldname';
        gsiblcDateField.DataField := 'datefieldname';
      end
    else
      gdcObject.FieldByName('datefieldname').AsString := q.Fields[0].AsString;
  finally
    q.Free;
  end;
end;


procedure Tgdc_dlgBlockRule.gsiblcTableNameEnter(Sender: TObject);
begin
  if gsiblcTableName.DataField <> '' then
    begin
      gsiblcTableName.DataField := '';
      gsiblcTableName.KeyField := 'id';
    end;
end;

procedure Tgdc_dlgBlockRule.gsiblcDateFieldEnter(Sender: TObject);
begin
  if gsiblcDateField.DataField <> '' then
    begin
      gsiblcDateField.DataField := '';
      gsiblcDateField.KeyField := 'id';
    end;
end;

procedure Tgdc_dlgBlockRule.CtrlsGroupOnOff(OnCtrls: array of TControl;
        OffCtrls: array of TControl) ;
var
  I: Integer;
begin
  for I := Low(OnCtrls) to High(OnCtrls) do
    if (Assigned(OnCtrls[I])) and (OnCtrls[I] is TControl)
      then (OnCtrls[I] as TControl).Enabled := true;
  for I := Low(OffCtrls) to High(OffCtrls) do
    if (Assigned(OffCtrls[I])) and (OffCtrls[I] is TControl)
      then (OffCtrls[I] as TControl).Enabled := false;
end;

procedure Tgdc_dlgBlockRule.GetSomeFields;
var
  I: Byte;
begin
  if gdcObject.FieldByName('fordocs').AsInteger = 1 then
    PageControl1.ActivePageIndex := 0
  else
    PageControl1.ActivePageIndex := 1;

  RadioButton10.Checked := gdcObject.FieldByName('alldoctypes').AsInteger = 1;
  RadioButton11.Checked := (gdcObject.FieldByName('incldoctypes').AsInteger = 1) and
                           (gdcObject.FieldByName('alldoctypes').AsInteger = 0);
  RadioButton12.Checked := (gdcObject.FieldByName('incldoctypes').AsInteger = 0) and
                           (gdcObject.FieldByName('alldoctypes').AsInteger = 0);

  RadioButton1.Checked := gdcObject.FieldByName('allrecords').AsInteger = 1;

  RadioButton3.Checked := gdcObject.FieldByName('anydate').AsInteger = 1;

  RadioButton5.Checked := gdcObject.FieldByName('fixeddate').AsInteger = 1;

  RadioButton6.Checked := (gdcObject.FieldByName('fixeddate').AsInteger = 0) and
                          (gdcObject.FieldByName('dateunit').AsString <> 'TO') and
                          (not gdcObject.FieldByName('dateunit').IsNull);

  RadioButton13.Checked := (gdcObject.FieldByName('fixeddate').AsInteger = 0) and
                           (gdcObject.FieldByName('dateunit').AsString = 'TO') and
                           (gdcObject.FieldByName('daynumber').AsInteger < 0);

  rbAllGroups.Checked := gdcObject.FieldByName('allusers').AsInteger = 1;
  RadioButton8.Checked := (gdcObject.FieldByName('inclusers').AsInteger = 1) and
                          (gdcObject.FieldByName('allusers').AsInteger = 0);
  RadioButton9.Checked := (gdcObject.FieldByName('inclusers').AsInteger = 0) and
                          (gdcObject.FieldByName('allusers').AsInteger = 0);

  if (not gdcObject.FieldByName('dateunit').IsNull) and
     (gdcObject.FieldByName('dateunit').AsString <> 'TO') then
    begin
      for I := 0 to 7 do
        if  cDateUnit[I] = gdcObject.FieldByName('dateunit').AsString then
          ComboBox1.ItemIndex := I;
    end;
  if gdcObject.FieldByName('dateunit').AsString = 'TO' then
    Edit1.Text := IntToStr(-1 * gdcObject.FieldByName('daynumber').AsInteger);
end;

procedure Tgdc_dlgBlockRule.SetSomeFields;
begin
  gdcObject.FieldByName('allrecords').AsInteger :=
    Integer(RadioButton1.Checked);
  gdcObject.FieldByName('anydate').AsInteger :=
    Integer(RadioButton3.Checked);
  gdcObject.FieldByName('fixeddate').AsInteger :=
    Integer(RadioButton5.Checked);
  if RadioButton3.Checked then
    begin
      gdcObject.FieldByName('blockdate').Clear;
      gdcObject.FieldByName('daynumber').AsInteger := 0;
      gdcObject.FieldByName('dateunit').AsString:= '';
    end;

  if RadioButton5.Checked then
    begin
      gdcObject.FieldByName('daynumber').AsInteger := 0;
      gdcObject.FieldByName('dateunit').AsString := '';
    end;
  if RadioButton6.Checked then
    begin
      gdcObject.FieldByName('blockdate').Clear;
      case ComboBox1.ItemIndex of
        0:gdcObject.FieldByName('dateunit').AsString := 'CW';
        1:gdcObject.FieldByName('dateunit').AsString := 'CM';
        2:gdcObject.FieldByName('dateunit').AsString := 'CQ';
        3:gdcObject.FieldByName('dateunit').AsString := 'CY';
        4:gdcObject.FieldByName('dateunit').AsString := 'PW';
        5:gdcObject.FieldByName('dateunit').AsString := 'PM';
        6:gdcObject.FieldByName('dateunit').AsString := 'PQ';
        7:gdcObject.FieldByName('dateunit').AsString := 'PY';
      end;
    end;
  if RadioButton13.Checked then
    begin
      gdcObject.FieldByName('blockdate').Clear;
      gdcObject.FieldByName('dateunit').AsString := 'TO';
      try
        gdcObject.FieldByName('daynumber').AsInteger :=
         -1 * strtoint(Edit1.Text);
      except
        raise Exception.Create('Некоректно заполнено поле "... дней назад" !');
      end;
    end;

  gdcObject.FieldByName('allusers').AsInteger :=
    Integer(rbAllGroups.Checked);
  gdcObject.FieldByName('inclusers').AsInteger :=
    Integer(RadioButton8.Checked);

  case PageControl1.ActivePageIndex of
   0:begin
       gdcObject.FieldByName('fordocs').AsInteger := 1;
       gdcObject.FieldByName('alldoctypes').AsInteger :=
         Integer(RadioButton10.Checked);
       gdcObject.FieldByName('incldoctypes').AsInteger :=
         Integer(RadioButton11.Checked);
       if RadioButton10.Checked then
         (gdcObject as TgdcBlockRule).ClearDocTypeItems;
       gdcObject.FieldByName('datefieldname').Clear;  
     end;
   1:begin
       gdcObject.FieldByName('fordocs').AsInteger := 0;
     end;
  end;
end;

procedure Tgdc_dlgBlockRule.RadioButton10Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([],[mDocumentTypes, Button2]);
end;

procedure Tgdc_dlgBlockRule.RadioButton11Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([mDocumentTypes, Button2],[]);
end;

procedure Tgdc_dlgBlockRule.RadioButton12Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([mDocumentTypes, Button2],[]);
end;

procedure Tgdc_dlgBlockRule.RadioButton1Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([],[dbmCondition]);
end;

procedure Tgdc_dlgBlockRule.RadioButton2Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([dbmCondition],[]);
end;

procedure Tgdc_dlgBlockRule.RadioButton3Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([],[RadioButton5,dbeDateBlock,
                      RadioButton6,dbeDayNumber,ComboBox1,RadioButton13,Edit1]);
end;

procedure Tgdc_dlgBlockRule.RadioButton4Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([RadioButton5,dbeDateBlock,
                   RadioButton6,dbeDayNumber,ComboBox1,RadioButton13,Edit1],[]);

end;

procedure Tgdc_dlgBlockRule.RadioButton5Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([dbeDateBlock],[dbeDayNumber,ComboBox1,Edit1]);

end;

procedure Tgdc_dlgBlockRule.RadioButton6Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([dbeDayNumber,ComboBox1], [dbeDateBlock,Edit1]);
end;

procedure Tgdc_dlgBlockRule.RadioButton13Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([Edit1], [dbeDateBlock,dbeDayNumber,ComboBox1]);

end;

procedure Tgdc_dlgBlockRule.rbAllGroupsClick(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([],[chbxGroups]);
end;

procedure Tgdc_dlgBlockRule.RadioButton8Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([chbxGroups],[]);
end;

procedure Tgdc_dlgBlockRule.RadioButton9Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([chbxGroups],[]);
end;

procedure Tgdc_dlgBlockRule.RadioButton14Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([],[gsIBLookupComboBox1]);
end;

procedure Tgdc_dlgBlockRule.RadioButton15Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([gsIBLookupComboBox1],[]);
end;

procedure Tgdc_dlgBlockRule.RadioButton16Click(Sender: TObject);
begin
  inherited;
  CtrlsGroupOnOff([gsIBLookupComboBox1],[]);
end;

procedure Tgdc_dlgBlockRule.GetUserGroups;
var
  q:  TIBSQL;
  I, M, R: Integer;
begin
  chbxGroups.Items.Clear;
  q := TIBSQL.Create(nil);
  try
    q.ParamCheck := false;
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.Close;
    q.SQL.Text := 'SELECT id, name FROM gd_usergroup ORDER BY id';
    q.ExecQuery;
    if not q.Eof then
      begin
        R := gdcObject.FieldByName('usergroups').AsInteger;

        while not q.Eof do
          begin
            chbxGroups.Items.Add(q.FieldByName('name').AsString);
            q.Next;
          end;

        M := 1;
        for I := 1 to chbxGroups.Items.Count do
          begin
            chbxGroups.Checked[I - 1] :=
              ((M and R) <> 0);
            if I < chbxGroups.Items.Count then
              M := M shl 1;
          end;

      end;
  finally
    q.Free;
  end;
end;

procedure Tgdc_dlgBlockRule.SetUserGroups;
var
  q:  TIBSQL;
  I, M: Integer;
begin
  M := 0;
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT id, name FROM gd_usergroup ORDER BY id';
    q.ExecQuery;
    while not q.Eof do
    begin
      I := chbxGroups.Items.IndexOf(q.FieldByName('name').AsString);
      if chbxGroups.Checked[I] or rbAllGroups.Checked then
        M := M or (1 shl (q.FieldByName('id').AsInteger - 1));
      q.Next;
    end;
    gdcObject.FieldByName('usergroups').AsInteger := M;
  finally
    q.Free;
  end;
end;

procedure Tgdc_dlgBlockRule.actNextRecordUpdate(Sender: TObject);
begin
  inherited;
//  mGroups.Lines.Text := (gdcObject as TgdcBlockRule).UserGroupStr(false);
//  mDocumentTypes.Lines.Text := (gdcObject as TgdcBlockRule).GetExcludedDocumentTypes;
end;

procedure Tgdc_dlgBlockRule.actPrevRecordUpdate(Sender: TObject);
begin
  inherited;
//  mGroups.Lines.Text := (gdcObject as TgdcBlockRule).UserGroupStr(false);
//  mDocumentTypes.Lines.Text := (gdcObject as TgdcBlockRule).GetExcludedDocumentTypes;

end;

procedure Tgdc_dlgBlockRule.actFirstRecordUpdate(Sender: TObject);
begin
  inherited;
//  mGroups.Lines.Text := (gdcObject as TgdcBlockRule).UserGroupStr(false);
//  mDocumentTypes.Lines.Text := (gdcObject as TgdcBlockRule).GetExcludedDocumentTypes;

end;

procedure Tgdc_dlgBlockRule.actLastRecordUpdate(Sender: TObject);
begin
  inherited;
//  mGroups.Lines.Text := (gdcObject as TgdcBlockRule).UserGroupStr(false);
//  mDocumentTypes.Lines.Text := (gdcObject as TgdcBlockRule).GetExcludedDocumentTypes;

end;

function Tgdc_dlgBlockRule.GetTypeTriggerFromTree(
  TreeNode: TTreeNode): Integer;
var
  NodeText: String;
begin
  Result := -1;

  if TreeNode = nil then
    Exit;

  if TreeNode.Parent <> nil then
    NodeText := AnsiUpperCase(Trim(TreeNode.Parent.Text))
  else
    NodeText := AnsiUpperCase(Trim(TreeNode.Text));

  if NodeText = 'BEFORE INSERT' then
    Result := 1
  else if NodeText = 'AFTER INSERT' then
    Result := 2
  else if NodeText = 'BEFORE UPDATE' then
    Result := 3
  else if NodeText = 'AFTER UPDATE' then
    Result := 4
  else if NodeText = 'BEFORE DELETE' then
    Result := 5
  else if NodeText = 'AFTER DELETE' then
    Result := 6;
end;

procedure Tgdc_dlgBlockRule.GetTriggers;
var
  tNode: TTreeNode;
  q: TIBSQL;
begin
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    tNode := tvTriggers.Items.GetFirstNode;
    while  tNode <> nil do
      begin
        if (tNode.Parent = nil) then
          begin
            (gdcObject as TgdcBlockRule).GetTriggersList(q,GetTypeTriggerFromTree(tNode));
            while not q.Eof do
              begin
                tvTriggers.Items.AddChild(tNode, q.Fields[0].AsString);
                q.Next;
              end;
          end;
        tNode := tNode.GetNext;
      end;
  finally
    q.Free;
  end;
end;

function Tgdc_dlgBlockRule.GetTriggerBody(const TriggerName: String): String;
var
  q: TIBSQL;
begin
  result := '';
  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.Close;
    q.SQL.Text :=
       'select rdb$trigger_source from rdb$triggers'#13#10 +
       ' where rdb$trigger_name = :TriggerName';
    q.ParamByName('TriggerName').AsString := TriggerName;
    q.ExecQuery;
    if not q.EOF then
       result := q.Fields[0].AsString;
  finally
    q.Free;
  end;
end;


procedure Tgdc_dlgBlockRule.PageControl1Change(Sender: TObject);
begin
  inherited;
  gsiblcDateField.Enabled := PageControl1.ActivePageIndex = 1;
end;

procedure Tgdc_dlgBlockRule.tvTriggersChange(Sender: TObject;
  Node: TTreeNode);
begin
  inherited;
  if (Node.Parent <> nil) then
    smTriggerBody.Text := GetTriggerBody(trim(Node.Text))
  else
    smTriggerBody.Lines.Clear;
end;

procedure Tgdc_dlgBlockRule.tvTriggersCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  inherited;
  if Node.StateIndex > 0 then
  begin
    if Sender.Selected = Node then
      Sender.Canvas.Font.Style := [fsBold]
    else
      Sender.Canvas.Font.Color := clGray
  end;
end;

initialization
  RegisterFrmClass(Tgdc_dlgBlockRule);

finalization
  UnRegisterFrmClass(Tgdc_dlgBlockRule);

end.
