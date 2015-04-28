
unit gdHelp_Interface;

interface

type
  IgdHelp = interface
    procedure ShowHelp(const ATopic: String); overload;
    procedure ShowHelp(const HelpContext: Integer); overload;
    procedure ShowHelp(const AFormClass, AFormSubType, AnObjClass, AnObjSubType: String); overload;
    function GetHelpText(const AFormClass, AFormSubType, AnObjClass, AnObjSubType: String): String;
    function ShowHelpText(const AFormClass, AFormSubType, AnObjClass, AnObjSubType: String): Boolean;
  end;

var
  gdHelp: IgdHelp;  

procedure ShowHelp(const ATopic: String);overload;
procedure ShowHelp(const HelpContext: Integer); overload;

implementation

procedure ShowHelp(const ATopic: String);
begin
  if Assigned(gdHelp) then
    gdHelp.ShowHelp(ATopic);
end;

procedure ShowHelp(const HelpContext: Integer);
begin
  if Assigned(gdHelp) then
    gdHelp.ShowHelp(HelpContext);
end;

initialization
  gdHelp := nil;
end.
 