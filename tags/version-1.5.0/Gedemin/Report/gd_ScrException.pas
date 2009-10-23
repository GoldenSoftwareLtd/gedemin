unit gd_ScrException;

interface

uses
  contnrs, sysutils;

type
  TOnCreateObject = procedure(Sender: TObject) of object;

  CException = class of Exception;
  
{  ESingleException = class
  private
    FExcClass: String;
    FEMessage: String;
  public
    property ExcClass: String read FExcClass write FExcClass;
    property EMessage: String read FEMessage write FEMessage;
  end;        }

  EScrException = class
  private
    FEMessage: String;
    FExcClass: String;
  public
    constructor Create;

    procedure AddRaise(ARaise: String; AnEMessage: String);
    procedure DelRaise;
    procedure GetException;

    property ExcClass: String read FExcClass write FExcClass;
    property EMessage: String read FEMessage write FEMessage;
  end;

  // Анализирует Исключение и создает гл.объект хранящий это Исключение
  // Используется для передачи исключений, возникших в Делфи, через скрипт назат в Делфи
  function  ExceptionCopier(const E: Exception): Exception;

var
  gdScrException: Exception;

implementation

uses
  IB;

{ EScrException }

function  ExceptionCopier(const E: Exception): Exception;
begin
  Result := nil;
  if E = nil then
    Exit;

  if E.InheritsFrom(EIBError) then
  begin
    Result := EIBError.Create(EIBError(E).SQLCode,
      EIBError(E).IBErrorCode, EIBError(E).Message);
  end else
    begin
      // создаем глобальный объект того-же типа, что и возникшее исключение
      Result := CException(E.ClassType).Create(E.Message);
    end;
end;

procedure EScrException.AddRaise(ARaise, AnEMessage: String);
begin
  if Trim(ARaise) = '' then
    Exit;

  FExcClass := ARaise;
  FEMessage := AnEMessage;
  GetException;
  raise Exception.Create('В Execute.raise передан неизвестный класс исключения - ' + Trim(FExcClass) + '.');
end;

constructor EScrException.Create;
begin
  inherited Create;

  DelRaise;
end;

procedure EScrException.DelRaise;
begin
  FEMessage := '';
  FExcClass := '';
end;

procedure EScrException.GetException;
var
  S: String;
begin
  if Length(Trim(FEMessage)) = 0 then FEMessage := ' ';
  S := UpperCase(Trim(FExcClass));
  if S = 'EABORT' then
    raise EAbort.Create(FEMessage)
  else if S = 'EDIVBYZERO' then
    raise EDivByZero.Create(FEMessage)
  else if S = 'EXCEPTION' then
    raise Exception.Create(FEMessage);
end;

initialization

finalization
  if Assigned(gdScrException) then
    FreeAndNil(gdScrException);

end.
