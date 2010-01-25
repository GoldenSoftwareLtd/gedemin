
unit Xwg_prov;

{ 1.00    16-aug-97 }
{ 1.01    16-feb-98  Add fourth primary key }
{ 1.02    27-okt-98 TxEmplProv initaial verison }

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, DBTables, Xbook, MakeReg, xCommon_anj, xBkIni;

type
  String6 = string[6];
  String32 = string[32];

  TColUnit = (cu_None, cu_Day, cu_Hour, cu_Tkm, cu_CG, cu_GSM);

const
  EmpZero = 0;

type
  TxPushWageProv = class(TComponent)
  private
    WageProv: TTable;
    StProv: TTable;
    xBookkeep: TxBookkeep;
  public
    constructor Create(anOwner: TComponent); override;
    destructor Destroy; override;

    {delete the document in the regim}
    procedure DelRegSubReg(RegKey, SubRegKey: Integer);

    {adds entry into the wageprov }
    procedure PushProv(
      Codes: array of Integer;        {коды - Employee + Regim + SubRegim}
      ADate: TDateTime;              {дата выполнения проводки}
      DepKey: Integer;               {подразделение}
      Debet, Kredit: String6;        {дебет, кредит}
      DebetKAU, KreditKAU: String32; {КАУ по дебету и кредиту}
      aValue: Double;                {Сумма}
      OperName: String;              {Наименование операции}
      ColUnits: array of TColUnit;   {Количественные показатели (наименовагния)}
      ColValues: array of Double    {Количественные показатели (суммы)}
      );
  end;

type
  TxEmplProv = class(TComponent)
  private
    FActive: Boolean;
    FEmplKey: Integer;
    FCode: Integer;

    FEmplProv: TTable;

    function GetDebet: String;
    function GetDebetKAU: String;
    function GetKredit: String;
    function GetKreditKAU: String;

    procedure SetActive(Value: Boolean);
  public
    constructor Create(anOwner: TComponent); override;
    destructor Destroy; override;

    property Active: Boolean read FActive write SetActive;

    property EmplKey: Integer read FEmplKey write FEmplKey;
    property Code: Integer read FCode write FCode;

    property Debet: String read GetDebet;
    property DebetKAU: String read GetDebetKAU;

    property Kredit: String read GetKredit;
    property KreditKAU: String read GetKreditKAU;
  end;

procedure Register;

implementation

{ ---- TxPushWageProv ---- }
constructor TxPushWageProv.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);

  WageProv := TTable.Create(Self);
  WageProv.DatabaseName := 'WAGE';
  WageProv.TableName := 'wageprov.db';
  WageProv.IndexFieldNames := 'EmplKey;RegKey;SubReg';
  WageProv.Open;

  StProv := TTable.Create(Self);
  StProv.DatabaseName := 'WAGE';
  StProv.TableName := 'stprov.db';
  StProv.IndexFieldNames := 'Code';
  StProv.Open;

  xBookkeep := TxBookkeep.Create(Self);
  xBookkeep.StopKAU := [kauPeople];
end;

destructor TxPushWageProv.Destroy;
begin
  WageProv.Close;
  WageProv.Free;

  StProv.Close;
  StProv.Free;

  xBookkeep.Free;

  inherited Destroy;
end;

procedure TxPushWageProv.DelRegSubReg(RegKey, SubRegKey: Integer);
var
  OldIndexFieldNames: String;
begin
  OldIndexFieldNames := WageProv.IndexFieldNames;
  WageProv.Close;
  WageProv.IndexFieldNames := 'RegKey;SubReg';
  WageProv.Open;

  while WageProv.FindKey([RegKey, SubRegKey]) do WageProv.Delete;

  WageProv.Close;
  WageProv.IndexFieldNames := OldIndexFieldNames;
  WageProv.Open;
end;

procedure TxPushWageProv.PushProv(
  Codes: array of Integer;
  ADate: TDateTime;
  DepKey: Integer;
  Debet, Kredit: String6;
  DebetKAU, KreditKAU: String32;
  aValue: Double;
  OperName: String;
  ColUnits: array of TColUnit;
  ColValues: array of Double);

var
  I: Integer;
  isConstType: Boolean;

begin
  isConstType := False;

  {Определить индекс и удалить проводки}
  case High(Codes) of
    0: while WageProv.FindKey([Codes[0]]) do WageProv.Delete;
    1: while WageProv.FindKey([Codes[0], Codes[1]]) do WageProv.Delete;
    2: while WageProv.FindKey([Codes[0], Codes[1], Codes[2]]) do WageProv.Delete;
    3: while WageProv.FindKey([Codes[0], Codes[1], Codes[2], Codes[3]]) do WageProv.Delete;
    else Exit;
  end;

  {if High(Codes) in [0, 1, 2] then while WageProv.FindKey(Codes) do WageProv.Delete
  else Exit;}

  if AValue = 0 then Exit;
  {Добавить проводки}
  WageProv.Insert;
  for I := Low(Codes) to High(Codes) do
  begin
    case I of
      0:
        WageProv.FieldByName('EmplKey').AsInteger := Codes[0];
      1:
      begin
        WageProv.FieldByName('RegKey').AsInteger := Codes[1];
        isConstType := StProv.FindKey([WageProv.FieldByName('RegKey').AsInteger]);
      end;
      2:
        WageProv.FieldByName('SubReg').AsInteger := Codes[2];
      3:
        WageProv.FieldByName('FourthKey').AsInteger := Codes[3];
    end;
  end;
  WageProv.FieldByName('WorkDate').AsDateTime := ADate;
  WageProv.FieldByName('DepKey').AsInteger := DepKey;

  WageProv.FieldByName('Debet').AsString := Debet;
  WageProv.FieldByName('DebetKAU').AsString := DebetKAU;
  WageProv.FieldByName('Kredit').AsString := Kredit;
  WageProv.FieldByName('KreditKAU').AsString := KreditKAU;

  {Проверить: проводка зашита или нет}
  if isConstType and ((Debet = '') or (Kredit = '')) then
  begin
    WageProv.FieldByName('Debet').AsString := StProv.FieldByName('Debet').AsString;
    WageProv.FieldByName('DebetKAU').AsString := StProv.FieldByName('DebetKAU').AsString;
    WageProv.FieldByName('Kredit').AsString := StProv.FieldByName('Kredit').AsString;
    WageProv.FieldByName('KreditKAU').AsString := StProv.FieldByName('KreditKAU').AsString;
  end;

  WageProv.FieldByName('ProvSum').AsFloat := AValue;
  WageProv.FieldByName('OperName').AsString := OperName;

  {Количественные показатели}
  for I := Low(ColUnits) to High(ColUnits) do
  begin
    case ColUnits[I] of
      cu_Day: WageProv.FieldByName('Day').AsFloat := ColValues[I];
      cu_Hour: WageProv.FieldByName('Hour').AsFloat := ColValues[I];
      cu_Tkm: WageProv.FieldByName('TKM').AsFloat := ColValues[I];
      cu_CG: WageProv.FieldByName('CG').AsFloat := ColValues[I];
      cu_GSM: WageProv.FieldByName('Expense').AsFloat := ColValues[I];
    end;
  end;

  WageProv.Post;
end;


{---------- TxEmplProv}
constructor TxEmplProv.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FEmplProv := TTable.Create(Self);
  FEmplProv.DatabaseName := 'WAGE';
  FEmplProv.TableName := 'EmplProv.db';
  FEmplProv.IndexFieldNames := 'EmplKey';

  FActive := False;
  FEmplKey := -1;
  FCode := -1;
end;

destructor TxEmplProv.Destroy;
begin
  if Assigned(FEmplProv) then
  begin
    FEmplProv.Close;
    FEmplProv.Free;
  end;

  inherited Destroy;
end;

procedure TxEmplProv.SetActive(Value: Boolean);
begin
  if FEmplProv.Active <> Value then
    FEmplProv.Active := Value;
end;

function TxEmplProv.GetDebet: String;
begin
  Result := '';
  if FEmplProv.FindKey([FEmplKey]) then
    case FCode of
      0: Result := FEmplProv.FieldByName('Debet').AsString;
      1: Result := FEmplProv.FieldByName('ITDebet').AsString;
      2: Result := FEmplProv.FieldByName('VetDebet').AsString;
      3: Result := FEmplProv.FieldByName('TUDebet').AsString;
    end;
end;

function TxEmplProv.GetDebetKAU: String;
begin
  Result := '';
  if FEmplProv.FindKey([FEmplKey]) then
    case FCode of
      0: Result := FEmplProv.FieldByName('DebetKAU').AsString;
      1: Result := FEmplProv.FieldByName('ITDebetKAU').AsString;
      2: Result := FEmplProv.FieldByName('VetDebetKAU').AsString;
      3: Result := FEmplProv.FieldByName('TUDebetKAU').AsString;
    end;
end;

function TxEmplProv.GetKredit: String;
begin
  Result := '';
  if FEmplProv.FindKey([FEmplKey]) then
    case FCode of
      0: Result := FEmplProv.FieldByName('Kredit').AsString;
      1: Result := FEmplProv.FieldByName('ITKredit').AsString;
      2: Result := FEmplProv.FieldByName('VetKredit').AsString;
      3: Result := FEmplProv.FieldByName('TUKredit').AsString;
    end;
end;

function TxEmplProv.GetKreditKAU: String;
begin
  Result := '';
  if FEmplProv.FindKey([FEmplKey]) then
    case FCode of
      0: Result := FEmplProv.FieldByName('KreditKAU').AsString;
      1: Result := FEmplProv.FieldByName('ITKreditKAU').AsString;
      2: Result := FEmplProv.FieldByName('VetKreditKAU').AsString;
      3: Result := FEmplProv.FieldByName('TUKreditKAU').AsString;
    end;
end;

procedure Register;
begin
  RegisterComponents('xWage', [TxEmplProv]);
  RegisterComponents('xWage', [TxPushWageProv]);
end;

end.

