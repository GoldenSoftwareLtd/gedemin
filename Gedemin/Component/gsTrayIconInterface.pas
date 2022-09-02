// ShlTanya, 20.02.2019

unit gsTrayIconInterface;

interface

type
  IgsTrayIcon = interface
    ['{755C69A2-42F6-11D5-B4A9-0060520A1991}']

    function GetToolTip: String;
    procedure SetToolTip(const Value: String);

    property ToolTip: String read GetToolTip write SetToolTip;
  end;

{ only one tray icon per project now is allowed }  
var
  TrayIcon: IgsTrayIcon;  

implementation

end.
 