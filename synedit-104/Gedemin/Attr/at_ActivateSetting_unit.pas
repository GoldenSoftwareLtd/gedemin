unit at_ActivateSetting_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  WM_ACTIVATESETTING = WM_USER + 30000;
  WM_DEACTIVATESETTING = WM_USER + 30001;

type
  TActivateSetting = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    FSettingKeys: String;

    procedure WMActivateSetting(var Msg: TMessage); message WM_ActivateSetting;
    procedure WMDeActivateSetting(var Msg: TMessage); message WM_DeActivateSetting;    

  public
    constructor Create(AnOwner: TComponent); override;

    property SettingKeys: String read FSettingKeys write FSettingKeys;
  end;

var
  ActivateSetting: TActivateSetting;

implementation

uses
  gdcSetting;

{$R *.DFM}

constructor TActivateSetting.Create(AnOwner: TComponent);
begin
  inherited;
  FSettingKeys := '';
end;

procedure TActivateSetting.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TActivateSetting.WMActivateSetting(var Msg: TMessage);
begin
  _ActivateSetting(FSettingKeys, false, Boolean(Msg.LParam), Msg.WParamLo, Msg.WParamHi);
  Close;
end;

procedure TActivateSetting.WMDeActivateSetting(var Msg: TMessage);
begin
  _DeActivateSetting(FSettingKeys, Boolean(Msg.LParam));
  Close;
end;

end.
