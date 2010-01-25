
unit xTblCnvr;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ConvForm;

type
  TxTblData = class
    FOrderNum: String;
    FListNum: String;
    FFullName: String;
    FDays: Double;
    FHours: Double;
  public
    property OrderNum: String read FOrderNum write FOrderNum;
    property ListNum: String read FListNum write FListNum;
    property FullName: String read FFullName write FFullName;
    property Days: Double read FDays write FDays;
    property Hours: Double read FHours write FHours;
  end;

type
  TxTblConvert = class(TComponent)
  private
    FEmployeeList: TList;
  protected
    { Protected declarations }

  public
    constructor Create(anOwner: TComponent); override;
    destructor Destroy; override;
    function Execute: Boolean;
    procedure FillList;

    property EmployeeList: TList read FEmployeeList;

  published
    { Published declarations }
  end;

procedure Register;

implementation

{ CREATE }
constructor TxTblConvert.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);
  FEmployeeList := TList.Create;
end;

{ DESTROY }
destructor TxTblConvert.Destroy;
var
  I: Integer;
begin
  for I := 0 to FEmployeeList.Count - 1 do
    TxTblData(FEmployeeList[I]).Free;
  FEmployeeList.Free;

  inherited Destroy;
end;

{ FILL_LIST }
procedure TxTblConvert.FillList;
var
  xTblData: TxTblData;
  I: Integer;
begin
  for I := 0 to FEmployeeList.Count - 1 do
    TxTblData(FEmployeeList[I]).Free;
  FEmployeeList.Clear;

  frmConvert.MemTable.First;
  with frmConvert do
  begin
    MemTable.First;
    while not MemTable.EOF do
    begin
      xTblData := TxTblData.Create;
      xTblData.OrderNum := OrderNum;
      xTblData.ListNum := MemTableListNum.Value;
      xTblData.FullName := MemTableFullName.Value;
      xTblData.Days := StrToFloat(MemTableDays.Value);
      xTblData.Hours := StrToFloat(MemTableHours.Value);

      FEmployeeList.Add(xTblData);

      MemTable.Next;
    end;
  end;
end;

{ EXECUTE }
function TxTblConvert.Execute: Boolean;
begin
  frmConvert := TfrmConvert.Create(Self);
  try
    Result := False;
    case frmConvert.ShowModal of
      mrOk:
      begin
        FillList;
        Result := True;
      end;
      mrCancel:
        Result := False;
    end;
  finally
    frmConvert.Free;
  end;
end;

{ REGISTER }
procedure Register;
begin
  RegisterComponents('xWage', [TxTblConvert]);
end;

end.











