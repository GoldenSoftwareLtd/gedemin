// ShlTanya, 25.02.2019

unit prp_dlgBreakPointProperty_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ActnList, StdCtrls, obj_i_Debugger;

type
  TdlgBreakPointProperty = class(TForm)
    Panel1: TPanel;
    btCancel: TButton;
    btOk: TButton;
    ActionList: TActionList;
    Bevel1: TBevel;
    cbName: TComboBox;
    cbLine: TComboBox;
    cbCondition: TComboBox;
    cbPassCount: TComboBox;
    lbName: TLabel;
    lbLine: TLabel;
    lbCondition: TLabel;
    lbPassCount: TLabel;
    actOk: TAction;
    actCancel: TAction;
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure cbPassCountExit(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FBreakPoint: TBreakPoint;
    { Private declarations }
    procedure CheckHistory(ComboBox: TComboBox);
    procedure SetBreakPoint(const Value: TBreakPoint);
    procedure CheckNumber(ComboBox: TComboBox);
    procedure SaveHistory;
    procedure LoadHistory;
    procedure UpdateBreakPoint;
  public
    { Public declarations }
    property BreakPoint: TBreakPoint read FBreakPoint write SetBreakPoint;
  end;

var
  dlgBreakPointProperty: TdlgBreakPointProperty;

implementation

uses
  prp_MessageConst,
  IBSQL,
  gdcBaseInterface,
  gdcConstants,
  Storages
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  sBreakPointPropertyHistoryPath = 'Options\PropertySettings\BreakPointPoropertyHostory';
  cName = 'Name';
  cLine = 'Line';
  cCondition = 'Condition';
  cPassCount = 'PassCount';

{$R *.DFM}

{ TdlgBreakPointProperty }

procedure TdlgBreakPointProperty.CheckHistory(ComboBox: TComboBox);
var
  S: String;
  I: Integer;
begin
  S := Trim(ComboBox.Text);
  if (S > '') and (ComboBox.Items.IndexOf(S) = - 1) then
    ComboBox.Items.Insert(0, S);
  if ComboBox.Items.Count > 30 then
  begin
    for I := ComboBox.Items.Count - 1 downto 30 do
      ComboBox.Items.Delete(I);
  end;
end;

procedure TdlgBreakPointProperty.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgBreakPointProperty.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
  CheckHistory(cbName);
  CheckHistory(cbLine);
  CheckHistory(cbCondition);
  CheckHistory(cbPassCount);
  UpdateBreakPoint;
  FBreakPoint := nil;
end;

procedure TdlgBreakPointProperty.cbPassCountExit(Sender: TObject);
begin
  CheckNumber(TComboBox(Sender));
end;

procedure TdlgBreakPointProperty.SetBreakPoint(const Value: TBreakPoint);
var
  SQL: TIBSQL;
begin
  FBreakPoint := Value;
  if FBreakPoint <> nil then
  begin
    with FBreakPoint do
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQl.Transaction := gdcBaseManager.ReadTransaction;
        SQL.SQL.Text := 'SELECT ' + fnName + ' FROM gd_function WHERE id = :id';
        SetTID(SQl.Params[0], FunctionKey);
        SQL.ExecQuery;
        cbName.Text := SQL.FieldByName(fnName).AsString;
      finally
        SQl.Free;
      end;
      cbLine.Text := IntToStr(Line);
      cbCondition.Text := Condition;
      cbPassCount.Text := IntToStr(PassCount);
    end;
  end;
end;

procedure TdlgBreakPointProperty.CheckNumber(ComboBox: TComboBox);
begin
  try
    StrToInt(Trim(ComboBox.Text));
  except
    MessageBox(Application.Handle, '¬ведено некорректное число.', MSG_ERROR,
      MB_OK or MB_TASKMODAL or MB_ICONERROR);
    Abort;
  end;
end;

procedure TdlgBreakPointProperty.LoadHistory;
begin
  if UserStorage <> nil then
  begin
    cbName.Items.Text := UserStorage.ReadString(sBreakPointPropertyHistoryPath, cName);
    cbLine.Items.Text := UserStorage.ReadString(sBreakPointPropertyHistoryPath, cLine);
    cbCondition.Items.Text := UserStorage.ReadString(sBreakPointPropertyHistoryPath, cCondition);
    cbPassCount.Items.Text := UserStorage.ReadString(sBreakPointPropertyHistoryPath, cPassCount);
  end;
end;

procedure TdlgBreakPointProperty.SaveHistory;
begin
  if UserStorage <> nil then
  begin
    UserStorage.WriteString(sBreakPointPropertyHistoryPath, cName, cbName.Items.Text);
    UserStorage.WriteString(sBreakPointPropertyHistoryPath, cLine, cbLine.Items.Text);
    UserStorage.WriteString(sBreakPointPropertyHistoryPath, cCondition, cbCondition.Items.Text);
    UserStorage.WriteString(sBreakPointPropertyHistoryPath, cPassCount, cbPassCount.Items.Text);
  end;
end;

procedure TdlgBreakPointProperty.FormCreate(Sender: TObject);
begin
  LoadHistory;
end;

procedure TdlgBreakPointProperty.FormDestroy(Sender: TObject);
begin
  SaveHistory;
end;

procedure TdlgBreakPointProperty.UpdateBreakPoint;
begin
  if FBreakPoint <> nil then
  begin
    with FBreakPoint do
    begin
      Line := StrToInt(cbLine.Text);
      Condition := cbCondition.Text;
      PassCount := StrToInt(cbPassCount.Text);
    end;
  end;
end;

end.
