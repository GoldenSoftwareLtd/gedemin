{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgPaymentRoll_unit.pas

  Abstract

    Window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.

--}

unit ctl_dlgPaymentRoll_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, IBDatabase, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ActnList, StdCtrls, flt_sqlFilter, Menus, FrmPlSvr,
  gd_createable_form, gsReportManager;

type
  Tctl_dlgPaymentRoll = class(TCreateableForm)
    btnMakePaymentRoll: TButton;
    btnCancel: TButton;
    alPaymentRoll: TActionList;
    actMakePaymentRoll: TAction;
    actCancel: TAction;
    ibgrdReceipts: TgsIBGrid;
    ibtrReceipts: TIBTransaction;
    ibdsReceipts: TIBDataSet;
    dsReceipts: TDataSource;
    btnFilter: TButton;
    actFilter: TAction;
    pmFilter: TPopupMenu;
    qfReceipts: TgsQueryFilter;
    pmPrint: TPopupMenu;
    FormPlaceSaver: TFormPlaceSaver;
    gsMainReportManager: TgsReportManager;
    pmMain: TPopupMenu;
    actChooseAll: TAction;
    actChooseClear: TAction;

    procedure actFilterExecute(Sender: TObject);
    procedure actMakePaymentRollExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actChooseAllExecute(Sender: TObject);
    procedure actChooseClearExecute(Sender: TObject);

  protected
    function  Get_SelectedKey: OleVariant; override;

  private

  public

  end;

var
  ctl_dlgPaymentRoll: Tctl_dlgPaymentRoll;

implementation

uses dmDataBase_unit;

{$R *.DFM}

procedure Tctl_dlgPaymentRoll.actFilterExecute(Sender: TObject);
var
  P: TPoint;
begin
  P := btnFilter.ClientToScreen(Point(0, btnFilter.Height));
  pmFilter.Popup(P.X, P.Y);
end;

procedure Tctl_dlgPaymentRoll.actMakePaymentRollExecute(Sender: TObject);
var
  P: TPoint;
begin
  P := btnMakePaymentRoll.ClientToScreen(Point(0, btnMakePaymentRoll.Height));
  pmPrint.Popup(P.X, P.Y);
end;

procedure Tctl_dlgPaymentRoll.actCancelExecute(Sender: TObject);
begin
//
end;

procedure Tctl_dlgPaymentRoll.FormCreate(Sender: TObject);
begin
  if not ibtrReceipts.Active then
    ibtrReceipts.StartTransaction;

  ibdsReceipts.Open;
end;

function Tctl_dlgPaymentRoll.Get_SelectedKey: OleVariant;
var
  Values: array of Variant;
  I: Integer;
begin
  with ibgrdReceipts.CheckBox do
  begin
    SetLength(Values, CheckCount);
    for I := 0 to CheckCount - 1 do
      Values[I] := IntCheck[I];
  end;

  Result := VarArrayOf(Values);
end;

procedure Tctl_dlgPaymentRoll.actChooseAllExecute(Sender: TObject);
var
  Bookmark: String;
begin
  Bookmark := ibdsReceipts.Bookmark;
  ibdsReceipts.DisableControls;
  try
    ibgrdReceipts.CheckBox.Clear;
    ibdsReceipts.First;
    while not ibdsReceipts.EOF do
    begin
      ibgrdReceipts.CheckBox.AddCheck(ibdsReceipts.FieldByName('documentkey').AsString);
      ibdsReceipts.Next;
    end;
  finally
    ibdsReceipts.Bookmark := Bookmark;
    ibdsReceipts.EnableControls;
  end;
end;

procedure Tctl_dlgPaymentRoll.actChooseClearExecute(Sender: TObject);
begin
  ibgrdReceipts.CheckBox.Clear;
  ibgrdReceipts.Refresh;
end;

end.

