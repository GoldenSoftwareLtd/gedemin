unit gdc_frmAccountSel_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, gsDBGrid, gsIBGrid, IBCustomDataSet, gdcBase,
  gdcContacts, StdCtrls, ExtCtrls, gd_Createable_Form, dmDataBase_unit,
  gsIBLookupComboBox, ActnList, gdc_frmAnalyticsSel_unit, gdcConstants;

type
  TfrmAccountSel = class(TfrmAnalyticSel)
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    function GetAccountAlias: String;
  protected
    function DefaultListField: string; override;
    function DefaultListTable: string; override;
    function DefaultKeyField: string; override;
    function DefaultCaption: string; override;
    function DefaultCondition: string; override;
  public
    property AccountAlias: String read GetAccountAlias;
  end;

var
  frmAccountSel: TfrmAccountSel;

implementation

uses
  gd_Security;

{$R *.DFM}

{ TfrmAccountSel }

{ TfrmAccountSel }

function TfrmAccountSel.GetAccountAlias: String;
begin
  Result := ibcbAnalytics.Text;
end;

procedure TfrmAccountSel.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmAccountSel.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function TfrmAccountSel.DefaultCaption: string;
begin
  Result := '—чет'
end;

function TfrmAccountSel.DefaultCondition: string;
begin
  Result := '(ac.lb > ap.lb and ac.rb < ap.rb) or (ac.lb = ap.lb and ac.rb = ap.rb)';
end;

function TfrmAccountSel.DefaultKeyField: string;
begin
  Result := fnID;
end;

function TfrmAccountSel.DefaultListField: string;
begin
  Result := fnAlias
end;

function TfrmAccountSel.DefaultListTable: string;
begin
  Result :=  'ac_account ac ' +
    'join ac_companyaccount ca ON ' +
    GetCompCondition('ca.companykey') + ' and ca.isactive = 1 ' +
    'join ac_account ap ON ap.id = ca.accountkey';
end;

end.
