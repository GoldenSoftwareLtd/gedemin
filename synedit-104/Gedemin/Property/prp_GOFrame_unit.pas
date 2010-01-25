unit prp_GOFrame_unit;

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
  TGOFrame = class(TFunctionFrame)
    procedure gdcFunctionAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
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
  end;

var
  GOFrame: TGOFrame;
const
  cInfoHint = 'Глобальный объект %s'#13#10'Владелец %s';
  cSaveMsg = 'Глобальный объект %s был изменён. Сохранить изменения?';
  cDelMsg = 'Удалить глобальный объект %s?';
implementation
uses rp_report_const, dm_i_ClientReport_unit, gd_i_ScriptFactory, gdcConstants,
  prp_MessageConst;

{$R *.DFM}

{ TGOFrame }

function TGOFrame.Delete: Boolean;
var
  N: TTreeNode;
begin
  N := Node;
  Result := inherited Delete;
  if result then
    if Assigned(N) then N.Delete;
end;

function TGOFrame.GetInfoHint: String;
begin
  if Assigned(CustomTreeItem) then
    Result := Format(cInfoHint, [CustomTreeItem.Name, CustomTreeItem.MainOwnerName])
  else
    Result := '';
end;

function TGOFrame.GetModule: string;
begin
  Result := scrGlobalObject;
end;

procedure TGOFrame.Setup(const FunctionName: String = '');
begin
  inherited;
  gdcFunction.FieldByName(fnScript).AsString := Format(VB_GLOBAL_OBJECT,
    [gdcFunction.FieldByName(fnName).AsString,
    gdcFunction.FieldByName(fnName).AsString,
    gdcFunction.FieldByName(fnName).AsString,
    gdcFunction.FieldByName(fnName).AsString])
end;

procedure TGOFrame.gdcFunctionAfterPost(DataSet: TDataSet);
begin
  inherited;

  dm_i_ClientReport.CreateGlobalSF;
  ScriptFactory.Reset;
end;

function TGOFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TGOFrame.GetCanRun: Boolean;
begin
  Result := False;
end;

function TGOFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

function TGOFrame.GetDeleteMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cDelMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

class function TGOFrame.GetTypeName: string;
begin
  Result := 'Глобальный объект ';
end;

initialization
  RegisterClass(TGOFrame);
finalization
  UnRegisterClass(TGOFrame);

end.
