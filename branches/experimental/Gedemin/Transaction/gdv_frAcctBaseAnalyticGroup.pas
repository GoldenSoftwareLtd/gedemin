unit gdv_frAcctBaseAnalyticGroup;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_AvailAnalytics_unit,ActnList, stdctrls, gd_common_functions, IBSQL,
  AcctStrings, gdcBaseInterface, AcctUtils, checklst;

type
  TfrAcctBaseAnalyticsGroup = class(TFrame)
    ActionList1: TActionList;
    actUp: TAction;
    actDown: TAction;
    actInclude: TAction;
    actIncludeAll: TAction;
    actExclude: TAction;
    actExcludeAll: TAction;
    procedure actUpExecute(Sender: TObject);
    procedure actUpUpdate(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
    procedure actDownUpdate(Sender: TObject);
    procedure actIncludeExecute(Sender: TObject);
    procedure actIncludeUpdate(Sender: TObject);
    procedure actIncludeAllExecute(Sender: TObject);
    procedure actIncludeAllUpdate(Sender: TObject);
    procedure actExcludeExecute(Sender: TObject);
    procedure actExcludeUpdate(Sender: TObject);
    procedure actExcludeAllExecute(Sender: TObject);
    procedure actExcludeAllUpdate(Sender: TObject);
    procedure lbAvailDblClick(Sender: TObject);
    procedure lbSelectedDblClick(Sender: TObject);
    procedure lbAvailKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbSelectedKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Action1Execute(Sender: TObject);
  private
    FOnSelect: TNotifyEvent;
    FStringListAvail: TStringList;
    function GetAvail: TgdvAvailAnalytics;
    function GetSelected: TgdvAnalyticsList;
    function GetSelectedCount: Integer;
    procedure SetOnSelect(const Value: TNotifyEvent);
    function GetAnalyticListFields: String;
    procedure SetAnalyticListFields(const Value: String);
    { Private declarations }
  protected
    FAvailFieldList: TgdvAvailAnalytics;
    FSelectedFieldList: TgdvAnalyticsList;

    procedure UpdateSelectedFieldList;virtual;
    procedure SelectedFieldListClear;
    function ListBoxSelected: TCheckListBox;virtual; abstract;
    function ListBoxAvail: TListBox;virtual; abstract;
    function AvailIndex(FieldName: string): Integer;
    function StringListAvail: TStringList;
    procedure DoSelect;
  public
    { Public declarations }
    destructor Destroy; override;

    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;

    procedure UpdateAnalyticsList(AIdList: TList); virtual;

    property Avail: TgdvAvailAnalytics read GetAvail;
    property Selected: TgdvAnalyticsList read GetSelected;
    property SelectedCount: Integer read GetSelectedCount;
    property OnSelect: TNotifyEvent read FOnSelect write SetOnSelect;
    property AnalyticListFields: String read GetAnalyticListFields write SetAnalyticListFields;
  end;

implementation

{$R *.DFM}
procedure TfrAcctBaseAnalyticsGroup.actDownExecute(Sender: TObject);
var
  S: String;
  P: Pointer;
  ItemData: LongInt;
  ItemIndex: Integer;
begin
  if ListBoxSelected.ItemIndex < ListBoxSelected.Items.Count - 1 then
  begin
    ItemIndex := ListBoxSelected.ItemIndex;
    S := ListBoxSelected.Items[ItemIndex + 1];
    P := ListBoxSelected.Items.Objects[ItemIndex + 1];
    ItemData := SendMessage(ListBoxSelected.Handle, LB_GETITEMDATA, ItemIndex + 1, 0);

    ListBoxSelected.Items[ItemIndex + 1] := ListBoxSelected.Items[ItemIndex];
    SendMessage(ListBoxSelected.Handle, LB_SETITEMDATA, ItemIndex + 1,
      SendMessage(ListBoxSelected.Handle, LB_GETITEMDATA, ItemIndex, 0));
    ListBoxSelected.Items.Objects[ItemIndex + 1] := ListBoxSelected.Items.Objects[ItemIndex];

    ListBoxSelected.Items[ItemIndex] := S;
    SendMessage(ListBoxSelected.Handle, LB_SETITEMDATA, ItemIndex,  ItemData);
    ListBoxSelected.Items.Objects[ItemIndex] := P;

    ListBoxSelected.ItemIndex := ListBoxSelected.ItemIndex + 1;
  end;
  SelectedFieldListClear;
end;

procedure TfrAcctBaseAnalyticsGroup.actDownUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (ListBoxSelected.ItemIndex >= 0)
    and (ListBoxSelected.Items.Count > 1);
end;

procedure TfrAcctBaseAnalyticsGroup.actExcludeAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ListBoxSelected.Items.Count - 1 do
  begin
    ListBoxAvail.Items.AddObject(ListBoxSelected.Items[I], ListBoxSelected.Items.Objects[I]);
  end;

  ListBoxSelected.Items.Clear;
  SelectedFieldListClear;
  DoSelect;
end;

procedure TfrAcctBaseAnalyticsGroup.actExcludeAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ListBoxSelected.Items.Count > 0;
end;

function TfrAcctBaseAnalyticsGroup.StringListAvail: TStringList;
begin
  if FStringListAvail = nil then
    FStringListAvail := TStringList.Create;
    
  Result := FStringListAvail;
end;

procedure TfrAcctBaseAnalyticsGroup.actExcludeExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ListBoxSelected.Items.Count - 1 do
    if ListBoxSelected.Selected[I] then
      ListBoxAvail.Items.AddObject(ListBoxSelected.Items[I], ListBoxSelected.Items.Objects[I]);

  for I := ListBoxSelected.Items.Count - 1 downto 0 do
    if ListBoxSelected.Selected[I] then
      ListBoxSelected.Items.Delete(I);

  SelectedFieldListClear;
  DoSelect;
end;

procedure TfrAcctBaseAnalyticsGroup.actExcludeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ListBoxSelected.ItemIndex > -1;
end;

procedure TfrAcctBaseAnalyticsGroup.actIncludeAllExecute(Sender: TObject);
var
  I: Integer;
  Index: Integer;
begin
  for I := 0 to ListBoxAvail.Items.Count - 1 do
  begin
    Index := ListBoxSelected.Items.AddObject(ListBoxAvail.Items[I], ListBoxAvail.Items.Objects[I]);
    ListBoxSelected.Checked[Index] := True;
  end;

  ListBoxAvail.Items.Clear;
  SelectedFieldListClear;
  DoSelect;
end;

procedure TfrAcctBaseAnalyticsGroup.actIncludeAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ListBoxAvail.Items.Count > 0;
end;

procedure TfrAcctBaseAnalyticsGroup.actIncludeExecute(Sender: TObject);
var
  I: Integer;
  Index: Integer;
begin
  for I := 0 to ListBoxAvail.Items.Count - 1 do
  begin
    if ListBoxAvail.Selected[I] then
    begin
      Index := ListBoxSelected.Items.AddObject(ListBoxAvail.Items[I], ListBoxAvail.Items.Objects[I]);
      ListBoxSelected.Checked[Index] := True;
    end;
  end;

  for I := ListBoxAvail.Items.Count - 1 downto 0 do
  begin
    if ListBoxAvail.Selected[I] then
      ListBoxAvail.Items.Delete(I);
  end;

  SelectedFieldListClear;
  DoSelect;
end;

procedure TfrAcctBaseAnalyticsGroup.actIncludeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ListBoxAvail.ItemIndex > -1;
end;

procedure TfrAcctBaseAnalyticsGroup.actUpExecute(Sender: TObject);
var
  S: String;
  P: Pointer;
  ItemData: LongInt;
  ItemIndex: Integer;
begin
  if ListBoxSelected.ItemIndex > 0 then
  begin
    ItemIndex := ListBoxSelected.ItemIndex;
    S := ListBoxSelected.Items[ItemIndex - 1];
    P := ListBoxSelected.Items.Objects[ItemIndex - 1];
    ItemData := SendMessage(ListBoxSelected.Handle, LB_GETITEMDATA, ItemIndex - 1, 0);

    ListBoxSelected.Items[ItemIndex - 1] := ListBoxSelected.Items[ItemIndex];
    SendMessage(ListBoxSelected.Handle, LB_SETITEMDATA, ItemIndex - 1,
      SendMessage(ListBoxSelected.Handle, LB_GETITEMDATA, ItemIndex, 0));
    ListBoxSelected.Items.Objects[ItemIndex - 1] := ListBoxSelected.Items.Objects[ItemIndex];

    ListBoxSelected.Items[ItemIndex] := S;
    SendMessage(ListBoxSelected.Handle, LB_SETITEMDATA, ItemIndex, ItemData);
    ListBoxSelected.Items.Objects[ItemIndex] := P;

    ListBoxSelected.ItemIndex := ListBoxSelected.ItemIndex - 1;
  end;
  SelectedFieldListClear;
end;

procedure TfrAcctBaseAnalyticsGroup.actUpUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (ListBoxSelected.ItemIndex >= 0)
    and (ListBoxSelected.Items.Count > 1);
end;

function TfrAcctBaseAnalyticsGroup.AvailIndex(FieldName: string): Integer;
var
  I: Integer;
begin
  Result := - 1;
  for I := 0 to StringListAvail.Count - 1 do
  begin
    if TgdvAnalytics(StringListAvail.Objects[I]).FieldName = FieldName then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

destructor TfrAcctBaseAnalyticsGroup.Destroy;
begin
  inherited;
  FAvailFieldList.Free;
  FSelectedFieldList.Free;
  FStringListAvail.Free;
end;

function TfrAcctBaseAnalyticsGroup.GetAvail: TgdvAvailAnalytics;
begin
  if FAvailFieldList = nil then
  begin
    FAvailFieldList := TgdvAvailAnalytics.Create;
    FAvailFieldList.Refresh;
  end;  

  Result := FAvailFieldList;
end;

function TfrAcctBaseAnalyticsGroup.GetSelected: TgdvAnalyticsList;
begin
  if FSelectedFieldList = nil then
    FSelectedFieldList := TgdvAnalyticsList.Create;

  UpdateSelectedFieldList;

  Result := FSelectedFieldList;
end;

function TfrAcctBaseAnalyticsGroup.GetSelectedCount: Integer;
begin
  Result := Selected.Count;
end;

procedure TfrAcctBaseAnalyticsGroup.lbAvailDblClick(Sender: TObject);
begin
  actInclude.Execute;
end;

procedure TfrAcctBaseAnalyticsGroup.lbAvailKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_SPACE then
  begin
    actInclude.Execute;
    Key := 0;
  end else
    inherited;
end;

procedure TfrAcctBaseAnalyticsGroup.lbSelectedDblClick(Sender: TObject);
begin
  actExclude.Execute;
end;

procedure TfrAcctBaseAnalyticsGroup.lbSelectedKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_SPACE then
  begin
    actExclude.Execute;
    Key := 0;
  end else
    inherited;
end;

procedure TfrAcctBaseAnalyticsGroup.LoadFromStream(Stream: TStream);
var
  I: Integer;
  Count: Integer;
  Index: Integer;
  FieldName: string;
  SIndex: Integer;
  AvIndex: Integer;
begin
  SelectedFieldListClear;
  ListBoxSelected.Items.BeginUpdate;
  try
    ListBoxSelected.Items.Clear;

    Count := ReadIntegerFromStream(Stream);
    for I := 0 to Count - 1 do
    begin
      FieldName := ReadStringFromStream(Stream);
      Index := AvailIndex(FieldName);
      if Index > - 1 then
      begin
        SIndex := ListBoxSelected.Items.AddObject(StringListAvail[Index],
          StringListAvail.Objects[Index]);
        ListBoxSelected.Checked[SIndex] := ReadBooleanFromStream(Stream);

        AvIndex := ListBoxAvail.Items.IndexOfObject(StringListAvail.Objects[Index]);
        if AvIndex > -1 then
          ListBoxAvail.Items.Delete(AvIndex);
      end;
    end;
  finally
    ListBoxSelected.Items.EndUpdate;
  end;
  DoSelect;
end;

procedure TfrAcctBaseAnalyticsGroup.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  SaveIntegerToStream(SelectedCount, Stream);
  for I := 0 to SelectedCount - 1 do
  begin
    SaveStringToStream(Selected[I].FieldName, Stream);
    SaveBooleanToStream(Selected[I].Total, Stream);
  end;
end;

procedure TfrAcctBaseAnalyticsGroup.SelectedFieldListClear;
begin
  if FSelectedFieldList <> nil then
  begin
    FSelectedFieldList.Clear;
    FreeAndNil(FSelectedFieldList);
  end;
end;

procedure TfrAcctBaseAnalyticsGroup.UpdateAnalyticsList(AIdList: TList);
var
  I: Integer;
  SQL: TIBSQl;
begin
  if FAvailFieldList = nil then
  begin
    FAvailFieldList := TgdvAvailAnalytics.Create;
    FAvailFieldList.Refresh;
  end;

  StringListAvail.Clear;

  ListBoxAvail.Items.BeginUpdate;
  try
    ListBoxAvail.Items.Clear;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;

      for I := 0 to FAvailFieldList.Count - 1 do
      begin
        if (FAvailFieldList[i].Field <> nil) and
          (FAvailFieldList[i].FieldName <> ENTRYDATE) and
          (FAvailFieldList[i].FieldName <> 'ACCOUNTKEY') and
          (FAvailFieldList[i].FieldName <> 'CURRKEY') and
          (FAvailFieldList[i].FieldName <> 'COMPANYKEY') then
        begin
          if SQL.SQL.Count > 0 then
            SQL.SQL.Add(', ');

          SQL.SQL.Add(Format('Sum(%s)', [FAvailFieldList[i].FieldName]));

{          SQL.SQL.Text := Format('SELECT COUNT(*) FROM AC_ACCOUNT WHERE ' +
            '(%s = 1)', [FAvailFieldList[i].FieldName]);

          if AIDList.Count > 0 then
            SQL.SQL.Add(Format('AND id IN (%s)', [AcctUtils.IdList(AIdList)]));

          SQL.ExecQuery;
          try
            if (SQL.Fields[0].AsInteger = AIDList.Count) or (AIDList.Count = 0) then
              ListBoxAvail.Items.AddObject(FAvailFieldList[i].Caption,
                FAvailFieldList[I]);
          finally
            SQL.Close;
          end;                      }
        end else
        begin
          StringListAvail.AddObject(FAvailFieldList[i].Caption, FAvailFieldList[I]);
        end;
      end;
      if SQL.SQL.Count > 0 then
      begin
        SQL.SQL.Insert(0, 'SELECT ');
        SQL.SQL.Add('FROM ac_account ');
        if AIDList.Count > 0 then
          SQL.SQL.Add(Format('WHERE id IN (%s)', [AcctUtils.IdList(AIdList)]));
        SQL.ExecQuery;
        for I := 0 to FAvailFieldList.Count - 1 do
        begin
          if (FAvailFieldList[i].Field <> nil) and
            (FAvailFieldList[i].FieldName <> ENTRYDATE) and
            (FAvailFieldList[i].FieldName <> 'ACCOUNTKEY') and
            (FAvailFieldList[i].FieldName <> 'CURRKEY') and
            (FAvailFieldList[i].FieldName <> 'COMPANYKEY') and
            ((SQL.Fields[i].AsInteger = AIDList.Count) or (AIDList.Count = 0)) then
          begin
            StringListAvail.AddObject(FAvailFieldList[i].Caption, FAvailFieldList[I]);
          end;
        end;  
      end;
    finally
      SQL.Free;
    end;

    SelectedFieldListClear;
    for I := ListBoxSelected.Items.Count - 1 downto 0 do
    begin
      if (StringListAvail.IndexOfObject(ListBoxSelected.Items.Objects[I]) = -1) then
        ListBoxSelected.Items.Delete(I);
    end;

    for I := 0 to StringListAvail.Count - 1 do
    begin
      if (ListBoxSelected.Items.IndexOfObject(StringListAvail.Objects[I]) = -1) then
        ListBoxAvail.Items.AddObject(StringListAvail[I], StringListAvail.Objects[I]);
    end;

  finally
    ListBoxAvail.Items.EndUpdate;
  end;
  DoSelect;
end;

procedure TfrAcctBaseAnalyticsGroup.UpdateSelectedFieldList;
var
  I: Integer;
begin
  if FSelectedFieldList.Count = 0 then
  begin
    for I := 0 to ListBoxSelected.Items.Count - 1 do
    begin
      FSelectedFieldList.Add(ListBoxSelected.Items.Objects[I]);
      TgdvAnalytics(ListBoxSelected.Items.Objects[I]).Total := ListBoxSelected.Checked[I]
    end;
  end;
end;

procedure TfrAcctBaseAnalyticsGroup.Action1Execute(Sender: TObject);
begin
//
end;

procedure TfrAcctBaseAnalyticsGroup.SetOnSelect(const Value: TNotifyEvent);
begin
  FOnSelect := Value;
end;

procedure TfrAcctBaseAnalyticsGroup.DoSelect;
begin
  if Assigned(FOnselect) then
    FOnSelect(Self);
end;

function TfrAcctBaseAnalyticsGroup.GetAnalyticListFields: String;
var
  List: TStrings;
  AnalyticCounter: Integer;
begin
  Result := '';
  List := TStringList.Create;
  try
    for AnalyticCounter := 0 to SelectedCount - 1 do
    begin
      if Assigned(Selected.Analytics[AnalyticCounter].ListField) then
        List.Add(Selected.Analytics[AnalyticCounter].FieldName + '=' +
          Selected.Analytics[AnalyticCounter].ListField.FieldName);
    end;
    Result := List.Text;
  finally
    FreeAndNil(List);
  end;
end;

procedure TfrAcctBaseAnalyticsGroup.SetAnalyticListFields(const Value: String);
var
  List: TStrings;
  AnalyticCounter: Integer;
begin
  List := TStringList.Create;
  try
    List.Text := Value;
    for AnalyticCounter := 0 to SelectedCount - 1 do
    begin
      if List.IndexOfName(Selected.Analytics[AnalyticCounter].FieldName) > -1 then
        Selected.Analytics[AnalyticCounter].SetListFieldByFieldName(List.Values[Selected.Analytics[AnalyticCounter].FieldName]);
    end;
  finally
    FreeAndNil(List);
  end;
end;

end.
