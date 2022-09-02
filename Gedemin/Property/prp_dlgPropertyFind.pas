// ShlTanya, 25.02.2019

unit prp_dlgPropertyFind;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, StdActns, ActnList, SuperPageControl, Mask,
  xDateEdits;

CONST
  cStrSearchIdentifier = '\b[0-9]{9,}\b';

type
  TSOptions = record
    CaseSensitive: Boolean;
    WholeWord: Boolean;
  end;

  TSDirection = (sdForward, sdBackward);
  TSScope = (ssGlobal, ssSelectedText);
  TSOrigin = (soFromCursor, soEntireScope);

  TSearchInTextOptions = record
    Options: TSOptions;
    Direction: TSDirection;
    Scope: TSScope;
    Origin: TSOrigin;
  end;

  TSearchType = (stSearchText, stSearchInDB, stSearchIdentifier);

  TWhere = (wInText, wInCaption);
  TSWhere = set of TWhere;

  TInNameWhere = (nwMacro, nwReport, nwOther, nwEvent);
  TSInNameWhere = set of TInNameWhere;

  TSearchInDbOptions = record
    Options: TSOptions;
    Where: TSWhere;
    InNameWhere: TSInNameWhere;
    ByID: Boolean;
    CurrentObject: Boolean;
    Date: Boolean;
    BeginDate: TDateTime;
    EndDate: TDateTime;
    UseRegExp: Boolean;
    SkipComments: Boolean;
    NotLimitResults: Boolean;
  end;

  //Опции поиска
  TSearchOptions = record
    //Искомый текст
    SearchText: string;
    //Список ранее искомых текстов
    SearchTextList: string;
    SearchIdentifier: boolean;
    WithReplace: boolean;
    ReplaceText: string;
    ReplaceTextList: string;
    SearchInText: TSearchInTextOptions;
    SearchInDb: TSearchInDbOptions;
  end;

type
  TdlgPropertyFind = class(TForm)
    PC: TPageControl;
    tsFind: TTabSheet;
    tsFindInDB: TTabSheet;
    Panel1: TPanel;
    btnFind: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    cbText: TComboBox;
    gbOptions: TGroupBox;
    rgDirection: TRadioGroup;
    rgScope: TRadioGroup;
    rgOrigin: TRadioGroup;
    cbCaseSensitive: TCheckBox;
    cbWholeWord: TCheckBox;
    Label2: TLabel;
    cbTextDB: TComboBox;
    gbOptionsDB: TGroupBox;
    cbCaseSensitiveDB: TCheckBox;
    cbWholeWordDB: TCheckBox;
    ActionList1: TActionList;
    WindowClose: TWindowClose;
    cbByID_DB: TCheckBox;
    gbScopeDB: TGroupBox;
    cbInTextDB: TCheckBox;
    cbInCaptionDB: TCheckBox;
    actChangePage: TAction;
    Panel2: TPanel;
    cbInMacroName: TCheckBox;
    cbInReportName: TCheckBox;
    cbInOtherName: TCheckBox;
    cbCurrentObject: TCheckBox;
    cbDate: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    xdeBeginDate: TxDateEdit;
    xdeEndDate: TxDateEdit;
    Button1: TButton;
    actHelp: TAction;
    cbInEventName: TCheckBox;
    cbReplaceText: TComboBox;
    cbWithReplace: TCheckBox;
    cbUseRegExpDB: TCheckBox;
    cbSkipCommentsDB: TCheckBox;
    tsFindIdentifier: TTabSheet;
    mPeriodHelp: TMemo;
    cbNotLimitResults: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbTextDropDown(Sender: TObject);
    procedure cbTextChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnFindClick(Sender: TObject);
    procedure PCChange(Sender: TObject);
    procedure UpdateOptions;
    procedure UpdateControls;
    procedure WindowCloseExecute(Sender: TObject);
    procedure cbByID_DBClick(Sender: TObject);
    procedure actChangePageExecute(Sender: TObject);
    procedure cbInCaptionDBClick(Sender: TObject);
    procedure tsFindInDBShow(Sender: TObject);
    procedure tsFindShow(Sender: TObject);
    procedure cbDateClick(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure cbWithReplaceClick(Sender: TObject);
    procedure cbReplaceTextDropDown(Sender: TObject);
    procedure cbReplaceTextChange(Sender: TObject);
    procedure cbUseRegExpDBClick(Sender: TObject);

  private
    FHistorySearch: TStrings;
    FHistoryReplace: TStrings;
    FSearchType: TSearchType;
    procedure SetSearchType(const Value: TSearchType);
    procedure SetCBEnable;
    procedure SetInNameEnable;

  public
    property SearchType: TSearchType read FSearchType write SetSearchType;
  end;

var
  dlgPropertyFind: TdlgPropertyFind;
  SearchOptions: TSearchOptions;

procedure SaveSearchOptions(SO: TSearchOptions);
function LoadSearchOptions: TSearchOptions;
function LoadDefault: TSearchOptions;

implementation

uses
  Storages, gsStorage, gdcBaseInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}
const
  sPropertyGeneralPath = 'Options\PropertySettings\SearchOptions';
const
  cSearchText = 'SearchText';
  cSearchTextList = 'SearchTextList';
  cSearchInText = 'SearchInText';
  cSearchInDb = 'SearchInDb';
  cReplaceText = 'ReplaceText';
  cReplaceTextList = 'ReplaceTextList';


procedure SaveSearchOptions(SO: TSearchOptions);
var
  F: TgsStorageFolder;
  S: TMemoryStream;
begin
  if not Assigned(UserStorage) then
    Exit;

  F := UserStorage.OpenFolder(sPropertyGeneralPath, True);
  try
    with SO do
    begin
      F.WriteString(cSearchText, SearchText);
      F.WriteString(cSearchTextList, SearchTextList);
      F.WriteString(cReplaceText, ReplaceText);
      F.WriteString(cReplaceTextList, ReplaceTextList);
      S := TMemoryStream.Create;
      try
        S.WriteBuffer(SearchInText, SizeOf(SearchInText));
        F.WriteStream(cSearchInText, S);
        S.Size := 0;
        S.WriteBuffer(SearchInDb, SizeOf(SearchInDb));
        F.WriteStream(cSearchInDb, S);
      finally
        S.Free;
      end;
    end;
  finally
    UserStorage.CloseFolder(F);
  end;
end;

function LoadSearchOptions: TSearchOptions;
var
  F: TgsStorageFolder;
  S: TMemoryStream;
begin
  Result := LoadDefault;

  if not Assigned(UserStorage) then
    exit;

  if UserStorage.FolderExists(sPropertyGeneralPath) then
  begin
    try
      F := UserStorage.OpenFolder(sPropertyGeneralPath, True);
      try
        with Result do
        begin
          SearchText := F.ReadString(cSearchText, '');
          SearchTextList := F.ReadString(cSearchTextList, '');
          ReplaceText := F.ReadString(cReplaceText, '');
          ReplaceTextList := F.ReadString(cReplaceTextList, '');
          S := TMemoryStream.Create;
          try
            F.ReadStream(cSearchInText, S);
            S.ReadBuffer(SearchInText, SizeOf(SearchInText));
            S.Size := 0;
            F.ReadStream(cSearchInDb, S);
            S.ReadBuffer(SearchInDb, SizeOf(SearchInDb));
          finally
            S.Free;
          end;

          if (SearchInDb.BeginDate < 0) or (SearchInDb.BeginDate > EncodeDate(3000, 01, 01)) then
          begin
            SearchInDb.Date := False;
            SearchInDb.Begindate := Date;
          end;

          if (SearchInDb.EndDate < SearchInDb.BeginDate) or (SearchInDb.EndDate > EncodeDate(3000, 01, 01)) then
          begin
            SearchInDb.Date := False;
            SearchInDb.EndDate := SearchInDb.BeginDate;
          end;
          SearchInDb.NotLimitResults := False; // по умолчанию ограничиваем результаты
        end;
      finally
        UserStorage.CloseFolder(F);
      end;
    except
      Result := LoadDefault;
    end;
  end;
end;

function LoadDefault: TSearchOptions;
begin
  with Result do
  begin
    SearchText := '';
    SearchTextList := '';
    SearchInText.Options.CaseSensitive := False;
    SearchInText.Options.WholeWord := False;
    SearchInText.Direction := sdForward;
    SearchInText.Scope := ssGlobal;
    SearchInText.Origin := soEntireScope;
    SearchInDb.Options.CaseSensitive := False;
    SearchInDb.Options.WholeWord := False;
    SearchInDb.Where := [wInText];
    SearchInDb.ByID := False;
    SearchInDb.InNameWhere := [nwMacro, nwReport, nwOther, nwEvent];
    SearchInDb.CurrentObject := False;
    SearchInDb.Date := False;
    SearchInDb.Begindate := Date;
    SearchInDb.Enddate := Date;
    SearchInDb.SkipComments := False;
    SearchInDb.UseRegExp := False;
    SearchInDb.NotLimitResults := False;
    WithReplace := False;
    ReplaceText := '';
    ReplaceTextList := '';
    SearchIdentifier := False;
  end;
end;

procedure TdlgPropertyFind.FormCreate(Sender: TObject);
begin
  if dlgPropertyFind <> nil then
    Exception.Create('Error');
  inherited;

  dlgPropertyFind := Self;

  FHistorySearch := TStringList.Create;
  FHistoryReplace := TStringList.Create;

  SearchOptions := LoadSearchOptions;

  FHistorySearch.Text := SearchOptions.SearchTextList;
  FHistoryReplace.Text := SearchOptions.ReplaceTextList;
  cbTextDropDown(cbText);
  cbTextDropDown(cbTextDB);
  SearchOptions.WithReplace := False;
end;

procedure TdlgPropertyFind.FormDestroy(Sender: TObject);
begin
  dlgPropertyFind := nil;
  if SearchType <> stSearchIdentifier then
  begin
    SearchOptions.SearchTextList := FHistorySearch.Text;
    SearchOptions.ReplaceTextList := FHistoryReplace.Text;
    SaveSearchOptions(SearchOptions);
  end;
  FHistorySearch.Free;
  FHistoryReplace.Free;
  inherited;
end;

procedure TdlgPropertyFind.cbTextDropDown(Sender: TObject);
begin
  with TComboBox(Sender) do
  begin
    Items.Clear;
    Items.Assign(FHistorySearch);
    ItemIndex := Items.IndexOf(Text);
  end;
end;

procedure TdlgPropertyFind.cbTextChange(Sender: TObject);
begin
  with TComboBox(Sender) do
    SearchOptions.SearchText := Text;
end;

procedure TdlgPropertyFind.FormShow(Sender: TObject);
begin
  cbText.Text := SearchOptions.SearchText;
  cbTextDB.Text := SearchOptions.SearchText;

  cbText.ItemIndex := -1;
  cbTextDB.ItemIndex := -1;
  if PC.ActivePage = tsFind then
  begin
    cbText.SelectAll;
    cbText.SetFocus;
  end else
    if PC.ActivePage = tsFindInDB then
    begin
      cbTextDb.SelectAll;
      cbTextDB.SetFocus;
    end;
end;

procedure TdlgPropertyFind.btnFindClick(Sender: TObject);
var
  Index: Integer;
begin
  if SearchType = stSearchIdentifier then
  begin
    ModalResult := mrOk;
  end
  else
  begin
    if (SearchOptions.SearchText = '') and
      not ((PC.ActivePage = tsFindInDb) and cbDate.Checked) then
    begin
      MessageBox(Handle,
        'Введите текст для поиска!',
        'Ошибка',
        MB_ICONERROR or MB_OK or MB_TASKMODAL);
    end else
    begin
      Index := FHistorySearch.IndexOf(SearchOptions.SearchText);

      if Index = -1 then
        FHistorySearch.Insert(0, SearchOptions.SearchText)
      else
        FHistorySearch.Move(Index, 0);

      while FHistorySearch.Count > 20 do
        FHistorySearch.Delete(FHistorySearch.Count - 1);

      if (PC.ActivePage = tsFindInDb) and cbWithReplace.Checked and
         (SearchOptions.ReplaceText <> '') then
      begin
        Index := FHistoryReplace.IndexOf(SearchOptions.ReplaceText);

        if Index = -1 then
          FHistoryReplace.Insert(0, SearchOptions.ReplaceText)
        else
          FHistoryReplace.Move(Index, 0);

        while FHistoryReplace.Count > 20 do
          FHistoryReplace.Delete(FHistoryReplace.Count - 1);
      end;

      UpdateOptions;
      SearchOptions.SearchTextList := FHistorySearch.Text;
      SearchOptions.ReplaceTextList := FHistoryReplace.Text;
      SaveSearchOptions(SearchOptions);

      if (PC.ActivePage = tsFindInDb) and cbByID_DB.Checked then
      begin
        if Pos('_', cbTextDB.Text) = 0 then
        begin
          Index := GetTID(cbTextDB.Text, -1);

          if Index >= 0 then
          begin
            ModalResult := mrOk;
            cbTextDB.Text := TID2S(Index);
          end else
          begin
            MessageBox(Handle,
              'Для поиска по ИД необходимо ввести целое положительное число.',
              'Ошибка',
              MB_OK or MB_ICONERROR or MB_TASKMODAL);
            cbTextDB.SetFocus;
          end;
        end else
        begin
          gdcBaseManager.GetIDByRUIDString(cbTextDB.Text);
          ModalResult := mrOk;
        end;
      end else
        ModalResult := mrOk;
    end;
  end;
end;

procedure TdlgPropertyFind.SetSearchType(const Value: TSearchType);
begin
  FSearchType := Value;
  case Value of
  stSearchInDB:
    begin
      tsFind.TabVisible := False;
      tsFindInDB.TabVisible := True;
      tsFindIdentifier.TabVisible := False;
      PC.ActivePage := tsFindInDB;
      ActiveControl := cbTextDb;
    end;
  stSearchText:
    begin
      tsFind.TabVisible := True;
      tsFindInDB.TabVisible := False;
      tsFindIdentifier.TabVisible := False;
      PC.ActivePage := tsFind;
      ActiveControl := cbText;
    end;
  stSearchIdentifier:
    begin
      SearchOptions := LoadDefault;
      with SearchOptions do
      begin
        SearchInDb.UseRegExp := True;
        SearchInDb.InNameWhere := [];
        SearchInDb.SkipComments := True;
        SearchText := cStrSearchIdentifier;
        WithReplace := True;
        SearchIdentifier := True;
      end;
      tsFind.TabVisible := False;
      tsFindInDB.TabVisible := False;
      tsFindIdentifier.TabVisible := True;
      PC.ActivePage := tsFindIdentifier;
    end;
  end;

  if Value in [stSearchInDB, stSearchText] then
  begin
    SearchOptions := LoadSearchOptions;

    cbText.Text := SearchOptions.SearchText;
    cbTextDB.Text := SearchOptions.SearchText;

    UpdateControls;

    SetCBEnable;
  end;
end;

procedure TdlgPropertyFind.PCChange(Sender: TObject);
begin
  cbText.Text := SearchOptions.SearchText;
  cbTextDB.Text := SearchOptions.SearchText;
  cbText.SelectAll;
  cbTextDB.SelectAll;
end;

procedure TdlgPropertyFind.UpdateOptions;
begin
  with SearchOptions do
  begin
    SearchInText.Options.CaseSensitive := cbCaseSensitive.Checked;
    SearchInText.Options.WholeWord := cbWholeWord.Checked;
    SearchInText.Direction := TSDirection(rgDirection.ItemIndex);
    SearchInText.Scope := TSScope(rgScope.ItemIndex);
    SearchInText.Origin := TSOrigin(rgOrigin.ItemIndex);

    SearchInDb.Options.CaseSensitive := cbCaseSensitiveDB.Checked;
    SearchInDb.Options.WholeWord := cbWholeWordDB.Checked and cbWholeWordDB.Enabled;
    SearchInDb.UseRegExp := cbUseRegExpDB.Checked;
    SearchInDb.SkipComments := cbSkipCommentsDB.Checked;
    SearchInDb.CurrentObject := cbCurrentObject.Checked;
    SearchInDb.Where := [];
    if cbInTextDB.Checked  and cbInTextDB.Enabled then
      Include(SearchInDb.Where, wInText);
    if cbInCaptionDB.Checked and cbInCaptionDB.Enabled then
      Include(SearchInDb.Where, wInCaption);
    SearchInDb.ByID := cbByID_DB.Checked;
    SearchInDb.Date := cbDate.Checked;
    SearchInDb.BeginDate := xdeBeginDate.Date;
    SearchInDb.Enddate := xdeEndDate.Date;
    SearchInDb.NotLimitResults := cbNotLimitResults.Checked; 

    SearchInDb.InNameWhere := [];
    if cbInMacroName.Checked and cbInMacroName.Enabled then
      Include(SearchInDb.InNameWhere, nwMacro);
    if cbInReportName.Checked and cbInReportName.Enabled then
      Include(SearchInDb.InNameWhere, nwReport);
    if cbInOtherName.Checked and cbInOtherName.Enabled then
      Include(SearchInDb.InNameWhere, nwOther);
    if cbInEventName.Checked and cbInEventName.Enabled then
      Include(SearchInDb.InNameWhere, nwEvent);

    WithReplace := cbWithReplace.Checked;
  end;
end;

procedure TdlgPropertyFind.WindowCloseExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgPropertyFind.UpdateControls;
begin
  with SearchOptions do
  begin
    cbCaseSensitive.Checked := SearchInText.Options.CaseSensitive;
    cbWholeWord.Checked := SearchInText.Options.WholeWord;
    rgDirection.ItemIndex := Integer(SearchInText.Direction);
    rgScope.ItemIndex := Integer(SearchInText.Scope);
    rgOrigin.ItemIndex := Integer(SearchInText.Origin);

    cbCaseSensitiveDB.Checked := SearchInDb.Options.CaseSensitive;
    cbWholeWordDB.Checked := SearchInDb.Options.WholeWord;
    cbUseRegExpDB.Checked := SearchInDb.UseRegExp;
    cbSkipCommentsDB.Checked := SearchInDb.SkipComments;
    cbInTextDB.Checked := (wInText in SearchInDb.Where);
    cbInCaptionDB.Checked := (wInCaption in SearchInDb.Where);
    cbCurrentObject.Checked := SearchInDb.CurrentObject;
    cbByID_DB.Checked := SearchInDb.ByID;

    cbDate.Checked := SearchInDb.Date;
    xdeBeginDate.Date := SearchInDb.BeginDate;
    xdeEndDate.Date := SearchInDb.EndDate;

    cbInMacroName.Checked := (nwMacro in SearchInDb.InNameWhere);
    cbInReportName.Checked := (nwReport in SearchInDb.InNameWhere);
    cbInOtherName.Checked := (nwOther in SearchInDb.InNameWhere);
    cbInEventName.Checked := (nwEvent in SearchInDb.InNameWhere);

    cbWithReplace.Checked := WithReplace;
  end;
end;

procedure TdlgPropertyFind.cbByID_DBClick(Sender: TObject);
begin
  inherited;
  SetCBEnable;
end;


procedure TdlgPropertyFind.SetCBEnable;
begin
  cbCaseSensitiveDB.Enabled := not cbByID_DB.Checked;
  cbWholeWordDB.Enabled := (not cbByID_DB.Checked) and (not cbUseRegExpDB.Checked);
  cbUseRegExpDB.Enabled := not cbByID_DB.Checked;
  cbSkipCommentsDB.Enabled := not cbByID_DB.Checked;
  cbInTextDB.Enabled := not cbByID_DB.Checked;
  cbInCaptionDB.Enabled := (not cbByID_DB.Checked) and (not cbWithReplace.Checked);
  cbCurrentObject.Enabled := not cbByID_DB.Checked;
  cbDate.Enabled := not cbByID_DB.Checked;
  cbReplaceText.Enabled := cbWithReplace.Checked;
  cbDateClick(nil);
  SetInNameEnable;
end;

procedure TdlgPropertyFind.actChangePageExecute(Sender: TObject);
begin
  PC.ActivePageIndex := (PC.ActivePageIndex + 1) MOD PC.PageCount;
end;

procedure TdlgPropertyFind.cbInCaptionDBClick(Sender: TObject);
begin
  SetInNameEnable;
end;

procedure TdlgPropertyFind.SetInNameEnable;
var
  B: Boolean;
begin
  B := cbInCaptionDB.Checked and cbInCaptionDb.Enabled;
  cbInMacroName.Enabled := B;
  cbInReportName.Enabled := B;
  cbInEventName.Enabled := B;
  cbInOtherName.Enabled := B;
end;

procedure TdlgPropertyFind.tsFindInDBShow(Sender: TObject);
begin
  cbTextDB.SetFocus;
end;

procedure TdlgPropertyFind.tsFindShow(Sender: TObject);
begin
  cbText.SetFocus;
end;

procedure TdlgPropertyFind.cbDateClick(Sender: TObject);
begin
  xdeBeginDate.Enabled := cbDate.Checked and cbDate.Enabled;
  xdeEndDate.Enabled := cbDate.Checked and cbDate.Enabled;
end;

procedure TdlgPropertyFind.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TdlgPropertyFind.FormActivate(Sender: TObject);
begin
  cbText.ItemIndex := -1;
  cbTextDB.ItemIndex := -1;
end;

procedure TdlgPropertyFind.cbWithReplaceClick(Sender: TObject);
begin
  SetCBEnable;
end;

procedure TdlgPropertyFind.cbReplaceTextDropDown(Sender: TObject);
begin
  with TComboBox(Sender) do
  begin
    Items.Clear;
    Items.Assign(FHistoryReplace);
    ItemIndex := Items.IndexOf(Text);
  end;
end;

procedure TdlgPropertyFind.cbReplaceTextChange(Sender: TObject);
begin
  with TComboBox(Sender) do
    SearchOptions.ReplaceText := Text;
end;

procedure TdlgPropertyFind.cbUseRegExpDBClick(Sender: TObject);
begin
  SetCBEnable;
end;

initialization
  SearchOptions := LoadDefault;
end.
