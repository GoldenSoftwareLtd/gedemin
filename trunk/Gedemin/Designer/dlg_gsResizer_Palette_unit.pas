
{++
  Copyright (c) 2002 by Golden Software of Belarus

  Module
    dlg_gsResizer_Palette_unit
  Abstract

    Палитра инструментов для gsResizer

    Для добавления новых контролов в палитру необходимо:
      1) В вызов процедуры RegisterNewClasses([TLabel, ..]) в секции
         initialization добавить имя желаемого класа
      2) В ресурс gsResizer.res добавить картинку размера 23x23
         назвав её именем класа, если картинка не будет добавлена
         будет использована стандартная
      3) При необходимости прописать units. Перекомпилировать.
  Author

    Kornachenko Nikolai (nkornachenko@yahoo.com) (17-01-2002)

  Revisions history

    Initial  17-01-2002  Nick  Initial version.
--}

unit dlg_gsResizer_Palette_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, ActnList, ImgList, Buttons, gsResizerInterface,
  ExtCtrls, TB2Dock, TB2Toolbar, TB2Item, Menus, clipbrd;

const
  GDCFolderName = 'GDC';

type

  Tdlg_gsResizer_Palette = class(TForm)
    ilPalette: TImageList;
    ActionList1: TActionList;
    actArrow: TAction;
    actExitAndSave: TAction;
    actExitWithoutSaving: TAction;
    actExitAndLoadDef: TAction;
    Panel2: TPanel;
    tbButons: TTBToolbar;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    pnTab: TPanel;
    pcPalette: TPageControl;
    actComponentList: TAction;
    TBItem4: TTBItem;
    PopupMenu1: TPopupMenu;
    miStayOnTop: TMenuItem;
    TBSubmenuItem1: TTBSubmenuItem;
    tbTab: TTBItem;
    tbSize: TTBItem;
    tbAlign: TTBItem;
    actAlign: TAction;
    actSize: TAction;
    actTab: TAction;
    TBSeparatorItem1: TTBSeparatorItem;
    actCutCotrol: TAction;
    actCopyControl: TAction;
    actPasteControl: TAction;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
    TBItem7: TTBItem;
    actBringToFront: TAction;
    actSendToBack: TAction;
    TBItem8: TTBItem;
    TBItem9: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    procedure actArrowExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actExitAndSaveExecute(Sender: TObject);
    procedure actExitWithoutSavingExecute(Sender: TObject);
    procedure actExitAndLoadDefExecute(Sender: TObject);
    procedure pcPaletteChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actComponentListExecute(Sender: TObject);
    procedure miStayOnTopClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure actAlignExecute(Sender: TObject);
    procedure actSizeExecute(Sender: TObject);
    procedure actTabExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actCutCotrolExecute(Sender: TObject);
    procedure actCutCotrolUpdate(Sender: TObject);
    procedure actCopyControlExecute(Sender: TObject);
    procedure actPasteControlExecute(Sender: TObject);
    procedure actCopyControlUpdate(Sender: TObject);
    procedure actBringToFrontExecute(Sender: TObject);
    procedure actBringToFrontUpdate(Sender: TObject);
    procedure actSendToBackExecute(Sender: TObject);
    procedure actSendToBackUpdate(Sender: TObject);
    procedure actPasteControlUpdate(Sender: TObject);

  private
    FManager: IgsResizeManager;
    function  GetNewClassName: TPersistentClass;
    procedure ToolButtonClick(Sender: TObject);

    function  GetActiveControl(const ANoCut: boolean = False): TControl;
  public
    constructor Create(AnOwner: TComponent); override;
    procedure BreakState;
    property NewControlClass: TPersistentClass read GetNewClassName;
  end;

var
  dlg_gsResizer_Palette: Tdlg_gsResizer_Palette;

implementation

uses
  gsResizer, stdctrls, dbctrls, gsIBLookupComboBox, gsIBGrid, xDateEdits,
  gd_ClassList, Outline, checklst, grids, filectrl, mask, ColorGrd, Gauges, Spin,
  xCalculatorEdit,  TB2ToolWindow, gsDbGrid, dbclient, db, IBDataBase, IBDatabaseInfo,
  IBCustomDataSet, IBEvents, IBExtract, IBQuery, IBSQL, IBStoredProc, gsdbReduction,
  IBTable, IBUpdateSQL, extdlgs, IBSQLMonitor, Storages, contnrs, gdcBase,
  gsDBTreeView, dlg_gsResizer_Components_unit, at_Container, gsScaner, gsComScaner, ColorComboBox, gd_MacrosMenu, gd_ReportMenu,
  flt_QueryFilterGDC, BtnEdit, gd_AttrComboBox, SynEdit, SynMemo, SynHighlighterVBScript,
  SynHighlighterSQL, shdocvw, xCalc, gsComponentEmulator, JvDBImage, gsPeriodEdit
{$IFDEF MODEM}
  , gsModem
{$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}
{$R gsResizer.res}

var
  ClassArray: TClassPaletteArray;

type
  TPaletteTabSheet = class(TTabSheet)
  protected
    FPanelLeft: TPanel;
    FPanelClient: TPanel;
    FToolbar: TTBToolbar;
    FbtnArrow: TSpeedButton;
    FForm: Tdlg_gsResizer_Palette;
  public
    constructor Create(AnOwner: TComponent; AForm: Tdlg_gsResizer_Palette); reintroduce;
    destructor Destroy; override;
  end;


procedure Tdlg_gsResizer_Palette.actArrowExecute(Sender: TObject);
var
  I: Integer;
begin

  for I := 0 to (pcPalette.ActivePage as TPaletteTabSheet).FToolbar.Items.Count - 1 do
    (pcPalette.ActivePage as TPaletteTabSheet).FToolbar.Items[I].Checked := False;

  (pcPalette.ActivePage as TPaletteTabSheet).FbtnArrow.Down := True;

  if Assigned(FManager) then
    FManager.SetManagerState(msDesign);
end;

procedure Tdlg_gsResizer_Palette.BreakState;
begin
  actArrowExecute(nil);
end;

constructor Tdlg_gsResizer_Palette.Create(AnOwner: TComponent);
var
  I, J: Integer;
  TB: TTBItem;
  Bitmap: TBitmap;
  MaskColor: TColor;
  Sheet: TPaletteTabSheet;
  OldSheet: String;
  P: PClassPalette;
  TempList: TClassList;
begin
  inherited;
  OldSheet := '';
  Sheet := nil;
  ClientHeight := pnTab.Height;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;

  if AnOwner is TgsResizeManager then
    FManager := TgsResizeManager(AnOwner)
  else
    FManager := nil;

//  if J >= 0 then
  if Assigned(gdcClassList) then
  begin
    if (ClassArray[High(ClassArray)]^.FolderName <> GDCFolderName) and
       (gdcClassList.Count > 0) then
    begin
      TempList := TClassList.Create;
      try
        for I := 0 to gdcClassList.Count - 1 do
          if CgdcBase(gdcClassList[I]).InheritsFrom(TgdcBase)
            and {(not CgdcBase(gdcClassList[I]).IsAbstractClass)}
              (gdcClassList[I].ClassName <> 'TgdcBase')
            and (gdcClassList[I].ClassName <> 'TgdcTree')
            and (gdcClassList[I].ClassName <> 'TgdcLBRBTree') then
          begin
            TempList.Add(gdcClassList[I]);
          end;
        J := High(ClassArray);
        SetLength(ClassArray, J + TempList.Count + 1);
        for I := J + 1 to High(ClassArray) do
        begin
          New(P);
          P^.ClassType := TPersistentClass(TempList[I - (J + 1)]);
          P^.FolderName := GDCFolderName;
          ClassArray[I] := P;
        end;
      finally
        TempList.Free;
      end;
    end;
  end;

  Bitmap := TBitmap.Create;

  try
    for I := Low(ClassArray) to High(ClassArray) do
    begin
      if (I = Low(ClassArray)) or (OldSheet <> ClassArray[I]^.FolderName) then
      begin
        Sheet := nil;
        for J := 0 to pcPalette.PageCount - 1 do
          if pcPalette.Pages[J].Caption = ClassArray[I]^.FolderName then
          begin
            Sheet := TPaletteTabSheet(pcPalette.Pages[J]);
            Break;
          end;
        if not Assigned(Sheet) then
        begin
          Sheet := TPaletteTabSheet.Create(pcPalette, Self);
          Sheet.Caption := ClassArray[I]^.FolderName;
          Sheet.PageControl := pcPalette;
        end;
      end;

      TB := TTBItem.Create(Sheet.FToolbar);
      TB.GroupIndex := 1;
      TB.Hint := ClassArray[I]^.ClassType.ClassName;
      TB.OnClick := ToolButtonClick;

      if FindResource(hInstance, PChar(UpperCase(TB.Hint)), RT_BITMAP) = 0 then
        TB.ImageIndex := 0
      else
      begin
        try
          Bitmap.LoadFromResourceName(hInstance, UpperCase(TB.Hint));
          MaskColor := Bitmap.Canvas.Pixels[0, Bitmap.Height - 1];
          TB.ImageIndex := ilPalette.AddMasked(Bitmap, MaskColor);
        except
          TB.ImageIndex := 0;
        end;
      end;

      Sheet.FToolbar.Items.Add(TB);

    end;
  finally
    Bitmap.Free;
  end;
  (pcPalette.ActivePage as TPaletteTabSheet).FbtnArrow.Down := True;

end;

{destructor Tdlg_gsResizer_Palette.Destroy;
begin
  inherited;
end;}

function Tdlg_gsResizer_Palette.GetNewClassName: TPersistentClass;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to (pcPalette.ActivePage as TPaletteTabSheet).FToolbar.Items.Count - 1 do
  begin
    if (pcPalette.ActivePage as TPaletteTabSheet).FToolbar.Items[I].Checked then
    begin
      Result := GetClass((pcPalette.ActivePage as TPaletteTabSheet).FToolbar.Items[I].Hint);
      Break;
    end;
  end;
end;

procedure RegisterNewClasses(const AFolderName: String;
  AClasses: array of TPersistentClass);
var I, J: Integer;
  P: PClassPalette;
begin
  RegisterClasses(AClasses);

  J := High(ClassArray);
  SetLength(ClassArray, J + High(AClasses) + 2);

  for I := J + 1 to High(ClassArray) do
  begin
    New(P);
    P^.ClassType := AClasses[I - (J + 1)];
    P^.FolderName := AFolderName;
    ClassArray[I] := P;
  end;
end;
procedure ClearComponents;
var
  I: Integer;
begin
  for I := Low(ClassArray) to High(ClassArray) do
    Dispose(PClassPalette(ClassArray[I]));
  SetLength(ClassArray, 0);
end;

procedure Tdlg_gsResizer_Palette.ToolButtonClick(Sender: TObject);
begin
  (pcPalette.ActivePage as TPaletteTabSheet).FbtnArrow.Down := False;

  (Sender as TTBItem).Checked := True;

  if Assigned(FManager) then
    FManager.SetManagerState(msNewControl);
end;

procedure Tdlg_gsResizer_Palette.FormCreate(Sender: TObject);
begin
  pcPalette.ActivePageIndex := 0;
  if Assigned(UserStorage) then
  begin
    Top := UserStorage.ReadInteger('\'+ Name, Name + 'Top', Top);
    Left := UserStorage.ReadInteger('\'+ Name, Name + 'Left', Left);
    Width := UserStorage.ReadInteger('\'+ Name, Name + 'Width', Width);

    if Left > Screen.Width then
      Left := Screen.Width - Width;
    if Top > Screen.Height then
      Top := Screen.Height - Height;
    if UserStorage.ReadBoolean('\'+ Name, Name + 'StayOnTop', False) then
      FormStyle := fsStayOnTop
    else
      FormStyle := fsNormal;

  end;
end;

procedure Tdlg_gsResizer_Palette.actExitAndSaveExecute(Sender: TObject);
begin
  if Assigned(FManager) then
    FManager.SaveAndExit;
end;

procedure Tdlg_gsResizer_Palette.actExitWithoutSavingExecute(
  Sender: TObject);
begin
  if MessageBox(Handle,
    'Выйти без сохранения?', 'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
  begin
    if Assigned(FManager) then
      FManager.ExitWithoutSaving;
  end;
end;

procedure Tdlg_gsResizer_Palette.actExitAndLoadDefExecute(Sender: TObject);
begin
  if Assigned(FManager) then
    FManager.ExitAndLoadDefault;
end;

{ TPaletteTabSheet }

constructor TPaletteTabSheet.Create(AnOwner: TComponent; AForm: Tdlg_gsResizer_Palette);
begin
  inherited Create(AnOwner);
  FForm := AForm;

  FPanelLeft := TPanel.Create(Self);
  FPanelLeft.BevelOuter := bvNone;
  FPanelLeft.Align := AlLeft;
  FPanelLeft.Width := 28;
  FPanelLeft.Parent := Self;

  FbtnArrow := TSpeedButton.Create(FPanelLeft);
  FbtnArrow.Top := 1;
  FbtnArrow.Width := 28;
  FbtnArrow.Height := 28;
  FbtnArrow.Action := FForm.actArrow;
  FbtnArrow.GroupIndex := 1;
  FbtnArrow.Flat := True;
  FbtnArrow.AllowAllUp := True;
  FbtnArrow.Parent := FPanelLeft;

  FPanelClient := TPanel.Create(Self);
  FPanelClient.Align := AlClient;
  FPanelClient.Parent := Self;
  FPanelClient.BevelOuter := bvNone;

  FToolbar := TTBToolbar.Create(FPanelClient);
  FToolbar.Align := AlClient;
  FToolbar.Images := FForm.ilPalette;
  FToolbar.AutoResize := False;
  FToolbar.DockableTo := [];
  FToolbar.Options := [tboDefault,tboToolbarStyle];
  FToolbar.ReSizable := False;
  FToolbar.ShrinkMode := tbsmChevron;
  FToolbar.ShowHint := True;
  FToolbar.Parent := FPanelClient;

end;

destructor TPaletteTabSheet.Destroy;
begin
  FbtnArrow.Free;
  FPanelLeft.Free;
  FToolbar.Free;
  FPanelClient.Free;
  inherited;
end;

procedure Tdlg_gsResizer_Palette.pcPaletteChange(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to (pcPalette.ActivePage as TPaletteTabSheet).FToolbar.Items.Count - 1 do
  begin
    (pcPalette.ActivePage as TPaletteTabSheet).FToolbar.Items[I].Checked := False;
  end;
  (pcPalette.ActivePage as TPaletteTabSheet).FbtnArrow.Down := True;
  if Assigned(FManager) then
    FManager.SetManagerState(msDesign);
end;

procedure Tdlg_gsResizer_Palette.FormDestroy(Sender: TObject);
begin
  if Assigned(UserStorage) then
  begin
    UserStorage.WriteInteger('\'+ Name, Name + 'Height', Height);
    UserStorage.WriteInteger('\'+ Name, Name + 'Top', Top);
    UserStorage.WriteInteger('\'+ Name, Name + 'Left', Left);
    UserStorage.WriteInteger('\'+ Name, Name + 'Width', Width);
    UserStorage.WriteBoolean('\'+ Name, Name + 'StayOnTop', FormStyle = fsStayOnTop);
  end;
end;

procedure Tdlg_gsResizer_Palette.actComponentListExecute(Sender: TObject);
begin
  if not Assigned(FManager.ComponentsForm) then
    FManager.ComponentsForm := Tdlg_gsResizer_Components.Create(nil, ClassArray, FManager.EditForm);
  FManager.ComponentsForm.Show;
end;

procedure Tdlg_gsResizer_Palette.miStayOnTopClick(Sender: TObject);
begin
  if Self.FormStyle = fsStayOnTop then
    Self.FormStyle := fsNormal
  else
    Self.FormStyle := fsStayOnTop;
end;

procedure Tdlg_gsResizer_Palette.PopupMenu1Popup(Sender: TObject);
begin
  miStayOnTop.Checked := Self.FormStyle = fsStayOnTop;
end;

procedure Tdlg_gsResizer_Palette.actAlignExecute(Sender: TObject);
begin
  if Assigned(FManager) then
    FManager.AlignmentAction.OnExecute(nil);
end;

procedure Tdlg_gsResizer_Palette.actSizeExecute(Sender: TObject);
begin
  if Assigned(FManager) then
    FManager.SetSizeAction.OnExecute(nil);
end;

procedure Tdlg_gsResizer_Palette.actTabExecute(Sender: TObject);
begin
  if Assigned(FManager) then
    FManager.TabOrderAction.OnExecute(nil);
end;

procedure Tdlg_gsResizer_Palette.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  MessageBox(Handle,
    'Чтобы закрыть Палитру компонент воспользуйтесь кнопками:'#13#10 +
    'Сохранить, Закрыть или Сбросить в левой части окна.',
    'Внимание',
    MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

  CanClose := False;
end;

procedure Tdlg_gsResizer_Palette.actCutCotrolExecute(Sender: TObject);
begin
  if Assigned(FManager) then
    FManager.CutActionI.Execute;
end;

procedure Tdlg_gsResizer_Palette.actCutCotrolUpdate(Sender: TObject);
var
  C: TObject;
begin
  C:= GetActiveControl;

  if Assigned(C) and (not ((C is TTabSheet) or (C is TToolButton) or (C is TgsComponentEmulator))) then
    actCutCotrol.Enabled := True
  else
    actCutCotrol.Enabled := False;
  FManager.CutActionI.Enabled:= actCutCotrol.Enabled;
end;

procedure Tdlg_gsResizer_Palette.actCopyControlExecute(Sender: TObject);
begin
  if Assigned(FManager) then
    FManager.CopyActionI.Execute;
end;

procedure Tdlg_gsResizer_Palette.actCopyControlUpdate(Sender: TObject);
begin
  if not Assigned(FManager) then Exit;
  if FManager.ResizersList.Count > 0 then
    actCopyControl.Enabled := True
  else
    actCopyControl.Enabled := False;
  FManager.CopyActionI.Enabled:= actCopyControl.Enabled;
end;

procedure Tdlg_gsResizer_Palette.actPasteControlExecute(Sender: TObject);
begin
  if Assigned(FManager) then
    FManager.PasteActionI.Execute;
end;

procedure Tdlg_gsResizer_Palette.actPasteControlUpdate(Sender: TObject);
var
  C: TControl;
  FMan: TgsResizeManager;
begin
  if not Assigned(FManager) then Exit;

  C:= GetActiveControl(True);
  FMan:= FManager.Get_Self as TgsResizeManager;

  if not Assigned(C) then
    C:= FMan.EditForm;

  if Assigned(C) and (C is TWinControl) and ((((FMan.IsCut) and (C.InheritsFrom(TWinControl)) and
     (csAcceptsControls in C.ControlStyle) and (C <> FMan.GetParentControl)))
     or (not FMan.IsCut) and Clipboard.HasFormat(CF_TEXT) and (Pos('object', Clipboard.AsText) = 1)) then
  begin
    FMan.SetNewParentControl(C as TWinControl);
    actPasteControl.Enabled := True;
  end
  else
    actPasteControl.Enabled := False;
  FManager.PasteActionI.Enabled:= actPasteControl.Enabled;
end;

procedure Tdlg_gsResizer_Palette.actBringToFrontExecute(Sender: TObject);
var
  C: TObject;
begin
  C:= GetActiveControl;

  if Assigned(C) and C.InheritsFrom(TControl) then
    (C as TControl).BringToFront;
end;

procedure Tdlg_gsResizer_Palette.actBringToFrontUpdate(Sender: TObject);
var
  C: TObject;
begin
  C:= GetActiveControl;

  if Assigned(C) and C.InheritsFrom(TControl) then
    actBringToFront.Enabled := True
  else
    actBringToFront.Enabled := False;
end;

procedure Tdlg_gsResizer_Palette.actSendToBackExecute(Sender: TObject);
var
  C: TObject;
begin
  C:= GetActiveControl;

  if Assigned(C) and C.InheritsFrom(TControl) then
    (C as TControl).SendToBack;
end;

procedure Tdlg_gsResizer_Palette.actSendToBackUpdate(Sender: TObject);
var
  C: TObject;
begin
  C:= GetActiveControl;

  if Assigned(C) and C.InheritsFrom(TControl) then
    actSendToBack.Enabled := True
  else
    actSendToBack.Enabled := False;
end;

function Tdlg_gsResizer_Palette.GetActiveControl(const ANoCut: boolean): TControl;
var
 i: integer;
begin
  Result:= nil;
  try

    if not Assigned(FManager) then Exit;
    if FManager.ResizersList.Count = 0 then Exit;

    if ANoCut then begin
      i:= 0;
      repeat
        Result:= FManager.ResizersList[i] as TControl;
        Inc(i);
      until (i = FManager.ResizersList.Count) or not TgsResizer(Result).Cut;
    end
    else
      Result:= FManager.ResizersList[0] as TControl;

    if Result is TgsResizer then
      Result := TgsResizer(Result).MovedControl;
    while Assigned(Result) and (Result.Name = '') do
      Result := Result.Parent;
  except
    Result:= nil;
  end;
end;

initialization
  RegisterClasses([TTabSheet, TAction, TTBItem, TTBSeparatorItem, TTBSubmenuItem, TMenuItem, TgsAction]);
  RegisterClasses([TADTField, TDateField, TReferenceField, TAggregateField,
    TDateTimeField, TSmallIntField, TArrayField, TFloatField, TStringField,
    TAutoIncField, TGraphicField, TTimeField, TBCDField, TGuidField,
    TVarBytesField, TBlobField, TIDispatchField, TVariantField, TBooleanField,
    TIntegerField, TWideStringField, TBytesField, TLargeIntField, TWordField,
    TCurrencyField, TMemoField, TIBBCDField]);
{  RegisterNewClasses('Стандартные', [TLabel, TEdit, TButton, TMemo, TPopupMenu,
                     TCheckBox, TRadioButton, TListBox, TComboBox, TGroupBox, TRadioGroup, TPanel]);
  RegisterNewClasses('БД', [TDBEdit, TgsIBLookupCombobox, TgsIBGrid, TxDateDBEdit]);
  RegisterNewClasses('Дополнительные', [TxDateEdit]);
 }
  RegisterNewClasses('Стандартные', [TBevel, TBitBtn, TButton, TCheckbox, TCheckListbox,
         TCombobox, TEdit, TGroupbox, TLabel, TListbox, TListview, TMainmenu, TMemo,
         TPageControl, TPanel, TPopupMenu, TRadioButton, TRadioGroup, TSpeedButton,
         TSplitter, TStaticText, TStatusBar, TStringGrid, TTreeView, TgsColorComboBox, TBtnEdit]);
  RegisterNewClasses('Дополнительные', [TAnimate, TDirectoryListbox, TColorGrid, TControlbar, TCoolbar,
         TDateTimePicker, TDrawGrid, TDriveCombobox, TFileListbox, TFilterCombobox, TGauge, TImage,
         TMaskEdit, TMonthCalendar, TPageScroller, TPaintbox, TProgressBar, TRichEdit, TScrollbar,
         TScrollbox, TShape, TSpinButton, TSpinEdit, TTabControl, TtbBackground, TtbDock,
         TtbGroupItem, TtbItemContainer, TtbToolbar, TtbToolWindow, TToolbar, TTrackbar,
         TUpDown, TxCalculatorEdit, TxDateEdit, TxFoCal, TgdReportMenu, TgdMacrosMenu, TQueryFilterGDC,
         TWebBrowser, TgsPeriodEdit]);
  RegisterNewClasses('Системные', [TActionList, THeaderControl, THotKey, TImageList, TOutLine, TTimer, TgsScanerHook, TgsComScaner]);
  RegisterNewClasses('БД компоненты', [TdbCheckbox, TdbCombobox, TdbEdit, TdbImage, TJvDBImage,
    TdbListbox, TdbMemo, TdbNavigator, TdbRadioGroup, TdbRichedit, TdbText, TgsdbGrid, TgsdbReduction,
    TgsdbReductionWizard, TgsibGrid, TxdbCalculatorEdit, TgsIBLookupCombobox, TgsDBTreeView,
    TxDateDBEdit, TAtContainer, TgsComboBoxAttrSet, TDBLookupComboBox ]);
  RegisterNewClasses('БД доступ', [TClientDataSet, TDataSource]);
  RegisterNewClasses('Interbase', [{TibClientDataset,} TibDatabase, TibDatabaseInfo, TibDataset, {TibDatasource,} TibEvents, TibExtract, TibQuery, {TibScript,} TibSQL, TibSqlMonitor, TibStoredProc, TibTable, TibTransaction, TibUpdateSql]);
  RegisterNewClasses('Диалоги', [TFindDialog, TFontDialog, TOpenDialog, TOpenPictureDialog, TPrintDialog, TPrinterSetupDialog, TReplaceDialog, TSaveDialog, TSavePictureDialog, TColorDialog]);
  RegisterNewClasses('SynEdit', [TSynEdit, TSynMemo, TSynVBScriptSyn, TSynSQLSyn]);
{$IFDEF MODEM}
  RegisterNewClasses('Модем', [TgsModem]);
{$ENDIF}

finalization
  ClearComponents;


end.
