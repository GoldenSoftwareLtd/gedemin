unit gdc_attr_dlgView_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgRelation_unit, SynEditHighlighter, SynHighlighterSQL, Db,
  ActnList, SynEdit, SynMemo, ComCtrls, TB2Item, TB2Dock, TB2Toolbar,
  Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls, DBCtrls, Mask, ExtCtrls,
  IBSQL, at_classes, IBDatabase, gdcMetaData, IBCustomDataSet, gdcBase,
  Menus, gsIBLookupComboBox;

type
  Tgdc_attr_dlgView = class(Tgdc_dlgRelation)
    tsView: TTabSheet;
    smViewBody: TSynMemo;
    btnCreateView: TButton;
    actCreateView: TAction;
    procedure actCreateViewExecute(Sender: TObject);
    procedure pcRelationChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure pcRelationChange(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure cbCreateExplorerCommandClick(Sender: TObject);
    procedure actCreateViewUpdate(Sender: TObject);
    procedure dbedRelationNameEnter(Sender: TObject);
    procedure dbedRelationNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbedRelationNameKeyPress(Sender: TObject; var Key: Char);

  public
    constructor Create(AnOwner: TComponent); override;

    procedure SetupDialog; override;
  end;

var
  gdc_attr_dlgView: Tgdc_attr_dlgView;

implementation

{$R *.DFM}

uses
  gd_ClassList
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgdc_attr_dlgView.actCreateViewExecute(Sender: TObject);
var
  ibsql: TIBSQL;
begin
  Assert(gdcObject.State in dsEditModes);

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcObject.Transaction;
    ibsql.SQL.Text := smViewBody.Text;
    ibsql.Prepare;

    gdcObject.FieldByName('view_source').AsString := smViewBody.Text;

    if gdcObject.State = dsEdit then
      (gdcObject as TgdcView).ReCreateView;
      
    gdcObject.Post;
    gdcObject.Edit;

    //Специально стоит 0, а не Handle текущего окна.
    //На экране может оказаться активной форма вывода информации
    MessageBox(0, 'Для синхронизации полей представления переподключитесь к БД!',
      'Внимание', MB_OK or MB_ICONASTERISK or MB_TASKMODAL);

    tsFields.TabVisible := True;
    tsTrigger.TabVisible := True;

    dbedRelationName.ReadOnly := True;
    actCreateView.Enabled := False;
  finally
    ibsql.Free;
  end;
end;

procedure Tgdc_attr_dlgView.pcRelationChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  pcRelation.SetFocus;
  if pcRelation.ActivePage = tsCommon then
  begin
    if gdcObject.State = dsInsert then
    begin
      if Pos(UserPrefix, gdcObject.FieldByName('relationname').AsString) = 0 then
        gdcObject.FieldByName('relationname').AsString := UserPrefix +
          gdcObject.FieldByName('relationname').AsString;
    end;
  end;
end;

procedure Tgdc_attr_dlgView.pcRelationChange(Sender: TObject);
var
  S: String;
  ibsql: TIBSQL;
begin
  inherited;
  if pcRelation.ActivePage = tsView then
  begin
    if gdcObject.State = dsInsert then
    begin
      if (smViewBody.Text = '')
        or (AnsiPos(AnsiUpperCase(gdcObject.FieldByName('relationname').AsString),
          AnsiUpperCase(smViewBody.Text)) = 0)
      then
        smViewBody.Text := Format(
         'CREATE VIEW %s '#13#10 +
         'AS '#13#10 +
         '  SELECT '#13#10 +
         '  FROM '#13#10, [gdcObject.FieldByName('relationname').AsString])
    end
    else
    begin
      if smViewBody.Text = '' then
      begin

        smViewBody.Text := Format(
        'CREATE VIEW %s '#13#10 +
        ' ('#13#10, [gdcObject.FieldByName('relationname').AsString]);

        S := '';

        ibsql := TIBSQL.Create(nil);
        try
          ibsql.Transaction := gdcObject.ReadTransaction;
          ibsql.SQL.Text := 'SELECT * FROM rdb$relation_fields ' +
            ' WHERE rdb$relation_name = :rn ORDER BY rdb$field_position ';
          ibsql.ParamByName('rn').AsString := gdcObject.FieldByName('relationname').AsString;
          ibsql.ExecQuery;
          if not ibsql.EOF then
          begin
            while not ibsql.EOF do
            begin
              S := S + Trim(ibsql.FieldByName('rdb$field_name').AsString);
              ibsql.Next;
              if not ibsql.EOF then
                S := S + ','#13#10;
            end;
          end else
          begin
            gdcTableField.First;
            while not gdcTableField.EOF do
            begin
              S := S + gdcTableField.FieldByName('fieldname').AsString;
              gdcTableField.Next;
              if not gdcTableField.EOF then
                S := S + ','#13#10;
            end;
          end;
        finally
          ibsql.Free;
        end;

        smViewBody.Text := smViewBody.Text + S + #13#10 + ') '#13#10 + 'AS ' +
           gdcObject.FieldByName('view_source').AsString;
      end;
    end;
  end;
end;

procedure Tgdc_attr_dlgView.actOkUpdate(Sender: TObject);
begin
  inherited;
  btnOK.Default := not smViewBody.Focused;
end;

procedure Tgdc_attr_dlgView.cbCreateExplorerCommandClick(Sender: TObject);
begin
  inherited;
  if not (gdcObject.State in [dsEdit, dsInsert]) then
    gdcObject.Edit;
end;

procedure Tgdc_attr_dlgView.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_ATTR_DLGVIEW', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_ATTR_DLGVIEW', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_DLGVIEW') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_DLGVIEW',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_DLGVIEW' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  tsFields.TabVisible := gdcObject.State <> dsInsert;
  tsTrigger.TabVisible := gdcObject.State <> dsInsert;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_DLGVIEW', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_DLGVIEW', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_dlgView.actCreateViewUpdate(Sender: TObject);
begin
  actCreateView.Enabled := (gdcObject <> nil) and (gdcObject.RecordCount > 0) and
    (((gdcObject.State = dsEdit) and gdcObject.CanDelete) or
    (gdcObject.State = dsInsert));
  smViewBody.ReadOnly := not actCreateView.Enabled;
end;

procedure Tgdc_attr_dlgView.dbedRelationNameEnter(Sender: TObject);
var
  S: string;
begin
  S:= '00000409';
  LoadKeyboardLayout(@S[1], KLF_ACTIVATE);
end;

procedure Tgdc_attr_dlgView.dbedRelationNameKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if ((Shift = [ssShift]) and (Key = VK_INSERT)) or ((Shift = [ssCtrl]) and (Chr(Key) in ['V', 'v'])) then begin
    CheckClipboardForName;
  end;
end;

procedure Tgdc_attr_dlgView.dbedRelationNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  Key:= CheckNameChar(Key);
end;

constructor Tgdc_attr_dlgView.Create(AnOwner: TComponent);
begin
  inherited;
  FEnterAsTab := 2; // отключим EnterAsTab
end;

initialization
  RegisterFrmClass(Tgdc_attr_dlgView);

finalization
  UnRegisterFrmClass(Tgdc_attr_dlgView);
end.
