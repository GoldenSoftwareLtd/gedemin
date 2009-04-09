
unit gd_splash;

interface

type
  IgdSplash = interface
    procedure ShowSplash;
    procedure ShowText(const AText: String);
    procedure FreeSplash(const Immediately: Boolean = False);
  end;

var
  gdSplash: IgdSplash;
  NoSplashParam: Boolean;

implementation

{var
  I: Integer;}

uses
  SysUtils;  

initialization
  NoSplashParam := FindCmdLineSwitch('NS', ['/', '-'], True);

  {NoSplashParam := False;
  for I := 1 to ParamCount do
    if (ParamStr(I) = '/ns') or (ParamStr(I) = '/NS') then
    begin
      NoSplashParam := True;
      break;
    end;}
end.
 