// ShlTanya, 21.02.2019

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
    FHasTabSheet: Boolean;

    class procedure RegisterMethod;

  protected
    FHTS: TTabSheet;
    FHMemo: TMemo;

    //Заменяет знак $ на его код
    function CorrectRelationName(ARelationName: String): String;

    //Возвращает первоначально имя таблицы по названию табшита
    function FirstRelationName(ATabName: String): String;

    //Создает дополнительные страницы для работы с множествами
    procedure CreateTabSheet;

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

    procedure SetupHelpPage(APC: TPageControl);

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
  gdc_framSetControl_unit, gd_ClassList, at_sql_parser, gdHelp_Interface;

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
  S: String;
  FC: TgdcFullClass;
begin
  if pgcMain.ActivePage <> nil then
  begin
    if pgcMain.ActivePage = FHTS then
    begin
      if (FHMemo = nil) and (gdcObject <> nil) then
      begin
        FC := gdcObject.GetCurrRecordClass;
        S := gdHelp.GetHelpText(Self.ClassName, Self.SubType,
          FC.gdClass.ClassName, FC.SubType);

        if S = '' then
          S := 'Для данного объекта нет справочной информации.';

        FHMemo := TMemo.Create(Self);
        FHMemo.Name := 'm_gd_Help';
        FHMemo.Parent := FHTS;
        FHMemo.Align := alClient;
        FHMemo.ReadOnly := True;
        FHMemo.Lines.Text := S;
      end;
    end else
    begin
      for I := 0 to pgcMain.ActivePage.ControlCount - 1 do
      begin
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
    end;
  end;
end;

procedure Tgdc_dlgTRPC.CreateTabSheet;
var
  I: Integer;
  TS: TTabSheet;
  SO: TgdcBase;
  C: TgdcFullClass;
  Fr: Tgdc_framSetControl;
  AttrLast: Boolean;
begin
  //
  AttrLast := tbsAttr.PageIndex = pgcMain.PageCount - 1;

  if HasTabSheet
    and (not FIsShowSetTabSheet)
    and Assigned(gdcObject) then
  begin
    FIsShowSetTabSheet := True;

    for I := 0 to gdcObject.SetAttributesCount - 1 do
    begin
      if not NeedVisibleTabSheet(gdcObject.SetAttributes[I].CrossRelationName) then
        continue;

      C := GetBaseClassForRelation(gdcObject.SetAttributes[I].ReferenceRelationName);

      if C.gdClass = nil then
        continue;

      TS := TTabSheet.Create(Self);
      TS.Name := cstTabSheetPrefix + CorrectRelationName(gdcObject.SetAttributes[I].CrossRelationName);
      TS.Caption := gdcObject.SetAttributes[I].Caption;
      TS.PageControl := pgcMain;

      Fr := Tgdc_framSetControl.Create(Self);
      Fr.Name := cstFramePrefix + CorrectRelationName(gdcObject.SetAttributes[I].CrossRelationName);
      Fr.Parent := TS;
      Fr.Transaction := ibtrCommon;
      Fr.LoadSettings;
      Fr.Align := alClient;

      if GetgdcClass(gdcObject.SetAttributes[I].CrossRelationName) > '' then
        Fr.gdcClass := GetgdcClass(gdcObject.SetAttributes[I].CrossRelationName)
      else
        Fr.gdcClass := C.gdClass.ClassName;

      if GetChooseComponentName(gdcObject.SetAttributes[I].CrossRelationName) > '' then
        Fr.ChooseComponentName := GetChooseComponentName(gdcObject.SetAttributes[I].CrossRelationName);

      if GetChooseSubSet(gdcObject.SetAttributes[I].CrossRelationName) > '' then
        Fr.ChooseSubSet := GetChooseSubSet(gdcObject.SetAttributes[I].CrossRelationName);

      if GetChooseSubType(gdcObject.SetAttributes[I].CrossRelationName) > '' then
        Fr.ChooseSubType := GetChooseSubType(gdcObject.SetAttributes[I].CrossRelationName)
      else
        Fr.ChooseSubType := C.SubType;

      SO := C.gdClass.CreateSubType(Self, C.SubType);
      SO.Name := cstFramePrefix + CorrectRelationName(gdcObject.SetAttributes[I].CrossRelationName)
        + '_gdc';
      SO.MasterSource := dsgdcBase;
      SO.SetTable := gdcObject.SetAttributes[I].CrossRelationName;
      SO.ReadTransaction := gdcObject.Transaction;

      Fr.DS.DataSet := SO;

      Fr.Lk.Transaction := ibtrCommon;
      Fr.Lk.SubType := Fr.ChooseSubType;
      Fr.Lk.gdClassName := Fr.gdcClass;
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
  AllowChange := (not HasTabSheet) or (gdcObject.State <> dsInsert);
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

  if HasTabSheet then
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
  I: Integer;
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

  FHasTabSheet := False;
  FIsShowSetTabSheet := False;

  for I := 0 to gdcObject.SetAttributesCount - 1 do
  begin
    if NeedVisibleTabSheet(gdcObject.SetAttributes[I].CrossRelationName)
      and (GetBaseClassForRelation(gdcObject.SetAttributes[I].ReferenceRelationName).gdClass <> nil) then
    begin
      FHasTabSheet := True;
      break;
    end;
  end;

  if HasTabSheet then
    ActivateTransaction(gdcObject.Transaction);

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
begin
  Result := (gdcObject <> nil) and FHasTabSheet;
end;

procedure Tgdc_dlgTRPC.actNewExecute(Sender: TObject);
begin
  inherited;
  pgcMain.ActivePageIndex := 0;    
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

  if HasTabSheet then
    ActivateTransaction(gdcObject.Transaction);

  inherited;

  if HasTabSheet and (not FIsShowSetTabSheet) then
  begin
    CreateTabSheet;
    ShowTabSheet;
  end;

  if FHTS = nil then
    SetupHelpPage(pgcMain);

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGTRPC', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGTRPC', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgTRPC.SetupHelpPage(APC: TPageControl);
begin
  Assert(FHTS = nil);
  FHTS := TTabSheet.Create(Self);
  FHTS.Name := cstTabSheetPrefix + '_gd_Help';
  FHTS.Caption := 'Справка';
  FHTS.PageControl := APC;
end;

initialization
  RegisterFrmClass(Tgdc_dlgTRPC, 'Диалоговое окно с вкладками').ShowInFormEditor := True;
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
