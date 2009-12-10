unit prp_dlgEventProperty_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Registry, gd_directories_const;

type
  TEventLogSettings = record
    UseEventLog: Boolean;
    ClearOnStart: Boolean;
    UnlimitSize: Boolean;
    EventSize: Integer;
  end;

type
  TdlgEventProperty = class(TForm)
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    bCancel: TButton;
    bOK: TButton;
    GroupBox1: TGroupBox;
    cbClearOnStart: TCheckBox;
    cbUnlimitSize: TCheckBox;
    eEventSize: TEdit;
    cbUseEventLog: TCheckBox;
    procedure cbUnlimitSizeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FSettings: TEventLogSettings;
    procedure SetSettings(const Value: TEventLogSettings);
    { Private declarations }
  public
    { Public declarations }
    property Settings: TEventLogSettings read FSettings write SetSettings;
  end;

function LoadSettings: TEventLogSettings;
procedure SaveSettings(Settings: TEventLogSettings);

var
  dlgEventProperty: TdlgEventProperty;

implementation

  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
uses
     gd_localization_stub
  ;
  {$ENDIF}

const
  cUseEventLog = 'UseEventLog';
  cClearOnStart = 'ClearOnStart';
  cUnlimitSize = 'UnlimitSize';
  cEventSize = 'EventSize';

function LoadSettings: TEventLogSettings;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := ClientRootRegistryKey;

    if Reg.OpenKeyReadOnly(ClientRootRegistrySubKey + 'EventLog') then
      try
        with Result do
        begin
          if Reg.ValueExists(cUseEventLog) then
            UseEventLog := Reg.ReadBool(cUseEventLog);
          if Reg.ValueExists(cClearOnStart) then
             ClearOnStart := Reg.ReadBool(cClearOnStart);
          if Reg.ValueExists(cUnlimitSize) then
             UnlimitSize := Reg.ReadBool(cUnlimitSize);
          if Reg.ValueExists(cEventSize) then
             EventSize := Reg.ReadInteger(cEventSize);
        end;
      finally
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure SaveSettings(Settings: TEventLogSettings);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := ClientRootRegistryKey;

    Reg.OpenKey(ClientRootRegistrySubKey + 'EventLog', True);
    try
      with Settings do
      begin
        Reg.WriteBool(cUseEventLog, UseEventLog);
        Reg.WriteBool(cClearOnStart, ClearOnStart);
        Reg.WriteBool(cUnlimitSize, UnlimitSize);
        Reg.WriteInteger(cEventSize, EventSize);
      end;
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

{$R *.DFM}

procedure TdlgEventProperty.cbUnlimitSizeClick(Sender: TObject);
begin
  eEventSize.Enabled := not cbUnlimitSize.Checked;
end;

procedure TdlgEventProperty.FormDestroy(Sender: TObject);
begin
  if ModalResult = mrOk then
    SaveSettings(Settings);
end;

procedure TdlgEventProperty.SetSettings(const Value: TEventLogSettings);
begin
  FSettings := Value;
  with FSettings do
  begin
    cbUseEventLog.Checked := UseEventLog;
    cbClearOnStart.Checked := ClearOnStart;
    cbUnlimitSize.Checked := UnlimitSize;
    eEventSize.Text := IntToStr(EventSize);
  end;
end;

procedure TdlgEventProperty.FormCreate(Sender: TObject);
begin
  Settings := LoadSettings;
end;

procedure TdlgEventProperty.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrCancel then
    CanClose := True
  else
  begin
    CanClose := False;
    with FSettings do
    begin
      try
        EventSize := StrToInt(eEventSize.Text);
      except
        MessageBox(Handle, 'Значение длинны списка должно содержать целое положительное число',
          PChar(Caption), MB_OK);
      end;
      ClearOnStart := cbClearOnStart.Checked;
      UnlimitSize := cbUnlimitSize.Checked;
      UseEventLog := cbUseEventLog.Checked;
    end;
    CanClose := True;
  end;
end;

end.
