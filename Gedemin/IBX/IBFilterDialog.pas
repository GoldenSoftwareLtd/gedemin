{*******************************************************
 Classes:     TIBFilterDialog, TfrmIBFilterDialog,
              TIBFieldInfo, TIBVariable
 Created      6/3/2001.
 Author:      Jeffrey P Overcash
 CopyRight:   Jeffrey P Overcash 1998-2001 all rights reserved
 Description: This is a filter dialog component that allows the runtime
              Filtering of IBDataSet's.

 Version:     1.0.0.40 beta
 Status:      FreeWare
 Disclaimer:  This is provided as is, expressly without a
              warranty of any kind.
              You use it at your own risk.

 *******************************************************}

unit IBFilterDialog;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, ComCtrls, Db, IBCustomDataset;

type

  TIBFilterMatchType = (fdMatchExact, fdMatchStart, fdMatchEnd,
                            fdMatchAny, fdMatchRange, fdMatchNone);
  TIBOption = (fdCaseSensitive, fdShowCaseSensitive, fdShowNonMatching);
  TIBOptions = Set of TIBOption;

  TIBFieldInfo = class
  public
    FieldName : String;
    FieldOrigin : String;
    FieldType : TFieldType;
    DisplayLabel : String;
    MatchType : TIBFilterMatchType;
    FilterValue : String;
    StartingValue : String;
    EndingValue : String;
    CaseSensitive : boolean;
    NonMatching : boolean;
    procedure Assign(o : TIBFieldInfo);
    function CreateSQL : String;
    procedure SetVariables( d : TIBCustomDataset);
  end;

  TIBVariable = class
  public
    VariableName : String;
    VariableValue : Variant;
    constructor Create(name : String; value : Variant);
  end;

  TfrmIBFilterDialog = class(TForm)
    Label1: TLabel;
    pgeFields: TPageControl;
    tabAll: TTabSheet;
    tabSelected: TTabSheet;
    lstAllFields: TListBox;
    lstSelectedFields: TListBox;
    pgeCriteria: TPageControl;
    tabByValue: TTabSheet;
    tabByRange: TTabSheet;
    Label2: TLabel;
    edtFieldValue: TEdit;
    btnClearFieldValue: TButton;
    grpSearchType: TRadioGroup;
    Label3: TLabel;
    Label4: TLabel;
    edtStartingRange: TEdit;
    edtEndingRange: TEdit;
    btnClearStartingRange: TButton;
    btnClearEndingRange: TButton;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnViewSummary: TButton;
    btnNewSearch: TButton;
    Panel1: TPanel;
    cbxCaseSensitive: TCheckBox;
    cbxNonMatching: TCheckBox;
    procedure RefreshClearButtons(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FieldsListBoxClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pgeFieldsChanging(Sender: TObject; var AllowChange: Boolean);
    procedure btnNewSearchClick(Sender: TObject);
    procedure btnViewSummaryClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnClearFieldValueClick(Sender: TObject);
    procedure btnClearStartingRangeClick(Sender: TObject);
    procedure btnClearEndingRangeClick(Sender: TObject);
  private
    FFilterList : TList;
    FPreviousList : TList;
    LastIndex : Integer;
    procedure SetCriteria;
    procedure GetCriteria;
    procedure ClearCriteria;
    function GetFilterItem(index: Integer): TIBFieldInfo;
    { Private declarations }
  public
    procedure NewSQL;
    property FilterList : TList read FFilterList;
    property FilterItem[index : Integer] : TIBFieldInfo read GetFilterItem; default;
    { Public declarations }
  end;

type
  TIBFilterDialog = class(TComponent)
  private
    FDialog : TfrmIBFilterDialog;
    FOriginalSQL : TStrings;
    FModifiedSQL : TStrings;
    FDataSet : TIBCustomDataset;
    FDefaultMatchType : TIBFilterMatchType;
    FOptions : TIBOptions;
    FCaption: String;
    FFields: TStringList;
    FOriginalVariables : TList;
    SQLProp : String;
    procedure SetDataSet(const Value: TIBCustomDataset);
    procedure SetOptions(const Value: TIBOptions);
    procedure SetCaption(const Value: String);
    procedure SetDefaultMatchType(const Value: TIBFilterMatchType);
    procedure SetFields;
    procedure SetFieldsList(const Value: TStringList);
    procedure SetOriginalSQL(const Value: TStrings);
    procedure RestoreSQL;
    procedure SaveParamValues;
    { Private declarations }
  protected
    { Protected declarations }
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    property OriginalSQL : TStrings read FOriginalSQL write SetOriginalSQL;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Execute;
    procedure ReBuildSQL;
    property ModifiedSQL : TStrings read FModifiedSQL;
  published
    { Published declarations }
    property Caption : String read FCaption write SetCaption;
    property DataSet : TIBCustomDataset read FDataSet write SetDataSet;
    property DefaultMatchType : TIBFilterMatchType read FDefaultMatchType write SetDefaultMatchType
       default fdMatchStart;
    property Options : TIBOptions read FOptions write SetOptions default
      [fdShowCaseSensitive, fdShowNonMatching];
    property Fields : TStringList read FFields write SetFieldsList;
  end;

implementation

uses IBQuery, typInfo, IBFilterSummary, IBUtils;

{$R *.DFM}

const
  Identifiers = ['a'..'z', 'A'..'Z', '0'..'9', '_', '#', '$', '.', '"', '@'];


function WordPos(const AWord, AString: string): Integer;
var s: string;
    i, p: Integer;
begin
  s := ' ' + AnsiUpperCase(AString) + ' ';   {do not localize}
  for i := 1 to Length(s) do if not (s[i] in Identifiers) then s[i] := ' ';  {do not localize}
  p := Pos(' ' + AnsiUpperCase(AWord) + ' ', s);    {do not localize}
  Result := p;
end;

procedure TfrmIBFilterDialog.RefreshClearButtons(Sender: TObject);
begin
  if edtFieldValue.Text <> '' then
    btnClearFieldValue.Enabled := true
  else
    btnClearFieldValue.Enabled := false;
  if edtStartingRange.Text <> '' then
    btnClearStartingRange.Enabled := true
  else
    btnClearStartingRange.Enabled := false;
  if edtEndingRange.Text <> '' then
    btnClearEndingRange.Enabled := true
  else
    btnClearEndingRange.Enabled := false;
  btnNewSearch.Enabled := (btnClearFieldValue.Enabled or
     btnClearStartingRange.Enabled or btnClearEndingRange.Enabled);
  if btnNewSearch.Enabled or (FFilterList.Count > 0) then
    btnViewSummary.Enabled := true;
end;

procedure TfrmIBFilterDialog.FormCreate(Sender: TObject);
begin
  FFilterList := TList.Create;
  FPreviousList := TList.Create;
  LastIndex := -1;
end;

procedure TfrmIBFilterDialog.FieldsListBoxClick(Sender: TObject);
begin
  if Sender = lstSelectedFields then
    // Select the same field on the AllFields list
    lstAllFields.ItemIndex := lstAllFields.Items.IndexOf(
      lstSelectedFields.Items[lstSelectedFields.ItemIndex])
  else
    // Select the same field in the Selected List
    lstSelectedFields.ItemIndex := lstSelectedFields.Items.IndexOf(
      lstAllFields.Items[lstAllFields.ItemIndex]);
  if lstAllFields.ItemIndex = LastIndex then
    exit;
  GetCriteria;
  SetCriteria;
  LastIndex := lstAllFields.ItemIndex;
end;

procedure TfrmIBFilterDialog.GetCriteria;
var
  FilterIndex, i : Integer;
begin
  FilterIndex := -1;
  i := 0;
  while (i < FFilterList.Count) and (FilterIndex < 0) do
  begin
    if TIBFieldInfo(FFilterList[i]).DisplayLabel = lstAllFields.Items[LastIndex] then
      FilterIndex := i;
    Inc(i);
  end;
  // This is only enabled when at least one of the fields has entry
  if btnNewSearch.Enabled then
  begin
    // The user added a new criteria
    if FilterIndex < 0 then
    begin
      FFilterList.Add(TIBFieldInfo.Create);
      FilterIndex := FFilterList.Count - 1;
      lstSelectedFields.Items.AddObject(lstAllFields.Items[LastIndex],
        lstAllFields.Items.Objects[LastIndex]);
    end;
    // Set the fields
    with TIBFieldInfo(FFilterList[FilterIndex])  do
    begin
      CaseSensitive := cbxCaseSensitive.Checked;
      DisplayLabel := lstAllFields.Items[LastIndex];
      // Save off the TField for this field

      FieldName := TField(lstAllFields.Items.Objects[LastIndex]).FieldName;
      FieldOrigin := TField(lstAllFields.Items.Objects[LastIndex]).Origin;
      FieldType := TField(lstAllFields.Items.Objects[LastIndex]).DataType;
      // Match Criteria is either Range or one of the other 4
      if pgeCriteria.ActivePage = tabByRange then
        MatchType := fdMatchRange
      else
        MatchType := TIBFilterMatchType(grpSearchType.ItemIndex);
      // Only save the criteria that they want to work with
      if MatchType = fdMatchRange then
      begin
        EndingValue := edtEndingRange.Text;
        StartingValue := edtStartingRange.Text;
        FilterValue := '';
      end
      else
      begin
        EndingValue := '';
        StartingValue := '';
        FilterValue := edtFieldValue.Text;
      end;
      NonMatching := cbxNonMatching.Checked;
    end;
  end
  else
    // The user removed a criteria that existed
    if FilterIndex >= 0 then
    begin
      // remove the Selected list item
      lstSelectedFields.Items.Delete(lstSelectedFields.Items.IndexOf(
           TIBFieldInfo(FFilterList[FilterIndex]).DisplayLabel));
      // Free the FieldInfo Object
      TIBFieldInfo(FFilterList[FilterIndex]).Free;
      // Delete it from the list
      FFilterList.Delete(FilterIndex);
      if FFilterList.Count = 0 then
        btnViewSummary.Enabled := false;
    end;
end;

procedure TfrmIBFilterDialog.SetCriteria;
var
  FilterIndex, i : Integer;
  DisplayName : String;
begin
  DisplayName := lstAllFields.Items[lstAllFields.ItemIndex];
  i := 0;
  FilterIndex := -1;
  // Find the Item in the list if it exists
  while (i < FFilterList.Count) and (FilterIndex < 0) do
  begin
    if TIBFieldInfo(FFilterList[i]).DisplayLabel = DisplayName then
      FilterIndex := i;
    Inc(i);
  end;
  if FilterIndex < 0 then
    // This has no current criteria
    ClearCriteria
  else
  begin
    with TIBFieldInfo(FFilterList[FilterIndex])  do
    begin
      cbxCaseSensitive.Checked := CaseSensitive;
      edtEndingRange.Text := EndingValue;
      edtFieldValue.Text := FilterValue;
      if MatchType <> fdMatchRange then
        grpSearchType.ItemIndex := Integer(MatchType);
      cbxNonMatching.Checked := NonMatching;
      edtStartingRange.Text := StartingValue;
      if MatchType = fdMatchRange then
        pgeCriteria.ActivePage := tabByRange
      else
        pgeCriteria.ActivePage := tabByValue;
    end;
  end;
end;

procedure TfrmIBFilterDialog.FormDestroy(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to FFilterList.Count - 1 do
    TIBFieldInfo(FFilterList[i]).Free;
  FFilterList.Free;
  for i := 0 to FPreviousList.Count - 1 do
    TIBFieldInfo(FPreviousList[i]).Free;
  FPreviousList.Free;
end;

procedure TfrmIBFilterDialog.pgeFieldsChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if (Sender as TPageControl).ActivePage = tabAll then
  begin
    if lstAllFields.ItemIndex < 0 then
      exit;
  end
  else
    if lstSelectedFields.ItemIndex < 0 then
      exit;
  GetCriteria;
  SetCriteria;
  FieldsListBoxClick(Sender);
end;

procedure TfrmIBFilterDialog.ClearCriteria;
begin
    edtFieldValue.Text := '';
    edtStartingRange.Text := '';
    edtEndingRange.Text := '';
end;

procedure TfrmIBFilterDialog.btnNewSearchClick(Sender: TObject);
var
  i : Integer;
begin
  for i := 0 to FFilterList.Count - 1 do
    TIBFieldInfo(FFilterList[i]).Free;
  FFilterList.Clear;
  ClearCriteria;
  lstSelectedFields.Items.Clear;
  pgeFields.ActivePage := tabAll;
end;

//Return to this and change once field lists are done
procedure TfrmIBFilterDialog.btnViewSummaryClick(Sender: TObject);
var
  i : Integer;
  Summary, ValueString : String;
begin
  GetCriteria;
  with TfrmIBFilterSummary.Create(self) do
  try
    for i := 0 to FFilterList.Count - 1 do
      with TIBFieldInfo(FFilterList[i]) do
        with lstSummary.Items.Add do
        begin
          Caption := DisplayLabel;
          if FieldType = ftString then
            case MatchType of
              fdMatchStart :
              begin
                Summary := 'Partial match at beginning';
                ValueString := FilterValue;
              end;
              fdMatchAny :
              begin
                Summary := 'Partial match anywhere';
                ValueString := FilterValue;
              end;
              fdMatchExact :
              begin
                Summary := 'Exact Match';
                ValueString := FilterValue;
              end;
              fdMatchEnd :
              begin
                Summary := 'Partial match at end';
                ValueString := FilterValue;
              end;
              fdMatchRange :
              begin
                Summary := 'Match Range';
                if StartingValue <> '' then
                  ValueString := '>=' + StartingValue;
                if EndingValue <> '' then
                begin
                  if ValueString <> '' then
                    ValueString := ValueString + ', ';
                  ValueString := ValueString + '<=' + EndingValue;
                end
              end;
            end
          else
            case MatchType of
              fdMatchRange :
              begin
                Summary := 'Match Range';
                if StartingValue <> '' then
                  ValueString := '>=' + StartingValue;
                if EndingValue <> '' then
                begin
                  if ValueString <> '' then
                    ValueString := ValueString + ', ';
                  ValueString := ValueString + '<=' + EndingValue;
                end
              end;
              else
                Summary := '=';
                ValueString := FilterValue;
            end;

          if (MatchType <> fdMatchRange) and NonMatching then
            Summary := 'Not ' + Summary;
          SubItems.Add(Summary);
          SubItems.Add(ValueString);
        end;
    ShowModal;
  finally
    Free;
  end;
end;

{ TIBFilterDialog }

constructor TIBFilterDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDialog := TfrmIBFilterDialog.Create(self);
  FOptions := [fdShowCaseSensitive, fdShowNonMatching];
  FDefaultMatchType := fdMatchStart;
  Caption := 'IBX Filter Dialog';
  FFields := TStringList.Create;
  FOriginalSQL := TStringList.Create;
  FModifiedSQL := TStringList.Create;
  FOriginalVariables := TList.Create;
end;

destructor TIBFilterDialog.Destroy;
var
  i : Integer;
begin
  FDialog.Free;
  FFields.Free;
  FOriginalSQL.Free;
  FModifiedSQL.Free;
  for i := 0 to FOriginalVariables.Count - 1 do
    TIBVariable(FOriginalVariables[i]).Free;
  FOriginalVariables.Free;
  inherited Destroy;
end;

procedure TIBFilterDialog.Execute;
var
  CurrentSQL : TStrings;
begin
  CurrentSQL := TStrings(GetOrdProp(FDataSet, SQLProp));
  // Check to see if the SQL has changed from before
  if not FModifiedSQL.Equals(CurrentSQL) then
    OriginalSQL := CurrentSQL;
  if FDialog.lstAllFields.Items.Count = 0 then
    SetFields;
  FDialog.grpSearchType.ItemIndex := Integer(FDefaultMatchType);
  if fdShowCaseSensitive in Options then
    FDialog.cbxCaseSensitive.Visible := true
  else
    FDialog.cbxCaseSensitive.Visible := false;
  if fdShowNonMatching in Options then
    FDialog.cbxNonMatching.Visible := true
  else
    FDialog.cbxNonMatching.Visible := false;
  if fdCaseSensitive in Options then
    FDialog.cbxCaseSensitive.Checked := true
  else
    FDialog.cbxCaseSensitive.Checked := false;
  SaveParamValues;
  if FDialog.ShowModal = mrOK then
    ReBuildSQL;
end;

procedure TIBFilterDialog.Loaded;
var
  i : Integer;
begin
  inherited;
  if Assigned(FDataSet) and not (csDesigning in ComponentState) then
  begin
    SetFields;
    OriginalSQL.Assign(TStrings(GetOrdProp(FDataSet, SQLProp)));
    // save off the new variable list
    if FDataSet is TIBDataSet then
      for i := 0 to TIBDataSet(FDataSet).Params.Count - 1 do
        FOriginalVariables.Add(TIBVariable.Create(TIBDataSet(FDataSet).Params[i].Name,
          TIBDataSet(FDataSet).Params[i].Value))
    else
      for i := 0 to TIBQuery(FDataSet).Params.Count - 1 do
        FOriginalVariables.Add(TIBVariable.Create(TIBQuery(FDataSet).Params[i].Name,
          TIBQuery(FDataSet).Params[i].Value));
  end;
end;

procedure TIBFilterDialog.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FDataset) and (Operation = opRemove) then
    FDataset := nil;
end;

procedure TIBFilterDialog.ReBuildSQL;
var
  s, s1 : String;
  SQL, NewSQL : TStringStream;
  p, i : Integer;
  hasWhere : boolean;
begin
  if FDialog.lstSelectedFields.Items.Count = 0 then
  begin
    // only restore if necessary
    if TStrings(GetOrdProp(FDataSet, SQLProp)) <> FOriginalSQL then
      RestoreSQL;
    exit;
  end;
  NewSQL := TStringStream.Create(s1);
  SQL := TStringStream.Create(s);
  try
    FOriginalSQL.SaveToStream(SQL);
    SQL.Seek( 0, soFromBeginning);
    p := WordPos('WHERE', SQL.DataString);   {do not localize}
    // if there is no where clause
    if p = 0 then                   
    begin
      hasWhere := false;
      p := WordPos('GROUP', SQL.DataString);  {do not localize}
      if p = 0 then
        p := WordPos('HAVING', SQL.DataString);    {do not localize}
        if p = 0 then
          P := WordPos('ORDER', SQL.DataString);   {do not localize}
          if p = 0 then
            p := SQL.Size;
    end
    else
    begin
      hasWhere := true;
      // Put the position past the WHERE
      Inc(p, 5);
    end;
    // Copy the first part over
    NewSQL.WriteString(SQL.ReadString(p - 1));
    if not hasWhere then
      NewSQL.WriteString(' WHERE ');    {do not localize}
    for i := 0 to FDialog.FilterList.Count - 1 do
    begin
      NewSQL.WriteString(FDialog[i].CreateSQL);
      if i < FDialog.FilterList.Count - 1 then
        NewSQL.WriteString(' AND ')      {do not localize}
      else
        if hasWhere then
          NewSQL.WriteString(' AND ');    {do not localize}
    end;
    NewSQL.WriteString(SQL.ReadString(SQL.Size));

    // Now Assign the SQL and set all the variables
    // Disable the controls while we are working
    if FDataSet is TIBDataSet then
      with FDataSet as TIBDataSet do
      begin
        DisableControls;
        Close;
        SelectSQL.Clear;
        SelectSQL.Add(NewSQL.DataString);
        for i := 0 to FOriginalVariables.Count - 1 do
          ParamByName(TIBVariable(FOriginalVariables[i]).VariableName).Value :=
                TIBVariable(FOriginalVariables[i]).VariableValue;
        // Set the new Variables
        for i := 0 to FDialog.FilterList.Count - 1 do
          FDialog[i].SetVariables(FDataSet);
        try
          Open;
        except
          RestoreSQL;
        end;
      end
    else
      if FDataSet is TIBQuery then
        with FDataSet as TIBQuery do
        begin
          DisableControls;
          Close;
          SQL.Clear;
          SQL.Add(NewSQL.DataString);
          for i := 0 to FOriginalVariables.Count - 1 do
            ParamByName(TIBVariable(FOriginalVariables[i]).VariableName).Value :=
                  TIBVariable(FOriginalVariables[i]).VariableValue;
          // Set the new Variables
          for i := 0 to FDialog.FilterList.Count - 1 do
            FDialog[i].SetVariables(FDataSet);
          try
            Open;
          except
            RestoreSQL;
          end;
        end;

    SetFields;
    FDataSet.EnableControls;
    FModifiedSQL.Assign(TStrings(GetOrdProp(FDataSet, SQLProp)));
  finally
    SQL.Free;
    NewSQL.Free;
  end;
end;

procedure TIBFilterDialog.RestoreSQL;
var
  i : Integer;
begin
  // Disable the controls while we are working
  FDataSet.DisableControls;
  FDataSet.Close;
  // clear the existing SQL and variable declarations
  // restore the original SQL and variables
  SetOrdProp(FDataSet, SQLProp, Integer(FOriginalSQL));
  if FDataSet is TIBDataSet then
    for i := 0 to FOriginalVariables.Count - 1 do
      TIBDataSet(FDataSet).ParamByName(TIBVariable(FOriginalVariables[i]).VariableName).Value :=
         TIBVariable(FOriginalVariables[i]).VariableValue
  else
    for i := 0 to FOriginalVariables.Count - 1 do
      TIBQuery(FDataSet).ParamByName(TIBVariable(FOriginalVariables[i]).VariableName).Value :=
         TIBVariable(FOriginalVariables[i]).VariableValue;
  FDataSet.Open;
  SetFields;
  FDataSet.EnableControls;
  FModifiedSQL.Assign(TStrings(GetOrdProp(FDataSet, SQLProp)));
end;

procedure TIBFilterDialog.SaveParamValues;
var
  i : Integer;
begin
  // save off the Params list
  if FDataSet is TIBDataSet then
    for i := 0 to FOriginalVariables.Count - 1 do
      TIBVariable(FOriginalVariables[i]).VariableValue :=
        TIBDataSet(FDataSet).ParamByName(TIBVariable(FOriginalVariables[i]).VariableName).Value
  else
    for i := 0 to FOriginalVariables.Count - 1 do
      TIBVariable(FOriginalVariables[i]).VariableValue :=
        TIBQuery(FDataSet).ParamByName(TIBVariable(FOriginalVariables[i]).VariableName).Value;
end;

procedure TIBFilterDialog.SetCaption(const Value: String);
begin
  FCaption := Value;
  FDialog.Caption := FCaption;
end;

procedure TIBFilterDialog.SetDataSet(const Value: TIBCustomDataset);
begin
  if not ((Value is TIBDataSet) or (Value is TIBQuery) or
          (Value = nil)) then
    Raise Exception.Create('IBFilterDialog only works with IBDataSet or IBQuery components');
  FDataSet := Value;
  if Value is TIBDatASet then
    SQLProp := 'SelectSQL'  {do not localize}
  else
    SQLProp := 'SQL';     {do not localize}
  if ([csDesigning, csLoading] * ComponentState) = [] then
  begin
    SetFields;
    OriginalSQL := TStrings(GetOrdProp(FDataSet, SQLProp));
  end;
end;

procedure TIBFilterDialog.SetDefaultMatchType(
  const Value: TIBFilterMatchType);
begin
  FDefaultMatchType := Value;
  if Assigned(FDialog) and not (csDesigning in ComponentState) then
    case FDefaultMatchType of
      fdMatchNone :
      begin
        FDialog.grpSearchType.ItemIndex := 0;
        FDialog.cbxNonMatching.Checked := true;
      end;
      fdMatchRange:
        FDialog.pgeCriteria.ActivePage := FDialog.tabByRange;
      else
        FDialog.grpSearchType.ItemIndex := Integer(FDefaultMatchType);
    end;
end;

procedure TIBFilterDialog.SetFields;
var
  i, j, p : Integer;
  field, display : String;
begin
  FDialog.lstAllFields.Clear;
  //  Can't get the fields if the dataset is not active yet.
//  if not FDataSet.Active then
//    exit;
  if FFields.Count = 0 then
  begin
    for i := 0 to FDataSet.FieldList.Count - 1 do
      FDialog.lstAllFields.Items.AddObject(FDataSet.FieldList.Fields[i].FieldName,
        FDataSet.FieldList.Fields[i]);
  end
  else
    for j := 0 to FFields.Count - 1 do
    begin
      p := Pos(';', FFields.Strings[j]);
      field := Copy(FFields.Strings[j], 1, p - 1);
      if p = Length(FFields.Strings[j]) then
        display := field
      else
        display := Copy(FFields.Strings[j], p+1, Length(FFields.Strings[j]));
      for i := 0 to FDataSet.FieldList.Count - 1 do
        if FDataSet.FieldList.Fields[i].FieldName = field then
        FDialog.lstAllFields.Items.AddObject(display, FDataSet.FieldList.Fields[i]);
    end;
  if FDialog.lstAllFields.Items.Count > 0 then
  begin
    FDialog.lstAllFields.ItemIndex := 0;
    FDialog.FieldsListBoxClick(nil);
  end;
end;

procedure TIBFilterDialog.SetFieldsList(const Value: TStringList);
begin
  FFields.Assign(Value);
end;

procedure TIBFilterDialog.SetOptions(const Value: TIBOptions);
begin
  FOptions := Value;
end;

procedure TfrmIBFilterDialog.FormActivate(Sender: TObject);
begin
  if FPreviousList.Count <> 0 then
  begin
    pgeFields.ActivePage := tabSelected;
    lstSelectedFields.ItemIndex := 0;
    FieldsListBoxClick(lstSelectedFields);
  end
  else
    pgeFields.ActivePage := tabAll;
end;

procedure TfrmIBFilterDialog.btnCancelClick(Sender: TObject);
var
  i : Integer;
  f : TIBFieldInfo;
begin
  // Restore the previous List
  for i := FFilterList.Count - 1 downto 0 do
  begin
    TIBFieldInfo(FFilterList[i]).Free;
    FFilterList.Delete(i);
  end;
  for i := 0 to FPreviousList.Count - 1 do
  begin
    f := TIBFieldInfo.Create;
    f.Assign(TIBFieldInfo(FPreviousList[i]));
    FFilterList.Add(f);
  end;
end;

procedure TIBFilterDialog.SetOriginalSQL(const Value: TStrings);
var
  i : Integer;
begin
  if FOriginalSQL.Text <> Value.Text then
  begin
    FOriginalSQL.Clear;
    FOriginalSQL.AddStrings(Value);
    if not (csLoading in ComponentState) then
      FFields.Clear;
    FDialog.NewSQL;
  end;
  for i := 0 to FOriginalVariables.Count - 1 do
    TIBVariable(FOriginalVariables[i]).Free;
  if TStrings(GetOrdProp(FDataSet, SQLProp)).Text = '' then
    exit;
  // save off the new variable list
  if FDataSet is TIBDataSet then
    for i := 0 to TIBDataSet(FDataSet).Params.Count - 1 do
      FOriginalVariables.Add(TIBVariable.Create(TIBDataSet(FDataSet).Params[i].Name,
        TIBDataSet(FDataSet).Params[i].Value))
  else
    for i := 0 to TIBQuery(FDataSet).Params.Count - 1 do
      FOriginalVariables.Add(TIBVariable.Create(TIBQuery(FDataSet).Params[i].Name,
        TIBQuery(FDataSet).Params[i].Value));
  SetFields;
end;

{ TIBFieldInfo }

procedure TIBFieldInfo.Assign(o : TIBFieldInfo);
begin
  FieldName := o.FieldName;
  FieldOrigin := o.FieldOrigin;
  FieldType := o.FieldType;
  DisplayLabel := o.DisplayLabel;
  MatchType := o.MatchType;
  FilterValue := o.FilterValue;
  StartingValue := o.StartingValue;
  EndingValue := o.EndingValue;
  CaseSensitive := o.CaseSensitive;
  NonMatching := o.NonMatching;
end;

procedure TfrmIBFilterDialog.btnOkClick(Sender: TObject);
var
  i : Integer;
  f : TIBFieldInfo;
begin
  // Save off the list for the possible next Execute call
  for i := FPreviousList.Count - 1 downto 0 do
  begin
    TIBFieldInfo(FPreviousList[i]).Free;
    FPreviousList.Delete(i);
  end;
  GetCriteria;
  SetCriteria;
  for i := 0 to FFilterList.Count - 1 do
  begin
    f := TIBFieldInfo.Create;
    f.Assign(TIBFieldInfo(FFilterList[i]));
    FPreviousList.Add(f);
  end;
end;

procedure TfrmIBFilterDialog.btnClearFieldValueClick(Sender: TObject);
begin
  edtFieldValue.Text := '';
end;

procedure TfrmIBFilterDialog.btnClearStartingRangeClick(
  Sender: TObject);
begin
  edtStartingRange.Text := '';
end;

procedure TfrmIBFilterDialog.btnClearEndingRangeClick(Sender: TObject);
begin
  edtEndingRange.Text := '';
end;

function TIBFieldInfo.CreateSQL: String;
var
  Field : String;
begin
  if FieldOrigin <> '' then
    Field := FieldOrigin
  else
    Field := FieldName;
  if NonMatching then
    Result := ' not ( '     {do not localize}
  else
    Result := ' ( ';     {do not localize}
  if AnsiUpperCase(FilterValue) = 'NULL' then   {do not localize}
  begin
    Result := Result + Format('%s is NULL) ', [Field]);   {do not localize}
    exit;
  end;
  if FieldType = ftString then
  begin
    if CaseSensitive then
      case MatchType of
        fdMatchStart:
          Result := Result + Format('%0:s starting with :%1:sFilter ) ', [Field, FieldName]); {do not localize}
        fdMatchAny:
          Result := Result + Format('%0:s containing :%1:sFilter ) ', [Field, FieldName]); {do not localize}
        fdMatchEnd :
          Result := Result + Format('%0:s = :%1:sFilter ) ', [Field, FieldName]); {do not localize}
        fdMatchExact :
          Result := Result + Format('%0:s = :%1:sFilter ) ', [Field, FieldName]); {do not localize}
        fdMatchRange :
        begin
          if StartingValue <> '' then
            Result := Result + Format('%0:s >= :%1:sStart)', [Field, ExtractIdentifier(3, FieldName)]); {do not localize}
          if (StartingValue <> '') and (EndingValue <> '') then
            Result := Result + ' and (';
          if EndingValue <> '' then
            Result := Result + Format('%0:s <= :%1:sEnd)', [Field, FieldName]); {do not localize}
        end;
      end
    else
      case MatchType of
        fdMatchStart:
          Result := Result + Format('UPPER(%0:s) starting with :%1:sFilter ) ', [Field, FieldName]); {do not localize}
        fdMatchAny:
          Result := Result + Format('UPPER(%0:s) containing :%1:sFilter ) ', [Field, FieldName]); {do not localize}
        fdMatchEnd :
          Result := Result + Format('UPPER(%0:s) like :%1:sFilter ) ', [Field, FieldName]);  {do not localize}
        fdMatchExact :
          Result := Result + Format('UPPER(%0:s) = :%1:sFilter ) ', [Field, FieldName]);  {do not localize}
        fdMatchRange :
        begin
          if FieldType = ftString then
          begin
            if StartingValue <> '' then
              Result := Result + Format('UPPER(%0:s) >= :%1:sStart)', [Field, FieldName]); {do not localize}
            if (StartingValue <> '') and (EndingValue <> '') then
              Result := Result + ' and (';  {do not localize}
            if EndingValue <> '' then
              Result := Result + Format('UPPER(%0:s) <= :%1:sEnd)', [Field, FieldName]); {do not localize}
          end
          else
          begin
            if StartingValue <> '' then
              Result := Result + Format('%0:s >= :%1:sStart)', [Field, FieldName]);   {do not localize}
            if (StartingValue <> '') and (EndingValue <> '') then
              Result := Result + ' and (';   {do not localize}
            if EndingValue <> '' then
              Result := Result + Format('%0:s <= :%1:sEnd)', [Field, FieldName]);  {do not localize}
          end
        end;
      end;
  end
  else
    case MatchType of
      fdMatchRange :
      begin
        if StartingValue <> '' then
          Result := Result + Format('%0:s >= :%1:sStart)', [Field, FieldName]); {do not localize}
        if (StartingValue <> '') and (EndingValue <> '') then
          Result := Result + ' and ('; {do not localize}
        if EndingValue <> '' then
          Result := Result + Format('%0:s <= :%1:sEnd)', [Field, FieldName]);  {do not localize}
      end;
      else
        Result := Result + Format('%0:s = :%1:sFilter ) ', [Field, FieldName]); {do not localize}
    end;
end;

procedure TIBFieldInfo.SetVariables(d: TIBCustomDataset);
var
  value : String;
begin
  if AnsiUpperCase(FilterValue) = 'NULL' then  {do not localize}
    exit;
  if FieldType = ftString then
  begin
    if CaseSensitive then
      case MatchType of
        fdMatchStart, fdMatchAny :
          value := FilterValue;
        fdMatchEnd :
          value := '%' + FilterValue;  {do not localize}
        fdMatchExact :
          value := FilterValue;
      end
    else
      case MatchType of
        fdMatchStart, fdMatchAny :
          value := AnsiUpperCase(FilterValue);
        fdMatchEnd :
          value := '%' + AnsiUpperCase(FilterValue);  {do not localize}
        fdMatchExact :
          value := AnsiUpperCase(FilterValue);
      end;
  end
  else
    value := FilterValue;
  if d is TIBDataSet then
  begin
    if MatchType <> fdMatchRange then
      TIBDataSet(d).ParamByName(FieldName + 'Filter').Value :=  value {do not localize}
    else
    begin
      if CaseSensitive then
      begin
        if StartingValue <> '' then
          TIBDataSet(d).ParamByName(FieldName + 'Start').Value := StartingValue; {do not localize}
        if EndingValue <> '' then
          TIBDataSet(d).ParamByName(FieldName + 'End').Value := EndingValue;  {do not localize}
      end
      else
      begin
        if StartingValue <> '' then
          TIBDataSet(d).ParamByName(FieldName + 'Start').Value := AnsiUpperCase(StartingValue); {do not localize}
        if EndingValue <> '' then
          TIBDataSet(d).ParamByName(FieldName + 'End').Value := AnsiUpperCase(EndingValue); {do not localize}
      end;
    end;
  end
  else
  begin
    if MatchType <> fdMatchRange then
      TIBQuery(d).ParamByName(FieldName + 'Filter').Value :=  value {do not localize}
    else
    begin
      if CaseSensitive then
      begin
        if StartingValue <> '' then
          TIBQuery(d).ParamByName(FieldName + 'Start').Value := StartingValue; {do not localize}
        if EndingValue <> '' then
          TIBQuery(d).ParamByName(FieldName + 'End').Value := EndingValue;  {do not localize}
      end
      else
      begin
        if StartingValue <> '' then
          TIBQuery(d).ParamByName(FieldName + 'Start').Value := AnsiUpperCase(StartingValue);  {do not localize}
        if EndingValue <> '' then
          TIBQuery(d).ParamByName(FieldName + 'End').Value := AnsiUpperCase(EndingValue);   {do not localize}
      end;
    end;
  end
end;

{ TIBVariable }

constructor TIBVariable.Create(name: String; value : Variant);
begin
  VariableName := name;
  VariableValue := value;
end;

function TfrmIBFilterDialog.GetFilterItem(
  index: Integer): TIBFieldInfo;
begin
  Result := TIBFieldInfo(FFilterList[index]);
end;

procedure TfrmIBFilterDialog.NewSQL;
var
  i : Integer;
begin
  for i := FPreviousList.Count - 1 downto 0 do
  begin
    TIBFieldInfo(FPreviousList[i]).Free;
    FPreviousList.Delete(i);
  end;
  btnNewSearchClick(nil);
end;

end.
