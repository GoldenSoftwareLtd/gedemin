unit gsSearchReplaceHelper;

interface

uses
  dialogs, SynEdit;

type
  TgsSearchReplaceHelper = class
  private
    FFindDialog: TFindDialog;
    FReplaceDialog: TReplaceDialog;
    FSynEdit: TCustomSynEdit;

  protected
    procedure DoOnSearch(Sender: TObject);
    procedure DoOnReplace(Sender: TObject);

    procedure DoSearchReplace(const ASearchStr, AReplaceStr: String; AOptions: TSynSearchOptions);
  public
    constructor Create(ASynEdit: TCustomSynEdit);
    destructor Destroy; override;

    procedure Search;
    procedure Replace;
    procedure SearchNext;
  end;

implementation

uses
  Windows, Sysutils, prp_MessageConst;

var
  FSearchText: String;

{ TgsSearchReplaceHelper }

constructor TgsSearchReplaceHelper.Create(ASynEdit: TCustomSynEdit);
begin
  // Компонент ввода, по которому ведется поиск
  FSynEdit := ASynEdit;
  // Диалог поиска строки
  FFindDialog := TFindDialog.Create(nil);
  FFindDialog.OnFind := DoOnSearch;
  // Диалог поиска и замены строки
  FReplaceDialog := TReplaceDialog.Create(nil);
  FReplaceDialog.OnFind := DoOnSearch;
  FReplaceDialog.OnReplace := DoOnReplace;
end;

destructor TgsSearchReplaceHelper.Destroy;
begin
  inherited;
  FreeAndNil(FFindDialog);
  FreeAndNil(FReplaceDialog);
end;

procedure TgsSearchReplaceHelper.DoSearchReplace(const ASearchStr, AReplaceStr: String;
  AOptions: TSynSearchOptions);
begin
  if Length(ASearchStr) = 0 then
  begin
    Beep;
    MessageBox(FSynEdit.Handle, MSG_FIND_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end
  else
  begin
    if FSynEdit.SearchReplace(ASearchStr, AReplaceStr, AOptions) = 0 then
    begin
      Beep;
      MessageBox(FSynEdit.Handle, PChar(MSG_SEACHING_TEXT + ASearchStr + MSG_NOT_FIND), MSG_WARNING,
       MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    end;
  end;
end;

procedure TgsSearchReplaceHelper.DoOnSearch(Sender: TObject);
var
  SearchOptions: TSynSearchOptions;
begin
  SearchOptions := [];
  // Вперед\назад по тексту
  if not (frDown in TFindDialog(Sender).Options) then
    Include(SearchOptions, ssoBackwards);
  // С учетом регистра
  if frMatchCase in TFindDialog(Sender).Options then
    Include(SearchOptions, ssoMatchCase);
  // Слово целиком
  if frWholeWord in TFindDialog(Sender).Options then
    Include(SearchOptions, ssoWholeWord);

  DoSearchReplace(FFindDialog.FindText, '', SearchOptions);

  FSearchText := FFindDialog.FindText;
end;

procedure TgsSearchReplaceHelper.DoOnReplace(Sender: TObject);
var
  SearchOptions: TSynSearchOptions;
begin
  // Замена строки
  if frReplaceAll in TReplaceDialog(Sender).Options then
    SearchOptions := [ssoReplaceAll, ssoEntireScope]
  else
    SearchOptions := [ssoReplace, ssoPrompt];
  // Вперед\назад по тексту
  if not (frDown in TReplaceDialog(Sender).Options) then
    Include(SearchOptions, ssoBackwards);
  // С учетом регистра
  if frMatchCase in TReplaceDialog(Sender).Options then
    Include(SearchOptions, ssoMatchCase);
  // Слово целиком
  if frWholeWord in TReplaceDialog(Sender).Options then
    Include(SearchOptions, ssoWholeWord);
  // Заменять только в выбранном тексте
  if FSynEdit.SelAvail then
    Include(SearchOptions, ssoSelectedOnly);

  DoSearchReplace(FReplaceDialog.FindText, FReplaceDialog.ReplaceText, SearchOptions);

  FSearchText := FFindDialog.FindText;
end;

procedure TgsSearchReplaceHelper.Search;
begin
  if FSearchText > '' then
    FFindDialog.FindText := FSearchText
  else if FSynEdit.SelAvail then
    FFindDialog.FindText := FSynEdit.SelText
  else
    FFindDialog.FindText := FSynEdit.WordAtCursor;
  FFindDialog.Execute;
end;

procedure TgsSearchReplaceHelper.SearchNext;
begin
  if Length(FFindDialog.FindText) > 0 then
    DoOnSearch(FFindDialog)
  else
    Search;
end;

procedure TgsSearchReplaceHelper.Replace;
begin
  if FSynEdit.SelAvail then
    FReplaceDialog.FindText := FSynEdit.SelText
  else
    FReplaceDialog.FindText := FSynEdit.WordAtCursor;
  FReplaceDialog.Execute;
end;

initialization
  FSearchText := '';
end.
