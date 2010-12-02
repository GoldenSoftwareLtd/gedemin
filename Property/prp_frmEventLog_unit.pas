unit prp_frmEventLog_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList, Menus, prp_dlgEventComent_unit,
  prp_dlgEventProperty_unit, gd_DebugLog;

type
  TfrmEventLog = class(TForm)
    mEventLog: TMemo;
    pmEventLog: TPopupMenu;
    alEventLog: TActionList;
    actAddComent: TAction;
    actSaveEventToLog: TAction;
    actClearEventLog: TAction;
    actProperty: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    SaveDialog: TSaveDialog;
    procedure actAddComentExecute(Sender: TObject);
    procedure actSaveEventToLogExecute(Sender: TObject);
    procedure actPropertyExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actClearEventLogExecute(Sender: TObject);
  private
    { Private declarations }
    FSettings: TEventLogSettings;
    
    procedure OnAddLog(Sender: TObject; Str: String);
  public
    { Public declarations }
  end;

var
  frmEventLog: TfrmEventLog;

implementation
{$R *.DFM}

procedure TfrmEventLog.actAddComentExecute(Sender: TObject);
var
  D: TdlgEventComent;
begin
  D := TdlgEventComent.Create(nil);
  try
    if D.ShowModal = mrOk then
    begin
      mEventLog.Lines.Add(D.eComent.Text);
      Log.Strings.Add(D.eComent.Text);
    end
  finally
    D.Free;
  end;
end;

procedure TfrmEventLog.actSaveEventToLogExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
    mEventLog.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TfrmEventLog.actPropertyExecute(Sender: TObject);
var
  D: TdlgEventProperty;
begin
  D := TdlgEventProperty.Create(nil);
  try
    if D.ShowModal = mrOk then
      Log.Settings := D.Settings;
      FSettings := D.Settings;
  finally
    D.Free;
  end;
end;

procedure TfrmEventLog.FormDestroy(Sender: TObject);
begin
  frmEventLog := nil;
  Log.OnAddLog := nil;
end;

procedure TfrmEventLog.FormCreate(Sender: TObject);
begin
  if not Assigned(frmEventLog) then
    frmEventLog := Self;
  FSettings := LoadSettings;
  mEventLog.Lines := Log.Strings;
  Log.OnAddLog := OnAddLog;
end;

procedure TfrmEventLog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmEventLog.actClearEventLogExecute(Sender: TObject);
begin
  mEventLog.Lines.Clear;
  Log.Strings.Clear;
end;

procedure TfrmEventLog.OnAddLog(Sender: TObject; Str: String);
var
  I: Integer;
begin
  mEventLog.Lines.Add(Str);
  if not FSettings.UnlimitSize and (FSettings.EventSize < mEventLog.Lines.Count) then
  begin
    for I := mEventLog.Lines.Count - FSettings.EventSize - 1 downto 0 do
      mEventLog.Lines.Delete(I);
  end;
end;

end.
