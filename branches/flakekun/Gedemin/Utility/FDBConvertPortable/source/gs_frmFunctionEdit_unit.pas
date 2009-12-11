unit gs_frmFunctionEdit_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, SynEdit, ExtCtrls, SynEditHighlighter,
  SynHighlighterSQL;

type
  TfrmFunctionEdit = class(TForm)
    ActionList1: TActionList;
    actSave: TAction;
    actCancel: TAction;
    pnlSynEdit: TPanel;
    seFunction: TSynEdit;
    pnlBottom: TPanel;
    pnlBottomRight: TPanel;
    btnSave: TButton;
    btnSkip: TButton;
    SynSQLSyn: TSynSQLSyn;
    pnlFunctionLabel: TPanel;
    lblFunction: TLabel;
    Splitter1: TSplitter;
    pnlTop: TPanel;
    pnlError: TPanel;
    Splitter2: TSplitter;
    pnlParams: TPanel;
    seParams: TSynEdit;
    pnlParamsLabel: TPanel;
    lblParams: TLabel;
    Panel2: TPanel;
    lblEditComment: TLabel;
    seError: TSynEdit;
    btnStopConvert: TButton;
    Panel1: TPanel;
    actStopConvert: TAction;
    procedure actSaveExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actCommentExecute(Sender: TObject);
    procedure actStopConvertExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure InitializeLocalization;

    function GetSynEditFunctionText: String;
    procedure SetSynEditFunctionText(const Value: String);
    function GetSynEditParamText: String;
    procedure SetSynEditParamText(const Value: String);
    { Private declarations }
  public
    function ShowForTrigger(const ATriggerName, ATriggerText, AErrorMessage: String): TModalResult;
    function ShowForProcedure(const AProcedureName, AProcedureParamsText, AProcedureText, AErrorMessage: String): TModalResult;
    function ShowForView(const AViewName, AViewText, AErrorMessage: String): TModalResult;

    property SynEditFunctionText: String read GetSynEditFunctionText write SetSynEditFunctionText;
    property SynEditParamText: String read GetSynEditParamText write SetSynEditParamText;
  end;

var
  frmFunctionEdit: TfrmFunctionEdit;

implementation

{$R *.DFM}

uses
  gsFDBConvert_unit, gsFDBConvertLocalization_unit;

{ TfrmFunctionEdit }

function TfrmFunctionEdit.GetSynEditFunctionText: String;
begin
  Result := seFunction.Lines.Text;
end;

procedure TfrmFunctionEdit.SetSynEditFunctionText(const Value: String);
begin
  seFunction.Lines.Text := Value;
end;

procedure TfrmFunctionEdit.actSaveExecute(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TfrmFunctionEdit.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmFunctionEdit.ShowForProcedure(const AProcedureName,
  AProcedureParamsText, AProcedureText,
  AErrorMessage: String): TModalResult;
begin
  Self.Caption := Format('%s %s', [GetLocalizedString(lsFEProcedureEditCaption), AProcedureName]);
  lblEditComment.Caption := GetLocalizedString(lsFEProcedureErrorCaption);
  pnlParams.Visible := True;
  seParams.Lines.Text := AProcedureParamsText;
  SynEditFunctionText := AProcedureText;
  seError.Lines.Text := AErrorMessage;
  lblParams.Caption := Format('%s %s', [GetLocalizedString(lsFEParamsCaption), AProcedureName]);
  lblFunction.Caption := Format('%s %s', [GetLocalizedString(lsFEProcedureCaption), AProcedureName]);

  Result := ShowModal;
end;

function TfrmFunctionEdit.ShowForTrigger(const ATriggerName, ATriggerText,
  AErrorMessage: String): TModalResult;
begin
  Self.Caption := Format('%s %s', [GetLocalizedString(lsFETriggerEditCaption), ATriggerName]);
  lblEditComment.Caption := GetLocalizedString(lsFETriggerErrorCaption);
  pnlParams.Visible := False;
  SynEditFunctionText := ATriggerText;
  seError.Lines.Text := AErrorMessage;
  lblFunction.Caption := Format('%s %s', [GetLocalizedString(lsFETriggerCaption), ATriggerName]);;

  Result := ShowModal;
end;

function TfrmFunctionEdit.ShowForView(const AViewName, AViewText,
  AErrorMessage: String): TModalResult;
begin
  Self.Caption := Format('%s %s', [GetLocalizedString(lsFEViewEditCaption), AViewName]);
  lblEditComment.Caption := GetLocalizedString(lsFEViewErrorCaption);
  pnlParams.Visible := False;
  SynEditFunctionText := AViewText;
  seError.Lines.Text := AErrorMessage;
  lblFunction.Caption := Format('%s %s', [GetLocalizedString(lsFEViewCaption), AViewName]);

  Result := ShowModal;
end;

function TfrmFunctionEdit.GetSynEditParamText: String;
begin
  Result := seParams.Lines.Text;
end;

procedure TfrmFunctionEdit.SetSynEditParamText(const Value: String);
begin
  seParams.Lines.Text := Value;
end;

procedure TfrmFunctionEdit.actCommentExecute(Sender: TObject);
var
  FunctionText: String;
begin
  FunctionText := SynEditFunctionText;
  if TgsMetadataEditor.CommentFunctionBody(FunctionText) then
    SynEditFunctionText := FunctionText;
end;

procedure TfrmFunctionEdit.actStopConvertExecute(Sender: TObject);
begin
  ModalResult := mrAbort;
end;

procedure TfrmFunctionEdit.FormShow(Sender: TObject);
begin
  InitializeLocalization;
end;

procedure TfrmFunctionEdit.InitializeLocalization;
begin
  btnStopConvert.Caption := GetLocalizedString(lsFEStopConvert);
  btnSave.Caption := GetLocalizedString(lsFESaveMetadata);
  btnSkip.Caption := GetLocalizedString(lsFESkipMetadata);
end;

end.
