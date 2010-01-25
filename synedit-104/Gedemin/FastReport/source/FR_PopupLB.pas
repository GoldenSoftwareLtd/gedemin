unit FR_PopupLB;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrPopupListBox = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
    ListBox: TListBox;
    constructor Create(AOwner: TComponent); override;
    procedure _Deactivate(Sender: TObject);
  end;


implementation

{$R *.DFM}

constructor TfrPopupListBox.Create(AOwner: TComponent);
begin
  inherited Create(nil);
  BorderStyle := bsNone;
//  OnDeactivate := _Deactivate;
  ListBox := TListBox.Create(Self);
  with ListBox do
  begin
    Parent := Self;
    Ctl3D := False;
    IntegralHeight := True;
    ItemHeight := 11;
  end;
end;

procedure TfrPopupListBox._Deactivate(Sender: TObject);
begin
//  Hide;
end;

end.
