// ShlTanya, 09.03.2019

unit gdv_frAcctTreeAnalytic_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, gdvParamPanel, gdv_AvailAnalytics_unit, at_classes, contnrs,
  gdv_frAcctTreeAnalyticLine_unit, Math;

type
  Tgdv_frAcctTreeAnalytic = class(TFrame)
    ppMain: TgdvParamPanel;
    procedure ppMainResize(Sender: TObject);
  private
    FLinesList: TObjectList;
    procedure SortLine;
    procedure UpdateTabOrder;
    function GetLines(Index: Integer): Tgdv_frAcctTreeAnalyticLine;
    function GetTreeAnalitic: string;
    procedure SetTreeAnalitic(const Value: string);
    function GetCount: Integer;
  public
    destructor Destroy; override;
    procedure UpdateAnalyticsList(AnalyticsList: TgdvAnalyticsList);
    procedure CheckProcedures;

    function InfexOf(F: TatRelationField): Integer;

    property Count: Integer read GetCount;
    property Lines[Index: Integer]: Tgdv_frAcctTreeAnalyticLine read GetLines; default;
    property TreeAnalitic: string read GetTreeAnalitic write SetTreeAnalitic;
  end;

implementation

{$R *.DFM}

procedure Tgdv_frAcctTreeAnalytic.CheckProcedures;
var
  I: Integer;
begin
  if FLinesList <> nil then
  begin
    for I := 0 to FLinesList.Count - 1 do
    begin
      Tgdv_frAcctTreeAnalyticLine(FLinesList[i]).CheckProcedure
    end;
  end;
end;

destructor Tgdv_frAcctTreeAnalytic.Destroy;
begin
  FLinesList.Free;
  inherited;
end;

function Tgdv_frAcctTreeAnalytic.GetCount: Integer;
begin
  Result := FLinesList.Count;
end;

function Tgdv_frAcctTreeAnalytic.GetLines(
  Index: Integer): Tgdv_frAcctTreeAnalyticLine;
begin
  Result := nil;
  if FLinesList <> nil then
  begin
    Result := Tgdv_frAcctTreeAnalyticLine(FLinesList[Index]);
  end;
end;

function Tgdv_frAcctTreeAnalytic.GetTreeAnalitic: string;
var
  I: Integer;
  Line: Tgdv_frAcctTreeAnalyticLine;
  S: TStrings;
begin
  Result := '';
  if FLinesList <> nil then
  begin
    S := TStringList.Create;
    try
      for I := 0 to FLinesList.Count - 1 do
      begin
        Line := Tgdv_frAcctTreeAnalyticLine(FLinesList[I]);
        if not Line.IsEmpty then
        begin
          S.Add(Line.Field.FieldName + '=' + Line.eLevel.Text);
        end;
      end;
      if S.Count > 0 then
      begin
        Result := S.Text;
      end;
    finally
      S.Free;
    end;
  end;
end;

function Tgdv_frAcctTreeAnalytic.InfexOf(F: TatRelationField): Integer;
var
  I: Integer;
begin
  Result := -1;
  if FLinesList <> nil then
  begin
    for I := 0 to FLinesList.Count - 1 do
    begin
      if Tgdv_frAcctTreeAnalyticLine(FLinesList[I]).Field = F then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;
end;

procedure Tgdv_frAcctTreeAnalytic.ppMainResize(Sender: TObject);
begin
  SetBounds(Left, Top, ppMain.Width, ppMain.Height);
end;


procedure Tgdv_frAcctTreeAnalytic.SetTreeAnalitic(const Value: string);
var
  S: TStrings;
  I: Integer;
  A, V: string;
  J: Integer;
  Line: Tgdv_frAcctTreeAnalyticLine;
begin
  if FLinesList <> nil then
  begin
    for J := 0 to FLinesList.Count - 1 do
    begin
      Line := Tgdv_frAcctTreeAnalyticLine(FLinesList[J]);
      Line.eLevel.Text := '';
    end;

    S := TStringList.Create;
    try
      S.Text := Value;
      for I := 0 to S.Count - 1 do
      begin
        A := S.Names[I];
        V := S.Values[A];

        for J := 0 to FLinesList.Count - 1 do
        begin
          Line := Tgdv_frAcctTreeAnalyticLine(FLinesList[J]);
          if Line.Field.FieldName = A then
          begin
            Line.eLevel.Text := V;
            Break;
          end;
        end;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure Tgdv_frAcctTreeAnalytic.SortLine;
var
  S: TStringList;
  I: Integer;
  T: Integer;
begin
  if FLinesList.Count > 0 then
  begin
    S := TStringList.Create;
    try
      for I := 0 to FLinesList.Count - 1 do
      begin
        S.AddObject(Tgdv_frAcctTreeAnalyticLine(FLinesList[I]).lAnaliticName.Caption,
          FLinesList[I]);
      end;
      S.Sort;

      T := ppMain.ClientRect.Top;
      for I := 0 to S.Count - 1 do
      begin
        Tgdv_frAcctTreeAnalyticLine(S.Objects[I]).Top := T;
        T := T + Tgdv_frAcctTreeAnalyticLine(S.Objects[I]).Height;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure Tgdv_frAcctTreeAnalytic.UpdateAnalyticsList(AnalyticsList: TgdvAnalyticsList);
var
  I, Index: Integer;
  F: TatRelationField;
  LList: TObjectList;
  Line: Tgdv_frAcctTreeAnalyticLine;
  H, W: Integer;
  P: Integer;

  function IndexOf(F: TatRelationField): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to LList.Count - 1 do
    begin
      if Tgdv_frAcctTreeAnalyticLine(LList[I]).Field = F then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;

begin
  P := ppMain.ClientRect.Top;
  if FLinesList = nil then
    FLinesList := TObjectList.Create;

  LList := TObjectList.Create;
  try
    for I := FLinesList.Count - 1 downto 0 do
    begin
      LList.Add(FLinesList[I]);
      FLinesList.Extract(FLinesList[I]);
    end;

    for I := 0 to AnalyticsList.Count - 1 do
    begin
      F := AnalyticsList[i].Field;
      if F <> nil then
      begin
        if (F.References <> nil) and
          (F.References.IsLBRBTreeRelation) then
        begin
          Index := IndexOf(F);
          if Index > - 1 then
          begin
            Line := Tgdv_frAcctTreeAnalyticLine(LList[Index]);
            LList.Extract(Line);
          end else
          begin
            Line := Tgdv_frAcctTreeAnalyticLine.Create(nil);
            Line.Parent := ppMain;
            Line.Name := 'gdv_frAcctTreeAnalyticLine_' + StringReplace(F.FieldName, '$', '_', [rfReplaceAll]);
            Line.Field := F;
            Line.Color := ppMain.FillColor;

          end;
          FLinesList.Add(Line);

          with Line do
          begin
            H := Height;
            Top := P;
          end;
          P := P + H;
        end;
      end;
    end;

    ppMain.UpdateHeight(Max(P + 4, cMinUnwrapedHeight));

  finally
    LList.Free;
  end;

  W := 0;
  for I := 0 to ppMain.ControlCount - 1 do
  begin
    W := Max(Tgdv_frAcctTreeAnalyticLine(ppMain.Controls[i]).lAnaliticName.Left +
      Tgdv_frAcctTreeAnalyticLine(ppMain.Controls[i]).lAnaliticName.Width, W);
  end;
  W := W + 5;

  for I := 0 to ppMain.ControlCount - 1 do
  begin
    Tgdv_frAcctTreeAnalyticLine(ppMain.Controls[i]).eLevel.Left := W;
    Tgdv_frAcctTreeAnalyticLine(ppMain.Controls[i]).eLevel.Width :=
      Tgdv_frAcctTreeAnalyticLine(ppMain.Controls[i]).ClientWidth - 2 - W;
  end;
  SortLine;
  UpdateTabOrder;
end;

procedure Tgdv_frAcctTreeAnalytic.UpdateTabOrder;
var
  T, Index, Order: Integer;

  function GetNextIndex(ATop: Integer): Integer;
  var
    I: Integer;
    Delta: Integer;
  begin
    Delta := MaxInt;
    Result := -1;
    for I := 0 to ppMain.ControlCount - 1 do
    begin
      if (ATop < ppMain.Controls[I].Top) and (ppMain.Controls[I].Top - ATop < Delta) then
      begin
        Result := I;
        Delta := ppMain.Controls[I].Top - ATop;
      end;
    end;
  end;
begin
  T := Low(Integer);
  Order := 0;
  while GetNextIndex(T) > -1 do
  begin
    Index := GetNextIndex(T);
    T := ppMain.Controls[Index].Top;
    if ppMain.Controls[Index] is TWinControl then
    begin
      (ppMain.Controls[Index] as TWinControl).TabOrder := Order;
      Inc(Order);
    end;
  end;
end;

end.
