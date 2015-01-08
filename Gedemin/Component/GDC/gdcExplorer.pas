
{++

  Copyright (c) 2000-2013 by Golden Software of Belarus
                                                               
  Module

    gdcExplorer.pas

  Abstract

    Модуль содержит базовый класс для Исследователя

  Author

    Michael Shoihet

  Contact address

    mikle_shoihet@yahoo.com

  Revisions history

    1.00    13-dec-01    michael    Initial version.
    1.01    09-apr-02    JKL        CreateObjectByClass was added

--}

unit gdcExplorer;

interface

uses
  Windows,      Messages,       SysUtils,       Classes,        Graphics,
  Controls,     Forms,          Dialogs,        Db,             IBCustomDataSet,
  gdcBase,      gdcTree,        gd_security,    gd_createable_form, dmDatabase_unit,
  gdcBaseInterface, gd_KeyAssoc, rp_ReportClient, TB2Item, Contnrs, Menus;


const
  cst_expl_cmdtype_report = 2;
  cst_expl_cmdtype_function = 1;
  cst_expl_cmdtype_class = 0;

  //Допустимые символы в сабтайпе
  cst_sbt_Symbols = ['A'..'Z', '0'..'9', '_', '$'];

type
  TgdcExplorer = class(TgdcTree)
  private
    FOldSubType, FOldClassName: Variant;

    function Get_gdcClass: CgdcBase;

    function TestSubType(const AClassName, ASubType: String): Boolean;
    procedure AddSubType(const AClassName, ASubType: String);
    procedure RemoveSubType(const AClassName, ASubType: String);

  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

    procedure DoAfterPost; override;
    procedure DoAfterEdit; override;
    procedure DoAfterInsert; override;
    procedure DoAfterDelete; override;
    procedure DoBeforeDelete; override;
    procedure DoBeforePost; override;

    function GetSecCondition: String; override;
    procedure InternalSetFieldData(Field: TField; Buffer: Pointer); override;

  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;
    class function NeedModifyFromStream(const SubType: String): Boolean; override;

    function CheckTheSameStatement: String; override;

    procedure ShowProgram(const AlwaysCreateWindow: Boolean = False);
    function CreateGdcInstance: TgdcBase;

    procedure _SaveToStream(Stream: TStream; ObjectSet: TgdcObjectSet;
      PropertyList: TgdcPropertySets; BindedList: TgdcObjectSet;
      WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean = True); override;

    procedure SubNewPopup(ATBSI: TTBSubmenuItem;
      const AnOnlySameLevel: Boolean;
      ADisabled: TClassList = nil); overload; override;

    procedure SubNewPopup(AMI: TMenuItem;
      const AnOnlySameLevel: Boolean;
      ADisabled: TClassList = nil); overload; override;

    function GetDescendantCount(const AnOnlySameLevel: Boolean): Integer; override;

    property gdcClass: CgdcBase read Get_gdcClass;
  end;

function ViewFormByClass(const AnClassName, AnSubType: String;
  const AlwaysCreateWindow: Boolean): TForm;

procedure Register;

implementation

uses
  gd_ClassList,         gdc_createable_form,     gdc_frmExplorer_unit,
  gdc_frmG_unit,        gdc_frmMDH_unit,         gsStorage,
  gdc_dlgExplorer_unit, gd_directories_const,    Storages,
  scr_i_functionlist,   rp_BaseReport_unit,      gd_i_scriptfactory,
  gdcFunction,          jclStrings,              gsResizerInterface,
  IBUtils,              at_classes,
  IBDatabase,           IBSQL,                   gdcReport
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

type
  TgdcBaseCrack = class(TgdcBase);

procedure Register;
begin
  RegisterComponents('GDC', [TgdcExplorer]);
end;

{ TgdcExplorer }


procedure TgdcExplorer.AddSubType(const AClassName, ASubType: String);
var
  C: TPersistentClass;
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  C := GetClass(AClassName);
  if (C <> nil)
    // список классов подтипы которых находятся не в хранилище
    and (C.InheritsFrom(TgdcBase))
    and (not C.ClassNameIs('TgdcAttrUserDefined'))
    and (not C.ClassNameIs('TgdcAttrUserDefinedTree'))
    and (not C.ClassNameIs('TgdcAttrUserDefinedLBRBTree'))
    and (not C.ClassNameIs('TgdcUserDocument'))
    and (not C.ClassNameIs('TgdcUserDocumentLine'))
    and (not C.ClassNameIs('TgdcInvBasePriceList'))
    and (not C.ClassNameIs('TgdcSelectedGood'))
    and (not C.ClassNameIs('TgdcInvGoodRemains'))
    and (not C.ClassNameIs('TgdcInvRemains'))
    and (not C.ClassNameIs('TgdcInvMovement'))
    and (not C.ClassNameIs('TgdcInvDocument'))
    and (not C.ClassNameIs('TgdcInvDocumentLine'))
    and (not C.ClassNameIs('TgdcInvBasePriceList'))
    and (not C.ClassNameIs('TgdcInvPriceList'))
    and (not C.ClassNameIs('TgdcInvPriceListLine'))
    then
  begin
    if Assigned(GlobalStorage) then
    begin
      F := GlobalStorage.OpenFolder('SubTypes', True);
      try
        if Assigned(F) then
        begin
          V := F.ValueByName(C.ClassName);
          if V = nil then
          begin
            F.WriteString(C.ClassName, '');
            V := F.ValueByName(C.ClassName);
          end;
          if not (V is TgsStringValue) then
          begin
            F.DeleteValue(C.ClassName);
            F.WriteString(C.ClassName, '');
            V := F.ValueByName(C.ClassName);
          end;
          if V is TgsStringValue then
          begin
            if V.AsString > '' then
              V.AsString := V.AsString + ',' + ASubType + '=' + ASubType
            else
              V.AsString := ASubType + '=' + ASubType
          end;
        end;
      finally
        GlobalStorage.CloseFolder(F);
      end;
    end;
  end;
end;

function TgdcExplorer.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCEXPLORER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXPLORER', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXPLORER',
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
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXPLORER' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result :=
      'SELECT FIRST 1 id FROM gd_command ' +
      'WHERE COALESCE(cmd, '''') > '''' AND UPPER(cmd) = UPPER(:cmd)'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else
    Result :=
      'SELECT FIRST 1 id FROM gd_command ' +
      'WHERE COALESCE(cmd, '''') > '''' AND UPPER(cmd) = UPPER(''' +
      StringReplace(FieldByName('cmd').AsString, '''', '''''', [rfReplaceAll]) + ''') ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXPLORER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXPLORER', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

function TgdcExplorer.CreateGdcInstance: TgdcBase;
begin
  if gdcClass <> nil then
    Result := gdcClass.CreateSubType(Application, FieldByName('subtype').AsString)
  else
    Result := nil;
end;

procedure TgdcExplorer.DoAfterDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  V: OleVariant;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEXPLORER', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXPLORER', KEYDOAFTERDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXPLORER',
  {M}          'DOAFTERDELETE', KEYDOAFTERDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  if (VarType(FOldClassName) = varString)
    and (VarType(FOldSubType) = varString) then
  begin
    ExecSingleQueryResult('SELECT id FROM gd_command WHERE classname=:cn AND subtype=:st',
      VarArrayOf([FOldClassName, FOldSubType]), V);

    if VarType(V) = varEmpty then
    begin
      RemoveSubType(FOldClassName, FOldSubType);
    end;  
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXPLORER', 'DOAFTERDELETE', KEYDOAFTERDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXPLORER', 'DOAFTERDELETE', KEYDOAFTERDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcExplorer.DoAfterEdit;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEXPLORER', 'DOAFTEREDIT', KEYDOAFTEREDIT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXPLORER', KEYDOAFTEREDIT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTEREDIT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXPLORER',
  {M}          'DOAFTEREDIT', KEYDOAFTEREDIT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  FOldClassName := FieldByName('classname').AsVariant;
  FOldSubType := FieldByName('subtype').AsVariant;  

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXPLORER', 'DOAFTEREDIT', KEYDOAFTEREDIT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXPLORER', 'DOAFTEREDIT', KEYDOAFTEREDIT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcExplorer.DoAfterInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEXPLORER', 'DOAFTERINSERT', KEYDOAFTERINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXPLORER', KEYDOAFTERINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXPLORER',
  {M}          'DOAFTERINSERT', KEYDOAFTERINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  FOldClassName := Unassigned;
  FOldSubType := Unassigned;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXPLORER', 'DOAFTERINSERT', KEYDOAFTERINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXPLORER', 'DOAFTERINSERT', KEYDOAFTERINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcExplorer.DoAfterPost;
var
  SL: TStringList;

  procedure DoRecurs(AnID: Integer);
  var
    Tr: TIBTransaction;
    q, q2: TIBSQL;
    C: TPersistentClass;
    O: TgdcBase;
    I: Integer;
    RelationName: String;
  begin
    Tr := TIBTransaction.Create(nil);
    q := TIBSQL.Create(nil);
    q2 := TIBSQL.Create(nil);
    try
      Tr.DefaultDatabase := gdcBaseManager.Database;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q2.Transaction := Tr;

      q.SQL.Text := 'SELECT classname, subtype, aview, achag, afull FROM gd_command WHERE id=:AnID';
      q.ParamByName('AnID').AsInteger := AnID;
      q.ExecQuery;

      if q.FieldByName('classname').AsString > '' then
      begin
        q2.SQL.Text := 'UPDATE gd_command SET aview = :AVIEW, achag = :ACHAG, afull = :AFULL ' +
          ' WHERE classname = :CN AND IIF(subtype IS NULL, '''', subtype) = :ST AND id <> :ID ';
        q2.ParamByName('AVIEW').AsInteger := q.FieldByName('AVIEW').AsInteger;
        q2.ParamByName('ACHAG').AsInteger := q.FieldByName('ACHAG').AsInteger;
        q2.ParamByName('AFULL').AsInteger := q.FieldByName('AFULL').AsInteger;
        q2.ParamByName('ID').AsInteger := AnID;
        q2.ParamByName('CN').AsString := q.FieldByName('classname').AsString;
        q2.ParamByName('ST').AsString := q.FieldByName('subtype').AsString;
        try
          q2.ExecQuery;
        except
        end;
        q2.Close;
      end;

      C := GetClass(q.FieldByName('classname').AsString);
      if (C <> nil) and C.InheritsFrom(TgdcBase) then
      begin
        O := CgdcBase(C).CreateSubType(nil, q.FieldByName('subtype').AsString, 'ByID');
        try
          try
            O.Open;

            for I := 0 to O.Fields.Count - 1 do
            begin
              RelationName := ExtractIdentifier(Database.SQLDialect,
                System.Copy(O.Fields[I].Origin, 1, Pos('.', O.Fields[I].Origin) - 1));

              if SL.IndexOf(RelationName) = -1 then
              begin
                gdcBaseManager.ExecSingleQuery('UPDATE at_relation_fields SET ' +
                  'aview = BIN_OR(aview, ' + FieldByName('aview').AsString + '), ' +
                  'achag = BIN_OR(achag, ' + FieldByName('achag').AsString + '), ' +
                  'afull = BIN_OR(afull, ' + FieldByName('afull').AsString + ') ' +
                  'WHERE relationname = ''' + RelationName + '''', Tr);

                gdcBaseManager.ExecSingleQuery('UPDATE at_relations SET ' +
                  'aview = BIN_OR(aview, ' + FieldByName('aview').AsString + '), ' +
                  'achag = BIN_OR(achag, ' + FieldByName('achag').AsString + '), ' +
                  'afull = BIN_OR(afull, ' + FieldByName('afull').AsString + ') ' +
                  'WHERE relationname = ''' + RelationName + '''', Tr);

                SL.Add(RelationName);
              end;
            end;
          except
            // TODO: пустой except
          end;
        finally
          O.Free;
        end;
      end;

      if UpdateChildren_Global then
      begin
        q.Close;
        q.SQL.Text := 'SELECT id FROM gd_command WHERE parent=:P';
        q.ParamByName('P').AsInteger := AnID;
        q.ExecQuery;
        while not q.EOF do
        begin
          DoRecurs(q.FieldByName('id').AsInteger);
          q.Next;
        end;
      end;

      q.Close;
      Tr.Commit;
    finally
      q.Free;
      q2.Free;
      Tr.Free;
    end;
  end;

var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  V: OleVariant;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEXPLORER', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXPLORER', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXPLORER',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  if GetClass(FieldByName('classname').AsString) <> nil then
  begin
    gdcBaseManager.Class_SetSecDesc(GetClass(FieldByName('classname').AsString),
      FieldByName('subtype').AsString,
      FieldByName('aview').AsInteger,
      FieldByName('achag').AsInteger,
      FieldByName('afull').AsInteger)
  end;

  if (VarType(FOldClassName) = varEmpty) and (VarType(FOldSubType) = varEmpty) then
  begin
    if (FieldByName('classname').AsString > '')
      and (FieldByName('subtype').AsString > '') then
    begin
      if not TestSubType(FieldByName('classname').AsString, FieldByName('subtype').AsString) then
      begin
        AddSubType(FieldByName('classname').AsString, FieldByName('subtype').AsString);
      end;
    end;
  end else
  begin
    if (FieldByName('classname').AsVariant <> FOldClassName) or
      (FieldByName('subtype').AsVariant <> FOldSubType) then
    begin
      if (VarType(FOldClassName) = varString) and (VarType(FOldSubType) = varString) then
      begin
        ExecSingleQueryResult('SELECT id FROM gd_command WHERE classname=:cn AND subtype=:st',
          VarArrayOf([FOldClassName, FOldSubType]), V);

        if VarType(V) = varEmpty then
        begin
          RemoveSubType(FOldClassName, FOldSubType);
        end;
      end;
      if (FieldByName('classname').AsString > '')
        and (FieldByName('subtype').AsString > '') then
      begin
        if not TestSubType(FieldByName('classname').AsString, FieldByName('subtype').AsString) then
        begin
          AddSubType(FieldByName('classname').AsString, FieldByName('subtype').AsString);
        end;
      end;
    end;
  end;

  // Через поток поля настройки прав не переносятся,
  //  поэтому обновлять права у зависимых объектов не надо
  if not (sLoadFromStream in Self.BaseState) then
  begin
    try
      SL := TStringList.Create;
      try
        SL.Sorted := True;
        SL.Duplicates := dupIgnore;
        DoRecurs(ID);
      finally
        SL.Free;
      end;
    except
      on E: Exception do
      begin
        Application.ShowException(E);
      end;
    end;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXPLORER', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXPLORER', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcExplorer.DoBeforeDelete;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEXPLORER', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXPLORER', KEYDOBEFOREDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXPLORER',
  {M}          'DOBEFOREDELETE', KEYDOBEFOREDELETE, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited;

  FOldClassName := FieldByName('classname').AsVariant;
  FOldSubType := FieldByName('subtype').AsVariant;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXPLORER', 'DOBEFOREDELETE', KEYDOBEFOREDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXPLORER', 'DOBEFOREDELETE', KEYDOBEFOREDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcExplorer.DoBeforePost;

  procedure SetAccessRightsForExistingRecords;
  var
    Obj: TgdcBase;
    AClassName, ASubType: String;
    AListTable, AListTableAlias, AKeyField: String;
    SetRightClause, S: String;
  begin
    AClassName := FieldByName('classname').AsString;
    if not GetClass(AClassName).InheritsFrom(TgdcBase) then
      exit;

    Obj := CgdcBase(GetClass(AClassName)).CreateSubType(nil, FieldByName('subtype').AsString);
    try
      AListTable := Obj.GetListTable(ASubType);
      AListTableAlias := Obj.GetListTableAlias;
      AKeyField := Obj.GetKeyField(ASubType);

      if (AListTable = '') or (AKeyField = '') then
        exit;

      if (tiAView in Obj.gdcTableInfos) and FieldChanged('aview') then
        SetRightClause := 'aview=' + FieldByName('aview').AsString + ','
      else
        SetRightClause := '';

      if (tiAChag in Obj.gdcTableInfos) and FieldChanged('achag') then
        SetRightClause := SetRightClause + 'achag=' + FieldByName('achag').AsString + ',';

      if (tiAFull in Obj.gdcTableInfos) and FieldChanged('afull') then
        SetRightClause := SetRightClause + 'afull=' + FieldByName('afull').AsString
      else if SetRightClause > '' then
        SetLength(SetRightClause, Length(SetRightClause) - 1);

      if SetRightClause > '' then
      begin
        if MessageBox(ParentHandle,
           PChar('Распространить права доступа на существующие записи типа ' +
           Obj.GetDisplayName(Obj.SubType) + '?'),
           'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
        begin
          S := 'UPDATE ' + AListTable + ' SET ' + SetRightClause +
            ' WHERE ' + AKeyField + ' IN ('+ 'SELECT ' + AListTableAlias + '.' + AKeyField + ' ' +
            TgdcBaseCrack(Obj).GetFromClause(False) + TgdcBaseCrack(Obj).GetWhereClause + ')';

          ExecSingleQuery(S);
        end;
      end;
    finally
      Obj.Free;
    end;
  end;

var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCEXPLORER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCEXPLORER', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCEXPLORER') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCEXPLORER',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCEXPLORER' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FDataTransfer then
    exit;

  inherited DoBeforePost;

  if (FieldByName('subtype').AsString > '') then
  begin
    FieldByName('subtype').AsString :=
      UpperCase(Trim(FieldByName('subtype').AsString));

    for I := 1 to Length(FieldByName('subtype').AsString) do
    begin
      if not (FieldByName('subtype').AsString[I] in cst_sbt_Symbols) then
      begin
        raise EgdcException.Create('Недопустимый символ в подтипе "' +
            FieldByName('subtype').AsString + '".');
      end;
    end;
  end;

  if (GetClass(FieldByName('classname').AsString) <> nil) and (sView in BaseState)
    and (FieldChanged('aview') or FieldChanged('achag') or FieldChanged('afull'))
    and (State = dsEdit) then
  begin
    SetAccessRightsForExistingRecords;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCEXPLORER', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCEXPLORER', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

class function TgdcExplorer.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgExplorer';
end;

class function TgdcExplorer.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcExplorer.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'gd_command';
end;

function TgdcExplorer.GetSecCondition: String;
begin
  Result := '';
end;

class function TgdcExplorer.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByExplorer;'
end;

class function TgdcExplorer.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmExplorer';
end;

class function TgdcExplorer.NeedModifyFromStream(const SubType: String): Boolean;
begin
  Result := True;
end;

procedure TgdcExplorer.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  {
  if HasSubSet('ByExplorer') then
  begin
    S.Add('z.id > 710000'); // саму "голову" Исследователь в дерево не будем включать
    S.Add('z.disabled = 0'); // Только активные пункты меню. Таким образом мы можем отключать
                             // не неужные пункты меню не удаляя их из gd_command и затем при
                             // Upgrade все будет нормально.
  end;
  }
end;

function TgdcExplorer.Get_gdcClass: CgdcBase;
var
  Cl: TClass;
begin
  Result := nil;
  if RecordCount > 0 then
  begin
    Cl := GetClass(FieldByName('classname').AsString);
    if (Cl <> nil) and Cl.InheritsFrom(TgdcBase) then
      Result := CgdcBase(Cl);
  end;
end;

procedure TgdcExplorer.InternalSetFieldData(Field: TField;
  Buffer: Pointer);
var
  Res: OleVariant;
begin
  inherited;

  if FDataTransfer then
    exit;

  if (UpperCase(Field.FieldName) = 'PARENT')
    and (not (sLoadFromStream in BaseState))
    and (not Field.IsNull) then
  begin
    ExecSingleQueryResult('SELECT aview, achag, afull FROM gd_command WHERE id = :ID',
      Field.AsInteger, Res);

    if not VarIsEmpty(Res) then
    begin
      FieldByName('aview').AsInteger := Res[0, 0];
      FieldByName('achag').AsInteger := Res[1, 0];
      FieldByName('afull').AsInteger := Res[2, 0];
    end;
  end;
end;

procedure TgdcExplorer.RemoveSubType(const AClassName, ASubType: String);
var
  C: TPersistentClass;
  S: String;
  F: TgsStorageFolder;
  V: TgsStorageValue;
begin
  C := GetClass(AClassName);
  if (C <> nil) and (C.InheritsFrom(TgdcBase)) then
  begin
    if Assigned(GlobalStorage) then
    begin
      F := GlobalStorage.OpenFolder('SubTypes', False);
      try
        if Assigned(F) then
        begin
          V := F.ValueByName(C.ClassName);
          if V <> nil then
          begin
            if V is TgsStringValue then
            begin
              S := StringReplace(V.AsString + ',', ASubType + '=' + ASubType + ',', '', [rfReplaceAll]);
              if (Length(S) > 0) and (S[Length(S)] = ',') then
              begin
                SetLength(S, Length(S) - 1);
              end;
              if S > '' then
                V.AsString := S
              else
                F.DeleteValue(C.ClassName);
            end else
              F.DeleteValue(C.ClassName);
          end;
        end;
      finally
        GlobalStorage.CloseFolder(F);
      end;
    end;
  end;
end;

procedure TgdcExplorer.ShowProgram(const AlwaysCreateWindow: Boolean = False);
var
  F: TrpCustomFunction;
  R: TgdcReport;
  P: Variant;
begin
  CheckBrowseMode;

  if ((FieldByName('afull').AsInteger
    or FieldByName('achag').AsInteger
    or FieldByName('aview').AsInteger or 1) and IBLogin.InGroup) = 0 then
  begin
    MessageBox(ParentHandle,
      'У вас нет прав для доступа к данному разделу.',
      'Внимание',
      MB_OK or MB_ICONHAND or MB_TASKMODAL);
    exit;
  end;

  case FieldByName('cmdtype').AsInteger of

    cst_expl_cmdtype_function:
    begin
      F := glbFunctionList.FindFunction(gdcBaseManager.GetIDByRUIDString(FieldByName('cmd').AsString));
      if Assigned(F) then
      try
        P := VarArrayOf([]);
        if ScriptFactory.InputParams(F, P) then
          ScriptFactory.ExecuteFunction(F, P);
      finally
        glbFunctionList.ReleaseFunction(F);
      end;
    end;

    cst_expl_cmdtype_report:
    begin
      Assert(ClientReport <> nil);

      R := TgdcReport.Create(nil);
      try
        R.SubSet := 'ByID';
        R.ID := gdcBaseManager.GetIDByRUIDString(FieldByName('cmd').AsString);
        R.Open;

        if not R.Eof then
          ClientReport.BuildReport(Unassigned, R.ID)
        else
          MessageBox(ParentHandle,
            'Отчет не найден или нет прав доступа.',
            'Внимание',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
      finally
        R.Free;
      end;
    end;

  else
    if FieldByName('classname').AsString > '' then
    begin
      // JKL: Вынесено в отдельную функцию
      ViewFormByClass(FieldByName('classname').AsString, FieldByName('subtype').AsString,
        AlwaysCreateWindow);
    end;
  end;
end;

function ViewFormByClass(const AnClassName, AnSubType: String;
  const AlwaysCreateWindow: Boolean): TForm;
var
  FormClass: TFormClass;
  Cl: TPersistentClass;
  OldCursor: TCursor;
begin
  Result := nil;
  if StrIPos(USERFORM_PREFIX, AnClassName) = 1 then
  begin
    try
      Cl := GetClass(AnsiUpperCase(GlobalStorage.ReadString(
        st_ds_NewFormPath + '\' + AnClassName, st_ds_FormClass)));

      if (Cl <> nil) and Cl.InheritsFrom(TgdcCreateableForm) then
      begin
        if not AlwaysCreateWindow then
        begin
          Result := CgdcCreateableForm(Cl).FindForm(CgdcCreateableForm(Cl), '', AnClassName);
          if Result = nil then
            Result := CgdcCreateableForm(Cl).CreateUser(Application,
              AnClassName);
        end else
        begin
          Result := CgdcCreateableForm(Cl).CreateUser(Application,
            AnClassName);
        end;
        if Result <> nil then
          Result.Show;
      end;
    except
      { TODO :
подавление исключения тут потому что Юля
к имени формы вручную прибавляет РУИД какого-то
профиля. естественно что для пользовательской
формы отыскать ресурс с таким именем не удается и возникает
исключение. }
    end;
  end else
  begin
    Cl := Classes.GetClass(AnClassName);
    OldCursor := Screen.Cursor;
    try
      try
        // JKL: Тут можно оптимизировать код
        if (Cl <> nil) and Cl.InheritsFrom(TForm) then
        begin
          FormClass := TFormClass(Cl);

          if FormClass.InheritsFrom(TCreateableForm) and (not AlwaysCreateWindow) then
          begin
            Result := CCreateableForm(FormClass).CreateAndAssign(Application);
          end else
          begin
            Result := FormClass.Create(Application);
          end;
        end else if (Cl <> nil) and Cl.InheritsFrom(TgdcBase) then
        begin
          Result := CgdcBase(Cl).CreateViewForm(Application, '', AnSubType,
            AlwaysCreateWindow);
        end else
          if Cl = nil then
            MessageBox(0,
              PChar('Незарэгістраваны кляс ' + AnClassName),
              'Памылка',
              MB_OK or MB_ICONHAND or MB_TASKMODAL);

        if Result <> nil then
        begin
          Result.Show;
        end;
      except
        Result.Free;
        raise;
      end;
    finally
      Screen.Cursor := OldCursor;
    end;
  end;
end;

function TgdcExplorer.TestSubType(const AClassName,
  ASubType: String): Boolean;
var
  C: TPersistentClass;
begin
  Result := False;

  C := GetClass(AClassName);

  if (C <> nil) and (C.InheritsFrom(TgdcBase)) and (ASubType > '')then
    Result := CgdcBase(C).CheckSubType(ASubType);
end;

procedure TgdcExplorer._SaveToStream(Stream: TStream;
  ObjectSet: TgdcObjectSet; PropertyList: TgdcPropertySets;
  BindedList: TgdcObjectSet;
  WithDetailList: TgdKeyArray; const SaveDetailObjects: Boolean);
var
  f: TgdcFunction;
  R: TgdcReport;
  AnID: Integer;
begin
  inherited;

  case FieldByName('cmdtype').AsInteger of

    {Если у нас исследователь связан с функцией, сохраним и ее в поток}
    cst_expl_cmdtype_function:
    begin
      AnID := gdcBaseManager.GetIDByRUIDString(FieldByName('cmd').AsString);
      if ((not Assigned(BindedList)) or (BindedList.Find(AnID) = -1)) and (AnID > 0)then
      begin
        f := TgdcFunction.CreateSingularByID(Self, AnID, '') as TgdcFunction;
        try
          f.Open;
          f._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects);
        finally
          f.Free;
        end;
      end;
    end;

    cst_expl_cmdtype_report:
    begin
      R := TgdcReport.Create(nil);
      try
        R.SubSet := 'ByID';
        R.ID := gdcBaseManager.GetIDByRUIDString(FieldByName('cmd').AsString);
        R.Open;

        if not R.Eof then
          R._SaveToStream(Stream, ObjectSet, PropertyList, BindedList, WithDetailList, SaveDetailObjects)
        else
          MessageBox(ParentHandle,
            PChar('Отчет RUID=' + FieldByName('cmd').AsString + ' не найден или недостаточно прав доступа.'),
            'Внимание',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
      finally
        R.Free;
      end;
    end;
  end;
end;

procedure TgdcExplorer.SubNewPopup(ATBSI: TTBSubmenuItem;
  const AnOnlySameLevel: Boolean;
  ADisabled: TClassList = nil);
var
  I, J: Integer;
  OL: TObjectList;
  TBEI: TTBExtItem;
begin
  if ATBSI = nil then
    raise Exception.Create('SubmenuItem is nil');

  ATBSI.Clear;

  OL := TObjectList.Create(False);
    try
    if GetChildrenClass(SubType, OL) then
    begin
      for I := 0 to OL.Count - 1 do
      begin
        TBEI := TTBExtItem.Create(ATBSI);
        TBEI.Caption := TgdClassEntry(OL[I]).Caption;
        if TBEI.Caption = '' then
          TBEI.Caption := TgdClassEntry(OL[I]).TheClass.ClassName;
        TBEI.Obj := OL[I];
        TBEI.AsChildren := False;
        TBEI.OnClick := DoOnDescendantClick;
        TBEI.ImageIndex := 0;
        if ADisabled <> nil then
          for J := 0 to ADisabled.Count - 1 do
          begin
            if ADisabled[J] = TgdClassEntry(OL[I]).TheClass then
              TBEI.Enabled := False;
          end;
        ATBSI.Add(TBEI);
      end;

    end;
  finally
    OL.Free;
  end;
end;

procedure TgdcExplorer.SubNewPopup(AMI: TMenuItem;
  const AnOnlySameLevel: Boolean;
  ADisabled: TClassList = nil);
var
  I, J: Integer;
  OL: TObjectList;
  EMI: TExtMenuItem;
begin
  if AMI = nil then
    raise Exception.Create('SubmenuItem is nil');

  AMI.Clear;

  OL := TObjectList.Create(False);
  try
    if GetChildrenClass(SubType, OL) then
    begin
      for I := 0 to OL.Count - 1 do
      begin
        EMI := TExtMenuItem.Create(AMI);
        EMI.Caption := TgdClassEntry(OL[I]).Caption;
        if EMI.Caption = '' then
          EMI.Caption := TgdClassEntry(OL[I]).TheClass.ClassName;
        EMI.Obj := OL[I];
        EMI.AsChildren := False;
        EMI.OnClick := DoOnDescendantClick;
        EMI.ImageIndex := 0;
        if ADisabled <> nil then
          for J := 0 to ADisabled.Count - 1 do
          begin
            if ADisabled[J] = TgdClassEntry(OL[I]).TheClass then
              EMI.Enabled := False;
          end;
        AMI.Add(EMI);
      end;
    end;
  finally
    OL.Free;
  end;
end;

function TgdcExplorer.GetDescendantCount(const AnOnlySameLevel: Boolean): Integer;
var
  OL: TObjectList;
begin
  OL := TObjectList.Create(False);
  try
    GetChildrenClass(SubType, OL);
    Result := OL.Count;
  finally
    OL.Free;
  end;
end;

initialization
  RegisterGdcClass(TgdcExplorer);

finalization
  UnRegisterGdcClass(TgdcExplorer);
end.
