unit frFieldVlues_unit;

{$M+}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst, ExtCtrls, gdvParamPanel, contnrs, at_Classes, db, Math,
  frFieldValuesLine_unit, frFieldValuesLineConfig_unit, gdcBaseInterface, AcctUtils,
  ImgList, Menus, dmImages_unit;

type
  TViewKind = (vkParamPanel, vkConfig, vkSimple);
                                                              
  TfrFieldValues = class(TFrame)
    pmCondition: TPopupMenu;
    mi0: TMenuItem;
    mi1: TMenuItem;
    mi2: TMenuItem;
    mi3: TMenuItem;
    mi4: TMenuItem;
    mi5: TMenuItem;
    mi6: TMenuItem;
    mi7: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    ppMain: TgdvParamPanel;
    sbMain: TgdvParamScrolBox;
    procedure ppMainResize(Sender: TObject);
  private
    FLinesList: TObjectList;
    FAlias: string;
    FViewKind: TViewKind;
    FLineType: string;
    FAlign: TAlign;
    FNeedClearValues: boolean;
    FSorted: boolean;
    function GetLines(Index: Integer): TfrFieldValuesLine;
    function GetCondition: string;
    procedure SetAlias(const Value: string);
    procedure SortLine;
    procedure ClearValues;
    function GetValues: string;
    procedure SetValues(const Value: string);
    function GetCount: integer;
    function GetViewControl: TWinControl;
    procedure SetViewKind(const Value: TViewKind);
    function GetLineType: string;
    function GetLineAlign: TAlign;
    function GetLinesCount: integer;
  public
    destructor Destroy; override;
    procedure UpdateFieldList(FieldList: TObjectList);
    property Lines[Index: Integer]: TfrFieldValuesLine read GetLines; default;
    function IndexOf(FN: string): Integer;
    property Condition: string read GetCondition;
    property Alias:  string read FAlias write SetAlias;
    property Values: string read GetValues write SetValues;
    property Count:  integer read GetCount;
    property ViewCtrl: TWinControl read GetViewControl;
    property LineType: string read GetLineType write FLineType;
    procedure UpdateFrameHeight;
    procedure UpdateLines;
    property  LineAlign: TAlign read GetLineAlign write FAlign default alTop;
    property LinesCount: integer read GetLinesCount;
    property NeedClearValues: boolean read FNeedClearValues write FNeedClearValues default True;
    property ViewKind: TViewKind read FViewKind write SetViewKind default vkParamPanel;
    property Sorted: boolean read FSorted write FSorted default True;
  end;

implementation

{$R *.DFM}

{ Tgdv_frFieldsData }

procedure TfrFieldValues.ClearValues;
var
  I: Integer;
begin
  if FLinesList <> nil then
    for I := 0 to FLinesList.Count - 1 do begin
      Lines[I].Value := '';
    end;
end;

destructor TfrFieldValues.Destroy;
begin
  if Assigned(FLinesList) then
    FLinesList.Free;
  inherited;
end;

function TfrFieldValues.GetCondition: string;
var
  I: Integer;
  Line: TfrFieldValuesLine;
  F: TatRelationField;
begin
  Result := '';
  if FLinesList <> nil then begin
    for I := 0 to FLinesList.Count - 1 do begin
      Line := Lines[I];
      F := Line.Field;
      if not Line.IsEmpty then begin
        if Result > '' then
          Result := Result + ' AND '#13#10;
        Result := Result + FAlias + '.' + F.FieldName + Line.Condition;
      end;
    end;
  end;
end;

function TfrFieldValues.GetCount: integer;
begin
  Result:= FLinesList.Count;
end;

function TfrFieldValues.GetLines(Index: Integer): TfrFieldValuesLine;
begin
  Result := nil;
  if FLinesList <> nil then
    Result := TfrFieldValuesLine(FLinesList[Index]);
end;

function TfrFieldValues.GetValues: string;
var
  I: Integer;
  Line: TfrFieldValuesLine;
begin
  Result := '';
  if FLinesList <> nil then begin
    for I := 0 to FLinesList.Count - 1 do begin
      Line := Lines[I];
      if not Line.IsEmpty then begin
        if Result > '' then
          Result := Result + #13#10;
        Result := Result + Line.Field.FieldName + '=' + Line.Value;
      end;
    end;
  end;
end;

function TfrFieldValues.IndexOf(FN: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  if FLinesList <> nil then begin
    for I := 0 to FLinesList.Count - 1 do begin
      if TfrFieldValuesLine(FLinesList[I]).Field.FieldName = FN then begin
        Result := I;
        Exit;
      end;
    end;
  end;
end;

procedure TfrFieldValues.SetAlias(const Value: string);
begin
  FAlias := Value;
end;

procedure TfrFieldValues.SetValues(const Value: string);
var
  S: TStrings;
  I: Integer;
  Index: Integer;
  Line: TfrFieldValuesLine;
begin
  if FNeedClearValues then
    ClearValues;
  S := TStringList.Create;
  try
    S.Text := Value;
    for I := 0 to S.Count - 1 do begin
      if (S.Values[S.Names[I]] <> cInputParam) or (ViewKind = vkConfig) then begin
        Index := IndexOf(S.Names[I]);
        if Index > - 1 then begin
          Line := FLinesList[Index] as TfrFieldValuesLine;
          Line.Value := S.Values[S.Names[I]];
        end;
      end;
    end;
  finally
    S.Free;
  end;
end;

procedure TfrFieldValues.SortLine;
var
  S: TStringList;
  I: Integer;
  T: Integer;
begin
  if FLinesList.Count > 0 then begin
    S := TStringList.Create;
    try
      for I := 0 to FLinesList.Count - 1 do begin
        S.AddObject(TfrFieldValuesLine(FLinesList[I]).lblName.Caption,
          FLinesList[I]);
      end;
      S.Sort;

      T := ppMain.ClientRect.Top;
      for I := 0 to S.Count - 1 do begin
        TfrFieldValuesLine(S.Objects[I]).Top := T;
        T := T + TfrFieldValuesLine(S.Objects[I]).Height;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure TfrFieldValues.UpdateFieldList(FieldList: TObjectList);
var
  F: TatRelationField;
  Line: TfrFieldValuesLine;
  iTop, i, Index, j: integer;
  LList: TObjectList;
  C: TClass;
begin
  iTop := ppMain.ClientRect.Top + 2;
  if FLinesList = nil then
    FLinesList := TObjectList.Create;

  LList := TObjectList.Create;
  try
    for I := FLinesList.Count - 1 downto 0 do begin
      LList.Add(FLinesList[I]);
      FLinesList.Extract(FLinesList[I]);
    end;
    for i:= 0 to FieldList.Count - 1 do begin
      if not Assigned(FieldList[i]) then Continue;
      if TatRelationField(FieldList[i]).Field.FieldType = ftBlob then Continue;
      F:= TatRelationField(FieldList[i]);
      Index:= -1;
      for j:= 0 to LList.Count - 1 do
        if TfrFieldValuesLine(LList[j]).Field.FieldName = F.FieldName then begin
          Index:= j;
          Break;
        end;
      if Index > - 1 then begin
        Line := TfrFieldValuesLine(LList[Index]);
        LList.Extract(Line);
      end else begin
        C:= GetClass(LineType);
        Line:= CfrFieldValuesLine(C).Create(GetViewControl);
        Line.lblName.Constraints.MaxWidth:= 150;
        Line.cmbValue.Transaction:= gdcBaseManager.ReadTransaction;
        Line.Parent:= GetViewControl;
        Line.Name:= 'FieldValuesLine_' + StringReplace(F.FieldName, '$', '_', [rfReplaceAll]);
        Line.Field:= F;
        if FViewKind = vkParamPanel then
          Line.Color:= ppMain.FillColor
        else
          Line.Color:= sbMain.Color;
        Line.Align:= LineAlign;
      end;
      iTop:= iTop + Line.Height;
      if FViewKind = vkParamPanel then
        ppMain.Height:= iTop + 4;
      FLinesList.Add(Line);
    end;
  finally
    LList.Free;
  end;
  UpdateLines;
  if FSorted then
    SortLine;
  UpdateTabOrder(GetViewControl);
  UpdateFrameHeight;
end;

procedure TfrFieldValues.ppMainResize(Sender: TObject);
begin
  Height:= ppMain.Height;
end;

function TfrFieldValues.GetViewControl: TWinControl;
begin
  if FViewKind = vkParamPanel then
    Result:= ppMain
  else
    Result:= sbMain;
end;

procedure TfrFieldValues.SetViewKind(const Value: TViewKind);
begin
  FViewKind := Value;
  ppMain.Visible:= FViewKind = vkParamPanel;
  sbMain.Visible:= FViewKind in [vkConfig, vkSimple];
  if FViewKind in [vkParamPanel, vkSimple] then
    FLineType:= 'TfrFieldValuesLine'
  else
    FLineType:= 'TfrFieldValuesLineConfig';
  if FViewKind = vkSimple then
    sbMain.BorderStyle:= bsNone;
end;

function TfrFieldValues.GetLineType: string;
begin
  if FViewKind in [vkParamPanel, vkSimple] then
    FLineType:= 'TfrFieldValuesLine'
  else
    FLineType:= 'TfrFieldValuesLineConfig';
  Result := FLineType;
end;

procedure TfrFieldValues.UpdateFrameHeight;
var
  i, H, iMax: integer;
begin
  H:= 0;
  iMax:= 0;
  for i:= 0 to FLinesList.Count - 1 do begin
    H:= H + Lines[i].Height;
    iMax:= Max(iMax, Lines[i].Height);
  end;
  if FViewKind = vkParamPanel then begin
    if Parent is TScrollBox then
      TScrollBox(Parent).AutoScroll:= False;
    H:= H + ppMain.ClientRect.Top + 2;
    ppMain.UpdateHeight(Max(H + 4, cMinUnwrapedHeight));
    Height:= ppMain.Height;
    if Parent is TScrollBox then
      TScrollBox(Parent).AutoScroll:= True;
  end
  else begin
    sbMain.AutoScroll:= False;
    if LineAlign = alLeft then begin
      Height:= iMax;
    end
    else if Align <> alClient then begin
      Height:= H;
    end;
    sbMain.AutoScroll:= True;
  end;
end;

procedure TfrFieldValues.UpdateLines;
var
  I, W: integer;
begin
  W:= 0;
  for I:= 0 to GetViewControl.ControlCount - 1 do begin
    W:= Max(TfrFieldValuesLine(GetViewControl.Controls[i]).lblName.Left +
      TfrFieldValuesLine(GetViewControl.Controls[i]).lblName.Width, W);
  end;
  for I:= 0 to GetViewControl.ControlCount - 1 do begin
    TfrFieldValuesLine(GetViewControl.Controls[i]).SetControlPosition(W);
  end;
end;

function TfrFieldValues.GetLineAlign: TAlign;
begin
  if FAlign = alNone then
    FAlign:= alTop;
  Result := FAlign;
end;

function TfrFieldValues.GetLinesCount: integer;
begin
  Result:= FLinesList.Count
end;

end.
