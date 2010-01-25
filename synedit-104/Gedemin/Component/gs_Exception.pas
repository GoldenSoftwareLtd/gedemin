unit gs_Exception;

interface

function GetGsException(AnObject: TObject; const AnMessage: String): String;

implementation

function GetGsException(AnObject: TObject; const AnMessage: String): String;
begin
  Result := AnObject.ClassName + ': ' + AnMessage;
end;

end.
 