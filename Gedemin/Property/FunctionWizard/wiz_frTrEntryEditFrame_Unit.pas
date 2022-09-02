// ShlTanya, 09.03.2019

unit wiz_frTrEntryEditFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_frMultiEditFrame_Unit, StdCtrls, ComCtrls, wiz_FunctionBlock_unit,
  BtnEdit, Menus, wiz_Strings_unit, gdcBaseInterface,
  at_classes,
  gdc_frmAnalyticsSel_unit,
  gdcConstants, IBSQL, contnrs, Math,
  wiz_frAnalyticLine_unit, ExtCtrls;

type
  TfrTrEntryEditFrame = class(TfrMultiEditFrame)
    pmCompany: TPopupMenu;
    lCompany: TLabel;
    beCompany: TBtnEdit;
    lDate: TLabel;
    beDate: TBtnEdit;
    Label3: TLabel;
    beEntryDescription: TBtnEdit;
    tsAttr: TTabSheet;
    Panel1: TPanel;
    sbAnalytics: TScrollBox;
    procedure beDateBtnOnClick(Sender: TObject);
    procedure beCompanyBtnOnClick(Sender: TObject);
    procedure pmCompanyPopup(Sender: TObject);
    procedure beCompanyChange(Sender: TObject);

  private
    { Private declarations }
    FCompanyKey: Integer;
    FAvailAnalyticFields: TList;
    FAnalyticLines: TObjectList;

    procedure ClickCompany(Sender: TObject);
    procedure ClickExpression(Sender: TObject);
  protected
    function CanEdit(V: TVisualBlock): boolean; override;
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    { Public declarations }
    destructor Destroy; override;
    procedure SaveChanges; override;
  end;

var
  frTrEntryEditFrame: TfrTrEntryEditFrame;

implementation

{$R *.DFM}

{ TfrTrEntryEditFrame }

function TfrTrEntryEditFrame.CanEdit(V: TVisualBlock): boolean;
begin
  Result := V is TTrEntryPositionBlock
end;

procedure TfrTrEntryEditFrame.beDateBtnOnClick(Sender: TObject);
begin
  TEditSButton(Sender).Edit.Text := FBlock.EditExpression(TEditSButton(Sender).Edit.Text, FBlock);
end;

procedure TfrTrEntryEditFrame.beCompanyBtnOnClick(Sender: TObject);
begin
  beClick(Sender, pmCompany);
end;

procedure TfrTrEntryEditFrame.pmCompanyPopup(Sender: TObject);
var
  MI: TMenuItem;
begin
  pmCompany.Items.Clear;
  MI := TMenuItem.Create(pmCompany);
  MI.Caption := RUS_COMPANY;
  MI.OnClick := ClickCompany;
  pmCompany.Items.Add(MI);

  MI := TMenuItem.Create(pmCompany);
  MI.Caption := '-';
  pmCompany.Items.Add(MI);

  MI := TMenuItem.Create(pmCompany);
  MI.Caption := RUS_EXPRESSION;
  MI.OnClick := ClickExpression;
  pmCompany.Items.Add(MI);
end;

procedure TfrTrEntryEditFrame.ClickCompany(Sender: TObject);
var
  F: TatRelationField;
  D: TfrmAnalyticSel;
begin
  if FActiveEdit <> nil then
  begin
    F := atDatabase.FindRelationField(AC_RECORD, fnCompanyKey);
    if F <> nil then
    begin
      D := TfrmAnalyticSel.Create(nil);
      try
        D.DataField := F;
        if FCompanyKey > 0 then
          D.AnalyticsKey := FCompanyKey;

        if D.ShowModal = mrOk then
        begin
          FActiveEdit.Text := D.AnalyticAlias;
          FCompanyKey := D.AnalyticsKey;
        end;
      finally
        D.Free;
      end;
    end;
  end;
end;

procedure TfrTrEntryEditFrame.ClickExpression(Sender: TObject);
begin
  FActiveEdit.Text := FBlock.EditExpression(FActiveEdit.Text, FBlock);
end;

procedure TfrTrEntryEditFrame.beCompanyChange(Sender: TObject);
begin
  FCompanyKey := 0;
end;


procedure TfrTrEntryEditFrame.SaveChanges;
var
  S: TStrings;
  I: Integer;
begin
  inherited;
  with FBlock as TTrEntryBlock do
  begin
    if FCompanyKey > 0 then
    begin
      CompanyRUID := gdcBaseManager.GetRUIDStringById(FCompanyKey);
    end else
    begin
      CompanyRUID := beCompany.Text;
    end;

    EntryDate := beDate.Text;
    EntryDescription := beEntryDescription.Text;

    Attributes := '';
    if (FAnalyticLines <> nil) and (FAnalyticLines.Count > 0) then
    begin
      S := TStringList.Create;
      try
        for I := 0 to FAnalyticLines.Count - 1 do
        begin
          if TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text > '' then
          begin
            if (TfrAnalyticLine(FAnalyticLines[I]).Field.ReferencesField <> nil) and
              (TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey > 0) then
            begin
              S.Add(TfrAnalyticLine(FAnalyticLines[I]).Field.FieldName +
                '=' + gdcBaseManager.GetRUIDStringById(TfrAnalyticLine(FAnalyticLines[I]).AnalyticKey))
            end else
              S.Add(TfrAnalyticLine(FAnalyticLines[I]).Field.FieldName +
                '=' + TfrAnalyticLine(FAnalyticLines[I]).eAnalytic.Text);
          end;
        end;
        Attributes := S.Text;
      finally
        S.Free;
      end;
    end;
  end;
end;

procedure TfrTrEntryEditFrame.SetBlock(const Value: TVisualBlock);
var
  SQL: TIBSQL;
  Id: Integer;
  I, J: Integer;
  R: TatRelation;
  W, T: Integer;
  Line: TfrAnalyticLine;
  S: TStrings;
  FieldName: String;
begin
  inherited;
  with FBlock as TTrEntryBlock do
  begin
    if CheckRuid(CompanyRUID) then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        SQl.SQl.Text := 'SELECT name FROM gd_contact WHERE id = :id';
        ID := gdcBaseManager.GetIDByRUIDString(CompanyRUID);
        SQL.ParamByName(fnId).AsInteger := Id;
        SQl.ExecQuery;
        beCompany.Text := SQL.FieldByName(fnName).AsString;
        FCompanyKey := Id;
      finally
        SQl.Free;
      end;
    end else
    begin
      FCompanyKey := 0;
      beCompany.Text := CompanyRUID;
    end;

    beDate.Text := EntryDate;
    beEntryDescription.Text := EntryDescription;

    if FAvailAnalyticFields = nil then
    begin
      FAvailAnalyticFields := TList.Create;

      R := atDatabase.Relations.ByRelationName('AC_RECORD');
      if R <> nil then
        for i := 0 to R.RelationFields.Count - 1 do
          if Pos('USR$', UpperCase(R.RelationFields[I].FieldName)) = 1 then
            FAvailAnalyticFields.Add(R.RelationFields[I]);
    end;

    tsAttr.TabVisible := FAvailAnalyticFields.Count > 0;
    if tsAttr.TabVisible then
    begin
      if FAnalyticLines = nil then
      begin
        FAnalyticLines := TObjectList.Create;
      end else
        FAnalyticLines.Clear;

      W := 0;
      for I := 0 to FAvailAnalyticFields.Count - 1 do
      begin
        Line := TfrAnalyticLine.Create(nil);
        FAnalyticLines.Add(Line);
        Line.Field := TatRelationField(FAvailAnalyticFields[I]);
        Line.Block := FBlock;

        Line.Parent := sbAnalytics;
        W := Max(W, Line.lName.Width + Line.lName.Left);
      end;

      T := 0;
      for i := 0 to FAnalyticLines.Count - 1 do
      begin
        Line := TfrAnalyticLine(FAnalyticLines[i]);
        Line.Top := T;
        Line.TabOrder := i;
        Line.eAnalytic.Left := W + 3;
        Line.eAnalytic.Width := Line.Width - Line.eAnalytic.Left - 3;
        T := Line.Height + T;
      end;

      if (FAnalyticLines <> nil) and (FAnalyticLines.Count > 0) then
      begin
        SQL := TIBSQL.Create(nil);
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        S := TStringList.Create;
        try
          S.Text := Attributes;
          for I := 0 to S.Count - 1 do
          begin
            FieldName := S.Names[I];
            for J := 0 to FAnalyticLines.Count - 1 do
            begin
              if TfrAnalyticLine(FAnalyticLines[J]).Field.FieldName = FieldName then
              begin
                id := 0;
                if TfrAnalyticLine(FAnalyticLines[J]).Field.ReferencesField <> nil then
                begin
                  try
                    if CheckRuid(S.Values[FieldName]) then
                      id := gdcBaseManager.GetIDByRUIDString(S.Values[FieldName])
                    else
                      id := 0;
                  except
                    Id := 0;
                  end;
                end;

                if id > 0 then
                begin
                  SQL.SQl.Text := Format('SELECT %s FROM %s WHERE %s = %d',
                    [TfrAnalyticLine(FAnalyticLines[J]).Field.References.ListField.FieldName,
                    TfrAnalyticLine(FAnalyticLines[J]).Field.References.RelationName,
                    TfrAnalyticLine(FAnalyticLines[J]).Field.ReferencesField.FieldName,
                    TID264(id)]);
                  SQL.ExecQuery;
                  try
                    TfrAnalyticLine(FAnalyticLines[J]).eAnalytic.Text := SQL.Fields[0].AsString;
                    TfrAnalyticLine(FAnalyticLines[J]).AnalyticKey := Id;
                  finally
                    SQL.Close;
                  end;
                end else
                  TfrAnalyticLine(FAnalyticLines[J]).eAnalytic.Text := S.Values[FieldName];
              end;
            end;
          end;
        finally
          S.Free;
          SQL.Free;
        end;
      end;

    end;
  end;
end;

destructor TfrTrEntryEditFrame.Destroy;
begin
  if Assigned(FAvailAnalyticFields) then
    FreeAndNil(FAvailAnalyticFields);
  if Assigned(FAnalyticLines) then
    FreeAndNil(FAnalyticLines);

  inherited;
end;

end.
