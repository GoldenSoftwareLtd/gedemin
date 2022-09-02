// ShlTanya, 26.02.2019

unit prp_VBClass_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PRP_FUNCTIONFRAME_UNIT, ImgList, ExtCtrls, SynCompletionProposal,
  SynHighlighterJScript, SynEditHighlighter, SynHighlighterVBScript,
  gdcTree, gdcDelphiObject, Db, IBCustomDataSet, gdcBase, gdcFunction,
  ActnList, Menus, SynEdit, SynDBEdit, gsFunctionSyncEdit, StdCtrls,
  DBCtrls, ComCtrls, SuperPageControl, prpDBComboBox, SynEditExport,
  SynExportRTF, gdcCustomFunction, StdActns, Mask, TB2Item, TB2Dock,
  TB2Toolbar;

type
  TVBClassFrame = class(TFunctionFrame)
    procedure gdcFunctionAfterPost(DataSet: TDataSet);
  private
    procedure VBClassesReset;
  protected
    function GetModule: string; override;
    function GetInfoHint: String; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
    function GetSaveMsg: string; override;
    function GetDeleteMsg: string; override;
    class function GetTypeName: string; override;
  public
    { Public declarations }
    function Delete: Boolean;override;
    procedure Setup(const FunctionName: String = ''); override;

    // Вставляет объект
    procedure PasteObject; override;
    // Помещает объект в буфер
    procedure CopyObject; override;
  end;

var
  VBClassFrame: TVBClassFrame;
const
  cInfoHint = 'Класс Visual Basic %s'#13#10'Владелец %s';
  cSaveMsg = 'Класс Visual Basic %s был изменён. Сохранить изменения?';
  cDelMsg = 'Удалить  VB класс %s?';

implementation

uses
  rp_report_const, dm_i_ClientReport_unit, gd_i_ScriptFactory, gdcConstants,
  prp_MessageConst, gd_security_operationconst, prp_TreeItems, prp_dfPropertyTree_Unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

{ TVBClassFrame }

function TVBClassFrame.GetInfoHint: String;
begin
  if Assigned(CustomTreeItem) then
    Result := Format(cInfoHint, [CustomTreeItem.Name, CustomTreeItem.MainOwnerName])
  else
    Result := '';
end;

function TVBClassFrame.GetModule: string;
begin
  Result := scrVBClasses;
end;

procedure TVBClassFrame.gdcFunctionAfterPost(DataSet: TDataSet);
begin
  inherited;

  VBClassesReset; 
end;

procedure TVBClassFrame.Setup(const FunctionName: String = '');
begin
  inherited;
  gdcFunction.FieldByName(fnScript).AsString := Format(VBClASS_TEMPLATE,
    [gdcFunction.FieldByName(fnName).AsString])
end;

function TVBClassFrame.Delete: Boolean;
var
  N: TTreeNode;
begin
  N := Node;
  Result := inherited Delete;
  if Result then
    if Assigned(N) then N.Delete;
    
  VBClassesReset;
end;

function TVBClassFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TVBClassFrame.GetCanRun: Boolean;
begin
  Result := False;
end;

function TVBClassFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

function TVBClassFrame.GetDeleteMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cDelMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

procedure TVBClassFrame.VBClassesReset;
begin
  if Modify then
  begin
    if CustomTreeItem.OwnerId = OBJ_APPLICATION then
    begin
      if Assigned(dm_i_ClientReport) then
      begin
        dm_i_ClientReport.CreateGlobalSF;
      end;
      ScriptFactory.Reset;
    end else
      ScriptFactory.ResetVBClasses(CustomTreeItem.OwnerId);
  end
end;

procedure TVBClassFrame.CopyObject;
var
  TmpStream: TMemoryStream;
  Str: String;
  I: Integer;
  ItemType: TTreeItemType;
begin
  // копируем скрипт и комментарий
  TmpStream := TMemoryStream.Create;
  try
    try
      ItemType := tiVBClass;
      TmpStream.Write(ItemType, SizeOf(ItemType));
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
      dfPropertyTree.dfClipboard.FillClipboard(TmpStream, ItemType);
    except
      raise Exception.Create(dfCopyError);
    end;
  finally
    TmpStream.Free;
  end;
end;

procedure TVBClassFrame.PasteObject;
var
  OldName, NewName, Str: String;
  I: Integer;
  ItemType: TTreeItemType;
  SearchOptions: TSynSearchOptions;
begin
  if dfPropertyTree.dfClipboard.ObjectType <> tiVBClass then
    raise Exception.Create(dfPasteError);

  with dfPropertyTree.dfClipboard.ObjectStream do
  try
    Position := 0;
    Read(ItemType, SizeOf(ItemType));
    if ItemType <> tiVBClass then
      raise Exception.Create(dfPasteError);
    Read(I, SizeOf(I));
    SetLength(OldName, I);
    Read(OldName[1], I);
    NewName :=
      GetUniCopyname(OldName, gdcFunction.ID);
//      GetUniFuncname(OldName, gdcFunction.FieldByName(fnModuleCode).AsInteger);
    if Length(NewName) = 0 then
      NewName := OldName;
    gdcFunction.FieldByName(fnName).AsString := NewName;
    Node.Text := NewName;
    SpeedButton.Caption := NewName;

    Read(I, SizeOf(I));
    SetLength(Str, I);
    Read(Str[1], I);
    gdcFunction.FieldByName(fnScript).AsString := Str;

    Read(I, SizeOf(I));
    SetLength(Str, I);
    Read(Str[1], I);
    gdcFunction.FieldByName(fnComment).AsString := Str;
  except
    raise Exception.Create(dfPasteError);
  end;

  if MessageBox(Handle, 'Вставлен VB-класс из буфера. Скорректировать имя?',
    'Вставка VB-класса',
    MB_YESNO or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST) = IDYES then
  begin
    SearchOptions := [ssoWholeWord, ssoReplaceAll];
    gsFunctionSynEdit.SearchReplace(OldName, NewName, SearchOptions);
  end;
end;

class function TVBClassFrame.GetTypeName: string;
begin
  Result := 'VB класс '
end;

initialization
  RegisterClass(TVBClassFrame);
finalization
  UnRegisterClass(TVBClassFrame);

end.
