// ShlTanya, 27.02.2019

unit xfr_TemplateBuilder;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, SynEdit, TB2Item, ActnList, TB2Dock, TB2Toolbar;

type
  Txfr_dlgTemplateBuilder = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Panel2: TPanel;
    Memo: TSynEdit;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    ActionList: TActionList;
    actLoadFromFile: TAction;
    actSaveToFile: TAction;
    actFind: TAction;
    actReplace: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    FindDialog: TFindDialog;
    ReplaceDialog: TReplaceDialog;
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure ReplaceDialogReplace(Sender: TObject);
  private
  public
    function Execute(const AnStream: TStream): Boolean;
  end;

var
  xfr_dlgTemplateBuilder: Txfr_dlgTemplateBuilder;

implementation

uses
  prp_MessageConst
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

function Txfr_dlgTemplateBuilder.Execute(const AnStream: TStream): Boolean;
begin
  Memo.Lines.Clear;
  Memo.Lines.LoadFromStream(AnStream);
  Result := ShowModal = mrOk;
  if Result then
  begin
    AnStream.Position := 0;
    AnStream.Size := 0;
    Memo.Lines.SaveToStream(AnStream);
  end;
end;

procedure Txfr_dlgTemplateBuilder.actSaveToFileExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    Memo.Lines.SaveToFile(SaveDialog.FileName);
  end;
end;

procedure Txfr_dlgTemplateBuilder.actLoadFromFileExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    Memo.Lines.LoadFromFile(OpenDialog.FileName);
  end;
end;

procedure Txfr_dlgTemplateBuilder.actFindExecute(Sender: TObject);
begin
  FindDialog.FindText := Memo.WordAtCursor;
  FindDialog.Execute
end;

procedure Txfr_dlgTemplateBuilder.FindDialogFind(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
  F: TFindDialog;
begin
  F := TFindDialog(Sender);
  sSearch := F.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Application.Handle, MSG_REPLACE_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end else
  begin
    rOptions := [];

    if frMatchCase in F.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in F.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in F.Options then
      Include(rOptions, ssoReplaceAll);
    if Memo.SelAvail and not (frFindNext in F.Options) then
      Include(rOptions, ssoSelectedOnly);
    Memo.SearchReplace(sSearch, '', rOptions);
  end;
end;

procedure Txfr_dlgTemplateBuilder.actReplaceExecute(Sender: TObject);
begin
  ReplaceDialog.FindText := Memo.WordAtCursor;
  ReplaceDialog.Execute
end;

procedure Txfr_dlgTemplateBuilder.ReplaceDialogReplace(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch, sReplace: string;
  F: TFindDialog;
begin
  F := TFindDialog(Sender);
  sSearch := F.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Application.Handle, MSG_REPLACE_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end else
  begin
    rOptions := [ssoReplace];
    sReplace := ReplaceDialog.ReplaceText;

    if frMatchCase in F.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in F.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in F.Options then
      Include(rOptions, ssoReplaceAll);
    if Memo.SelAvail then
      Include(rOptions, ssoSelectedOnly);
    Memo.SearchReplace(sSearch, sReplace, rOptions);
  end;
end;

end.
