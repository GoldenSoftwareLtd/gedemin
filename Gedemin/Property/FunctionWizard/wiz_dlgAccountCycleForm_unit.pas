// ShlTanya, 09.03.2019

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
unit wiz_dlgAccountCycleForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_DLGEDITFROM_UNIT, ActnList, StdCtrls, ComCtrls, ExtCtrls, BtnEdit,
  gsIBLookupComboBox, wiz_FunctionBlock_unit, Db, IBCustomDataSet, Grids,
  DBGrids, gsDBGrid, gsIBGrid, Menus;

type
  TdlgAccountCycleForm = class(TBlockEditForm)
    beAnal: TBtnEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    beFilter: TBtnEdit;
    gsIBGrid: TgsIBGrid;
    DataSource: TDataSource;
    IBDataSet: TIBDataSet;
    tsAdditional: TTabSheet;
    Label10: TLabel;
    beBeginDate: TBtnEdit;
    beEndDate: TBtnEdit;
    Label11: TLabel;
    Label6: TLabel;
    beGroupBy: TBtnEdit;
    pmAdd: TPopupMenu;
    gbSQL: TGroupBox;
    lSelect: TLabel;
    lFrom: TLabel;
    lWhere: TLabel;
    lOrder: TLabel;
    eSelect: TEdit;
    eFrom: TEdit;
    eWhere: TEdit;
    eOrder: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure beAnalBtnOnClick(Sender: TObject);
    procedure beFilterBtnOnClick(Sender: TObject);
    procedure beBeginDateBtnOnClick(Sender: TObject);
    procedure pmAddPopup(Sender: TObject);
  private
    { Private declarations }
    FActiveEdit: TBtnEdit;
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
    function GetAccounts: string;
    procedure SetAccounts(A: string);
    procedure ClickAnal(Sender: TObject);
    procedure ClickAnalCycle(Sender: TObject);
  public
    { Public declarations }
    procedure SaveChanges; override;
    function CheckOk: Boolean; override;
  end;

var
  dlgAccountCycleForm: TdlgAccountCycleForm;

implementation
uses tax_frmAnalytics_unit, wiz_dlgAliticSelect_unit, wiz_Utils_unit,
  wiz_ExpressionEditorForm_unit, Storages;
{$R *.DFM}

{ TdlgAccountCycleForm }

function TdlgAccountCycleForm.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
    Result := gsIBGrid.CheckBox.CheckCount > 0;
end;

procedure TdlgAccountCycleForm.SaveChanges;
begin
  inherited;
  with FBlock as TAccountCycleBlock do
  begin
    Account := GetAccounts;
    Analise := beAnal.Text;
    Filter := beFilter.Text;
    BeginDate := beBeginDate.Text;
    EndDate := beEnddate.Text;
    GroupBy := beGroupBy.Text;

    Select := eSelect.Text;
    From := eFrom.Text;
    Where := eWhere.Text;
    Order := eOrder.Text;
  end;
end;

procedure TdlgAccountCycleForm.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  with FBlock as TAccountCycleBlock do
  begin
    SetAccounts(Account);
    beAnal.Text := Analise;
    beFilter.Text := Filter;
    beBeginDate.Text := BeginDate;
    beEnddate.Text := EndDate;
    beGroupBy.Text := GroupBy;

    eSelect.Text := Select;
    eFrom.Text := From;
    eWhere.Text := Where;
    eOrder.Text := Order;
  end;
end;

procedure TdlgAccountCycleForm.beAnalBtnOnClick(Sender: TObject);
var
  F: TdlgAnaliticSelect;
begin
  F := TdlgAnaliticSelect.Create(nil);
  try
    F.Analitics := TEditSButton(Sender).Edit.Text;
    if F.ShowModal = mrOk then
      TEditSButton(Sender).Edit.Text := F.Analitics;
  finally
    F.Free;
  end;
end;

procedure TdlgAccountCycleForm.beFilterBtnOnClick(Sender: TObject);
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

procedure TdlgAccountCycleForm.FormCreate(Sender: TObject);
begin
  inherited;
  IBDataSet.Open;
  if UserStorage <> nil then
    UserStorage.LoadComponent(gsIBGrid, gsIBGrid.LoadFromStream);
end;

function TdlgAccountCycleForm.GetAccounts: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to gsIBGrid.CheckBox.CheckCount - 1 do
  begin
    if Result > '' then Result := Result + '; ';
    Result := Result + gsIBGrid.CheckBox.CheckList[I];
  end;
end;

procedure TdlgAccountCycleForm.SetAccounts(A: string);
var
  S: TStrings;
  I: Integer;
begin
  gsIBGrid.CheckBox.CheckList.Clear;
  S := TStringList.Create;
  try
    ParseString(A, S);
    for I := 0 to S.Count - 1 do
      gsIBGrid.CheckBox.CheckList.Add(S[I]);
  finally
    S.Free;
  end;
end;

procedure TdlgAccountCycleForm.beBeginDateBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock)
end;

procedure TdlgAccountCycleForm.FormDestroy(Sender: TObject);
begin
  inherited;
  if UserStorage <> nil then
    UserStorage.SaveComponent(gsIBGrid, gsIBGrid.SaveToStream);
end;

procedure TdlgAccountCycleForm.pmAddPopup(Sender: TObject);
begin
  pmAdd.Items.Clear;
  FillAnaliticMenuItem(pmAdd, pmAdd.Items, ClickAnal, nil, ClickAnalCycle, nil);
end;

procedure TdlgAccountCycleForm.ClickAnal(Sender: TObject);
var
  D: TfrmAnalytics;
begin
  D := TfrmAnalytics.Create(nil);
  try
    D.Block := Block;
    if D.ShowModal = idOk then
    begin
      if FActiveEdit.Text > '' then
      begin
        if FActiveEdit.Text[Length(FActiveEdit.Text)] = ';' then
          FActiveEdit.Text := FActiveEdit.Text + D.Analytics
        else
          FActiveEdit.Text := FActiveEdit.Text + ';' + D.Analytics;
      end else
        FActiveEdit.Text := D.Analytics;
    end;
  finally
    D.Free
  end;
end;

procedure TdlgAccountCycleForm.ClickAnalCycle(Sender: TObject);
var
  S: string;
begin
  S := Format('%s.%s',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName,
    TMenuItem(Sender).Caption]);
  if FActiveEdit.Text > '' then
  begin
    if FActiveEdit.Text[Length(FActiveEdit.Text)] = ';' then
      FActiveEdit.Text := FActiveEdit.Text + S
    else
      FActiveEdit.Text := FActiveEdit.Text + ';' + S;
  end else
    FActiveEdit.Text := S;
end;

end.
