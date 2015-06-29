
{

  П: Якія мэты мы праследуем ствараючы бізнэс аб'екты?
  А: Галоўныя мэты гэта:

     1. Сістэматызацыя і акрэсленьне адзінага падыходу да
        стварэньня праграмных кампанэнтаў.

     2. Магчымасць паўторнага выкарыстаньня коду і структуры
        базы дадзеных.

     3. Магчымасць перадачы часткі коду да трэціх распрацоўшчыкаў.

     4. Магчымасць выкарыстоўваньня коду, створанага трэцімі распрацоўшчыкамі.

  П: У якой ступені БА з'яўляюцца закончанай тэхналёгіяй?
  А: На дадзеным этапе развіцця БА -- гэта ў большай ступені збор метадалягічных
     падыходаў чым пэўна акрэсленная тэхналёгія.


  Базавы клас Business Object

  TboObject

  Уласцівасці:

    Active      -- азначае, што кампанэнт падключаны да базы дадзеных
    ID          -- унікальны ідэнтыфікатар аб'екта
    Valid       -- азначае, што аб'ект ініцыялізаваны


  If Active == 1 then ID == ?; Valid == ?;
  If Active == 0 then ID == ?; Valid == 0;
  If Valid  == 1 then Active == 1; ID == ?;
  If Valid  == 0 then Active == ?; ID == ?;

  1.01    17-08-99    andreik    Registration removed.
}

unit boObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, IBDatabase, IBQuery, IBStoredProc, IBCustomDataSet;

type
  TboObject = class(TComponent)
  private
    FIBDataBase: TIBDatabase;
    FIBTransaction: TIBTransaction;
    FLinkFieldName: String;
    FUpdateMasterSource: Boolean;
    OldOnDataChange: TDataChangeEvent;

    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    procedure DoOnDataChange(Sender: TObject; Field: TField);
    function GetValidID: Boolean;
    procedure SetValidID(const Value: Boolean);

  protected
    FDataLink: TDataLink;
    FIBQuery: TIBQuery;
    FspGetNextID: TIBStoredProc;
    FKeys: TParams;

    procedure Loaded; override;

    function GetID: Integer; virtual; abstract;
    procedure SetID(const Value: Integer); virtual; abstract;

    function GetActive: Boolean; virtual;
    procedure SetActive(const Value: Boolean); virtual;

    procedure SetIBDatabase(AnIBDatabase: TIBDatabase); virtual;
    procedure SetIBTransaction(AnIBTransaction: TIBTransaction); virtual;

    function GetDataSet: TDataSet; virtual; abstract;
    function GetQueryText: String; virtual; abstract;
    function GetNextIDProcName: String; virtual; abstract;
    procedure InitBOData; virtual; abstract;
    procedure InitBOKeys; virtual; abstract;
    function CreateDeleteProc: TIBStoredProc; virtual; abstract;

    procedure DoOnUpdateRecord(DataSet: TDataSet; UpdateKind: TUpdateKind;
      var UpdateAction: TIBUpdateAction); virtual;

    function DoModify: TIBUpdateAction; virtual; abstract;
    function DoInsert: TIBUpdateAction; virtual; abstract;
    function DoDelete: TIBUpdateAction; virtual; abstract;

    procedure SyncKeys; virtual;

    property DataSet: TDataSet read GetDataSet;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    //
    procedure CreateObject(const AnID: Integer = -1); virtual;
    procedure DeleteObject; virtual;

    procedure ApplyUpdates; virtual;
    procedure CancelUpdates; virtual;

  published
    property Active: Boolean read GetActive write SetActive
      default False;
    property IBDataBase: TIBDatabase read FIBDataBase write SetIBDataBase;
    property IBTransaction: TIBTransaction read FIBTransaction write SetIBTransaction;
    property ID: Integer read GetID write SetID;
    property ValidID: Boolean read GetValidID write SetValidID
      default False;
    property Datasource: TDatasource read GetDataSource write SetDataSource;
    property LinkFieldName: String read FLinkFieldName write FLinkFieldName;
    property UpdateMasterSource: Boolean read FUpdateMasterSource write FUpdateMasterSource
      default False;
  end;

  TboDataSource = class(TDataSource)
  private
    FboObject: TboObject;
    procedure SetboObject(const Value: TboObject);

  published
    property boObject: TboObject read FboObject write SetboObject;
  end;

procedure Register;

implementation

procedure TboObject.ApplyUpdates;
begin
  if Active then
  begin
    if FIBQuery.State in [dsEdit, dsInsert] then
      FIBQuery.Post;

    if FIBQuery.UpdatesPending then
      FIBQuery.ApplyUpdates;

    SyncKeys;
  end;
end;

procedure TboObject.CancelUpdates;
begin
  if Active then
  begin
    if FIBQuery.State in [dsInsert, dsEdit] then
      FIBQuery.Cancel;

    if FIBQuery.UpdatesPending then
      FIBQuery.CancelUpdates;

    SyncKeys;
  end;
end;

constructor TboObject.Create(AnOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AnOwner);

  FKeys := TParams.Create(Self);
  InitBOKeys;

  FIBDataBase := nil;
  FIBTransaction := nil;
//  FValidID := False;
  FLinkFieldName := '';
  FDataLink := TDataLink.Create;
  FUpdateMasterSource := False;

  FIBQuery := TIBQuery.Create(Self);
  FIBQuery.Transaction := FIBTransaction;
  FIBQuery.CachedUpdates := True;
  FIBQuery.UniDirectional := True;
  FIBQuery.SQL.Text := GetQueryText;

  FspGetNextId := TIBStoredProc.Create(Self);
  FspGetNextId.Transaction := FIBTransaction;
  FspGetNextId.StoredProcName := GetNextIDProcName;

  for I := 0 to FKeys.Count - 1 do
    FIBQuery.ParamByName(FKeys.Items[I].Name).Assign(FKeys.Items[I]);
end;

procedure TboObject.CreateObject(const AnID: Integer = -1);
begin
  //
  ApplyUpdates;

  // адкрываем табліцы
  Active := True;

  if AnID = -1 then
  begin
    FspGetNextID.ExecProc;
    FKeys.ParamByName('id').AsInteger := FspGetNextId.ParamByName('id').AsInteger;
  end else
    FKeys.ParamByName('id').AsInteger := AnID;

  FIBQuery.Append;
  InitBOData;

  if UpdateMasterSource and (FDataLink.DataSet <> nil) then
  begin
    FDataLink.DataSet.Edit;
    FDataLink.DataSet.FieldByName(LinkFieldName).AsInteger := FKeys.ParamByName('id').AsInteger;
    FDataLink.DataSet.Post;
  end;
end;

procedure TboObject.DeleteObject;
var
  sp: TIBStoredProc;
  I: Integer;
begin
  Assert(ValidID);

  if UpdateMasterSource and (FDataLink.DataSet <> nil) and
    (FDataLink.DataSet.FieldByName(LinkFieldName).AsInteger = FKeys.ParamByName('id').AsInteger) then
  begin
    FDataLink.DataSet.Edit;
    FDataLink.DataSet.FieldByName(LinkFieldName).Clear;
    FDataLink.DataSet.Post;
  end;

  if FIBQuery.State in [dsInsert] then
  begin
    FIBQuery.Cancel;
    FIBQuery.CancelUpdates;
  end else
  begin
    if FIBQuery.State in [dsEdit] then
      FIBQuery.Cancel;

    // УВАГА!!! гэта будзе працаваць толькi тады, калі гарантавана
    // што id нельга рэдактаваць!!!
    FIBQuery.CancelUpdates;

    Active := False;

    sp := CreateDeleteProc;
    try
      sp.Prepare;
      for I := 0 to FKeys.Count - 1 do
        sp.ParamByName(FKeys.Items[I].Name).Assign(FKeys.Items[I]);
      sp.ExecProc;
    finally
      sp.Free;
    end;

    Active := True; // неабходна адчыніць, бо неабходна
                    // каб вызваўся івэнт звязанага дата соурса
  end;
end;

destructor TboObject.Destroy;
begin
  ApplyUpdates;
  FDataLink.Free;
  inherited Destroy;
end;

procedure TboObject.DoOnDataChange(Sender: TObject; Field: TField);
begin
  if Assigned(OldOnDataChange) then
    OldOnDataChange(Sender, Field);

  if dsBrowse = FDataLink.DataSet.State then
  begin
    if FDataLink.DataSet.FieldByName(FLinkFieldName).IsNull then
      Active := False
    else
      ID := FDataLink.DataSet.FieldByName(FLinkFieldName).AsInteger;
  end;
end;

procedure TboObject.DoOnUpdateRecord(DataSet: TDataSet;
  UpdateKind: TUpdateKind; var UpdateAction: TIBUpdateAction);
begin
  case UpdateKind of
    ukModify: UpdateAction := DoModify;
    ukInsert: UpdateAction := DoInsert;
    ukDelete: UpdateAction := DoDelete;
  end;
end;

function TboObject.GetActive: Boolean;
begin
  Result := FIBQuery.Active;
end;

function TboObject.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TboObject.GetValidID: Boolean;
begin
  Result := FIBQuery.Active and (FIBQuery.RecNo <> 0);
end;

procedure TboObject.Loaded;
begin
  inherited;

  FIBQuery.Transaction := FIBTransaction;
  FspGetNextID.Transaction := FIBTransaction;
end;

procedure TboObject.SetActive(const Value: Boolean);
begin
  if Active <> Value then
  begin
    FIBQuery.Active := Value;
  end;
end;

procedure TboObject.SetDataSource(const Value: TDataSource);
begin
  if FDataLink.DataSource <> nil then
  begin
    FDataLink.DataSource.OnDataChange := OldOnDataChange;
    OldOnDataChange := nil;
  end;

  FDataLink.DataSource := Value;

  if Value <> nil then
  begin
    OldOnDataChange := Value.OnDataChange;
    Value.OnDataChange := DoOnDataChange;
  end;
end;

{ TboDataSource }

procedure TboDataSource.SetboObject(const Value: TboObject);
begin
  FboObject := Value;
  if Assigned(FboObject) then
    DataSet := FboObject.DataSet
  else
    DataSet := nil;
end;

procedure Register;
begin
  RegisterComponents('gsBO', [TboDataSource]);
end;

procedure TboObject.SetIBDatabase(AnIBDatabase: TIBDatabase);
begin
  Active := False;
  FIBDatabase := AnIBDatabase;
  FIBQuery.Database := FIBDatabase;
  FIBTransaction := FIBQuery.Transaction;
end;

procedure TboObject.SetIBTransaction(AnIBTransaction: TIBTransaction);
begin
  Active := False;
  FIBTransaction := AnIBTransaction;
  FIBQuery.Transaction := FIBTransaction;
  FIBDatabase := FIBQuery.Database;
end;

procedure TboObject.SetValidID(const Value: Boolean);
begin
  //dummy
end;

procedure TboObject.SyncKeys;
var
  I: Integer;
begin
  if ValidID then
    for I := 0 to FKeys.Count - 1 do
      FKeys.Items[I].Assign(FIBQuery.FieldByName(FKeys.Items[I].Name));
end;

end.

