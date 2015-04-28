
{++

  Copyright (c) 2000-2001 by Golden Software of Belarus

  Module

  Abstract

  Author

    Andrei Kireev

  Contact address

    a_kireev@yahoo.com
    andreik@gsbelarus.com

  Revisions history

    1.00    15-sep-00    andreik    Initial version.
    1.01    14-mar-01    andreik    Minor changes.
    1.02    14-dec-01    michael    ��������� ����������� ���������� � desktop
                                    ���� � ������� ������� � ��� �����  
--}

unit gsDesktopManager;

{ TODO : � ������� ���� screenres ������� NOT NULL }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, StdCtrls, Contnrs, gsStorage, gdcBase;

(*
 * ���������:
 *   ������� -- ���������� �������� ��'���� (�����).
 *
 *   ������ ���������� � ����� �������� �/� �����(�) �� ������ ��������
 *     ReadFromStream, WriteToStream
 *   ������ ���������� � ������������� ������������ ��'���� �� ������ ��������
 *     SaveDesktopItem, LoadDesktopItem
 *
 * �� ���� ������:
 *   �� �������� ����������� ��������� ��'���� � �������� �� � ����� ���������
 *   ����� �� ����� �������� ����� ��������� � ����, ����� � �����.
 *   ������� �� ����� ������� ����������� ��������� ��'���� � ���� �
 *   ���� ���������, ��� ����� �������� �� ��������� ��'����.
 *
 *   ���� �����, ��� ����������� ������� �������, ��� ������� ���������
 *   ��'���� (����� �� ���������� �����) ���������� ���������� ���������, ����
 *   ��������� ��������� ������ ��'���� (������ ������, ������, �������� � �.�.).
 *
 *   ���������, ����������� ����� ��������� �����, ��������� ����������
 *   � ����� �������� �� ����� ��������. �� ������ � ������������ ����� ��������
 *   �������, �������� �������� ����������� � ����, �������� ��'���� (�����)
 *   ������������ ����������, ��������� � ��������.
 *
 *)

(*
 * ������ ����, �� ����� �� ������ ���������� ��� �����
 * ��� ������������ �������� ��������� �����. �.��. �
 * ���� �� ���������, � ���� �� �������� ����������� ���������
 * ��'����.
 *)
type
  TDesktopItem = class(TObject)
  private
    FOwnerName: String;
    FItemClassName: String;
    FItemName: String;
    FItem: TComponent;

  protected
    // ������� � ������ �������� ��'����
    procedure ReadFromStream(Reader: TReader); virtual;
    // ������� � ����� �������� ��'����
    procedure WriteToStream(Writer: TWriter); virtual;

    // ��������� (��������) ������� ��'��� ��������� ����������
    procedure LoadDesktopItem(I: TComponent); overload; virtual;
    // ��������� (��������) ������� ��'��� ��������� ����������
    // ��'��� ���� �� ������� FItem
    procedure LoadDesktopItem; overload;
    // ������� �������� ��������� ��������� ��'����
    procedure SaveDesktopItem(I: TComponent); virtual;

  public
    constructor CreateFromStream(S: TReader);

    // ���� ����
    procedure Assign(I: TDesktopItem); virtual;

    // ������� ������ ������, ��� ���� ��'��� �������
    // �������� ��� ��������� ��'���� (��'��� ����������
    // ���� AnOwnerName, AClassName, AName)
    function IsItem(const AnOwnerName, AClassName, AName: String): Boolean; overload;
    function IsItem(const AClassName, AName: String): Boolean; overload;

    // ��� ���������� ������ �������� �������� ��������
    // � ����� ��� ���� �������� ���, ����� ����� �� �����
    // ��������� ������������ ������
    class function GetTypeID: Integer; virtual;

    // ����������� ��������� ��'����
    property OwnerName: String read FOwnerName;
    property ItemClassName: String read FItemClassName;
    property ItemName: String read FItemName;

    // �������� �� ��� ������� ��'���
    property Item: TComponent read FItem {write FItem};
  end;

(*
 * ����, �� ���������� ��� �������� ��������� �����.
 *
 *)
type
  TFormData = class(TDesktopItem)
  private
    FHeight: Integer;
    FLeft: Integer;
    FWidth: Integer;
    FTop: Integer;
    FVisible: Boolean;
    FWindowState: TWindowState;

    function GetForm: TForm;
    procedure SetForm(const Value: TForm);

  protected
    procedure ReadFromStream(Reader: TReader); override;
    procedure WriteToStream(Writer: TWriter); override;

    procedure LoadDesktopItem(I: TComponent); override;
    procedure SaveDesktopItem(I: TComponent); override;

  public
    procedure Assign(I: TDesktopItem); override;

    class function GetTypeID: Integer; override;

    property Left: Integer read FLeft;
    property Top: Integer read FTop;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Visible: Boolean read FVisible;
    property WindowState: TWindowState read FWindowState;

    property Form: TForm read GetForm write SetForm;
  end;

  TgdcBaseData = class(TFormData)
  private
    FgdcSubType: String;
    FgdcClassName: String;

  protected
    procedure ReadFromStream(Reader: TReader); override;
    procedure WriteToStream(Writer: TWriter); override;

    procedure SaveDesktopItem(I: TComponent); override;
  public
    procedure Assign(I: TDesktopItem); override;
    
    class function GetTypeID: Integer; override;

    property gdcClassName: String read FgdcClassName;
    property gdcSubType: String read FgdcSubType;
  end;

type
  TgsDesktopManager = class;

  (*

    ���� TDesktopItems ����������, ��� �������� ���� ��'����,
    ��� ��������� �������� ��������, �������� ��'���� ���
    ������ ��������.

  *)
  TDesktopItems = class(TObject)
  private
    FItems: TObjectList;
    FDesktopManager: TgsDesktopManager;

    function GetItems(Index: Integer): TDesktopItem;
   // procedure SetItems(Index: Integer; const Value: TDesktopItem);
    function GetCount: Integer;

    // ����� ��������� ��������� ����� ������ � ����� � ���������� � ����
    // ��� ��������������
    function FindComponent(AnOwner: TComponent; const AClassName, AName: String): TComponent; overload;
    // ����� ��������� �������� �������, ���� ������ -- ���������� ��� ������
    // ���� ��� -- ���
    function FindComponent(AnOwner: TComponent; AComponent: TComponent): TComponent; overload;

  protected
    // ��������� �� ������ ������ �������� �������� ��������
    procedure ReadFromStream(S: TStream);
    // ���������� � ����� ������ �������� �������� ��������
    procedure WriteToStream(S: TStream);

  public
    constructor Create(ADesktopManager: TgsDesktopManager);
    destructor Destroy; override;

    // �������� � ��� ������ ����� ��������� ��� �������� ��������
    // ��������� �������
    procedure Add(const DI: TDesktopItem);
    //
    procedure Remove(const Item: TComponent);
    // ����� � ����� ������ ���� ��������� � ����������� ��������� �������
    // �� �������� ������ ���������, ������ � �������
    function Find(const AnOwnerName, AClassName, AName: String): TDesktopItem; overload;
    function Find(const AClassName, AName: String): TDesktopItem; overload;
    // ����� � ����� ������ ���� ��������� � ����������� ��������� �������
    // �� �������� ������ �� ���� �������� ������
    function Find(const Item: TComponent): TDesktopItem; overload;
    //
    procedure Clear;

    // �������� �� ���� ����� � ��������� �� ���������
    // � ����� ���������
    procedure SaveDesktopItems(const Mode: Boolean = True);
    // �������� �� ������ ��������, ��� ������� � ��� ����
    // ����������� ��������� � ���������������� ��� ���������������
    // �������� ������ (����)
    procedure LoadDesktopItems;

    // ���������� �������� � ����������� ���� � ����� ������
    property Count: Integer read GetCount;
    // ������� � ����������� �������� ��������
    property Items[Index: Integer]: TDesktopItem read GetItems {write SetItems};
      default;
    // ������ �� �������� ���������
    property DesktopManager: TgsDesktopManager read FDesktopManager;
  end;

  TOnDesktopItemCreateEvent = function(Sender: TObject;
    const AnItemClass, AnItemName: String): TComponent of object;

  (*

    TgsDesktopManager. ���� ��������� �������� �� ���������� ����������.
    �� ��������� � ��������� �� �� ����.
    �� ����� ���������������� �������� ������� (�����) ������������ �����������.
    �� ����� �������� ��������� �������� �������� � ���� ���������.
    �� ������������ ������ ��������� ���������.

  *)
  TgsDesktopManager = class(TComponent)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FDesktopItems: TDesktopItems;
    FDesktopNames: array of String;
    FDesktopCount: Integer;
    FCurrentDesktopName: String;
    FOnDesktopItemCreate: TOnDesktopItemCreateEvent;
    FStorage: TgsStorage;
    FLoadingDesktop: Boolean;

    procedure SetDatabase(const Value: TIBDatabase);
    function GetDesktopNames(Index: Integer): String;
    function GetCurrentDesktopIndex: Integer;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function DoOnDesktopItemCreate(const AnItemClass, AnItemName: String): TComponent;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    // ��������� �� ���� ������ ��������� ��� �������� ������������
    // � ���������� ������
    procedure ReadDesktopNames;
    // ��������� � ����� ������ ��������� ���������
    // ������ � ����� ������� ������� �������
    procedure InitComboBox(CB: TComboBox);

    // ��������� �������, �������� ������ �� ���� ������
    function ReadDesktopData(const ADesktopName: String = ''): Boolean;
    // ���������� �������, �������� ������ � ���� ������
    // ���� �����=0, �� ��������� ����� ���� �� �����������, �� �����������
    // ��������� �����������, ������� �������� ��������� �����������
    // ������ ����� ������������ ��� ���������� �������� �� ������
    // �� ���������. � ���� ������ ��������� ���� � �� ��������� �� ���� ���������
    // ��� (��������� ����, �� ���������) ����������� � ���� ������
    // ��� �������������� ���������� �������� ��� �������� ������ ��������.
    procedure WriteDesktopData(ADesktopName: String; const Mode: Boolean);

    // ���� ��� �������� �������� �� ������� ���������� ���, ��
    // ����������� �������, ����������� ��������� (������� ��-���������)
    // ������ �����, ��������� ���� ���������� ��������, ���������
    // ������, ������ ��� ��������� ��-���������
    procedure SetDefaultDesktop(ADesktopName: String);

    // ����������� �������� �������� ��������� �� �������� ��������
    procedure LoadDesktop;
    // ��������� ��������� �������� �������� � ������� ��������
    // Mode: 1 -- �������� � ���� ����� � �������� ���������
    //       0 -- �������� ����� �������� ��������
    // ����� ����� ���������������, ��� ����������� ������� �������
    // ������. ���� ����� ���������������, ��� �����������
    // �������� � �������������.
    procedure SaveDesktop(const Mode: Boolean);

    // ��������� ��������� ��� ���������� � � ��������
    procedure SaveDesktopItem(I: TComponent);
    // ��������� �������� ������ �����������, ������������ � ��������
    // ���� � �������� ��� �������� ��� ������� �������, ��
    // � �������� ��������� ������ � ����������� � ����������������
    // ����������� ��������� �������
    procedure LoadDesktopItem(I: TComponent);

    //
    procedure RemoveDeskTopItem(I: TComponent);

    // ������� �������, �������� ������
    procedure DeleteDesktop(const ADesktopName: String);

    //
    function FindDesktop(const ADesktopName: String): Integer;

    property DesktopNames[Index: Integer]: String read GetDesktopNames;
      default;
    property DesktopCount: Integer read FDesktopCount;
    property CurrentDesktopName: String read FCurrentDesktopName;
    property CurrentDesktopIndex: Integer read GetCurrentDesktopIndex;
    property Storage: TgsStorage read FStorage;
    property DesktopItems: TDesktopItems read FDesktopItems;
    property LoadingDesktop: Boolean read FLoadingDesktop;

  published
    property Database: TIBDatabase read FDatabase write SetDatabase;

    // ��� ���������� �������� �� ���� ������ � �������� �������� ��������
    // �� ���� ������������ ����������� ������� ��������� ������� �������
    // ��� ����� �� ������ ��������� ������ �����
    // ��������� ������� ����� ����������� �� ���������� �� ������
    // ����� ������. �������, ��� ����� ������ ���� ���������������
    property OnDesktopItemCreate: TOnDesktopItemCreateEvent read FOnDesktopItemCreate
      write FOnDesktopItemCreate;
  end;

  EDesktopError = class(Exception);

procedure Register;

var
  DesktopManager: TgsDesktopManager;

implementation

uses
  DB, IBSQL, gd_security, gd_ClassList, gdcBaseInterface,
  gdc_createable_form, gdc_frmG_unit, gd_createable_form,
  gdc_frmMDH_unit, gsResizerInterface, gd_splash, gdc_dlgG_unit,
  IBBlob;

const
  DesktopValueName = 'Desktop';

function GetScreenRes: Integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  try
    Result := GetDeviceCaps(DC, HORZRES) * GetDeviceCaps(DC, VERTRES);
  finally
    ReleaseDC(0, DC);
  end;
end;

{ TgsDesktopManager }

constructor TgsDesktopManager.Create;
begin
  // ������ ���� �������� ��������� ����� ���� ������ �� ������
  Assert(DesktopManager = nil, 'Only one desktop manager per project allowed.');
  inherited Create(AnOwner);
  DesktopManager := Self;
  FDesktopItems := TDesktopItems.Create(Self);
  FDesktopCount := 0;
  FCurrentDesktopName := '';
  FTransaction := TIBTransaction.Create(nil);
  FTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait'#13#10;
  FDatabase := nil;
  FStorage := TgsStorage.Create;
end;

destructor TgsDesktopManager.Destroy;
begin
  DesktopManager := nil;
  if FTransaction.InTransaction then
    FTransaction.Commit;
  FTransaction.Free;
  FDesktopItems.Free;
  FStorage.Free;
  inherited;
end;

function TgsDesktopManager.ReadDesktopData(const ADesktopName: String = ''): Boolean;
var
  IBSQL: TIBSQL;
  S: TStream;
  bs: TIBBlobStream;
begin
  Result := False;
  if DesktopCount = 0 then exit;
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Database := FDatabase;
    IBSQL.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    if ADesktopName > '' then
      IBSQL.SQL.Text := Format('SELECT dtdata, name FROM gd_desktop WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
        [IBLogin.UserKey, ADesktopName, GetScreenRes])
    else
      IBSQL.SQL.Text := Format('SELECT dtdata, name FROM gd_desktop WHERE userkey = %d AND ((screenres IS NULL) OR (screenres = %d)) ORDER BY saved DESC',
        [IBLogin.UserKey, GetScreenRes]);
    IBSQL.ExecQuery;

    if IBSQL.EOF then exit;

    if IBSQL.FieldByName('dtdata').IsNull then
      FStorage.Clear
    else begin
      bs := TIBBlobStream.Create;
      try
        bs.Mode := bmRead;
        bs.Database := FDatabase;
        bs.Transaction := FTransaction;
        bs.BlobID := IBSQL.FieldByName('dtdata').AsQUAD;
        FStorage.LoadFromStream(bs);
      finally
        bs.Free;
      end;
    end;

    try
      S := TMemoryStream.Create;
      try
        if FStorage.ReadStream('\', DesktopValueName, S) then
          FDesktopItems.ReadFromStream(S);
      finally
        S.Free;
      end;
      FCurrentDesktopName := IBSQL.FieldByName('name').AsString;
      Result := True;
    except
      if ADesktopName > '' then
        DeleteDesktop(ADesktopName);
      Result := False;
    end;

    if FTransaction.InTransaction then
      FTransaction.Commit;
  finally
    IBSQL.Free;
  end;
end;

procedure TgsDesktopManager.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if FDatabase <> nil then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if FDatabase <> nil then
      FDatabase.FreeNotification(Self);
    FTransaction.DefaultDatabase := FDatabase;
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsNew', [TgsDesktopManager]);
end;

procedure TgsDesktopManager.SaveDesktopItem(I: TComponent);
var
  DI: TDesktopItem;
//  SubType: String;
begin
  DI := FDesktopItems.Find(I.ClassName, I.Name);
  (*
  DI := FDesktopItems.Find(I);
  if (DI = nil) and (I <> nil) and (I.Owner <> nil) then
  *)

  if not Assigned(DI) then
  begin
    if (I is TForm) then
    begin
      if (I is TgdcCreateableForm) and ((I as TgdcCreateableForm).SubType <> '') then
        DI := TgdcBaseData.Create
      else
        DI := TFormData.Create;
    end
    else
      DI := TDesktopItem.Create;

    FDesktopItems.Add(DI);
  end;

  DI.SaveDesktopItem(I)
end;

procedure TgsDesktopManager.LoadDesktopItem(I: TComponent);
var
  DI: TDesktopItem;
//  SubType: String;
begin
  DI := FDesktopItems.Find(I.ClassName, I.Name);
  {
  if Assigned(I.Owner) then
    DI := FDesktopItems.Find(I.Owner.Name, I.ClassName, I.Name)
  else
    DI := FDesktopItems.Find('', I.ClassName, I.Name);
  }

  if Assigned(DI) then
    DI.LoadDesktopItem(I)
  else
  begin
{    if I is TForm then
    begin
      if (I is TgdcCreateableForm) and ((I as TgdcCreateableForm).SubType <> '') then
        DI := TgdcBaseData.Create
      else
        DI := TFormData.Create;
    end
    else
      DI := TDesktopItem.Create;

    FDesktopItems.Add(DI);

    DI.SaveDesktopItem(I); }
  end;
end;

function TgsDesktopManager.GetDesktopNames(Index: Integer): String;
begin
  Assert((Index >= 0) and (Index < FDesktopCount));
  Result := FDesktopNames[Index];
end;

procedure TgsDesktopManager.WriteDesktopData;
var
  IBSQL: TIBSQL;
  I: Integer;
  Found: Boolean;
  S: TStream;
begin
  FStorage.Clear;
  // ������� ������� ��������� �������� ��������
  SaveDesktop(Mode);
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Database := FDatabase;
    IBSQL.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    if ADesktopName = '' then
      ADesktopName := '�����������';

    IBSQL.SQL.Text := Format('SELECT * FROM gd_desktop WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
      [IBLogin.UserKey, ADesktopName, GetScreenRes]);
    IBSQL.ExecQuery;

    if IBSQL.EOF then
    begin
      IBSQL.Close;
      IBSQL.SQL.Text := Format('INSERT INTO gd_desktop (userkey, screenres, name) VALUES (%d,%d,''%s'')',
        [IBLogin.UserKey, GetScreenRes, ADesktopName]);
      IBSQL.ExecQuery;
    end;

    IBSQL.Close;
    IBSQL.SQL.Text := Format('UPDATE gd_desktop SET dtdata = :D, saved=''NOW'' WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
      [IBLogin.UserKey, ADesktopName, GetScreenRes]);
    IBSQL.Prepare;

    // ������� ���������� ���� ����� � ��������
    S := TMemoryStream.Create;
    try
      FDesktopItems.WriteToStream(S);
      FStorage.WriteStream('', DesktopValueName, S);
    finally
      S.Free;
    end;
    FStorage.WriteInteger('', 'DesktopItemsCount', FDesktopItems.Count);
    IBSQL.Params.ByName('D').AsString := FStorage.DataString;
    IBSQL.ExecQuery;
    IBSQL.Close;
    if FTransaction.InTransaction then
      FTransaction.Commit;

    Found := False;
    for I := 0 to FDesktopCount - 1 do
      if FDesktopNames[I] = ADesktopName then
      begin
        Found := True;
        break;
      end;
    if not Found then
    begin
      SetLength(FDesktopNames, FDesktopCount + 1);
      FDesktopNames[FDesktopCount] := ADesktopName;
      Inc(FDesktopCount);
    end;
    FCurrentDesktopName := ADesktopName;
  finally
    IBSQL.Free;
  end;
end;

procedure TgsDesktopManager.LoadDesktop;
begin
  FLoadingDesktop := True;
  try
    FDesktopItems.LoadDesktopItems;

    if DesktopManager.DesktopItems.Count > 0 then
    begin
      if (DesktopManager.DesktopItems.Items[0].Item is TForm) and
        (DesktopManager.DesktopItems.Items[0].Item as TForm).Visible
      then
      begin
        (DesktopManager.DesktopItems.Items[0].Item as TForm).SetFocus;
      end;
    end;
  finally
    FLoadingDesktop := False;
  end;
end;

procedure TgsDesktopManager.SaveDesktop;
begin
  FDesktopItems.SaveDesktopItems(Mode);
end;

procedure TgsDesktopManager.DeleteDesktop(const ADesktopName: String);
var
  IBSQL: TIBSQL;
  A: array of String;
  I, K: Integer;
begin
  if (FDesktopCount = 0) or (ADesktopName = '') then
    exit; 

  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Database := FDatabase;
    IBSQL.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    IBSQL.SQL.Text := Format('DELETE FROM gd_desktop WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
      [IBLogin.UserKey, ADesktopName, GetScreenRes]);
    IBSQL.ExecQuery;

    if FTransaction.InTransaction then
      FTransaction.Commit;
  finally
    IBSQL.Free;
  end;

  SetLength(A, FDesktopCount);
  for I := 0 to FDesktopCount - 1 do
    A[I] := FDesktopNames[I];
  K := 0;
  for I := 0 to FDesktopCount - 1 do
    if A[I] <> ADesktopName then
    begin
      FDesktopNames[K] := A[I];
      Inc(K);
    end;
  Dec(FDesktopCount);
  SetLength(A, 0);

  if ADesktopName = FCurrentDesktopName then
  begin
    FCurrentDesktopName := '';
  end;
end;

procedure TgsDesktopManager.ReadDesktopNames;
var
  IBSQL: TIBSQL;
begin
  FDesktopCount := 0;
  FCurrentDesktopName := '';
  SetLength(FDesktopNames, 0);

  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Transaction := gdcBaseManager.ReadTransaction;
    IBSQL.SQL.Text := Format('SELECT name FROM gd_desktop WHERE userkey=%d AND ((screenres IS NULL) OR (screenres=%d))',
      [IBLogin.UserKey, GetScreenRes]);
    IBSQL.ExecQuery;
    while not IBSQL.EOF do
    begin
      SetLength(FDesktopNames, FDesktopCount + 1);
      FDesktopNames[FDesktopCount] := IBSQL.FieldByName('name').AsString;
      Inc(FDesktopCount);
      IBSQL.Next;
    end;
  finally
    IBSQL.Free;
  end;
end;

procedure TgsDesktopManager.InitComboBox;
var
  I: Integer;
begin
  CB.Items.Clear;
  for I := 0 to FDesktopCount - 1 do
    CB.Items.Add(FDesktopNames[I]);
  // � �������� �� ���������! ���� ������������
  // � ����� ��������� ����������
  for I := 0 to FDesktopCount - 1 do
    FDesktopNames[I] := CB.Items[I];
  if CurrentDesktopIndex >= 0 then
    CB.ItemIndex := CurrentDesktopIndex;
end;

function TgsDesktopManager.GetCurrentDesktopIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FDesktopCount - 1 do
    if FDesktopNames[I] = FCurrentDesktopName then
    begin
      Result := I;
      break;
    end;
end;

procedure TgsDesktopManager.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) then
  begin
    if AComponent = FDatabase then
      FDatabase := nil;
  end;
end;

function TgsDesktopManager.DoOnDesktopItemCreate(const AnItemClass,
  AnItemName: String): TComponent;
begin
  if Assigned(FOnDesktopItemCreate) then
    Result := FOnDesktopItemCreate(Self, AnItemClass, AnItemName)
  else
    Result := nil;  
end;

procedure TgsDesktopManager.SetDefaultDesktop(ADesktopName: String);
var
  IBSQL: TIBSQL;
begin
  Assert(FDesktopCount > 0);

  if ADesktopName = '' then
    ADesktopName := FCurrentDesktopName;

  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Database := FDatabase;
    IBSQL.Transaction := FTransaction;

    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;

    IBSQL.SQL.Text := Format('UPDATE gd_desktop SET saved = ''NOW'' WHERE userkey = %d AND name = ''%s'' AND ((screenres IS NULL) OR (screenres = %d))',
      [IBLogin.UserKey, ADesktopName, GetScreenRes]);
    IBSQL.ExecQuery;

    if FTransaction.InTransaction then
      FTransaction.Commit;
  finally
    IBSQL.Free;
  end;
end;

function TgsDesktopManager.FindDesktop(const ADesktopName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to DesktopCount - 1 do
    if AnsiCompareText(ADesktopName, DesktopNames[I]) = 0 then
    begin
      Result := I;
      break;
    end;
end;

procedure TgsDesktopManager.RemoveDeskTopItem(I: TComponent);
begin
  FDesktopItems.Remove(I);
end;

{ TDesktopItem }

procedure TDesktopItem.Assign(I: TDesktopItem);
begin
  if Assigned(I) then
  begin
    FItemClassName := I.ItemClassName;
    FItemName := I.ItemName;
    FOwnerName := I.OwnerName;
    FItem := I.Item;
  end;
end;

constructor TDesktopItem.CreateFromStream(S: TReader);
begin
  Create;
  ReadFromStream(S);
end;

class function TDesktopItem.GetTypeID: Integer;
begin
  Result := 0;
end;

function TDesktopItem.IsItem(const AnOwnerName, AClassName, AName: String): Boolean;
begin
  Result := (AnOwnerName = FOwnerName) and
    (AClassName = FItemClassName) and (AName = FItemName);
end;

procedure TDesktopItem.LoadDesktopItem(I: TComponent);
begin
  // ��� �� �������� � ���������� ����� ���������� �
  // �������� FItem ����� ����� Ͳ�
  // ���������� ��� ��������� ���������
  if FItem = nil then
    FItem := I;
end;

function TDesktopItem.IsItem(const AClassName, AName: String): Boolean;
begin
  Result := (AClassName = FItemClassName) and (AName = FItemName);
end;

procedure TDesktopItem.LoadDesktopItem;
begin
  Assert(FItem <> nil);
  LoadDesktopItem(FItem);
end;

procedure TDesktopItem.ReadFromStream;
begin
  Reader.ReadSignature;
  FOwnerName := Reader.ReadString;
  FItemClassName := Reader.ReadString;
  FItemName := Reader.ReadString;
end;

procedure TDesktopItem.SaveDesktopItem(I: TComponent);
begin
  if Assigned(I) then
  begin
    if Assigned(I.Owner) then
      FOwnerName := I.Owner.Name
    else
      FOwnerName := '';

    FItemClassName := I.ClassName;
    FItemName := I.Name;
    FItem := I;
  end;
end;

procedure TDesktopItem.WriteToStream;
begin
  Writer.WriteSignature;
  Writer.WriteString(OwnerName);
  Writer.WriteString(ItemClassName);
  Writer.WriteString(ItemName);
end;

{ TFormData }

procedure TFormData.Assign(I: TDesktopItem);
begin
  inherited;
  if Assigned(I) then
  with I as TFormData do
  begin
    FLeft := Left;
    FTop := Top;
    FWidth := Width;
    FHeight := Height;
    FVisible := Visible;
    FWindowState := WindowState;
  end;
end;

function TFormData.GetForm: TForm;
begin
  Result := Item as TForm;
end;

class function TFormData.GetTypeID: Integer;
begin
  Result := 1;
end;

procedure TFormData.LoadDesktopItem(I: TComponent);
begin
  inherited LoadDesktopItem(I);
  if Assigned(I) then
    with I as TForm do
    begin
      WindowState := FWindowState;

      // �� �� ��������������� �������, ���������� ����, ����
      // ��� ���������������, ��������������
      if WindowState = wsNormal then
      begin
        Left := FLeft;
        Top := FTop;
        Width := FWidth;
        Height := FHeight;
      end;

{ TODO :
DAlex. /// 
��� ���� ����� Show �� �������.
� Delphi ����������, ��� WM_Activate �������� ������ ��� OnCreate, ��� �����������.
���� ���� ����������������, �� �������� ���.
                                                                          DAlex. }
      if FVisible then {Show} else
      begin
        // ���� ������� ����� - �� ������ ������� ������� �� ��������������! (denis)
        if Application.MainForm = I then
          //SendMessage(Application.MainForm.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0)
        else
          Hide;
      end;
    end;
end;

procedure TFormData.ReadFromStream;
begin
  inherited;
  FLeft := Reader.ReadInteger;
  FTop := Reader.ReadInteger;
  FWidth := Reader.ReadInteger;
  FHeight := Reader.ReadInteger;
  FVisible := Reader.ReadBoolean;
  FWindowState := TWindowState(Reader.ReadInteger);
end;

procedure TFormData.SaveDesktopItem(I: TComponent);
begin
  inherited;
  if Assigned(I) then
    with I as TForm do
    begin
      FLeft := Left;
      FTop := Top;
      FWidth := Width;
      FHeight := Height;
      FVisible := IsWindowVisible(Handle);
      FWindowState := WindowState;
    end;
end;

procedure TFormData.SetForm(const Value: TForm);
begin
  FItem := Value;
end;

procedure TFormData.WriteToStream;
begin
  inherited;
  Writer.WriteInteger(FLeft);
  Writer.WriteInteger(FTop);
  Writer.WriteInteger(FWidth);
  Writer.WriteInteger(FHeight);
  Writer.WriteBoolean(FVisible);
  Writer.WriteInteger(Integer(FWindowState));
end;

{ TDesktopItems }

constructor TDesktopItems.Create(ADesktopManager: TgsDesktopManager);
begin
  inherited Create;
  FItems := TObjectList.Create(True);
  FDesktopManager := ADesktopManager;
end;

destructor TDesktopItems.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TDesktopItems.Add;
begin
  Assert(Find(DI.ItemClassName, DI.ItemName) = nil, 'Items with the same classname/name are not allowed');
  FItems.Add(DI);
end;

function TDesktopItems.Find(const AnOwnerName, AClassName, AName: String): TDesktopItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].IsItem(AnOwnerName, AClassName, AName) then
    begin
      Result := Items[I];
      break;
    end;
end;

function TDesktopItems.Find(const Item: TComponent): TDesktopItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
    if TDesktopItem(FItems[I]).Item = Item then
    begin
      Result := FItems[I] as TDesktopItem;
      break;
    end;
end;

function TDesktopItems.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TDesktopItems.GetItems(Index: Integer): TDesktopItem;
begin
  Result := TDesktopItem(FItems[Index]);
end;

procedure TDesktopItems.LoadDesktopItems;
var
  I{, K}: Integer;
  C: TComponent;
  //Cl: TPersistentClass;
  PC: TFormClass;
  F: TForm;
//  GdC: CgdcBase;
  CE: TgdClassEntry;
begin
  // ��� �����, ��� ��� ���� �������� � ��������
  // ������
  for I := 0 to Screen.FormCount - 1 do
  begin
    if (Find(Screen.Forms[I].ClassName, Screen.Forms[I].Name, '') = nil)
      and (Screen.Forms[I] <> Application.MainForm)
      and (Screen.Forms[I].FormStyle <> fsStayOnTop)
      and (Screen.Forms[I].BorderStyle = bsSizeable)
      and (Screen.Forms[I].ClassName <> 'TfrmSplash') then
    begin
      Screen.Forms[I].Hide;
    end;
  end;

  for I := Count - 1 downto 0 do
  begin
    C := FindComponent(Application, Items[I].ItemClassName, Items[I].ItemName);
    if (C <> nil) and (C is TCreateableForm) then
    begin
       TCreateableForm(C).LoadDesktopSettings;
    end
    else if (C <> nil) and (not (C is TForm)) then
      Items[I].LoadDesktopItem(C)
    else if (Items[I] is TFormData) and TFormData(Items[I]).Visible then
    begin
      if Assigned(FDesktopManager) then
        C := FDesktopManager.DoOnDesktopItemCreate(Items[I].ItemClassName, Items[I].ItemName);

      if not Assigned(C) then
      begin
        PC := TFormClass(GetClass(Items[I].ItemClassName));
        if PC <> nil then
        begin
          if Pos(USERFORM_PREFIX, Items[I].ItemName) = 1 then
          begin
            try
              F := CgdcCreateableForm(PC).CreateUser(Application, Items[I].ItemName);
              if Assigned(F) then
                F.Show;
            except
              { TODO : 
���������� ���������� ��� ������ ��� ���
� ����� ����� ������� ���������� ���� ������-��
�������. ����������� ��� ��� ����������������
����� �������� ������ � ����� ������ �� ������� � ���������
����������. }
            end;
          end
          else if PC.InheritsFrom(Tgdc_frmG) then
          begin
            if (Items[i] is TgdcBaseData) then
            begin
              CE := gdClassList.Find((Items[i] as TgdcBaseData).gdcClassName);
              if CE is TgdFormEntry {and GdC.Class_TestUserRights([tiAView, tiAChag, tiAFull], (Items[i] as TgdcBaseData).gdcSubType)} then
              begin
                // ���� ��� �������� ����-��� � ����������������� �������
                // ������������ � ������ ���� ������, ��� ����� ���� ���
                // ����� ������
                // �� ������ ����������.
                { TODO : � ��� ���� ���� ��� ����� ������ ������?? }
                try
                  F := TgdFormEntry(CE).frmClass.CreateSubType(Application, (Items[i] as TgdcBaseData).gdcSubType);
                except
                  F := nil;
                end;
              end else
                F := nil;
            end else
              F := CgdcCreateableForm(PC).CreateAndAssign(Application);
            if Assigned(F) then
            begin
              if not TgdcCreateableForm(F).CreatedCarefully then
                FreeAndNil(F)
              else
                F.Show;
            end;
          end
          else if PC.InheritsFrom(Tgdc_dlgG) then
          begin
            // NOP
            // �� ���������� ���������� ����, ���� ���� ���
            // ����������� � ������� ����
          end
          else if PC.InheritsFrom(TgdcCreateableForm) then
            try
              C := CgdcCreateableForm(PC).CreateAndAssign(Application);
            except
            end
          else if PC.InheritsFrom(TCreateableForm) then
            try
              C := CCreateableForm(PC).CreateAndAssign(Application)
            except
            end
          else
            try
              C := PC.Create(Application);
            except
            end;
        end;
      end;

      if Assigned(C) then
        Items[I].LoadDesktopItem(C);
    end;
    if (C <> nil) and C.InheritsFrom(TCustomForm) then
      TCustomForm(C).Show;
  end;

  {$IFNDEF DEBUG}
  if gdSplash <> nil then
    gdSplash.ShowSplash;
  {$ENDIF}  
end;

procedure TDesktopItems.ReadFromStream;
var
  DI: TDesktopItem;
  Reader: TReader;
begin
  FItems.Clear;
  Reader := TReader.Create(S, 1024);
  try
    Reader.ReadSignature;
    Reader.ReadListBegin;
    while not Reader.EndOfList do
    begin
      case Reader.ReadInteger of
        0: DI := TDesktopItem.CreateFromStream(Reader);
        1: DI := TFormData.CreateFromStream(Reader);
        2: DI := TgdcBaseData.CreateFromStream(Reader);
      else
        DI := nil;
      end;

      if Assigned(DI) then
      begin
        if Find({DI.OwnerName, }DI.ItemClassName, DI.ItemName) <> nil then
        begin
          Find({DI.OwnerName, }DI.ItemClassName, DI.ItemName).Assign(DI);
          DI.Free;
        end else
          FItems.Add(DI);
      end else
        raise EDesktopError.Create('Stream error. Invalid desktop item type encountered.');
    end;
    Reader.ReadListEnd;
  finally
    Reader.Free;
  end;
end;

procedure TDesktopItems.SaveDesktopItems;
var
  I: Integer;
begin
  if Mode then
    Clear;

{ TODO : ���������� � �������� ������� �������� ����� ������������� }
{ TODO : ����� ������������ ��� ������ }

  for I := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[I] <> Application.MainForm then
    begin
      if (Screen.Forms[I] is TCreateableForm)
        and (not (Screen.Forms[I] is Tgdc_dlgG)) then
      begin
        if Screen.Forms[I].Visible or (Find(Screen.Forms[I]) <> nil) then
          (Screen.Forms[I] as TCreateableForm).SaveDesktopSettings;
      end;
    end;
  end;

  if (Application.MainForm is TCreateableForm) and Application.MainForm.Visible then
    (Application.MainForm as TCreateableForm).SaveDesktopSettings;
end;

{procedure TDesktopItems.SetItems(Index: Integer;
  const Value: TDesktopItem);
begin
  FItems[Index] := Value;
end;}

procedure TDesktopItems.WriteToStream;
var
  I: Integer;
  Writer: TWriter;
begin
  Writer := TWriter.Create(S, 1024);
  try
    Writer.WriteSignature;
    Writer.WriteListBegin;
    for I := 0 to Count - 1 do
    begin
      Writer.WriteInteger(Items[I].GetTypeID);
      Items[I].WriteToStream(Writer);
    end;
    Writer.WriteListEnd;
  finally
    Writer.Free;
  end;
end;

function TDesktopItems.FindComponent(AnOwner: TComponent; const AClassName,
  AName: String): TComponent;
var
  I: Integer;
begin
  Result := nil;
  if AnOwner <> nil then
    if (AnOwner.ClassName = AClassName) and (AnOwner.Name = AName) then
      Result := AnOwner else
    for I := 0 to AnOwner.ComponentCount - 1 do
    begin
      if (AnOwner.Components[I].ClassName = AClassName) and
        (AnOwner.Components[I].Name = AName) then
      begin
        Result := AnOwner.Components[I];
        break;
      end;

      Result := FindComponent(AnOwner.Components[I], AClassName, AName);

      if Result <> nil then
        break;
    end;
end;

function TDesktopItems.FindComponent(AnOwner, AComponent: TComponent): TComponent;
var
  I: Integer;
begin
  if AnOwner = AComponent then Result := AComponent else
  begin
    Result := nil;
    if AnOwner <> nil then
      for I := 0 to AnOwner.ComponentCount - 1 do
        if AnOwner.Components[I] = AComponent then
        begin
          Result := AnOwner.Components[I];
          break;
        end else if AnOwner.Components[I] is TForm then
        begin
          Result := FindComponent(AnOwner.Components[I], AComponent);
          if Result <> nil then break;
        end;
  end;
end;

procedure TDesktopItems.Clear;
begin
  FItems.Clear;
end;

function TDesktopItems.Find(const AClassName, AName: String): TDesktopItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].IsItem(AClassName, AName) then
    begin
      Result := Items[I];
      break;
    end;
end;

procedure TDesktopItems.Remove(const Item: TComponent);
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if TDesktopItem(FItems[I]).Item = Item then
    begin
      FItems.Delete(I);
      break;
    end;
end;

{ TgdcBaseData }

procedure TgdcBaseData.Assign(I: TDesktopItem);
begin
  inherited;

  if Assigned(I) then
    with I as TgdcBaseData do
    begin
      FgdcClassName := gdcClassName;
      FgdcSubType := gdcSubType;
    end;

end;

class function TgdcBaseData.GetTypeID: Integer;
begin
  Result := 2;
end;

procedure TgdcBaseData.ReadFromStream(Reader: TReader);
begin
  inherited ReadFromStream(Reader);
  FgdcClassName := Reader.ReadString;
  FgdcSubType := Reader.ReadString;
end;

procedure TgdcBaseData.SaveDesktopItem(I: TComponent);
begin
  inherited SaveDesktopItem(I);

  { TODO : 
��� �����. ������ ���� ����� �������� ����� �������
�� ����� ����� ����. }
  FgdcClassName := I.ClassName;
  FgdcSubType := (I as TgdcCreateableForm).SubType;
end;

procedure TgdcBaseData.WriteToStream(Writer: TWriter);
begin
  inherited WriteToStream(Writer);
  Writer.WriteString(FgdcClassName);
  Writer.WriteString(FgdcSubType);
end;

initialization
  DesktopManager := nil;

finalization
  DesktopManager := nil;
end.
