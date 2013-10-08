unit prp_PrologSFFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PRP_FUNCTIONFRAME_UNIT, SynEditExport, SynExportRTF,
  SynCompletionProposal, gdcTree, gdcDelphiObject, Db, IBCustomDataSet,
  gdcBase, gdcCustomFunction, gdcFunction, StdActns, ActnList, Menus,
  StdCtrls, ExtCtrls, SynEdit, SynDBEdit, gsFunctionSyncEdit, Mask,
  DBCtrls, prpDBComboBox, TB2Item, TB2Dock, TB2Toolbar, SuperPageControl;

type
  TPrologSFFrame = class(TFunctionFrame)
  private
  protected
    function GetModule: string; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
    function GetInfoHint: String; override;
    function GetSaveMsg: string; override;
  public
    constructor Create(AOwner: TComponent); override;
    function Delete: Boolean; override;
  end;

var
  PrologSFFrame: TPrologSFFrame;

const
  cInfoHint = 'Пролог - скрипт %s'#13#10'Владелец %s';
  cSaveMsg = 'Пролог - скрипт %s был изменён. Сохранить изменения?';

implementation

{$R *.DFM}

uses
  rp_report_const, comctrls;

constructor TPrologSFFrame.Create(AOwner: TComponent);
begin
  inherited;

  gdcFunction.CompileScript := False;
end;

function TPrologSFFrame.GetModule: string;
begin
  Result := scrPrologModuleName;
end;

function TPrologSFFrame.GetInfoHint: String;
begin
  if Assigned(CustomTreeItem) then
    Result := Format(cInfoHint, [CustomTreeItem.Name, CustomTreeItem.MainOwnerName])
  else
    Result := '';
end;

function TPrologSFFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

function TPrologSFFrame.GetCanRun: Boolean;
begin
  Result := False;
end;

function TPrologSFFrame.GetCanPrepare: Boolean;
begin
  Result := True;
end;

function TPrologSFFrame.Delete: Boolean;
var
  N: TTreeNode;
begin
  N := Node;
  Result := inherited Delete;
  if Result then
    if Assigned(N) then N.Delete;
end;

initialization
  RegisterClass(TPrologSFFrame);
finalization
  UnRegisterClass(TPrologSFFrame);    
end.
