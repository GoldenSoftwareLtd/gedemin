unit rpl_GlobalVars_unit;

interface

uses Classes, IB, IBErrorCodes, SysUtils, Controls;

var
  //Тру указывает на необходимость задавать всякие глупые вопросы пользователю
  gvAskQuestion, gvAskQuestionBack: Boolean;
  gvAskQuestionResult: TModalResult;
  gvNodeClicked: string;

const
  StreamVersion = 3;
function Errors: TStrings;
function IsForegnKeyError(E: Exception): boolean;

implementation

var
  _Errors: TStrings;

function Errors: TStrings;
begin
  if _Errors = nil then
    _Errors := TStringList.Create;

  Result := _Errors;
end;

function IsForegnKeyError(E: Exception): boolean;
begin
  Result:= (E is EIBError) and (EIBError(E).IBErrorCode = isc_foreign_key);
end;

initialization
  gvAskQuestion := True;
  gvAskQuestionBack := True;
  gvAskQuestionResult:= mrYes;

finalization
  _Errors.Free;

end.
