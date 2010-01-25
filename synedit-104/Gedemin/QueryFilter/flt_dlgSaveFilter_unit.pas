unit flt_dlgSaveFilter_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gd_security, ActnList, Db, IBCustomDataSet, Mask, DBCtrls,
  flt_sqlfilter_condition_type, IBSQL;

type
  TdlgSaveFilter = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    btnAccess: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    ActionList1: TActionList;
    aRights: TAction;
    ibdsAddFilter: TIBDataSet;
    dsFilter: TDataSource;
    dbeName: TDBEdit;
    dbeDescription: TDBEdit;
    cbFilterForMe: TCheckBox;
    ibsqlGetID: TIBSQL;
    procedure aRightsUpdate(Sender: TObject);
  private
    function GetUserKey: Integer;
    function GetIngroup: Integer;
    function SaveFilter(const AnFilterData: TFilterData): Integer;
    procedure RemoveDataSet;
    procedure SetDataSet;
  public
    function SaveWithOutName(const AnFilterData: TFilterData; const AnComponentKey: Integer): Integer;
    function AddFilter(const AnFilterData: TFilterData; const AnComponentKey: Integer): Integer;
    function EditFilter(const FilterKey: Integer): Boolean;
    function DeleteFilter(const FilterKey: Integer): Boolean;
  end;

var
  dlgSaveFilter: TdlgSaveFilter;

implementation

{$R *.DFM}

procedure TdlgSaveFilter.aRightsUpdate(Sender: TObject);
begin
  aRights.Enabled := not cbFilterForMe.Checked;
end;

function TdlgSaveFilter.GetUserKey: Integer;
begin
  if IBLogin <> nil then
    Result := IBLogin.UserKey
  else
    Result := -1;
end;

function TdlgSaveFilter.GetIngroup: Integer;
begin
  if IBLogin <> nil then
    Result := IBLogin.Ingroup
  else
    Result := -1;
end;

procedure TdlgSaveFilter.RemoveDataSet;
begin
  dbeName.DataSource := nil;
  dbeDescription.DataSource := nil;
end;

procedure TdlgSaveFilter.SetDataSet;
begin
  dbeName.DataSource := dsFilter;
  dbeDescription.DataSource := dsFilter;
end;

function TdlgSaveFilter.SaveFilter(const AnFilterData: TFilterData): Integer;
var
  BlobStream: TIBDSBlobStream;
begin
  Result := 0;
  try
    if cbFilterForMe.Checked then
      ibdsAddFilter.FieldByName('userkey').AsInteger := GetUserKey;
    BlobStream := ibdsAddFilter.CreateBlobStream(ibdsAddFilter.FieldByName('data'), bmWrite) as TIBDSBlobStream;
    try
      AnFilterData.WriteToStream(BlobStream);
    finally
      FreeAndNil(BlobStream);
    end;
    ibsqlGetID.Close;
    ibsqlGetID.ExecQuery;
    ibdsAddFilter.FieldByName('id').AsInteger := ibsqlGetID.Fields[0].AsInteger;
    ibdsAddFilter.FieldByName('lastextime').AsDateTime := 0;
    ibdsAddFilter.Post;
    Result := ibdsAddFilter.FieldByName('id').AsInteger;
  except
    on E: exception do
    begin
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
      ibdsAddFilter.Cancel;
    end;
  end
end;

function TdlgSaveFilter.SaveWithOutName(const AnFilterData: TFilterData; const AnComponentKey: Integer): Integer;
begin
  ibdsAddFilter.Close;
  ibdsAddFilter.Open;
  ibdsAddFilter.Insert;
  ibdsAddFilter.FieldByName('afull').AsInteger := GetIngroup;
  ibdsAddFilter.FieldByName('achag').AsInteger := GetIngroup;
  ibdsAddFilter.FieldByName('aview').AsInteger := -1;
  ibdsAddFilter.FieldByName('componentkey').AsInteger := AnComponentKey;
  ibdsAddFilter.FieldByName('name').AsString := 'Без имени';
  RemoveDataSet;
  Result := SaveFilter(AnFilterData);
  SetDataSet;
end;

function TdlgSaveFilter.AddFilter(const AnFilterData: TFilterData; const AnComponentKey: Integer): Integer;
begin
  Result := 0;
  ibdsAddFilter.Close;
  ibdsAddFilter.Open;
  ibdsAddFilter.Insert;
  ibdsAddFilter.FieldByName('afull').AsInteger := GetIngroup;
  ibdsAddFilter.FieldByName('achag').AsInteger := GetIngroup;
  ibdsAddFilter.FieldByName('aview').AsInteger := -1;
  ibdsAddFilter.FieldByName('componentkey').AsInteger := AnComponentKey;
  if ShowModal = mrOk then
    Result := SaveFilter(AnFilterData)
  else
    ibdsAddFilter.Cancel;
end;

function TdlgSaveFilter.EditFilter(const FilterKey: Integer): Boolean;
begin
  Result := False;
  ibdsAddFilter.Close;
  ibdsAddFilter.Params[0].AsInteger := FilterKey;
  ibdsAddFilter.Open;
  if ibdsAddFilter.Eof then
  begin
    MessageBox(Self.Handle, 'Фильтр не найден', 'Внимание', MB_OK or MB_ICONERROR);
    Result := True;
  end;
  ibdsAddFilter.Edit;
  cbFilterForMe.Checked := not ibdsAddFilter.FieldByName('userkey').IsNull;
  if ShowModal = mrOk then
  try
    if cbFilterForMe.Checked then
      ibdsAddFilter.FieldByName('userkey').AsInteger := GetUserKey
    else
      ibdsAddFilter.FieldByName('userkey').AsVariant := null;
    ibdsAddFilter.Post;
    Result := True;
  except
    on E: exception do
    begin
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
      ibdsAddFilter.Cancel;
    end;
  end else
    ibdsAddFilter.Cancel;
end;

function TdlgSaveFilter.DeleteFilter(const FilterKey: Integer): Boolean;
begin
  Result := False;
  ibdsAddFilter.Close;
  ibdsAddFilter.Params[0].AsInteger := FilterKey;
  ibdsAddFilter.Open;
  if ibdsAddFilter.Eof then
  begin
    MessageBox(Self.Handle, 'Фильтр не найден', 'Внимание', MB_OK or MB_ICONERROR);
    Result := True;
  end;
  try
    ibdsAddFilter.Delete;
    Result := True;
  except
    on E: exception do
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
  end;
end;

end.
