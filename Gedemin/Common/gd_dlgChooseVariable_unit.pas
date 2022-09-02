// ShlTanya, 24.02.2019

unit gd_dlgChooseVariable_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls, Db,
  IBCustomDataSet, IBDatabase, dmDatabase_unit;

type
  TdlgChooseVariable = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    bOk: TButton;
    bCancel: TButton;
    ibdsRelationField: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsRelationField: TDataSource;
    ibdsRelationFieldLNAME: TIBStringField;
    ibdsRelationFieldLSHORTNAME: TIBStringField;
    ibdsRelationFieldLTABLENAME: TIBStringField;
    ibdsRelationFieldLTABLESHORTNAME: TIBStringField;
    ibdsRelationFieldFIELDNAME: TIBStringField;
    ibdsRelationFieldRELATIONNAME: TIBStringField;
    ibdsRelationFieldLVAR: TIBStringField;
    Panel3: TPanel;
    Label1: TLabel;
    ibgrVariable: TgsIBGrid;
    Splitter1: TSplitter;
    pTax: TPanel;
    Label2: TLabel;
    ibgrTax: TgsIBGrid;
    ibdsTax: TIBDataSet;
    dsTax: TDataSource;
  private
    function GetVariable: String;
    { Private declarations }
  public
    { Public declarations }
    property Variable: String read GetVariable;
    function Setup(RelationNames: array of String; ShowTax: Boolean = True): Boolean;
  end;

var
  dlgChooseVariable: TdlgChooseVariable;

implementation

{$R *.DFM}

{ TdlgChooseVariable }

function TdlgChooseVariable.GetVariable: String;
var
  i: Integer;
begin
  Result := '';
  for i:= 0 to ibgrVariable.CheckBox.CheckCount - 1 do
  begin
    Result := Result + ibgrVariable.CheckBox.StrCheck[i];
    if i < ibgrVariable.CheckBox.CheckCount - 1 then
      Result := Result + '+';
  end;
  if (Result > '') and (ibgrTax.CheckBox.CheckCount > 0) then
    Result := Result + '+';
  for i:= 0 to ibgrTax.CheckBox.CheckCount - 1 do
  begin
    Result := Result + ibgrTax.CheckBox.StrCheck[i];
    if i < ibgrTax.CheckBox.CheckCount - 1 then
      Result := Result + '+';
  end;
end;

function TdlgChooseVariable.Setup(RelationNames: array of String;
  ShowTax: Boolean = True): Boolean;
var
  i: Integer;
  S: String;
begin
  if High(RelationNames) - Low(RelationNames) >= 0
  then
  begin
    S := ' WHERE r.RelationName IN (';
    for i:= Low(RelationNames) to High(RelationNames) do
    begin
      S := S + '''' + UpperCase(RelationNames[i]) + '''';
      if i < High(RelationNames) then 
        S := S + ',';
    end;
    S := S + ')';
    ibdsRelationField.SelectSQL.Text :=
      'SELECT ' + #13#10 +
      '  rf.LName, ' + #13#10 +
      '  rf.LShortName, ' + #13#10 +
      '  r.LName as LTableName, ' + #13#10 +
      '  r.LShortName as LTableShortName, ' + #13#10 +
      '  rf.FieldName, ' + #13#10 +
      '  r.RelationName, ' + #13#10 +
      '   r.LShortName || ''_'' || rf.LShortName as LVar ' + #13#10 +
      'FROM ' + #13#10 +
      '  at_relations r JOIN at_relation_fields rf ON r.relationname = rf.relationname ' + #13#10 +
      S;
  end;
  ibdsRelationField.Open;
  if ShowTax then
    ibdsTax.Open
  else
    pTax.Height := 0;  
  Result := ShowModal = mrOk;
end;

end.
