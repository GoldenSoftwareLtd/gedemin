unit tr_dlgAnalyze_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, ActnList, at_classes, gd_security,
  IBDatabase, dmDatabase_unit, IBSQL;

type
  TdlgAnalyze = class(TForm)
    Label1: TLabel;
    gsiblcRelation: TgsIBLookupComboBox;
    Label2: TLabel;
    edName: TEdit;
    Label3: TLabel;
    edShortName: TEdit;
    Label4: TLabel;
    edDescription: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    actNext: TAction;
    actCancel: TAction;
    Button4: TButton;
    actRight: TAction;
    IBTransaction: TIBTransaction;
    IBSQL: TIBSQL;
    procedure actOkExecute(Sender: TObject);
    procedure gsiblcRelationExit(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actNextUpdate(Sender: TObject);
  private

    FisAppend: Boolean;
    FFieldName: String;
    function Save: Boolean;

  public
    procedure SetupDialog(const aFieldName: String);
  end;

var
  dlgAnalyze: TdlgAnalyze;

implementation

{$R *.DFM}

function TdlgAnalyze.Save: Boolean;
var
  R: TatRelation;
begin
  Result := False;
  if (gsiblcRelation.CurrentKey > '') and (edName.Text > '') then
  begin
    if FIsAppend then
    begin
      R := atDatabase.Relations.ByRelationName(gsiblcRelation.CurrentKey);
      if Assigned(R) then
      begin
{        Result := atDatabase.Relations.CreateNewRelationRefs(['GD_CARDACCOUNT', 'GD_ENTRY', 'GD_ENTRYS'],
          [False, True, True], R.RelationName, edName.Text, edShortName.Text, edDescription.Text,
          -1, -1, -1);}
      end;
    end
    else
    begin
      ibsql.Prepare;
      ibsql.ParamByName('FIELDNAME').AsString := FFieldName;
      ibsql.ParamByName('LNAME').AsString := edName.Text;
      ibsql.ParamByName('LSHORTNAME').AsString := edShortName.Text;
      ibsql.ParamByName('DESCRIPTION').AsString := edDescription.Text;
      try
        ibsql.ExecQuery;
        ibsql.Close;
        Result := True;
      except
      end;
    end;  
  end;
end;

procedure TdlgAnalyze.actOkExecute(Sender: TObject);
begin
  if Save then
  begin
    IBTransaction.Commit;
    ModalResult := mrOk;
  end;  
end;

procedure TdlgAnalyze.gsiblcRelationExit(Sender: TObject);
var
  R: TatRelation;
begin
  if gsiblcRelation.CurrentKey > '' then
  begin
    R := atDatabase.Relations.ByRelationName(gsiblcRelation.CurrentKey);
    if not Assigned(R) or not Assigned(R.PrimaryKey) or (R.PrimaryKey.ConstraintFields.Count <> 1)
    then
    begin
      MessageBox(HANDLE, 'Нельзя выбрать данную таблицу в качестве объекта аналитики',
        'Внимание', mb_Ok or mb_IconQuestion);
      gsiblcRelation.SetFocus;
      abort;
    end
    else
    begin
      edName.Text := R.LName;
      edShortName.Text := R.LShortName;
      edDescription.Text := R.Description;
    end;
  end;
end;

procedure TdlgAnalyze.actNextExecute(Sender: TObject);
begin
  if Save then
    SetupDialog('');
end;

procedure TdlgAnalyze.SetupDialog(const aFieldName: String);
var
  R: TatRelationField;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  FisAppend := aFieldName = '';
  FFieldName := aFieldName;

  gsiblcRelation.Enabled := FisAppend;
  if FisAppend then
  begin
    gsiblcRelation.CurrentKey := '';
    edName.Text := '';
    edShortName.Text := '';
    edDescription.Text := '';
  end
  else
  begin
    R := atDatabase.FindRelationField('GD_CARDACCOUNT', aFieldName);
    if Assigned(R) then
    begin
      edName.Text := R.LName;
      edShortName.Text := R.LShortName;
      edDescription.Text := R.Description;
      R := atDatabase.FindRelationField('GD_ENTRY', aFieldName);
      if Assigned(R.References) then
        gsiblcRelation.CurrentKey := R.References.RelationName;
    end;
  end;
end;

procedure TdlgAnalyze.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgAnalyze.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if IBTransaction.InTransaction then
    IBTransaction.RollBack;
end;

procedure TdlgAnalyze.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := FIsAppend;
end;

end.
