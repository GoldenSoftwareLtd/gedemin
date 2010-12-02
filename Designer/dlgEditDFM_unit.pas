
unit dlgEditDFM_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, SynEdit, SynEditHighlighter, SynHighlighterDfm,
  TB2Dock, TB2Toolbar, TB2Item, dmImages_unit, Menus, ActnList,
  gsSearchReplaceHelper;

type
  TdlgEditDFM = class(TForm)
    SynDfmSyn1: TSynDfmSyn;
    seDFM: TSynEdit;
    Panel1: TPanel;
    btnOk: TButton;
    Button2: TButton;
    ActionList: TActionList;
    actLoadFromFile: TAction;
    actSaveToFile: TAction;
    actFind: TAction;
    actReplace: TAction;
    actCopy: TAction;
    actCut: TAction;
    actPaste: TAction;
    TBToolbar1: TTBToolbar;
    TBItem18: TTBItem;
    TBItem19: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem16: TTBItem;
    TBItem15: TTBItem;
    TBSeparatorItem5: TTBSeparatorItem;
    TBItem14: TTBItem;
    TBItem13: TTBItem;
    TBItem12: TTBItem;
    TBPopupMenu1: TTBPopupMenu;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
    TBItem7: TTBItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    actFindNext: TAction;
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnOkClick(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
  private
    FSearchReplaceHelper: TgsSearchReplaceHelper;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

function EditDFM(const AName: String; var S: String): Boolean;

implementation

uses
  prp_MessageConst
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;
  
{$R *.DFM}

function EditDFM(const AName: String; var S: String): Boolean;
begin
  Result := False;
  with TdlgEditDFM.Create(nil) do
  try
    Caption := AName;
    seDFM.Lines.Text := S;

    if (ShowModal = mrOk) and (seDFM.Lines.Text <> S) then
    begin
      S := seDFM.Lines.Text;
      Result := True;
    end
  finally
    Free;
  end
end;

constructor TdlgEditDFM.Create(AnOwner: TComponent);
begin
  inherited;
  FSearchReplaceHelper := TgsSearchReplaceHelper.Create(seDFM);
end;

destructor TdlgEditDFM.Destroy;
begin
  FreeAndNil(FSearchReplaceHelper);
  inherited;
end;

procedure TdlgEditDFM.actLoadFromFileExecute(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    seDFM.Lines.LoadFromFile(OpenDialog1.FileName);
  end;
end;

procedure TdlgEditDFM.actSaveToFileExecute(Sender: TObject);
begin
  SaveDialog1.FileName := Caption;
  if SaveDialog1.Execute then
    seDFM.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TdlgEditDFM.actFindExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Search;
end;

procedure TdlgEditDFM.actFindNextExecute(Sender: TObject);
begin
  FSearchReplaceHelper.SearchNext;
end;

procedure TdlgEditDFM.actReplaceExecute(Sender: TObject);
begin
  FSearchReplaceHelper.Replace;
end;

procedure TdlgEditDFM.actCopyExecute(Sender: TObject);
begin
  seDFM.CopyToClipboard;
end;

procedure TdlgEditDFM.actCutExecute(Sender: TObject);
begin
  seDFM.CutToClipboard;
end;

procedure TdlgEditDFM.actPasteExecute(Sender: TObject);
begin
  seDFM.PasteFromClipboard;
end;

procedure TdlgEditDFM.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if seDFM.Modified then
  begin
    if Messagedlg('Хотите выйти без сохранения?',
         mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      CanClose := False;
  end;
end;

procedure TdlgEditDFM.btnOkClick(Sender: TObject);
begin
  seDFM.Modified := False; 
end;

end.
