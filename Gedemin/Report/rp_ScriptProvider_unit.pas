// ShlTanya, 27.02.2019

unit rp_ScriptProvider_unit;

interface

uses
  boScriptControl, obj_IBQuery_unit, IBDatabase;

type
  TReportProvider = class(TScriptObjectProvider)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FcoQueryList: TQueryList;

  protected
    procedure CreateObjects; override;
    procedure AfterDeleteObjects; override;

  public
    constructor Create(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction);
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils;

{ TReportProvider }

procedure TReportProvider.AfterDeleteObjects;
begin
  FcoQueryList := nil;
end;

constructor TReportProvider.Create(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction);
begin
  inherited Create;

  FDatabase := AnDatabase;
  FTransaction := AnTransaction;
  FcoQueryList := nil;
end;

procedure TReportProvider.CreateObjects;
begin
  FcoQueryList := TQueryList.Create(FDatabase, FTransaction);
  AddObject('QueryList', FcoQueryList);
end;

destructor TReportProvider.Destroy;
begin
  if Assigned(FcoQueryList) then
    FreeAndNil(FcoQueryList);

  inherited;
end;

end.


