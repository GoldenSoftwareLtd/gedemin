unit xCommonOperation;

interface

uses SysUtils;

const
  taCustomer   = 10;
  taUserDefine = 2000;

function GetAnalyzeFromString(const S: String; var ValueID: Integer): Integer;  

implementation

function GetAnalyzeFromString(const S: String; var ValueID: Integer): Integer;
var
  PerS: String;
begin
  Result := -1;
  ValueID := -1;
  if Pos('=', S) > 0 then
  begin
    PerS := copy(S, 1, Pos('=', S) - 1);
    try
      Result := StrToInt(PerS);
    except
      Result := -1;
    end;
    PerS := copy(S, Pos('=', S) + 1, 255);
    try
      ValueID := StrToInt(PerS);
    except
      ValueID := -1;
    end;
  end;
end;


end.
