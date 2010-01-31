
unit dlgEditDFM_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, SynEdit, SynEditHighlighter, SynHighlighterDfm,
  TB2Dock, TB2Toolbar, TB2Item, dmImages_unit, Menus, ActnList;

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
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnOkClick(Sender: TObject);
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

procedure TdlgEditDFM.ReplaceDialog1Replace(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := ReplaceDialog1.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Handle, MSG_REPLACE_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING);
  end else
  begin
    rOptions := [ssoReplace];
    if frMatchCase in ReplaceDialog1.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog1.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog1.Options then
      Include(rOptions, ssoReplaceAll);
    if seDFM.SelAvail then
      Include(rOptions, ssoSelectedOnly);
    if seDFM.SearchReplace(sSearch, ReplaceDialog1.ReplaceText, rOptions) = 0 then
    begin
      Beep;
      MessageBox(Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_REPLACE),
       MSG_WARNING, MB_OK or MB_ICONWARNING);
    end;
  end;
end;

procedure TdlgEditDFM.FindDialog1Find(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  dlg: TFindDialog;
  sSearch: string;
begin
  if Sender = ReplaceDialog1 then
    dlg := ReplaceDialog1
  else
    dlg := FindDialog1;

  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Handle, MSG_FIND_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING);
  end else
  begin
    rOptions := [];
    if not (frDown in dlg.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, ssoWholeWord);
    if seDFM.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      Beep;
      Application.MessageBox(PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_FIND), MSG_WARNING,
       MB_OK or MB_ICONWARNING);
    end;
  end;
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
  if seDFM.SelAvail then
    FindDialog1.FindText := seDFM.SelText
  else
    FindDialog1.FindText := seDFM.WordAtCursor;
  FindDialog1.Execute;
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

procedure TdlgEditDFM.actReplaceExecute(Sender: TObject);
begin
  if seDFM.SelAvail then
    ReplaceDialog1.FindText := seDFM.SelText
  else
    ReplaceDialog1.FindText := seDFM.WordAtCursor;
  ReplaceDialog1.Execute;
end;

procedure TdlgEditDFM.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if seDFM.Modified then
  begin
    if Messagedlg('Хотите выйти без сохранения?',
    mtConfirmation, [mbYes, mbNo], 0)  <> mrYes then
      CanClose := False;
  end;
end;

procedure TdlgEditDFM.btnOkClick(Sender: TObject);
begin
  seDFM.Modified := False; 
end;

end.
