// ShlTanya, 25.02.2019

unit prp_dlgEventComent_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TdlgEventComent = class(TForm)
    eComent: TEdit;
    bCancel: TButton;
    bOk: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgEventComent: TdlgEventComent;

implementation

{$R *.DFM}

end.
