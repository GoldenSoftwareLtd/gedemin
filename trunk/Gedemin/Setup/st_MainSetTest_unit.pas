unit st_MainSetTest_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  st_IniStorage, StdCtrls, ExtCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ListView1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListView1Resize(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  protected
    FIniSettingsStorage: TIniSettingsStorage;

    procedure ShowSettings;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses st_dlgSelectSettings_unit;

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FIniSettingsStorage := TIniSettingsStorage.Create;
  FIniSettingsStorage.IniName := ExtractFilePath(Application.ExeName) + 'SETTING.INI';
  FIniSettingsStorage.ReadFromIni;
  ShowSettings;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
//  FIniSettingsStorage.WriteToIni;
  FIniSettingsStorage.Free;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  if FIniSettingsStorage.AddSetting then
    ShowSettings;
end;

procedure TMainForm.ListView1Resize(Sender: TObject);
begin
  ListView1.Column[1].Width := ListView1.Width - 20 - ListView1.Column[0].Width;
end;

procedure TMainForm.ShowSettings;
var
  I: Integer;
  LI: TListItem;
begin
  ListView1.Items.Clear;
  for I := 0 to FIniSettingsStorage.Count - 1 do
  begin
    LI := ListView1.Items.Add;
    LI.Caption := FIniSettingsStorage.Setting[I].RUID;
    LI.SubItems.Add(FIniSettingsStorage.Setting[I].Title);
    LI.Data := Pointer(I);
  end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  if not Assigned(ListView1.Selected) then
    Exit;
  if FIniSettingsStorage.EditSetting(Integer(ListView1.Selected.Data)) then
    ShowSettings;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  if not Assigned(ListView1.Selected) then
    Exit;
  if MessageBox(Handle, 'Вы действительно хотите удалить эту настройку?',
   'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    FIniSettingsStorage.DeleteSetting(Integer(ListView1.Selected.Data));
    ShowSettings;
  end;
end;

end.
