{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module


  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}
unit wiz_dlgEntryEditForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_dlgEditFrom_unit, ActnList, StdCtrls, ExtCtrls, gsIBLookupComboBox,
  BtnEdit, wiz_FunctionBlock_unit, wiz_ExpressionEditorForm_unit, ComCtrls,
  Menus, AcctUtils, wiz_Strings_unit, gdcBaseInterface;

type
  TdlgEntryEditForm = class(TBlockEditForm)
    Label9: TLabel;
    Label8: TLabel;
    Label7: TLabel;
    Label6: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    beAnalDebit: TBtnEdit;
    beAnalCredit: TBtnEdit;
    beSum: TBtnEdit;
    gsiblCurr: TgsIBLookupComboBox;
    beSumCurr: TBtnEdit;
    tsAdditional: TTabSheet;
    Label10: TLabel;
    beBeginDate: TBtnEdit;
    Label11: TLabel;
    beEndDate: TBtnEdit;
    Label12: TLabel;
    beEntryDate: TBtnEdit;
    beDebit: TBtnEdit;
    beCredit: TBtnEdit;
    procedure beSumBtnOnClick(Sender: TObject);
    procedure beAnalDebitBtnOnClick(Sender: TObject);
    procedure beDebitBtnOnClick(Sender: TObject);
    procedure beDebitExit(Sender: TObject);
    procedure beDebitChange(Sender: TObject);
    procedure beCreditChange(Sender: TObject);
    procedure beCreditExit(Sender: TObject);
  private
    { Private declarations }
    FAccountPopupMenu: TAccountPopupMenu;
    FAnalPopupMenu: TAnalPopupMenu;

    FDebit, FCredit: Integer;
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
    procedure ClickAccount(Sender: TObject);
    procedure ClickAccountCicle(Sender: TObject);
    procedure ClickAnal(Sender: TObject);
    procedure ClickAnalCycle(Sender: TObject);
  public
    { Public declarations }
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  dlgEntryEditForm: TdlgEntryEditForm;

implementation
uses tax_frmAnalytics_unit, gdc_frmAccountSel_unit;
{$R *.DFM}

{ TdlgEntryEditForm }

function TdlgEntryEditForm.CheckOk: Boolean;
begin
  Result := inherited CheckOk;
  if Result then
    Result := beDebit.Text > '';
  if Result then
    Result := beCredit.Text > '';
  if Result  then
    Result := (Trim(beSum.Text) > '') or ((Trim(beSumCurr.Text) > '') and
      (gsiblCurr.CurrentKeyInt > 0)) and (beBeginDate.Text > '') and
      (beEndDate.Text > '') and (beEntryDate.Text > '');
end;

procedure TdlgEntryEditForm.SaveChanges;
begin
  inherited;
  with FBlock as TEntryBlock do
  begin
    Debit := GetAccount(beDebit.Text, FDebit);
    Credit := GetAccount(beCredit.Text, FCredit);
    AnalDebit := beAnalDebit.Text;
    AnalCredit := beAnalCredit.Text;
    Sum := beSum.Text;
    CurrRUID := gdcBaseManager.GetRUIDStringById(gsiblCurr.CurrentKeyInt);
    SumCurr := beSumCurr.Text;

    BeginDate := beBeginDate.Text;
    EndDate := beEndDate.Text;
    EntryDate := beEntryDate.Text;  
  end;
end;

procedure TdlgEntryEditForm.SetBlock(const Value: TVisualBlock);
var
  Id: Integer;
begin
  inherited;
  with FBlock as TEntryBlock do
  begin
    beDebit.Text := SetAccount(Debit, id);
    FDebit := id;
    beCredit.Text := SetAccount(Credit, id);
    FCredit := id;

    beAnalDebit.Text := AnalDebit;
    beAnalCredit.Text := AnalCredit;
    beSum.Text := Sum;
    gsiblCurr.CurrentKeyInt := gdcBaseManager.GetIdByRUIDString(CurrRUID);
    beSumCurr.Text := SumCurr;

    beBeginDate.Text := BeginDate;
    beEndDate.Text := EndDate;
    beEntryDate.Text := EntryDate;
  end;
end;

procedure TdlgEntryEditForm.beSumBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

procedure TdlgEntryEditForm.beAnalDebitBtnOnClick(Sender: TObject);
begin
  if FAnalPopupMenu = nil then
  begin
    FAnalPopupMenu := TAnalPopupMenu.Create(self);
    FAnalPopupMenu.OnClickAnal := ClickAnal;
    FAnalPopupMenu.OnClickAnalCycle := ClickAnalCycle;
  end;
  beClick(Sender, FAnalPopupMenu);
end;

procedure TdlgEntryEditForm.beDebitBtnOnClick(Sender: TObject);
begin
  if FAccountPopupMenu = nil then
  begin
    FAccountPopupMenu := TAccountPopupMenu.Create(self);
    FAccountPopupMenu.OnClickAccount := ClickAccount;
    FAccountPopupMenu.OnClickAccountCycle := ClickAccountCicle;
  end;
  beClick(Sender, FAccountPopupMenu);
end;

procedure TdlgEntryEditForm.ClickAccount(Sender: TObject);
var
  S: string;
  RUID: String;
begin
  if FActiveEdit <> nil then
  begin
    S := FActiveEdit.Text;
    if FActiveEdit = beDebit then
    begin
      try
        RUID := gdcBaseManager.GetRUIDStringById(FDebit);
      except
        RUID := '';
      end;
      MainFunction.OnClickAccount(S, Ruid);
      FActiveEdit.Text := S;
      try
        FDebit := gdcBaseManager.GetIdByRUIDString(RUID);
      except
        FDebit := 0;
      end;
    end else
    begin
      try
        RUID := gdcBaseManager.GetRUIDStringById(FCredit);
      except
        RUID := '';
      end;
      MainFunction.OnClickAccount(S, RUID);
      FActiveEdit.Text := S;
      try
        FCredit := gdcBaseManager.GetIdByRUIDString(RUID);
      except
        FCRedit := 0;
      end;
    end;
  end;
end;

procedure TdlgEntryEditForm.ClickAccountCicle(Sender: TObject);
begin
  if FActiveEdit <> nil then
  begin
    FActiveEdit.Text := TAccountCycleBlock(TMenuItem(Sender).Tag).BlockName + '.Account';
  end;
end;

procedure AddAnal(Edit: TBtnEdit; AddedText: string);
begin
  Edit.Text := Trim(Edit.Text);
  if Edit.Text > '' then
  begin
    if Edit.Text[Length(Edit.Text)] = ';' then
      Edit.Text := Edit.Text + AddedText
    else
      Edit.Text := Edit.Text + ';' + AddedText;
  end else
    Edit.Text := AddedText;
end;

procedure TdlgEntryEditForm.ClickAnal(Sender: TObject);
var
  D: TfrmAnalytics;
begin
  if FActiveEdit <> nil then
  begin
    D := TfrmAnalytics.Create(nil);
    try
      if ShowModal = idOk then
        AddAnal(FActiveEdit, D.Analytics);
    finally
      D.Free
    end;
  end;
end;

procedure TdlgEntryEditForm.ClickAnalCycle(Sender: TObject);
begin
 if FActiveEdit <> nil then
 begin
   AddAnal(FActiveEdit, Format('%s.%s',
    [TVisualBlock(TMenuItem(Sender).Tag).BlockName, TMenuItem(Sender).Caption]));
 end;
end;

procedure TdlgEntryEditForm.beDebitExit(Sender: TObject);
begin
  if not MainFunction.CheckAccount(TBtnEdit(Sender).Text, FDebit) then
  begin
    ShowMessage(RUS_INVALIDACCOUNT);
    Windows.SetFocus(TWinControl(Sender).Handle);
  end;
end;

procedure TdlgEntryEditForm.beDebitChange(Sender: TObject);
begin
  FDebit := 0;
end;

procedure TdlgEntryEditForm.beCreditChange(Sender: TObject);
begin
  FCredit := 0;
end;

procedure TdlgEntryEditForm.beCreditExit(Sender: TObject);
begin
  if not MainFunction.CheckAccount(TBtnEdit(Sender).Text, FCredit) then
  begin
    ShowMessage(RUS_INVALIDACCOUNT);
    Windows.SetFocus(TWinControl(Sender).Handle);
  end;
end;

end.
