
unit flt_dlgShowFilter_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList, flt_sqlfilter_condition_type, IBDatabase, Db,
  IBCustomDataSet, IBQuery, ComCtrls, IBSQL, Contnrs,
  Buttons, gd_security, Mask, DBCtrls, ImgList;

const
  FUserFieldPrefix = 'USR$';            // ������� ���������
  FDefaultDisplayName = 'NAME';

type
  TdlgShowFilter = class(TForm)
    ActionList: TActionList;
    actAddLine: TAction;
    actDeleteLine: TAction;
    ibqryTableName: TIBQuery;
    ibqryAttrRef: TIBQuery;
    pcOrderFilter: TPageControl;
    tsFilter: TTabSheet;
    tsOrder: TTabSheet;
    pnlButton: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    Button3: TButton;
    Button1: TButton;
    btnSaveFilter: TButton;
    ibsqlPrimaryField: TIBSQL;
    ibsqlSimpleField: TIBSQL;
    ibsqlChildField: TIBSQL;
    ibsqlForeignField: TIBSQL;
    ibsqlSetField: TIBSQL;
    ibsqlSortFields: TIBSQL;
    Panel1: TPanel;
    rbAND: TRadioButton;
    rbOR: TRadioButton;
    Panel2: TPanel;
    chbOnlyIndexed: TCheckBox;
    ibsqlFunctions: TIBSQL;
    sbFilter: TScrollBox;
    sbOrder: TScrollBox;
    tsName: TTabSheet;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    cbOnlyForMe: TCheckBox;
    tsSQL: TTabSheet;
    Panel5: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Button4: TButton;
    Button5: TButton;
    btnAccess: TButton;
    ibdsFilter: TIBDataSet;
    ibsqlGetID: TIBSQL;
    dsFilter: TDataSource;
    dbeName: TDBEdit;
    dbeComment: TDBEdit;
    Label3: TLabel;
    dbtExTime: TDBText;
    actShowOriginalSQL: TAction;
    actShowConditionSQL: TAction;
    ilFields: TImageList;
    Label4: TLabel;
    cbNameMode: TComboBox;
    cbDistinct: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actAddLineExecute(Sender: TObject);
    procedure actAddLineUpdate(Sender: TObject);
    procedure actDeleteLineExecute(Sender: TObject);
    procedure actDeleteLineUpdate(Sender: TObject);
    procedure btnSaveFilterClick(Sender: TObject);
    procedure chbOnlyIndexedClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbOnlyForMeClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure actShowOriginalSQLExecute(Sender: TObject);
    procedure actShowConditionSQLExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnAccessClick(Sender: TObject);
  private
    { Private declarations }
    FIsIndexField: Boolean;             // ��������������� ����
    FSetingCheck: Boolean;              // ����

    FFieldList: TTreeView;     // ������ ����� ��� ����������
    FSortList: TTreeView;      // ������ ����� ��� ����������
    FIndexList: TTreeView;     // ������ ��������������� ����� ��� ����������

    FComponentKey: Integer;             // ���� ����������

    FFilterList: TObjectList;           // ������ ���������� ������� �������
    FOrderList: TObjectList;            // ������ ���������� ������� ������� ����������
    FFilterBloksList: TObjectList;      // FFieldList, FSortList, FIndexList
                                        // �� ����� ��������� ����������� �������� ������� ...


    FNoVisibleList: TStrings;           // ������ ��������� �����
    FTableList: TfltStringList;         // ������ ������
    FConditionLink: TfltStringList;     // ������ ��������� �������
    FTableNames: array of String[255];  // ����. ������ ������
    FFunctionList: TStrings;            // ������ �������
    FMainWindow: Boolean;               // ����. ������� ����

    DeltaHeight: Integer;               // ������ ������������� �������
    SizeScreenX: Integer;               // ������ ������
    SizeScreenY: Integer;               // ������ ������
    FIsFill: Boolean;                   // ���������� ����. ���������� �� ����
    FEnableOrder: Boolean;              // ���� ����������� �� ����������
    FIsNewFilter: Boolean;              // ������ �� ����� ������
    FSQLText: String;                   // ����� ������� ����������

    function CheckMainFields: Boolean;  // �������� ������������ ���������� �����
    // �������� ���� �� ������� ���� ����������
    procedure ChangeSortFields(const AnIndexField: Boolean);
    // ��������� ��� ���� Interbase � ��� ���� �������
    function ConvertDataType(const InterbaseType, SubType: Integer;
     const DomenName: String; const Size: Integer = 0): Integer;
    // �������� ������� ���������� �� ����������� ������
    function GetCondition(const I: Integer; var AnConditionData: TFilterCondition): Boolean;
    // ������������� ������� ���������� �� ���������� �����
    procedure SetCondition(const I: Integer; const AnConditionData: TFilterCondition);
    // ������������� ������� ���������� �� ���������� �����
    procedure SetOrderLine(const I: Integer; const AnOrderData: TFilterOrderBy);
    // �������� ������� ���������� �� ���������� �����
    function GetOrderLine(const I: Integer; const AnOrderData: TFilterOrderBy): boolean;
    // ��������� ����������� ���������
    procedure FullIBParams;
    // ��������� ������� �������
    procedure OpenSimpleQuery(const ParentNode: TTreeNode; const AnTableName,
     AnPrimaryName: String);
    // ��������� ��� �������
    function OpenQuery(const AnTableName, AnTableAlias: String): Pointer;
    // ��������� ���� �� ���������� ����
    function CheckVisible(const AnTableName, AnFieldName: String): Boolean;

    // ��������� ����� ����������
    procedure AddFilterLine;
    // ��������� ����� ����������
    procedure AddOrderLine;

    // ������� ����� ����������
    procedure DeleteOrderLine(const AnIndex: Integer);
    // ������� ����� ����������
    procedure DeleteFilterLine(const AnIndex: Integer);

    // ������ ������ ������� ����������
    procedure ClearFilterLine;
    // ������ ������ ������� ����������
    procedure ClearOrderLine;

    // ��������� ������ ������� ���������� � ����������
    procedure CompliteFilterData(const AnConditionList: TFilterConditionList;
     const AnOrderByList: TFilterOrderByList);

    // ������ �������
    procedure ReadFunctions;
    // ��������� ��������� �� �������
    procedure WMUser(var Message: TMessage); message WM_USER;

    function GetIngroup: Integer;
    function GetUserKey: Integer;
    procedure ClearFieldList;
    procedure ClearSortList;
    procedure ClearIndexList;
    function CheckFieldName(AnFieldName: String): String;
  public
    // ��� ��������� ������ ���� ��������� �� ������ ������ �������
    Database: TIBDatabase;
    Transaction: TIBTransaction;

    // �������� ��������� ������� �� �� ������������
    procedure FindTable(const ATableName, AFieldName: String;
     var ADisplayName: String; var AIsReference: Boolean; const AnSecondTable: String);
    // ������ ��� ��������� ������
    function ShowLinkTableFilter(const AnConditionList: TFilterConditionList;
     const AnTableName, AnLinkField: String): Boolean;
    // ������ ��� ���� ��������� ������
    function ShowFilter(const AnConditionList: TFilterConditionList; const AnOrderByList: TFilterOrderByList;
     const AnNoVisibleList: TStrings; const AnTableList, AnLinkCondition: TfltStringList; const AnIsFill: Boolean): Boolean;
    // �������� ������
    function AddFilter(const AnComponentKey: Integer; const AnSQLText: String;
     const AnNoVisibleList: TStrings; const AnIsFill: Boolean; out AnIsNewFilter: Boolean): Integer;
    // �������� ������
    function EditFilter(const FilterKey: Integer; const AnSQLText: String;
     const AnNoVisibleList: TStrings; const AnIsFill: Boolean; out AnIsNewFilter: Boolean): Integer;
    // ������� ������
    function DeleteFilter(const FilterKey: Integer): Boolean;
  end;

type
  TFieldNameMode = (fnmDuplex, fnmOriginal, fnmLocalize);

var
  dlgShowFilter: TdlgShowFilter;
  fltFieldNameMode: TFieldNameMode;

implementation

uses
  flt_frFilterLine_unit, flt_frOrderLine_unit, flt_sql_parser,
  {$IFDEF SYNEDIT}
  flt_frmSQLEditorSyn_unit,
  {$ELSE}
  flt_frmSQLEditor_unit,
  {$ENDIF}
  flt_SQLFilter, Math, at_Classes, Registry, gd_security_dlgChangeRigth, gsComboTreeBox,
  flt_IBUtils
{$IFDEF VER140}
  , Variants
{$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}
procedure TdlgShowFilter.FormCreate(Sender: TObject);
begin
  // ��������� ���������
  FSQLText := '';
  FSetingCheck := False;
  FIsFill := False;
  FMainWindow := False;
  FEnableOrder := False;
  // ������� ������
  SizeScreenX := GetSystemMetrics(SM_CXSCREEN);
  SizeScreenY := GetSystemMetrics(SM_CYSCREEN);
  // ������ �����
  DeltaHeight := Self.Height - pnlButton.Height;
  // �������� �������
  FFilterList := TObjectList.Create(False);
  FOrderList := TObjectList.Create(False);
  FFilterBloksList := TObjectList.Create;

  FFieldList := TTreeView.Create(nil);
  FFieldList.Visible := False;
  FFieldList.Parent := Self;
  FSortList := TTreeView.Create(nil);
  FSortList.Visible := False;
  FSortList.Parent := Self;
  FIndexList := TTreeView.Create(nil);
  FIndexList.Visible := False;
  FIndexList.Parent := Self;

  FNoVisibleList := TStringList.Create;
  FTableList := TfltStringList.Create;
  FConditionLink := TfltStringList.Create;
  FFunctionList := TStringList.Create;

  {$IFNDEF GEDEMIN}
  ibsqlPrimaryField.SQL.Text := cPrimaryFieldSQL;
  ibsqlForeignField.SQL.Text := cForeignFieldSQL;
  ibsqlSimpleField.SQL.Text := cSimpleFieldSQL;
  ibsqlSetField.SQL.Text := cSetFieldSQL;
  ibsqlChildField.SQL.Text := cChildSetSQL;
  {$ENDIF}
  ibsqlSortFields.SQL.Text := cSortFieldSQL;
  ibsqlFunctions.SQL.Text := cFunctionSQL;
end;

function TdlgShowFilter.GetCondition(const I: Integer; var AnConditionData: TFilterCondition): Boolean;
var
  F: TfrFilterLine;
  FieldType: Integer;
begin
   Result := False;
  // �������� �� ��������
  Assert((I >= 0) and (FFilterList.Count > I), '������ ��� ���������');
  // ������� ���������
  AnConditionData.Clear;
  // ����������� ����� ��� �������� ���������
  F := TfrFilterLine(FFilterList.Items[I]);
  if F.ctbFields.SelectedNode <> nil then
  begin
    // ����������� ��� ��������� ���������
    AnConditionData.FieldData.Assign(TfltFieldData(F.ctbFields.SelectedNode.Data));
    AnConditionData.ValueList.Assign(F.gscbSet.ValueID);
    AnConditionData.SubFilter.Assign(F.ConditionList);
    AnConditionData.Value1 := F.escbEnumSet.QuoteSelected;
    if AnConditionData.FieldData.FieldType = GD_DT_FORMULA then
    begin
      AnConditionData.Value1 := F.cbFormula.Text;
      AnConditionData.ConditionType := ExtractCondition(F.cbCondition.ItemIndex, GD_DT_FORMULA);
      Result := True;
      Exit;
    end;
    if AnConditionData.FieldData.FieldType = GD_DT_UNKNOWN_SET then
      FieldType := AnConditionData.FieldData.LinkTargetFieldType
    else
      FieldType := AnConditionData.FieldData.FieldType;
    AnConditionData.ConditionType := ExtractCondition(F.cbCondition.ItemIndex, FieldType);
    // � ����������� �� ���� ������� �����������, ��� ����
    case AnConditionData.ConditionType of
      GD_FC_EQUAL_TO, GD_FC_GREATER_THAN, GD_FC_LESS_THAN, GD_FC_NOT_EQUAL_TO,
      GD_FC_GREATER_OR_EQUAL_TO, GD_FC_LESS_OR_EQUAL_TO, GD_FC_BEGINS_WITH,
      GD_FC_ENDS_WITH, GD_FC_CONTAINS, GD_FC_DOESNT_CONTAIN, GD_FC_LAST_N_DAYS:
        case FieldType of
          GD_DT_ENUMERATION: AnConditionData.Value1 := F.ecbEnum.QuoteSelected;
        else
          AnConditionData.Value1 := F.edCondition.Text;
        end;

      GD_FC_SELDAY:
        AnConditionData.Value1 := DateToStr(F.dtpSelDay.Date);

      GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT, GD_FC_OUT, GD_FC_OUT_LIMIT:
      begin
        AnConditionData.Value1 := F.edFrom.Text;
        AnConditionData.Value2 := F.edTo.Text;
      end;

      GD_FC_ENTER_PARAM:
      begin
        AnConditionData.Value1 := F.edDataName.Text;
        AnConditionData.Value2 := F.cbSign.Text;
      end;

      GD_FC_SCRIPT:
      begin
        AnConditionData.Value1 := F.edScript.Text;
        AnConditionData.Value2 := F.cbLanguage.Text;
      end;
    end;
    Result := True;
  end;
end;

procedure TdlgShowFilter.SetCondition(const I: Integer; const AnConditionData: TFilterCondition);
var
  F: TfrFilterLine;
  FieldType: Integer;
  J: Integer;
  Flag: Boolean;
begin
  // �������� �� ��������
  Assert((I >= 0) and (FFilterList.Count > I), '������ ��� ���������');
  F := TfrFilterLine(FFilterList.Items[I]);
  Flag := False;
  // ����������������� ������ ���������� ������
//  F.ctbFields.Options := F.ctbFields. Options + [icoExpanded];
  // ���� ���� �� ������� � ������ �����
  for J := 0 to F.ctbFields.Nodes.Count - 1 do
  begin
    if (TObject(F.ctbFields.Nodes[J].Data) is TfltFieldData)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).FieldName = AnConditionData.FieldData.FieldName)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).FieldType = AnConditionData.FieldData.FieldType)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).TableName = AnConditionData.FieldData.TableName)
     {gs} // ��������� ��������, ������� ���� ����� �������
     and (AnsiUpperCase(TfltFieldData(F.ctbFields.Nodes[J].Data).TableAlias) = AnsiUpperCase(AnConditionData.FieldData.TableAlias))
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).RefField = AnConditionData.FieldData.RefField)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).RefTable = AnConditionData.FieldData.RefTable)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).LinkTable = AnConditionData.FieldData.LinkTable)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).LinkTargetField = AnConditionData.FieldData.LinkTargetField)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).LinkSourceField = AnConditionData.FieldData.LinkSourceField)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).AttrKey = AnConditionData.FieldData.AttrKey)
     and (TfltFieldData(F.ctbFields.Nodes[J].Data).AttrRefKey = AnConditionData.FieldData.AttrRefKey) then
    begin
      // ���� �����, �� �����������
      F.ctbFields.SelectedNode := F.ctbFields.Nodes[J];
      F.cbFieldsChange(Self);
      Flag := True;
      Break;
    end;
  end;
  if Flag then
  begin
    // ������������� �������
    //TfltFieldData(F.ctbFields.SelectedNode.Data).Assign(AnConditionData.FieldData);
    F.gscbSet.ValueID.Assign(AnConditionData.ValueList);
    F.ConditionList.Assign(AnConditionData.SubFilter);
    F.escbEnumSet.QuoteSelected := AnConditionData.Value1;
    // ������� ����� ������
    if AnConditionData.FieldData.FieldType = GD_DT_UNKNOWN_SET then
      FieldType := AnConditionData.FieldData.LinkTargetFieldType
    else
      FieldType := AnConditionData.FieldData.FieldType;
    // ����������� ��������
    F.cbCondition.ItemIndex := ConvertCondition(AnConditionData.ConditionType, FieldType);
    F.SetValues;
    // � ����������� �� ���� ������� ����������� �� ��������
    case AnConditionData.ConditionType of
      GD_FC_EQUAL_TO, GD_FC_GREATER_THAN, GD_FC_LESS_THAN, GD_FC_NOT_EQUAL_TO,
      GD_FC_GREATER_OR_EQUAL_TO, GD_FC_LESS_OR_EQUAL_TO, GD_FC_BEGINS_WITH,
      GD_FC_ENDS_WITH, GD_FC_CONTAINS, GD_FC_DOESNT_CONTAIN, GD_FC_LAST_N_DAYS:
      begin
        F.edCondition.Text := AnConditionData.Value1;
        if FieldType = GD_DT_ENUMERATION then
          F.ecbEnum.QuoteSelected := AnConditionData.Value1;
      end;

      GD_FC_SELDAY:
        F.dtpSelDay.Date := StrToDate(AnConditionData.Value1);

      GD_FC_QUERY_WHERE, GD_FC_QUERY_ALL:
        F.cbFormula.Text := AnConditionData.Value1;

      GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT, GD_FC_OUT, GD_FC_OUT_LIMIT:
      begin
        F.edFrom.Text := AnConditionData.Value1;
        F.edTo.Text := AnConditionData.Value2;
      end;

      GD_FC_ENTER_PARAM:
      begin
        F.edDataName.Text := AnConditionData.Value1;
        for J := 0 to F.cbSign.Items.Count - 1 do
          if UpperCase(F.cbSign.Items[J]) = UpperCase(AnConditionData.Value2) then
            F.cbSign.ItemIndex := J;
      end;

      GD_FC_SCRIPT:
      begin
        F.edScript.Text := AnConditionData.Value1;
        for J := 0 to LanguageCount - 1 do
          if UpperCase(LanguageList[J]) = UpperCase(AnConditionData.Value2) then
            F.cbLanguage.ItemIndex := J;
      end;
    end;
  end else
    MessageBox(Self.Handle, PChar('���� �������� ������ ���������. '{, ���� ��� �������� � �������.'#13#10} +
     '�� ������� ����� ���� �� ����� � ������� ' + String(AnConditionData.FieldData.TableName)
     + ' ' + AnConditionData.FieldData.TableAlias), '��������', MB_OK or MB_ICONWARNING);
end;

procedure TdlgShowFilter.ReadFunctions;
var
  TempStr: String;
  I, J: Integer;
begin
  // ������� ������
  FFunctionList.Clear;
  ibsqlFunctions.Close;
  ibsqlFunctions.ExecQuery;
  while not ibsqlFunctions.Eof do
  begin
    // ������������ �������
    TempStr := Trim(ibsqlFunctions.FieldByName('fname').AsString);
    // ���������� ����������
    J := ibsqlFunctions.FieldByName('argcount').AsInteger;
    if J > 0 then
    begin
      TempStr := TempStr + '(';
      for I := 0 to J - 2 do
        TempStr := TempStr + ' ,';
      TempStr := TempStr + ' ) ';
    end;
    // ��������� �������
    FFunctionList.Add(TempStr);

    ibsqlFunctions.Next;
  end;
end;

// ����������� �������� � ���������� ��� ���������
procedure TdlgShowFilter.FullIBParams;
begin
  {$IFNDEF GEDEMIN}
  ibsqlPrimaryField.Database := Database;
  ibsqlPrimaryField.Transaction := Transaction;
  ibsqlForeignField.Database := Database;
  ibsqlForeignField.Transaction := Transaction;
  ibsqlSimpleField.Database := Database;
  ibsqlSimpleField.Transaction := Transaction;
  ibsqlSetField.Database := Database;
  ibsqlSetField.Transaction := Transaction;
  ibsqlChildField.Database := Database;
  ibsqlChildField.Transaction := Transaction;
  {$ENDIF}
  ibsqlSortFields.Database := Database;
  ibsqlSortFields.Transaction := Transaction;
  ibsqlFunctions.Database := Database;
  ibsqlFunctions.Transaction := Transaction;
  ibsqlGetID.Database := Database;
  ibsqlGetID.Transaction := Transaction;
  ibdsFilter.Database := Database;
  ibdsFilter.Transaction := Transaction;
end;

// ��������� ����� OpenQuery. ������������ ��� ��������� ������. ��� ������������.
procedure TdlgShowFilter.OpenSimpleQuery(const ParentNode: TTreeNode; const AnTableName, AnPrimaryName: String);
var
{$IFNDEF GEDEMIN}
  I: Integer;
  TepmTreeNode: TTreeNode;
  S: String;
  F: TatRelationField;

  procedure FillMainFields(const AnFieldData: TfltFieldData);
  begin
    AnFieldData.TableName := AnTableName;
  end;

begin
//  ibqryTableName.Open;

  // ���������� FOREIGN KEY
  ibsqlForeignField.Close;
  ibsqlForeignField.Params[0].AsString := AnTableName;
  ibsqlForeignField.ExecQuery;

  // ���������� ������� ����
  ibsqlSimpleField.Close;
  ibsqlSimpleField.SQL.Delete(ibsqlSimpleField.SQL.Count - 1);
  I := ibsqlSimpleField.SQL.Add('AND NOT relf.RDB$FIELD_NAME IN (');
  while not ibsqlForeignField.Eof do
  begin
    if (FMainWindow or (ibsqlForeignField.FieldByName('iscircle').AsInteger <> 1))
      and CheckVisible(AnTableName, Trim(ibsqlForeignField.FieldByName('sourcefield').AsString))
      and (AnPrimaryName <> Trim(ibsqlForeignField.FieldByName('sourcefield').AsString))
      {gs} // TODO ����� ���������� ����� ����. ��������� ��������� ���� ������.
      {and (Pos(FUserFieldPrefix, TfltFieldData(TepmTreeNode.Data).FieldName) = 0)} then
    begin
      TepmTreeNode := FFieldList.Items.AddChild(ParentNode, '1_' + Trim(ibsqlForeignField.FieldByName('sourcefield').AsString));
      TepmTreeNode.ImageIndex := 2;
      TepmTreeNode.Data := TfltFieldData.Create;
      FFilterBloksList.Add(TepmTreeNode.Data);
      // ��������� ���� FOREIGN KEY
      TfltFieldData(TepmTreeNode.Data).FieldName := CheckFieldName(ibsqlForeignField.FieldByName('sourcefield').AsString);
      TfltFieldData(TepmTreeNode.Data).FieldType := GD_DT_REF_SET_ELEMENT;
      TfltFieldData(TepmTreeNode.Data).RefTable := Trim(ibsqlForeignField.FieldByName('targettable').AsString);
      TfltFieldData(TepmTreeNode.Data).RefField := Trim(ibsqlForeignField.FieldByName('targetfield').AsString);
      FindTable(AnTableName,
       TfltFieldData(TepmTreeNode.Data).FieldName, S,
       TfltFieldData(TepmTreeNode.Data).IsReference,
       TfltFieldData(TepmTreeNode.Data).RefTable);
      TfltFieldData(TepmTreeNode.Data).DisplayName := S;

      FillMainFields(TfltFieldData(TepmTreeNode.Data));

      if atDatabase <> nil then
        F := atDatabase.FindRelationField(
          TfltFieldData(TepmTreeNode.Data).TableName, TfltFieldData(TepmTreeNode.Data).FieldName)
      else
        F := nil;

      if F <> nil then
      begin
        TfltFieldData(TepmTreeNode.Data).LocalField := Trim(F.LName);
        TepmTreeNode.Text := TfltFieldData(TepmTreeNode.Data).LocalField + ' (' + TepmTreeNode.Text + ')';
      end else
        TfltFieldData(TepmTreeNode.Data).LocalField := '';
     end;

    ibsqlSimpleField.SQL.Strings[I] := ibsqlSimpleField.SQL.Strings[I] + ''''
     + Trim(ibsqlForeignField.FieldByName('sourcefield').AsString) + '''';
    ibsqlForeignField.Next;
    ibsqlSimpleField.SQL.Strings[I] := ibsqlSimpleField.SQL.Strings[I] + ','
  end;

  ibsqlSimpleField.SQL.Strings[I] := ibsqlSimpleField.SQL.Strings[I] + '''' + AnPrimaryName + ''')';
  ibsqlSimpleField.Params[0].AsString := AnTableName;

  ibsqlSimpleField.ExecQuery;
  while not ibsqlSimpleField.Eof do
  begin
    if CheckVisible(AnTableName, Trim(ibsqlSimpleField.FieldByName('fieldname').AsString)) then
    begin
      // ��������� ������� ����
      TepmTreeNode := FFieldList.Items.AddChild(ParentNode, '2_' + Trim(ibsqlSimpleField.FieldByName('fieldname').AsString));
      TepmTreeNode.ImageIndex := 3;
      TepmTreeNode.Data := TfltFieldData.Create;
      FFilterBloksList.Add(TepmTreeNode.Data);
      TfltFieldData(TepmTreeNode.Data).FieldName := CheckFieldName(ibsqlSimpleField.FieldByName('fieldname').AsString);
      TfltFieldData(TepmTreeNode.Data).FieldType := ConvertDataType(ibsqlSimpleField.FieldByName('fieldtype').AsInteger,
       ibsqlSimpleField.FieldByName('fieldsubtype').AsInteger, ibsqlSimpleField.FieldByName('domainname').AsString,
       ibsqlSimpleField.FieldByName('fieldlength').AsInteger);
      FillMainFields(TfltFieldData(TepmTreeNode.Data));

      if atDatabase <> nil then
        F := atDatabase.FindRelationField(
         TfltFieldData(TepmTreeNode.Data).TableName, TfltFieldData(TepmTreeNode.Data).FieldName)
      else
        F := nil;

      if F <> nil then
      begin
        TfltFieldData(TepmTreeNode.Data).LocalField := Trim(F.LName);
        TepmTreeNode.Text := TfltFieldData(TepmTreeNode.Data).LocalField + ' (' + TepmTreeNode.Text + ')';
      end else
        TfltFieldData(TepmTreeNode.Data).LocalField := '';
    end;

    ibsqlSimpleField.Next;
  end;

end;
{$ELSE}
  J: Integer;
  TepmTreeNode: TTreeNode;
  S, ExclFields: String;
  F: TatRelationField;
  FK: TatForeignKey;
  Lst: TObjectList;
  R: TatRelation;

  procedure FillMainFields(const AnFieldData: TfltFieldData);
  begin
    AnFieldData.TableName := AnTableName;
  end;

begin
  ExclFields := '"' + AnPrimaryName + '"' + '"AFULL""ACHAG""AVIEW""LB""RB"';
  Lst := TObjectList.Create(False);
  try
    atDatabase.ForeignKeys.ConstraintsByRelation(AnTableName, Lst);
    for J := 0 to Lst.Count - 1 do
    begin
      FK := Lst[J] as TatForeignKey;

      if not FK.IsSimpleKey then
        continue;

      if (FMainWindow or (FK.Relation.RelationName <> FK.ReferencesRelation.RelationName))
        and CheckVisible(AnTableName, FK.ConstraintFields[0].FieldName)
        and (AnPrimaryName <> FK.ConstraintFields[0].FieldName) then
      begin
        TepmTreeNode := FFieldList.Items.AddChild(ParentNode, '1_' + FK.ConstraintFields[0].FieldName);
        TepmTreeNode.ImageIndex := 2;
        TepmTreeNode.Data := TfltFieldData.Create;
        FFilterBloksList.Add(TepmTreeNode.Data);
        // ��������� ���� FOREIGN KEY
        TfltFieldData(TepmTreeNode.Data).FieldName := CheckFieldName(FK.ConstraintFields[0].FieldName);
        TfltFieldData(TepmTreeNode.Data).FieldType := GD_DT_REF_SET_ELEMENT;
        TfltFieldData(TepmTreeNode.Data).RefTable := FK.ReferencesRelation.RelationName;
        TfltFieldData(TepmTreeNode.Data).RefField := FK.ReferencesFields[0].FieldName;
        FindTable(AnTableName,
         TfltFieldData(TepmTreeNode.Data).FieldName, S,
         TfltFieldData(TepmTreeNode.Data).IsReference,
         TfltFieldData(TepmTreeNode.Data).RefTable);
        TfltFieldData(TepmTreeNode.Data).DisplayName := S;

        FillMainFields(TfltFieldData(TepmTreeNode.Data));

        if atDatabase <> nil then
          F := atDatabase.FindRelationField(
            TfltFieldData(TepmTreeNode.Data).TableName, TfltFieldData(TepmTreeNode.Data).FieldName)
        else
          F := nil;

        if F <> nil then
        begin
          TfltFieldData(TepmTreeNode.Data).LocalField := Trim(F.LName);
          TepmTreeNode.Text := TfltFieldData(TepmTreeNode.Data).LocalField + ' (' + TepmTreeNode.Text + ')';
        end else
          TfltFieldData(TepmTreeNode.Data).LocalField := '';
       end;

      ExclFields := ExclFields + '"' + FK.ConstraintFields[0].FieldName + '"';
    end;
  finally
    Lst.Free;
  end;

  R := atDatabase.Relations.ByRelationName(AnTableName);

  for J := 0 to R.RelationFields.Count - 1 do
  begin
    if Pos('"' + R.RelationFields[J].FieldName + '"', ExclFields) <> 0 then
      continue;

    if CheckVisible(AnTableName, R.RelationFields[J].FieldName) then
    begin
      // ��������� ������� ����
      TepmTreeNode := FFieldList.Items.AddChild(ParentNode, '2_' + R.RelationFields[J].FieldName);
      TepmTreeNode.ImageIndex := 3;
      TepmTreeNode.Data := TfltFieldData.Create;
      FFilterBloksList.Add(TepmTreeNode.Data);
      TfltFieldData(TepmTreeNode.Data).FieldName := CheckFieldName(R.RelationFields[J].FieldName);
      TfltFieldData(TepmTreeNode.Data).FieldType := ConvertDataType(R.RelationFields[J].Field.SQLType,
       R.RelationFields[J].Field.SQLSubType, R.RelationFields[J].Field.FieldName,
       R.RelationFields[J].Field.FieldLength);
      FillMainFields(TfltFieldData(TepmTreeNode.Data));

      TfltFieldData(TepmTreeNode.Data).LocalField := R.RelationFields[J].LName;
      TepmTreeNode.Text := TfltFieldData(TepmTreeNode.Data).LocalField + ' (' + TepmTreeNode.Text + ')';
    end;
  end;
end;
{$ENDIF}

(*procedure TdlgShowFilter.FindTable(const ATableName: String; var ADisplayName: String; var AIsReference: Boolean);
begin
  if ibqryTableName.Locate('tablename', ATableName, []) then
  begin
    // ����������� ������������ ���� ��� �����������
    ADisplayName := Trim(ibqryTableName.FieldByName('displayfield').AsString);
    // ����������� ���� �����������
    AIsReference := ibqryTableName.FieldByName('isreference').AsInteger = 1;
  end else
  begin
    ADisplayName := 'name';
    AIsReference := False;
  end;
end;*)

procedure TdlgShowFilter.FindTable(const ATableName, AFieldName: String;
 var ADisplayName: String; var AIsReference: Boolean; const AnSecondTable: String);
var
  R: TatRelation;
  F: TatRelationField;
begin
  ADisplayName := '';
  if atDatabase <> nil then
    R := atDatabase.Relations.ByRelationName(ATableName)
  else
    R := nil;
  if R <> nil then
  begin
    F := R.RelationFields.ByFieldName(AFieldName);
    if F <> nil then
      ADisplayName := F.Field.RefListFieldName;
  end;

  if ADisplayName = '' then
  begin
    if atDatabase <> nil then
      R := atDatabase.Relations.ByRelationName(AnSecondTable)
    else
      R := nil;
    if R <> nil then
    begin
      F := R.ListField;
      if F <> nil then
        ADisplayName := F.FieldName;
    end;
  end;

  if ADisplayName = '' then
    ADisplayName := FDefaultDisplayName;
  AIsReference := True;
end;

// ������� ������ �����
function TdlgShowFilter.OpenQuery(const AnTableName, AnTableAlias: String): Pointer;
{$IFNDEF GEDEMIN}
const
  FReferenceLabel = 'R';

var
  AnPrimaryName, AnLocalTable, S: String;
  I, L: Integer;
  OrderTreeNode, TepmOrderTreeNode, TepmFieldTreeNode, TableTreeNode: TTreeNode;
  F: TatRelationField;
  R: TatRelation;
  OnlySimpleFields: Boolean;

  // ������� ���� �� ������������ ������� � ���� ������� � �������
  function FindLinkTable(const SForeignField, STableName: String): Integer;
  var
    M, N: Integer;
    TTN, TFF: String;
  begin
    Result := -1;
    TTN := AnsiUpperCase(STableName);
    TFF := AnsiUpperCase(AnTableAlias + SForeignField);
    for M := 0 to FTableList.Count - 1 do
      if AnsiUpperCase(FTableList.Names[M]) = TTN then
        for N := 0 to FConditionLink.Count - 1 do
          if (((FConditionLink.Names[N] = TFF) and
           (Pos(AnsiUpperCase(FTableList.ValuesOfIndex[M]), FConditionLink.ValuesOfIndex[N]) = 1)) or
           ((FConditionLink.ValuesOfIndex[N] = TFF) and
           (Pos(AnsiUpperCase(FTableList.ValuesOfIndex[M]), FConditionLink.Names[N]) = 1))) then
          begin
            FConditionLink.Delete(N);
            Result := M;
            Exit;
          end;
  end;

  // ���������� �������� ����� � ���������
  procedure FillMainFields(const AnFieldData: TfltFieldData);
  begin
    AnFieldData.TableName := AnTableName;
    AnFieldData.TableAlias := AnTableAlias;
    AnFieldData.LocalTable := AnLocalTable;
  end;

  // ���������� ����� ��� ���������� ���������� �� ����� ��� ����������
  procedure FillSortItem(const AnFieldData: TfltFieldData; const AnOrderByData: TFilterOrderBy);
  begin
    AnOrderByData.TableName := AnFieldData.TableName;
    AnOrderByData.TableAlias := AnFieldData.TableAlias;
    AnOrderByData.FieldName := AnFieldData.FieldName;
    AnOrderByData.LocalField := AnFieldData.LocalField;
    AnOrderByData.IsAscending := True;
  end;

  function GetFieldName(const AnLocalName, AnOriginalName: String): String;
  begin
    case fltFieldNameMode of
      fnmOriginal: Result := AnOriginalName;
      fnmLocalize: Result := AnLocalName;
      fnmDuplex: Result := AnLocalName + ' (' + AnOriginalName + ')';
    else
      Assert(False, 'Filter Field Name Mode not suported.');
    end;
  end;
begin
  Result := nil;
  try
    if atDatabase <> nil then
      R := atDatabase.Relations.ByRelationName(AnTableName)
    else
      R := nil;
    if R <> nil then
    begin
      AnLocalTable := Trim(R.LName);
      if Trim(AnLocalTable) = '' then
        AnLocalTable := AnTableName;
    end else
      AnLocalTable := AnTableName;
    // ���������� ������ ������
    AnLocalTable := GetFieldName(AnLocalTable, AnTableName);

    {ibqryTableName.Open;
    if ibqryTableName.Locate('tablename', AnTableName, []) then
      AnLocalTable := Trim(ibqryTableName.FieldByName('name').AsString)
    else
      AnLocalTable := AnTableName;}

    // ���������� ���������
{    ibqryAttrRef.Close;
    ibqryAttrRef.Params[0].AsString := AnTableName;
    ibqryAttrRef.Open;}

    OnlySimpleFields := False;
    // ���������� PRIMARY KEY
    ibsqlPrimaryField.Close;
    ibsqlPrimaryField.Params[0].AsString := AnTableName;
    ibsqlPrimaryField.ExecQuery;
    if not ibsqlPrimaryField.Eof then
    begin
      AnPrimaryName := Trim(ibsqlPrimaryField.Fields[0].AsString);
      ibsqlPrimaryField.Next;
      if not ibsqlPrimaryField.Eof then
      begin
      //{gs}  MessageBox(Self.Handle, PChar(Format('� ������� %s ������, ��� ���� PRIMARY KEY.', [AnTableName])), '��������',
      //   MB_OK or MB_ICONINFORMATION);
         OnlySimpleFields := True;
        //Result := False;
        //Exit;
      end;
    end else
    begin
      //{gs}MessageBox(Self.Handle, PChar(Format('� ������� %s ����������� PRIMARY KEY.', [AnTableName])), '��������',
      // MB_OK or MB_ICONINFORMATION);
       OnlySimpleFields := True;
      //Result := False;
      //Exit;
    end;

    OrderTreeNode := FSortList.Items.AddObject(nil, AnLocalTable, nil);
    OrderTreeNode.ImageIndex := 1;
    TableTreeNode := FFieldList.Items.AddObject(nil, AnLocalTable, OrderTreeNode);
    Result := TableTreeNode;
    TableTreeNode.ImageIndex := 1;

    TepmOrderTreeNode := FSortList.Items.AddChildObject(OrderTreeNode, AnPrimaryName, TFilterOrderBy.Create);
    TepmOrderTreeNode.ImageIndex := 3;
    FFilterBloksList.Add(TepmOrderTreeNode.Data);
    TFilterOrderBy(TepmOrderTreeNode.Data).TableName := AnTableName;
    TFilterOrderBy(TepmOrderTreeNode.Data).TableAlias := AnTableAlias;
    TFilterOrderBy(TepmOrderTreeNode.Data).FieldName := CheckFieldName(AnPrimaryName);
    if atDatabase <> nil then
      F := atDatabase.FindRelationField(TFilterOrderBy(TepmOrderTreeNode.Data).TableName,
        TFilterOrderBy(TepmOrderTreeNode.Data).FieldName)
    else
      F := nil;
    if F <> nil then
      TFilterOrderBy(TepmOrderTreeNode.Data).LocalField := Trim(F.LName);
    TFilterOrderBy(TepmOrderTreeNode.Data).IsAscending := True;
    TepmOrderTreeNode.Text := GetFieldName(TFilterOrderBy(TepmOrderTreeNode.Data).LocalField, TepmOrderTreeNode.Text);

    // ���������� FOREIGN KEY
    ibsqlForeignField.Close;
    ibsqlForeignField.Params[0].AsString := AnTableName;
    ibsqlForeignField.ExecQuery;

    // ���������� ������� ����
    ibsqlSimpleField.Close;
    ibsqlSimpleField.SQL.Text := cSimpleFieldSQL;
    ibsqlSimpleField.SQL.Delete(ibsqlSimpleField.SQL.Count - 1);
    if not OnlySimpleFields then
    begin
      I := ibsqlSimpleField.SQL.Add('AND NOT relf.RDB$FIELD_NAME IN (');
      while not ibsqlForeignField.Eof do
      begin  // {jkl} ���������� �� ������� ���� � ������
        if {(FMainWindow or (ibsqlForeignField.FieldByName('iscircle').AsInteger <> 1))
         and} CheckVisible(AnTableName, Trim(ibsqlForeignField.FieldByName('sourcefield').AsString)) then
        begin
          TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '1_' + Trim(ibsqlForeignField.FieldByName('sourcefield').AsString));
          TepmFieldTreeNode.ImageIndex := 2;
          TepmFieldTreeNode.Data := TfltFieldData.Create;
          FFilterBloksList.Add(TepmFieldTreeNode.Data);
          // ��������� ���� FOREIGN KEY
          TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(ibsqlForeignField.FieldByName('sourcefield').AsString);
          TfltFieldData(TepmFieldTreeNode.Data).IsTree := ibsqlForeignField.FieldByName('istree').AsInteger = 1;
          {if Pos(FUserFieldPrefix, TfltFieldData(TepmFieldTreeNode.Data).FieldName) = 0 then
          begin}
            TfltFieldData(TepmFieldTreeNode.Data).FieldType := GD_DT_REF_SET_ELEMENT;
            TfltFieldData(TepmFieldTreeNode.Data).RefTable := Trim(ibsqlForeignField.FieldByName('targettable').AsString);
            TfltFieldData(TepmFieldTreeNode.Data).RefField := Trim(ibsqlForeignField.FieldByName('targetfield').AsString);
            FindTable(AnTableName,
             TfltFieldData(TepmFieldTreeNode.Data).FieldName, S,
             TfltFieldData(TepmFieldTreeNode.Data).IsReference,
             TfltFieldData(TepmFieldTreeNode.Data).RefTable);
            TfltFieldData(TepmFieldTreeNode.Data).DisplayName := S;
          {end
          begin
            if ibqryAttrRef.Locate('fieldname', TfltFieldData(TepmFieldTreeNode.Data).FieldName, []) then
            begin
              TfltFieldData(TepmFieldTreeNode.Data).FieldType := GD_DT_ATTR_SET_ELEMENT;
              TfltFieldData(TepmFieldTreeNode.Data).AttrKey := ibqryAttrRef.FieldByName('attrkey').AsInteger;
              TfltFieldData(TepmFieldTreeNode.Data).AttrRefKey := ibqryAttrRef.FieldByName('id').AsInteger;
              TfltFieldData(TepmFieldTreeNode.Data).IsReference := ibqryAttrRef.FieldByName('direct').AsInteger <> 0;
            end;
          end;}
          FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));

          if atDatabase <> nil then
            F := atDatabase.FindRelationField(
              TfltFieldData(TepmFieldTreeNode.Data).TableName, TfltFieldData(TepmFieldTreeNode.Data).FieldName)
          else
            F := nil;

          if F <> nil then
            TfltFieldData(TepmFieldTreeNode.Data).LocalField := Trim(F.LName)
          else
            TfltFieldData(TepmFieldTreeNode.Data).LocalField := '';

          TepmFieldTreeNode.Text := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);

          L := FindLinkTable(TfltFieldData(TepmFieldTreeNode.Data).FieldName,
           TfltFieldData(TepmFieldTreeNode.Data).RefTable);
          if L > -1 then
            if TfltFieldData(TepmFieldTreeNode.Data).LocalField > '' then
              FTableNames[L] := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TfltFieldData(TepmFieldTreeNode.Data).FieldName)
            else
              FTableNames[L] := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);

          TepmOrderTreeNode := FSortList.Items.AddChildObject(OrderTreeNode, TepmFieldTreeNode.Text, TFilterOrderBy.Create);
          TepmOrderTreeNode.ImageIndex := 2;
          FFilterBloksList.Add(TepmOrderTreeNode.Data);
          FillSortItem(TfltFieldData(TepmFieldTreeNode.Data), TFilterOrderBy(TepmOrderTreeNode.Data));
        end;

        // ������ �� ������� ��� ������������ � ��������� �������
        ibsqlSimpleField.SQL.Strings[I] := ibsqlSimpleField.SQL.Strings[I] + ''''
         + Trim(ibsqlForeignField.FieldByName('sourcefield').AsString) + '''';
        ibsqlForeignField.Next;
        ibsqlSimpleField.SQL.Strings[I] := ibsqlSimpleField.SQL.Strings[I] + ','
      end;
      ibsqlSimpleField.SQL.Strings[I] := ibsqlSimpleField.SQL.Strings[I] + '''' + AnPrimaryName + ''')';
    end else
      ibsqlSimpleField.SQL.Add('/**/');

    ibsqlSimpleField.Params[0].AsString := AnTableName;

    // ���������� ������� ����
    ibsqlSimpleField.ExecQuery;
    // ���� ��� ��� � ��� ����� ...
    if ibsqlSimpleField.Eof then
    begin
      // ���������� ����� ���������
      ibsqlSimpleField.Close;
      ibsqlSimpleField.SQL.Text := cProcedureFieldSQL;
      ibsqlSimpleField.Params[0].AsString := AnTableName;
      ibsqlSimpleField.ExecQuery;
    end;

    while not ibsqlSimpleField.Eof do
    begin
      if CheckVisible(AnTableName, Trim(ibsqlSimpleField.FieldByName('fieldname').AsString)) then
      begin
        // ��������� ������� ����
        TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '2_' + Trim(ibsqlSimpleField.FieldByName('fieldname').AsString));
        TepmFieldTreeNode.ImageIndex := 3;
        TepmFieldTreeNode.Data := TfltFieldData.Create;
        FFilterBloksList.Add(TepmFieldTreeNode.Data);
        TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(ibsqlSimpleField.FieldByName('fieldname').AsString);
        TfltFieldData(TepmFieldTreeNode.Data).FieldType := ConvertDataType(ibsqlSimpleField.FieldByName('fieldtype').AsInteger,
         ibsqlSimpleField.FieldByName('fieldsubtype').AsInteger, ibsqlSimpleField.FieldByName('domainname').AsString,
         ibsqlSimpleField.FieldByName('fieldlength').AsInteger);
        FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));

        if atDatabase <> nil then
          F := atDatabase.FindRelationField(
            TfltFieldData(TepmFieldTreeNode.Data).TableName, TfltFieldData(TepmFieldTreeNode.Data).FieldName)
        else
          F := nil;

        if F <> nil then
          TfltFieldData(TepmFieldTreeNode.Data).LocalField := Trim(F.LName)
        else
          TfltFieldData(TepmFieldTreeNode.Data).LocalField := '';

        TepmFieldTreeNode.Text := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);

        TepmOrderTreeNode := FSortList.Items.AddChildObject(OrderTreeNode, TepmFieldTreeNode.Text, TFilterOrderBy.Create);
        TepmOrderTreeNode.ImageIndex := 3;
        FFilterBloksList.Add(TepmOrderTreeNode.Data);
        FillSortItem(TfltFieldData(TepmFieldTreeNode.Data), TFilterOrderBy(TepmOrderTreeNode.Data));
      end;

      ibsqlSimpleField.Next;
    end;

    if not OnlySimpleFields then
    begin
      // ���������� ���������
      ibsqlSetField.Close;
      ibsqlSetField.Params[0].AsString := AnTableName;
      ibsqlSetField.ExecQuery;

      // ���������� Child ����
      ibsqlChildField.Close;
      ibsqlChildField.SQL.Delete(ibsqlChildField.SQL.Count - 1);
      if not ibsqlSetField.Eof then
        I := ibsqlChildField.SQL.Add('AND NOT rc2.RDB$RELATION_NAME IN (')
      else
        I := ibsqlChildField.SQL.Add('/* ������ ���� */');

      while not ibsqlSetField.Eof do
      begin
        if CheckVisible(Trim(ibsqlSetField.FieldByName('nettable').AsString),
         Trim(ibsqlSetField.FieldByName('secondfield').AsString)) then
        begin
          TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '4_' + Trim(ibsqlSetField.FieldByName('nettable').AsString) + '&' + Trim(ibsqlSetField.FieldByName('secondfield').AsString));
          TepmFieldTreeNode.ImageIndex := 5;
          TepmFieldTreeNode.Data := TfltFieldData.Create;
          FFilterBloksList.Add(TepmFieldTreeNode.Data);
          TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(AnPrimaryName);
          TfltFieldData(TepmFieldTreeNode.Data).IsTree := ibsqlSetField.FieldByName('istree').AsInteger = 1;
          TfltFieldData(TepmFieldTreeNode.Data).FieldType := GD_DT_REF_SET;
          TfltFieldData(TepmFieldTreeNode.Data).LinkTable := Trim(ibsqlSetField.FieldByName('nettable').AsString);
          TfltFieldData(TepmFieldTreeNode.Data).LinkSourceField := Trim(ibsqlSetField.FieldByName('firstfield').AsString);
          TfltFieldData(TepmFieldTreeNode.Data).LinkTargetField := Trim(ibsqlSetField.FieldByName('secondfield').AsString);
          TfltFieldData(TepmFieldTreeNode.Data).RefTable := Trim(ibsqlSetField.FieldByName('targettable').AsString);
          TfltFieldData(TepmFieldTreeNode.Data).RefField := Trim(ibsqlSetField.FieldByName('targetfield').AsString);
          FindTable(AnTableName,
           TfltFieldData(TepmFieldTreeNode.Data).FieldName, S,
           TfltFieldData(TepmFieldTreeNode.Data).IsReference,
           TfltFieldData(TepmFieldTreeNode.Data).RefTable);
          TfltFieldData(TepmFieldTreeNode.Data).DisplayName := S;
          FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));

          if atDatabase <> nil then
            F := atDatabase.FindRelationField(
              TfltFieldData(TepmFieldTreeNode.Data).LinkTable, TfltFieldData(TepmFieldTreeNode.Data).LinkTargetField)
          else
            F := nil;

          if F <> nil then
            TfltFieldData(TepmFieldTreeNode.Data).LocalField := Trim(F.LName)
          else
            TfltFieldData(TepmFieldTreeNode.Data).LocalField := '';

          TepmFieldTreeNode.Text := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);
        end;

        // ������ �� ������� ������������ � ���������
        ibsqlChildField.SQL.Strings[I] := ibsqlChildField.SQL.Strings[I] + ''''
         + Trim(ibsqlSetField.FieldByName('nettable').AsString) + '''';

        ibsqlSetField.Next;

        if not ibsqlSetField.Eof then
          ibsqlChildField.SQL.Strings[I] := ibsqlChildField.SQL.Strings[I] + ','
        else
          ibsqlChildField.SQL.Strings[I] := ibsqlChildField.SQL.Strings[I] + ')';
      end;

      ibsqlChildField.Params[0].AsString := AnTableName;
      ibsqlChildField.ExecQuery;
      while not ibsqlChildField.Eof do
      begin
        // ��������� ������� ����
        if {FMainWindow or (ibsqlChildField.FieldByName('iscircle').AsInteger <> 1) and}
         CheckVisible(Trim(ibsqlChildField.FieldByName('targettable').AsString),
         Trim(ibsqlChildField.FieldByName('targetfield').AsString)) then
        begin
          TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '5_' + Trim(ibsqlChildField.FieldByName('targettable').AsString) + '&' + Trim(ibsqlChildField.FieldByName('targetfield').AsString));
          TepmFieldTreeNode.ImageIndex := 6;
          TepmFieldTreeNode.Data := TfltFieldData.Create;
          FFilterBloksList.Add(TepmFieldTreeNode.Data);
          TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(ibsqlChildField.FieldByName('sourcefield').AsString);
          TfltFieldData(TepmFieldTreeNode.Data).FieldType := GD_DT_CHILD_SET;
          TfltFieldData(TepmFieldTreeNode.Data).IsTree := ibsqlChildField.FieldByName('istree').AsInteger = 1;
          TfltFieldData(TepmFieldTreeNode.Data).LinkTable := Trim(ibsqlChildField.FieldByName('targettable').AsString);
          TfltFieldData(TepmFieldTreeNode.Data).LinkSourceField := Trim(ibsqlChildField.FieldByName('targetfield').AsString);
          TfltFieldData(TepmFieldTreeNode.Data).LinkTargetField := Trim(ibsqlChildField.FieldByName('targetprimary').AsString);
          FindTable(AnTableName,
           TfltFieldData(TepmFieldTreeNode.Data).FieldName, S,
           TfltFieldData(TepmFieldTreeNode.Data).IsReference,
           TfltFieldData(TepmFieldTreeNode.Data).LinkTable);
          TfltFieldData(TepmFieldTreeNode.Data).DisplayName := S;
          FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));

          if atDatabase <> nil then
            F := atDatabase.FindRelationField(
              TfltFieldData(TepmFieldTreeNode.Data).LinkTable, TfltFieldData(TepmFieldTreeNode.Data).LinkSourceField)
          else
            F := nil;

          if F <> nil then
            TfltFieldData(TepmFieldTreeNode.Data).LocalField := Trim(F.LName)
          else
            TfltFieldData(TepmFieldTreeNode.Data).LocalField := '';

          TepmFieldTreeNode.Text := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);
        end;

        ibsqlChildField.Next;
      end;
    end;

    ibsqlSortFields.Close;
    ibsqlSortFields.Params[0].AsString := AnTableName;
    ibsqlSortFields.ExecQuery;
    TepmOrderTreeNode := FIndexList.Items.AddObject(nil, AnLocalTable, TFilterOrderBy.Create);
    FFilterBloksList.Add(TepmOrderTreeNode.Data);
    OrderTreeNode.Data := TepmOrderTreeNode;
    OrderTreeNode := TepmOrderTreeNode;
    OrderTreeNode.ImageIndex := 1;
    while not ibsqlSortFields.Eof do
    begin
      // ��������� ������ ����� ��� ����������
      TepmOrderTreeNode := FIndexList.Items.AddChildObject(OrderTreeNode, '6_' + Trim(ibsqlSortFields.FieldByName('fieldname').AsString),
       TFilterOrderBy.Create);
      FFilterBloksList.Add(TepmOrderTreeNode.Data);
      TepmOrderTreeNode.ImageIndex := 2;
      TFilterOrderBy(TepmOrderTreeNode.Data).TableName := AnTableName;
      TFilterOrderBy(TepmOrderTreeNode.Data).TableAlias := AnTableAlias;
      TFilterOrderBy(TepmOrderTreeNode.Data).FieldName := CheckFieldName(ibsqlSortFields.FieldByName('fieldname').AsString);

      if atDatabase <> nil then
        F := atDatabase.FindRelationField(TFilterOrderBy(TepmOrderTreeNode.Data).TableName,
          TFilterOrderBy(TepmOrderTreeNode.Data).FieldName)
      else
        F := nil;

      if F <> nil then
        TFilterOrderBy(TepmOrderTreeNode.Data).LocalField := Trim(F.LName);

      TFilterOrderBy(TepmOrderTreeNode.Data).IsAscending := ibsqlSortFields.FieldByName('asctype').AsInteger <> 1;

      TepmOrderTreeNode.Text := GetFieldName(TFilterOrderBy(TepmOrderTreeNode.Data).LocalField, TepmOrderTreeNode.Text);

      ibsqlSortFields.Next;
    end;

    // ��������� ������ ������ ��������� ���������
    {ibqryAttrRef.First;
    while not ibqryAttrRef.Eof do
    begin
      if (ibqryAttrRef.FieldByName('attrtype').AsString = FReferenceLabel) and
       (ibqryAttrRef.FieldByName('setelement').AsInteger = 0) then
      begin
        TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '7_' + Trim(ibqryAttrRef.FieldByName('label').AsString));
        TepmFieldTreeNode.ImageIndex := 7;
        TepmFieldTreeNode.Data := TfltFieldData.Create;
        FFilterBloksList.Add(TepmTreeNode.Data);
        TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(AnPrimaryName);
        TfltFieldData(TepmFieldTreeNode.Data).FieldType := GD_DT_ATTR_SET;
        TfltFieldData(TepmFieldTreeNode.Data).AttrKey := ibqryAttrRef.FieldByName('attrkey').AsInteger;
        TfltFieldData(TepmFieldTreeNode.Data).AttrRefKey := ibqryAttrRef.FieldByName('id').AsInteger;
        TfltFieldData(TepmFieldTreeNode.Data).IsReference := ibqryAttrRef.FieldByName('direct').AsInteger <> 0;

        FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));
      end;

      ibqryAttrRef.Next;
    end;}
  except
    //Result := False;
  end;
end;
{$ELSE}
const
  FReferenceLabel = 'R';

var
  AnPrimaryName, AnLocalTable, S, ExclFields: String;
  L, J: Integer;
  OrderTreeNode, TepmOrderTreeNode, TepmFieldTreeNode, TableTreeNode: TTreeNode;
  F: TatRelationField;
  R: TatRelation;
  OnlySimpleFields: Boolean;
  Lst: TObjectList;
  FK: TatForeignKey;

  // ������� ���� �� ������������ ������� � ���� ������� � �������
  function FindLinkTable(const SForeignField, STableName: String): Integer;
  var
    M, N: Integer;
    TTN, TFF: String;
  begin
    Result := -1;
    TTN := AnsiUpperCase(STableName);
    TFF := AnsiUpperCase(AnTableAlias + SForeignField);
    for M := 0 to FTableList.Count - 1 do
      if AnsiUpperCase(FTableList.Names[M]) = TTN then
        for N := 0 to FConditionLink.Count - 1 do
          if (((FConditionLink.Names[N] = TFF) and
           (Pos(AnsiUpperCase(FTableList.ValuesOfIndex[M]), FConditionLink.ValuesOfIndex[N]) = 1)) or
           ((FConditionLink.ValuesOfIndex[N] = TFF) and
           (Pos(AnsiUpperCase(FTableList.ValuesOfIndex[M]), FConditionLink.Names[N]) = 1))) then
          begin
            FConditionLink.Delete(N);
            Result := M;
            Exit;
          end;
  end;

  // ���������� �������� ����� � ���������
  procedure FillMainFields(const AnFieldData: TfltFieldData);
  begin
    AnFieldData.TableName := AnTableName;
    AnFieldData.TableAlias := AnTableAlias;
    AnFieldData.LocalTable := AnLocalTable;
  end;

  // ���������� ����� ��� ���������� ���������� �� ����� ��� ����������
  procedure FillSortItem(const AnFieldData: TfltFieldData; const AnOrderByData: TFilterOrderBy);
  begin
    AnOrderByData.TableName := AnFieldData.TableName;
    AnOrderByData.TableAlias := AnFieldData.TableAlias;
    AnOrderByData.FieldName := AnFieldData.FieldName;
    AnOrderByData.LocalField := AnFieldData.LocalField;
    AnOrderByData.IsAscending := True;
  end;

  function GetFieldName(const AnLocalName, AnOriginalName: String): String;
  begin
    case fltFieldNameMode of
      fnmOriginal: Result := AnOriginalName;
      fnmLocalize: Result := AnLocalName;
      fnmDuplex: Result := AnLocalName + ' (' + AnOriginalName + ')';
    else
      Assert(False, 'Filter Field Name Mode not suported.');
    end;
  end;
begin
  Result := nil;
  try
    if atDatabase <> nil then
      R := atDatabase.Relations.ByRelationName(AnTableName)
    else
      R := nil;

    if R <> nil then
    begin
      AnLocalTable := R.LName;
      if AnLocalTable = '' then
        AnLocalTable := AnTableName;
    end else
      AnLocalTable := AnTableName;

    // ���������� ������ ������
    AnLocalTable := GetFieldName(AnLocalTable, AnTableName);

    // ���������� PRIMARY KEY
    OnlySimpleFields := False;
    if R <> nil then
    begin
      if (R.PrimaryKey <> nil) and (R.PrimaryKey.ConstraintFields.Count = 1) then
      begin
        AnPrimaryName := R.PrimaryKey.ConstraintFields[0].FieldName;
      end else
        OnlySimpleFields := True;
    end;

    OrderTreeNode := FSortList.Items.AddObject(nil, AnLocalTable, nil);
    OrderTreeNode.ImageIndex := 1;
    TableTreeNode := FFieldList.Items.AddObject(nil, AnLocalTable, OrderTreeNode);
    Result := TableTreeNode;
    TableTreeNode.ImageIndex := 1;

    TepmOrderTreeNode := FSortList.Items.AddChildObject(OrderTreeNode, AnPrimaryName, TFilterOrderBy.Create);
    TepmOrderTreeNode.ImageIndex := 3;
    FFilterBloksList.Add(TepmOrderTreeNode.Data);
    TFilterOrderBy(TepmOrderTreeNode.Data).TableName := AnTableName;
    TFilterOrderBy(TepmOrderTreeNode.Data).TableAlias := AnTableAlias;
    TFilterOrderBy(TepmOrderTreeNode.Data).FieldName := CheckFieldName(AnPrimaryName);
    if atDatabase <> nil then
      F := atDatabase.FindRelationField(TFilterOrderBy(TepmOrderTreeNode.Data).TableName,
        TFilterOrderBy(TepmOrderTreeNode.Data).FieldName)
    else
      F := nil;
    if F <> nil then
      TFilterOrderBy(TepmOrderTreeNode.Data).LocalField := Trim(F.LName);
    TFilterOrderBy(TepmOrderTreeNode.Data).IsAscending := True;
    TepmOrderTreeNode.Text := GetFieldName(TFilterOrderBy(TepmOrderTreeNode.Data).LocalField, TepmOrderTreeNode.Text);

    // ���������� FOREIGN KEY
    ExclFields := '"AFULL""ACHAG""AVIEW""LB""RB"';
    if not OnlySimpleFields then
    begin
      Lst := TObjectList.Create(False);
      try
        atDatabase.ForeignKeys.ConstraintsByRelation(AnTableName, Lst);
        for J := 0 to Lst.Count - 1 do
        begin
          FK := Lst[J] as TatForeignKey;

          if not FK.IsSimpleKey then
            continue;

          if CheckVisible(AnTableName, FK.ConstraintFields[0].FieldName) then
          begin
            TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '1_' + FK.ConstraintFields[0].FieldName);
            TepmFieldTreeNode.ImageIndex := 2;
            TepmFieldTreeNode.Data := TfltFieldData.Create;
            FFilterBloksList.Add(TepmFieldTreeNode.Data);
            // ��������� ���� FOREIGN KEY
            TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(FK.ConstraintFields[0].FieldName);
            TfltFieldData(TepmFieldTreeNode.Data).IsTree := FK.ReferencesRelation.IsLBRBTreeRelation;
            TfltFieldData(TepmFieldTreeNode.Data).FieldType := GD_DT_REF_SET_ELEMENT;
            TfltFieldData(TepmFieldTreeNode.Data).RefTable := FK.ReferencesRelation.RelationName;
            TfltFieldData(TepmFieldTreeNode.Data).RefField := FK.ReferencesFields[0].FieldName;
            FindTable(AnTableName,
             TfltFieldData(TepmFieldTreeNode.Data).FieldName, S,
             TfltFieldData(TepmFieldTreeNode.Data).IsReference,
             TfltFieldData(TepmFieldTreeNode.Data).RefTable);
            TfltFieldData(TepmFieldTreeNode.Data).DisplayName := S;
            FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));

            TfltFieldData(TepmFieldTreeNode.Data).LocalField := FK.ConstraintFields[0].LName;

            TepmFieldTreeNode.Text := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);

            L := FindLinkTable(TfltFieldData(TepmFieldTreeNode.Data).FieldName,
             TfltFieldData(TepmFieldTreeNode.Data).RefTable);
            if L > -1 then
              if TfltFieldData(TepmFieldTreeNode.Data).LocalField > '' then
                FTableNames[L] := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TfltFieldData(TepmFieldTreeNode.Data).FieldName)
              else
                FTableNames[L] := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);

            TepmOrderTreeNode := FSortList.Items.AddChildObject(OrderTreeNode, TepmFieldTreeNode.Text, TFilterOrderBy.Create);
            TepmOrderTreeNode.ImageIndex := 2;
            FFilterBloksList.Add(TepmOrderTreeNode.Data);
            FillSortItem(TfltFieldData(TepmFieldTreeNode.Data), TFilterOrderBy(TepmOrderTreeNode.Data));
          end;

          ExclFields := ExclFields + '"' + FK.ConstraintFields[0].FieldName + '"';
        end;
      finally
        Lst.Free;
      end;

      ExclFields := ExclFields + '"' + AnPrimaryName + '"';
    end;

    if R <> nil then
    begin
      for J := 0 to R.RelationFields.Count - 1 do
      begin
        if Pos('"' + R.RelationFields[J].FieldName + '"', ExclFields) <> 0 then
          continue;

        if CheckVisible(AnTableName, R.RelationFields[J].FieldName) then
        begin
          // ��������� ������� ����
          TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '2_' + R.RelationFields[J].FieldName);
          TepmFieldTreeNode.ImageIndex := 3;
          TepmFieldTreeNode.Data := TfltFieldData.Create;
          FFilterBloksList.Add(TepmFieldTreeNode.Data);
          TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(R.RelationFields[J].FieldName);
          TfltFieldData(TepmFieldTreeNode.Data).FieldType := ConvertDataType(R.RelationFields[J].Field.SQLType,
           R.RelationFields[J].Field.SQLSubType, R.RelationFields[J].Field.FieldName,
           R.RelationFields[J].Field.FieldLength);
          FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));

          TfltFieldData(TepmFieldTreeNode.Data).LocalField := R.RelationFields[J].LName;

          TepmFieldTreeNode.Text := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);

          TepmOrderTreeNode := FSortList.Items.AddChildObject(OrderTreeNode, TepmFieldTreeNode.Text, TFilterOrderBy.Create);
          TepmOrderTreeNode.ImageIndex := 3;
          FFilterBloksList.Add(TepmOrderTreeNode.Data);
          FillSortItem(TfltFieldData(TepmFieldTreeNode.Data), TFilterOrderBy(TepmOrderTreeNode.Data));
        end;
      end;
    end; {else R = nil

      ��� ���������! �� ���� �� ������������!

      // ���������� ����� ���������
      ibsqlSimpleField.Close;
      ibsqlSimpleField.SQL.Text := cProcedureFieldSQL;
      ibsqlSimpleField.Params[0].AsString := AnTableName;
      ibsqlSimpleField.ExecQuery;}

    if not OnlySimpleFields then
    begin
      Lst := TObjectList.Create(False);
      try
        atDatabase.ForeignKeys.ConstraintsByReferencedRelation(AnTableName, Lst,
          True, False, True);

        for J := 0 to Lst.Count - 1 do
        begin
          FK := Lst[J] as TatForeignKey;

          if CheckVisible(FK.Relation.RelationName,
            FK.Relation.PrimaryKey.ConstraintFields[1].FieldName) then
          begin
            TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '4_' + FK.Relation.RelationName + '&' + FK.Relation.PrimaryKey.ConstraintFields[1].FieldName);
            TepmFieldTreeNode.ImageIndex := 5;
            TepmFieldTreeNode.Data := TfltFieldData.Create;
            FFilterBloksList.Add(TepmFieldTreeNode.Data);
            TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(AnPrimaryName);
            TfltFieldData(TepmFieldTreeNode.Data).IsTree := FK.Relation.PrimaryKey.ConstraintFields[1].References.IsLBRBTreeRelation;
            TfltFieldData(TepmFieldTreeNode.Data).FieldType := GD_DT_REF_SET;
            TfltFieldData(TepmFieldTreeNode.Data).LinkTable := FK.Relation.RelationName;
            TfltFieldData(TepmFieldTreeNode.Data).LinkSourceField := FK.Relation.PrimaryKey.ConstraintFields[0].FieldName;
            TfltFieldData(TepmFieldTreeNode.Data).LinkTargetField := FK.Relation.PrimaryKey.ConstraintFields[1].FieldName;
            TfltFieldData(TepmFieldTreeNode.Data).RefTable := FK.Relation.PrimaryKey.ConstraintFields[1].References.RelationName;
            TfltFieldData(TepmFieldTreeNode.Data).RefField := FK.Relation.PrimaryKey.ConstraintFields[1].ReferencesField.FieldName;
            FindTable(AnTableName,
             TfltFieldData(TepmFieldTreeNode.Data).FieldName, S,
             TfltFieldData(TepmFieldTreeNode.Data).IsReference,
             TfltFieldData(TepmFieldTreeNode.Data).RefTable);
            TfltFieldData(TepmFieldTreeNode.Data).DisplayName := S;
            FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));

            TfltFieldData(TepmFieldTreeNode.Data).LocalField := FK.Relation.PrimaryKey.ConstraintFields[1].LName;

            TepmFieldTreeNode.Text := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);
          end;
        end;

        atDatabase.ForeignKeys.ConstraintsByReferencedRelation(AnTableName, Lst,
          True, True, False);
        for J := 0 to Lst.Count - 1 do
        begin
          FK := Lst[J] as TatForeignKey;

          if FK.Relation.PrimaryKey = nil then
            continue;

          if CheckVisible(FK.Relation.RelationName, FK.ConstraintFields[0].FieldName) then
          begin
            TepmFieldTreeNode := FFieldList.Items.AddChild(TableTreeNode, '5_' + FK.Relation.RelationName + '&' + FK.ConstraintFields[0].FieldName);
            TepmFieldTreeNode.ImageIndex := 6;
            TepmFieldTreeNode.Data := TfltFieldData.Create;
            FFilterBloksList.Add(TepmFieldTreeNode.Data);
            TfltFieldData(TepmFieldTreeNode.Data).FieldName := CheckFieldName(FK.ReferencesFields[0].FieldName);
            TfltFieldData(TepmFieldTreeNode.Data).FieldType := GD_DT_CHILD_SET;
            TfltFieldData(TepmFieldTreeNode.Data).IsTree := FK.Relation.IsLBRBTreeRelation;
            TfltFieldData(TepmFieldTreeNode.Data).LinkTable := FK.Relation.RelationName;
            TfltFieldData(TepmFieldTreeNode.Data).LinkSourceField := FK.ConstraintFields[0].FieldName;
            TfltFieldData(TepmFieldTreeNode.Data).LinkTargetField := FK.Relation.PrimaryKey.ConstraintFields[0].FieldName;
            FindTable(AnTableName,
             TfltFieldData(TepmFieldTreeNode.Data).FieldName, S,
             TfltFieldData(TepmFieldTreeNode.Data).IsReference,
             TfltFieldData(TepmFieldTreeNode.Data).LinkTable);
            TfltFieldData(TepmFieldTreeNode.Data).DisplayName := S;
            FillMainFields(TfltFieldData(TepmFieldTreeNode.Data));

            TfltFieldData(TepmFieldTreeNode.Data).LocalField := FK.ConstraintFields[0].LName;

            TepmFieldTreeNode.Text := GetFieldName(TfltFieldData(TepmFieldTreeNode.Data).LocalField, TepmFieldTreeNode.Text);
          end;
        end;
      finally
        Lst.Free;
      end;
    end;

    ibsqlSortFields.Close;
    ibsqlSortFields.Params[0].AsString := AnTableName;
    ibsqlSortFields.ExecQuery;
    TepmOrderTreeNode := FIndexList.Items.AddObject(nil, AnLocalTable, TFilterOrderBy.Create);
    FFilterBloksList.Add(TepmOrderTreeNode.Data);
    OrderTreeNode.Data := TepmOrderTreeNode;
    OrderTreeNode := TepmOrderTreeNode;
    OrderTreeNode.ImageIndex := 1;
    while not ibsqlSortFields.Eof do
    begin
      // ��������� ������ ����� ��� ����������
      TepmOrderTreeNode := FIndexList.Items.AddChildObject(OrderTreeNode, '6_' + Trim(ibsqlSortFields.FieldByName('fieldname').AsString),
       TFilterOrderBy.Create);
      FFilterBloksList.Add(TepmOrderTreeNode.Data);
      TepmOrderTreeNode.ImageIndex := 2;
      TFilterOrderBy(TepmOrderTreeNode.Data).TableName := AnTableName;
      TFilterOrderBy(TepmOrderTreeNode.Data).TableAlias := AnTableAlias;
      TFilterOrderBy(TepmOrderTreeNode.Data).FieldName := CheckFieldName(ibsqlSortFields.FieldByName('fieldname').AsString);

      if atDatabase <> nil then
        F := atDatabase.FindRelationField(TFilterOrderBy(TepmOrderTreeNode.Data).TableName,
          TFilterOrderBy(TepmOrderTreeNode.Data).FieldName)
      else
        F := nil;

      if F <> nil then
        TFilterOrderBy(TepmOrderTreeNode.Data).LocalField := Trim(F.LName);

      TFilterOrderBy(TepmOrderTreeNode.Data).IsAscending := ibsqlSortFields.FieldByName('asctype').AsInteger <> 1;

      TepmOrderTreeNode.Text := GetFieldName(TFilterOrderBy(TepmOrderTreeNode.Data).LocalField, TepmOrderTreeNode.Text);

      ibsqlSortFields.Next;
    end;
  except
    //Result := False;
  end;
end;
{$ENDIF}

// ���������� ShowFilter ������ ��� ��������� ������. ��� ������������.
function TdlgShowFilter.ShowLinkTableFilter(const AnConditionList: TFilterConditionList;
 const AnTableName, AnLinkField: String): Boolean;
var
  I: Integer;
  ConditionData: TFilterCondition;
begin
  if AnConditionList.IsAndCondition then
    rbAND.Checked := True
  else
    rbOR.Checked := True;
  cbDistinct.Visible := False;
  FullIBParams;
  FMainWindow := False;
  Result := False;

  FEnableOrder := False;
  tsOrder.TabVisible := False;
  btnSaveFilter.Visible := False;
  tsName.TabVisible := False;
  tsSQL.TabVisible := False;

  if not FMainWindow then
  begin
    Position := poDesigned;
    Left := (Owner as TFrame).Parent.Parent.Parent.Parent.Left + 10;
    Top := (Owner as TFrame).Parent.Parent.Parent.Parent.Top + 10;
  end;

  pcOrderFilter.ActivePage := tsFilter;

  Caption := '������������ ������� ��� ������� ' + AnTableName;
  ClearFieldList;

  OpenSimpleQuery(nil, AnsiUpperCase(AnTableName), AnsiUpperCase(AnLinkField));

  // ��������� ����
  for I := 0 to AnConditionList.Count - 1 do
  begin
    ConditionData := AnConditionList.Conditions[I];
    AddFilterLine;
    SetCondition(FFilterList.Count - 1, ConditionData);
  end;
  // ��������� ���� ���� ���� ���� ����
  if (AnConditionList.Count = 0 ) then
    AddFilterLine;

  // �������� ������
  if ShowModal = mrOk then
  begin
    AnConditionList.Clear;
    // ��������� ���� ������
    CompliteFilterData(AnConditionList, nil);

    Result := True;
  end;

  ClearFilterLine;
end;

// ��������� �������
function TdlgShowFilter.AddFilter(const AnComponentKey: Integer; const AnSQLText: String;
 const AnNoVisibleList: TStrings; const AnIsFill: Boolean; out AnIsNewFilter: Boolean): Integer;
var
  LocFilterData: TFilterData;
  LocBlobStream: TIBDSBlobStream;
  LocTableList, LocLinkCondition: TfltStringList;
begin
  Result := 0;
  LocFilterData := TFilterData.Create;
  FComponentKey := AnComponentKey;
  FSQLText := AnSQLText;
  try
    // ��������� ����� �� ��������
    if {gs}False then
    begin
      MessageBox(Self.Handle, '� ��� ��� ���� ��������� ������.', '��������', MB_OK or MB_ICONWARNING);
      Exit;
    end;

    // ��������� ������
    ibdsFilter.Close;
    ibdsFilter.Database := Database;
    ibdsFilter.Transaction := Transaction;
    ibdsFilter.Params[0].AsInteger := 0;
    ibdsFilter.Open;

    // ��������� ������
    ibdsFilter.Insert;
    LocTableList := TfltStringList.Create;
    try
      LocLinkCondition := TfltStringList.Create;
      try
        // ��������� ������ �������
        ExtractFieldLink(AnSQLText, LocLinkCondition);
        // ��������� ������ ������
        ExtractTablesList(AnSQLText, LocTableList);
        // �������� ����� �� ���������
        ibdsFilter.FieldByName('name').AsString := '��� �����';
        ibdsFilter.FieldByName('lastextime').AsDateTime := 0;
        ibdsFilter.FieldByName('afull').AsInteger := GetIngroup or 1;
        ibdsFilter.FieldByName('achag').AsInteger := GetIngroup or 1;
        ibdsFilter.FieldByName('aview').AsInteger := -1;
        // ����� ���� ��������
        ibsqlGetID.Close;
        ibsqlGetID.Database := Database;
        ibsqlGetID.Transaction := Transaction;
        ibsqlGetID.ExecQuery;
        ibdsFilter.FieldByName('id').AsInteger := ibsqlGetID.Fields[0].AsInteger;
        ibdsFilter.FieldByName('componentkey').AsInteger := AnComponentKey;

        FMainWindow := True;
        FIsNewFilter := False;

        // �������� ��������� ��������� ���������� �������
        if ShowFilter(LocFilterData.ConditionList, LocFilterData.OrderByList,
         AnNoVisibleList, LocTableList, LocLinkCondition, AnIsFill) then
        begin
          // ��������� ��� ������
          try
            // Thanks to Julia ...
            if Assigned(ibdsFilter.FindField('editorkey')) then
              ibdsFilter.FieldByName('editorkey').Required := False;
            if Assigned(ibdsFilter.FindField('editiondate')) then
              ibdsFilter.FieldByName('editiondate').Required := False;

            if cbOnlyForMe.Checked and (GetUserKey <> -1) then
            begin
              ibdsFilter.FieldByName('userkey').AsInteger := GetUserKey;
              // Thanks to Julia ...
              if Assigned(ibdsFilter.FindField('editorkey')) then
                ibdsFilter.FieldByName('editorkey').AsInteger :=
                 ibdsFilter.FieldByName('userkey').AsInteger;
            end;

            LocBlobStream := ibdsFilter.CreateBlobStream(ibdsFilter.FieldByName('data'), bmReadWrite) as TIBDSBlobStream;
            try
              LocFilterData.WriteToStream(LocBlobStream);
            finally
              LocBlobStream.Free;
            end;
            ibdsFilter.Post;
            Result := ibdsFilter.FieldByName('id').AsInteger;
            FIsNewFilter := True;
          except
            on E: Exception do
            begin
              MessageBox(Self.Handle, PChar('��������� ������ ��� ���������� �������:'#13#10 +
               E.Message), '������', MB_OK or MB_ICONERROR);
              ibdsFilter.Cancel;
            end;
          end;
        end else
          ibdsFilter.Cancel;
      finally
        AnIsNewFilter := FIsNewFilter;
        LocLinkCondition.Free;
        FMainWindow := False;
      end;
    finally
      LocTableList.Free;
    end;
  finally
    LocFilterData.Free;
    FSQLText := '';
  end;
end;

// �������������� �������
function TdlgShowFilter.EditFilter(const FilterKey: Integer; const AnSQLText: String;
 const AnNoVisibleList: TStrings; const AnIsFill: Boolean; out AnIsNewFilter: Boolean): Integer;
var
  LocFilterData: TFilterData;
  LocBlobStream: TIBDSBlobStream;
  LocTableList, LocLinkCondition: TfltStringList;
begin
  Result := 0;
  FSQLText := AnSQLText;
  LocFilterData := TFilterData.Create;
  try
    // ���� ������
    ibdsFilter.Close;
    ibdsFilter.Database := Database;
    ibdsFilter.Transaction := Transaction;
    ibdsFilter.Params[0].AsInteger := FilterKey;
    ibdsFilter.Open;
    if not ibdsFilter.Eof then
    begin
      // ��������� �����
      if ((ibdsFilter.FieldByName('afull').AsInteger or
       ibdsFilter.FieldByName('achag').AsInteger) and GetIngroup = 0) and
       (ibdsFilter.FieldByName('userkey').AsInteger = 0) then
      begin
        MessageBox(Self.Handle, '� ��� ��� ���� ������������� ������ ������.', '��������', MB_OK or MB_ICONWARNING);
        Exit;
      end;

      // ������������� ����������� ���������
      FComponentKey := ibdsFilter.FieldByName('componentkey').AsInteger;

      ibdsFilter.Edit;
      LocBlobStream := ibdsFilter.CreateBlobStream(ibdsFilter.FieldByName('data'), bmRead) as TIBDSBlobStream;
      try
        LocFilterData.ReadFromStream(LocBlobStream);
      finally
        LocBlobStream.Free;
      end;

      LocTableList := TfltStringList.Create;
      try
        LocLinkCondition := TfltStringList.Create;
        try
          ExtractFieldLink(AnSQLText, LocLinkCondition);
          ExtractTablesList(AnSQLText, LocTableList);
          FMainWindow := True;
          FIsNewFilter := False;
          cbOnlyForMe.Checked := not ibdsFilter.FieldByName('userkey').IsNull;

          // �������� ��������� ��������� ������� �������
          if ShowFilter(LocFilterData.ConditionList, LocFilterData.OrderByList,
           AnNoVisibleList, LocTableList, LocLinkCondition, AnIsFill) then
          begin
            // ��������� ��� ���������
            try
              if cbOnlyForMe.Checked and (GetUserKey <> -1) then
                ibdsFilter.FieldByName('userkey').AsInteger := GetUserKey
              else
                ibdsFilter.FieldByName('userkey').AsVariant := NULL;
              LocBlobStream := ibdsFilter.CreateBlobStream(ibdsFilter.FieldByName('data'), bmWrite) as TIBDSBlobStream;
              try
                LocFilterData.WriteToStream(LocBlobStream);
              finally
                FreeAndNil(LocBlobStream);
              end;
              ibdsFilter.Post;
              Result := ibdsFilter.FieldByName('id').AsInteger;
              FIsNewFilter := True;
            except
              on E: Exception do
              begin
                MessageBox(Self.Handle, PChar('��������� ������ ��� ���������� �������:'#13#10 +
                 E.Message), '������', MB_OK or MB_ICONERROR);
                ibdsFilter.Cancel;
              end;
            end;
          end else
            ibdsFilter.Cancel;
        finally
          AnIsNewFilter := FIsNewFilter;
          LocLinkCondition.Free;
          FMainWindow := False;
        end;
      finally
        LocTableList.Free;
      end;

    end else
    begin
      MessageBox(Self.Handle, '��������� ������ �� ������.', '��������������', MB_OK or MB_ICONWARNING);
      Result := 0;
    end;
  finally
    LocFilterData.Free;
    FSQLText := '';
  end;
end;

// ������� ������
function TdlgShowFilter.DeleteFilter(const FilterKey: Integer): Boolean;
begin
  Result := False;
  // ���� ������
  ibdsFilter.Close;
  ibdsFilter.Database := Database;
  ibdsFilter.Transaction := Transaction;
  ibdsFilter.Params[0].AsInteger := FilterKey;
  ibdsFilter.Open;
  if not ibdsFilter.Eof then
  begin
    // ��������� �����
    if ibdsFilter.FieldByName('afull').AsInteger and GetIngroup = 0 then
    begin
      MessageBox(0,
        '� ��� ��� ���� ������� ������ ������.',
        '��������',
        MB_OK or MB_ICONWARNING or MB_TASKMODAL);
      Exit;
    end;

    // ������������� ��������
    if MessageBox(0,
      PChar(Format('�� ������������� ������ ������� ������ ''%s''?', [ibdsFilter.FieldByName('name').AsString])),
      '��������',
      MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
    try
      ibdsFilter.Delete;
      Result := True;
    except
      // ��������� ������
      on E: Exception do
        MessageBox(0,
          PChar('��������� ������ ��� �������� �������:'#13#10
            + E.Message),
          '������',
          MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  end else
  begin
    MessageBox(0,
      '��������� ������ �� ������.',
      '��������������',
      MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    Result := True;
  end;
end;

// ������� ��������� �����
function TdlgShowFilter.ShowFilter(const AnConditionList: TFilterConditionList; const AnOrderByList: TFilterOrderByList;
 const AnNoVisibleList: TStrings; const AnTableList, AnLinkCondition: TfltStringList; const AnIsFill: Boolean): Boolean;
var
  I: Integer;
  ConditionData: TFilterCondition;
  OrderLine: TFilterOrderBy;
  TempTreeNode: TTreeNode;
begin
  FIsIndexField := False;
  // ����������� ������ �� ������� �����
  if AnNoVisibleList <> nil then
    FNoVisibleList.Assign(AnNoVisibleList);
  // ����������� ������ ������
  FTableList.Assign(AnTableList);
  // ����������� ������ �������
  if AnLinkCondition <> nil then
    FConditionLink.Assign(AnLinkCondition);
  // ������������� ������� �����������
  if AnConditionList.IsAndCondition then
    rbAND.Checked := True
  else
    rbOR.Checked := True;
  // Distinct
  cbDistinct.Visible := FMainWindow;
  cbDistinct.Checked := AnConditionList.IsDistinct;
  // ����������� ��������� �����������
  FullIBParams;
  Result := False;

  // ���������� ����������� ����������
  FEnableOrder := AnOrderByList <> nil;
  // ����������� ����� ������ ��� �������� ����
  tsOrder.TabVisible := FEnableOrder and FMainWindow;
  tsSQL.TabVisible := tsOrder.TabVisible;
  tsName.TabVisible := tsOrder.TabVisible;

  // ����������� �������� ������ ������� ���� ������ ��� �������� ����
  btnSaveFilter.Visible := FMainWindow;

  // ���� ������� ���� �� ������� �������� � ������ �������
  if FMainWindow then
    pcOrderFilter.ActivePage := tsName
  else
    if FEnableOrder then
    begin
      if AnConditionList.Count < AnOrderByList.Count then
        pcOrderFilter.ActivePage := tsOrder
      else
        pcOrderFilter.ActivePage := tsFilter;
    end;

  if not FMainWindow and (Owner <> nil) and (Owner is TFrame) then
  begin
    Position := poDesigned;
    Left := (Owner as TFrame).Parent.Parent.Parent.Parent.Left + 10;
    Top := (Owner as TFrame).Parent.Parent.Parent.Parent.Top + 10;
  end;

  // ���� ���� ��� �� ������� ��� ���� ������� ������
  if not(AnIsFill and FIsFill) then
  begin
    Caption := '������������ ������� ��� ������� ';
    // ������� ������ �����
    ClearFieldList;
    // ��������� �������
    if not FIsFill then
      ReadFunctions;
    // ����������� ����� ������� ���� ������ � ������� ����
    if FMainWindow then
    begin
      TempTreeNode := FFieldList.Items.AddObject(nil, '�������', TfltFieldData.Create);
      FFilterBloksList.Add(TempTreeNode.Data);
      TfltFieldData(TempTreeNode.Data).FieldType := GD_DT_FORMULA;
      TfltFieldData(TempTreeNode.Data).LocalField := '�������';
    end;
    // ������� ������ ����� ��� ����������
    ClearSortList;
    // ������� ������ ��������������� ����� ��� ����������
    ClearIndexList;
    // ������������� ����� ������� ������ ������ ���������� ������
    SetLength(FTableNames, AnTableList.Count);
    // ���������� ���������� ����� ��� ���� ������
    for I := 0 to AnTableList.Count - 1 do
    begin
      //if not
      AnTableList.Objects[I] := OpenQuery(AnsiUpperCase(AnTableList.Names[I]), AnsiUpperCase(AnTableList.ValuesOfIndex[I]));// then
      //  Exit;
    end;
    // ������ ������������ ������, ���� ����
    for I := 0 to AnTableList.Count - 1 do
    begin
      if AnTableList.Objects[I] <> nil then
      begin
        if FTableNames[I] > '' then
        begin
          TTreeNode(AnTableList.Objects[I]).Text := FTableNames[I];
          TTreeNode(TTreeNode(AnTableList.Objects[I]).Data).Text := FTableNames[I];
          TTreeNode(TTreeNode(TTreeNode(AnTableList.Objects[I]).Data).Data).Text := FTableNames[I];
          TTreeNode(TTreeNode(AnTableList.Objects[I]).Data).Data := TFilterOrderBy.Create;
          FFilterBloksList.Add(TTreeNode(TTreeNode(AnTableList.Objects[I]).Data).Data);
          TTreeNode(AnTableList.Objects[I]).Data := TfltFieldData.Create;
          FFilterBloksList.Add(TTreeNode(AnTableList.Objects[I]).Data);
        end;
        Caption := Caption + ' ' + TTreeNode(AnTableList.Objects[I]).Text;
        // ������� �������� ����� ������ � �������� ������
        {if AnTableList.Count > 1 then
          for J := 0 to TfcTreeNode(AnTableList.Objects[I]).Count - 1 do
            TfcTreeNode(AnTableList.Objects[I]).Item[J].Text :=
             TfcTreeNode(AnTableList.Objects[I]).Item[J].Text + ' - ' +
             TfcTreeNode(AnTableList.Objects[I]).Text;}
      end;
    end;
    // ������������� ���������, ��� ���� ��������
    FIsFill := True;
  end;

  // ��������� ����
  for I := 0 to AnConditionList.Count - 1 do
  begin
    ConditionData := AnConditionList.Conditions[I];
    AddFilterLine;
    SetCondition(FFilterList.Count - 1, ConditionData);
  end;
  // ��������� ���� ���� ���� ���� ����
  if (AnConditionList.Count = 0 ) then
    AddFilterLine;

  if FEnableOrder then
  begin
    FIsIndexField := AnOrderByList.OnlyIndexField;
    FSetingCheck := True;
    chbOnlyIndexed.Checked := FIsIndexField;
    FSetingCheck := False;
    // ��������� ������� ����������
    for I := 0 to AnOrderByList.Count - 1 do
    begin
      OrderLine := AnOrderByList.OrdersBy[I];
      AddOrderLine;
      SetOrderLine(FOrderList.Count - 1, OrderLine);
    end;
    // ��������� ���� �������, ���� ���� ����
    if (AnOrderByList.Count = 0) then
      AddOrderLine;
  end;

  // �������� ������
  if ShowModal = mrOk then
  begin
    AnConditionList.Clear;
    if FEnableOrder then
      AnOrderByList.Clear;
    // ��������� ���� ������
    CompliteFilterData(AnConditionList, AnOrderByList);

    Result := True;
  end;

  ClearFilterLine;
  ClearOrderLine;
end;

// �������� ��������� ����
function TdlgShowFilter.CheckVisible(const AnTableName, AnFieldName: String): Boolean;
var
  I: Integer;
  TempS: String;
begin
  Result := True;
  TempS := AnsiUpperCase(AnTableName + '|' + AnFieldName);
  // ���� ������ ������������ � ������ �� ��������� False
  for I := 0 to FNoVisibleList.Count - 1 do
    if FNoVisibleList.Strings[I] = TempS then
    begin
      Result := False;
      FNoVisibleList.Delete(I);
      Break;
    end;
end;

// ��������� ��� ������ Interbase � ��� ��������
function TdlgShowFilter.ConvertDataType(const InterbaseType, SubType: Integer;
 const DomenName: String; const Size: Integer = 0): Integer;
begin
  case InterbaseType of
    8, 10, 11, 27, {IB6}16:
      Result := GD_DT_DIGITAL;
    14, 37, {IB6}40:
      if Size = 1 then
        Result := GD_DT_ENUMERATION
      else
        Result := GD_DT_CHAR;
    35:
      Result := GD_DT_TIMESTAMP;
    {IB6}12:
      Result := GD_DT_DATE;
    {IB6}13:
      Result := GD_DT_TIME;
    7:
      if Trim(DomenName) = 'DBOOLEAN' then
        Result := GD_DT_BOOLEAN
      else
        Result := GD_DT_DIGITAL;
    261:
      if SubType = 1 then
        Result := GD_DT_BLOB_TEXT
      else
        Result := GD_DT_BLOB;
  else
    Result := GD_DT_UNKNOWN
  end;
end;

// ��������� ����� �������
procedure TdlgShowFilter.AddFilterLine;
var
  F: TfrFilterLine;
  I: Integer;
begin
  // ������� ����� �����
  F := TfrFilterLine.Create(dlgShowFilter);
  F.Visible := False;
  F.Parent := sbFilter;
  // ������ ����������� ���������
  F.ctbFields.Nodes.Assign(FFieldList.Items);
  F.ctbFields.Images := ilFields;
  F.FunctionList.Assign(FFunctionList);
  F.FTableList.Assign(FTableList);

  F.IBDatabase := Database;
  F.IBTransaction := Transaction;
  F.gscbElementSet.Transaction := Transaction;
  F.gscbElementSet.Database := Database;
  F.gscbSet.Transaction := Transaction;
  F.gscbSet.Database := Database;
  F.ecbEnum.Database := Database;
  F.escbEnumSet.Database := Database;
  F.SQLText := FSQLText;
  F.FComponentKey := FComponentKey;

  F.NoVisibleList.Assign(FNoVisibleList);

  for I := 0 to FSortList.Items.Count - 1 do
    if not FSortList.Items[I].HasChildren then
      F.SortFieldList.AddObject(FSortList.Items[I].Text, FSortList.Items[I].Data);

  F.gscbElementSet.UserAttr := False;
  // ��������� � ������ �������
  I := FFilterList.Add(F);
  // ��������� ��� �������
  if I = 0 then
    F.Top := (I) * F.Height
  else
    F.Top := TfrFilterLine(FFilterList[I - 1]).Top + F.Height;
  F.Align := alTop;
  // ������������� ������ ����
  if (Self.Height < (I + 1) * F.Height + pnlButton.Height + DeltaHeight)
   and (SizeScreenY > (I + 1) * F.Height + pnlButton.Height + DeltaHeight + 20) then
    Self.Height := (I + 1) * F.Height + pnlButton.Height + DeltaHeight;
  F.Visible := True;
end;

// ��������� ����� ����������
procedure TdlgShowFilter.AddOrderLine;
var
  F: TfrOrderLine;
  I: Integer;
begin
  // ������� ����� �����
  F := TfrOrderLine.Create(dlgShowFilter);
  F.Visible := False;
  F.Parent := sbOrder;
  F.Align := alTop;
  // ��������� ���������
  if FIsIndexField then
  begin
    F.ctbFields.Nodes.Assign(FIndexList.Items);
    F.cbOrderType.Enabled := False;
  end else
    F.ctbFields.Nodes.Assign(FSortList.Items);

  F.ctbFields.Images := ilFields;
  
  // ��������� � ������ �������
  I := FOrderList.Add(F);
  if I = 0 then
    F.Top := (I) * F.Height
  else
    F.Top := TfrOrderLine(FOrderList[I - 1]).Top + F.Height;
  // ���������� ������ ����
  if (Self.Height < (I + 1) * F.Height + pnlButton.Height + DeltaHeight)
   and (SizeScreenY > (I + 1) * F.Height + pnlButton.Height + DeltaHeight + 20) then
    Self.Height := (I + 1) * F.Height + pnlButton.Height + DeltaHeight;
  F.Visible := True;
end;

procedure TdlgShowFilter.actAddLineExecute(Sender: TObject);
begin
  // ����� �������
  if pcOrderFilter.ActivePage = tsFilter then
    AddFilterLine;
  // ����� ����������
  if pcOrderFilter.ActivePage = tsOrder then
    AddOrderLine;
end;

procedure TdlgShowFilter.FormDestroy(Sender: TObject);
begin
  ClearFieldList;
  ClearIndexList;
  ClearSortList;
  FFieldList.Free;
  FSortList.Free;
  FIndexList.Free;

  FFilterBloksList.Free;
  FOrderList.Free;
  FFilterList.Free;
  FNoVisibleList.Free;
  FTableList.Free;
  FConditionLink.Free;
  FFunctionList.Free;
  SetLength(FTableNames, 0);
end;

procedure TdlgShowFilter.DeleteOrderLine(const AnIndex: Integer);
var
  F: TfrOrderLine;
  FilterHeigth: Integer;
begin
  Assert((AnIndex >= 0) and (AnIndex < FOrderList.Count));
  if FOrderList.Count > 0 then
  begin
    F := TfrOrderLine(FOrderList.Extract(FOrderList[AnIndex]));
    F.Visible := False;
    //FilterHeigth := sbFilter.Height;
    if FFilterList.Count = 0 then
      FilterHeigth := 0
    else
      FilterHeigth := Min(sbFilter.Height, FFilterList.Count * TfrFilterLine(FFilterList.Items[0]).Height);
    if (SizeScreenY > FOrderList.Count * F.Height + pnlButton.Height + DeltaHeight + 20) then
    begin
      if FOrderList.Count * F.Height >= FilterHeigth then
        Self.Height := (FOrderList.Count) * F.Height + pnlButton.Height + DeltaHeight
      else
        Self.Height := FilterHeigth + pnlButton.Height + DeltaHeight;
    end;
    F.Free;
  end;
end;

// ��������� ������ ������� ���������� � ����������
procedure TdlgShowFilter.CompliteFilterData(const AnConditionList: TFilterConditionList;
 const AnOrderByList: TFilterOrderByList);
var
  I: Integer;
  ConditionData: TFilterCondition;
  OrderByData: TFilterOrderBy;
begin
  // ��������� ������ ������� ����������
  ConditionData := TFilterCondition.Create;
  try
    for I := 0 to FFilterList.Count - 1 do
      if GetCondition(I, ConditionData) and AnConditionList.CheckCondition(ConditionData) then
        AnConditionList.AddCondition(ConditionData);
  finally
    ConditionData.Free;
  end;

  AnConditionList.IsAndCondition := rbAND.Checked;
  AnConditionList.IsDistinct := cbDistinct.Checked;

  // ��������� ������ ������� ����������
  if FEnableOrder then
  begin
    OrderByData := TFilterOrderBy.Create;
    try
      for I := 0 to FOrderList.Count - 1 do
      begin
        if I = 0 then
          AnOrderByList.OnlyIndexField := chbOnlyIndexed.Checked;
        if GetOrderLine(I, OrderByData) then
          AnOrderByList.AddOrderBy(OrderByData);
      end;
    finally
      OrderByData.Free;
    end;
  end;
end;

// ������� ����� ����������
procedure TdlgShowFilter.DeleteFilterLine(const AnIndex: Integer);
var
  F: TfrFilterLine;
  OrderHeigth: Integer;
begin
  // ��������� ��������
  Assert((AnIndex >= 0) and (AnIndex < FFilterList.Count));
  if FFilterList.Count > 0 then
  begin
    // ��������� ����� �� ������
    F := TfrFilterLine(FFilterList.Extract(FFilterList[AnIndex]));
    F.Visible := False;
    //OrderHeigth := sbFilter.Height;
    if FOrderList.Count = 0 then
      OrderHeigth := 0
    else
      OrderHeigth := Min(sbFilter.Height, FOrderList.Count * TfrOrderLine(FOrderList.Items[0]).Height);
    // ������������� ������ ����
    if (SizeScreenY > FFilterList.Count * F.Height + pnlButton.Height + DeltaHeight + 20) then
    begin
      if FFilterList.Count * F.Height >= OrderHeigth then
        Self.Height := (FFilterList.Count) * F.Height + pnlButton.Height + DeltaHeight
      else
        Self.Height := OrderHeigth + pnlButton.Height + DeltaHeight;
    end;
    F.Free;
  end;
end;

procedure TdlgShowFilter.ClearFilterLine;
var
  I: Integer;
begin
  // ������� ������ ������� ����������
  for I := FFilterList.Count - 1 downto 0 do
    DeleteFilterLine(I);
end;

procedure TdlgShowFilter.ClearOrderLine;
var
  I: Integer;
begin
  // ������� ������ ������� ����������
  for I := FOrderList.Count - 1 downto 0 do
    DeleteOrderLine(I);
end;

procedure TdlgShowFilter.actDeleteLineExecute(Sender: TObject);
begin
  if pcOrderFilter.ActivePageIndex = 0 then
  begin
    if FFilterList.Count = 1 then
    begin
      TfrFilterLine(FFilterList[0]).ctbFields.SelectedNode := nil;
      TfrFilterLine(FFilterList[0]).cbFieldsChange(Self);
    end else
      DeleteFilterLine(FFilterList.Count - 1);
  end else
  begin
    if FOrderList.Count = 1 then
    begin
      TfrOrderLine(FOrderList[0]).ctbFields.SelectedNode := nil;
      TfrOrderLine(FOrderList[0]).cbOrderType.ItemIndex := -1;
    end else
      DeleteOrderLine(FOrderList.Count - 1);
  end;
end;

procedure TdlgShowFilter.actDeleteLineUpdate(Sender: TObject);
begin
  // �������� �� ���������� ����� ���������
  if pcOrderFilter.ActivePage = tsFilter then
    (Sender as TAction).Enabled := (FFilterList.Count > 0)
  else
    if pcOrderFilter.ActivePage = tsOrder then
      (Sender as TAction).Enabled := (FOrderList.Count > 0)
    else
      (Sender as TAction).Enabled := False;
end;

procedure TdlgShowFilter.actAddLineUpdate(Sender: TObject);
begin
  if pcOrderFilter.ActivePage = tsOrder then
    if {(OrderList.Count = 3) or
       }(TfrOrderLine(FOrderList.Items[FOrderList.Count - 1]).ctbFields.SelectedNode = nil) or
       (TfrOrderLine(FOrderList.Items[FOrderList.Count - 1]).ctbFields.Nodes.Count < 2) then
      actAddLine.Enabled := False
    else
    // �������� �� ����� �� ������� ������ ����� �����������
      (Sender as TAction).Enabled := (Self.Top + Self.Height) < SizeScreenY
  else
    if pcOrderFilter.ActivePage = tsFilter then
      if (TfrFilterLine(FFilterList.Items[FFilterList.Count - 1]).ctbFields.SelectedNode = nil) or
         (TfrFilterLine(FFilterList.Items[FFilterList.Count - 1]).cbCondition.ItemIndex = -1) then
        actAddLine.Enabled := False
      else
       // �������� �� ����� �� ������� ������ ����� �����������
        (Sender as TAction).Enabled := (Self.Top + Self.Height) < SizeScreenY
    else
      (Sender as TAction).Enabled := False;
end;

// ������� ����� ������
procedure TdlgShowFilter.btnSaveFilterClick(Sender: TObject);
var
  FData: TFilterData;
  LocBlobStream: TIBDSBlobStream;
  TempBool: Boolean;
begin
  // ���� �� ������� ����, �� �������
  if not FMainWindow then
    Exit;
  // ��������� ������� ����
  if not CheckMainFields then
    Exit;

  TempBool := True;
  FormCloseQuery(Self, TempBool);
  if not TempBool then
    Exit;

  FData := TFilterData.Create;
  try
    FData.ConditionList.Clear;
    // ��������� ���� ������
    CompliteFilterData(FData.ConditionList, FData.OrderByList);

    // ��������� ��� ��� ���� � ����
    try
      LocBlobStream := ibdsFilter.CreateBlobStream(ibdsFilter.FieldByName('data'), bmWrite) as TIBDSBlobStream;
      try
        FData.WriteToStream(LocBlobStream);
      finally
        FreeAndNil(LocBlobStream);
      end;

      // Thanks to Julia ...
      if Assigned(ibdsFilter.FindField('editorkey')) then
        ibdsFilter.FieldByName('editorkey').Required := False;
      if Assigned(ibdsFilter.FindField('editiondate')) then
        ibdsFilter.FieldByName('editiondate').Required := False;
        
      if cbOnlyForMe.Checked and (GetUserKey <> -1) then
        ibdsFilter.FieldByName('userkey').AsInteger := GetUserKey
      else
        ibdsFilter.FieldByName('userkey').AsVariant := NULL;
      ibdsFilter.Post;
      FIsNewFilter := True;
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, PChar('��������� ������ ��� ���������� �������.'#13#10 +
         E.Message), '������', MB_OK or MB_ICONERROR);
        ibdsFilter.Cancel;
      end;
    end;

    // ������� ����� ������
    ibdsFilter.Insert;
    ibsqlGetID.Close;
    ibsqlGetID.ExecQuery;
    ibdsFilter.FieldByName('id').AsInteger := ibsqlGetID.Fields[0].AsInteger;
    ibdsFilter.FieldByName('componentkey').AsInteger := FComponentKey;
    ibdsFilter.FieldByName('name').AsString := '��� �����';
    ibdsFilter.FieldByName('lastextime').AsDateTime := 0;
    ibdsFilter.FieldByName('afull').AsInteger := GetIngroup or 1;
    ibdsFilter.FieldByName('achag').AsInteger := GetIngroup or 1;
    ibdsFilter.FieldByName('aview').AsInteger := -1;

    pcOrderFilter.ActivePage := tsName;

  finally
    FData.Free;
  end;
end;

procedure TdlgShowFilter.SetOrderLine(const I: Integer; const AnOrderData: TFilterOrderBy);
var
  J: Integer;
  F: TfrOrderLine;
  Flag: Boolean;
begin
  // �������� ���������
  Assert((I >= 0) and (FOrderList.Count > I), '������ ��� ���������');

  F := TfrOrderLine(FOrderList.Items[I]);
  Flag := False;
  // ����� ����
  for J := 0 to F.ctbFields.Nodes.Count - 1 do
    if (TObject(F.ctbFields.Nodes[J].Data) is TFilterOrderBy) and
    (Trim(TFilterOrderBy(F.ctbFields.Nodes[J].Data).FieldName) = Trim(AnOrderData.FieldName)) and
    (Trim(TFilterOrderBy(F.ctbFields.Nodes[J].Data).TableName) = Trim(AnOrderData.TableName)) and
    (Trim(AnsiUpperCase(TFilterOrderBy(F.ctbFields.Nodes[J].Data).TableAlias)) = Trim(AnsiUpperCase(AnOrderData.TableAlias))) then
    begin
      // ������������� ���������
      F.ctbFields.SelectedNode := F.ctbFields.Nodes[J];
      if AnOrderData.IsAscending then
        F.cbOrderType.ItemIndex := 0
      else
        F.cbOrderType.ItemIndex := 1;
      Flag := True;
      Break;
    end;

  if not Flag then
  begin
    MessageBox(Self.Handle, PChar('���� ' + Trim(AnOrderData.TableAlias) + 
     Trim(AnOrderData.FieldName) + ' ��������� ��� ���������� �� �������'), '��������',
     MB_OK or MB_ICONINFORMATION);
    Exit;
  end;
end;

function TdlgShowFilter.GetOrderLine(const I: Integer; const AnOrderData: TFilterOrderBy): boolean;
var
  F: TfrOrderLine;
begin
  Result := False;
  // �������� ���������
  Assert((I >= 0) and (FOrderList.Count > I), '������ ��� ���������');
  // ������� ���� ������
  AnOrderData.Clear;
  F := TfrOrderLine(FOrderList.Items[I]);
  if F.ctbFields.SelectedNode <> nil then
  begin
    // ����������� ���������
    AnOrderData.Assign(TFilterOrderBy(F.ctbFields.SelectedNode.Data));
    AnOrderData.IsAscending := F.cbOrderType.ItemIndex = 0;
    Result := True;
  end;
end;

function TdlgShowFilter.GetIngroup: Integer;
begin
  if IBLogin <> nil then
    Result := IBLogin.Ingroup
  else
    Result := -1;
end;

function TdlgShowFilter.GetUserKey: Integer;
begin
  if IBLogin <> nil then
    Result := IBLogin.UserKey
  else
    Result := -1;
end;

procedure TdlgShowFilter.WMUser(var Message: TMessage);
var
  I: Integer;
begin
  case Message.WParam of
    // �������� ������ ����������
    WM_CLOSEFILTERLINE:
      if FFilterList.Count = 1 then
      begin
        TfrFilterLine(FFilterList[0]).ctbFields.SelectedNode := nil;
        TfrFilterLine(FFilterList[0]).cbFieldsChange(Self);
      end else
      begin
        I := FFilterList.IndexOf(TObject(Message.LParam));
        if I > -1 then
          DeleteFilterLine(I);
      end;
    // �������� ������ ����������
    WM_CLOSEORDERLINE:
      if FOrderList.Count = 1 then
      begin
        TfrOrderLine(FOrderList[0]).ctbFields.SelectedNode := nil;
        TfrOrderLine(FOrderList[0]).cbOrderType.ItemIndex := -1;
      end else
      begin
        I := FOrderList.IndexOf(TObject(Message.LParam));
        if I > -1 then
          DeleteOrderLine(I);
      end;
  else
    inherited;
  end;
end;

// �������� ���� ��� ����������
procedure TdlgShowFilter.ChangeSortFields(const AnIndexField: Boolean);
var
  I, J: Integer;
  T1, T2: TFilterOrderBy;
  Flag: Boolean;
begin
  FIsIndexField := AnIndexField;

  T1 := TFilterOrderBy.Create;
  try
    for I := FOrderList.Count - 1 downto 0 do
    begin
      Flag := False;
      // ���� ������ ������� �����������
      if TfrOrderLine(FOrderList.Items[I]).ctbFields.SelectedNode <> nil then
      begin
        T1.Assign(TFilterOrderBy(TfrOrderLine(FOrderList.Items[I]).ctbFields.SelectedNode.Data));
        T1.IsAscending := TfrOrderLine(FOrderList.Items[I]).cbOrderType.ItemIndex <> 1;
        if FIsIndexField then
        begin
          TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes.Assign(FIndexList.Items);
          TfrOrderLine(FOrderList.Items[I]).cbOrderType.Enabled := False;
          // ���� �������������� �������
          for J := 0 to TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes.Count - 1 do
          begin
            T2 := TFilterOrderBy(TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes[J].Data);
            if (T1.TableName = T2.TableName) and (T1.TableAlias = T2.TableAlias) and
             (T1.FieldName = T2.FieldName) and (T1.IsAscending = T2.IsAscending) then
            begin
              // ���� ������ �� �������������
              TfrOrderLine(FOrderList.Items[I]).ctbFields.SelectedNode :=
               TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes[J];
              Flag := True;
              Break;
            end;
          end
        end else
        begin
          TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes.Assign(FSortList.Items);
          TfrOrderLine(FOrderList.Items[I]).cbOrderType.Enabled := True;
          // ���� �������������� �������
          for J := 0 to TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes.Count - 1 do
          begin
            T2 := TFilterOrderBy(TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes[J].Data);
            if (T1.TableName = T2.TableName) and (T1.TableAlias = T2.TableAlias) and
             (T1.FieldName = T2.FieldName) then
            begin
              // ���� �������, �� ������������� ������ � ������������ ����������
              TFilterOrderBy(TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes[J].Data).IsAscending := T1.IsAscending;
              TfrOrderLine(FOrderList.Items[I]).ctbFields.SelectedNode :=
               TfrOrderLine(FOrderList.Items[I]).ctbFields.Nodes[J];
              Flag := True;
              Break;
            end;
          end;
        end;
      end;
      // ���� �� �����, �� �������
      if not Flag then
        DeleteOrderLine(I);
    end;
  finally
    T1.Free;
  end;

  // ���� ������� ��� �������, �� ������� ����
  if FOrderList.Count = 0 then
    AddOrderLine;
end;

procedure TdlgShowFilter.chbOnlyIndexedClick(Sender: TObject);
begin
  if not FSetingCheck then
    ChangeSortFields(chbOnlyIndexed.Checked);
end;

procedure TdlgShowFilter.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  I: Integer;
begin
  // ��� ������� ������ ��������� ������������ ���������� �����
  if ModalResult = mrOk then
  begin
    for I := 0 to FFilterList.Count - 1 do
      if not TfrFilterLine(FFilterList.Items[I]).CheckTypeValue then
      begin
        CanClose := False;
        Break;
      end;
    case cbNameMode.ItemIndex of
      0: fltFieldNameMode := fnmOriginal;
      1: fltFieldNameMode := fnmLocalize;
      2: fltFieldNameMode := fnmDuplex;
    else
      Assert(False, 'Filter Field Name Mode not suported');
    end;
  end;
end;

procedure TdlgShowFilter.cbOnlyForMeClick(Sender: TObject);
begin
  btnAccess.Enabled :=  not cbOnlyForMe.Checked;
end;

// ��������� �������� ����
function TdlgShowFilter.CheckMainFields: Boolean;
var
  I: Integer;
  LocOrderData: TFilterOrderBy;
  ibsql: TIBSQL;
begin
  Result := False;
  // ������������ ������� �� ������ ���� ������
  if tsName.TabVisible and (Trim(dbeName.Text) = '') then
  begin
    MessageBox(Self.Handle, '�� ������� ��� �������', '��������', MB_OK or MB_ICONSTOP);
    pcOrderFilter.ActivePage := tsName;
    dbeName.SetFocus;
    Exit;
  end;

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := Transaction;
    ibsql.SQL.Text := 'SELECT * FROM flt_savedfilter ' +
      ' WHERE name = :name AND componentkey = :componentkey AND id <> :id';
    if cbOnlyForMe.Checked and (GetUserKey > -1) then
      ibsql.SQL.Text := ibsql.SQL.Text + ' AND userkey = ' + IntToStr(GetUserKey)
    else
      ibsql.SQL.Text := ibsql.SQL.Text + ' AND userkey IS NULL ';
    ibsql.ParamByName('name').AsString := Trim(dbeName.Text);
    ibsql.ParamByName('componentkey').AsInteger := FComponentKey;
    ibsql.ParamByName('id').AsString := ibdsFilter.ParamByName('filterkey').AsString;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      MessageBox(Self.Handle, '��� ������� ����������� � ��� ������������. ������� ������ ��� �������.',
        '��������', MB_OK or MB_ICONSTOP);
      pcOrderFilter.ActivePage := tsName;
      dbeName.SetFocus;
      Exit;
    end;
  finally
    ibsql.Free;
  end;

  // ���� ������ ����� ������, ��� ������ ���� ������ � ������������ ��������
  LocOrderData := TFilterOrderBy.Create;
  try
    for I := 0 to FFilterList.Count - 1 do
    begin
      if TfrFilterLine(FFilterList.Items[I]).ctbFields.SelectedNode <> nil then
      begin
        if (ExtractCondition(TfrFilterLine(FFilterList.Items[I]).cbCondition.ItemIndex,
         TfltFieldData(TfrFilterLine(FFilterList.Items[I]).ctbFields.SelectedNode.Data).FieldType) = GD_FC_QUERY_ALL) and
         (FFilterList.Count > 1) then
        begin
          MessageBox(Self.Handle, '������ ������������ ������ ����'#13#10 +
           '������ � ������������ ��������.', '��������', MB_OK or MB_ICONSTOP);
          pcOrderFilter.ActivePage := tsFilter;
          Exit;
        end;
        if (ExtractCondition(TfrFilterLine(FFilterList.Items[I]).cbCondition.ItemIndex,
         TfltFieldData(TfrFilterLine(FFilterList.Items[I]).ctbFields.SelectedNode.Data).FieldType) = GD_FC_QUERY_ALL) and
         ((FOrderList.Count > 1) or (GetOrderLine(0, LocOrderData))) then
        begin
          MessageBox(Self.Handle, '��� ������� ������ ������������, '#13#10 +
           '���������� ������ ����������� � ������ SQL.', '��������', MB_OK or MB_ICONSTOP);
          pcOrderFilter.ActivePage := tsOrder;
          Exit;
        end;
      end;
    end;
  finally
    LocOrderData.Free;
  end;

  Result := True;
end;

procedure TdlgShowFilter.btnOkClick(Sender: TObject);
begin
  if not CheckMainFields then
    ModalResult := mrNone;
end;

procedure TdlgShowFilter.actShowOriginalSQLExecute(Sender: TObject);
begin
  {$IFDEF SYNEDIT}
  with TfrmSQLEditorSyn.Create(Self) do
  {$ELSE}
  with TfrmSQLEditor.Create(Self) do
  {$ENDIF}
  try
    FDatabase := Self.Database;
    ShowSQL(FSQLText, nil);
  finally
    Free;
  end;
end;

procedure TdlgShowFilter.actShowConditionSQLExecute(Sender: TObject);
var
  SQLFilter: TgsSQLFilter;
  TempBool: Boolean;
begin
  TempBool := True;
  FormCloseQuery(Self, TempBool);
  if not TempBool then
    Exit;

  SQLFilter := TgsSQLFilter.Create(Self);
  try
    {$IFDEF SYNEDIT}
    with TfrmSQLEditorSyn.Create(Self) do
    {$ELSE}
    with TfrmSQLEditor.Create(Self) do
    {$ENDIF}
    try
      CompliteFilterData(SQLFilter.FilterData.ConditionList, SQLFilter.FilterData.OrderByList);
      SQLFilter.SelectText.Text := ExtractSQLSelect(FSQLText);
      SQLFilter.FromText.Text := ExtractSQLFrom(FSQLText);
      SQLFilter.WhereText.Text := ExtractSQLWhere(FSQLText);
      SQLFilter.OtherText.Text := ExtractSQLOther(FSQLText);
      SQLFilter.OrderText.Text := ExtractSQLOrderBy(FSQLText);
      SQLFilter.CreateSQL;
      FDatabase := Self.Database;
      ShowSQL(SQLFilter.FilteredSQL.Text, nil);
    finally
      Free;
    end;
  finally
    SQLFilter.Free;
  end;
end;

procedure TdlgShowFilter.FormActivate(Sender: TObject);
begin
  case fltFieldNameMode of
    fnmOriginal: cbNameMode.ItemIndex := 0;
    fnmLocalize: cbNameMode.ItemIndex := 1;
    fnmDuplex: cbNameMode.ItemIndex := 2;
  else
    Assert(False, 'Filter Field Name Type not suported');
  end;
end;

// ��� ��������� �� gd_security
procedure TdlgShowFilter.btnAccessClick(Sender: TObject);
var
  F: TdlgChangeRight;
  StateDS: Boolean;
  ADataSet: TIBDataSet;
begin
  ADataSet := ibdsFilter;

  Assert((ADataSet <> nil) and (ADataSet.Active));

  F := TdlgChangeRight.Create(Self);
  try
    F.ibqryWork.Database := ADataSet.Database;
    F.ibqryWork.Transaction := ADataSet.Transaction;

    F.ARight := 0;
    // ��������� ���� �� ��������
    if ADataSet.FindField('afull') <> nil then
    begin
      F.AFull := ADataSet.FieldByName('afull').AsInteger;
      F.ARight := 1;
    end;
    // ��������� ���� �� ���������
    if ADataSet.FindField('achag') <> nil then
    begin
      F.AChag := ADataSet.FieldByName('achag').AsInteger;
      F.ARight := F.ARight or 2;
    end;
    // ��������� ���� �� ��������
    if ADataSet.FindField('aview') <> nil then
    begin
      F.AView := ADataSet.FieldByName('aview').AsInteger;
      F.ARight := F.ARight or 4;
    end;

    F.actShow.Execute;
    F.btnOk.Enabled := (F.AFull and IBLogin.Ingroup <> 0) or (1 and IBLogin.Ingroup <> 0);
    if F.ShowModal = mrOk then
    begin
      if (dsEdit = ADataSet.State) or (dsInsert = ADataSet.State) then
        StateDS := False
      else begin
        StateDS := True;
        ADataSet.Edit;
      end;
      // �������� ��������� ���� �������
      if (F.ARight and 1) <> 0 then
        ADataSet.FieldByName('afull').AsInteger := F.AFull or 1;
      if (F.ARight and 2) <> 0 then
        ADataSet.FieldByName('achag').AsInteger := F.AChag or 1;
      if (F.ARight and 4) <> 0 then
        ADataSet.FieldByName('aview').AsInteger := F.AView or 1;
      if StateDS then
        ADataSet.Post;
    end;
  finally
    F.Free;
  end;
end;

procedure TdlgShowFilter.ClearFieldList;
begin
  // ������ ����� ������� ����� ��� ������� TreeView, �� ���������� �����
  while FFieldList.Items.Count > 0 do
    FFieldList.Items[0].Delete;
  FFieldList.Items.Clear;
end;

procedure TdlgShowFilter.ClearIndexList;
begin
  // ������ ����� ������� ����� ��� ������� TreeView, �� ���������� �����
  while FIndexList.Items.Count > 0 do
    FIndexList.Items[0].Delete;
  FIndexList.Items.Clear;
end;

procedure TdlgShowFilter.ClearSortList;
begin
  // ������ ����� ������� ����� ��� ������� TreeView, �� ���������� �����
  while FSortList.Items.Count > 0 do
    FSortList.Items[0].Delete;
  FSortList.Items.Clear;
end;

function TdlgShowFilter.CheckFieldName(AnFieldName: String): String;
begin
  Result := Trim(AnFieldName);
  {$IFDEF SQLD3}
  if AnsiUpperCase(Result) <> Result then
    Result := '"' + Result + '"';
  {$ENDIF}
end;

end.
