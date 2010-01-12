unit gs_frmFunctionEdit_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, SynEdit, ExtCtrls, SynEditHighlighter,
  SynHighlighterSQL, TB2Item, TB2Dock, TB2Toolbar,
  gsFDBConvertHelper_unit, dmImages_unit;

type
  TfrmFunctionEdit = class(TForm)
    ActionList1: TActionList;
    actSave: TAction;
    pnlSynEdit: TPanel;
    seFunction: TSynEdit;
    pnlBottom: TPanel;
    pnlBottomRight: TPanel;
    btnSave: TButton;
    SynSQLSyn: TSynSQLSyn;
    btnStopConvert: TButton;
    actStopConvert: TAction;
    actComment: TAction;
    actUncomment: TAction;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    actShowErrorMessage: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBItem3: TTBItem;
    procedure actSaveExecute(Sender: TObject);
    procedure actCommentExecute(Sender: TObject);
    procedure actStopConvertExecute(Sender: TObject);       
    procedure FormShow(Sender: TObject);
    procedure actUncommentExecute(Sender: TObject);
    procedure actShowErrorMessageExecute(Sender: TObject);
    procedure actCommentUpdate(Sender: TObject);
    procedure actUncommentUpdate(Sender: TObject);
  private
    FErrorMessage: String;
    FMetadataType: TgsMetadataType;

    procedure InitializeLocalization;

    function GetSynEditFunctionText: String;
    procedure SetSynEditFunctionText(const Value: String);
  public
    function ShowForTrigger(const ATriggerName, ATriggerText, AErrorMessage: String): TModalResult;
    function ShowForProcedure(const AProcedureName, AProcedureText, AErrorMessage: String): TModalResult;
    function ShowForView(const AViewName, AViewText, AErrorMessage: String): TModalResult;

    property SynEditFunctionText: String read GetSynEditFunctionText write SetSynEditFunctionText;
    property MetadataErrorMessage: String read FErrorMessage write FErrorMessage;
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

function TfrmFunctionEdit.ShowForProcedure(const AProcedureName, AProcedureText,
  AErrorMessage: String): TModalResult;
begin
  // Заголовок окна
  Self.Caption := Format('%s %s', [GetLocalizedString(lsFEProcedureEditCaption), AProcedureName]);
  // Текст процедуры
  SynEditFunctionText := AProcedureText;
  // Текст сообщения об ошибке
  MetadataErrorMessage := AErrorMessage;

  FMetadataType := mtProcedure;

  Result := ShowModal;
end;

function TfrmFunctionEdit.ShowForTrigger(const ATriggerName, ATriggerText,
  AErrorMessage: String): TModalResult;
begin
  // Заголовок окна
  Self.Caption := Format('%s %s', [GetLocalizedString(lsFETriggerEditCaption), ATriggerName]);
  // Текст триггера
  SynEditFunctionText := ATriggerText;
  // Текст сообщения об ошибке
  MetadataErrorMessage := AErrorMessage;

  FMetadataType := mtTrigger;

  Result := ShowModal;
end;

function TfrmFunctionEdit.ShowForView(const AViewName, AViewText,
  AErrorMessage: String): TModalResult;
begin
  // Заголовок окна
  Self.Caption := Format('%s %s', [GetLocalizedString(lsFEViewEditCaption), AViewName]);
  // Текст представления
  SynEditFunctionText := AViewText;
  // Текст сообщения об ошибке
  MetadataErrorMessage := AErrorMessage;

  FMetadataType := mtView;

  Result := ShowModal;
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
  actStopConvert.Caption := GetLocalizedString(lsFEStopConvert);
  actSave.Caption := GetLocalizedString(lsFESaveMetadata);
  actComment.Caption := GetLocalizedString(lsFEDoComment);
  actUncomment.Caption := GetLocalizedString(lsFEDoUncomment);
  actShowErrorMessage.Caption := GetLocalizedString(lsFEDoShowError);
end;

procedure TfrmFunctionEdit.actUncommentExecute(Sender: TObject);
var
  FunctionText: String;
begin
  FunctionText := SynEditFunctionText;
  if TgsMetadataEditor.UncommentFunctionBody(FunctionText) then
    SynEditFunctionText := FunctionText;
end;

procedure TfrmFunctionEdit.actShowErrorMessageExecute(Sender: TObject);
var
  ErrorMessageLocal: String;
begin
  // Сформируем сообщение
  case FMetadataType of
    mtTrigger:
    begin
      ErrorMessageLocal := Format('%s %s %s ...',
        [GetLocalizedString(lsFETriggerErrorCaption), #13#10, TgsMetadataEditor.GetFirstNLines(FErrorMessage, 25)]);
    end;

    mtProcedure:
    begin
      ErrorMessageLocal := Format('%s %s %s ...',
        [GetLocalizedString(lsFEProcedureErrorCaption), #13#10, TgsMetadataEditor.GetFirstNLines(FErrorMessage, 25)]);
    end;

    mtView:
    begin
      ErrorMessageLocal := Format('%s %s %s ...',
        [GetLocalizedString(lsFEViewErrorCaption), #13#10, TgsMetadataEditor.GetFirstNLines(FErrorMessage, 25)]);
    end;     
  end;
  // Выведем сообщение
  Application.MessageBox(PChar(ErrorMessageLocal), PChar(GetLocalizedString(lsInformationDialogCaption)),
    MB_OK or MB_ICONERROR or MB_APPLMODAL);
end;

procedure TfrmFunctionEdit.actCommentUpdate(Sender: TObject);
begin
  actComment.Enabled := (FMetadataType in [mtTrigger, mtProcedure]);
end;

procedure TfrmFunctionEdit.actUncommentUpdate(Sender: TObject);
begin
  actUncomment.Enabled := (FMetadataType in [mtTrigger, mtProcedure]);
end;

end.
