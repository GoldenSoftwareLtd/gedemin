
{

  Як паводзіць сябе, калі ўласцівасці прысвайваецца новае значэньне?

  1. мяняць значэньне уласцівасці ў існуючуга аб'екту?
  2. ствараць новы аб'ект?


}

unit boIcon_oldf;

{DONE 3 -oAndreik: Зрабіць звязку з DataSource}
{DONE 3 -oAndreik: Адразу пасля стварэньня не абнаўляецца Image}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, DBTables, boObject, UserLogin, ExtCtrls;

type
  TboIcon = class(TboObject)
  private
    FqryIcon: TQuery;
    FtblIcon, FtblIconData: TTable;
    FdsIcon, FdsIconData: TDataSource;
    FspGetIconId: TStoredProc;
    FIcon: TPicture;
    FDataLink: TDataLink;
    OldOnDataChange: TDataChangeEvent;
    FLinkFieldName: String;
    FLinkImage: TImage;

    function GetIcon: TPicture;
    procedure SetIcon(const Value: TPicture);
    function GetObjectName: String;
    procedure SetObjectName(const Value: String);
    function GetContext: Integer;
    procedure SetContext(const Value: Integer);
    function GetKind: Integer;
    procedure SetKind(const Value: Integer);
    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    procedure DoOnDataChange(Sender: TObject; Field: TField);

  protected
    function GetID: Integer; override;
    procedure SetID(const Value: Integer); override;
    function GetActive: Boolean; override;
    procedure SetActive(const Value: Boolean); override;
    procedure SetDatabaseName(const ADatabaseName: String); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function ShowIconDlg: Boolean;
    function CreateObject: Integer; override;
    procedure DeleteObject; override;

    procedure CreatePicture(const Kind: Integer = 0; const Context: Integer = 0);
    procedure DeletePicture;

    function FindPicture(const Kind: Integer = 0; const Context: Integer = 0): Boolean;

  published
    property Icon: TPicture read GetIcon write SetIcon
      stored False;
    property ObjectName: String read GetObjectName write SetObjectName
      stored False;
    property Kind: Integer read GetKind write SetKind
      stored False;
    property Context: Integer read GetContext write SetContext
      stored False;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property LinkFieldName: String read FLinkFieldName write FLinkFieldName;
    property LinkImage: TImage read FLinkImage write FLinkImage;
  end;

procedure Register;

implementation

uses
  boIcon_dlgShowIcon;

constructor TboIcon.Create(AnOwner: TComponent);
const
  q = 'SELECT i.id as id, i.parent as parent, i.name as name, '     +
      '  d.kind as kind, d.context as context, d.width as width, '  +
      '  d.height as height, d.colordepth as colordepth, d.data as data ' +
      'FROM fin_icon i LEFT JOIN fin_icondata d ' +
      '  ON i.id = d.id ' +
      'WHERE ' +
      '  i.id = :ID AND d.kind = :KIND AND d.context = :CONTEXT';
begin
  inherited Create(AnOwner);

  FqryIcon := TQuery.Create(Self);
  FqryIcon.DatabaseName := DatabaseName;
  FqryIcon.SQL.Text := q;
  FqryIcon.ParamByName('ID').AsInteger := -1;
  FqryIcon.ParamByName('KIND').AsInteger := -1;
  FqryIcon.ParamByName('CONTEXT').AsInteger := -1;

  FtblIcon := TTable.Create(Self);
  FtblIcon.DatabaseName := DatabaseName;
  FtblIcon.TableName := 'fin_icon';
  FtblIcon.IndexFieldNames := 'id';

  FdsIcon := TDataSource.Create(Self);
  FdsIcon.DataSet := FtblIcon;

  FtblIconData := TTable.Create(Self);
  FtblIconData.DatabaseName := DatabaseName;
  FtblIconData.TableName := 'fin_icondata';
  FtblIconData.MasterSource := FdsIcon;
  FtblIconData.MasterFields := 'id';

  FdsIconData := TDataSource.Create(Self);
  FdsIconData.DataSet := FtblIconData;

  FspGetIconId := TStoredProc.Create(Self);
  FspGetIconId.DatabaseName := DatabaseName;
  FspGetIconId.StoredProcName := 'fin_p_get_icon_id';

  FIcon := TPicture.Create;

  FLinkFieldName := 'icon';
  FDataLink := TDataLink.Create;
end;

function TboIcon.CreateObject: Integer;
begin
  // адкрываем табліцы
  Active := True;

  // атрымліваем наступны ўнікальны ідэнтыфікатар
  FspGetIconId.ExecProc;

  // дадаем вобраз з пустым імем
  FtblIcon.Append;
  FtblIcon.FieldByName('id').AsInteger := FspGetIconId.ParamByName('id').AsInteger;
  FtblIcon.FieldByName('name').AsString := '';
  FtblIcon.Post;

  // дадаем пусты малюнак для створанага вобразу
  FtblIconData.Append;
  FtblIconData.FieldByName('id').AsInteger := FspGetIconId.ParamByName('id').AsInteger;
  FtblIconData.Post;

  FValidID := True;

  Result := FspGetIconId.ParamByName('id').AsInteger;

  //
  if (FDataLink.DataSet <> nil) {and
    (FDataLink.DataSet.FieldByName(FLinkFieldName).AsInteger = _ID)} then
  begin
    FDataLink.DataSet.Edit;
    FDataLink.DataSet.FieldByName(FLinkFieldName).AsInteger := Result;
    FDataLink.DataSet.Post;
  end;
end;

procedure TboIcon.CreatePicture(const Kind: Integer = 0; const Context: Integer = 0);
begin
  Assert(ValidID);

  FtblIconData.Append;
  FtblIconData.FieldByName('kind').AsInteger := Kind;
  FtblIconData.FieldByName('context').AsInteger := Context;
  FtblIconData.Post;
end;

procedure TboIcon.DeleteObject;
var
  qry: TQuery;
  _ID: Integer;
begin
  Assert(ValidID);

  _ID := ID;
  Active := False;

  if (FDataLink.DataSet <> nil) and
    (FDataLink.DataSet.FieldByName(FLinkFieldName).AsInteger = _ID) then
  begin
    FDataLink.DataSet.Edit;
    FDataLink.DataSet.FieldByName(FLinkFieldName).Clear;
    FDataLink.DataSet.Post;
  end;

  qry := TQuery.Create(Self);
  try
    qry.DatabaseName := DatabaseName;
    qry.SQL.Text := 'DELETE FROM fin_icon WHERE id = ' + IntToStr(_ID);
    qry.ExecSQL;
  finally
    qry.Free;
  end;

  if Assigned(FLinkImage) then
    FLinkImage.Picture.Assign(nil);
end;

procedure TboIcon.DeletePicture;
begin
  Assert(ValidID);
end;

destructor TboIcon.Destroy;
begin
  FIcon.Free;
  FDataLink.Free;
  inherited Destroy;
end;

procedure TboIcon.DoOnDataChange(Sender: TObject; Field: TField);
begin
  if Assigned(OldOnDataChange) then
    OldOnDataChange(Sender, Field);

  if Assigned(FLinkImage) then
    FLinkImage.Picture.Assign(Icon);

  try
    if dsBrowse = FDataLink.DataSet.State then
      ID := FDataLink.DataSet.FieldByName(FLinkFieldName).AsInteger;
  except
    //...
  end;
end;

function TboIcon.FindPicture(const Kind, Context: Integer): Boolean;
var
  Bm: TBookmark;
begin
  //Assert(ValidID);

  Result := False;

  if not ValidID then
    exit;

  Bm := FtblIconData.GetBookmark;
  try
    FtblIconData.First;
    while not FtblIconData.EOF do
    begin
      if (FtblIconData.FieldByName('kind').AsInteger = Kind) and
        (FtblIconData.FieldByName('context').AsInteger = Context) then
      begin
        Result := True;
        exit;
      end;

      FtblIconData.Next;
    end;

    FtblIconData.GotoBookmark(Bm);
  finally
    FtblIconData.FreeBookmark(Bm);
  end;
end;

function TboIcon.GetActive: Boolean;
begin
  Result := FtblIcon.Active and FtblIconData.Active;
end;

function TboIcon.GetContext: Integer;
begin
//  Assert(ValidID);

  if ValidID then
    Result := FtblIconData.FieldByName('context').AsInteger
  else
    Result := -1;
end;

function TboIcon.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TboIcon.GetIcon: TPicture;
begin
  if not ValidID then
  begin
    Result := FIcon;
    Result.Assign(nil);
  end else
  begin
    Result := FIcon;
    Result.Assign(FtblIconData.FieldByName('data'));
  end;
end;

function TboIcon.GetID: Integer;
begin
  //Assert(ValidID);

  if ValidID then
    Result := FtblIcon.FieldByName('id').AsInteger
  else
    Result := -1;
end;

function TboIcon.GetKind: Integer;
begin
  //Assert(ValidID);

  if ValidID then
    Result := FtblIconData.FieldByName('kind').AsInteger
  else
    Result := -1;
end;

function TboIcon.GetObjectName: String;
begin
  //Assert(ValidID);

  if ValidID then
    Result := FtblIcon.FieldByName('name').AsString
  else
    Result := '';
end;

procedure TboIcon.SetActive(const Value: Boolean);
begin
  if Active <> Value then
  begin
    FtblIcon.Active := Value;
    FtblIconData.Active := Value;
    FValidID := Value;
  end;
end;

procedure TboIcon.SetContext(const Value: Integer);
begin
  Assert(ValidID);

  FtblIconData.Edit;
  FtblIconData.FieldByName('context').AsInteger := Value;
  FtblIconData.Post;
end;

procedure TboIcon.SetDatabaseName(const ADatabaseName: String);
begin
  inherited SetDatabaseName(ADatabaseName);
  FtblIcon.DatabaseName := DatabaseName;
  FtblIconData.DatabaseName := DatabaseName;
end;

procedure TboIcon.SetDataSource(const Value: TDataSource);
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

procedure TboIcon.SetIcon(const Value: TPicture);
begin
  Assert(ValidID);

  FtblIconData.Edit;

  if Value <> nil then
  begin
    (FtblIconData.FieldByName('data') as TGraphicField).Assign(Value);
    FtblIconData.FieldByName('width').AsInteger := Value.Width;
    FtblIconData.FieldByName('height').AsInteger := Value.Height;
//    FtblIconData.FieldByName('colordepth').AsInteger := 0; //!!!
  end else
  begin
    (FtblIconData.FieldByName('data') as TGraphicField).Clear;
  end;

  FtblIconData.Post;
end;

procedure TboIcon.SetID(const Value: Integer);
var
  OldKind, OldContext: Integer;
begin
  {DONE 2 -oAndreik: Разабрацца з загрузкай ідэнтыфікатару}
  {DONE 4 -oAndreik: Пры змене ідэнтыфзкатару неаходна шукаць Kind & Context}

  if Value = -1 then
   exit;

  if ValidID then
  begin
    OldKind := Kind;
    OldContext := Context;
  end else
  begin
    OldKind := -1;
    OldContext := -1;
  end;

  Active := True;

  if FtblIcon.FindKey([Value]) then
  begin
    FValidID := True;
    FindPicture(OldKind, OldContext);
  end else
  begin
    FValidID := False;
    raise Exception.Create('unknown ID');
  end;
end;

procedure TboIcon.SetKind(const Value: Integer);
begin
  Assert(ValidID);

  FtblIconData.Edit;
  FtblIconData.FieldByName('kind').AsInteger := Value;
  FtblIconData.Post;

(*
  FtblIconData.First;
  while not FtblIconData.EOF do
  begin
    if FtblIconData.FieldByName('kind').AsInteger = Value then
      exit;
    FtblIconData.Next;
  end;

  FtblIconData.Append;
  FtblIconData.FieldByName('id').AsInteger := ID;
  FtblIconData.FieldByName('kind').AsInteger := Value;
  FtblIconData.FieldByName('context').AsInteger := 0;
  FtblIconData.FieldByName('width').AsInteger := 0;
  FtblIconData.FieldByName('height').AsInteger := 0;
  FtblIconData.FieldByName('colordepth').AsInteger := 0;
  FtblIconData.Post;
*)
end;

procedure TboIcon.SetObjectName(const Value: String);
begin
  Assert(ValidID);

  FtblIcon.Edit;
  FtblIcon.FieldByName('name').AsString := Value;
  FtblIcon.Post;
end;

function TboIcon.ShowIconDlg: Boolean;
begin
  Assert(ValidID);

  with TdlgShowIcon.Create(Application) do
  try
    //
    dsIcon.DataSet := FtblIcon;
    dsIconData.DataSet := FtblIconData;

    Result := ShowModal = mrOk;
  finally
    Free;
  end;

  if Result then
  begin
    if Assigned(FLinkImage) then
      FLinkImage.Picture.Assign(Icon);
  end;
end;

procedure Register;
begin
  RegisterComponents('gsBO', [TboIcon]);
end;

end.

