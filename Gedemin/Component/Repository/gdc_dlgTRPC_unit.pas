
unit gdc_dlgTRPC_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, contnrs,
  Forms, Dialogs,
  gdc_dlgTR_unit, ComCtrls, IBDatabase, Db, ActnList, StdCtrls,
  at_Container, DBCtrls, Menus, gdcBaseInterface;

type
  Tgdc_dlgTRPC = class(Tgdc_dlgTR)
    pgcMain: TPageControl;
    tbsMain: TTabSheet;
    tbsAttr: TTabSheet;
    atcMain: TatContainer;
    labelID: TLabel;
    dbtxtID: TDBText;
    procedure FormCreate(Sender: TObject);
    procedure pgcMainChange(Sender: TObject);
    procedure pgcMainChanging(Sender: TObject; var AllowChange: Boolean);
    procedure actNewExecute(Sender: TObject);

  private
    //указывает, отображены ли уже страницы-множества
    FIsShowSetTabSheet: Boolean;

    //Указывает есть ли у объекта связанные таблицы-множества
    //Инициализируется в методе Setup
    FHasTabSheet: Boolean;

    class procedure RegisterMethod;

  protected
    //Заменяет знак $ на его код
    function CorrectRelationName(ARelationName: String): String;

    //Возвращает первоначально имя таблицы по названию табшита
    function FirstRelationName(ATabName: String): String;

    //Создает дополнительные страницы для работы с множествами
    procedure CreateTabSheet;

    { TODO : 
много где мы работаем используя эту функцию, но
ведь не только закладки с множествами нас должны интересовать
но и компоненты -- выпадающие списки множеств -- на
закладке атрибутов }
    //Проверяет, если ли страницы для работы со множествами
    function HasTabSheet: Boolean;

    //Перечитывает страницы и отображает или скрывает их
    procedure ShowTabSheet;

    //Указывает необходимо ли отображать страницу
    function NeedVisibleTabSheet(const ARelationName: String): Boolean; virtual;

    //Если объект в состоянии вставки, делает Post
    //Вызывает метод для создания (отображения) дополнительных страниц
    procedure SaveAndShowTabSheet; virtual;

    //Указывает нестандартный базовый класс для Choose по имени таблицы
    function GetgdcClass(ARelationName: String): String; virtual;

    //Указывает нестандартный компонент выбора для Choose по имени таблицы
    function GetChooseComponentName(ARelationName: String): String; virtual;

    //Указывает сабсет для компонента выбора для Choose по имени таблицы
    function GetChooseSubSet(ARelationName: String): String; virtual;

    //Указывает нестандартный сабтайп  для Choose по имени таблицы
    function GetChooseSubType(ARelationName: String): TgdcSubType; virtual;

    function OnInvoker(const Name: WideString; AnParams: OleVariant): OleVariant; override;

  public
    procedure SetupDialog; override;
    procedure SetupRecord; override;
    procedure SyncControls; override;

    //Указывает отобразили ли мы дополнительные страницы
    property IsShowSetTabSheet: Boolean read FIsShowSetTabSheet;

    procedure SaveSettings; override;
  end;

var
  gdc_dlgTRPC: Tgdc_dlgTRPC;

implementation
{$R *.DFM}

uses
  ExtCtrls, gdcBase, gsIBGrid, at_classes, gsIBLookupComboBox,
  gdc_framSetControl_unit, gd_ClassList, at_sql_parser;

const
//Префикс имени страницы, созданной для работы со множеством
  cstTabSheetPrefix = 'set_tsh_';
//Префикс фрейма, созданного для работы со множеством
  cstFramePrefix = 'set_frm_';

procedure Tgdc_dlgTRPC.FormCreate(Sender: TObject);
begin
  inherited;
  pgcMain.ActivePageIndex := 0;
end;

procedure Tgdc_dlgTRPC.SyncControls;
begin
  inherited;
  if Assigned(gdcObject) then
    tbsAttr.TabVisible := gdcObject.HasAttribute;
end;

procedure Tgdc_dlgTRPC.pgcMainChange(Sender: TObject);
var
  I: Integer;
begin
  if pgcMain.ActivePage <> nil then
    for I := 0 to pgcMain.ActivePage.ControlCount - 1 do
      if pgcMain.ActivePage.Controls[I] is Tgdc_framSetControl then
        with pgcMain.ActivePage.Controls[I] as Tgdc_framSetControl do
        begin
          if (DS.DataSet <> nil) and (not DS.DataSet.Active) then
          with DS.DataSet as TgdcBase do
          begin
            if not DS.DataSet.Active then
            begin
              DS.DataSet.Open;
              SetupGrid;
            end;

          end;

          break;
        end;
end;

procedure Tgdc_dlgTRPC.CreateTabSheet;
var
  I, J, K: Integer;
  F, FD: TatRelationField;
  TS: TTabSheet;
  SO: TgdcBase;
  C: TgdcFullClass;
  Fr: Tgdc_framSetControl;
  AttrLast: Boolean;
  OL: TObjectList;
  FList, LinkTableList: TStrings;
begin
  //
  AttrLast := tbsAttr.PageIndex = pgcMain.PageCount - 1;

  if FHasTabSheet
    and (not FIsShowSetTabSheet)
    and Assigned(gdcObject) then
  begin
    LinkTableList := TStringList.Create;
    try
      FIsShowSetTabSheet := True;

      // теперь найдем все таблицы, первичный ключ которых одновременно
      // является ссылкой на нашу запись, т.е. таблицы связанные
      // жесткой связью один-к-одному с нашей таблицей
      // записи в таких таблицах, в совокупности с записью в главной
      // таблице, представляют данные одного объекта
      // пример: gd_contact -- gd_company -- gd_companycode
      OL := TObjectList.Create(False);
      FList := TStringList.Create;
      try
        (FList as TStringList).Sorted := True;
        //Считаем все таблицы, входящие в селект запрос
        GetTablesName(gdcObject.SelectSQL.Text, FList);
        atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
          gdcObject.GetListTable(SubType), OL);
        for I := 0 to OL.Count - 1 do
          with OL[I] as TatForeignKey do
        begin
          if IsSimpleKey
            and (Relation.PrimaryKey <> nil)
            and (Relation.PrimaryKey.ConstraintFields.Count = 1)
            and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0])
            and (FList.IndexOf(AnsiUpperCase(Trim(Relation.RelationName))) > -1) then
          begin
            //Сохраним только те таблицы, которые ссылаются на главную таблицу 1:1
            //и присутствуют в селект запросе объекта
            LinkTableList.Add(Trim(Relation.RelationName));
          end;
        end;
      finally
        OL.Free;
        FList.Free;
      end;

      //Добавим в список и главную таблицу объекта
      LinkTableList.Insert(0, gdcObject.GetListTable(SubType));

      for I := 0 to atDatabase.PrimaryKeys.Count - 1 do
        with atDatabase.PrimaryKeys[I] do
        if ConstraintFields.Count > 1 then
        begin
          F := nil;
          FD := nil;

          for K := 0 to LinkTableList.Count - 1 do
          begin
            if (ConstraintFields[0].References <> nil) and
              (AnsiCompareText(ConstraintFields[0].References.RelationName,
               LinkTableList[K]) = 0)
            then
            begin
              F := ConstraintFields[0];
              Break;
            end;
          end;

          if not Assigned(F) then
            continue;

          //Вытянем поле со второй ссылкой
          for K := 1 to ConstraintFields.Count - 1 do
          begin
            if (ConstraintFields[K].References <> nil) and
               (ConstraintFields[K] <> F) and (FD = nil)
            then
            begin
              FD := ConstraintFields[K];
              Break;
            end else

            //Если у нас полей-ссылок в первичном ключе > 2
            if (ConstraintFields[K].References <> nil) and
               (ConstraintFields[K] <> F) and (FD <> nil)
            then
            begin
              continue;
            end;
          end;

          if not Assigned(FD) then
            continue;

          if not NeedVisibleTabSheet(FD.Relation.RelationName) then
            continue;

          TS := TTabSheet.Create(Self);
          TS.Name := cstTabSheetPrefix + CorrectRelationName(FD.Relation.RelationName);
          TS.Caption := '';
          TS.PageControl := pgcMain;

          with F.References do
            for J := 0 to RelationFields.Count - 1 do
              if RelationFields[J].CrossRelation = F.Relation then
              begin
                TS.Caption := RelationFields[J].LShortName;
                break;
              end;

          if TS.Caption = '' then
          begin
            C := GetBaseClassForRelation(FD.Relation.RelationName);
            if C.gdClass <> nil then
              TS.Caption := C.gdClass.GetDisplayName(C.SubType)
            else
              TS.Caption := FD.Relation.LShortName;
          end;

          C := GetBaseClassForRelation(FD.References.RelationName);

          if C.gdClass <> nil then
          begin
            Fr := Tgdc_framSetControl.Create(Self);
            Fr.Name := cstFramePrefix + CorrectRelationName(FD.Relation.RelationName);
            Fr.Parent := TS;
            Fr.Transaction := ibtrCommon;
            Fr.LoadSettings;
            Fr.Align := alClient;

            if GetgdcClass(FD.Relation.RelationName) > '' then
              Fr.gdcClass := GetgdcClass(FD.Relation.RelationName)
            else
              Fr.gdcClass := C.gdClass.ClassName;

            if GetChooseComponentName(FD.Relation.RelationName) > '' then
              Fr.ChooseComponentName := GetChooseComponentName(FD.Relation.RelationName);

            if GetChooseSubSet(FD.Relation.RelationName) > '' then
              Fr.ChooseSubSet := GetChooseSubSet(FD.Relation.RelationName);

            if GetChooseSubType(FD.Relation.RelationName) > '' then
              Fr.ChooseSubType := GetChooseSubType(FD.Relation.RelationName)
            else
              Fr.ChooseSubType := C.SubType;

            SO := C.gdClass.CreateSubType(Self, C.SubType);
            SO.Name := cstFramePrefix + CorrectRelationName(FD.Relation.RelationName)
              + '_gdc';
            SO.MasterSource := dsgdcBase;
            SO.SetTable := FD.Relation.RelationName;
            SO.ReadTransaction := gdcObject.Transaction;

            Fr.DS.DataSet := SO;

            Fr.Lk.Transaction := ibtrCommon;
            Fr.Lk.SubType := Fr.ChooseSubType;
            Fr.Lk.gdClassName := Fr.gdcClass;
          end
          else
            TS.Free;
        end;
    finally
      LinkTableList.Free;
    end;
  end;
  if AttrLast then
    tbsAttr.PageIndex := pgcMain.PageCount - 1;
end;

function Tgdc_dlgTRPC.NeedVisibleTabSheet(const ARelationName: String): Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_NEEDVISIBLETABSHEET('TGDC_DLGTRPC', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGTRPC', KEYNEEDVISIBLETABSHEET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYNEEDVISIBLETABSHEET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}        'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = varBoolean then
  {M}          Result := Boolean(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}      begin
  {M}        Result := True; //Inherited NeedVisibleTabSheet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := True;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'NEEDVISIBLETABSHEET', KEYNEEDVISIBLETABSHEET);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTRPC.pgcMainChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  SaveAndShowTabSheet;
  AllowChange := gdcObject.State <> dsInsert;
end;

procedure Tgdc_dlgTRPC.SaveAndShowTabSheet;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  OldIsTransaction: Boolean;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTRPC', 'SAVEANDSHOWTABSHEET', KEYSAVEANDSHOWTABSHEET)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTRPC', KEYSAVEANDSHOWTABSHEET);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVEANDSHOWTABSHEET]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}          'SAVEANDSHOWTABSHEET', KEYSAVEANDSHOWTABSHEET, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if FHasTabSheet then
  begin
    if gdcObject.State = dsInsert then
    begin
      CallBeforePost;
      if TestCorrect then
      begin
        try
          OldIsTransaction := FIsTransaction;
          FIsTransaction := True;
          try
            Post;
          finally
            FIsTransaction := OldIsTransaction;
          end;
        except
          on E: Exception do
          begin
            Application.ShowException(E);
            exit;
          end;
        end;
      end else
        exit;
    end;
    if gdcObject.State = dsBrowse then
    begin
      gdcObject.Edit;
      SetupRecord;
    end;
    if not IsShowSetTabSheet then
    begin
      CreateTabSheet;
      ShowTabSheet;
    end;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'SAVEANDSHOWTABSHEET', KEYSAVEANDSHOWTABSHEET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'SAVEANDSHOWTABSHEET', KEYSAVEANDSHOWTABSHEET);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTRPC.ShowTabSheet;
var
  I: Integer;
begin
  for I := 0 to pgcMain.PageCount - 1 do
    if AnsiPos(cstTabSheetPrefix, pgcMain.Pages[I].Name) = 1 then
      pgcMain.Pages[I].TabVisible := NeedVisibleTabSheet(FirstRelationName(pgcMain.Pages[I].Name));
end;

function Tgdc_dlgTRPC.CorrectRelationName(ARelationName: String): String;
begin
  Result := StringReplace(ARelationName, '$', '_alt_' + IntToStr(Ord('$')), [rfReplaceAll]);
end;

function Tgdc_dlgTRPC.FirstRelationName(ATabName: String): String;
begin
  Result := StringReplace(Copy(ATabName,
    Length(cstTabSheetPrefix) + 1, Length(ATabName) - Length(cstTabSheetPrefix)),
    '_alt_' + IntToStr(Ord('$')), '$',  [rfReplaceAll]);
end;

function Tgdc_dlgTRPC.GetChooseSubSet(ARelationName: String): String;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_GETCHOOSESUBSET('TGDC_DLGTRPC', 'GETCHOOSESUBSET', KEYGETCHOOSESUBSET)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGTRPC', KEYGETCHOOSESUBSET);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETCHOOSESUBSET]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}        'GETCHOOSESUBSET', KEYGETCHOOSESUBSET, Params, LResult) then
  {M}      begin
  {M}        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}          Result := String(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}      begin
  {M}        Result := '';//Inherited GetChooseSubSet(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'GETCHOOSESUBSET', KEYGETCHOOSESUBSET)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'GETCHOOSESUBSET', KEYGETCHOOSESUBSET);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgTRPC.GetChooseSubType(ARelationName: String): TgdcSubType;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_GETCHOOSESUBTYPE('TGDC_DLGTRPC', 'GETCHOOSESUBTYPE', KEYGETCHOOSESUBTYPE)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGTRPC', KEYGETCHOOSESUBTYPE);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETCHOOSESUBTYPE]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}        'GETCHOOSESUBTYPE', KEYGETCHOOSESUBTYPE, Params, LResult) then
  {M}      begin
  {M}        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}          Result := ShortString(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}      begin
  {M}        Result := '';//Inherited GetChooseSubType(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'GETCHOOSESUBTYPE', KEYGETCHOOSESUBTYPE)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'GETCHOOSESUBTYPE', KEYGETCHOOSESUBTYPE);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgTRPC.GetChooseComponentName(ARelationName: String): String;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_GETCHOOSECOMPONENTNAME('TGDC_DLGTRPC', 'GETCHOOSECOMPONENTNAME', KEYGETCHOOSECOMPONENTNAME)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGTRPC', KEYGETCHOOSECOMPONENTNAME);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETCHOOSECOMPONENTNAME]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}        'GETCHOOSECOMPONENTNAME', KEYGETCHOOSECOMPONENTNAME, Params, LResult) then
  {M}      begin
  {M}        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}          Result := ShortString(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}      begin
  {M}        Result := '';//Inherited GetChooseComponentName(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'GETCHOOSECOMPONENTNAME', KEYGETCHOOSECOMPONENTNAME)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'GETCHOOSECOMPONENTNAME', KEYGETCHOOSECOMPONENTNAME);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgTRPC.GetgdcClass(ARelationName: String): String;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_DLGTRPC_GETGDCCLASS('TGDC_DLGTRPC', 'GETGDCCLASS', KEYGETGDCCLASS)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGTRPC', KEYGETGDCCLASS);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGDCCLASS]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}        'GETGDCCLASS', KEYGETGDCCLASS, Params, LResult) then
  {M}      begin
  {M}        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}          Result := ShortString(LResult);
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}      begin
  {M}        Result := '';//Inherited GetgdcClass(ARelationName);
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'GETGDCCLASS', KEYGETGDCCLASS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'GETGDCCLASS', KEYGETGDCCLASS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTRPC.SaveSettings;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTRPC', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTRPC', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  for I := 0 to ComponentCount - 1 do
    if Components[I] is Tgdc_framSetControl then
      (Components[I] as Tgdc_framSetControl).SaveSettings;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTRPC.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTRPC', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTRPC', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  FIsShowSetTabSheet := False;
  FHasTabSheet := HasTabSheet;

  if FHasTabSheet then
  begin
    ActivateTransaction(gdcObject.Transaction);
  end;

  inherited;

  pgcMain.ActivePage := tbsMain;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

function Tgdc_dlgTRPC.HasTabSheet: Boolean;
var
  I, K: Integer;
  F, FD: TatRelationField;
  OL: TObjectList;
  FList: TStrings;
  LinkTableList: TStrings;
begin
  Assert(Assigned(gdcObject));
  Assert(Assigned(atDatabase));

  Result := False;

  // теперь найдем все таблицы, первичный ключ которых одновременно
  // является ссылкой на нашу запись, т.е. таблицы связанные
  // жесткой связью один-к-одному с нашей таблицей
  // записи в таких таблицах, в совокупности с записью в главной
  // таблице, представляют данные одного объекта
  // пример: gd_contact -- gd_company -- gd_companycode
  LinkTableList := TStringList.Create;
  try
    OL := TObjectList.Create(False);
    FList := TStringList.Create;
    try
      (FList as TStringList).Sorted := True;
      //Считаем все таблицы, входящие в селект запрос
      GetTablesName(gdcObject.SelectSQL.Text, FList);
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(
        gdcObject.GetListTable(SubType), OL);
      for I := 0 to OL.Count - 1 do
        with OL[I] as TatForeignKey do
      begin
        if IsSimpleKey
          and (Relation.PrimaryKey <> nil)
          and (Relation.PrimaryKey.ConstraintFields.Count = 1)
          and (ConstraintField = Relation.PrimaryKey.ConstraintFields[0])
          and (FList.IndexOf(AnsiUpperCase(Trim(Relation.RelationName))) > -1) then
        begin
          //Сохраним только те таблицы, которые ссылаются на главную таблицу 1:1
          //и присутствуют в селект запросе объекта
          LinkTableList.Add(Trim(Relation.RelationName));
        end;
      end;
    finally
      OL.Free;
      FList.Free;
    end;

    //Добавим в список и главную таблицу объекта
    LinkTableList.Insert(0, gdcObject.GetListTable(SubType));

    for I := 0 to atDatabase.PrimaryKeys.Count - 1 do
      with atDatabase.PrimaryKeys[I] do
      if ConstraintFields.Count > 1 then
      begin
        {
        if not NeedVisibleTabSheet(Relation.RelationName) then
          continue;
        }  

        F := nil;
        FD := nil;

        for K := 0 to LinkTableList.Count - 1 do
        begin
          if (ConstraintFields[0].References <> nil) and
            (AnsiCompareText(ConstraintFields[0].References.RelationName,
             LinkTableList[K]) = 0)
          then
          begin
            F := ConstraintFields[0];
            Break;
          end;
        end;

        if not Assigned(F) then
          continue;

        //Вытянем поле со второй ссылкой
        for K := 0 to ConstraintFields.Count - 1 do
        begin
          if (ConstraintFields[K].References <> nil) and
             (ConstraintFields[K] <> F) and (FD = nil)
          then
          begin
            FD := ConstraintFields[K];
            Break;
          end else

          //Если у нас полей-ссылок в первичном ключе > 2
          if (ConstraintFields[K].References <> nil) and
             (ConstraintFields[K] <> F) and (FD <> nil)
          then
          begin
            continue;
          end;
        end;

        if not Assigned(FD) then
          continue;

        Result := True;
        Break;
      end;
  finally
    LinkTableList.Free;
  end;
end;

procedure Tgdc_dlgTRPC.actNewExecute(Sender: TObject);
var
  I: Integer;
begin
  inherited;
  //Прячем закладки
  for I := 0 to pgcMain.PageCount - 1 do
    if AnsiPos(cstTabSheetPrefix, pgcMain.Pages[I].Name) = 1 then
      pgcMain.Pages[I].TabVisible := False;
end;

function Tgdc_dlgTRPC.OnInvoker(const Name: WideString;
  AnParams: OleVariant): OleVariant;
begin
  if  AnsiUpperCase(Name) = 'NEEDVISIBLETABSHEET' then
  begin
    Result := NeedVisibleTabSheet(String(AnParams[1]))
  end else
  if  AnsiUpperCase(Name) = 'SAVEANDSHOWTABSHEET' then
  begin
    SaveAndShowTabSheet
  end else
  if  AnsiUpperCase(Name) = 'GETGDCCLASS' then
  begin
    Result := GetgdcClass(String(AnParams[1]))
  end else
  if  AnsiUpperCase(Name) = 'GETCHOOSECOMPONENTNAME' then
  begin
    Result := GetChooseComponentName(String(AnParams[1]))
  end else
  if  AnsiUpperCase(Name) = 'GETCHOOSESUBSET' then
  begin
    Result := GetChooseSubSet(String(AnParams[1]))
  end else
  if  AnsiUpperCase(Name) = 'GETCHOOSESUBTYPE' then
  begin
    Result := GetChooseSubType(String(AnParams[1]))
  end else
    Result := inherited OnInvoker(Name, AnParams);
end;

class procedure Tgdc_dlgTRPC.RegisterMethod;
begin
  RegisterFrmClassMethod(Tgdc_dlgTRPC, 'NeedVisibleTabSheet',
    'Self: Object; ARelationName: Variable', 'Variable');
  RegisterFrmClassMethod(Tgdc_dlgTRPC, 'SaveAndShowTabSheet', 'Self: Object', '');
  RegisterFrmClassMethod(Tgdc_dlgTRPC, 'GetgdcClass',
    'Self: Object; ARelationName: Variable', 'Variable');
  RegisterFrmClassMethod(Tgdc_dlgTRPC, 'GetChooseComponentName',
    'Self: Object; ARelationName: Variable', 'Variable');
  RegisterFrmClassMethod(Tgdc_dlgTRPC, 'GetChooseSubSet',
    'Self: Object; ARelationName: Variable', 'Variable');
  RegisterFrmClassMethod(Tgdc_dlgTRPC, 'GetChooseSubType',
    'Self: Object; ARelationName: Variable', 'Variable');
end;

procedure Tgdc_dlgTRPC.SetupRecord;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGTRPC', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGTRPC', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGTRPC') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGTRPC',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGTRPC' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  { TODO : тут кажется этот вызов лишний... }
  if FHasTabSheet then
  begin
    ActivateTransaction(gdcObject.Transaction);
  end;

  inherited;

  if FHasTabSheet and (not FIsShowSetTabSheet) then
  begin
    CreateTabSheet;
    ShowTabSheet;
  end;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

initialization
  RegisterFrmClass(Tgdc_dlgTRPC);
  Tgdc_dlgTRPC.RegisterMethod;

finalization
  UnRegisterFrmClass(Tgdc_dlgTRPC);

{@DECLARE MACRO Inh_dlgTRPC_NeedVisibleTabSheet(%ClassName%, %MethodName%, %MethodKey%)
Result := True;
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
        %MethodName%, %MethodKey%, Params, LResult) then
      begin
        if VarType(LResult) = varBoolean then
          Result := Boolean(LResult);
        exit;
      end;
    end else
      if tmpStrings.LastClass.gdClassName <> %ClassName% then
      begin
        Result := Inherited NeedVisibleTabSheet(ARelationName);
        Exit;
      end;
  end;
END MACRO}

{@DECLARE MACRO Inh_dlgTRPC_GetgdcClass(%ClassName%, %MethodName%, %MethodKey%)
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
        %MethodName%, %MethodKey%, Params, LResult) then
      begin
        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
          Result := ShortString(LResult);
        exit;
      end;
    end else
      if tmpStrings.LastClass.gdClassName <> %ClassName% then
      begin
        Result := Inherited GetgdcClass(ARelationName);
        Exit;
      end;
  end;
END MACRO}

{@DECLARE MACRO Inh_dlgTRPC_GetChooseComponentName(%ClassName%, %MethodName%, %MethodKey%)
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
        %MethodName%, %MethodKey%, Params, LResult) then
      begin
        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
          Result := ShortString(LResult);
        exit;
      end;
    end else
      if tmpStrings.LastClass.gdClassName <> %ClassName% then
      begin
        Result := Inherited GetChooseComponentName(ARelationName);
        Exit;
      end;
  end;
END MACRO}

{@DECLARE MACRO Inh_dlgTRPC_GetChooseSubSet(%ClassName%, %MethodName%, %MethodKey%)
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
        %MethodName%, %MethodKey%, Params, LResult) then
      begin
        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
          Result := String(LResult);
        exit;
      end;
    end else
      if tmpStrings.LastClass.gdClassName <> %ClassName% then
      begin
        Result := Inherited GetChooseSubSet(ARelationName);
        Exit;
      end;
  end;
END MACRO}

{@DECLARE MACRO Inh_dlgTRPC_GetChooseSubType(%ClassName%, %MethodName%, %MethodKey%)
try
  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  begin
    SetFirstMethodAssoc(%ClassName%, %MethodKey%);
    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[%MethodKey%]);
    if (tmpStrings = nil) or (tmpStrings.IndexOf(%ClassName%) = -1) then
    begin
      Params := VarArrayOf([GetGdcInterface(Self), ARelationName]);
      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, %ClassName%,
        %MethodName%, %MethodKey%, Params, LResult) then
      begin
        if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
          Result := ShortString(LResult);
        exit;
      end;
    end else
      if tmpStrings.LastClass.gdClassName <> %ClassName% then
      begin
        Result := Inherited GetChooseSubType(ARelationName);
        Exit;
      end;
  end;
END MACRO}

end.
