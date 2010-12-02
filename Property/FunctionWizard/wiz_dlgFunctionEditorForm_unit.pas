{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}
unit wiz_dlgFunctionEditorForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_DLGEDITFROM_UNIT, ActnList, StdCtrls, ExtCtrls, ComCtrls, wiz_FunctionBlock_unit,
  prm_ParamFunctions_unit, contnrs, wiz_FunctionsParams_unit, SynEdit,
  SynEditHighlighter, SynHighlighterVBScript;

type
  TdlgFunctionEditForm = class(TBlockEditForm)
    cbReturnResult: TCheckBox;
    actAddParam: TAction;
    actDeleteParam: TAction;
    Label3: TLabel;
    lbParams: TListBox;
    bAddParam: TButton;
    bDeleteParam: TButton;
    bUp: TButton;
    bDown: TButton;
    actUp: TAction;
    actDown: TAction;
    Button3: TButton;
    actEditParam: TAction;
    tsParams: TTabSheet;
    sbParams: TScrollBox;
    pnlCaption: TPanel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    tsInitScript: TTabSheet;
    seInitScript: TSynEdit;
    SynVBScriptSyn: TSynVBScriptSyn;
    tsFinalScript: TTabSheet;
    seFinalScript: TSynEdit;
    Panel2: TPanel;
    Button5: TButton;
    actDefaultInit: TAction;
    Panel3: TPanel;
    Button6: TButton;
    actDefaultFin: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PageControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure PageControlChange(Sender: TObject);
    procedure actAddParamExecute(Sender: TObject);
    procedure actDeleteParamUpdate(Sender: TObject);
    procedure actDeleteParamExecute(Sender: TObject);
    procedure actEditParamExecute(Sender: TObject);
    procedure lbParamsDblClick(Sender: TObject);
    procedure actUpExecute(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actDefaultInitExecute(Sender: TObject);
    procedure actDefaultFinExecute(Sender: TObject);
  private
    { Private declarations }
    FFunctionParams: TwizParamList;
    FParamLines: TObjectList;
  protected
    procedure SetBlock(const Value: TVisualBlock); override;

    procedure InitParamsListBox;
    function SaveParams: boolean;
  public
    { Public declarations }
    procedure SaveChanges; override;
  end;

var
  dlgFunctionEditForm: TdlgFunctionEditForm;

implementation

uses
  wiz_dlgFunctionParamEditForm_unit,
  rp_frmParamLineSE_unit,
  syn_ManagerInterface_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

{ TdlgFunctionEditForm }

procedure TdlgFunctionEditForm.SaveChanges;
begin
  inherited;

  with FBlock as TFunctionBlock do
  begin
    ReturnResult := cbReturnResult.Checked;
    if PageControl.ActivePage = tsParams then SaveParams;
    FunctionParams.Assign(FFunctionParams);
    InitScript := seInitScript.Lines.Text;
    FinalScript := seFinalScript.Lines.Text;
  end;
end;

procedure TdlgFunctionEditForm.SetBlock(const Value: TVisualBlock);
begin
  inherited;

  with FBlock as TFunctionBlock do
  begin
    cbReturnResult.Checked := ReturnResult;
    FFunctionParams.Assign(FunctionParams);
    InitParamsListBox;
    seInitScript.Lines.Text := InitScript;
    seFinalScript.Lines.Text := FinalScript;
  end;
end;

procedure TdlgFunctionEditForm.FormCreate(Sender: TObject);
begin
  inherited;
  FFunctionParams := TwizParamList.Create;
  FParamLines := TObjectList.Create(True);
  if Assigned(SynManager) then
    SynManager.GetHighlighterOptions(SynVBScriptSyn);
end;

procedure TdlgFunctionEditForm.FormDestroy(Sender: TObject);
begin
  FFunctionParams.Free;
  FParamLines.Free;

  inherited;
end;

procedure TdlgFunctionEditForm.PageControlChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := True;
  if PageControl.ActivePage = tsParams then AllowChange := SaveParams;
  if AllowChange then
  begin
    sbParams.Visible := False;
    FParamLines.Clear;
  end;
end;

procedure TdlgFunctionEditForm.PageControlChange(Sender: TObject);
var
  ParamDlg: TwizParamList;
  I, J: Integer;
  LocParamLine: TfrmParamLineSE;
begin
  if PageControl.ActivePage = tsParams then
  begin
    sbParams.Visible := False;
    try
      ParamDlg := TwizParamList.Create;
      try
        for I := 0 to lbParams.Items.Count - 1 do
          ParamDlg.AddParam(lbParams.Items[i], '', prmInteger, '');

        pnlCaption.Visible := ParamDlg.Count <> 0;

        FParamLines.Clear;
        for I := 0 to ParamDlg.Count - 1 do
        begin
          for J := 0 to FFunctionParams.Count - 1 do
            if FFunctionParams.Params[J].RealName = ParamDlg.Params[I].RealName then
            begin
              ParamDlg.Params[I].Assign(FFunctionParams.Params[J]);
              Break;
            end;
          LocParamLine := TfrmParamLineSE.Create(nil);
          LocParamLine.Top := FParamLines.Count * LocParamLine.Height;
          LocParamLine.Parent := sbParams;
          LocParamLine.SetParam(ParamDlg.Params[I]);
//          LocParamLine.OnParamChange := ParamChange;
          FParamLines.Add(LocParamLine);
          sbParams.VertScrollBar.Increment := LocParamLine.Height;
        end;
      finally
        ParamDlg.Free;
      end;
    finally
      sbParams.Visible := True;
    end;
  end ;
end;

procedure TdlgFunctionEditForm.actAddParamExecute(Sender: TObject);
var
  F: TdlgFunctionParamEditForm;
  Index: Integer;
begin
  F := TdlgFunctionParamEditForm.Create(Application);
  try
    if F.ShowModal = mrOk then
    begin
      Index := FFunctionParams.AddParam(Trim(F.eName.Text), '', prmInteger, '');
      FFunctionParams.Params[Index].ReferenceType := F.cbReferenceType.Text;
      lbParams.Items.AddObject(F.eName.Text, FFunctionParams.Params[Index]);
    end;
  finally
    F.Free;
  end;
end;

procedure TdlgFunctionEditForm.actDeleteParamUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbParams.ItemIndex > - 1;
end;

procedure TdlgFunctionEditForm.actDeleteParamExecute(Sender: TObject);
begin
  if (UpperCase(lbParams.Items[lbParams.ItemIndex]) = 'BEGINDATE') or
    (UpperCase(lbParams.Items[lbParams.ItemIndex]) = 'ENDDATE') then
  begin
    MessageBox(Application.Handle, 'Данный параметр является обязательным'#13#10 +
      'и не может быть удален.', 'Внимание', MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    Exit;  
  end;
  FFunctionParams.Remove(lbParams.Items.Objects[lbParams.ItemIndex]);
  lbParams.Items.Delete(lbParams.ItemIndex);
end;

procedure TdlgFunctionEditForm.actEditParamExecute(Sender: TObject);
var
  F: TdlgFunctionParamEditForm;
begin
  F := TdlgFunctionParamEditForm.Create(Application);
  try
    F.eName.Text := TwizParamData(lbParams.Items.Objects[lbParams.ItemIndex]).RealName;
    F.cbReferenceType.Text := TwizParamData(lbParams.Items.Objects[lbParams.ItemIndex]).ReferenceType;
    if F.ShowModal = mrOk then
    begin
      lbParams.Items[lbParams.ItemIndex] := Trim(F.eName.Text);
      TwizParamData(lbParams.Items.Objects[lbParams.ItemIndex]).RealName := Trim(F.eName.Text);
      TwizParamData(lbParams.Items.Objects[lbParams.ItemIndex]).ReferenceType := F.cbReferenceType.Text;
    end;
  finally
    F.Free;
  end;
end;

procedure TdlgFunctionEditForm.lbParamsDblClick(Sender: TObject);
begin
  actEditParam.Execute;
end;

procedure TdlgFunctionEditForm.InitParamsListBox;
var
  I: Integer;
  P:  TwizParamData;
begin
  lbParams.Items.Clear;
  for I := 0 to FFunctionParams.Count - 1 do
  begin
    P := FFunctionParams.Params[i];
    lbParams.Items.AddObject(P.RealName, P);
  end;
end;

procedure TdlgFunctionEditForm.actUpExecute(Sender: TObject);
var
  Index: Integer;
begin
  if lbParams.ItemIndex > 0 then
  begin
    Index := lbParams.ItemIndex;
    lbParams.Items.Move(Index, Index - 1);
    FFunctionParams.Move(Index, Index - 1)
  end;
end;

procedure TdlgFunctionEditForm.actDownExecute(Sender: TObject);
var
  Index: Integer;
begin
  if lbParams.ItemIndex < lbParams.Items.Count - 1 then
  begin
    Index := lbParams.ItemIndex;
    lbParams.Items.Move(Index, Index + 1);
    FFunctionParams.Move(Index, Index + 1)
  end;
end;

function TdlgFunctionEditForm.SaveParams: boolean;
var
  I, Index: Integer;
begin
  Result := True;
  FFunctionParams.Clear;
  lbParams.Items.Clear;
  for I := 0 to FParamLines.Count - 1 do
  begin
    Index := FFunctionParams.AddParam('', '', prmInteger, '');
    Result := Result and
      TfrmParamLineSE(FParamLines[I]).GetParam(FFunctionParams.Params[I]);
    if Result then
      lbParams.Items.AddObject(FFunctionParams.Params[Index].RealName, FFunctionParams.Params[Index]);
  end;
end;

procedure TdlgFunctionEditForm.actOkExecute(Sender: TObject);
begin
  inherited;
  if (ActiveControl = seInitScript) or (ActiveControl = seFinalScript) then
    ModalResult := mrNone;
end;

procedure TdlgFunctionEditForm.actDefaultInitExecute(Sender: TObject);
begin
  with Block as TFunctionBlock do
  begin
    InitInitScript;
    seInitScript.Text := InitScript;
  end;
end;

procedure TdlgFunctionEditForm.actDefaultFinExecute(Sender: TObject);
begin
  with Block as TFunctionBlock do
  begin
    InitFinalScript;
    seFinalScript.Text := FinalScript;
  end;
end;

end.
