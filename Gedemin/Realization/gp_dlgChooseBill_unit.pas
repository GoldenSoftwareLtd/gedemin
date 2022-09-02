// ShlTanya, 11.03.2019

unit gp_dlgChooseBill_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ToolWin, ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid,
  flt_sqlFilter, Db, IBCustomDataSet, dmDatabase_unit, IBDatabase, ActnList,
  gd_security_OperationConst, gd_security;

type
  Tgp_dlgChooseBill = class(TForm)
    Panel1: TPanel;
    gsibgrMain: TgsIBGrid;
    cbMain: TControlBar;
    tbMain: TToolBar;
    tbtNew: TToolButton;
    pmFilter: TPopupMenu;
    ibdsMain: TIBDataSet;
    dsMain: TDataSource;
    gsqfChooseBill: TgsQueryFilter;
    IBTransaction: TIBTransaction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    function GetBillCount: Integer;
    function GetBillKey(Index: Integer): TID;
    { Private declarations }
  public
    { Public declarations }
    property BillCount: Integer read GetBillCount;
    property BillKey[Index: Integer]: TID read GetBillKey; 
  end;

var
  gp_dlgChooseBill: Tgp_dlgChooseBill;

implementation

{$R *.DFM}

uses
  Storages;

procedure Tgp_dlgChooseBill.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgp_dlgChooseBill.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgp_dlgChooseBill.FormCreate(Sender: TObject);
begin
  IBTransaction.StartTransaction;
  
  SetTID(ibdsMain.ParamByName('dt'), GD_DOC_BILL);
  SetTID(ibdsMain.ParamByName('ck'), IBLogin.CompanyKey);
  ibdsMain.Open;

  UserStorage.LoadComponent(gsibgrMain, gsibgrMain.LoadFromStream);
end;

function Tgp_dlgChooseBill.GetBillCount: Integer;
begin
  Result := gsibgrMain.CheckBox.CheckCount;
end;

function Tgp_dlgChooseBill.GetBillKey(Index: Integer): TID;
begin
  if Index < BillCount then
    Result := gsibgrMain.CheckBox.IntCheck[Index]
  else
    Result := -1;  
end;

procedure Tgp_dlgChooseBill.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(gsibgrMain, gsibgrMain.SaveToStream);
end;

end.
