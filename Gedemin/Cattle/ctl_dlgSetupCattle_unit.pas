{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgSetupCattle_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgSetupCattle_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ActnList, IBDatabase, IBSQL, gdcConst;

type
  Tctl_dlgSetupCattle = class(TForm)
    btnClose: TButton;
    ActionList1: TActionList;
    actClose: TAction;
    Button1: TButton;
    Label1: TLabel;
    lblCattleBranch: TLabel;
    Label2: TLabel;
    Button2: TButton;
    Label3: TLabel;
    Button3: TButton;
    Bevel1: TBevel;
    actBranch: TAction;
    actFields: TAction;
    actReceiptFormula: TAction;
    ibsqlBranch: TIBSQL;
    ibtrSetup: TIBTransaction;
    lbTariff: TLabel;
    edTariff: TEdit;

    procedure actCloseExecute(Sender: TObject);
    procedure actBranchExecute(Sender: TObject);
    procedure actFieldsExecute(Sender: TObject);
    procedure actReceiptFormulaExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private

  public
    function Execute(Const ADate: TDate): Boolean;
  end;

var
  ctl_dlgSetupCattle: Tctl_dlgSetupCattle;

implementation

{$R *.DFM}

uses
  ctl_dlgSetupReceipt_unit, ctl_ChooseCattleBranch_unit,
  ctl_dlgSetupPrice_unit, dmDataBase_unit, ctl_CattleConstants_unit,
  Storages;

const
//Константа для рассчета транспортного тарифа
  cst_AutoTariff = 'AutoTariff';

procedure Tctl_dlgSetupCattle.actCloseExecute(Sender: TObject);
begin
//
end;

procedure Tctl_dlgSetupCattle.actBranchExecute(Sender: TObject);
begin
  with Tctl_ChooseCattleBranch.Create(Self) do
  try
    if Execute then
    begin
      if not ibtrSetup.Active then
        ibtrSetup.StartTransaction;

      with GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS) do
      try
        ibsqlBranch.ParamByName('ID').AsString :=
          ReadString(VALUE_CATTLEBRANCH, '0');
      finally
        GlobalStorage.CloseFolder(nil);
      end;

      ibsqlBranch.ExecQuery;

      if ibsqlBranch.RecordCount > 0 then
        lblCattleBranch.Caption := ibsqlBranch.FieldByName('NAME').AsString
      else
        lblCattleBranch.Caption := 'Не установлено';

      ibsqlBranch.Close;
      ibtrSetup.Commit;
    end;
  finally
    Free;
  end;
end;

procedure Tctl_dlgSetupCattle.actFieldsExecute(Sender: TObject);
begin
  with Tctl_dlgSetupPrice.Create(Self) do
  try
    Execute;
  finally
    Free;
  end;
end;

procedure Tctl_dlgSetupCattle.actReceiptFormulaExecute(Sender: TObject);
begin
  with Tctl_dlgSetupReceipt.Create(Self) do
  try
    Execute;
  finally
    Free;
  end;
end;

function Tctl_dlgSetupCattle.Execute(Const ADate: TDate): Boolean;
{var
  TransConst: TgdcConst;}

begin
  edTariff.Clear;
  lbTariff.Caption := 'Транспортный тариф на ' + DateToStr(ADate);
  //Считываем транспортный тариф для текущей записи
  {TransConst := TgdcConst.Create(Self);
  try}
    {edTariff.Text := TransConst.GetValue(cst_AutoTariff, ADate);}
    edTariff.Text := TgdcConst.QGetValueByNameAndDate(cst_AutoTariff, ADate);
  {finally
    TransConst.Free;
  end;}

  ShowModal;

  Result := True;
end;

procedure Tctl_dlgSetupCattle.FormCreate(Sender: TObject);
begin
  if not ibtrSetup.Active then
    ibtrSetup.StartTransaction;

  with GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS) do
  try
    ibsqlBranch.ParamByName('ID').AsString :=
      ReadString(VALUE_CATTLEBRANCH, '0');
    edTariff.Text := FloatToStr(ReadCurrency(VALUE_RECEIPT_CoeffTariff, Def_CoeffTariff));
  finally
    GlobalStorage.CloseFolder(nil);
  end;

  ibsqlBranch.ExecQuery;

  if ibsqlBranch.RecordCount > 0 then
    lblCattleBranch.Caption := ibsqlBranch.FieldByName('NAME').AsString
  else
    lblCattleBranch.Caption := 'Не установлено';

  ibsqlBranch.Close;
  ibtrSetup.Commit;
end;

end.
