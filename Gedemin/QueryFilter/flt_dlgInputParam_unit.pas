unit flt_dlgInputParam_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Db, IBSQL, TB2Dock, TB2Toolbar, dmImages_unit,
  TB2Item, ActnList, flt_frParamLine_unit;

type
  TdlgInputParam = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    ScrollBox: TScrollBox;
    pnTop: TPanel;
    TBDock1: TTBDock;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ActionList: TActionList;
    actSaveToFile: TAction;
    actLoadFromFile: TAction;
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
  private
    FLineList: TList;

    function AddLine(Param: TIBXSQLVAR): TfrParamLine;
    procedure DeleteLine;
    procedure ClearLine;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function SetParams(const AnParam: TIBXSQLDA): Boolean;
  end;

var
  dlgInputParam: TdlgInputParam;

implementation

uses
  IBHeader, xDateEdits
{$IFDEF VER140}
  , Variants
{$ENDIF}
  ;

{$R *.DFM}

function TdlgInputParam.AddLine(Param: TIBXSQLVAR): TfrParamLine;
begin
  Result := TfrParamLine.Create(nil, Param);
  Result.Parent := ScrollBox;
  Result.Top := FLineList.Count * Result.Height;

  FLineList.Add(Result);
end;

procedure TdlgInputParam.DeleteLine;
begin
  TfrParamLine(FLineList.Items[FLineList.Count - 1]).Free;
  FLineList.Delete(FLineList.Count - 1);
end;

procedure TdlgInputParam.ClearLine;
begin
  while FLineList.Count > 0 do
    DeleteLine;
end;

function TdlgInputParam.SetParams(const AnParam: TIBXSQLDA): Boolean;
var
  I: Integer;
  S: TStrings;
  Index: Integer;
begin
  Result := True;
  ClearLine;
  if AnParam.Count > 0 then
  begin
    S := TStringList.Create;
    try
      for I := 0 to AnParam.Count - 1 do
      begin
        if S.IndexOf(AnParam.Vars[I].Name) <> -1 then
          continue;
        S.Add(AnParam.Vars[I].Name);
        AddLine(AnParam.Vars[I]);
      end;

      if ShowModal = mrOk then
      begin
        for I := 0 to AnParam.Count - 1 do
        begin
          Index := S.IndexOf(AnParam.Vars[I].Name);
          if TfrParamLine(FLineList.Items[Index]).IsNull then
            AnParam.Vars[I].Clear
          else
            case AnParam.Vars[I].SQLType and (not 1) of
              SQL_SHORT, SQL_LONG:
                AnParam.Vars[I].AsInteger := TfrParamLine(FLineList.Items[Index]).AsInteger;
              SQL_INT64, SQL_DOUBLE, SQL_FLOAT, SQL_D_FLOAT:
                AnParam.Vars[I].AsCurrency := TfrParamLine(FLineList.Items[Index]).AsCurrency;
              SQL_TYPE_DATE:
                  AnParam.Vars[I].AsDate := TfrParamLine(FLineList.Items[Index]).AsDate;
              SQL_TYPE_TIME:
                AnParam.Vars[I].AsTime := TfrParamLine(FLineList.Items[Index]).AsTime;
              SQL_TIMESTAMP:
                AnParam.Vars[I].AsDateTime := TfrParamLine(FLineList.Items[Index]).AsDateTime;
            else
              AnParam.Vars[I].AsString := TfrParamLine(FLineList.Items[Index]).AsString;
            end;
        end;
      end else
        Result := False;
    finally
      S.Free;
    end;
  end;
end;

constructor TdlgInputParam.Create(AnOwner: TComponent);
begin
  inherited;
  FLineList := TList.Create;
end;

destructor TdlgInputParam.Destroy;
begin
  ClearLine;
  FLineList.Free;
  inherited;
end;

procedure TdlgInputParam.actSaveToFileExecute(Sender: TObject);
var
  List: TStringList;
  I: Integer;
  S: String;
begin
  if SaveDialog.Execute then
  begin
    List := TStringList.Create;
    try
      for I := 0 to FLineList.Count - 1 do
      begin
        S := TfrParamLine(FLineList.Items[I]).lblName.Caption + '=';
        if TfrParamLine(FLineList.Items[I]).IsNull then
          S := S + '<NULL>'
        else
          S := S + '"' + TfrParamLine(FLineList.Items[I]).AsString + '"';
        List.Add(S);
      end;
      List.SaveToFile(SaveDialog.FileName);
    finally
      List.Free;
    end;
  end;
end;

procedure TdlgInputParam.actLoadFromFileExecute(Sender: TObject);
var
  List: TStringList;
  I: Integer;
  N, S: String;
begin
  if OpenDialog.Execute then
  begin
    List := TStringList.Create;
    try
      List.LoadFromFile(OpenDialog.FileName);
      try
        for I := 0 to FLineList.Count - 1 do
        begin
          N := TfrParamLine(FLineList.Items[I]).lblName.Caption;
          if List.IndexOfName(N) <> -1 then
          begin
            S := List.Values[N];
            if S = '<NULL>' then
              TfrParamLine(FLineList.Items[I]).IsNull := True
            else begin
              TfrParamLine(FLineList.Items[I]).IsNull := False;
              if (Copy(S, 1, 1) = '"') and (Copy(S, Length(S), 1) = '"') then
                S := Copy(S, 2, Length(S) - 2);
              TfrParamLine(FLineList.Items[I]).AsString := S;
            end;
          end;
        end;
      except
        on E: Exception do
          Application.ShowException(E);
      end;
    finally
      List.Free;
    end;
  end;
end;

end.
