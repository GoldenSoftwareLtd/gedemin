unit at_ActivateSetting_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_messages_const;

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
  IBDatabase, at_classes, gdcSetting, gdcBaseInterface, gd_security;

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
var
  Tr: TIBTransaction;
begin
  Assert(gdcBaseManager <> nil);
  _ActivateSetting(FSettingKeys, false, Boolean(Msg.LParam), Msg.WParamLo, Msg.WParamHi);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    atDatabase.SyncIndicesAndTriggers(Tr);
    IBLogin.Relogin; //atDatabase.ForceLoadFromDatabase;
  finally
    Tr.Free;
  end;
  Close;
end;

procedure TActivateSetting.WMDeActivateSetting(var Msg: TMessage);
var
  Tr: TIBTransaction;
begin
  Assert(gdcBaseManager <> nil);
  _DeActivateSetting(FSettingKeys, Boolean(Msg.LParam));
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    atDatabase.SyncIndicesAndTriggers(Tr);
    IBLogin.Relogin; //atDatabase.ForceLoadFromDatabase;
  finally
    Tr.Free;
  end;
  Close;
end;

end.
