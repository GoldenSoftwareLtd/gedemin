unit at_dlgNamespaceOp_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls;

type
  Tat_dlgNamespaceOp = class(TForm)
    lblObject: TLabel;
    rbDelete: TRadioButton;
    rbMoveAdd: TRadioButton;
    Button1: TButton;
    ActionList: TActionList;
    actOk: TAction;
    Button2: TButton;
    actCancel: TAction;
    rbChange: TRadioButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  at_dlgNamespaceOp: Tat_dlgNamespaceOp;

implementation

{$R *.DFM}

end.
