unit flt_dlgInputParam_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Db, IBSQL, TB2Dock, TB2Toolbar, dmImages_unit,
  TB2Item, ActnList;

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

    function AddLine(Param: TIBXSQLVAR): Integer;
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
  flt_frParamLine_unit, IBHeader, xDateEdits
{$IFDEF VER140}
  , Variants
{$ENDIF}
  ;

{$R *.DFM}

function TdlgInputParam.AddLine(Param: TIBXSQLVAR): Integer;
var
  Frame: TfrParamLine;
begin
  Frame := TfrParamLine.Create(nil);
  Frame.InitParamType(Param);
  Result:= FLineList.Add(Frame);
  TfrParamLine(FLineList.Items[FLineList.Count - 1]).Parent := ScrollBox;
  TfrParamLine(FLineList.Items[FLineList.Count - 1]).Top :=
   FLineList.Count * TfrParamLine(FLineList.Items[FLineList.Count - 1]).Height;
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
  I, J: Integer;
  S: TStrings;
  Index: Integer;
begin
  Result := AnParam.Count = 0;
  if not Result then
  begin
    ClearLine;
    S := TStringList.Create;
    try
      for I := 0 to AnParam.Count - 1 do
      begin
        if S.IndexOf(AnParam.Vars[I].Name) = -1 then
        begin
          S.Add(AnParam.Vars[I].Name);
          J := AddLine(AnParam.Vars[I]);
          TfrParamLine(FLineList.Items[J]).lblName.Caption := AnParam.Vars[I].Name;
          TfrParamLine(FLineList.Items[J]).cbNull.Checked := AnParam.Vars[I].IsNull;
          if TfrParamLine(FLineList.Items[J]).edValue is TxCustomDateEdit then
            TxCustomDateEdit(TfrParamLine(FLineList.Items[J]).edValue).DateTime := AnParam.Vars[I].AsDateTime
          else
            TfrParamLine(FLineList.Items[J]).edValue.Text := AnParam.Vars[I].AsString;
        end;
      end;
      if ShowModal = mrOk then
      begin
        for I := 0 to AnParam.Count - 1 do
        begin
          Index := S.IndexOf(AnParam.Vars[I].Name);
          if TfrParamLine(FLineList.Items[Index]).cbNull.Checked then
            AnParam.Vars[I].Value := NULL
          else
            case AnParam.Vars[I].SQLType and (not 1) of
              SQL_SHORT, SQL_LONG:
                AnParam.Vars[I].AsInteger := StrToInt(TfrParamLine(FLineList.Items[Index]).edValue.Text);
              SQL_INT64, SQL_DOUBLE, SQL_FLOAT, SQL_D_FLOAT:
                AnParam.Vars[I].AsCurrency := StrToCurr(TfrParamLine(FLineList.Items[Index]).edValue.Text);
              SQL_TYPE_DATE:
                  AnParam.Vars[I].AsDate := StrToDate(TfrParamLine(FLineList.Items[Index]).edValue.Text);
              SQL_TYPE_TIME:
                AnParam.Vars[I].AsTime := StrToTime(TfrParamLine(FLineList.Items[Index]).edValue.Text);
              SQL_TIMESTAMP:
                AnParam.Vars[I].AsDateTime := StrToDateTime(TfrParamLine(FLineList.Items[Index]).edValue.Text);
            else
              AnParam.Vars[I].AsString := TfrParamLine(FLineList.Items[Index]).edValue.Text;
            end;
        end;
        Result := True;
      end;
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
begin
  if SaveDialog.Execute then
  begin
    List := TStringList.Create;
    try
      for I := 0 to FLineList.Count - 1 do
      begin
        List.Add(TfrParamLine(FLineList.Items[I]).lblName.Caption + '=' +
          TfrParamLine(FLineList.Items[I]).edValue.Text);
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
  I, J, Position: Integer;
  S: String;
begin
  if OpenDialog.Execute then
  begin
    List := TStringList.Create;
    try
      List.LoadFromFile(OpenDialog.FileName);
      for I := 0 to FLineList.Count - 1 do
      begin
        for J := 0 to List.Count do
        begin
          if List.Names[J] = TfrParamLine(FLineList.Items[I]).lblName.Caption then
          begin
            //Загрузим значение и выходим
            S := List[J];
            Position := Pos('=', S);
            if Position > 0  then
            begin
              S := Copy(S, Position + 1, Length(S));
              TfrParamLine(FLineList.Items[I]).edValue.Text := S;
              break;
            end;
          end;
        end;
      end;
    finally
      List.Free;
    end;
  end;
end;

end.
