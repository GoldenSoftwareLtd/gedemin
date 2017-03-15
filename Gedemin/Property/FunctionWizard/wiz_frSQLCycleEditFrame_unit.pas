unit wiz_frSQLCycleEditFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  WIZ_FREDITFRAME_UNIT, StdCtrls, ComCtrls, TB2Dock, SynEditHighlighter,
  SynHighlighterSQL, SynEdit, wiz_FunctionBlock_unit, IBSQL, gdcBaseInterface,
  wiz_frSQLCycleParamLine_unit, contnrs, Math, ExtCtrls, wiz_Strings_unit,
  TB2Item, ActnList, TB2Toolbar;

type
  TfrSQLCycleEditFrame = class(TfrEditFrame)
    tsSQL: TTabSheet;
    SynSQLSyn1: TSynSQLSyn;
    TBDock1: TTBDock;
    tsParams: TTabSheet;
    Panel1: TPanel;
    sbParams: TScrollBox;
    Panel2: TPanel;
    seSQL: TSynEdit;
    TBToolbar1: TTBToolbar;
    ActionList: TActionList;
    actSave: TAction;
    actLoad: TAction;
    actSQLEditor: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem3: TTBItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    procedure PageControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure actSaveExecute(Sender: TObject);
    procedure actLoadExecute(Sender: TObject);
    procedure actSQLEditorExecute(Sender: TObject);
  private
    { Private declarations }
    FLines: TObjectList;
    function UpdateParamList: Boolean;
    procedure SetParamValues(Values: string);
    function GetParamValues: string;
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    { Public declarations }
    destructor Destroy; override;
    function CheckOk: Boolean; override;
    procedure SaveChanges; override;
  end;

var
  frSQLCycleEditFrame: TfrSQLCycleEditFrame;

implementation
uses flt_frmSQLEditorSyn_unit;
{$R *.DFM}

{ TfrSQLCycleEditFrame }

function TfrSQLCycleEditFrame.CheckOk: Boolean;
var
  SQL: TIBSQL;
begin
  Result := inherited CheckOk;
  if Result then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Assign(seSQL.Lines);
      try
        SQL.Prepare;
      except
        on E: Exception do
        begin
          Result := False;
          ShowCheckOkMessage(Format(MSG_SQL_ERROR, [E.Message]));
        end;
      end;
    finally
      SQL.Free;
    end;
  end;

  if Result then
  begin
    UpdateParamList;
  end;
end;

destructor TfrSQLCycleEditFrame.Destroy;
begin
  FLines.Free;
  inherited;
end;

procedure TfrSQLCycleEditFrame.SaveChanges;
begin
  inherited;
  with FBlock as TSQLCycleBlock do
  begin
    SQL := seSQL.Lines.Text;
    Params := GetParamValues;
  end;
end;

procedure TfrSQLCycleEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;

  with FBlock as TSQLCycleBlock do
  begin
    seSQL.Lines.Text := SQL;
    if UpdateParamList then
    begin
      SetParamValues(Params);
    end;
  end;
end;

function TfrSQLCycleEditFrame.UpdateParamList: Boolean;
var
  SQL: TIBSQL;
  I, Index: Integer;
  L: TSQLCycleParamLine;
  W: Integer;
  P, V: TStrings;
begin
  P := TStringList.Create;
  V := TStringList.Create;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQl.Assign(seSQL.Lines);
    try
      if FLines = nil then
        FLines := TObjectList.Create
      else
      begin
        for I := 0 to FLines.Count - 1 do
        begin
          L := TSQLCycleParamLine(FLines[I]);
          V.Add(L.ParamName + '=' + L.Value);
        end;

        FLines.Clear;
      end;

      if SQL.SQL.Count > 0 then
      begin
        SQL.Prepare;
        W := 0;
        for I := 0 to SQL.Params.Count - 1 do
        begin
          if P.IndexOf(SQL.Params[I].Name) = - 1 then
          begin
            L := TSQLCycleParamLine.Create(nil);
            L.Parent := sbParams;
            L.ParamName := SQL.Params[I].Name;
            L.Block := FBlock;
            L.Top := (I + 1) * L.Height;

            Index := V.IndexOfName(SQL.Params[I].Name);
            if Index > - 1 then
            begin
              L.Value := V.Values[V.Names[Index]];
            end;

            FLines.Add(L);
            W := Max(W, L.lName.Left + L.lName.Width);
            P.Add(SQL.Params[I].Name);
          end;
        end;

        for I := 0 to FLines.Count - 1 do
        begin
          L := TSQLCycleParamLine(FLines[I]);
          L.cbNull.Left := W + 3;
          L.eParam.Left := L.cbNull.Left + L.cbNull.Width + 3;
          L.eParam.Width := L.Width - 3 - L.eParam.Left;
        end;
      end;  
      Result := True;
    except
      on E: Exception do
      begin
        Result := False;
        ShowCheckOkMessage(Format(MSG_SQL_ERROR, [E.Message]));
      end;
    end;
  finally
    SQL.Free;
    P.Free;
    V.Free;
  end;
end;

procedure TfrSQLCycleEditFrame.PageControlChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if PageControl.ActivePage = tsSQL then
  begin
    AllowChange := UpdateParamList;
  end;
end;

procedure TfrSQLCycleEditFrame.SetParamValues(Values: string);
var
  V: TStrings;
  I: Integer;
  L: TSQLCycleParamLine;
begin
  if FLines <> nil then
  begin
    V := TStringList.Create;
    try
      V.Text := Values;
      for I := 0 to FLines.Count - 1 do
      begin
        L := TSQLCycleParamLine(FLines[I]);
        if V.IndexOfName(L.ParamName) > - 1 then
        begin
          L.Value := V.Values[L.ParamName];
        end;
      end;
    finally
      V.Free;
    end;
  end;
end;

function TfrSQLCycleEditFrame.GetParamValues: string;
var
  I: Integer;
  L: TSQLCycleParamLine;
begin
  Result := '';
  if FLines <> nil then
  begin
    for I := 0 to FLines.Count -1 do
    begin
      L := TSQLCycleParamLine(FLines[I]);
      if Result > '' then Result := Result + #13#10;
      Result := Result + L.ParamName + '=' + L.Value; 
    end;
  end;
end;

procedure TfrSQLCycleEditFrame.actSaveExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    seSQL.Lines.SaveToFile(SaveDialog.FileName);
  end;
end;

procedure TfrSQLCycleEditFrame.actLoadExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    seSQL.Lines.LoadFromFile(OpenDialog.FileName);
  end;
end;

procedure TfrSQLCycleEditFrame.actSQLEditorExecute(Sender: TObject);
var
  D: TfrmSQLEditorSyn;
begin
  D := TfrmSQLEditorSyn.Create(Application);
  try
    D.FDatabase := gdcBaseManager.Database;
    if D.ShowSQL(seSQL.Lines.Text, nil, True) = mrOk then
    begin
      seSQL.Lines.Text := D.seQuery.Text;
    end;
  finally
    D.Free;
  end;
end;

end.
