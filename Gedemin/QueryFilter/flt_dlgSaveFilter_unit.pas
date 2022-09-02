// ShlTanya, 10.03.2019

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
    function GetUserKey: TID;
    function GetIngroup: Integer;
    function SaveFilter(const AnFilterData: TFilterData): TID;
    procedure RemoveDataSet;
    procedure SetDataSet;
  public
    function SaveWithOutName(const AnFilterData: TFilterData; const AnComponentKey: TID): TID;
    function AddFilter(const AnFilterData: TFilterData; const AnComponentKey: TID): Integer;
    function EditFilter(const FilterKey: TID): Boolean;
    function DeleteFilter(const FilterKey: tid): Boolean;
  end;

var
  dlgSaveFilter: TdlgSaveFilter;

implementation

{$R *.DFM}

procedure TdlgSaveFilter.aRightsUpdate(Sender: TObject);
begin
  aRights.Enabled := not cbFilterForMe.Checked;
end;

function TdlgSaveFilter.GetUserKey: TID;
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

function TdlgSaveFilter.SaveFilter(const AnFilterData: TFilterData): TID;
var
  BlobStream: TIBDSBlobStream;
begin
  Result := 0;
  try
    if cbFilterForMe.Checked then
      SetTID(ibdsAddFilter.FieldByName('userkey'), GetUserKey);
    BlobStream := ibdsAddFilter.CreateBlobStream(ibdsAddFilter.FieldByName('data'), bmWrite) as TIBDSBlobStream;
    try
      AnFilterData.WriteToStream(BlobStream);
    finally
      FreeAndNil(BlobStream);
    end;
    ibsqlGetID.Close;
    ibsqlGetID.ExecQuery;
    SetTID(ibdsAddFilter.FieldByName('id'), ibsqlGetID.Fields[0]);
    ibdsAddFilter.FieldByName('lastextime').AsDateTime := 0;
    ibdsAddFilter.Post;
    Result := GetTID(ibdsAddFilter.FieldByName('id'));
  except
    on E: exception do
    begin
      MessageBox(Self.Handle, @E.Message[1], 'Ошибка', MB_OK or MB_ICONERROR);
      ibdsAddFilter.Cancel;
    end;
  end
end;

function TdlgSaveFilter.SaveWithOutName(const AnFilterData: TFilterData; const AnComponentKey: TID): TID;
begin
  ibdsAddFilter.Close;
  ibdsAddFilter.Open;
  ibdsAddFilter.Insert;
  ibdsAddFilter.FieldByName('afull').AsInteger := GetIngroup;
  ibdsAddFilter.FieldByName('achag').AsInteger := GetIngroup;
  ibdsAddFilter.FieldByName('aview').AsInteger := -1;
  SetTID(ibdsAddFilter.FieldByName('componentkey'), AnComponentKey);
  ibdsAddFilter.FieldByName('name').AsString := 'Без имени';
  RemoveDataSet;
  Result := SaveFilter(AnFilterData);
  SetDataSet;
end;

function TdlgSaveFilter.AddFilter(const AnFilterData: TFilterData; const AnComponentKey: TID): TID;
begin
  Result := 0;
  ibdsAddFilter.Close;
  ibdsAddFilter.Open;
  ibdsAddFilter.Insert;
  ibdsAddFilter.FieldByName('afull').AsInteger := GetIngroup;
  ibdsAddFilter.FieldByName('achag').AsInteger := GetIngroup;
  ibdsAddFilter.FieldByName('aview').AsInteger := -1;
  SetTID(ibdsAddFilter.FieldByName('componentkey'), AnComponentKey);
  if ShowModal = mrOk then
    Result := SaveFilter(AnFilterData)
  else
    ibdsAddFilter.Cancel;
end;

function TdlgSaveFilter.EditFilter(const FilterKey: TID): Boolean;
begin
  Result := False;
  ibdsAddFilter.Close;
  SetTID(ibdsAddFilter.Params[0], FilterKey);
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
      SetTID(ibdsAddFilter.FieldByName('userkey'), GetUserKey)
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

function TdlgSaveFilter.DeleteFilter(const FilterKey: TID): Boolean;
begin
  Result := False;
  ibdsAddFilter.Close;
  SetTID(ibdsAddFilter.Params[0], FilterKey);
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
