
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

implementation

end.
 