// ShlTanya, 26.02.2019

unit prp_ScriptComparer_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, dmImages_unit, TB2Dock, TB2Toolbar, TB2Item, ActnList,
  gdc_createable_form;

type
  Tprp_ScriptComparer = class(TgdcCreateableForm)
    pnBottom: TPanel;
    pnMain: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    pnToolBar: TPanel;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    tbNextDiff: TTBItem;
    tbPrevDiff: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    tbOnlyDiff: TTBItem;
    ActionList1: TActionList;
    actFind: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem1: TTBItem;
    actFindNext: TAction;
    actReplace: TAction;
    TBItem2: TTBItem;
    actOnlyDiff: TAction;
    actHorizSplit: TAction;
    tbHorizSplit: TTBItem;
    procedure Compare(S1, S2: String);
    procedure tbNextDiffClick(Sender: TObject);
    procedure tbPrevDiffClick(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actOnlyDiffUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actOnlyDiffExecute(Sender: TObject);
    procedure actHorizSplitExecute(Sender: TObject);
  private
    FileView: TFrame;
    FCanEdit: Boolean; //Использовать как редактор
    FText1: String;
    FText2: String;

  public
    constructor Create(AnOwner: TComponent); override;
    procedure LeftCaption(Text: String);
    procedure RightCaption(Text: String);
    function GetText1: String;
    function GetText2: String;

    property CanEdit: Boolean read FCanEdit write FCanEdit;
  end;

var
  prp_ScriptComparer: Tprp_ScriptComparer;

implementation

{$R *.DFM}

uses
  FileView, gd_ClassList;

{ Tprp_ScriptComparer }

procedure Tprp_ScriptComparer.Compare(S1, S2: String);
begin
  if CanEdit then
  begin
    FText1 := S1;
    FText2 := S2;
  end;
  TFilesFrame(FileView).Compare(S1, S2);
end;

constructor Tprp_ScriptComparer.Create(AnOwner: TComponent);
begin
  inherited;

  pnBottom.Visible := False;
  FileView := TFilesFrame.Create(Self);
  FileView.Parent := pnMain;
  FileView.Align := alClient;
  with TFilesFrame(FileView).FontDialog1.Font do
  begin
    Name := 'Courier New';
    Size := 10;
  end;

  TFilesFrame(FileView).Setup;
  CanEdit := False;
end;

function Tprp_ScriptComparer.GetText1: String;
begin
  Result := TFilesFrame(FileView).CodeEdit1.Lines.Text;
end;

function Tprp_ScriptComparer.GetText2: String;
begin
  Result := TFilesFrame(FileView).CodeEdit2.Lines.Text;
end;


procedure Tprp_ScriptComparer.LeftCaption(Text: String);
begin
  TFilesFrame(FileView).pnlCaptionLeft.Caption := Text;
end;

procedure Tprp_ScriptComparer.RightCaption(Text: String);
begin
  TFilesFrame(FileView).pnlCaptionRight.Caption := Text;
end;

procedure Tprp_ScriptComparer.tbNextDiffClick(Sender: TObject);
begin
  TFilesFrame(FileView).NextClick;
end;

procedure Tprp_ScriptComparer.tbPrevDiffClick(Sender: TObject);
begin
  TFilesFrame(FileView).PrevClick;
end;

procedure Tprp_ScriptComparer.actFindExecute(Sender: TObject);
begin
  TFilesFrame(FileView).FindClick(Self);
end;

procedure Tprp_ScriptComparer.actFindNextExecute(Sender: TObject);
begin
  TFilesFrame(FileView).FindNextClick(Self);
end;

procedure Tprp_ScriptComparer.actReplaceExecute(Sender: TObject);
begin
  TFilesFrame(FileView).ReplaceClick(Self);
end;

procedure Tprp_ScriptComparer.actOnlyDiffUpdate(Sender: TObject);
begin
  actOnlyDiff.Enabled := (TFilesFrame(FileView).CodeEdit1.Lines.Text <> '')
    and (TFilesFrame(FileView).CodeEdit2.Lines.Text <> '')
    and (TFilesFrame(FileView).ChangeCount > 0);
end;

procedure Tprp_ScriptComparer.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if not CanClose then
    exit;

  if CanEdit then
  begin
    if (AnsiCompareText(TFilesFrame(FileView).CodeEdit1.Lines.Text, FText1) <> 0) then
    begin
      case MessageBox(Handle, 'Данные были изменены. Сохранить?', 'Внимание', MB_YESNOCANCEL or MB_ICONQUESTION) of
        IDYES: ModalResult := mrOK;
        IDNO: ModalResult := mrCancel;
        IDCANCEL: ModalResult := mrNone;
      end;

      CanClose := ModalResult <> mrNone;
    end;
  end;
end;

procedure Tprp_ScriptComparer.actOnlyDiffExecute(Sender: TObject);
begin
  tbOnlyDiff.Checked := not tbOnlyDiff.Checked;
  TFilesFrame(FileView).ShowDiffsOnly := tbOnlyDiff.Checked;
  TFilesFrame(FileView).DisplayDiffs;
end;

procedure Tprp_ScriptComparer.actHorizSplitExecute(Sender: TObject);
begin
  tbHorizSplit.Checked := not tbHorizSplit.Checked;
  TFilesFrame(FileView).HorzSplit(tbHorizSplit.Checked);
end;

initialization
  RegisterFrmClass(Tprp_ScriptComparer, 'Форма сравнения двух скриптов');

finalization
  UnRegisterFrmClass(Tprp_ScriptComparer);
end.
