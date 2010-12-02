unit wiz_frBalanceOffTrEntry_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_TrPosEntryEditFrame_Unit, ActnList, Menus, ComCtrls, TB2Item,
  TB2Dock, TB2Toolbar, ExtCtrls, StdCtrls, BtnEdit, wiz_FunctionBlock_unit,
  gdcBaseInterface, IBSQL, gdcConstants, wiz_Strings_unit, at_classes,
  gdc_frmAnalyticsSel_unit, wiz_frQuantity_unit, wiz_frAnalytics_unit;

type
  TfrBalanceOffTrEntry = class(TfrTrPosEntryEditFrame)
    beCompany: TBtnEdit;
    lDate: TLabel;
    beDate: TBtnEdit;
    lbDescr: TLabel;
    beEntryDescription: TBtnEdit;
    pmCompany: TPopupMenu;
    lbCompany: TLabel;
    procedure beCompanyBtnOnClick(Sender: TObject);
    procedure pmCompanyPopup(Sender: TObject);
    procedure beCompanyChange(Sender: TObject);
    procedure beDateBtnOnClick(Sender: TObject);
  private
    { Private declarations }
    FCompanyKey: Integer;

    procedure ClickCompany(Sender: TObject);
    procedure ClickExpression(Sender: TObject);
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    { Public declarations }
    procedure SaveChanges; override;
  end;

var
  frBalanceOffTrEntry: TfrBalanceOffTrEntry;

implementation

{$R *.DFM}

{ TfrBalanceOffTrEntry }

procedure TfrBalanceOffTrEntry.SaveChanges;
begin
  inherited;
  with FBlock as TBalanceOffTrEntryPositionBlock do
  begin
    if FCompanyKey > 0 then
    begin
      CompanyRUID := gdcBaseManager.GetRUIDStringById(FCompanyKey);
    end else
    begin
      CompanyRUID := beCompany.Text;
    end;

    EntryDate := beDate.Text;
    EntryDescription := beEntryDescription.Text;
  end;
end;

procedure TfrBalanceOffTrEntry.SetBlock(const Value: TVisualBlock);
var
  SQL: TIBSQL;
  Id: Integer;
begin
  inherited;
  with FBlock as TBalanceOffTrEntryPositionBlock do
  begin
    if CheckRuid(CompanyRUID) then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        SQl.SQl.Text := 'SELECT name FROM gd_contact WHERE id = :id';
        ID := gdcBaseManager.GetIDByRUIDString(CompanyRUID);
        SQL.ParamByName(fnId).AsInteger := Id;
        SQl.ExecQuery;
        beCompany.Text := SQL.FieldByName(fnName).AsString;
        FCompanyKey := Id;
      finally
        SQl.Free;
      end;
    end else
    begin
      FCompanyKey := 0;
      beCompany.Text := CompanyRUID;
    end;

    beDate.Text := EntryDate;
    beEntryDescription.Text := EntryDescription;
  end;
end;

procedure TfrBalanceOffTrEntry.beCompanyBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmCompany);
end;

procedure TfrBalanceOffTrEntry.pmCompanyPopup(Sender: TObject);
var
  MI: TMenuItem;
begin
  pmCompany.Items.Clear;
  MI := TMenuItem.Create(pmCompany);
  MI.Caption := RUS_COMPANY;
  MI.OnClick := ClickCompany;
  pmCompany.Items.Add(MI);

  MI := TMenuItem.Create(pmCompany);
  MI.Caption := '-';
  pmCompany.Items.Add(MI);

  MI := TMenuItem.Create(pmCompany);
  MI.Caption := RUS_EXPRESSION;
  MI.OnClick := ClickExpression;
  pmCompany.Items.Add(MI);
end;

procedure TfrBalanceOffTrEntry.beCompanyChange(Sender: TObject);
begin
  FCompanyKey := 0;
end;

procedure TfrBalanceOffTrEntry.beDateBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

procedure TfrBalanceOffTrEntry.ClickCompany(Sender: TObject);
var
  F: TatRelationField;
  D: TfrmAnalyticSel;
begin
  if FActiveEdit <> nil then
  begin
    F := atDatabase.FindRelationField(AC_RECORD, fnCompanyKey);
    if F <> nil then
    begin
      D := TfrmAnalyticSel.Create(nil);
      try
        D.DataField := F;
        if FCompanyKey > 0 then
          D.AnalyticsKey := FCompanyKey;

        if D.ShowModal = mrOk then
        begin
          FActiveEdit.Text := D.AnalyticAlias;
          FCompanyKey := D.AnalyticsKey;
        end;
      finally
        D.Free;
      end;
    end;
  end;
end;

procedure TfrBalanceOffTrEntry.ClickExpression(Sender: TObject);
begin
  FActiveEdit.Text := FBlock.EditExpression(FActiveEdit.Text, FBlock);
end;

end.
