{ Unit used by xBasics to input strings }
unit xReadStr;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls;

type
  TReadStrForm = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Comment: TMemo;
    Edit: TEdit;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReadStrForm: TReadStrForm;

implementation

{$R *.DFM}

procedure TReadStrForm.FormActivate(Sender: TObject);
begin
  Edit.SetFocus;
end;

end.
