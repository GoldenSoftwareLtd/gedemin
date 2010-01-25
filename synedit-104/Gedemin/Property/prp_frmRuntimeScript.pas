unit prp_frmRuntimeScript;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, obj_i_Debugger, Buttons, prp_DOCKFORM_unit, ActnList,
  TB2Item, TB2Dock, TB2Toolbar, Menus;

type
  TfrmRuntimeScript = class(TDockableForm)
    lbRunTime: TListBox;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    tbiSaveTime: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    actSaveTime: TAction;
    actDonorefresh: TAction;
    actRefresh: TAction;
    actDeleteAll: TAction;
    N1: TMenuItem;
    N3: TMenuItem;
    actGotoFunction: TAction;
    N4: TMenuItem;
    N5: TMenuItem;
    TBSeparatorItem2: TTBSeparatorItem;
    tbiIgnore: TTBItem;
    actIgnore: TAction;
    edtIgnoreList: TEdit;
    TBControlItem1: TTBControlItem;
    tbiSave: TTBItem;
    actSave: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure cbStopClick(Sender: TObject);
    procedure cbRuntimeSaveClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure actRefreshUpdate(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actGotoFunctionExecute(Sender: TObject);
    procedure lbRunTimeDblClick(Sender: TObject);
    procedure actDeleteAllUpdate(Sender: TObject);
    procedure actIgnoreExecute(Sender: TObject);
    procedure actIgnoreUpdate(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
  private
    FIgnoreList: TStringList;
    procedure AddRuntimeString(RuntimeRec: TRuntimeRec);
    procedure EndRunScript(Sender: TObject; RuntimeRec: TRuntimeRec);
    procedure FillList;
    procedure FillIgnoreList;
    procedure SaveIgnoreSettings;
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;

  public
    { Public declarations }
  end;

var
  frmRuntimeScript: TfrmRuntimeScript;

implementation

{$R *.DFM}

uses
  prp_PropertySettings, gd_i_Scriptfactory, scr_i_FunctionList, mtd_i_Base,
  prp_frmGedeminProperty_Unit, Storages;


procedure TfrmRuntimeScript.EndRunScript(Sender: TObject;
  RuntimeRec: TRuntimeRec);
begin
  if not actDonorefresh.Checked then
    AddRuntimeString(RuntimeRec);
end;

procedure TfrmRuntimeScript.FormCreate(Sender: TObject);
begin
  FIgnoreList:= TStringList.Create;
  edtIgnoreList.Text:= PropertySettings.DebugSet.IgnoreRuntimeList;
  if PropertySettings.DebugSet.IgnoreRuntime then begin
    FillIgnoreList;
    tbiIgnore.Checked:= True;
    actIgnore.ImageIndex:= 257;
  end;
  FillList;
end;

procedure TfrmRuntimeScript.FormDestroy(Sender: TObject);
begin
  SaveIgnoreSettings;
  FIgnoreList.Free;
  if Assigned(Debugger) then
    Debugger.OnEndScript := nil;
  inherited;  
end;

procedure TfrmRuntimeScript.btnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRuntimeScript.cbStopClick(Sender: TObject);
begin
  actDonorefresh.Checked := not actDonorefresh.Checked;
  if not actDonorefresh.Checked then
    FillList;
end;

procedure TfrmRuntimeScript.AddRuntimeString(RuntimeRec: TRuntimeRec);
var
  Str: String;
  i: integer;

const
  rtStr =
    'ID: %d, Runtime: %dmc, FunctionName: %s, Begin time: ';
begin
  if tbiIgnore.Checked then begin
    for i:= 0 to FIgnoreList.Count - 1 do
      if Pos(AnsiLowerCase(FIgnoreList[i]), AnsiLowerCase(RuntimeRec.FunctionName)) > 0 then
        Exit;
  end;
  with RuntimeRec do
  begin
    Str := Format(rtStr, [FunctionKey, RuntimeTicks, FunctionName]) +
      TimeToStr(BeginTime);
    lbRunTime.Items.AddObject(Str, TObject(FunctionKey));
  end;
end;

procedure TfrmRuntimeScript.FillList;
var
  i: Integer;           
begin
  lbRunTime.Items.Clear;
  if Assigned(Debugger) then
  begin
    Debugger.OnEndScript := EndRunScript;
    for i := 0 to Debugger.ResultRuntimeList.Count - 1 do
    begin
      AddRuntimeString(Debugger.ResultRuntimeList.Item[I]);
    end;
  end;
end;

procedure TfrmRuntimeScript.cbRuntimeSaveClick(Sender: TObject);
var
  LCursor: TCursor;
begin
  actSaveTime.Checked := not actSaveTime.Checked;
  PropertySettings.DebugSet.RuntimeSave := actSaveTime.Checked;

  LCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if Assigned(glbFunctionList) then
      glbFunctionList.UpdateList;
    if Assigned(ScriptFactory) then
      ScriptFactory.Reset;
    if Assigned(MethodControl) then
      MethodControl.ClearMacroCache;
  finally
    Screen.Cursor := LCursor;
  end;
end;

procedure TfrmRuntimeScript.FormActivate(Sender: TObject);
begin
  actSaveTime.Checked := PropertySettings.DebugSet.RuntimeSave;
end;

procedure TfrmRuntimeScript.btnRefreshClick(Sender: TObject);
begin
  FillList;
end;

procedure TfrmRuntimeScript.actRefreshUpdate(Sender: TObject);
begin
  Taction(Sender).Enabled := actDonorefresh.Checked;
end;

procedure TfrmRuntimeScript.actClearExecute(Sender: TObject);
begin
  lbRunTime.Items.Clear;
  if Debugger <> nil then
  begin
    Debugger.ResultRuntimeList.Clear;
  end;
end;

procedure TfrmRuntimeScript.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
{  if pCaption.Visible then
  begin
    pCaption.Top := 0;
    TBDock1.Top := pCaption.Height;
  end;}

  inherited;
end;

procedure TfrmRuntimeScript.actGotoFunctionExecute(Sender: TObject);
begin
  if (lbRunTime.ItemIndex > -1) and
    (Integer(lbRunTime.Items.Objects[lbRunTime.ItemIndex]) > 0) then
    TfrmGedeminProperty(DockForm).FindAndEdit(
      Integer(lbRunTime.Items.Objects[lbRunTime.ItemIndex]), 0, 0);
end;

procedure TfrmRuntimeScript.lbRunTimeDblClick(Sender: TObject);
begin
  actGotoFunction.Execute;
end;

procedure TfrmRuntimeScript.actDeleteAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbRunTime.Items.Count > 0
end;

procedure TfrmRuntimeScript.actIgnoreExecute(Sender: TObject);
begin
  PropertySettings.DebugSet.IgnoreRuntime:= tbiIgnore.Checked;
  if tbiIgnore.Checked then begin
    FillIgnoreList;
    actIgnore.ImageIndex:= 257;
  end
  else
    actIgnore.ImageIndex:= 20;
end;

procedure TfrmRuntimeScript.actIgnoreUpdate(Sender: TObject);
begin
  edtIgnoreList.Enabled:= not (tbiSaveTime.Checked and tbiIgnore.Checked);
end;

procedure TfrmRuntimeScript.FillIgnoreList;
var
  IStr, Str: string;
begin
  PropertySettings.DebugSet.IgnoreRuntimeList:= edtIgnoreList.Text;
  FIgnoreList.Clear;
  IStr:= Trim(edtIgnoreList.Text);
  while Length(IStr) > 0 do begin
    if Pos(',', IStr) > 0 then begin
      Str:= TrimRight(Copy(IStr, 1, Pos(',', IStr) - 1));
      FIgnoreList.Add(Str);
      Delete(IStr, 1, Pos(',', IStr));
      IStr:= TrimLeft(IStr);
    end
    else begin
      FIgnoreList.Add(Trim(IStr));
      IStr:= '';
    end;
  end;
end;

procedure TfrmRuntimeScript.actSaveExecute(Sender: TObject);
var
  SD: TSaveDialog;
begin
  SD:= TSaveDialog.Create(self);
  try
    SD.Options:= [ofOverwritePrompt];
    SD.DefaultExt:= 'txt';
    SD.Filter:= 'Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*.*';
    if SD.Execute then begin
      lbRunTime.Items.SaveToFile(SD.FileName);
    end;
  finally
    SD.Free;
  end;
end;

procedure TfrmRuntimeScript.SaveIgnoreSettings;
begin
  if not Assigned(UserStorage) then
    Exit;
  UserStorage.WriteBoolean(sPropertyDebugSetPath,
    cIgnoreRuntime, PropertySettings.DebugSet.IgnoreRuntime);
  UserStorage.WriteString(sPropertyDebugSetPath,
    cIgnoreRuntimeList, PropertySettings.DebugSet.IgnoreRuntimeList);
end;

end.
