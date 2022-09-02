// ShlTanya, 12.03.2019

{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    tax_frmAddParamsFunc_unit.pas

  Abstract

    Form for visual addition parameters of fiscal function.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    07.02.03    DAlex      Initial version.

--}

unit tax_frmAddParamsFunc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Spin, Buttons, StdCtrls, ExtCtrls, ImgList, ActnList, Menus, BtnEdit,
  tax_frmAvailableTaxFunc_unit, wiz_FunctionBlock_unit, gdcBaseInterface;

type
  TParamPanel = class(TPanel)
  private
    FedtParam: TBtnEdit;
    FlblParam: TLabel;

    procedure SetedtParam(const Value: TBtnEdit);
    procedure SetlblParam(const Value: TLabel);

  public
    constructor Create(AOwner: TComponent); override;

    procedure AssignSize(Source: TParamPanel);

    property lblParam: TLabel read FlblParam write SetlblParam;
    property edtParam: TBtnEdit read FedtParam write SetedtParam;
  end;

type
  TfrmAddParamsFunc = class(TForm)
    plnButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlMain: TPanel;
    pnlFunction: TPanel;
    lblFunction: TLabel;
    sbParams: TScrollBox;
    pnlParam: TPanel;
    lblParam: TLabel;
    pmAdd: TPopupMenu;
    alAdd: TActionList;
    actAddFunction: TAction;
    actAddAnalytics: TAction;
    ilAdd: TImageList;
    edtParam: TBtnEdit;
    miAnalitics: TMenuItem;
    miFunction: TMenuItem;
    actAccount: TAction;
    miAccount: TMenuItem;
    actOk: TAction;
    actCancel: TAction;
    pnlDescr: TPanel;
    mmDescription: TMemo;
    Bevel1: TBevel;
    actAddValue: TAction;
    N1: TMenuItem;
    procedure actAddFunctionExecute(Sender: TObject);
    procedure actAddAnalyticsExecute(Sender: TObject);
    procedure actAccountExecute(Sender: TObject);
    procedure edtParamBtnOnClick(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actAddValueExecute(Sender: TObject);
  protected
    FActualTaxKey: TID;
    FActiveEdit: TBtnEdit;
    FFuncDescr: TFuncDescr;
    FParamPanelList: TList;
    FLastParamPanel: TParamPanel;
    FMaxHeight: Integer;

    function GetParamsStr: String;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure  SetParams(const FuncMask, Description: String;
      const ActualTaxKey: TID; const FuncDescr: TFuncDescr);

    property ParamsStr: String read GetParamsStr;
  end;

var
  frmAddParamsFunc: TfrmAddParamsFunc;

implementation

uses
  tax_frmAnalytics_unit, gdc_frmAccountSel_unit, gdc_frmValueSel_unit;


{$R *.DFM}

procedure TfrmAddParamsFunc.actAddFunctionExecute(Sender: TObject);
begin
  with TfrmAvailableTaxFunc.CreateWithParams(Self, FActualTaxKey, '') do
  try
    if ShowModal = idOk then
    begin
      FActiveEdit.SelText := SelectedFunction;
    end;
  finally
    Free;
  end;
end;

procedure TfrmAddParamsFunc.actAddAnalyticsExecute(Sender: TObject);
begin
  with TfrmAnalytics.Create(nil) do
  try
    if ShowModal = idOk then
    begin
      if (FActiveEdit.Text > '') then
      begin
        FActiveEdit.Text := FActiveEdit.Text + ' + "; " + ';
      end;

      FActiveEdit.Text := FActiveEdit.Text + '"' + Analytics + '"';
    end;
  finally
    Free
  end;
end;

constructor TfrmAddParamsFunc.Create(AOwner: TComponent);
begin
  inherited;

  if GetDeviceCaps(GetDC(Self.Handle), VERTRES) > 479 then
    FMaxHeight := GetDeviceCaps(GetDC(Self.Handle), VERTRES) - 60;

  FParamPanelList := TList.Create;
end;

function TfrmAddParamsFunc.GetParamsStr: String;
var
  i: Integer;
  ParamPanel: TParamPanel;
begin
  Result := '';
  for i := 0 to FParamPanelList.Count - 1 do
    if ModalResult <> idCancel then
    begin
      ParamPanel := TParamPanel(FParamPanelList[i]);
      with ParamPanel do
      begin
        if Result > '' then
          Result := Result + ', ';
        if Trim(edtParam.Text) = '' then
          Result := Result + 'Empty'
        else
          Result := Result + edtParam.Text;
      end;
    end else
      begin
        if i = 0 then
          Result := Result + '  '
        else
          Result := Result + '  ,  ';
      end;
end;

procedure TfrmAddParamsFunc.actAccountExecute(Sender: TObject);
var
  Account: string;
  AccountRUID: string;
begin
  if (MainFunction <> nil) and (FActiveEdit <> nil) then
  begin
    if MainFunction.OnClickAccount(Account, AccountRUID) then
    begin
      if CheckRUID(AccountRUID) then
        FActiveEdit.Text := '"' + AccountRUID + '"{' + Account + '}'
      else
        FActiveEdit.Text :=  AccountRUID + '{' + Account + '}'
    end;
  end;
end;

procedure TfrmAddParamsFunc.edtParamBtnOnClick(Sender: TObject);
var
  Point: TPoint;
begin
  if Sender is TEditSButton then
  begin
    FActiveEdit := TEditSButton(Sender).Edit;
    Point.x := 0;
    Point.y := TEditSButton(Sender).Height - 1;
    Point := TEditSButton(Sender).ClientToScreen(Point);
    pmAdd.Popup(Point.X, Point.Y);
  end;
end;

procedure TfrmAddParamsFunc.SetParams(const FuncMask, Description: String;
  const ActualTaxKey: TID; const FuncDescr: TFuncDescr);
var
  i: Integer;
  ParamPanel: TParamPanel;
begin
  sbParams.AutoScroll := False;

  lblFunction.Caption := FuncMask;
  mmDescription.Lines.Text := Description;
  FActualTaxKey := ActualTaxKey;
  FFuncDescr := FuncDescr;

  if Length(FFuncDescr.ParamArray) = 0 then
    raise Exception.Create('Функция ' + FFuncDescr.Name + ' не имеет параметров.');

  ParamPanel := TParamPanel.Create(Self);
  with ParamPanel do
  begin
    Parent := sbParams;
    BoundsRect := pnlParam.BoundsRect;
    Align := pnlParam.Align;
    Anchors := pnlParam.Anchors;
    lblParam.BoundsRect := Self.lblParam.BoundsRect;
    lblParam.Align      := Self.lblParam.Align;
    lblParam.Anchors    := Self.lblParam.Anchors;
    edtParam.AssignSize(Self.edtParam);
    edtParam.BtnCaption := Self.edtParam.BtnCaption;
    edtParam.BtnGlyph   := Self.edtParam.BtnGlyph;
    edtParam.BtnOnClick := Self.edtParam.BtnOnClick;

    lblParam.Caption := FFuncDescr.ParamArray[0];
  end;
  FParamPanelList.Add(ParamPanel);
  FLastParamPanel := ParamPanel;

  for i := 1 to Length(FFuncDescr.ParamArray) - 1 do
  begin
    ParamPanel := TParamPanel.Create(Self);
    ParamPanel.AssignSize(FLastParamPanel);
    ParamPanel.Top := FLastParamPanel.Top + FLastParamPanel.Height;
    ParamPanel.Parent := sbParams;

    ParamPanel.lblParam.Caption := FFuncDescr.ParamArray[i];
    ParamPanel.edtParam.BtnCaption := Self.edtParam.BtnCaption;
    ParamPanel.edtParam.BtnGlyph   := Self.edtParam.BtnGlyph;
    ParamPanel.edtParam.BtnOnClick := Self.edtParam.BtnOnClick;
    FLastParamPanel := ParamPanel;
    FParamPanelList.Add(ParamPanel);
  end;
  if (sbParams.Height - 22) < (FLastParamPanel.Height + FLastParamPanel.Top) then
  begin
    Self.Height := Self.Height +
      FLastParamPanel.Height + FLastParamPanel.Top - sbParams.Height + 20;
    if Self.Height > FMaxHeight then
     Self.Height := FMaxHeight;
  end;
  sbParams.AutoScroll := True;;
end;

destructor TfrmAddParamsFunc.Destroy;
begin
  FParamPanelList.Free;
  inherited;
end;

{ TParamPanel }

procedure TParamPanel.AssignSize(Source: TParamPanel);
begin
  BoundsRect := Source.BoundsRect;
  Align   := Source.Align;
  Anchors := Source.Anchors;
  lblParam.BoundsRect := Source.lblParam.BoundsRect;
  lblParam.Align := Source.lblParam.Align;
  lblParam.Anchors := Source.lblParam.Anchors;
  edtParam.AssignSize(Source.edtParam);
end;

constructor TParamPanel.Create(AOwner: TComponent);
begin
  inherited;

  BevelInner := bvNone;
  BevelOuter := bvNone;
  FlblParam  := TLabel.Create(Self);
  FedtParam  := TBtnEdit.Create(Self);
  FlblParam.Parent := Self;
  FedtParam.Parent := Self;
end;

procedure TParamPanel.SetedtParam(const Value: TBtnEdit);
begin
  FedtParam := Value;
end;

procedure TParamPanel.SetlblParam(const Value: TLabel);
begin
  FlblParam := Value;
end;

procedure TfrmAddParamsFunc.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmAddParamsFunc.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmAddParamsFunc.actAddValueExecute(Sender: TObject);
begin
  with TfrmValueSel.Create(Self) do
  try
    if ShowModal = idOk then
    begin
      FActiveEdit.Text := 'gdcBaseManager.GetIDByRUIDString("' +
        gdcBaseManager.GetRUIDStringByID(iblcValue.CurrentKeyInt) + '")';
    end;
  finally
    Free;
  end
end;

end.
