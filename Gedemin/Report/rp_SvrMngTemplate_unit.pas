// ShlTanya, 27.02.2019

unit rp_SvrMngTemplate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  TSvrMngTemplate = class(TForm)
    btnClose: TButton;
    btnProperty: TButton;
    btnDisconnect: TButton;
    ActionList1: TActionList;
    actClose: TAction;
    btnRefresh: TButton;
    btnRebuild: TButton;
    btnConnectParam: TButton;
    btnRun: TButton;
    btnClear: TButton;
  private
  public
  end;

var
  SvrMngTemplate: TSvrMngTemplate;

implementation

{$R *.DFM}

end.
