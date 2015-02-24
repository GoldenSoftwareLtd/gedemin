unit tr_dlgChooseEntryVar_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, gsDBGrid, gsIBGrid, ExtCtrls, Db, IBCustomDataSet, dmDatabase_unit,
  StdCtrls;

type
  TdlgChooseEntryVar = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    gsibgrVariable: TgsIBGrid;
    ibdsFields: TIBDataSet;
    dsFields: TDataSource;
    ibdsFieldsLNAME: TIBStringField;
    ibdsFieldsLSHORTNAME: TIBStringField;
    ibdsFieldsRLNAME: TIBStringField;
    ibdsFieldsRLSHORTNAME: TIBStringField;
    ibdsFieldsFIELDNAME: TIBStringField;
    ibdsFieldsRELATIONNAME: TIBStringField;
    ibdsFieldsFT: TIBStringField;
    bOk: TButton;
    bCancel: TButton;
  private
    function GetVariable: String;
    { Private declarations }
  public
    { Public declarations }
    function SetupDialog(const aTransactionKey: Integer): Boolean;
    property Variable: String read GetVariable;
  end;

var
  dlgChooseEntryVar: TdlgChooseEntryVar;

implementation

{$R *.DFM}

{ TdlgChooseEntryVar }

function TdlgChooseEntryVar.GetVariable: String;
begin
  Result := '';
  ibdsFields.DisableControls;
  try
    ibdsFields.First;
    while not ibdsFields.EOF do
    begin
      if gsibgrVariable.CheckBox.RecordChecked then
      begin
        if Result > '' then
          Result := Result + '+';
        Result := Result + Trim(ibdsFields.FieldByName('rlshortname').AsString) + '_' +
          Trim(ibdsFields.FieldByName('lshortname').AsString);
      end;
      ibdsFields.Next;
    end;
  finally
    ibdsFields.EnableControls;
  end;
end;

function TdlgChooseEntryVar.SetupDialog(
  const aTransactionKey: Integer): Boolean;
begin
  ibdsFields.Params.ByName('TRTYPEKEY').AsInteger := aTransactionKey;
  ibdsFields.Open;
  Result := ShowModal = mrOk;
end;

end.
