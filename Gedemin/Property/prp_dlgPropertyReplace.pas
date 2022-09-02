// ShlTanya, 25.02.2019

unit prp_dlgPropertyReplace;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, StdActns, prp_dlgPropertyFind;
type
  TReplaceInText = record
    Options: TSOptions;
    Promt: Boolean;
    Direction: TSDirection;
    Scope: TSScope;
    Origin: TSOrigin;
  end;

  TReplaceOptions = record
    //Искомый текст
    SearchText: string;
    ReplaceText: string;
    //Список ранее искомых текстов
    SearchTextList: string;
    ReplaceTextList: string;
    ReplaceInText: TReplaceInText;
    ReplaceAll: Boolean;
  end;

type
  TdlgPropertyReplace = class(TForm)
    Label1: TLabel;
    cbSeachText: TComboBox;
    gbOptions: TGroupBox;
    cbCaseSensitive: TCheckBox;
    cbWholeWord: TCheckBox;
    rgDirection: TRadioGroup;
    rgScope: TRadioGroup;
    rgOrigin: TRadioGroup;
    btnOk: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    cbReplaceText: TComboBox;
    cbPromt: TCheckBox;
    ActionList: TActionList;
    WindowClose: TWindowClose;
    btnReplaceAll: TButton;
    btnHelp: TButton;
    actHelp: TAction;
    procedure WindowCloseExecute(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbSeachTextChange(Sender: TObject);
    procedure cbSeachTextDropDown(Sender: TObject);
    procedure cbReplaceTextChange(Sender: TObject);
    procedure cbReplaceTextDropDown(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FHistorySearch: TStrings;
    FHistoryReplace: TStrings;
    procedure UpdateOptions;
    procedure UpdateControls;
  public
    { Public declarations }
  end;

var
  dlgPropertyReplace: TdlgPropertyReplace;
  ReplaceOptions: TReplaceOptions;
  
procedure SaveReplaceOptions(RO: TReplaceOptions);
function LoadReplaceOptions: TReplaceOptions;
function LoadReplaceDefault: TReplaceOptions;

implementation

uses
  Storages, gsStorage
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  sPropertyGeneralPath = 'Options\PropertySettings\ReplaceOptions';
const
  cSearchText = 'SearchText';
  cSearchTextList = 'SearchTextList';
  cReplaceText = 'ReplaceText';
  cReplaceTextList = 'ReplaceTextList';
  cReplaceInText = 'ReplaceInText';
{$R *.DFM}

procedure TdlgPropertyReplace.WindowCloseExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgPropertyReplace.btnOkClick(Sender: TObject);
var
  Index: Integer;

begin
  ReplaceOptions.SearchText := cbSeachText.Text;
  ReplaceOptions.ReplaceText := cbReplaceText.Text;
  if ReplaceOptions.SearchText = '' then
  begin
    MessageBox(Application.Handle, 'Текст для поиска не может быть пустым.',
      'Ошибка', MB_ICONERROR or MB_OK or MB_TASKMODAL);
    Exit;
  end;

  Index := FHistorySearch.IndexOf(ReplaceOptions.SearchText);
  if Index = - 1 then
    FHistorySearch.Insert(0, ReplaceOptions.SearchText)
  else
    FHistorySearch.Move(Index, 0);

  Index := FHistoryReplace.IndexOf(ReplaceOptions.ReplaceText);
  if Index = - 1 then
    FHistoryReplace.Insert(0, ReplaceOptions.ReplaceText)
  else
    FHistoryReplace.Move(Index, 0);

  UpdateOptions;
  ReplaceOptions.SearchTextList := FHistorySearch.Text;
  ReplaceOptions.ReplaceTextList := FHistoryReplace.Text;
  SaveReplaceOptions(ReplaceOptions);
  ReplaceOptions.ReplaceAll := Sender <> btnOk;

  ModalResult := mrOk;
end;

procedure TdlgPropertyReplace.FormCreate(Sender: TObject);
begin
  if dlgPropertyReplace <> nil then
    Exception.Create('Error');
  inherited;

  ReplaceOptions := LoadReplaceOptions;
  FHistorySearch := TStringList.Create;
  FHistorySearch.Text := ReplaceOptions.SearchTextList;
  FHistoryReplace := TStringList.Create;
  FHistoryReplace.Text := ReplaceOptions.ReplaceTextList;
  UpdateControls;
  dlgPropertyReplace := Self;
end;

procedure TdlgPropertyReplace.FormDestroy(Sender: TObject);
begin
  dlgPropertyReplace := nil;
//  ReplaceOptions.SearchText := '';
  ReplaceOptions.SearchTextList := FHistorySearch.Text;
//  ReplaceOptions.ReplaceText := '';
  ReplaceOptions.ReplaceTextList := FHistoryReplace.Text;
  SaveReplaceOptions(ReplaceOptions);
  FHistorySearch.Free;
  FHistoryReplace.Free;
  inherited;
end;

procedure SaveReplaceOptions(RO: TReplaceOptions);
var
  F: TgsStorageFolder;
  S: TMemoryStream;
begin
  if not Assigned(UserStorage) then
    Exit;

  F := UserStorage.OpenFolder(sPropertyGeneralPath, True);
  try
    with RO do
    begin
      F.WriteString(cSearchText, SearchText);
      F.WriteString(cSearchTextList, SearchTextList);
      F.WriteString(cReplaceText, ReplaceText);
      F.WriteString(cReplaceTextList, ReplaceTextList);
      S := TMemoryStream.Create;
      try
        S.WriteBuffer(ReplaceInText, SizeOf(ReplaceInText));
        F.WriteStream(cReplaceInText, S);
      finally
        S.Free;
      end;
    end;
  finally
    UserStorage.CloseFolder(F);
  end;
end;

function LoadReplaceOptions: TReplaceOptions;
var
  F: TgsStorageFolder;
  S: TMemoryStream;
begin
  if not Assigned(UserStorage) then
    Exit;

  if not UserStorage.FolderExists(sPropertyGeneralPath) then
    Result := LoadReplaceDefault
  else
  begin
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
          F.ReadStream(cReplaceInText, S);
          S.ReadBuffer(ReplaceInText, SizeOf(ReplaceInText));
        finally
          S.Free;
        end;
      end;
    finally
      UserStorage.CloseFolder(F);
    end;
  end;
end;

function LoadReplaceDefault: TReplaceOptions;
begin
  with Result do
  begin
    SearchText := '';
    SearchTextList := '';
    ReplaceText := '';
    ReplaceTextList := '';
    ReplaceInText.Options.CaseSensitive := False;
    ReplaceInText.Options.WholeWord := False;
    ReplaceInText.Promt := True;
    ReplaceInText.Direction := sdForward;
    ReplaceInText.Scope := ssGlobal;
    ReplaceInText.Origin := soEntireScope;
  end;
end;

procedure TdlgPropertyReplace.UpdateOptions;
begin
  with ReplaceOptions do
  begin
    ReplaceInText.Options.CaseSensitive := cbCaseSensitive.Checked;
    ReplaceInText.Options.WholeWord := cbWholeWord.Checked;
    ReplaceInText.Promt := cbPromt.Checked;
    ReplaceInText.Direction := TSDirection(rgDirection.ItemIndex);
    ReplaceInText.Scope := TSScope(rgScope.ItemIndex);
    ReplaceInText.Origin := TSOrigin(rgOrigin.ItemIndex);
  end;
end;

procedure TdlgPropertyReplace.cbSeachTextChange(Sender: TObject);
begin
  with TComboBox(Sender) do
    ReplaceOptions.SearchText := Text;
end;

procedure TdlgPropertyReplace.cbSeachTextDropDown(Sender: TObject);
begin
  with TComboBox(Sender) do
  begin
    Items.Clear;
    Items.Assign(FHistorySearch);
    ItemIndex := Items.IndexOf(Text);
  end;
end;

procedure TdlgPropertyReplace.cbReplaceTextChange(Sender: TObject);
begin
  with TComboBox(Sender) do
    ReplaceOptions.ReplaceText := Text;
end;

procedure TdlgPropertyReplace.cbReplaceTextDropDown(Sender: TObject);
begin
  with TComboBox(Sender) do
  begin
    Items.Clear;
    Items.Assign(FHistoryReplace);
  end;
end;

procedure TdlgPropertyReplace.FormShow(Sender: TObject);
begin
  cbSeachTextDropDown(cbSeachText);
  cbReplaceTextDropDown(cbReplaceText);

  cbSeachText.Text := ReplaceOptions.SearchText;
  cbReplaceText.Text := ReplaceOptions.ReplaceText;
  if cbSeachText.Text <> '' then
    cbSeachText.SelectAll;
  cbSeachText.SetFocus;
end;

procedure TdlgPropertyReplace.UpdateControls;
begin
  with ReplaceOptions do
  begin
    cbCaseSensitive.Checked := ReplaceInText.Options.CaseSensitive;
    cbWholeWord.Checked := ReplaceInText.Options.WholeWord;
    cbPromt.Checked := ReplaceInText.Promt;
    rgDirection.ItemIndex := Integer(ReplaceInText.Direction);
    rgScope.ItemIndex := Integer(ReplaceInText.Scope);
    rgOrigin.ItemIndex := Integer(ReplaceInText.Origin);
  end;
end;

procedure TdlgPropertyReplace.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TdlgPropertyReplace.FormActivate(Sender: TObject);
begin
{  cbSeachText.ItemIndex := 0;
  cbReplaceText.ItemIndex := 0;}
end;

end.
