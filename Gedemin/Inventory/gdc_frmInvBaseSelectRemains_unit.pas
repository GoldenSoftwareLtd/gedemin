unit gdc_frmInvBaseSelectRemains_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmInvBaseRemains_unit, Db, IBCustomDataSet, gdcBase, gdcTree,
  gdcGood, gd_MacrosMenu, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, gsDBTreeView, StdCtrls, ExtCtrls, TB2Item, TB2Dock,
  TB2Toolbar, gdcInvMovement, gsStorage_CompPath;

type
  Tgdc_frmInvBaseSelectRemains = class(Tgdc_frmInvBaseRemains)
    Panel1: TPanel;
    tbciBaseRemains: TTBControlItem;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure actSelectAllExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure ibgrDetailColEnter(Sender: TObject);
    procedure gdcGoodGroupBeforeScroll(DataSet: TDataSet);
    procedure actSelectAllUpdate(Sender: TObject);
    procedure actUnSelectAllUpdate(Sender: TObject);
    procedure actUnSelectAllExecute(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure actChooseOkExecute(Sender: TObject);

  private
    procedure ReopenRemains(CurrentRemains: Boolean);

  public
    procedure Setup(AnObject: TObject); override;
    procedure SetChoose(AnObject: TgdcBase); override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gdc_frmInvBaseSelectRemains: Tgdc_frmInvBaseSelectRemains;

implementation

{$R *.DFM}

uses
  Storages,
  gd_ClassList,
  gdcInvDocument_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgdc_frmInvBaseSelectRemains.actSelectAllExecute(
  Sender: TObject);
var
  Bookmark: String;
begin
  Bookmark := gdcObject.Bookmark;

  if not gdcObject.Filtered then
  begin
    gdcObject.SetRefreshSQLOn(False);
    gdcObject.DisableControls;
  end;
  gdcObject.First;

  while not gdcObject.EOF do
  begin
    gdcObject.Edit;
    gdcObject.FieldByName('CHOOSEQUANTITY').AsCurrency :=
       gdcObject.FieldByName('REMAINS').AsCurrency;
    gdcObject.Post;
    gdcObject.Next;
  end;
  gdcObject.Bookmark := Bookmark;
  if not gdcObject.Filtered then
  begin
    gdcObject.SetRefreshSQLOn(True);
    gdcObject.Close;
    gdcObject.Open;
    gdcObject.EnableControls;
  end;
end;


procedure Tgdc_frmInvBaseSelectRemains.Setup(AnObject: TObject);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMINVBASESELECTREMAINS', 'SETUP', KEYSETUP)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMINVBASESELECTREMAINS', KEYSETUP);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUP]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVBASESELECTREMAINS') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVBASESELECTREMAINS',
  {M}        'SETUP', KEYSETUP, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVBASESELECTREMAINS' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  IsSetup := True;
  try
    if (AnObject as TgdcBase).HasSubSet('AllRemains') then
      cbAllRemains.Checked := True;
    if not (AnObject as TgdcInvRemains).CurrentRemains then
      RadioButton2.Checked := True;
    gdcObject := AnObject as TgdcBase;
    gdcGoodGroup.Close;
    gdcGoodGroup.ReadTransaction := gdcObject.ReadTransaction;
    SetupInvRemains(gdcObject as TgdcInvRemains);
    gdcObject.MasterSource := nil;
    gdcObject.ReadTransaction := gdcGoodGroup.ReadTransaction;
    if (gdcObject.HasSubSet(cst_ByGoodKey)) then
    begin
      pnMain.Width := 0;
      pnMain.Enabled := False;
      gdcObject.MasterField := '';
      gdcObject.DetailField := '';
      gdcObject.Open;
    end
    else
    begin
      gdcGoodGroup.Open;
      gdcObject.MasterSource := dsDetail;
    end;

    inherited Setup(AnObject);
  finally
    IsSetup := False;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVBASESELECTREMAINS', 'SETUP', KEYSETUP)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVBASESELECTREMAINS', 'SETUP', KEYSETUP);
  {M}end;
  {END MACRO}
end;

type
  TgsCrackCustomDBGrid = class(TgsCustomDBGrid);

procedure Tgdc_frmInvBaseSelectRemains.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;

  if (ModalResult <> mrOk) and ((gdcObject as TgdcInvRemains).CountPosition > 0) then
    case  MessageBox(HANDLE, 'Выбрать отмеченные товары', 'Внимание', mb_YesNoCancel or mb_IconQuestion) of
    idYes: ModalResult := mrOk;
    idNo: (gdcObject as TgdcInvRemains).RemovePosition;
    idCancel:
      begin
        CanClose := False;
        ModalResult := mrNone;
      end;
    end;
end;

procedure Tgdc_frmInvBaseSelectRemains.FormActivate(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  if gdcObject.Active then
  begin
    for I := 0 to ibgrDetail.Columns.Count - 1 do
    begin
      if ((ibgrDetail.Columns[I].Field = gdcObject.FieldByName('CHOOSEQUANTITY')) or
        (ibgrDetail.Columns[I].Field = gdcObject.FieldByName('CHOOSEQUANTPACK'))) and
        ibgrDetail.Columns[I].Visible
      then
      begin
        ibgrDetail.SelectedField := ibgrDetail.Columns[I].Field;
        ibgrDetail.Options :=  ibgrDetail.Options + [dgEditing];
        Break;
      end;
    end;
  end;
end;

procedure Tgdc_frmInvBaseSelectRemains.ibgrDetailColEnter(Sender: TObject);
begin
  inherited;
  if (ANSICompareText(ibgrDetail.SelectedField.FieldName, 'CHOOSEQUANTITY') <> 0) and
    (ANSICompareText(ibgrDetail.SelectedField.FieldName, 'CHOOSEQUANTPACK') <> 0)
  then
  begin
    if dgEditing in ibgrDetail.Options then
      ibgrDetail.Options := ibgrDetail.Options - [dgEditing]
  end
  else
    ibgrDetail.Options :=  ibgrDetail.Options + [dgEditing];
end;

procedure Tgdc_frmInvBaseSelectRemains.gdcGoodGroupBeforeScroll(
  DataSet: TDataSet);
begin
  if Assigned(gdcObject) then
  begin
    if gdcObject.State in [dsEdit, dsInsert] then
      gdcObject.Post;
  end;
  inherited;
end;

procedure Tgdc_frmInvBaseSelectRemains.SetChoose(AnObject: TgdcBase);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_SETUP('TGDC_FRMINVBASESELECTREMAINS', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMINVBASESELECTREMAINS', KEYSETCHOOSE);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETCHOOSE]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVBASESELECTREMAINS') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(AnObject)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVBASESELECTREMAINS',
  {M}        'SETCHOOSE', KEYSETCHOOSE, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVBASESELECTREMAINS' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  if anObject is TgdcInvDocumentLine then
  begin
    FgdcChooseObject := anObject;

    pnChoose.Visible := True;
    tbChooseMain.Visible := True;
    spChoose.Visible := True;

    dsChoose.Dataset := FgdcChooseObject;

    actSelectAll.Enabled := True;
    actUnSelectAll.Enabled := True;
  end
  else
    inherited;
      
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVBASESELECTREMAINS', 'SETCHOOSE', KEYSETCHOOSE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVBASESELECTREMAINS', 'SETCHOOSE', KEYSETCHOOSE);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmInvBaseSelectRemains.SaveSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  MS: TMemoryStream;  
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMINVBASESELECTREMAINS', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMINVBASESELECTREMAINS', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVBASESELECTREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVBASESELECTREMAINS',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVBASESELECTREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  //
  // Сохранение осуществляем в обычном порядке

  if Assigned(UserStorage) and Assigned(gdcObject) then
  begin
    UserStorage.SaveComponent(ibgrChoose, ibgrChoose.SaveToStream,
      SubType);
    MS := TMemoryStream.Create;
    try
      tvGroup.SaveToStream(MS);
      UserStorage.WriteStream(BuildComponentPath(tvGroup), 'TVState', MS);
    finally
      MS.Free;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVBASESELECTREMAINS', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVBASESELECTREMAINS', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmInvBaseSelectRemains.LoadSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  MS: TMemoryStream;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMINVBASEREMAINS', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMINVBASEREMAINS', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVBASEREMAINS',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  if UserStorage <> nil then
  begin
    UserStorage.LoadComponent(ibgrChoose, ibgrChoose.LoadFromStream,
      SubType);
    MS := TMemoryStream.Create;
    try
      if UserStorage.ReadStream(BuildComponentPath(tvGroup), 'TVState', MS) then
        tvGroup.LoadFromStream(MS);
    finally
      MS.Free;
    end;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVBASESELECTREMAINS', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVBASESELECTREMAINS', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmInvBaseSelectRemains.actSelectAllUpdate(Sender: TObject);
begin
// nothing
end;

procedure Tgdc_frmInvBaseSelectRemains.actUnSelectAllUpdate(
  Sender: TObject);
begin
// nothing
end;

procedure Tgdc_frmInvBaseSelectRemains.actUnSelectAllExecute(
  Sender: TObject);
begin
  inherited;
//
end;

procedure Tgdc_frmInvBaseSelectRemains.RadioButton1Click(Sender: TObject);
begin
  inherited;
  if not isSetup then
    ReopenRemains(True);
end;

procedure Tgdc_frmInvBaseSelectRemains.RadioButton2Click(Sender: TObject);
begin
  inherited;
  if Assigned(gdcObject) and not isSetup then
    ReopenRemains(False);
end;

procedure Tgdc_frmInvBaseSelectRemains.ReopenRemains(
  CurrentRemains: Boolean);
var
  OldSubSet: String;
begin
   OldSubSet := (gdcObject as TgdcInvRemains).SubSet;
  (gdcObject as TgdcInvRemains).Close;
  (gdcObject as TgdcInvRemains).SubSet := 'ByID';
  (gdcObject as TgdcInvRemains).SubSet := OldSubSet;
  (gdcObject as TgdcInvRemains).CurrentRemains := CurrentRemains;
  (gdcObject as TgdcInvRemains).Open;
end;

procedure Tgdc_frmInvBaseSelectRemains.actChooseOkExecute(Sender: TObject);
begin
  if Assigned(gdcObject) then
  begin
    if gdcObject.State in [dsEdit, dsInsert] then
      gdcObject.Post;
  end;
  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvBaseSelectRemains);

finalization
  UnRegisterFrmClass(Tgdc_frmInvBaseSelectRemains);
end.
