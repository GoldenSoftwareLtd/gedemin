unit tr_dlgSetCondValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  flt_sqlFilter, ActnList, Menus, Db, IBCustomDataSet, StdCtrls, Grids,
  DBGrids, gsDBGrid, gsIBGrid, Mask, ExtCtrls, dmDatabase_unit, tr_TransactionType_unit,
  IBHeader, gsIBLookupComboBox, IBSQL;

type
  TdlgSetCondValue = class(TForm)
    nValue: TNotebook;
    bOk: TButton;
    bCancel: TButton;
    medValue: TMaskEdit;
    ibdsReferency: TIBDataSet;
    dsReferency: TDataSource;
    gsibgrReferency: TgsIBGrid;
    Label2: TLabel;
    cbCond: TComboBox;
    Label3: TLabel;
    cbCharCond: TComboBox;
    medChar: TMaskEdit;
    pMenu: TPopupMenu;
    ActionList1: TActionList;
    actSelectAll: TAction;
    actDeleteSel: TAction;
    actInvert: TAction;
    bSelectAll: TButton;
    bDeleteSel: TButton;
    bInvert: TButton;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    gsQueryFilter: TgsQueryFilter;
    procedure actSelectAllExecute(Sender: TObject);
    procedure actDeleteSelExecute(Sender: TObject);
    procedure actInvertExecute(Sender: TObject);
  private
    { Private declarations }
    FFieldType: Integer;
    FRefTable: String;
    FRefField: String;
    function GetValue: String;
    procedure SetPage;
    function MakeCharValue: String;
    function MakeNumberValue: String;
    function MakeReferencyValue(const isCode: Boolean): String;
    procedure SetValue(const Value: String);
    function GetTextValue: String;
  public
    { Public declarations }
    procedure SetupDialog(const aFieldType: Integer; const aRefTable,
      aRefField, aValue: String);
    property Value: String read GetValue write SetValue;
    property TextValue: String read GetTextValue;
  end;

var
  dlgSetCondValue: TdlgSetCondValue;

implementation

{$R *.DFM}

{ TdlgSetCondValue }

procedure TdlgSetCondValue.SetupDialog(const aFieldType: Integer;
  const aRefTable, aRefField, aValue: String);
begin
  FFieldType := aFieldType;
  FRefTable := aRefTable;
  FRefField := Trim(aRefField);
  SetPage;
  Value := aValue;  
end;

procedure TdlgSetCondValue.SetPage;
var
  ibsql: TIBSQL;
begin
  { TODO 1 -oденис -cпросто : Лучьше это сделать через at_ стурктуру }
  if FRefTable > '' then
  begin
    if FrefField = '' then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := ibdsReferency.Transaction;
        ibsql.SQL.Text :=
          Format(
            'SELECT rdb$field_name FROM rdb$relation_fields ' +
            'WHERE rdb$field_position = ' +
            '(SELECT MIN(rdb$field_position) FROM ' +
            '  rdb$relation_fields rf JOIN rdb$fields f ON ' +
            '  rf.rdb$field_source = f.rdb$field_name AND ' +
            '  f.rdb$field_type = 37 AND ' +
            '  f.rdb$field_length > 20 AND ' +
            '  rf.rdb$relation_name = ''%0:s'') AND ' +
            'rdb$relation_name = ''%0:s''',
            [FRefTable]);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 1 then
          FrefField := ibsql.Fields[0].AsString
        else
        begin
          ibsql.SQL.Text :=
            Format(
              'SELECT rdb$field_name FROM rdb$relation_fields ' +
              'WHERE rdb$field_position = ' +
              '(SELECT MIN(rdb$field_position) FROM ' +
              '  rdb$relation_fields rf JOIN rdb$fields f ON ' +
              '  rf.rdb$field_source = f.rdb$field_name AND ' +
              '  f.rdb$field_type = 37 AND ' +
              '  rf.rdb$relation_name = ''%0:s'') AND ' +
              'rdb$relation_name = ''%0:s''',
              [FRefTable]);
          ibsql.ExecQuery;
          if ibsql.RecordCount = 1 then
            FrefField := ibsql.Fields[0].AsString
        end;
        ibsql.Close;
      finally
        ibsql.Free;
      end;
    end;
    nValue.PageIndex := 2;
    bSelectAll.Visible := True;
    bDeleteSel.Visible := True;
    bInvert.Visible := True;

    if FrefField > '' then
    begin
      ibdsReferency.SelectSQL.Text := Format('SELECT r.ID, r.%s FROM %s r',
        [FrefField, FRefTable]);
      ibdsReferency.Open;
      ibdsReferency.FieldByName('ID').Visible := False;
      gsibgrReferency.CheckBox.FieldName := 'ID';
      gsibgrReferency.CheckBox.DisplayField := Trim(FRefField);
      gsibgrReferency.CheckBox.Visible := True;
    end;
  end;
  if (FRefField = '') then
  begin

    case FFieldType of
    blr_short,
    blr_long,
    blr_quad,
    blr_float,
    blr_double,
    blr_d_float,
    blr_int64:
      begin
        nValue.PageIndex := 0;
        cbCond.ItemIndex := 0;
      end;  
    blr_timestamp,
    blr_sql_date,
    blr_sql_time:
      begin
        nValue.PageIndex := 0;
        cbCharCond.ItemIndex := 0;
        medValue.EditMask := '!99/99/00;1;_';
      end;
    else
      nValue.PageIndex := 1;
    end;

  end;
end;

function TdlgSetCondValue.GetValue: String;
begin
  Result := '';
  case nValue.PageIndex of
  0: Result := MakeNumberValue;
  1: Result := MakeCharValue;
  2: Result := MakeReferencyValue(True);
  end;
end;

function TdlgSetCondValue.MakeNumberValue: String;
begin
  Result := copy(cbCond.Text, 1, Pos(' ', cbCond.Text) - 1) + ' ' +
    medValue.Text;
end;

function TdlgSetCondValue.MakeCharValue: String;
begin
  Result := copy(cbCharCond.Text, 1, 1) + ' ' + medChar.Text;
end;

function TdlgSetCondValue.MakeReferencyValue(const isCode: Boolean): String;
var
  i: Integer;
begin
  Result := '';
  if isCode then
  begin
    for i:= 0 to gsibgrReferency.CheckBox.CheckCount - 1 do
    begin
      if Result > '' then
        Result := Result + ';';
      Result := Result + gsibgrReferency.CheckBox.StrCheck[i];
    end;
  end
  else
  begin
    Result := '';
    ibdsReferency.DisableControls;
    try
      i := 0;
      ibdsReferency.First;
      while not ibdsReferency.EOF do
      begin
        if gsibgrReferency.CheckBox.RecordChecked then
        begin
          if Result > '' then
            Result := Result + ';'; 
          Result := Result  + ibdsReferency.FieldByName(FRefField).AsString;
          Inc(i);
        end;
        if i >= gsibgrReferency.CheckBox.CheckCount then Break;
        ibdsReferency.Next;
      end;
    finally
      ibdsReferency.EnableControls;
    end;
  end;
end;

procedure TdlgSetCondValue.actSelectAllExecute(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  Bookmark := ibdsReferency.GetBookmark;
  ibdsReferency.DisableControls;
  try
    ibdsReferency.First;
    while not ibdsReferency.EOF do
    begin
      if not gsibgrReferency.CheckBox.RecordChecked then
        gsibgrReferency.CheckBox.AddCheck(ibdsReferency.FieldByName('ID').AsString);
      ibdsReferency.Next;
    end;
  finally
    ibdsReferency.GotoBookmark(Bookmark);
    ibdsReferency.FreeBookmark(Bookmark);
    ibdsReferency.EnableControls;
    gsibgrReferency.Refresh;
  end;
end;

procedure TdlgSetCondValue.actDeleteSelExecute(Sender: TObject);
begin
  gsibgrReferency.CheckBox.CheckList.Clear;
  gsibgrReferency.Refresh;
end;

procedure TdlgSetCondValue.actInvertExecute(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  Bookmark := ibdsReferency.GetBookmark;
  ibdsReferency.DisableControls;
  try
    ibdsReferency.First;
    while not ibdsReferency.EOF do
    begin
      if not gsibgrReferency.CheckBox.RecordChecked then
        gsibgrReferency.CheckBox.AddCheck(ibdsReferency.FieldByName('ID').AsString)
      else
        gsibgrReferency.CheckBox.DeleteCheck(ibdsReferency.FieldByName('ID').AsString);
      ibdsReferency.Next;
    end;
  finally
    ibdsReferency.GotoBookmark(Bookmark);
    ibdsReferency.FreeBookmark(Bookmark);
    ibdsReferency.EnableControls;
    gsibgrReferency.Refresh;
  end;
end;

procedure TdlgSetCondValue.SetValue(const Value: String);
var
  S: String;
  i: Integer;
begin
  case nValue.PageIndex of
  0:
    begin
      for i:= 0 to cbCond.Items.Count - 1 do
        if copy(cbCond.Items[i], 1, Pos(' ', Value) - 1) = copy(Value, 1, Pos(' ', Value) - 1)
        then
        begin
          cbCond.ItemIndex := i;
          Break;
        end;
      medValue.Text := copy(Value, Pos(' ', Value) + 1, 255);
    end;
  1:
    begin
      for i:= 0 to cbCharCond.Items.Count - 1 do
        if copy(cbCharCond.Items[i], 1, Pos(' ', Value) - 1) = copy(Value, 1, Pos(' ', Value) - 1)
        then
        begin
          cbCharCond.ItemIndex := i;
          Break;
        end;
      medChar.Text := copy(Value, Pos(' ', Value) + 1, 255);
    end;
  2:
    begin
      S := Value;
      while S > '' do
      begin
        if Pos(';', S) > 0 then
        begin
          gsibgrReferency.CheckBox.AddCheck(copy(S, 1, Pos(';', S) - 1));
          S := copy(S, Pos(';', S) + 1, Length(S));
        end
        else
        begin
          gsibgrReferency.CheckBox.AddCheck(S);
          S := '';
        end;
      end;
    end;
  end;
end;


function TdlgSetCondValue.GetTextValue: String;
begin
  Result := '';
  case nValue.PageIndex of
  0: Result := MakeNumberValue;
  1: Result := MakeCharValue;
  2: Result := MakeReferencyValue(False);
  end;
end;

end.
