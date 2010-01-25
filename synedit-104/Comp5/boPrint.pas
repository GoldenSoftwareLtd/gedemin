
unit boPrint;

interface

uses
  Classes, SysUtils, DB, DBTables, boObject, boIcon;

const
  DefPrintName = '';

type
  TboPrint = class(TboObject)
  private
    FspGetPrintId: TStoredProc;
    FqryPrint: TQuery;
    FID: Integer;

    procedure DoOnUpdateRecord(DataSet: TDataSet; UpdateKind: TUpdateKind;
      var UpdateAction: TUpdateAction);

  protected
    function GetID: Integer; override;
    procedure SetID(const Value: Integer); override;
    function GetActive: Boolean; override;
    procedure SetActive(const Value: Boolean); override;
    function GetDataSet: TDataSet; override;

  public
    constructor Create(AnOwner: TComponent); override;

    function ShowPrintDlg: Boolean;
    procedure CreateObject(const AnID: Integer = - 1); override;
    procedure DeleteObject; override;

  published
  end;

procedure Register;

implementation

uses
  boPrint_ShowPrintDlg;

{ TboPrint }

constructor TboPrint.Create(AnOwner: TComponent);
const
  q = 'SELECT p.id AS ID, p.name AS NAME, ' +
      '  p.customerkey AS CUSTOMERKEY, c.name AS CUSTOMERNAME, ' +
      '  p.logokey AS LOGOKEY ' +
      'FROM ' +
      '  rdz_print p LEFT JOIN cst_customer c ON p.customerkey = c.customerkey ' +
      'WHERE ' +
      '  p.id = :ID';
begin
  inherited;

  FID := -1;

  FqryPrint := TQuery.Create(Self);
  FqryPrint.Databasename := Databasename;
  FqryPrint.CachedUpdates := True;
  FqryPrint.RequestLive := True;
  FqryPrint.UniDirectional := True;
  FqryPrint.SQL.Text := q;
  FqryPrint.ParamByName('id').AsInteger := FID;
  FqryPrint.OnUpdateRecord := DoOnUpdateRecord;

  FspGetPrintID := TStoredProc.Create(Self);
  FspGetPrintID.DatabaseName := DatabaseName;
  FspGetPrintID.StoredProcName := 'rdz_p_getprintid';
end;

procedure TboPrint.CreateObject(const AnID: Integer);
begin
  //
  ApplyUpdates;

  // адкрываем табліцы
  Active := True;

  if AnID = -1 then
  begin
    FspGetPrintID.ExecProc;
    FID := FspGetPrintId.ParamByName('id').AsInteger;
  end else
    FID := AnID;

  FqryPrint.Append;
  FqryPrint.FieldByName('id').AsInteger := FID;
  FqryPrint.FieldByName('name').AsString := DefPrintName;
end;

procedure TboPrint.DeleteObject;
var
  sp: TStoredProc;
begin
  Assert(ValidID);

  if FqryPrint.State in [dsInsert] then
  begin
    FqryPrint.Cancel;
    FqryPrint.CancelUpdates;
  end else
  begin
    if FqryPrint.State in [dsEdit] then
      FqryPrint.Cancel;

    // УВАГА!!! гэта будзе працаваць толькi тады, калі гарантавана
    // што id нельга рэдактаваць!!!
    FqryPrint.CancelUpdates;

    Active := False;

    sp := TStoredProc.Create(Self);
    try
      sp.DatabaseName := DatabaseName;
      sp.StoredProcName := 'rdz_p_deleteprint';
      sp.Prepare;
      sp.ParamByName('id').AsInteger := FID;
      sp.ExecProc;
    finally
      sp.Free;
    end;

    Active := True; // неабходна адчыніць, бо неабходна
                    // каб вызваўся івэнт звязанага дата соурса
  end;
end;

procedure TboPrint.DoOnUpdateRecord(DataSet: TDataSet;
  UpdateKind: TUpdateKind; var UpdateAction: TUpdateAction);

  procedure DoModify;
  var
    q: TQuery;
  begin
    q := TQuery.Create(Self);
    try
      q.DatabaseName := DatabaseName;
      q.SQL.Text := Format('UPDATE rdz_print SET name = "%s", logokey = :LOGOKEY WHERE id = %d',
        [FqryPrint.FieldByName('name').AsString, FID]);
      q.ParamByName('LOGOKEY').Assign(FqryPrint.FieldByName('logokey'));
      q.ExecSQL;
    finally
      q.Free;
    end;
  end;

  procedure DoInsert;
  var
    q: TQuery;
  begin
    q := TQuery.Create(Self);
    try
      q.DatabaseName := DatabaseName;
      q.SQL.Text := Format('INSERT INTO rdz_print (id, name, customerkey, logokey) ' +
        'VALUES(%d, "%s", :CUSTOMERKEY, :LOGOKEY)',
        [FID, FqryPrint.FieldByName('name').AsString]);
      q.Prepare;
      q.ParamByName('CUSTOMERKEY').Assign(FqryPrint.FieldByName('customerkey'));
      q.ParamByName('LOGOKEY').Assign(FqryPrint.FieldByName('logokey'));
      q.ExecSQL;
    finally
      q.Free;
    end;
  end;

  procedure DoDelete;
  begin
    //
  end;

begin
  case UpdateKind of
    ukModify: begin DoModify; UpdateAction := uaApplied; end;
    ukInsert: begin DoInsert; UpdateAction := uaApplied; end;
    ukDelete: begin DoDelete; UpdateAction := uaApplied; end;
  end;
end;

function TboPrint.GetActive: Boolean;
begin
  Result := FqryPrint.Active;
end;

function TboPrint.GetDataSet: TDataSet;
begin
  Result := FqryPrint;
end;

function TboPrint.GetID: Integer;
begin
  if ValidID then
    Result := FqryPrint.FieldByName('id').AsInteger
  else
    Result := -1;
end;

{TODO 2 -oAndreik: Неабходна вырашыць на якой стадыі існуе ID }
procedure TboPrint.SetActive(const Value: Boolean);
begin
  if Value <> Active then
  begin
    FqryPrint.Active := Value;
    if ValidID then
      FID := FqryPrint.FieldByName('id').AsInteger;
  end;
end;

procedure TboPrint.SetID(const Value: Integer);
begin
  FID := Value;
  FqryPrint.Close;
  FqryPrint.ParamByName('id').AsInteger := FID;
  FqryPrint.Open;
end;

function TboPrint.ShowPrintDlg: Boolean;
begin
  with TdlgShowPrint.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsBO', [TboPrint]);
end;

end.

