unit prp_MacrosFrame;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PRP_FUNCTIONFRAME_UNIT, Db, IBCustomDataSet, gdcBase, gdcFunction,
  ExtCtrls, SynEdit, SynDBEdit, gsFunctionSyncEdit, StdCtrls, DBCtrls,
  Mask, ComCtrls, gdcMacros, Menus, ImgList, SynCompletionProposal,
  SynHighlighterJScript, SynEditHighlighter, SynHighlighterVBScript,
  gdcTree, gdcDelphiObject, ActnList, prp_TreeItems, SuperPageControl,
  IBQuery, prpDBComboBox, SynEditExport, SynExportRTF, gdcCustomFunction,
  StdActns, TB2Dock, TB2Item, TB2Toolbar, IBSQL, gdcBaseInterface, clipbrd;

type
  TMacrosFrame = class(TFunctionFrame)
    gdcMacros: TgdcMacros;
    dsMacros: TDataSource;
    dsServers: TDataSource;
    dbcbMacrosName: TDBComboBox;
    hkMacros: THotKey;
    dbcbDisplayInMenu: TDBCheckBox;
    lblHotKey: TLabel;
    lMacrosName: TLabel;
    lblRUIDMacros: TLabel;
    edtRUIDMacros: TEdit;
    pnlRUIDMacros: TPanel;
    btnCopyRUIDMacros: TButton;
    procedure actProperty1Execute(Sender: TObject);
    procedure hkMacrosMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure gdcMacrosAfterEdit(DataSet: TDataSet);
    procedure btnCopyRUIDFunctionClick(Sender: TObject);
    procedure pMainResize(Sender: TObject);
    procedure btnCopyRUIDMacrosClick(Sender: TObject);
    procedure actAddToSettingExecute(Sender: TObject);
    procedure actAddToSettingUpdate(Sender: TObject);
  private
    { Private declarations }
    FShortCut: TShortCut;
  protected
    function GetMasterObject: TgdcBase;override;
    function GetDetailObject: TgdcBase; override;
    function GetModule: string; override;
    function GetInfoHint: String; override;
    function GetSaveMsg: string; override;
    function GetDeleteMsg: string; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
    procedure DoOnCreate; override;
    procedure hkMacrosKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    class function GetNameFromDb(Id: Integer): string; override;
    class function GetTypeName: String; override;

  public
    function Delete: Boolean;override;
    function Run(const SFType: sfTypes): Variant; override;

    procedure Post; override;
    procedure Setup(const FunctionName: String = ''); override;

    //Блок процедур отвечающих за копирование
    // Помещает объект в буфер
    procedure CopyObject; override;
    // Вставляет объект
    procedure PasteObject; override;

    function Move(TreeItem: TCustomTreeItem): TCustomTreeItem; override;
    class function GetFunctionIdEx(Id: Integer): integer; override;
  end;

var
  MacrosFrame: TMacrosFrame;

const
  cInfoHint = 'Макрос %s'#13#10'Владелец %s';
  cSaveMsg = 'Макрос %s был изменён. Сохранить изменения?';
  cDelMsg = 'Удалить макрос %s?';

implementation

uses
  rp_report_const, gdcConstants, prp_MessageConst, evt_i_Base, gd_SetDatabase,
  prp_dfPropertyTree_Unit, at_AddToSetting
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

type
  TCrackHotKey = class(THotKey);
{$R *.DFM}

{ TMacrosFrame }

function TMacrosFrame.GetDetailObject: TgdcBase;
begin
  Result := gdcFunction;
end;

function TMacrosFrame.GetMasterObject: TgdcBase;
begin
  Result := gdcMacros;
end;

function TMacrosFrame.Delete: Boolean;
var
  N: TTreeNode;
begin
  N := Node;
  Result := inherited Delete;
  if Result then
    if Assigned(N) then N.Delete;
end;

procedure TMacrosFrame.Setup(const FunctionName: String = '');
begin
  if Assigned(CustomTreeItem) then
  begin
    gdcMacros.FieldByName(fnFunctionKey).AsInteger := gdcMacros.GetNextID(True);
    gdcFunction.FieldByName(fnId).AsInteger := gdcMacros.FieldByName(fnFunctionKey).AsInteger;
    gdcMacros.FieldByName(fnName).AsString := CustomTreeItem.Name +
      RUIDToStr(gdcFunction.GetRUID);
    gdcMacros.FieldByName(fnMacrosGroupKey).AsInteger := TMacrosTreeItem(CustomTreeItem).MacrosFolderId;
  end;

  inherited;
  gdcFunction.FieldByName(fnScript).AsString := Format(VB_MACROS_TEMPLATE,
    [gdcFunction.FieldByName(fnName).AsString]); 
end; 

function TMacrosFrame.GetInfoHint: String;
begin
  if Assigned(CustomTreeItem) then
    Result := Format(cInfoHint, [CustomTreeItem.Name, CustomTreeItem.MainOwnerName])
  else
    Result := '';
end;

function TMacrosFrame.GetModule: string;
begin
  Result := scrMacrosModuleName;
end;

function TMacrosFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TMacrosFrame.GetCanRun: Boolean;
begin
  Result := True;
end;

procedure TMacrosFrame.actProperty1Execute(Sender: TObject);
var
  R: Boolean;
begin
  EventControl.DisableProperty;
  try
    R := gdcMacros.EditDialog('Tgdc_dlgObjectProperties');
    if R then Modify := R;
  finally
    EventControl.EnableProperty;
  end;
end;

procedure TMacrosFrame.DoOnCreate;
begin
  inherited;

  TCrackHotKey(hkMacros).OnKeyUp := hkMacrosKeyUp;
end;

procedure TMacrosFrame.hkMacrosKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FShortCut <> hkMacros.HotKey then Modify := True;
end;

procedure TMacrosFrame.hkMacrosMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FShortCut := hkMacros.HotKey;
end;

procedure TMacrosFrame.Post;
begin
  gdcMacros.FieldByName(fnShortCut).AsInteger := hkMacros.HotKey;
  inherited;
end;

procedure TMacrosFrame.gdcMacrosAfterEdit(DataSet: TDataSet);
begin
  inherited;
  hkMacros.HotKey := gdcMacros.FieldByName(fnShortCut).AsInteger;
  edtRUIDMacros.Text:= gdcBaseManager.GetRUIDStringByID(gdcMacros.ID);
end;

function TMacrosFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

function TMacrosFrame.GetDeleteMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cDelMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetDeleteMsg;
end;

function TMacrosFrame.Run(const SFType: sfTypes): Variant;
begin
  inherited Run(sfMacros);
end;

procedure TMacrosFrame.CopyObject;
var
  TmpStream: TMemoryStream;
  Str: String;
  I: Integer;
  ItemType: TTreeItemType;
  ParamStr: TStream;
begin
  // копируем скрипт и комментарий
  TmpStream := TMemoryStream.Create;
  try
    try
      ItemType := tiMacros;
      TmpStream.Write(ItemType, SizeOf(ItemType));

      Str := gdcMacros.FieldByName(fnName).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);

      Str := gdcFunction.FieldByName(fnName).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);
      Str := gdcFunction.FieldByName(fnScript).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);
      Str := gdcFunction.FieldByName(fnComment).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);

      ParamStr := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmRead);
      try
        I := ParamStr.Size;
        TmpStream.Write(I, SizeOf(I));
        TmpStream.CopyFrom(ParamStr, I);
      finally
        ParamStr.Free;
      end;
      
      dfPropertyTree.dfClipboard.FillClipboard(TmpStream, ItemType);
    except
      raise Exception.Create(dfCopyError);
    end;
  finally
    TmpStream.Free;
  end;
end;

function TMacrosFrame.Move(TreeItem: TCustomTreeItem): TCustomTreeItem;
begin
  Result := nil;
  if dfPropertyTree.dfClipboard.CanMakePasteObject(TreeItem) then
  begin
    gdcFunction.FieldByName(fnName).asString :=
      gdcFunction.GetUniqueName('copy', gdcFunction.FieldByName(fnName).AsString,
          TreeItem.OwnerId);
    gdcFunction.FieldByName(fnModuleCode).AsInteger := TreeItem.OwnerId;

    gdcMacros.FieldByName(fnName).AsString := gdcMacros.GetUniqueName('copy',
      gdcMacros.FieldByName(fnName).AsString, TreeItem.Id);
    gdcMacros.FieldByName(fnMacrosGroupKey).AsInteger := TreeItem.Id;
    Result := CustomTreeItem;
    Result.OwnerId := TreeItem.OwnerId;
    Result.MainOwnerName := TreeItem.MainOwnerName;
    TMacrosTreeItem(Result).MacrosFolderId := TreeItem.Id;
    gdcFunction.Post;
    gdcMacros.Post;
    Cancel;
  end;
end;

procedure TMacrosFrame.PasteObject;
var
  OldName, NewName, Str, tmpStr: String;
  I: Integer;
  ItemType: TTreeItemType;
  SearchOptions: TSynSearchOptions;
  ParamStr: TStream;
begin
  if dfPropertyTree.dfClipboard.ObjectType <> tiMacros then
    raise Exception.Create(dfPasteError);

  with dfPropertyTree.dfClipboard.ObjectStream do
  try
    Position := 0;
    Read(ItemType, SizeOf(ItemType));
    if ItemType <> tiMacros then
      raise Exception.Create(dfPasteError);

    Read(I, SizeOf(I));
    SetLength(Str, I);
    Read(Str[1], I);
    TmpStr := GetUniCopyname(Str, gdcMacros.ID);//GetUniname(TmpStr, Str, NameList, IBSQL);
    if Length(TmpStr) = 0 then
      TmpStr := Str;
    gdcMacros.FieldByName(fnName).AsString := TmpStr;
    Node.Text := TmpStr;
    SpeedButton.Caption := TmpStr;

    Read(I, SizeOf(I));
    SetLength(OldName, I);
    Read(OldName[1], I);
    NewName :=
      GetUniCopyname(OldName, gdcFunction.ID);
    if Length(NewName) = 0 then
      NewName := OldName;
    gdcFunction.FieldByName(fnName).AsString := NewName;

    Read(I, SizeOf(I));
    SetLength(Str, I);
    Read(Str[1], I);
    gdcFunction.FieldByName(fnScript).AsString := Str;

    Read(I, SizeOf(I));
    SetLength(Str, I);
    Read(Str[1], I);
    gdcFunction.FieldByName(fnComment).AsString := Str;

    ParamStr := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmWrite);
    try
      Read(I, SizeOf(I));
      if I > 0 then
      begin
        ParamStr.CopyFrom(dfPropertyTree.dfClipboard.ObjectStream, I);
        ParamStr.Position := 0;
        FunctionParams.LoadFromStream(ParamStr);
      end;
    finally
      ParamStr.Free;
    end;

  except
    raise Exception.Create(dfPasteError);
  end;

  if MessageBox(Handle, 'Вставлен макрос из буфера. Скорректировать имя скрипт-функции?',
    'Вставка макроса',
    MB_YESNO or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST) = IDYES then
  begin
    SearchOptions := [ssoWholeWord, ssoReplaceAll];
    gsFunctionSynEdit.SearchReplace(OldName, NewName, SearchOptions);
  end;
end;

class function TMacrosFrame.GetNameFromDb(Id: Integer): string;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQl.SQL.Text := 'SELECT name FROM evt_macroslist WHERE id = :id';
    SQL.ParamByName('id').AsInteger := id;
    SQL.ExecQuery;
    Result := SQL.FieldByName('name').AsString;
  finally
    SQL.Free;
  end;
end;

class function TMacrosFrame.GetTypeName: string;
begin
  Result := 'Макрос ';
end;

class function TMacrosFrame.GetFunctionIdEx(Id: Integer): integer;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQl.Create(nil);
  try
    SQl.Transaction := gdcBaseManager.ReadTransaction;
    SQl.SQl.Text := 'SELECT functionkey FROM evt_macroslist WHERE id = :id';
    SQL.ParamByName('id').AsInteger := Id;
    SQL.ExecQuery;
    Result := SQL.FieldByName('functionkey').AsInteger;
  finally
    SQl.Free;
  end;
end;

procedure TMacrosFrame.btnCopyRUIDFunctionClick(Sender: TObject);
begin
  Clipboard.AsText:= edtRUIDFunction.Text;
end;

procedure TMacrosFrame.btnCopyRUIDMacrosClick(Sender: TObject);
begin
  Clipboard.AsText:= edtRUIDMacros.Text;
end;

procedure TMacrosFrame.pMainResize(Sender: TObject);
begin
  inherited;
  edtRUIDMacros.Width:= pMain.ClientWidth - edtRUIDMacros.Left - 87;
  pnlRUIDMacros.Left:= edtRUIDMacros.Left + edtRUIDMacros.Width + 2;
  pnlRUIDMacros.Width:= 75;
end;

procedure TMacrosFrame.actAddToSettingExecute(Sender: TObject);
begin
  if PageControl.ActivePage = tsScript then
    at_AddToSetting.AddToSetting(False, '', '', gdcFunction, nil)
  else
    inherited;
end;

procedure TMacrosFrame.actAddToSettingUpdate(Sender: TObject);
begin
  if PageControl.ActivePage = tsScript then
    actAddToSetting.Enabled := (gdcFunction <> nil)
      and (not gdcFunction.IsEmpty)
  else
    inherited;
end;

initialization
  RegisterClass(TMacrosFrame);
finalization
  UnRegisterClass(TMacrosFrame);
end.
