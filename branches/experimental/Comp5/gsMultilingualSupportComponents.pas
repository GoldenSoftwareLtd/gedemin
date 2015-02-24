unit gsMultilingualSupportComponents;

interface

uses Classes, gsMultilingualSupport;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gsNV', [TgsMultilingualBase]);
  RegisterComponents('gsNV', [TgsMultilingualSupport]);
end;

end.
