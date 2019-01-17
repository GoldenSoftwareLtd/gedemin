unit wiz_dlgCustumAnalytic_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, gsIBLookupComboBox, ActnList, IBDatabase, at_classes,
  gdcBase, TB2Item, TB2Dock, TB2Toolbar, gdcBaseInterface, gd_ClassList,
  Contnrs;

type
  TCustomAnalyticForm = class(TForm)
    bCancel: TButton;
    bOK: TButton;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    pnl: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    cbNeedId: TCheckBox;
    cbAnalyticValue: TgsIBLookupComboBox;
    Bevel1: TBevel;
    Transaction: TIBTransaction;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    edBO: TEdit;
    btnSelectClass: TButton;
    actSelectClass: TAction;

    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actSelectClassExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);

  private
    FC: TgdcFullClassName;

    function GetValue: String;

  public
    property Value: String read GetValue;
  end;

function CustomAnalyticForm: TCustomAnalyticForm;

implementation

{$R *.DFM}

uses
  gd_dlgClassList_unit;

var
  _CustomAnalyticForm: TCustomAnalyticForm;

function CustomAnalyticForm: TCustomAnalyticForm;
begin
  if _CustomAnalyticForm = nil then
    _CustomAnalyticForm := TCustomAnalyticForm.Create(nil);
  Result := _CustomAnalyticForm;
end;

procedure TCustomAnalyticForm.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TCustomAnalyticForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TCustomAnalyticForm.GetValue: String;
var
  RUID: String;
begin
  if cbAnalyticValue.Enabled then
  begin
    RUID := '"' + gdcBaseManager.GetRUIDStringById(cbAnalyticValue.CurrentKeyInt) + '"';
    if cbNeedId.Checked then
      Result := 'gdcBaseManager.GetIdByRUIDString(' + RUID + ')'
    else
      Result := RUID;
  end else
    Result := '';
end;

procedure TCustomAnalyticForm.actSelectClassExecute(Sender: TObject);
begin
  with Tgd_dlgClassList.Create(nil) do
  try
    if SelectModal('', FC) then
    begin
      edBO.Text := FC.gdClassName + FC.SubType;

      cbAnalyticValue.Condition := '';
      cbAnalyticValue.gdClassName := '';
      cbAnalyticValue.ListTable := '';
      cbAnalyticValue.ListField := '';
      cbAnalyticValue.KeyField :=  '';
      cbAnalyticValue.Fields := '';
      cbAnalyticValue.Text := '';
      cbAnalyticValue.SubType := '';

      cbAnalyticValue.gdClassName := FC.gdClassName;
      cbAnalyticValue.SubType := FC.SubType;
      cbAnalyticValue.Enabled := True;
    end;
  finally
    Free;
  end;
end;

procedure TCustomAnalyticForm.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := Value > '';
end;

initialization

finalization
  FreeAndNil(_CustomAnalyticForm);
end.
