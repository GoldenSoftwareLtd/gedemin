unit gdc_frmInvSelectedGoods_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmG_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, gsDBTreeView, gdcGood, IBCustomDataSet, gdcBase, gdcTree,
  DBClient;

type
  Tgdc_frmInvSelectedGoods = class(Tgdc_frmG)
    tvMain: TgsDBTreeView;
    Splitter1: TSplitter;
    ibgrDetail: TgsIBGrid;
    gdcGoodGroup: TgdcGoodGroup;
    dsGoodGroup: TDataSource;
    gdcSelectedGood: TgdcSelectedGood;
    procedure ibgrDetailClickedCheck(Sender: TObject; CheckID: String;
      Checked: Boolean);
    procedure ibgrDetailColEnter(Sender: TObject);
    procedure actDeleteChooseExecute(Sender: TObject);
    procedure actDeleteChooseUpdate(Sender: TObject);
    procedure gdcSelectedGoodGetSelectClause(Sender: TObject;
      var Clause: String);
    procedure gdcSelectedGoodBeforePost(DataSet: TDataSet);
    procedure ibgrDetailEnter(Sender: TObject);
  private
    FAssignList: TStrings;
    FEditedFieldList: TStrings;
    FgdcSelectedGoods: TgdcSelectedGood;
    FLastDelGoodKey: Integer;
    FOldOnGetSelectClause: TgdcOnGetSQLClause;

    procedure AllowEditColumns;
    procedure AfterSelectedGoodDelete(DataSet: TDataSet);
    procedure BeforeSelectedGoodDelete(DataSet: TDataSet);
    procedure SetAssignFieldsName(const Value: String);
    function GetAssignFieldsName: String;
    function GetEditedFieldsName: String;
    procedure SetEditedFieldsName(const Value: String);
  public
    constructor Create(AnOwner: TComponent); override;
    destructor  Destroy; override;

    procedure LoadSettings; override;
    procedure SaveSettings; override;

    procedure PassSelectedGoods(const gdcObject: TgdcBase; const SubType: String = '');

    class procedure RegisterClassHierarchy; override;

    //Строка-список присваиваемых полей вида:
    //имя поля 1 приемника = имя поля 1 gdcObject; имя поля 2 приемника = имя поля 2 gdcObject и т.д
    property AssignFieldsName: String read GetAssignFieldsName write SetAssignFieldsName;
    property EditedFieldsName: String read GetEditedFieldsName write SetEditedFieldsName;
  end;


var
  gdc_frmInvSelectedGoods: Tgdc_frmInvSelectedGoods;

implementation

{$R *.DFM}

uses
  Storages, gd_ClassList, gsStorage_CompPath, IBSQL,
  gdcBaseInterface;

{ Tgdc_frmInvSelectedGoods }

const
  sgSelQuantFieldName = 'SELECTEDQUANTITY';

constructor Tgdc_frmInvSelectedGoods.Create(AnOwner: TComponent);

  procedure SetColumn(const gsIBGrid: TgsIBGrid);
  var
    scField: TField;
    scI: Integer;
  begin
    scField := gdcObject.FieldByName(sgSelQuantFieldName);
    for scI := 0 to gsIBGrid.Columns.Count - 1 do
    begin
      if gsIBGrid.Columns.Items[scI].Field = scField then
      begin
        gsIBGrid.Columns.Items[scI].DisplayName := 'Количество';
        gsIBGrid.Columns.Items[scI].Index := 0;
        Break;
      end;
    end;
    scField := gdcObject.FieldByName('name');
    for scI := 0 to gsIBGrid.Columns.Count - 1 do
    begin
      if gsIBGrid.Columns.Items[scI].Field = scField then
      begin
        gsIBGrid.Columns.Items[scI].Index := 1;
        Break;
      end;
    end;
  end;
begin
  inherited;
  ibgrChoose.Visible := True;
  pnChoose.Visible   := True;

  FAssignList := TStringlist.Create;
  AssignFieldsName := 'quantity = ' + sgSelQuantFieldName + '; goodkey = id';
  FEditedFieldList := TStringlist.Create;
  EditedFieldsName := sgSelQuantFieldName;

  if FSubType <> '' then gdcSelectedGood.SubType := FSubType;
  gdcObject := gdcSelectedGood;
  gdcGoodGroup.Open;

  SetColumn(ibgrDetail);

  FgdcSelectedGoods := TgdcSelectedGood.Create(Self);
  FgdcSelectedGoods.SubSet := gdcSelectedGood.SubSet;
  FgdcSelectedGoods.SubType := gdcSelectedGood.SubType;

  dsChoose.DataSet := FgdcSelectedGoods;

  FgdcSelectedGoods.CachedUpdates := True;
  FgdcSelectedGoods.ExtraConditions.Add('Z.ID = -1');
  FOldOnGetSelectClause := FgdcSelectedGoods.OnGetSelectClause;
  FgdcSelectedGoods.OnGetSelectClause := gdcSelectedGood.OnGetSelectClause;
  FgdcSelectedGoods.BeforeDelete := BeforeSelectedGoodDelete;
  FgdcSelectedGoods.AfterDelete  := AfterSelectedGoodDelete;
  FgdcSelectedGoods.Open;
  SetColumn(ibgrChoose);
  spChoose.Align := alNone;
end;

procedure Tgdc_frmInvSelectedGoods.ibgrDetailClickedCheck(Sender: TObject;
  CheckID: String; Checked: Boolean);
begin
  if Checked then
  begin
    gdcObject.Edit;
    try
      if gdcObject.FieldByName(sgSelQuantFieldName).AsCurrency = 0 then
      begin
        gdcObject.FieldByName(sgSelQuantFieldName).AsCurrency := 1;
//      else
//        gdcObject.FieldByName(sgSelQuantFieldName).AsCurrency :=
//          gdcObject.FieldByName(sgSelQuantFieldName).AsCurrency;
        gdcObject.Post;
      end;
    except
      gdcObject.Cancel;
      raise;
    end;
  end else
    begin
      gdcObject.Edit;
      try
        gdcObject.FieldByName(sgSelQuantFieldName).AsCurrency := 0;
        FgdcSelectedGoods.DisableControls;
        try
          FgdcSelectedGoods.First;
          while not FgdcSelectedGoods.Eof do
          begin
            if FgdcSelectedGoods.FieldByName('ID').AsInteger = gdcObject.ID then
              FgdcSelectedGoods.Delete
            else
              FgdcSelectedGoods.Next;
          end;
          gdcObject.Post;
        finally
          FgdcSelectedGoods.EnableControls;
        end;
      except
        if gdcObject.State in dsEditModes then
          gdcObject.Cancel;
        raise;
      end;
    end;
end;

destructor Tgdc_frmInvSelectedGoods.Destroy;
begin
  if (FgdcSelectedGoods <> nil) and FgdcSelectedGoods.Active then
    FgdcSelectedGoods.CancelUpdates;
  FEditedFieldList.Free;
  FAssignList.Free;
  FgdcSelectedGoods.Free;

  inherited;
end;

procedure Tgdc_frmInvSelectedGoods.ibgrDetailColEnter(Sender: TObject);
begin
  inherited;
  if FEditedFieldList.IndexOf(ibgrDetail.SelectedField.FieldName) > -1  then
  begin
    ibgrDetail.Options := ibgrDetail.Options + [dgEditing];
//    ibgrDetail.SelectedField.ReadOnly := False;
  end else
    begin
//      ibgrDetail.SelectedField.ReadOnly := True;
      ibgrDetail.Options := ibgrDetail.Options - [dgEditing];
    end;
end;

procedure Tgdc_frmInvSelectedGoods.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
  T, L: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMINVSELECTEDGOODS', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMINVSELECTEDGOODS', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVSELECTEDGOODS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVSELECTEDGOODS',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVSELECTEDGOODS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if Assigned(UserStorage) then
  begin
    if (BorderStyle = bsSizeable) then
    begin
      Path := BuildComponentPath(Self);

      T := UserStorage.ReadInteger(Path, 'Top', Top);
      L := UserStorage.ReadInteger(Path, 'Left', Left);
      if ((L - 100) < Screen.Width) and ((T - 100) < Screen.Height) then
      begin
        Top := T;
        Left := L;
        Height := UserStorage.ReadInteger(Path, 'Height', Height);
        Width := UserStorage.ReadInteger(Path, 'Width', Width);
        tvMain.Width := UserStorage.ReadInteger(Path, 'tvMainWidth', tvMain.Width);
        pnChoose.Height  := UserStorage.ReadInteger(Path, 'pnChooseHeight', pnChoose.Height);
      end;
      WindowState :=
        TWindowState(UserStorage.ReadInteger(Path, 'WindowState', Integer(WindowState)));
    end;

    UserStorage.LoadComponent(ibgrDetail, ibgrDetail.LoadFromStream, SubType);
    UserStorage.LoadComponent(ibgrChoose, ibgrChoose.LoadFromStream, SubType);
  end;

  spChoose.Align := alBottom;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVSELECTEDGOODS', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVSELECTEDGOODS', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_frmInvSelectedGoods.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Path: String;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_FRMINVSELECTEDGOODS', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_FRMINVSELECTEDGOODS', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMINVSELECTEDGOODS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMINVSELECTEDGOODS',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMINVSELECTEDGOODS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  // Сохранение осуществляем в обычном порядке

  if Assigned(UserStorage) and Assigned(gdcObject) then
  begin
    UserStorage.SaveComponent(ibgrDetail, ibgrDetail.SaveToStream, SubType);
    UserStorage.SaveComponent(ibgrChoose, ibgrChoose.SaveToStream, SubType);

    Path := BuildComponentPath(Self);

    UserStorage.WriteInteger(Path, 'Height', Height);
    UserStorage.WriteInteger(Path, 'Top', Top);
    UserStorage.WriteInteger(Path, 'Left', Left);
    UserStorage.WriteInteger(Path, 'Width', Width);
    UserStorage.WriteInteger(Path, 'WindowState', Integer(WindowState));
    UserStorage.WriteInteger(Path, 'tvMainWidth', tvMain.Width);
    UserStorage.WriteInteger(Path, 'pnChooseHeight', pnChoose.Height);
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMINVSELECTEDGOODS', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMINVSELECTEDGOODS', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

class procedure Tgdc_frmInvSelectedGoods.RegisterClassHierarchy;

  procedure ReadFromDocumentType(ACE: TgdClassEntry);
  var
    CurrCE: TgdClassEntry;
    ibsql: TIBSQL;
    LSubType: string;
    LParentSubType: string;
  begin
    if ACE.Initialized then
      exit;

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text :=
        'SELECT '#13#10 +
        '  dt.classname AS classname, '#13#10 +
        '  dt.ruid AS subtype, '#13#10 +
        '  dt1.ruid AS parentsubtype '#13#10 +
        'FROM gd_documenttype dt '#13#10 +
        'LEFT JOIN gd_documenttype dt1 '#13#10 +
        '  ON dt1.id = dt.parent '#13#10 +
        '  AND dt1.documenttype = ''D'' '#13#10 +
        'WHERE '#13#10 +
        '  dt.documenttype = ''D'' '#13#10 +
        '  and dt.classname = ''TgdcInvDocumentType'' '#13#10 +
        'ORDER BY dt.parent';

      ibsql.ExecQuery;

      while not ibsql.EOF do
      begin
        LSubType := ibsql.FieldByName('subtype').AsString;
        LParentSubType := ibsql.FieldByName('parentsubtype').AsString;

        CurrCE := frmClassList.Add(ACE.TheClass, LSubType, LParentSubType);

        CurrCE.Initialized := True;
        ibsql.Next;
      end;
    finally
      ibsql.Free;
    end;

    ACE.Initialized := True;
  end;

var
  CEBase: TgdClassEntry;

begin
  CEBase := frmClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromDocumentType(CEBase);
end;

procedure Tgdc_frmInvSelectedGoods.AfterSelectedGoodDelete(DataSet: TDataSet);
var
  I: Integer;
  BM: String;
begin
  if DataSet <> FgdcSelectedGoods then Exit;

  BM := FgdcSelectedGoods.Bookmark;
  FgdcSelectedGoods.DisableControls;
  try
    FgdcSelectedGoods.First;

    while not FgdcSelectedGoods.Eof do
    begin
      if FgdcSelectedGoods.ID = FLastDelGoodKey then Break;
      FgdcSelectedGoods.Next;
    end;

    if not FgdcSelectedGoods.Eof then
    begin
      I := ibgrDetail.CheckBox.CheckList.IndexOf(IntToStr(FgdcSelectedGoods.ID));
      if I > - 1 then ibgrDetail.CheckBox.CheckList.Delete(I);
    end;
  finally
    FgdcSelectedGoods.Bookmark := BM;
    FgdcSelectedGoods.EnableControls;
  end;

end;

procedure Tgdc_frmInvSelectedGoods.BeforeSelectedGoodDelete(DataSet: TDataSet);
begin
  if DataSet <> FgdcSelectedGoods then Exit;

  FLastDelGoodKey := FgdcSelectedGoods.ID;
end;

procedure Tgdc_frmInvSelectedGoods.actDeleteChooseExecute(Sender: TObject);
begin
  ibgrDetail.CheckBox.DeleteCheck(FgdcSelectedGoods.ID);
  FgdcSelectedGoods.Delete;
end;

procedure Tgdc_frmInvSelectedGoods.actDeleteChooseUpdate(Sender: TObject);
begin
  actDeleteChoose.Enabled := not FgdcSelectedGoods.Eof; 
end;

procedure Tgdc_frmInvSelectedGoods.PassSelectedGoods(
  const gdcObject: TgdcBase; const SubType: String);
var
  I, SepPos: Integer;
  SelectedField: TField;
//  SourceFieldName: String;
begin


  FgdcSelectedGoods.First;

  if (not FgdcSelectedGoods.Eof) and
    (gdcObject.State = dsEdit) or (gdcObject.State = dsInsert) then gdcObject.Cancel;

  gdcObject.Last;
  while not FgdcSelectedGoods.Eof do
  begin
    gdcObject.Insert;
    try
      for I := 0 to FAssignList.Count - 1 do
      begin
        SepPos := Pos('=', FAssignList[I]);
        if SepPos > 0  then
        begin
          SelectedField := FgdcSelectedGoods.FieldByName(Copy(FAssignList[I], SepPos + 1, Length(FAssignList[I])));
          if not SelectedField.IsNull then
            gdcObject.FieldByName(Copy(FAssignList[I], 1, SepPos - 1)).AsVariant  :=
              SelectedField.AsVariant;
        end;
      end;
//      gdcObject.FieldByName(GoodKeyFieldName).AsInteger := FgdcSelectedGoods.ID;
//      gdcObject.FieldByName(QuantFieldName).AsCurrency  :=
//        FgdcSelectedGoods.FieldByName(sgSelQuantFieldName).AsCurrency;
      gdcObject.Post;
    except
      gdcObject.Cancel;
      raise;
    end;

    FgdcSelectedGoods.Next;
  end;
end;

procedure Tgdc_frmInvSelectedGoods.gdcSelectedGoodGetSelectClause(
  Sender: TObject; var Clause: String);
begin
  inherited;
  Clause := Clause + ',  0.0 as ' + sgSelQuantFieldName;
  if Assigned(FOldOnGetSelectClause) then
    FOldOnGetSelectClause(Sender, Clause);
end;

procedure Tgdc_frmInvSelectedGoods.gdcSelectedGoodBeforePost(
  DataSet: TDataSet);
var
  I: Integer;
begin
  if gdcSelectedGood.FieldByName(sgSelQuantFieldName).AsCurrency <> 0 then
  begin
    if ibgrDetail.CheckBox.CheckList.IndexOf(IntToStr(gdcSelectedGood.ID)) = -1 then
      ibgrDetail.AddCheck;

    FgdcSelectedGoods.DisableControls;
    try
      FgdcSelectedGoods.Last;

      FgdcSelectedGoods.Append;
      for I := 0 to gdcObject.Fields.Count - 1 do
      begin
        FgdcSelectedGoods.FieldByName(gdcObject.Fields[I].FieldName).Value :=
          gdcObject.Fields[I].Value;
      end;

      FgdcSelectedGoods.Post;
      ibgrChoose.AddCheck;
      gdcObject.FieldByName(sgSelQuantFieldName).AsCurrency := 0;
    finally
      FgdcSelectedGoods.EnableControls;
    end;
  end;
end;

procedure Tgdc_frmInvSelectedGoods.SetAssignFieldsName(
  const Value: String);
var
  TmpStr, RecFieldName, SourceFieldName: String;
  I: Integer;
  TmpList: TStrings;
begin
  TmpStr := Trim(Value);
  if TmpStr = '' then raise Exception.Create('Строка не содержит список полей.');

  I := Pos('=', TmpStr);
  if I = 0 then
    Exception.Create('Ошибка формата строки. Формат строки: ReceiverFieldName1=SourceFieldName1[; ReceiverFieldName1=SourceFieldName1][и т.д.]');
  TmpList := TStringList.Create;
  try
    while I > 0 do
    begin
      if I > 0 then
      begin
        RecFieldName := Trim(Copy(TmpStr, 1, I - 1));
        TmpStr := Trim(Copy(TmpStr, I + 1, Length(TmpStr)));
      end else
        Exception.Create('Ошибка формата строки. Формат строки: ReceiverFieldName1=SourceFieldName1[; ReceiverFieldName1=SourceFieldName1][и т.д.]');
      I := Pos(';', TmpStr);
      if I > 0 then
      begin
        SourceFieldName := Trim(Copy(TmpStr, 1, I - 1));
        TmpStr := Trim(Copy(TmpStr, I + 1, Length(TmpStr)));
        I := Pos('=', TmpStr);
      end else
        SourceFieldName := Trim(TmpStr);
      TmpList.Add(RecFieldName + '=' + SourceFieldName);
    end;
    FAssignList.Assign(TmpList);
  finally
    TmpList.Free;
  end;
end;

function Tgdc_frmInvSelectedGoods.GetAssignFieldsName: String;
var
  I: Integer;
begin
  Result := '';
  if FAssignList.Count > 0 then Result := FAssignList[0];
  for I := 1 to FAssignList.Count - 1 do Result := Result + ';' + FAssignList[I];
end;

function Tgdc_frmInvSelectedGoods.GetEditedFieldsName: String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FEditedFieldList.Count - 1 do
  begin
    Result := Result + FEditedFieldList[I] + ';';
  end;
end;

procedure Tgdc_frmInvSelectedGoods.SetEditedFieldsName(
  const Value: String);
var
  TmpStr: String;
  TmpList: TStringList;
  SepPos: Integer;
begin
  TmpStr := Trim(Value);
  TmpList := TStringList.Create;
  TmpList.Sorted := True;

  SepPos := Pos(';', TmpStr);
  while SepPos > 0 do
  begin
    if SepPos > 1 then
    begin
      TmpList.Add(Copy(TmpStr, 1, SepPos - 1));
    end;
    TmpStr := Trim(Copy(TmpStr, SepPos + 1, Length(TmpStr)));
    SepPos := Pos(';', TmpStr);
  end;
  if TmpStr <> '' then TmpList.Add(TmpStr);

  FEditedFieldList.Assign(TmpList);
  AllowEditColumns;  
end;

procedure Tgdc_frmInvSelectedGoods.AllowEditColumns;
{var
  I: Integer;}
begin
{  for I := 0 to gdcSelectedGood.Fields.Count - 1 do
  begin
    if FEditedFieldList.IndexOf(gdcSelectedGood.Fields[I].FieldName) > -1  then
      gdcSelectedGood.Fields[I].ReadOnly := False
    else
      gdcSelectedGood.Fields[I].ReadOnly := True;
  end;}
end;

procedure Tgdc_frmInvSelectedGoods.ibgrDetailEnter(Sender: TObject);
begin
  ibgrDetailColEnter(Sender);
end;

initialization
  RegisterFrmClass(Tgdc_frmInvSelectedGoods);

finalization
  UnRegisterFrmClass(Tgdc_frmInvSelectedGoods);

end.
