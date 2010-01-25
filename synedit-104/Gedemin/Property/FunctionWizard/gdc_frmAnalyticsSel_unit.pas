unit gdc_frmAnalyticsSel_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, gsDBGrid, gsIBGrid, IBCustomDataSet, gdcBase,
  gdcContacts, StdCtrls, ExtCtrls, gd_Createable_Form, dmDataBase_unit,
  gsIBLookupComboBox, ActnList, gdcBaseInterface, at_classes;

type
  TfrmAnalyticSel = class(TCreateableForm)
    pnlAnalyticsSel: TPanel;
    ibcbAnalytics: TgsIBLookupComboBox;
    alMain: TActionList;
    actOk: TAction;
    actCancel: TAction;
    lAnalyticName: TLabel;
    pnlButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    cbNeedId: TCheckBox;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FField: TatRelationField;
    procedure SetAnalyticAlias(const Value: String);
    procedure SetAnalyticsKey(const Value: Integer);
    procedure SetAnalyticsRUID(const Value: string);
    function GetAnalyticAlias: String;
    function GetAnalyticsKey: Integer;
    function GetAnalyticsRUID: string;
    function GetCondition: string;
    procedure SetCondition(const Value: string);
    procedure SetField(const Value: TatRelationField);
  protected
    function DefaultListField: string; virtual;
    function DefaultListTable: string; virtual;
    function DefaultKeyField: string; virtual;
    function DefaultCaption: string; virtual;
    function DefaultCondition: string; virtual;
  public
    property AnalyticAlias: String read GetAnalyticAlias write SetAnalyticAlias;
    property AnalyticsKey: Integer read GetAnalyticsKey write SetAnalyticsKey;
    property AnalyticsRUID: string read GetAnalyticsRUID write SetAnalyticsRUID;

    property DataField: TatRelationField read FField write SetField;
    property Condition: string read GETCondition write SetCondition;
  end;

var
  frmAnalyticSel: TfrmAnalyticSel;

implementation

uses
  gd_Security;

{$R *.DFM}

{ TfrmAccountSel }

{ TfrmAccountSel }

procedure TfrmAnalyticSel.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmAnalyticSel.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmAnalyticSel.FormCreate(Sender: TObject);
begin
  ibcbAnalytics.ListTable := DefaultListTable;
  ibcbAnalytics.ListField := DefaultListField;
  ibcbAnalytics.KeyField := DefaultKeyField;
  ibcbAnalytics.Condition := DefaultCondition;
  lAnalyticName.Caption := DefaultCaption + ':';
end;

procedure TfrmAnalyticSel.SetAnalyticAlias(const Value: String);
begin
  ibcbAnalytics.Text := Value
end;

procedure TfrmAnalyticSel.SetAnalyticsKey(const Value: Integer);
begin
  ibcbAnalytics.CurrentKeyInt := Value;
end;

procedure TfrmAnalyticSel.SetAnalyticsRUID(const Value: string);
begin
  ibcbAnalytics.CurrentKeyInt := gdcBaseManager.GetIDByRUIDString(Value)
end;

function TfrmAnalyticSel.GetAnalyticAlias: String;
begin
  Result := ibcbAnalytics.Text
end;

function TfrmAnalyticSel.GetAnalyticsKey: Integer;
begin
  Result := ibcbAnalytics.CurrentKeyInt
end;

function TfrmAnalyticSel.GetAnalyticsRUID: string;
begin
  if not cbNeedId.Checked then
    Result := Format('%s', [gdcBaseManager.GetRUIDStringByID(GetAnalyticsKey)])
  else
    Result := Format('gdcBaseManager.GetIdByRUIDString("%s")',
      [gdcBaseManager.GetRUIDStringByID(GetAnalyticsKey)]);
end;

function TfrmAnalyticSel.GetCondition: string;
begin
  Result := ibcbAnalytics.Condition
end;

procedure TfrmAnalyticSel.SetCondition(const Value: string);
begin
  ibcbAnalytics.Condition := Value
end;

procedure TfrmAnalyticSel.SetField(const Value: TatRelationField);
begin
  if FField <> Value then
  begin
    FField := Value;
    if (FField <> nil) and (FField.ReferencesField <> nil) then
    begin
      lAnalyticName.Caption := FField.LName + ':';
      ibcbAnalytics.Left := lAnalyticName.Left + lAnalyticName.Width + 3;
      ibcbAnalytics.Width := pnlAnalyticsSel.Width - ibcbAnalytics.Left - 3;
      ibcbAnalytics.ListTable := FField.References.RelationName;
      ibcbAnalytics.ListField := FField.References.ListField.FieldName;
      ibcbAnalytics.KeyField := FField.ReferencesField.FieldName;
    end else
    begin
      ibcbAnalytics.ListTable := '';
      ibcbAnalytics.ListField := '';
      ibcbAnalytics.KeyField := '';
    end;
  end;
end;

function TfrmAnalyticSel.DefaultCaption: string;
begin
  Result := ''
end;

function TfrmAnalyticSel.DefaultKeyField: string;
begin
  Result := ''
end;

function TfrmAnalyticSel.DefaultListField: string;
begin
  Result := ''
end;

function TfrmAnalyticSel.DefaultListTable: string;
begin
  Result := '';
end;

function TfrmAnalyticSel.DefaultCondition: string;
begin
  Result := ''
end;

end.
