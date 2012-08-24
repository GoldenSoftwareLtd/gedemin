
unit gd_dlgDeleteDesktop_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  Tgd_dlgDeleteDesktop = class(TForm)
    lb: TListBox;
    btnDelete: TButton;
    btnClose: TButton;
    ActionList: TActionList;
    actDelete: TAction;
    Label1: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_dlgDeleteDesktop: Tgd_dlgDeleteDesktop;

implementation

{$R *.DFM}

uses
  gsDesktopManager;

procedure Tgd_dlgDeleteDesktop.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure Tgd_dlgDeleteDesktop.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  lb.Clear;
  for I := 0 to DesktopManager.DesktopCount - 1 do
    lb.Items.Add(DesktopManager.DesktopNames[I]);
  lb.ItemIndex := 0;
end;

procedure Tgd_dlgDeleteDesktop.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := (lb.ItemIndex >= 0) and (lb.ItemIndex < lb.Items.Count);
end;

procedure Tgd_dlgDeleteDesktop.actDeleteExecute(Sender: TObject);
var
  K: Integer;
begin
  K := lb.ItemIndex;
  DesktopManager.DeleteDesktop(lb.Items[K]);
  lb.Items.Delete(K);
  if lb.Items.Count > 0 then
    if K >= lb.Items.Count then
      lb.ItemIndex := lb.Items.Count - 1
    else
      lb.ItemIndex := K;
end;

end.
