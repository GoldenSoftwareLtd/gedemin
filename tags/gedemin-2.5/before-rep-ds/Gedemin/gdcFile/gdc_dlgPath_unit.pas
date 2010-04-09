unit gdc_dlgPath_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dmImages_unit, ActnList, StdCtrls, ExtCtrls, FileCtrl;

type
  Tgdc_dlgPath = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnNext: TButton;
    btnCancel: TButton;
    ActionList1: TActionList;
    Label1: TLabel;
    edPath: TEdit;
    btnSelectDirectory: TButton;
    actSelectDirectory: TAction;
    edFullPath: TEdit;
    procedure actSelectDirectoryExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgPath: Tgdc_dlgPath;

implementation

{$R *.DFM}

procedure Tgdc_dlgPath.actSelectDirectoryExecute(Sender: TObject);
var
  Path: String;
begin
  Path := edPath.Text;
  if SelectDirectory(Path, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then
    edPath.Text := Path;
end;

end.
