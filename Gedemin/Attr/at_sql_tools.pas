// ShlTanya, 02.02.2019

unit at_sql_tools;

interface

uses
  Windows, SysUtils, Classes, Contnrs, at_sql_parser, at_classes, gdcBase,
  IBDatabase;

type
  TgdcClassHandler = class
  private
    FClass: CgdcBase;
    FIBBase: TIBBase;

    function GetDisplayName: String;
    function GetName: String;

    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);

  protected

  public
    constructor Create(AClass: CgdcBase;
      ADatabase: TIBDatabase; ATransaction: TIBTransaction);
    destructor Destroy; override;

    function GetSubTypes(SubTypes: TStringList): Boolean;

    property gdcClassName: String read GetName;
    property gdcDisplayName: String read GetDisplayName;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;

  end;


implementation

{ TgdcClassHandler }

constructor TgdcClassHandler.Create(AClass: CgdcBase;
  ADatabase: TIBDatabase; ATransaction: TIBTransaction);
begin
  FClass := AClass;
  FIBBase := TIBBase.Create(nil);

  FIBBase.Database := ADatabase;
  FIBBase.Transaction := ATransaction;
end;

destructor TgdcClassHandler.Destroy;
begin
  FIBBase.Free;
  inherited;
end;

function TgdcClassHandler.GetDatabase: TIBDatabase;
begin
  Result := FIBBase.Database;
end;

function TgdcClassHandler.GetDisplayName: String;
begin
  { TODO 1 -oденис -cсделать : Разобраться с подтипом }
  try
    Result := FClass.GetDisplayName('');
  except
  { TODO 1 -oMikle -cсделать : Разобраться с абстрактными классами }
  end;  
end;

function TgdcClassHandler.GetName: String;
begin
  Result := FClass.ClassName;
end;

function TgdcClassHandler.GetSubTypes(SubTypes: TStringList): Boolean;
begin
  Result := FClass.GetSubTypeList(SubTypes);
end;

function TgdcClassHandler.GetTransaction: TIBTransaction;
begin
  Result := FIBBase.Transaction;
end;

procedure TgdcClassHandler.SetDatabase(const Value: TIBDatabase);
begin
  FIBBase.Database := Value;
end;

procedure TgdcClassHandler.SetTransaction(const Value: TIBTransaction);
begin
  FIBBase.Transaction := Value;
end;

end.

