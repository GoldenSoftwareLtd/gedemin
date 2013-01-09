unit xp_frmMemoDropDown_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xp_frmDropDown_unit, ActnList, StdCtrls, XPEdit, TB2Item,
  TB2Dock, TB2Toolbar, ExtCtrls, SizePanel, ImgList, XPButton;

type
  TfrmMemoDropDown = class(TfrmDropDown)
    SizePanel: TSizePanel;
    Memo: TXPMemo;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    actSaveAndExit: TAction;
    actSaveToFile: TAction;
    actLoadFromFile: TAction;
    il16x16: TImageList;
    OpenDialog: TOpenDialog;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    bOk: TXPButton;
    bCancel: TXPButton;
    SaveDialog: TSaveDialog;
    procedure SizePanelButtonClick(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actSaveAndExitExecute(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetInitBounds(ALeft, ATop, AWidth, AHeight: Integer; FirstTime:Boolean): TRect; override;
    function GetValue: Variant; override;
    procedure SetValue(const Value: Variant); override;
    procedure Loaded; override;
  public
    { Public declarations }
  end;

var
  frmMemoDropDown: TfrmMemoDropDown;

implementation

{$R *.dfm}

{ TfrmMemoDropDown }

function TfrmMemoDropDown.GetValue: Variant;
begin
  Result := Memo.Lines.Text;
end;

procedure TfrmMemoDropDown.SetValue(const Value: Variant);
begin
  inherited;
  if VarIsNull(Value) then
    Memo.Lines.Text := ''
  else
    Memo.Lines.Text := Value;
end;

function TfrmMemoDropDown.GetInitBounds(ALeft, ATop, AWidth,
  AHeight: Integer; FirstTime:Boolean): TRect;
const
  InitWidth = 400;
begin
  if FirstTime  then
    if InitWidth > AWidth then
      Result := Rect(0, 0 , InitWidth, Height)
    else
      Result := Rect(0, 0 , AWidth, Height)
  else
    Result := Rect(0, 0 , Width, Height);
end;

procedure TfrmMemoDropDown.SizePanelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmMemoDropDown.MemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Vk_Return) and ([ssCtrl] * Shift <> []) then
  begin
    Key := 0;
    ModalResult := mrOk;
  end else
    inherited;
end;

procedure TfrmMemoDropDown.actSaveAndExitExecute(Sender: TObject);
begin
  ModalResult := mrOk;

end;

procedure TfrmMemoDropDown.actLoadFromFileExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    Memo.Lines.LoadFromFile(OpenDialog.FileName);
  end;
end;

procedure TfrmMemoDropDown.actSaveToFileExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    Memo.Lines.SaveToFile(SaveDialog.FileName);
  end;
end;

procedure TfrmMemoDropDown.Loaded;
begin
  inherited;
  bCancel.Left := SizePanel.Width - 17 - bCancel.Width;
  bOk.Left := bCancel.Left - 5 - bOk.Width;
end;

end.
