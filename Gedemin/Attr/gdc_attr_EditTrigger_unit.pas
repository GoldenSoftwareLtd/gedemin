unit gdc_attr_EditTrigger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, Db, IBDataBase, ActnList, StdCtrls, ExtCtrls, SynEdit, SynMemo,
  SynEditHighlighter, SynHighlighterSQL, IBSQL, gdcBase, gdc_dlgG_unit,
  Menus;

type
  Tgdc_attr_EditTrigger = class(Tgdc_dlgG)
    Bevel1: TBevel;
    pMainTrigger: TPanel;
    smTriggerBody: TSynMemo;
    SynSQLSyn1: TSynSQLSyn;
    procedure FormCreate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FCheckTrigger: Boolean;
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    function GetTriggerBody: String;
    procedure SetTriggerBody(const Value: String);

  protected
    function DlgModified: Boolean; override;
  public
    { Public declarations }
    function TestCorrect: Boolean; override; 

    property TriggerBody: String read GetTriggerBody write SetTriggerBody;
    property CheckTrigger: Boolean read FCheckTrigger write FCheckTrigger;
    property Database: TIBDatabase read FDatabase write FDatabase;
    property Transaction: TIBTransaction read FTransaction write FTransaction;
  end;

var
  gdc_attr_EditTrigger: Tgdc_attr_EditTrigger;

implementation

uses
  gd_ClassList;

{$R *.DFM}

{ Tgdc_attr_EditTrigger }

function Tgdc_attr_EditTrigger.GetTriggerBody: String;
begin
  Result := smTriggerBody.Text;
end;

procedure Tgdc_attr_EditTrigger.SetTriggerBody(const Value: String);
begin
  smTriggerBody.Text := Value;
end;

function Tgdc_attr_EditTrigger.TestCorrect: Boolean;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  ibsql: TIBSQL;
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_ATTR_EDITTRIGGER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_ATTR_EDITTRIGGER', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_ATTR_EDITTRIGGER') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_ATTR_EDITTRIGGER',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_ATTR_EDITTRIGGER' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  if FCheckTrigger then
  begin
    Result := False;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Database := Database;
      ibsql.Transaction := Transaction;
      ibsql.SQL.Text := TriggerBody;
      ibsql.ParamCheck := False;
      try
        ibsql.Prepare;
        Result := True;
      except
        on E: Exception do
          raise EgdcIBError.Create(Format('При сохранении триггера возникла следующая ошибка'#13#10 +
            ' %s', [E.Message]));
      end;
    finally
      ibsql.Free;
    end;
  end
  else
    Result := True;  
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_ATTR_EDITTRIGGER', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_ATTR_EDITTRIGGER', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_attr_EditTrigger.FormCreate(Sender: TObject);
begin
  inherited;
  FCheckTrigger := True;
end;

procedure Tgdc_attr_EditTrigger.actOkExecute(Sender: TObject);
begin
  if TestCorrect then
    ModalResult := mrOk;
end;

procedure Tgdc_attr_EditTrigger.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;

end;

procedure Tgdc_attr_EditTrigger.actOkUpdate(Sender: TObject);
begin
//

end;

function Tgdc_attr_EditTrigger.DlgModified: Boolean;
begin
  Result := True;
end;

procedure Tgdc_attr_EditTrigger.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
//  inherited;
  CanClose := True;
end;

initialization
  RegisterFrmClass(Tgdc_attr_EditTrigger);

finalization
  UnRegisterFrmClass(Tgdc_attr_EditTrigger);

end.
