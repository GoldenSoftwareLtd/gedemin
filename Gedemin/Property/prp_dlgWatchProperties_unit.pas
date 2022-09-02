// ShlTanya, 25.02.2019

unit prp_dlgWatchProperties_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, XPBevel, prp_WatchList;

type
  TdlgWatchProperties = class(TForm)
    lExpression: TLabel;
    cbName: TComboBox;
    Button1: TButton;
    Button2: TButton;
    cbEnabled: TCheckBox;
    cbAllowFunctionCall: TCheckBox;
    XPBevel1: TXPBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FWatch: TWatch;
    procedure SetWatch(const Value: TWatch);
    function GetWatch: TWatch;
  public
    { Public declarations }
    property Watch: TWatch read GetWatch write SetWatch;
  end;

var
  dlgWatchProperties: TdlgWatchProperties;

implementation
uses Storages;
const
  cWatchHistory = 'WatchHistory';
{$R *.DFM}

procedure TdlgWatchProperties.FormCreate(Sender: TObject);
begin
  FWatch := TWatch.Create;
  if UserStorage <> nil then
    cbName.Items.Text := UserStorage.ReadString(sWatchPropertiesPath, cWatchHistory, '');;
end;

procedure TdlgWatchProperties.FormDestroy(Sender: TObject);
begin
  if UserStorage <> nil then
    UserStorage.WriteString(sWatchPropertiesPath, cWatchHistory,
      cbName.Items.Text);

  FWatch.Free;
end;

procedure TdlgWatchProperties.Button2Click(Sender: TObject);
begin
  if cbName.Items.IndexOf(Trim(cbName.Text)) = - 1 then
  begin
    cbName.Items.Insert(0, Trim(cbName.Text));
    while cbName.Items.Count > 30 do
       cbName.Items.Delete(cbName.Items.Count - 1);
  end;
end;

procedure TdlgWatchProperties.SetWatch(const Value: TWatch);
begin
  with Value do
  begin
    cbName.Text := Name;
    cbEnabled.Checked := Enabled;
    cbAllowFunctionCall.Checked := AllowFunctionCall;
  end;
end;

function TdlgWatchProperties.GetWatch: TWatch;
begin
  with FWatch do
  begin
    Name := cbName.Text;
    Enabled := cbEnabled.Checked;
    AllowFunctionCall := cbAllowFunctionCall.Checked;
  end;
  Result := FWatch;
end;

end.
