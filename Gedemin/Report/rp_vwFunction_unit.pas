// ShlTanya, 27.02.2019, #4135

unit rp_vwFunction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBSQL, ActnList, ComCtrls, StdCtrls, ExtCtrls, IBDatabase, boScriptControl;

type
  TvwFunction = class(TForm)
    pnlRight: TPanel;
    pnlButton: TPanel;
    btnSelect: TButton;
    btnClose: TButton;
    lvFunction: TListView;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    ActionList1: TActionList;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    ibsqlFunction: TIBSQL;
    procedure btnSelectClick(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FModule: String;

    procedure ShowFunction;
    procedure CheckDatabase;
  public
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FboScriptControl: TboScriptControl;

    destructor Destroy; override;
    function SelectFunction(const AnModule: String; out Name: String; out Key: TID): Boolean;
  end;

var
  vwFunction: TvwFunction;

implementation

{$R *.DFM}

procedure TvwFunction.ShowFunction;
var
  L: TListItem;
begin
  ibsqlFunction.Close;
  CheckDatabase;
  ibsqlFunction.Params[0].AsString := FModule;
  ibsqlFunction.ExecQuery;

  lvFunction.Items.BeginUpdate;
  lvFunction.Items.Clear;
  while not ibsqlFunction.Eof do
  begin
    L := lvFunction.Items.Add;
    L.Caption := ibsqlFunction.FieldByName('name').AsString;
    L.Data := TID2Pointer(GetTID(ibsqlFunction.FieldByName('id')), Name);

    ibsqlFunction.Next;
  end;
  lvFunction.Items.EndUpdate;
end;

procedure TvwFunction.CheckDatabase;
begin
  if (FDatabase = nil) or (FTransaction = nil) then
    raise Exception.Create('Database or Transaction not assigned.');
  if not FTransaction.InTransaction then
    FTransaction.StartTransaction;
  ibsqlFunction.Database := FDatabase;
  ibsqlFunction.Transaction := FTransaction;

  boUserFunction1.boScriptControl := FboScriptControl;
end;

function TvwFunction.SelectFunction(const AnModule: String; out Name: String; out Key: TID): Boolean;
begin
  Result := False;
  Name := '';
  Key := -1;
  FModule := AnModule;
  ShowFunction;
  if ShowModal = mrOk then
  begin
    Result := True;
    Key := GetTID(lvFunction.Selected.Data, Name);
    Name := lvFunction.Selected.Caption;
  end;
end;

procedure TvwFunction.btnSelectClick(Sender: TObject);
begin
  if lvFunction.Selected = nil then
  begin
    MessageBox(Self.Handle, 'Не выбрана функция.', 'Внимание', MB_OK or MB_ICONWARNING);
    lvFunction.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

procedure TvwFunction.actAddExecute(Sender: TObject);
begin
  if boUserFunction1.AddFunction then
    ShowFunction;
end;

procedure TvwFunction.actEditExecute(Sender: TObject);
begin
  if lvFunction.Selected = nil then
    Exit;

  if boUserFunction1.FindFunctionById(GetTID(lvFunction.Selected.Data, Name)) then
    if boUserFunction1.EditCurrentFunction then
      ShowFunction;
end;

procedure TvwFunction.actDeleteExecute(Sender: TObject);
begin
  if lvFunction.Selected = nil then
    Exit;

  if boUserFunction1.FindFunctionById(GetTID(lvFunction.Selected.Data, Name)) then
    if boUserFunction1.DeleteFunction then
      ShowFunction;
end;

procedure TvwFunction.FormResize(Sender: TObject);
begin
  lvFunction.Column[0].Width := lvFunction.Width - 2;
end;

destructor TvwFunction.Destroy;
begin
  {$IFDEF ID64}
  FreeConvertContext(Name);
  {$ENDIF}
  inherited;
end;

end.
