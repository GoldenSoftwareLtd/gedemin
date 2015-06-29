
{

  як паводз≥ць с€бе, кал≥ Ґласц≥васц≥ прысвайваецца новае значэньне?

  1. м€н€ць значэньне уласц≥васц≥ Ґ ≥снуючуга аб'екту?
  2. ствараць новы аб'ект?

  Ў“ќ зраб≥ць:

}

unit boIcon;

{ TODO 2 -oAndreik -cпраблема : 
кал≥ адбываецца зм€неньне дадзеных ба ≥ апдэйт
адбываецца па змену зап≥су (змена id)
тады €к аднав≥ць табл≥цы €к≥€ могуць быць адчынена€
на гэты момант? }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, IBCustomDataSet, IBTable, IBQuery, IBStoredProc, boObject, ExtCtrls;

{TODO 3 -oAndreik: «начэньн≥ па Ґмалчаньню пав≥нны быць узгоднены
  тройчы: у б≥знэс-аб'екце, у тэксце SQL, у дакумэнтацы≥}
const
  DefIconName       = '';
  DefIconKind       = 0;
  DefIconContext    = 0;
  DefIconWidth      = 0;
  DefIconHeight     = 0;
  DefIconColorDepth = 4;

type
  TboIcon = class(TboObject)
  private
    function GetContext: Integer;
    procedure SetContext(const Value: Integer);
    function GetKind: Integer;
    procedure SetKind(const Value: Integer);
 
  protected
    function GetID: Integer; override;
    procedure SetID(const Value: Integer); override;
    function GetDataSet: TDataSet; override;
    function GetQueryText: String; override;
    function GetNextIDProcName: String; override;
    procedure InitBOData; override;
    procedure InitBOKeys; override;
    function CreateDeleteProc: TIBStoredProc; override;
    function DoModify: TIBUpdateAction; override;
    function DoInsert: TIBUpdateAction; override;
    function DoDelete: TIBUpdateAction; override;

  public
    constructor Create(AnOwner: TComponent); override;

    function ShowIconDlg: Boolean;

  published
    property Kind: Integer read GetKind write SetKind;
    property Context: Integer read GetContext write SetContext;
  end;

procedure Register;

implementation

uses
  boIcon_dlgShowIcon;

procedure InitParam(P: TParam; F: TField; const DefValue: Integer = 0);
begin
  if F.IsNull then
    P.AsInteger := DefValue
  else
    P.Assign(F);
end;

constructor TboIcon.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FIBQuery.OnUpdateRecord := DoOnUpdateRecord;
end;

function TboIcon.GetContext: Integer;
begin
  Result := FKeys.ParamByName('context').AsInteger;
end;

function TboIcon.GetID: Integer;
begin
  Result := FKeys.ParamByName('id').AsInteger;
end;

function TboIcon.GetKind: Integer;
begin
  Result := FKeys.ParamByName('kind').AsInteger;
end;

procedure TboIcon.SetContext(const Value: Integer);
begin
  if FKeys.ParamByName('context').AsInteger <> Value then
  begin
    ApplyUpdates;

    FIBQuery.Close;
    FKeys.ParamByName('context').AsInteger := Value;
    FIBQuery.ParamByName('context').AsInteger := Value;
    FIBQuery.Open;
  end;
end;

procedure TboIcon.SetID(const Value: Integer);
begin
  if (IBDatabase = nil) or (IBTransaction = nil) then
    exit;

  if Active and (FKeys.ParamByName('id').AsInteger = Value) then
    exit;

  ApplyUpdates;

  FKeys.ParamByName('id').AsInteger := Value;

  FIBQuery.Close;
  FIBQuery.ParamByName('id').AsInteger := FKeys.ParamByName('id').AsInteger;
  FIBQuery.Open;

  if FIBQuery.EOF then
  begin
    FIBQuery.Close;
    FKeys.ParamByName('kind').AsInteger := DefIconKind;
    FKeys.ParamByName('context').AsInteger := DefIconContext;
    FIBQuery.ParamByName('kind').AsInteger := DefIconKind;
    FIBQuery.ParamByName('context').AsInteger := DefIconContext;
    FIBQuery.Open;
  end;
end;

procedure TboIcon.SetKind(const Value: Integer);
begin
  if FKeys.ParamByName('kind').AsInteger <> Value then
  begin
    //
    ApplyUpdates;

    FIBQuery.Close;
    FKeys.ParamByName('kind').AsInteger := Value;
    FIBQuery.ParamByName('kind').AsInteger := Value;
    FIBQuery.Open;
  end;
end;

{TODO 3 -oAndreik: ’то пав≥нен адказваць за посц≥нг дадзеных
ды€лог, ц≥ выклiкаючы €го код?}
function TboIcon.ShowIconDlg: Boolean;
begin
  Assert(ValidID);

  with TdlgShowIcon.Create(Application) do
  try
    dsIcon.DataSet := FIBQuery;
    Result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

function TboIcon.GetDataSet: TDataSet;
begin
  Result := FIBQuery;
end;

function TboIcon.GetQueryText: String;
begin
  Result :=
      'SELECT i.id as id, i.parent as parent, i.name as name,           ' +
      '  d.kind as kind, d.context as context, d.width as width,        ' +
      '  d.height as height, d.colordepth as colordepth, d.data as data ' +
      'FROM fin_icon i JOIN fin_icondata d                              ' +
      '  ON i.id = d.id                                                 ' +
      'WHERE                                                            ' +
      '  i.id = :ID AND d.kind = :KIND AND d.context = :CONTEXT         ';
end;

function TboIcon.GetNextIDProcName: String;
begin
  Result := 'fin_p_get_icon_id';
end;

procedure TboIcon.InitBOData;
begin
  FIBQuery.FieldByName('id').AsInteger := FKeys.ParamByName('id').AsInteger;
  FIBQuery.FieldByName('name').AsString := DefIconName;
  FIBQuery.FieldByName('kind').AsInteger := FKeys.ParamByName('kind').AsInteger;
  FIBQuery.FieldByName('context').AsInteger := FKeys.ParamByName('context').AsInteger;
  FIBQuery.FieldByName('width').AsInteger := DefIconWidth;
  FIBQuery.FieldByName('height').AsInteger := DefIconHeight;
  FIBQuery.FieldByName('colordepth').AsInteger := DefIconColorDepth;
end;

procedure TboIcon.InitBOKeys;
begin
  with FKeys.Add as TParam do
  begin
    Name := 'id';
    DataType := ftInteger;
    AsInteger := -1;
  end;

  with FKeys.Add as TParam do
  begin
    Name := 'kind';
    DataType := ftInteger;
    AsInteger := DefIconKind;
  end;

  with FKeys.Add as TParam do
  begin
    Name := 'context';
    DataType := ftInteger;
    AsInteger := DefIconContext;
  end;
end;

function TboIcon.CreateDeleteProc: TIBStoredProc;
begin
  Result := TIBStoredProc.Create(Self);
  Result.Database := IBDatabase;
  Result.StoredProcName := 'fin_p_icon_delete';
end;

procedure Register;
begin
  RegisterComponents('gsBO', [TboIcon]);
end;

function TboIcon.DoDelete: TIBUpdateAction;
begin
  Assert(false);
end;

function TboIcon.DoInsert: TIBUpdateAction;
var
  q: TIBQuery;
begin
  if FIBQuery.FieldByName('id').IsNull then
  begin
    FspGetNextID.ExecProc;
    FKeys.ParamByName('id').AsInteger := FspGetNextID.ParamByName('id').AsInteger;
    FIBQuery.Edit;
    FIBQuery.FieldByName('id').AsInteger := FKeys.ParamByName('id').AsInteger;
    FIBQuery.Post;
  end;

  if FIBQuery.FieldByName('name').IsNull then
  begin
    FIBQuery.Edit;
    FIBQuery.FieldByName('name').AsString := '';
    FIBQuery.Post;
  end;

  q := TIBQuery.Create(Self);
  try
    q.Database := IBDatabase;

    q.SQL.Text := Format('SELECT COUNT(*) FROM fin_icon WHERE id = %d',
      [FKeys.ParamByName('id').AsInteger]);
    q.Open;
    if q.Fields[0].AsInteger = 0 then
    begin
      q.SQL.Text := Format('INSERT INTO fin_icon (id, parent, name) ' +
        'VALUES (%d, :PARENT, "%s")', [FKeys.ParamByName('id').AsInteger,
        FIBQuery.FieldByName('name').AsString]);
      q.Prepare;
      q.ParamByName('parent').Assign(FIBQuery.FieldByName('parent'));
      q.ExecSQL;
    end;

    q.SQL.Text := Format('INSERT INTO fin_icondata (id, kind, context, width, height, colordepth, data) ' +
      'VALUES (%d, :KIND, :CONTEXT, :WIDTH, :HEIGHT, :COLORDEPTH, :DATA)',
      [FKeys.ParamByName('id').AsInteger]);
    q.Prepare;
    InitParam(q.ParamByName('kind'), FIBQuery.FieldByName('kind'));
    InitParam(q.ParamByName('context'), FIBQuery.FieldByName('context'));
    InitParam(q.ParamByName('width'), FIBQuery.FieldByName('width'));
    InitParam(q.ParamByName('height'), FIBQuery.FieldByName('height'));
    InitParam(q.ParamByName('colordepth'), FIBQuery.FieldByName('colordepth'), 4);
    q.ParamByName('data').Assign(FIBQuery.FieldByName('data'));
    q.ExecSQL;
  finally
    q.Free;
  end;

  Result := uaApplied;
end;

function TboIcon.DoModify: TIBUpdateAction;
var
  q: TIBQuery;
begin
  if FKeys.ParamByName('id').AsInteger <> FIBQuery.FieldByName('id').AsInteger then
    raise Exception.Create('aaa');

  if (FIBQuery.FieldByName('id').AsInteger = FKeys.ParamByName('id').AsInteger) and
    (FIBQuery.FieldByName('kind').AsInteger = FKeys.ParamByName('kind').AsInteger) and
    (FIBQuery.FieldByName('context').AsInteger = FKeys.ParamByName('context').AsInteger) then
  begin
    q := TIBQuery.Create(Self);
    try
      q.Database := IBDatabase;
      q.SQL.Text := Format('UPDATE fin_icon SET parent = :PARENT, name = "%s" WHERE id = %d',
        [FIBQuery.FieldByName('name').AsString, FKeys.ParamByName('id').AsInteger]);
      q.Prepare;
      q.ParamByName('Parent').Assign(FIBQuery.FieldByName('parent'));
      q.ExecSQL;

      q.SQL.Text := Format('UPDATE fin_icondata SET width = %d, height = %d, colordepth = %d, data = :DATA ' +
                           '   WHERE id = %d AND kind = %d AND context = %d',
        [FIBQuery.FieldByName('width').AsInteger, FIBQuery.FieldByName('height').AsInteger,
         FIBQuery.FieldByName('colordepth').AsInteger,
         FKeys.ParamByName('id').AsInteger,
         FKeys.ParamByName('kind').AsInteger,
         FKeys.ParamByName('context').AsInteger]);
      q.Prepare;
      q.ParamByName('data').Assign(FIBQuery.FieldByName('data'));
      q.ExecSQL;
    finally
      q.Free;
    end;
  end else
  begin
    q := TIBQuery.Create(Self);
    try
      q.Database := IBDatabase;
      q.SQL.Text := Format('UPDATE fin_icon SET parent = :PARENT, name = "%s" WHERE id = %d',
        [FIBQuery.FieldByName('name').AsString, FKeys.ParamByName('id').AsInteger]);
      q.ParamByName('parent').Assign(FIBQuery.FieldByName('parent'));
      q.ExecSQL;

      q.SQL.Text := Format('UPDATE fin_icondata SET kind = %d, context = %d, width = %d, height = %d, colordepth = %d, data = :DATA ' +
                           '   WHERE id = %d AND kind = %d AND context = %d',
        [FIBQuery.FieldByName('kind').AsInteger, FIBQuery.FieldByName('context').AsInteger,
         FIBQuery.FieldByName('width').AsInteger, FIBQuery.FieldByName('height').AsInteger,
         FIBQuery.FieldByName('colordepth').AsInteger,
         FKeys.ParamByName('id').AsInteger,
         FKeys.ParamByName('kind').AsInteger,
         FKeys.ParamByName('context').AsInteger]);
      q.ParamByName('data').Assign(FIBQuery.FieldByName('data'));
      q.ExecSQL;
    finally
      q.Free;
    end;
  end;

  Result := uaApplied;
end;


end.

