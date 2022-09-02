// ShlTanya, 11.03.2019

unit gp_dlgChooseField_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls,
  IBDatabase, dmDatabase_unit, IBSQL, at_classes;

type
  TdlgChooseField = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    ibdsField: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsFields: TDataSource;
    gsdbgrFields: TgsDBGrid;
    ibdsFieldFIELDNAME: TIBStringField;
    ibdsFieldRELATIONNAME: TIBStringField;
    ibdsFieldLSHORTNAME: TIBStringField;
    ibdsFieldLNAME: TIBStringField;
    ibdsFieldLTABLENAME: TIBStringField;
    cbUseGroupKey: TCheckBox;
    sgrGroupSelect: TStringGrid;
    Label1: TLabel;
    gsdbgrRelField: TgsDBGrid;
    lRef: TLabel;
    ibdsRelField: TIBDataSet;
    IBStringField1: TIBStringField;
    IBStringField2: TIBStringField;
    IBStringField3: TIBStringField;
    IBStringField4: TIBStringField;
    IBStringField5: TIBStringField;
    dsRelField: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure ibdsFieldAfterScroll(DataSet: TDataSet);
  private
    function GetVariable: String;
    { Private declarations }
  public
    { Public declarations }
    property Variable: String read GetVariable;
  end;

var
  dlgChooseField: TdlgChooseField;

implementation

{$R *.DFM}

uses
  Storages;

{ TdlgChooseField }

function TdlgChooseField.GetVariable: String;
begin
  if ibdsField.FieldByName('LShortName').AsString > '' then
  begin
    if not ibdsRelField.Active then
    begin
      if not cbUseGroupKey.Enabled or not cbUseGroupKey.Checked or
         (sgrGroupSelect.Cells[1, sgrGroupSelect.Row] = '')
      then
        Result := Format('[%s(%s%%%s)]', [Trim(ibdsField.FieldByName('LShortName').AsString),
          Trim(ibdsField.FieldByName('FieldName').AsString),
          Trim(ibdsField.FieldByName('RelationName').AsString)])
      else
        Result := Format('[%s(%s%%%s''%s)]', [Trim(ibdsField.FieldByName('LShortName').AsString),
          Trim(ibdsField.FieldByName('FieldName').AsString),
          Trim(ibdsField.FieldByName('RelationName').AsString),
          sgrGroupSelect.Cells[1, sgrGroupSelect.Row]])
    end
    else
      Result := Format('[%s_%s(%s%%%s)/%s%%%s\]', [Trim(ibdsField.FieldByName('LShortName').AsString),
        Trim(ibdsRelField.FieldByName('LShortName').AsString),
        Trim(ibdsField.FieldByName('FieldName').AsString),
        Trim(ibdsField.FieldByName('RelationName').AsString),
        Trim(ibdsRelField.FieldByName('FieldName').AsString),
        Trim(ibdsRelField.FieldByName('RelationName').AsString)
        ]);
  end
  else
    Result := '';
end;

procedure TdlgChooseField.FormCreate(Sender: TObject);
var
  ibsql: TIBSQL;
  CountGroup, i: Integer;
  GroupKey: TID;
  NameGroup: String;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  sgrGroupSelect.ColWidths[1] := 0;
  CountGroup := GlobalStorage.ReadInteger('realizationoption', 'countprintgroup', 0);
  if CountGroup > 0 then
  begin
    sgrGroupSelect.RowCount := CountGroup + 1;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text := 'SELECT name FROM gd_goodgroup WHERE id = :gk';
      ibsql.Prepare;
      for i:= 1 to CountGroup do
      begin
        GroupKey := GlobalStorage.ReadInteger('realizationoption',
          Format('printgroupkey%d', [i]), 0);

        SetTID(ibsql.ParamByName('gk'), GroupKey);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 1 then
          NameGroup := ibsql.Fields[0].AsString
        else
          NameGroup := '';
        ibsql.Close;

        sgrGroupSelect.Cells[0, i] := NameGroup;
        sgrGroupSelect.Cells[1, i] := TID2S(GroupKey);
      end;
    finally
      ibsql.Free;
    end;
  end;

  cbUseGroupKey.Visible := CountGroup > 0;
  sgrGroupSelect.Visible := CountGroup > 0;
  ibdsField.Open;
end;

procedure TdlgChooseField.ibdsFieldAfterScroll(DataSet: TDataSet);
var
  R: TatRelationField;
begin
  cbUseGroupKey.Enabled :=
    UpperCase(Trim(ibdsField.FieldByName('RELATIONNAME').AsString)) = 'GD_DOCREALPOS';
  sgrGroupSelect.Enabled :=
    UpperCase(Trim(ibdsField.FieldByName('RELATIONNAME').AsString)) = 'GD_DOCREALPOS';

  R := atDatabase.FindRelationField(ibdsField.FieldByName('RELATIONNAME').AsString,
    ibdsField.FieldByName('FIELDNAME').AsString);
  if Assigned(R) and Assigned(R.References) then
  begin
    ibdsRelField.Close;
    gsdbgrRelField.Enabled := True;
    lRef.Enabled := True;
    ibdsRelField.ParamByName('rn').AsString := R.References.RelationName;
    ibdsRelField.Open;
  end
  else
  begin
    gsdbgrRelField.Enabled := False;
    lRef.Enabled := False;
    ibdsRelField.Close;
  end;
end;

initialization
  dlgChooseField := nil;

end.
