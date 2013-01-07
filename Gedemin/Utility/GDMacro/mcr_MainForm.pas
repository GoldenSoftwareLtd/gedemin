unit mcr_MainForm;
 
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, contnrs, mcr_Foundation, ExtCtrls, ComCtrls, Buttons;

type
  Tfrm_mcrMainForm = class(TForm)
    pcMain: TPageControl;
    tsParams: TTabSheet;
    tsResult: TTabSheet;
    plMemo: TPanel;
    lbResult: TListBox;
    gdSearch: TGroupBox;
    lbPath: TLabel;
    edPath: TEdit;
    edMask: TEdit;
    lbMask: TLabel;
    gbComment: TGroupBox;
    lblBeginComment: TLabel;
    edBeginComment: TEdit;
    edEndComment: TEdit;
    Label1: TLabel;
    gbDelete: TGroupBox;
    lblDeleteName: TLabel;
    edDeleteMacro: TEdit;
    gbControl: TGroupBox;
    btSearch: TButton;
    btnMacrosReplace: TButton;
    btnUnfoldRepl: TButton;
    btnDeleteMacro: TButton;
    btnSearchCall: TButton;
    btnSearchUnfold: TButton;
    tsStatic: TTabSheet;
    cbRecursive: TCheckBox;
    tsSelect: TTabSheet;
    pnlSelect: TPanel;
    lbUnfold: TListBox;
    lbIgnore: TListBox;
    lblAdd: TLabel;
    Label3: TLabel;
    btnReturn: TBitBtn;
    btnDelete: TBitBtn;
    lbDeleteMacros: TListBox;
    btnAddDelMacro: TButton;
    btnDelDelMacro: TButton;
    btnRefresh: TButton;
    btnAddAllDelMacro: TButton;
    btnExit: TButton;
    cbBackup: TCheckBox;
    procedure btSearchClick(Sender: TObject);
    procedure edPathDblClick(Sender: TObject);
    procedure btnSearchCallClick(Sender: TObject);
    procedure mmMacroDeclDblClick(Sender: TObject);
    procedure mmMacroDeclClick(Sender: TObject);
    procedure btnSearchUnfoldClick(Sender: TObject);
    procedure edPathChange(Sender: TObject);
    procedure btnMacrosReplaceClick(Sender: TObject);
    procedure edBeginCommentChange(Sender: TObject);
    procedure edEndCommentChange(Sender: TObject);
    procedure btnDeleteMacroClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnUnfoldReplClick(Sender: TObject);
    procedure lbResultMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure cbRecursiveClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnReturnClick(Sender: TObject);
    procedure btnAddDelMacroClick(Sender: TObject);
    procedure btnDelDelMacroClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnAddAllDelMacroClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
//    MacroDeclList: TStrings;
    FmcrList: TmcrMacroList;

    function  CompareSeachParams(const Scan: Boolean = True): Boolean;
    function  TestUnfoldPrepare: Boolean;
    procedure PassParams;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    property mcrList: TmcrMacroList read FmcrList write FmcrList;
  end;
var
  frm_mcrMainForm: Tfrm_mcrMainForm;

implementation

uses
  FileCtrl, mcr_frmGauge;

{$R *.DFM}

procedure Tfrm_mcrMainForm.btSearchClick(Sender: TObject);
begin
  if not CompareSeachParams(False) then
    Exit;

  mcrList.FindDeclares;
  lbResult.Items := mcrList.LogList;
  btnRefreshClick(Sender);
end;

constructor Tfrm_mcrMainForm.Create(AOwner: TComponent);
begin
  inherited;

  FmcrList := TmcrMacroList.Create;
  edBeginComment.Text := mcrList.BeginComment;
  edEndComment.Text := mcrList.EndComment;
  edPath.Text := mcrList.Path;
  edMask.Text := mcrList.FileMask;
  mcrList.RecursiveSearch := cbRecursive.Checked;
  mcrList.IgnoreMacros := lbIgnore.Items;
  mcrList.WorkMacros := lbUnfold.Items;
  frmGauge := TfrmGauge.Create(Self);
  frmGauge.Parent := Self;
  frmGauge.Close;

//  lbResult.Hint
//  mcrList.LogList := lbResult.Items;
end;

destructor Tfrm_mcrMainForm.Destroy;
begin
  mcrList.Path := edPath.Text;
  mcrList.FileMask := edMask.Text;
  mcrList.BeginComment := edBeginComment.Text;
  mcrList.EndComment := edEndComment.Text;
  FmcrList.Free;

  inherited;
end;

procedure Tfrm_mcrMainForm.edPathDblClick(Sender: TObject);
var
  SearchDir: string;
begin
  edPath.Text := SearchDir;
  if SelectDirectory('Choose a search path...', '', SearchDir) then
    edPath.Text := SearchDir;
end;


procedure Tfrm_mcrMainForm.btnSearchCallClick(Sender: TObject);
begin

  if (not CompareSeachParams) or (not TestUnfoldPrepare) then
    Exit;

//  PassParams;
  mcrList.UnfoldMacros(cbBackup.Checked);
  lbResult.Items := mcrList.LogList;
end;

procedure Tfrm_mcrMainForm.mmMacroDeclClick(Sender: TObject);
begin
//  if mcrList.Macro[mmMacroDecl.Lines.].Body.Count = 0 then
//    mmMacroCall.Items := mcrList.Macro[mmMacroDecl.itemIndex].Errors
//  else
//    mmMacroCall.Items := mcrList.Macro[mmMacroDecl.itemIndex].Body;
end;

procedure Tfrm_mcrMainForm.mmMacroDeclDblClick(Sender: TObject);
begin
//  mmMacroCall.Items := mcrList.Macro[mmMacroDecl.itemIndex].Params;
end;

procedure Tfrm_mcrMainForm.btnSearchUnfoldClick(Sender: TObject);
begin
  if not CompareSeachParams then
    Exit;

  PassParams;
  mcrList.CutMacros;
  lbResult.Items := mcrList.LogList;
end;

procedure Tfrm_mcrMainForm.edPathChange(Sender: TObject);
begin
//  mcrList.Path := edPath.Text;
//  mcrList.FileMask := edMask.Text;
end;

procedure Tfrm_mcrMainForm.btnMacrosReplaceClick(Sender: TObject);
begin
  if not CompareSeachParams then
    Exit;

  if not TestUnfoldPrepare then
    Exit;

//  PassParams;
  mcrList.ReplaceMacros;
  lbResult.Items := mcrList.LogList;
end;

procedure Tfrm_mcrMainForm.edBeginCommentChange(Sender: TObject);
begin
  mcrList.BeginComment := edBeginComment.Text;
end;

procedure Tfrm_mcrMainForm.edEndCommentChange(Sender: TObject);
begin
  mcrList.EndComment := edEndComment.Text;
end;

procedure Tfrm_mcrMainForm.btnDeleteMacroClick(Sender: TObject);
var
  i: Integer;
begin
  PassParams;
  for i := 0 to lbDeleteMacros.Items.Count - 1 do
    mcrList.DeleteMacroCall(lbDeleteMacros.Items[i]);
  lbResult.Items := mcrList.LogList;
end;

procedure Tfrm_mcrMainForm.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure Tfrm_mcrMainForm.btnUnfoldReplClick(Sender: TObject);
begin
  if (not CompareSeachParams) or (not TestUnfoldPrepare) then
    Exit;
    
  mcrList.UnfoldAndReplace(cbBackup.Checked);
  lbResult.Items := mcrList.LogList;
end;

procedure Tfrm_mcrMainForm.lbResultMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if lbResult.ItemIndex > -1 then
    lbResult.Hint := lbResult.Items[lbResult.ItemIndex]
  else
    lbResult.Hint := '';
end;

procedure Tfrm_mcrMainForm.cbRecursiveClick(Sender: TObject);
begin
  PassParams;
  mcrList.RecursiveSearch := cbRecursive.Checked;
end;

procedure Tfrm_mcrMainForm.PassParams;
begin
  mcrList.Path := edPath.Text;
  mcrList.FileMask := edMask.Text;
  mcrList.BeginComment := edBeginComment.Text;
  mcrList.EndComment := edEndComment.Text;
end;

procedure Tfrm_mcrMainForm.btnDeleteClick(Sender: TObject);
var
  i: Integer;
begin
  for i := lbUnfold.Items.Count - 1 downto 0 do
    if lbUnfold.Selected[i] then
    begin
      lbIgnore.Items.Add(lbUnfold.Items[i]);
      lbUnfold.Items.Delete(i);
    end;

end;

procedure Tfrm_mcrMainForm.btnReturnClick(Sender: TObject);
var
  i: Integer;
begin
  for i := lbIgnore.Items.Count - 1 downto 0 do
    if lbIgnore.Selected[i] then
    begin
      lbUnfold.Items.Add(lbIgnore.Items[i]);
      lbIgnore.Items.Delete(i);
    end;

end;

procedure Tfrm_mcrMainForm.btnAddDelMacroClick(Sender: TObject);
begin
  if lbDeleteMacros.Items.IndexOf(Trim(edDeleteMacro.Text)) = -1 then
    lbDeleteMacros.Items.Add(Trim(edDeleteMacro.Text));
  edDeleteMacro.Text := '';
end;

procedure Tfrm_mcrMainForm.btnDelDelMacroClick(Sender: TObject);
begin
  if lbDeleteMacros.ItemIndex > -1 then
    lbDeleteMacros.Items.Delete(lbDeleteMacros.ItemIndex);
end;

procedure Tfrm_mcrMainForm.btnRefreshClick(Sender: TObject);
var
  i: Integer;
begin
  lbUnfold.Items.Clear;
  for i := 0 to mcrList.Count - 1 do
    if lbIgnore.Items.IndexOf(mcrList[i].Name) = -1 then
      lbUnfold.Items.Add(mcrList[i].Name);

end;

procedure Tfrm_mcrMainForm.btnAddAllDelMacroClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to mcrList.Count - 1 do
    if lbDeleteMacros.Items.IndexOf(mcrList[i].Name) = -1 then
      lbDeleteMacros.Items.Add(mcrList[i].Name);

end;

function Tfrm_mcrMainForm.CompareSeachParams(const Scan: Boolean): Boolean;
begin
  Result := True;
  if (edPath.Text <> mcrList.Path) or (edMask.Text <> mcrList.FileMask) then
    case MessageDlg(
        'Изменены параметры поиска:'#13#10 +
        mcrList.Path + ' -> ' + edPath.Text + #13#10 +
        mcrList.FileMask + ' -> ' + edMask.Text + #13#10 +
        'Произвести поиск с новыми параметрами',
        mtWarning, [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        begin
          PassParams;
          if Scan then
            if not mcrList.SetFullFileList then
              Result := False;
        end;
      mrNo: Result := True;
      mrCancel:
        begin
          Result := False;
          Exit;
        end;
    end;
end;

function Tfrm_mcrMainForm.TestUnfoldPrepare: Boolean;
begin
  Result := False;
  if not (mcrList.WorkMacros.Count > 0) then
  begin
    MessageBox(0, 'Необходимо выбрать макросы для разворачивания.',
      'Ошибка', mb_Ok or MB_IconError or MB_TASKMODAL);
    pcMain.ActivePage := tsSelect;
  end else
    Result := True;
end;

procedure Tfrm_mcrMainForm.FormCreate(Sender: TObject);
begin
  PassParams;
end;

end.
