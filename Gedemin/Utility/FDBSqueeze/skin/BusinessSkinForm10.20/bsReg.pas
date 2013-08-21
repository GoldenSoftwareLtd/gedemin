{*******************************************************************}
{                                                                   }
{       Almediadev Visual Component Library                         }
{       BusinessSkinForm                                            }
{       Version 10.20                                               }
{                                                                   }
{       Copyright (c) 2000-2013 Almediadev                          }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{       Home:  http://www.almdev.com                                }
{       Support: support@almdev.com                                 }
{                                                                   }
{*******************************************************************}

unit bsreg;

{$I bsdefine.inc}

{$P+,S-,W-,R-}
{$WARNINGS OFF}
{$HINTS OFF}

interface

uses Classes, Menus, Dialogs, Forms, Controls, TypInfo,
     {$IFNDEF  VER130} DesignEditors, DesignIntf {$ELSE} DsgnIntf {$ENDIF};

type
  TbsSkinStatusBarEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TbsSkinToolBarEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TbsSkinPageControlEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TbsSkinRibbonControlEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TbsSkinRibbonAppMenuEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;


  TbsSkinRibbonPageEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TbsSkinRibbonGroupEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;
  
procedure Register;

implementation

uses
  bsUtils, BusinessSkinForm, bsSkinData, bsSkinCtrls, bsSkinHint, bsSkinGrids,
  bsSkinTabs, SysUtils, bsSkinBoxCtrls, bsSkinMenus, bsTrayIcon,
  bsDBGrids, bsDBCtrls, DB, bsCalc, bsMessages, bsSkinZip, bsSkinUnZip,
  bsFileCtrl, bsSkinShellCtrls, NBPagesEditor, bsCalendar, bsColorCtrls,
  bsDialogs, bsRootEdit, bsSkinPrinter, bsCategoryButtons, bsButtonGroup,
  bsSkinExCtrls, bsPngImageList, bsPngImage, bsPngImageEditor, bsRibbon;
  
type


  TbsBusinessSkinFormEditor = class(TComponentEditor)
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: integer; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

  TbsPNGPropertyEditor = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: String; override;
  end;

  TbsFilenameProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TbsDBStringProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TbsSkinDataNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TbsLabelSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsStdLabelSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsButtonSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsHeaderSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsRibbonDividerSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsButtonExSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsCalendarSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsCategoryButtonSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsCategorySkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsTrackEditSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsEditSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsSpinEditSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsGaugeSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsToolBarSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsMenuButtonSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsPanelSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsListBoxSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsOfficeListBoxSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsComboBoxSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

   TbsCheckListBoxSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  TbsSplitterSkinDataNameProperty = class(TbsSkinDataNameProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

  procedure TbsPNGPropertyEditor.Edit;
  begin
    if PropCount <> 1 then Exit;
    ExecutePngEditor(TbsPngImageItem(GetComponent(0)).PngImage);
    Designer.Modified;
  end;

  function TbsPNGPropertyEditor.GetAttributes: TPropertyAttributes;
  begin
    Result := inherited GetAttributes + [paDialog, paReadOnly];
  end;

  function TbsPNGPropertyEditor.GetValue: String;
  var
    P: TbsPngImage;
  begin
    P := TbsPngImageItem(GetComponent(0)).PngImage;
    if not P.Empty
    then
      Result := 'PNG image'
    else
      Result := '(none)';
  end;

  procedure TbsSkinDataNameProperty.GetValueList(List: TStrings);
  begin
  end;

  procedure TbsSkinDataNameProperty.GetValues(Proc: TGetStrProc);
  var
    I: Integer;
    Values: TStringList;
  begin
    Values := TStringList.Create;
    try
      GetValueList(Values);
      for I := 0 to Values.Count - 1 do Proc(Values[I]);
    finally
      Values.Free;
    end;
  end;

  function TbsSkinDataNameProperty.GetAttributes: TPropertyAttributes;
  begin
    Result := [paValueList, paMultiSelect];
  end;

  procedure TbsRibbonDividerSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('officegroupdivider');
    List.Add('menupagedivider');
    List.Add('bevel');
  end;

  procedure TbsButtonSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('button');
    List.Add('resizebutton');
    List.Add('toolbutton');
    List.Add('bigtoolbutton');
    List.Add('resizetoolbutton');
  end;

  procedure TbsHeaderSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('header');
    List.Add('resizetoolbutton');
    List.Add('resizebutton');
  end;

  procedure TbsButtonExSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('resizebutton');
    List.Add('resizetoolbutton');
  end;

  procedure TbsLabelSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('label');
    List.Add('appmenuheader');
  end;

  procedure TbsStdLabelSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('stdlabel');
    List.Add('appmenustdlabel');
  end;

   procedure TbsCategoryButtonSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('button');
    List.Add('resizebutton');
    List.Add('toolbutton');
    List.Add('bigtoolbutton');
    List.Add('resizetoolbutton');
  end;

  procedure TbsCategorySkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('resizetoolpanel');
    List.Add('panel');
  end;

  procedure TbsTrackEditSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('buttonedit');
    List.Add('statusbuttonedit');
    List.Add('toolbuttonedit');
  end;

  procedure TbsEditSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('edit');
    List.Add('buttonedit');
    List.Add('statusedit');
    List.Add('statusbuttonedit');
  end;

  procedure TbsSpinEditSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('spinedit');
    List.Add('statusspinedit');
  end;

  procedure TbsGaugeSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('gauge');
    List.Add('vgauge');
    List.Add('statusgauge');
  end;

  procedure TbsMenuButtonSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('toolmenubutton');
    List.Add('bigtoolmenubutton');
    List.Add('toolmenutrackbutton');
    List.Add('bigtoolmenutrackbutton');
    List.Add('resizetoolbutton');
    List.Add('resizebutton');
  end;

  procedure TbsToolBarSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('toolpanel');
    List.Add('bigtoolpanel');
    List.Add('resizetoolpanel');
    List.Add('panel');
  end;

  procedure TbsPanelSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('panel');
    List.Add('resizetoolpanel');
    List.Add('toolpanel');
    List.Add('bigtoolpanel');
    List.Add('statusbar');
    List.Add('groupbox');
  end;

  procedure TbsCalendarSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('panel');
    List.Add('groupbox');
    List.Add('resizetoolpanel');
  end;

  procedure TbsListBoxSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('listbox');
    List.Add('captionlistbox');
  end;

  procedure TbsOfficeListBoxSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('listbox');
    List.Add('resizetoolpanel');
    List.Add('panel');
    List.Add('memo');
    List.Add('menupagepanel')
  end;

  procedure TbsComboBoxSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('combobox');
    List.Add('captioncombobox');
    List.Add('statuscombobox');
  end;

  procedure TbsCheckListBoxSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('checklistbox');
    List.Add('captionchecklistbox');
  end;

  procedure TbsSplitterSkinDataNameProperty.GetValueList(List: TStrings);
  begin
    List.Add('vsplitter');
    List.Add('hsplitter');
  end;

  procedure TbsFilenameProperty.Edit;
  var
    FileOpen: TOpenDialog;
  begin
    FileOpen := TOpenDialog.Create(Application);
    try
      FileOpen.Filename := '';
      FileOpen.InitialDir := ExtractFilePath(FileOpen.Filename);
      FileOpen.Filter := '*.*|*.*';
      FileOpen.Options := FileOpen.Options + [ofHideReadOnly];
      if FileOpen.Execute then SetValue(FileOpen.Filename);
    finally
      FileOpen.Free;
    end;
  end;

  function TbsFilenameProperty.GetAttributes: TPropertyAttributes;
  begin
    Result := [paDialog , paRevertable];
  end;

  function TbsDBStringProperty.GetAttributes: TPropertyAttributes;
  begin
    Result := [paValueList, paSortList, paMultiSelect];
  end;

  procedure TbsDBStringProperty.GetValueList(List: TStrings);
  begin
  end;

procedure TbsDBStringProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

type

  TbsColumnDataFieldProperty = class(TbsDBStringProperty)
    procedure GetValueList(List: TStrings); override;
  end;

procedure TbsColumnDataFieldProperty.GetValueList(List: TStrings);
var
  Grid: TbsSkinCustomDBGrid;
  DataSource: TDataSource;
begin
  Grid := (GetComponent(0) as TbsColumn).Grid;
  if (Grid = nil) then Exit;
  DataSource := Grid.DataSource;
  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
    DataSource.DataSet.GetFieldNames(List);
end;

type
  TbsSkinDBLookUpListBoxFieldProperty = class(TbsDBStringProperty)
    procedure GetValueList(List: TStrings); override;
  end;

procedure TbsSkinDBLookUpListBoxFieldProperty.GetValueList(List: TStrings);
var
  DataSource: TDataSource;
  LookUpControl: TbsDBLookUpControl;
begin
  DataSource := (GetComponent(0) as TbsSkinDBLookUpListBox).ListSource;
  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
    DataSource.DataSet.GetFieldNames(List);
end;

type
  TbsSkinDBLookUpComboBoxFieldProperty = class(TbsDBStringProperty)
    procedure GetValueList(List: TStrings); override;
  end;

procedure TbsSkinDBLookUpComboBoxFieldProperty.GetValueList(List: TStrings);
var
  DataSource: TDataSource;
  LookUpControl: TbsDBLookUpControl;
begin
  DataSource := (GetComponent(0) as TbsSkinDBLookUpComboBox).ListSource;
  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
    DataSource.DataSet.GetFieldNames(List);
end;

type
  TbsSetPagesProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure SetValue(const Value: string); override;
   end;

procedure TbsSetPagesProperty.Edit;
var
  NB: TbsSkinNoteBook;
begin
  try
    NB := TbsSkinNoteBook(GetComponent(0));
    NBPagesEditor.Execute(NB);
  finally
  end;
end;

function TbsSetPagesProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

function TbsSetPagesProperty.GetValue: string;
begin
  Result := '(Pages)';
end;

procedure TbsSetPagesProperty.SetValue(const Value: string);
begin
  if Value = '' then SetOrdValue(0);
end;


procedure SPS_ComSetSkinData(TCom: TComponent; spSkinData: TbsSkinData);
var
  j, iPropCount: Integer;
  p: ppropinfo;
  plList,pl2: TPropList;
  strProp: String;
  ts: TSTrings;
  k, pc2, l: Integer;
  p2: ppropinfo;
  obj:TObject;
begin
  if not Assigned(spSkinData) then Exit;
  if not Assigned(TCom) then Exit;
  iPropCount := GetPropList(TCom.classinfo, [tkString, tkLString, tkWString,tkClass], @plList);
  for j := 0 to iPropCount - 1 do
  begin
    p := GetPropInfo(TCom.classinfo, plList[j].name);
    if p = nil then  continue;
    if SameText(p.PropType^.Name, 'TbsSkinData')
    then
      begin
        obj := GetObjectProp(TCom, p);
        if obj = nil
        then
          begin
            SetObjectProp(TCom, p, spSkinData);
          end;
        SetStrProp(tcom, p, strProp);
      end;
  end;
end;                          

procedure SPS_FormSetSkinData(WinControl: TWinControl; spSkinData: TbsSkinData);
var
  i: Integer;
begin
  if not Assigned(spSkinData) then Exit;
  if not Assigned(WinControl) then Exit;
  for i := 0 to WinControl.componentcount - 1 do
  begin
    SPS_ComSetSkinData(WinControl.Components[i], spSkinData);
  end;
end;

procedure TbsBusinessSkinFormEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0:
      begin
        if  TbsBusinessSkinForm(Component).SkinData <> nil
        then
          begin
            SPS_FormSetSkinData(TWinControl(TbsBusinessSkinForm(Component).owner as Controls.TWinControl),
              TbsBusinessSkinForm(Component).SkinData);
          end;
      end;
  else
    inherited;
  end;
end;

function TbsBusinessSkinFormEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := '&Apply SkinData to All Controls';
  end;
end;

function TbsBusinessSkinFormEditor.GetVerbCount: integer;
begin
  Result := 1;
end;

{ Registration }

resourcestring
  sNEW_PAGE = 'New page';
  sDEL_PAGE = 'Delete page';
  sNEW_GROUP = 'New group';
  sShowHideAppMenu = 'Show / Hide Application menu';
  sNew_RibbonDivider = 'New divider';

  sNEW_STATUSPANEL = 'New panel';
  sNEW_STATUSGAUGE = 'New gauge';
  sNEW_STATUSEDIT = 'New edit';
  sNEW_STATUSBUTTONEDIT = 'New edit with button';
  sNEW_STATUSCOMBOBOX = 'New combobox';
  sNEW_STATUSSPINEDIT = 'New spinedit';

  sNEW_TOOLBUTTON = 'New button';
  sNEW_TOOLMENUBUTTON = 'New button with dropdown menu';
  sNEW_TOOLMENUTRACKBUTTON = 'New button with chevron and dropdown menu';

  sNEW_TOOLSEPARATOR = 'New separator';
  sNEW_TOOLDIVIDER = 'New divider with alpha channel';
  sNEW_TOOLCOMBOBOX = 'New combobox';
  sNEW_TOOLEDIT = 'New edit';
  sNEW_TOOLBUTTONEDIT = 'New edit with button';
  sNEW_TOOLSPINEDIT = 'New spinedit';
  sNEW_TOOLCALCEDIT = 'New calc edit';
  sNEW_TOOLFONTCOMBOBOX = 'New font combobox';
  sNEW_TOOLFONTSIZECOMBOBOX = 'New font size combobox';

  sNEW_TOOLMENUCOLORBUTTON = 'New color button';
  sNEW_TOOLMENUCOLORTRACKBUTTON = 'New color button with chevron';

procedure RewritePublishedProperty(ComponentClass: TClass; const PropertyName: string);
var
   LPropInfo: PPropInfo;
begin
  LPropInfo := GetPropInfo(ComponentClass, PropertyName);
  if LPropInfo <> nil
  then
    RegisterPropertyEditor(LPropInfo^.PropType^, ComponentClass, PropertyName, TbsPNGPropertyEditor);
end;

procedure Register;
begin
  RegisterComponents('BusinessSkinForm VCL',  [TbsBusinessSkinForm, TbsSkinFrame,
    TbsSkinData, TbsResourceStrData, TbsCompressedSkinList, 
    TbsCompressedStoredSkin, TbsSkinMainMenuBar,
    TbsSkinMDITabsBar, TbsSkinHint, TbsTrayIcon, TbsSkinZip, TbsSkinUnZip,

    TbsSkinPopupMenu, TbsSkinMainMenu, TbsSkinImagesMenu, 

    TbsSkinScrollBar,

    TbsSkinSpeedButton, TbsSkinMenuSpeedButton, TbsSkinColorButton,
    TbsSkinButton, TbsSkinMenuButton, TbsSkinXFormButton, TbsSkinUpDown,
    TbsSkinCheckBox, TbsSkinRadioButton, TbsSkinCheckRadioBox, 

    TbsSkinGauge, TbsSkinAnimateGauge,
    TbsSkinTrackBar, TbsSkinSlider, TbsSkinSplitter, TbsSkinSplitterEx,

    TbsSkinLabel, TbsSkinStdlabel, TbsSkinTextLabel,
    TbsSkinButtonLabel, TbsSkinLinkLabel, TbsSkinLinkImage,
    TbsSkinBevel,

    TbsSkinEdit, TbsSkinMaskEdit,
    TbsSkinPasswordEdit, TbsSkinTrackEdit, TbsSkinTimeEdit,
    TbsSkinSpinEdit, TbsSkinNumericEdit, TbsSkinDateEdit,  TbsSkinMonthCalendar,
    TbsSkinCalculator, TbsSkinCalcEdit, TbsSkinURLEdit, 
    TbsSkinMemo, TbsSkinMemo2, TbsSkinRichEdit, TbsSkinCurrencyEdit,
    TbsSkinCalcCurrencyEdit,

    TbsSkinListBox, TbsSkinComboBox, TbsSkinMRUComboBox, TbsSkinComboBoxEx,
    TbsSkinCheckListBox,  TbsSkinCheckComboBox,
    TbsSkinColorComboBox, TbsSkinColorListBox,
    TbsSkinFontComboBox, TbsSkinFontListBox,
    TbsSkinFontSizeComboBox,

    TbsSkinPanel, TbsSkinGroupBox, TbsSkinExPanel, TbsSkinScrollPanel,
    TbsSkinPaintPanel, 
    TbsSkinRadioGroup, TbsSkinCheckGroup,TbsSkinStatusBar, TbsSkinStatusPanel,
    TbsSkinControlBar, TbsSkinCoolBar,
    TbsSkinToolBar, TbsSkinHeaderControl, TbsSkinButtonsBar,
    TbsSkinNoteBook,  TbsSkinScrollBox, TbsSkinPageControl, TbsSkinTabControl,
    TbsSkinDrawGrid, TbsSkinStringGrid,
    TbsSkinTreeView, TbsSkinListView,

    TbsSkinFileListBox, TbsSkinDirectoryListBox, TbsSkinDriveComboBox,
    TbsSkinFilterComboBox, TbsSkinFileListView, TbsSkinDirTreeView,
    TbsSkinShellDriveComboBox,  TbsSkinShellComboBox,
    TbsSkinDirectoryEdit, TbsSkinFileEdit, TbsSkinSaveFileEdit,

    TbsSkinColorGrid, TbsSkinCategoryButtons, TbsSkinButtonGroup,
    TbsPngImageList, TbsPngImageStorage, TbsPngImageView]);

  RegisterComponents('BusinessSkinForm DB VCL',
    [TbsSkinDBGrid, TbsSkinDBText,
     TbsSkinDBEdit, TbsSkinDBMemo, TbsSkinDBMemo2,
     TbsSkinDBCheckRadioBox, TbsSkinDBListBox, TbsSkinDBComboBox,
     TbsSkinDBNavigator, TbsSkinDBImage, TbsSkinDBRadioGroup,
     TbsSkinDBSpinEdit, TbsSkinDBRichEdit,
     TbsSkinDBLookUpListBox, TbsSkinDBLookUpComboBox,
     TbsSkinDBCalcEdit, TbsSkinDBDateEdit, TbsSkinDBTimeEdit,
     TbsSkinDBPasswordEdit, TbsSkinDBNumericEdit,
     TbsSkinDBCurrencyEdit, TbsSkinDBCalcCurrencyEdit,
     TbsSkinDbGauge, TbsSkinDbSlider, TbsSkinDBMRUComboBox,
     TbsSkinDBCtrlGrid, TbsSkinDBURLEdit]);

  RegisterComponents('BusinessSkinForm VCL Dialogs',
    [TbsSkinMessage, TbsOpenSkinDialog, TbsSelectSkinDialog,
     TbsSelectSkinsFromFoldersDialog,  
     TbsSkinSelectDirectoryDialog,
     TbsSkinOpenDialog, TbsSkinSaveDialog,
     TbsSkinOpenPictureDialog, TbsSkinSavePictureDialog,
     TbsSkinInputDialog, TbsSkinPasswordDialog, TbsSkinTextDialog,
     TbsSkinFontDialog, TbsSkinProgressDialog, TbsSkinConfirmDialog,
     TbsSkinColorDialog, TbsSkinSelectValueDialog,
     TbsSkinPrintDialog, TbsSkinPrinterSetupDialog, TbsSkinSmallPrintDialog,
     TbsSkinPageSetupDialog,
     TbsSkinFindDialog, TbsSkinReplaceDialog,
     TbsSkinOpenPreviewDialog, TbsSkinSavePreviewDialog,
     TbsSkinOpenSoundDialog, TbsSkinSaveSoundDialog]);

  RegisterComponents('BusinessSkinForm VCL Graphics',
    [TbsSkinGradientStyleButton, TbsSkinBrushStyleButton,
     TbsSkinPenStyleButton, TbsSkinPenWidthButton,
     TbsSkinShadowStyleButton,
     TbsSkinBrushColorButton,
     TbsSkinTextColorButton]);

  RegisterComponents('BusinessSkinForm VCL Additionals',
   [TbsSkinShadowLabel, TbsSkinVistaGlowLabel, TbsSkinButtonEx,
    TbsSkinOfficeListBox, TbsSkinOfficeComboBox, TbsSkinHorzListBox, 
    TbsSkinLinkBar, TbsSkinToolBarEx, TbsSkinMenuEx, TbsSkinDivider,
    TbsSkinOfficeGallery, TbsSkinOfficeGridView]);


  RegisterComponents('BusinessSkinForm VCL Ribbon',
   [TbsRibbon, TbsRibbonGroup, TbsAppMenu, TbsRibbonDivider, TbsAppMenuPageListBox]);


  RegisterClass(TbsSkinTabSheet);
  RegisterClass(TbsRibbonPage);
  RegisterClass(TbsAppMenu);
  RegisterClass(TbsAppMenuPage);

  RegisterComponentEditor(TbsBusinessSkinForm, TbsBusinessSkinFormEditor);
  RegisterComponentEditor(TbsSkinPageControl, TbsSkinPageControlEditor);
  RegisterComponentEditor(TbsRibbon, TbsSkinRibbonControlEditor);
  RegisterComponentEditor(TbsAppMenu, TbsSkinRibbonAppMenuEditor);
  RegisterComponentEditor(TbsSkinStatusBar, TbsSkinStatusBarEditor);
  RegisterComponentEditor(TbsSkinToolBar, TbsSkinToolBarEditor);
  RegisterComponentEditor(TbsSkinTabSheet, TbsSkinPageControlEditor);
  RegisterComponentEditor(TbsRibbonPage, TbsSkinRibbonPageEditor);
  RegisterComponentEditor(TbsRibbonGroup, TbsSkinRibbonGroupEditor);

  RegisterPropertyEditor(TypeInfo(string), TbsColumn, 'FieldName', TbsColumnDataFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinListItem, 'FileName', TbsFilenameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinListItem, 'CompressedFileName', TbsFilenameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsCompressedStoredSkin, 'FileName', TbsFilenameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsCompressedStoredSkin, 'CompressedFileName', TbsFilenameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinDBLookUpListBox, 'KeyField', TbsSkinDBLookUpListBoxFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinDBLookUpListBox, 'ListField', TbsSkinDBLookUpListBoxFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinDBLookUpComboBox, 'KeyField', TbsSkinDBLookUpComboBoxFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinDBLookUpComboBox, 'ListField', TbsSkinDBLookUpComboBoxFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinButton, 'SkinDataName', TbsButtonSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinLabel, 'SkinDataName', TbsLabelSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinStdLabel, 'SkinDataName', TbsStdLabelSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsRibbonDivider, 'SkinDataName', TbsRibbonDividerSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinButtonEx, 'SkinDataName', TbsButtonExSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinPageControl, 'ButtonTabSkinDataName', TbsButtonExSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinCategoryButtons, 'ButtonsSkinDataName', TbsCategoryButtonSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinCategoryButtons, 'CategorySkinDataName', TbsCategorySkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinButtonGroup, 'SkinDataName', TbsCategorySkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinButtonGroup, 'ButtonsSkinDataName', TbsCategoryButtonSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinEdit, 'SkinDataName', TbsEditSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinTrackEdit, 'SkinDataName', TbsTrackEditSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinSpinEdit, 'SkinDataName', TbsSpinEditSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinDBNavigator, 'BtnSkinDataName', TbsButtonSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinButtonsBar, 'SectionButtonSkinDataName', TbsButtonSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinHeaderControl, 'SkinDataName', TbsHeaderSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinListView, 'HeaderSkinDataName', TbsHeaderSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinFileEdit, 'LVHeaderSkinDataName', TbsHeaderSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinSaveFileEdit, 'LVHeaderSkinDataName', TbsHeaderSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinOpenDialog, 'LVHeaderSkinDataName', TbsHeaderSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinOpenPictureDialog, 'LVHeaderSkinDataName', TbsHeaderSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinSaveDialog, 'LVHeaderSkinDataName', TbsHeaderSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinSavePictureDialog, 'LVHeaderSkinDataName', TbsHeaderSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinGauge, 'SkinDataName', TbsGaugeSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinMenuButton, 'SkinDataName', TbsMenuButtonSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinSpeedButton, 'SkinDataName', TbsButtonSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinMenuSpeedButton, 'SkinDataName', TbsMenuButtonSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinPanel, 'SkinDataName', TbsPanelSkinDataNameProperty);

  RegisterPropertyEditor(TypeInfo(string), TbsSkinMonthCalendar, 'SkinDataName', TbsCalendarSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinDateEdit, 'CalendarSkinDataName', TbsCalendarSkinDataNameProperty);

  RegisterPropertyEditor(TypeInfo(string), TbsSkinToolBar, 'SkinDataName', TbsToolBarSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinComboBox, 'SkinDataName', TbsComboBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinListBox, 'SkinDataName', TbsListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinOfficeListBox, 'SkinDataName', TbsOfficeListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsAppMenuPageListBox, 'SkinDataName', TbsOfficeListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinHorzListBox, 'SkinDataName', TbsOfficeListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinOfficeGallery, 'SkinDataName', TbsOfficeListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinOfficeGridView, 'SkinDataName', TbsOfficeListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinLinkBar, 'SkinDataName', TbsOfficeListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinOfficeComboBox, 'ListBoxSkinDataName', TbsOfficeListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinCheckListBox, 'SkinDataName', TbsCheckListBoxSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinSplitter, 'SkinDataName', TbsSplitterSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TbsSkinSplitterEx, 'SkinDataName', TbsSplitterSkinDataNameProperty);
  RegisterPropertyEditor(TypeInfo(TStrings),  TbsSkinNoteBook, 'Pages', TbsSetPagesProperty);

  //
  RegisterPropertyEditor(TypeInfo(TRoot), TbsSkinDirTreeView, 'Root', TbsRootProperty);
  RegisterPropertyEditor(TypeInfo(TRoot), TbsSkinFileListView, 'Root', TbsRootProperty);
  RegisterPropertyEditor(TypeInfo(TRoot), TbsSkinShellComboBox, 'Root', TbsRootProperty);
  RegisterComponentEditor(TbsSkinDirTreeView, TbsRootEditor);
  RegisterComponentEditor(TbsSkinFileListView, TbsRootEditor);
  RegisterComponentEditor(TbsSkinShellComboBox, TbsRootEditor);
  //
  RewritePublishedProperty(TbsPngImageItem, 'PngImage');
  RewritePublishedProperty(TbsPngStorageImageItem, 'PngImage');
end;

function TbsSkinRibbonPageEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0:  result := sNEW_Group;
  end;
end;

procedure TbsSkinRibbonPageEditor.ExecuteVerb(Index: Integer);
var
  RControl: TbsRibbonPage;
  NewGroup: TbsRibbonGroup;
begin
  if Component is TbsRibbonPage
  then
    RControl := TbsRibbonPage(Component)
  else
    RControl := nil;
  if RControl <> nil
  then
    case Index of
      0: begin
          NewGroup := TbsRibbonGroup.Create(Designer.GetRoot);
          with NewGroup do
          begin
            Name := Designer.UniqueName(ClassName);
            Caption := Name;
            Left := Width;
            Align := alLeft;
            Parent := RControl;
            if RControl.Ribbon <> nil
            then
              SkinData := RControl.Ribbon.SkinData;
          end;
        end;
    end;
  if Designer <> nil then Designer.Modified;
end;

function TbsSkinRibbonPageEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;


function TbsSkinRibbonGroupEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := sNEW_TOOLBUTTON;
    1: Result := sNEW_TOOLMENUBUTTON;
    2: Result := sNEW_TOOLMENUTRACKBUTTON;
    3: Result := sNew_RibbonDivider;
  end;
end;

procedure TbsSkinRibbonGroupEditor.ExecuteVerb(Index: Integer);
var
  GControl: TbsRibbonGroup;
  NewButton: TbsSkinSpeedButton;
  NewMenuButton: TbsSkinMenuSpeedButton;
  NewDivider: TbsRibbonDivider;
begin
  if Component is TbsRibbonGroup
  then
    GControl := TbsRibbonGroup(Component)
  else
    GControl := nil;
  if GControl <> nil
  then
    case Index of
      0: begin
          NewButton := TbsSkinSpeedButton.Create(Designer.GetRoot);
          with NewButton do
          begin
            Name := Designer.UniqueName(ClassName);
            Caption := '';
            Flat := True;
            SkinDataName := 'resizetoolbutton';
            Top := 0;
            Left := 0;
            Parent := GControl;
            SkinData := GControl.SkinData;
          end;
           Designer.SelectComponent(NewButton);
        end;
      1: begin
         NewMenuButton := TbsSkinMenuSpeedButton.Create(Designer.GetRoot);
          with NewMenuButton do
          begin
            Name := Designer.UniqueName(ClassName);
            SkinData := GControl.SkinData;
            Left := 0;
            Top := 0;
            Flat := True;
            SkinDataName := 'resizetoolbutton';
            NewStyle := True;
            Parent := GControl;
            Designer.SelectComponent(NewMenuButton);
          end;
       end;
     2: begin
          NewMenuButton := TbsSkinMenuSpeedButton.Create(Designer.GetRoot);
          with NewMenuButton do
          begin
            Name := Designer.UniqueName(ClassName);
            SkinData := GControl.SkinData;
            Left := 0;
            Top := 0;
            Flat := True;
            TrackButtonMode := True;
            SkinDataName := 'resizetoolbutton';
            NewStyle := True;
            Parent := GControl;
            Designer.SelectComponent(NewMenuButton);
          end;
         end; 
      3: begin
           NewDivider := TbsRibbonDivider.Create(Designer.GetRoot);
           with NewDivider do
           begin
             Name := Designer.UniqueName(ClassName);
             Top := 0;
             Left := 0;
             Width := 15;
             Parent := GControl;
             SkinData := GControl.SkinData;
           end;
           Designer.SelectComponent(NewDivider);
         end;
    end;
  if Designer <> nil then Designer.Modified;
end;

function TbsSkinRibbonGroupEditor.GetVerbCount: Integer;
begin
  Result := 4;
end;


function TbsSkinRibbonControlEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := sNEW_PAGE;
    1: Result := sDEL_PAGE;
    2: Result := sShowHideAppMenu;
  end;
end;

procedure TbsSkinRibbonControlEditor.ExecuteVerb(Index: Integer);
var
  RControl : TbsRibbon;
begin
  if Component is TbsRibbon
  then
    RControl := TbsRibbon(Component)
  else
    RControl := nil;
  if RControl <> nil
  then
    case Index of
      0: RControl.Tabs.Add;
      1: if RControl.ActivePage <> nil then RControl.ActivePage.Free;
      2: begin
           if RControl.AppMenu <> nil
           then
            if RControl.AppMenu.Visible
            then RControl.HideAppMenu(nil)
            else RControl.ShowAppMenu;
         end;
    end;
  if Designer <> nil then Designer.Modified;
end;

function TbsSkinRibbonControlEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

function TbsSkinRibbonAppMenuEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := sNEW_PAGE;
    1: Result := sDEL_PAGE;
  end;
end;

procedure TbsSkinRibbonAppMenuEditor.ExecuteVerb(Index: Integer);
var
  RControl : TbsAppMenu;
begin
  if Component is TbsAppMenu
  then
    RControl :=  TbsAppMenu(Component)
  else
    RControl := nil;
  if RControl <> nil
  then
    case Index of
      0: RControl.CreatePage;
      1: if RControl.ActivePage <> nil then RControl.ActivePage.Free;
    end;
  if Designer <> nil then Designer.Modified;
end;

function TbsSkinRibbonAppMenuEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

function TbsSkinPageControlEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0:  result := sNEW_PAGE;
    1:  result := sDEL_PAGE;
  end;
end;

procedure TbsSkinPageControlEditor.ExecuteVerb(Index: Integer);
var
  NewPage: TbsSkinCustomTabSheet;
  PControl : TbsSkinPageControl;
begin
  if Component is TbsSkinPageControl then
    PControl := TbsSkinPageControl(Component)
  else PControl := TbsSkinPageControl(TbsSkinTabSheet(Component).PageControl);

  case Index of
    0:  begin
          NewPage := TbsSkinTabSheet.Create(Designer.GetRoot);
          with NewPage do
          begin
            Parent := PControl;
            PageControl := PControl;
            Name := Designer.UniqueName(ClassName);
            Caption := Name;
          end;
        end;
    1:  begin  
          with PControl do
          begin
            NewPage := TbsSkinCustomTabSheet(ActivePage);
            NewPage.PageControl := nil;
            NewPage.Free;
          end;
        end;
  end;
  if Designer <> nil then Designer.Modified;
end;

function TbsSkinPageControlEditor.GetVerbCount: Integer;
begin
  Result := 2;
end;

procedure TbsSkinStatusBarEditor.ExecuteVerb(Index: Integer);
var
  NewPanel: TbsSkinStatusPanel;
  NewGauge: TbsSkinGauge;
  NewEdit: TbsSkinEdit;
  NewSpinEdit: TbsSkinSpinEdit;
  NewComboBox: TbsSkinComboBox;
  PControl : TbsSkinStatusBar;
begin
  if Component is TbsSkinStatusBar
  then
    PControl := TbsSkinStatusBar(Component)
  else
    Exit;
  case Index of
    0:  begin
          NewPanel := TbsSkinStatusPanel.Create(Designer.GetRoot);
          with NewPanel do
          begin
            Left := PControl.Width;
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            SkinData := PControl.SkinData;
            Designer.SelectComponent(NewPanel);
          end;
        end;
    1:  begin
          NewGauge := TbsSkinGauge.Create(Designer.GetRoot);
          with NewGauge do
          begin
            Left := PControl.Width;
            SkinDataName := 'statusgauge';
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            SkinData := PControl.SkinData;
            Designer.SelectComponent(NewGauge);
          end;
        end;
    2:
       begin
         NewEdit := TbsSkinEdit.Create(Designer.GetRoot);
          with NewEdit do
          begin
            Left := PControl.Width;
            SkinDataName := 'statusedit';
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            SkinData := PControl.SkinData;
            Designer.SelectComponent(NewEdit);
          end;
       end;
    3:
       begin
         NewEdit := TbsSkinEdit.Create(Designer.GetRoot);
         with NewEdit do
         begin
           ButtonMode := True;
           Left := PControl.Width;
           SkinDataName := 'statusbuttonedit';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewEdit);
         end;
       end;
    4:
       begin
         NewSpinEdit := TbsSkinSpinEdit.Create(Designer.GetRoot);
         with NewSpinEdit do
         begin
           Left := PControl.Width;
           SkinDataName := 'statusspinedit';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewEdit);
         end;
       end;
     5:
       begin
         NewComboBox := TbsSkinComboBox.Create(Designer.GetRoot);
         with NewComboBox do
         begin
           Left := PControl.Width;
           SkinDataName := 'statuscombobox';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewEdit);
         end;
       end;
  end;
  if Designer <> nil then Designer.Modified;
end;

function TbsSkinStatusBarEditor.GetVerbCount: Integer;
begin
  Result := 6;
end;

function TbsSkinStatusBarEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := sNEW_STATUSPANEL;
    1: Result := sNEW_STATUSGAUGE;
    2: Result := sNEW_STATUSEDIT;
    3: Result := sNEW_STATUSBUTTONEDIT;
    4: Result := sNEW_STATUSSPINEDIT;
    5: Result := sNEW_STATUSCOMBOBOX;
  end;
end;

procedure TbsSkinToolBarEditor.ExecuteVerb(Index: Integer);
var
  NewSpeedButton: TbsSkinSpeedButton;
  NewMenuSpeedButton: TbsSkinMenuSpeedButton;
  NewBevel: TbsSkinBevel;
  NewEdit: TbsSkinEdit;
  NewSpinEdit: TbsSkinSpinEdit;
  NewComboBox: TbsSkinComboBox;
  NewCalcEdit: TbsSkinCalcEdit;
  NewFontComboBox: TbsSkinFontComboBox;
  NewFontSizeComboBox: TbsSkinFontSizeComboBox;
  NewColorButton: TbsSkinColorButton;
  NewDivider: TbsSkinDivider;
  PControl : TbsSkinToolBar;
begin
  if Component is TbsSkinToolBar
  then
    PControl := TbsSkinToolBar(Component)
  else
    Exit;
  case Index of
    0:  begin
          NewSpeedButton := TbsSkinSpeedButton.Create(Designer.GetRoot);
          with NewSpeedButton do
          begin
            Flat := PControl.Flat;
            SkinData := PControl.SkinData;
            Left := PControl.Width;
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            if (PControl.SkinDataName = 'resizetoolpanel')
            then
              SkinDataName := 'resizetoolbutton'
            else
            if (PControl.SkinDataName = 'panel')
            then
              SkinDataName := 'resizebutton'
            else
            if PControl.SkinDataName = 'bigtoolpanel'
            then
              SkinDataName := 'bigtoolbutton'
            else
              SkinDataName := 'toolbutton';
            Designer.SelectComponent(NewSpeedButton);
          end;
        end;
    1:  begin
          NewMenuSpeedButton := TbsSkinMenuSpeedButton.Create(Designer.GetRoot);
          with NewMenuSpeedButton do
          begin
            Flat := PControl.Flat;
            SkinData := PControl.SkinData;
            Left := PControl.Width;
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            if (PControl.SkinDataName = 'resizetoolpanel')
            then
              SkinDataName := 'resizetoolbutton'
            else
            if (PControl.SkinDataName = 'panel')
            then
              SkinDataName := 'resizebutton'
            else
            if PControl.SkinDataName = 'bigtoolpanel'
            then
              SkinDataName := 'bigtoolmenubutton'
            else
              SkinDataName := 'toolmenubutton';
            Designer.SelectComponent(NewMenuSpeedButton);
          end;
        end;
    2:  begin
          NewMenuSpeedButton := TbsSkinMenuSpeedButton.Create(Designer.GetRoot);
          with NewMenuSpeedButton do
          begin
            Flat := PControl.Flat;
            SkinData := PControl.SkinData;
            Left := PControl.Width;
            TrackButtonMode := True;
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            if (PControl.SkinDataName = 'resizetoolpanel')
            then
              SkinDataName := 'resizetoolbutton'
            else
            if (PControl.SkinDataName = 'panel')
            then
              SkinDataName := 'resizebutton'
            else
            if PControl.SkinDataName = 'bigtoolpanel'
            then
              SkinDataName := 'bigtoolmenutrackbutton'
            else
              SkinDataName := 'toolmenutrackbutton';
            Designer.SelectComponent(NewMenuSpeedButton);
          end;
        end;
    3: begin
          NewBevel := TbsSkinBevel.Create(Designer.GetRoot);
          with NewBevel do
          begin
            SkinData := PControl.SkinData;
            Left := PControl.Width;
            Width := 25;
            DividerMode := True;
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            Designer.SelectComponent(NewBevel);
          end;
        end;
     4:
       begin
         NewEdit := TbsSkinEdit.Create(Designer.GetRoot);
          with NewEdit do
          begin
            Left := PControl.Width;
            SkinDataName := 'edit';
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            SkinData := PControl.SkinData;
            Designer.SelectComponent(NewEdit);
          end;
       end;
    5:
       begin
         NewEdit := TbsSkinEdit.Create(Designer.GetRoot);
         with NewEdit do
         begin
           ButtonMode := True;
           Left := PControl.Width;
           SkinDataName := 'buttonedit';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewEdit);
         end;
       end;
    6:
       begin
         NewSpinEdit := TbsSkinSpinEdit.Create(Designer.GetRoot);
         with NewSpinEdit do
         begin
           Left := PControl.Width;
           SkinDataName := 'spinedit';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewSpinEdit);
         end;
       end;
    7:
       begin
         NewComboBox := TbsSkinComboBox.Create(Designer.GetRoot);
         with NewComboBox do
         begin
           Left := PControl.Width;
           SkinDataName := 'combobox';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewComboBox);
         end;
       end;
    8: begin
         NewCalcEdit := TbsSkinCalcEdit.Create(Designer.GetRoot);
         with NewCalcEdit do
         begin
           Left := PControl.Width;
           SkinDataName := 'buttonedit';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewCalcEdit);
         end;
       end;
    9:
       begin
         NewFontComboBox := TbsSkinFontComboBox.Create(Designer.GetRoot);
         with NewFontComboBox do
         begin
           Left := PControl.Width;
           SkinDataName := 'combobox';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewFontComboBox);
         end;
       end;
    10:
       begin
         NewFontSizeComboBox := TbsSkinFontSizeComboBox.Create(Designer.GetRoot);
         with NewFontSizeComboBox do
         begin
           Left := PControl.Width;
           SkinDataName := 'combobox';
           Parent := PControl;
           Align := alLeft;
           Name := Designer.UniqueName(ClassName);
           SkinData := PControl.SkinData;
           Designer.SelectComponent(NewFontSizeComboBox);
         end;
       end;
    11:
      begin
          NewColorButton := TbsSkinColorButton.Create(Designer.GetRoot);
          with NewColorButton do
          begin
            Flat := PControl.Flat;
            SkinData := PControl.SkinData;
            Left := PControl.Width;
            TrackButtonMode := False;
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            if (PControl.SkinDataName = 'resizetoolpanel')
            then
              SkinDataName := 'resizetoolbutton'
            else
            if (PControl.SkinDataName = 'panel')
            then
              SkinDataName := 'resizebutton'
            else
            if PControl.SkinDataName = 'bigtoolpanel'
            then
              SkinDataName := 'bigtoolmenubutton'
            else
              SkinDataName := 'toolmenubutton';
            Designer.SelectComponent(NewMenuSpeedButton);
          end;
        end;
      12:
      begin
          NewColorButton := TbsSkinColorButton.Create(Designer.GetRoot);
          with NewColorButton do
          begin
            Flat := PControl.Flat;
            SkinData := PControl.SkinData;
            Left := PControl.Width;
            TrackButtonMode := True;
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            if (PControl.SkinDataName = 'resizetoolpanel')
            then
              SkinDataName := 'resizetoolbutton'
            else
            if (PControl.SkinDataName = 'panel')
            then
              SkinDataName := 'resizebutton'
            else
            if PControl.SkinDataName = 'bigtoolpanel'
            then
              SkinDataName := 'bigtoolmenutrackbutton'
            else
              SkinDataName := 'toolmenutrackbutton';
            Designer.SelectComponent(NewMenuSpeedButton);
          end;
        end;

      13: begin
          NewDivider := TbsSkinDivider.Create(Designer.GetRoot);
          with NewDivider do
          begin
            SkinData := PControl.SkinData;
            Left := PControl.Width;
            Width := 15;
            Parent := PControl;
            Align := alLeft;
            Name := Designer.UniqueName(ClassName);
            Designer.SelectComponent(NewDivider);
          end;
        end;
    end;
  if Designer <> nil then Designer.Modified;
end;

function TbsSkinToolBarEditor.GetVerbCount: Integer;
begin
  Result := 14;
end;

function TbsSkinToolBarEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := sNEW_TOOLBUTTON;
    1: Result := sNEW_TOOLMENUBUTTON;
    2: Result := sNEW_TOOLMENUTRACKBUTTON;
    3: Result := sNEW_TOOLSEPARATOR;
    4: Result := sNEW_TOOLEDIT;
    5: Result := sNEW_TOOLBUTTONEDIT;
    6: Result := sNEW_TOOLSPINEDIT;
    7: Result := sNEW_TOOLCOMBOBOX;
    8: Result := sNEW_TOOLCALCEDIT;
    9: Result := sNEW_TOOLFONTCOMBOBOX;
    10: Result := sNew_TOOLFONTSIZECOMBOBOX;
    11: Result := sNEW_TOOLMENUCOLORBUTTON;
    12: Result := sNEW_TOOLMENUCOLORTRACKBUTTON;
    13: Result := sNEW_TOOLDIVIDER;
  end;
end;

end.


