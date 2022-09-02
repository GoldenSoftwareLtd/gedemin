// ShlTanya, 25.02.2019

unit prp_ConstFrame_unit;

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
  TConstFrame = class(TFunctionFrame)
    procedure gdcFunctionAfterPost(DataSet: TDataSet);    
  private
    { Private declarations }
  protected
    function GetModule: string; override;
    function GetInfoHint: String; override;
    function GetSaveMsg: string; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
    function GetDeleteMsg: string; override;
    procedure WarningFunctionName(const AnFunctionName: string;
      AnScriptText: TStrings); override;
    class function GetTypeName: string; override;      
  public
    { Public declarations }
    procedure Setup(const FunctionName: String = ''); override;
    function Delete: Boolean;override;
  end;

var
  ConstFrame: TConstFrame;
const
  cInfoHint = 'Констаны и переменные %s'#13#10'Владелец %s';
  cSaveMsg = 'Констаны и переменные %s были изменены. Сохранить изменения?';
  cDelMsg = 'Удалить список констант и переменных %s?';
implementation
uses rp_report_const, dm_i_ClientReport_unit, gd_i_ScriptFactory, gdcConstants,
  prp_MessageConst;
{$R *.DFM}

{ TConstFrame }

function TConstFrame.GetInfoHint: String;
begin
  if Assigned(CustomTreeItem) then
    Result := Format(cInfoHint, [CustomTreeItem.Name, CustomTreeItem.MainOwnerName])
  else
    Result := '';
end;

function TConstFrame.GetModule: string;
begin
  Result := scrConst;
end;

procedure TConstFrame.gdcFunctionAfterPost(DataSet: TDataSet);
begin
  inherited;
  ScriptFactory.Reset;
  dm_i_ClientReport.CreateGlobalSF;
//  dm_i_ClientReport.CreateVBConst;
//  dm_i_ClientReport.CreateVBClasses;
//  dm_i_ClientReport.CreateGlObjArray;
end;

procedure TConstFrame.Setup(const FunctionName: String = '');
begin
  inherited;
  gdcFunction.FieldByName(fnScript).AsString := Format(VB_CONST,
    [gdcFunction.FieldByName(fnName).AsString])
end;

function TConstFrame.Delete: Boolean;
var
  N: TTreeNode;
begin
  N := Node;
  result := inherited Delete;
  if Result then
    if Assigned(N) then N.Delete;
end;

function TConstFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TConstFrame.GetCanRun: Boolean;
begin
  Result := False;
end;

function TConstFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

function TConstFrame.GetDeleteMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cDelMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

procedure TConstFrame.WarningFunctionName(const AnFunctionName: string;
  AnScriptText: TStrings);
begin
   //Разрешаем все имена
end;

class function TConstFrame.GetTypeName: string;
begin
  Result := 'Константы и переменные ';
end;

initialization
  RegisterClass(TConstFrame);
finalization
  UnRegisterClass(TConstFrame);

end.
