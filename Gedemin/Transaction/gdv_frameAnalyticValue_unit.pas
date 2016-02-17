unit gdv_frameAnalyticValue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  contnrs, AcctUtils, StdCtrls, ExtCtrls;

type
  TframeAnalyticValue = class(TFrame)
    sbAnaliseLines: TScrollBox;
    procedure sbAnaliseLinesMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  private
    { Private declarations }
    FAnaliseLines: TObjectList;
    FFields: TObjectList;
    function GetAnalyticCount: Integer;
    procedure SetValues(const Value: string);
    function GetValues: string;
    procedure ClearValues;
    function IndexOf(FieldName: string): Integer;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateAnalytic(IdList: TList);

    property AnalyticCount: Integer read GetAnalyticCount;
    property Values: string read GetValues write SetValues;
  end;

implementation

uses 
  IBSQL, gdv_frameMapOfAnalitic_unit, gdcBaseInterface, at_classes, Math;

{$R *.DFM}

{ TframeAnalyticValue }

procedure TframeAnalyticValue.ClearValues;
var
  I: Integer;
  Line: TframeMapOfAnaliticLine;
begin
  for I := 0 to FAnaliseLines.Count - 1 do
  begin
    Line := TframeMapOfAnaliticLine(FAnaliseLines[I]);
    Line.Clear;
  end;
end;

constructor TframeAnalyticValue.Create(AOwner: TComponent);
begin
  inherited;
  FFields := TObjectList.Create(False);
  FAnaliseLines := TObjectList.Create(False);

  GetAnalyticsFields(FFields);
end;

destructor TframeAnalyticValue.Destroy;
begin
  FFields.Free;
  FAnaliseLines.Free;

  inherited;
end;

function TframeAnalyticValue.GetAnalyticCount: Integer;
var
  I: Integer;
begin
   Result := 0;

   for I := 0 to FAnaliseLines.Count - 1 do
   begin
     Result := Result + TframeMapOfAnaliticLine(FAnaliseLines[I]).Count;
   end;
end;

function TframeAnalyticValue.GetValues: string;
var
  I: Integer;
  Line: TframeMapOfAnaliticLine;
  F: TatRelationField;
  S: String;
begin
  Result := '';
  for I := 0 to FAnaliseLines.Count - 1 do
  begin
    Line := TframeMapOfAnaliticLine(FAnaliseLines[I]);
    F := Line.Field;
    if not Line.cbInputParam.Checked then
    begin
      S := Line.Value;
      if S > '' then
      begin
        if Result > '' then
          Result := Result + #13#10;
        Result := Result + F.FieldName + '=' + S;
      end;
    end else
    begin
      if Result > '' then
         Result := Result + #13#10;

      Result := Result + F.FieldName + '=' + cInputParam
    end;
  end;
end;

function TframeAnalyticValue.IndexOf(FieldName: string): Integer;
var
  I: Integer;
  F: TatRelationField;
begin
  Result := -1;
  for I := 0 to FAnaliseLines.Count -1 do
  begin
    F := TframeMapOfAnaliticLine(FAnaliseLines[I]).Field;
    if F.FieldName = UpperCase(FieldName) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TframeAnalyticValue.SetValues(const Value: string);
var
  S: TStrings;
  I: Integer;
  Index: Integer;
  Line: TframeMapOfAnaliticLine;
begin
  ClearValues;
  S := TStringList.Create;
  try
    S.Text := Value;
    for I := 0 to S.Count - 1 do
    begin
      Index := IndexOf(S.Names[I]);
      if Index > - 1 then
      begin
        Line := TframeMapOfAnaliticLine(FAnaliseLines[Index]);

        if S.Values[S.Names[I]] <> cInputParam then
          Line.Value := S.Values[S.Names[I]]
        else
          Line.cbInputParam.Checked := True;
      end;
    end;
  finally
    S.Free;
  end;
end;

procedure TframeAnalyticValue.UpdateAnalytic(IdList: TList);
var
  I, Index: Integer;
  SQL: TIBSQl;
  Line: TframeMapOfAnaliticLine;
  H: Integer;
  P: Integer;
  LAnaliseLines: TObjectList;
  C: Integer;

  function IndexOf(Field: TatRelationField): Integer;
  var
    I: Integer;
  begin
    Result := - 1;
    for I := 0 to LAnaliseLines.Count - 1 do
    begin
      if TframeMapOfAnaliticLine(LAnaliseLines[I]).Field = Field then
      begin
        Result := I;
        Break;
      end;
    end
  end;

begin
  LAnaliseLines := TObjectList.Create(True);
  try
    for I := FAnaliseLines.Count - 1 downto 0 do
    begin
      LAnaliseLines.Add(FAnaliseLines[I]);
      FAnaliseLines.Extract(FAnaliseLines[I]);
    end;

    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      H := 0; P := 0;
      if IDList.Count > 0 then
      begin
        for I := 0 to FFields.Count - 1 do
        begin
          if SQL.SQL.Count > 0 then
            SQL.SQL.Add(', ');
          SQL.SQL.Add(Format('SUM(%s)', [TatRelationField(FFields[I]).FieldName]));
        end;

        if FFields.Count > 0 then
        begin
          SQL.SQL.Insert(0, 'SELECT ');
          SQL.SQL.Add('FROM ac_account ');
          SQL.SQL.Add(Format('WHERE id IN (%s)', [AcctUtils.IdList(IdList)]));
          SQL.ExecQuery;
        end;
      end;

      for I := 0 to FFields.Count - 1 do
      begin
        if IDList.Count > 0 then
          C := SQL.Fields[I].AsInteger
        else
          C := 0;

        try
          if C = IDList.Count then
          begin
            Index := IndexOf(TatRelationField(FFields[i]));
            if Index = - 1 then
            begin
              Line := TframeMapOfAnaliticLine.Create(Self);
              FAnaliseLines.Add(Line);
              with Line do
              begin
                Name := '';
                Field := TatRelationField(FFields[i]);
                Parent := sbAnaliseLines;
              end;
            end else
            begin
              Line := TframeMapOfAnaliticLine(LAnaliseLines[Index]);
              FAnaliseLines.Add(LAnaliseLines[Index]);
              LAnaliseLines.Extract(LAnaliseLines[Index]);
            end;
            with Line do
            begin
              H := Height;
              Top := P;
            end;
            P := P + H;
          end;
        finally
          SQL.Close;
        end;
      end;
      if FAnaliseLines.Count > 0 then
      begin
        sbAnaliseLines.Enabled := True;
        sbAnaliseLines.VertScrollBar.Position := 0;
        sbAnaliseLines.VertScrollBar.Increment := H;
      end else
        sbAnaliseLines.Enabled := False;
    finally
      SQL.Free;
    end;

  finally
    LAnaliseLines.Free;
  end;
end;

procedure TframeAnalyticValue.sbAnaliseLinesMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  if Sender is TScrollBox then
  begin
    if WheelDelta > 0 then
      (Sender as TScrollBox).VertScrollBar.Position :=
        (Sender as TScrollBox).VertScrollBar.Position -
        (Sender as TScrollBox).VertScrollBar.Increment
    else
      (Sender as TScrollBox).VertScrollBar.Position :=
        (Sender as TScrollBox).VertScrollBar.Position +
        (Sender as TScrollBox).VertScrollBar.Increment;

    Handled := True;
  end;
end;

end.
