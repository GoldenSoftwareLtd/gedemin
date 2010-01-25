
unit gsAbout;

interface

uses Classes, gsAboutBase;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gsNV', [TgsAbout]);
end;

end.
