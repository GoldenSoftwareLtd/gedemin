unit prp_SFFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PRP_FUNCTIONFRAME_UNIT, ImgList, SynCompletionProposal,
  SynHighlighterJScript, SynEditHighlighter, SynHighlighterVBScript,
  gdcTree, gdcDelphiObject, Db, IBCustomDataSet, gdcBase, gdcFunction,
  ActnList, Menus, ExtCtrls, SynEdit, SynDBEdit, gsFunctionSyncEdit,
  StdCtrls, DBCtrls, ComCtrls, SuperPageControl, prpDBComboBox,
  SynEditExport, SynExportRTF, gdcCustomFunction, StdActns, Mask, TB2Item,
  TB2Dock, TB2Toolbar, prp_TreeItems, prp_dfPropertyTree_Unit;

type
  TSFFrame = class(TFunctionFrame)
    Label1: TLabel;
    DBText1: TDBText;
  private
    { Private declarations }
  protected
    function GetModule: string; override;
    function GetInfoHint: String; override;
    function GetSaveMsg: string; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
  public
    { Public declarations }
    procedure Setup(const FunctionName: String = ''); override;
    function Delete: Boolean;override;

    // Вставляет объект
    procedure PasteObject; override;
    // Помещает объект в буфер
    procedure CopyObject; override;
//    procedure CopyObject(const dfClipboart: TdfClipboart); override; overload;
  end;

var
  SFFrame: TSFFrame;

const
  cInfoHint = 'Скрипт - функция %s'#13#10'Владелец %s';
  cSaveMsg = 'Скрипт - функция %s была изменёна. Сохранить изменения?';

implementation

uses
  rp_report_const, dm_i_ClientReport_unit, gd_i_ScriptFactory, gdcConstants,
  prp_MessageConst
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

{ TSFFrame }

procedure TSFFrame.CopyObject;
var
  TmpStream: TMemoryStream;
  ParamStr: TStream;
  Str: String;
  I: Integer;
  ItemType: TTreeItemType;
begin
  // копируем скрипт и комментарий
  TmpStream := TMemoryStream.Create;
  try
    try
      ItemType := tiSF;
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

      ParamStr := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmRead);
      try
        I := ParamStr.Size;
        TmpStream.Write(I, SizeOf(I));
        TmpStream.CopyFrom(ParamStr, I);
      finally
        ParamStr.Free;
      end;
      // Write(Str[1], I);

      dfPropertyTree.dfClipboard.FillClipboard(TmpStream, ItemType);
    except
      raise Exception.Create(dfCopyError);
    end;
  finally
    TmpStream.Free;
  end;
end;

function TSFFrame.Delete: Boolean;
var
  N: TTreeNode;
begin
  N := Node;
  Result := inherited Delete;
  if Result then
    if Assigned(N) then N.Delete;
end;

function TSFFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TSFFrame.GetCanRun: Boolean;
begin
  Result := True;
end;

function TSFFrame.GetInfoHint: String;
begin
  if Assigned(CustomTreeItem) then
    Result := Format(cInfoHint, [CustomTreeItem.Name, CustomTreeItem.MainOwnerName])
  else
    Result := '';
end;

function TSFFrame.GetModule: string;
begin
  Result := scrUnkonownModule;
end;

function TSFFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

procedure TSFFrame.PasteObject;
var
  OldName, NewName, Str: String;
  I: Integer;
  ItemType: TTreeItemType;
  SearchOptions: TSynSearchOptions;
  ParamStr: TStream;
begin
  if dfPropertyTree.dfClipboard.ObjectType <> tiSF then
    raise Exception.Create(dfPasteError);

  with dfPropertyTree.dfClipboard.ObjectStream do
  try
    Position := 0;
    Read(ItemType, SizeOf(ItemType));
    if ItemType <> tiSF then
      raise Exception.Create(dfPasteError);
    Read(I, SizeOf(I));
    SetLength(OldName, I);
    Read(OldName[1], I);
    NewName :=
      GetUniCopyname(OldName, gdcFunction.ID);
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

  if MessageBox(Handle, 'Вставлена скрипт-функция из буфера. Скорректировать имя?',
    'Вставка скрипт-функции',
    MB_YESNO or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST) = IDYES then
  begin
    SearchOptions := [ssoWholeWord, ssoReplaceAll];
    gsFunctionSynEdit.SearchReplace(OldName, NewName, SearchOptions);
    Post;
  end;
end;

procedure TSFFrame.Setup(const FunctionName: String = '');
begin
  inherited;
  gdcFunction.FieldByName(fnScript).AsString := Format(VB_SCRIPTFUNCTION_TEMPLATE,
    [gdcFunction.FieldByName(fnName).AsString])
end;

initialization
  RegisterClass(TSFFrame);
finalization
  UnRegisterClass(TSFFrame);

end.
