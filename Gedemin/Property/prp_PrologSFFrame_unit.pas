// ShlTanya, 26.02.2019

unit prp_PrologSFFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  PRP_FUNCTIONFRAME_UNIT, SynEditExport, SynExportRTF,
  SynCompletionProposal, gdcTree, gdcDelphiObject, Db, IBCustomDataSet,
  gdcBase, gdcCustomFunction, gdcFunction, StdActns, ActnList, Menus,
  StdCtrls, ExtCtrls, SynEdit, SynDBEdit, gsFunctionSyncEdit, Mask,
  DBCtrls, prpDBComboBox, TB2Item, TB2Dock, TB2Toolbar, SuperPageControl,
  SynEditHighlighter, SynHighlighterProlog;

type
  TPrologSFFrame = class(TFunctionFrame)
    SynPrologSyn: TSynPrologSyn;
    procedure actExternalEditorExecute(Sender: TObject);
  private
  protected
    function GetModule: string; override;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
    function GetInfoHint: String; override;
    function GetSaveMsg: string; override;
    procedure SetHighlighter; override;
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
  rp_report_const, comctrls, gd_ExternalEditor;

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
  Result := False;
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

procedure TPrologSFFrame.actExternalEditorExecute(Sender: TObject);
begin
  InvokeExternalEditor('pl', gsFunctionSynEdit.Lines);
end;

procedure TPrologSFFrame.SetHighlighter;
var
  F: TCustomForm;
begin
  F := GetParentForm(Self);
  if F <> nil then
  begin
    gsFunctionSynEdit.Highlighter := SynPrologSyn;
    UpdateSelectedColor;
  end; 
end;

initialization
  RegisterClass(TPrologSFFrame);
finalization
  UnRegisterClass(TPrologSFFrame);    
end.
