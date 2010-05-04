
unit gd_dlgDesktopName_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  Tgd_dlgDesktopName = class(TForm)
    cb: TComboBox;
    btnOk: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_dlgDesktopName: Tgd_dlgDesktopName;

implementation

{$R *.DFM}

uses
  gsDesktopManager
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

procedure Tgd_dlgDesktopName.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  cb.Clear;
  if Assigned(DesktopManager) then
    for I := 0 to DesktopManager.DesktopCount - 1 do
      cb.Items.Add(DesktopManager.DesktopNames[I]);
  cb.Text := DesktopManager.CurrentDesktopName;
end;

procedure Tgd_dlgDesktopName.btnOkClick(Sender: TObject);
begin
  if DesktopManager.FindDesktop(cb.Text) >= 0 then
    if MessageBox(Handle,
      PChar(Format('Рабочий стол с именем "%s" уже существует. Заменить его?', [cb.Text])),
      'Внимание',
      MB_ICONQUESTION or MB_YESNO) = IDNO then exit;
  ModalResult := mrOk;
end;

end.
