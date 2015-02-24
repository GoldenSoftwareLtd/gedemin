
unit st_dlgeditvalue_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, gd_createable_form, ActnList, Buttons;

type
  Tst_dlgeditvalue = class(TCreateableForm)      
    Label1: TLabel;
    edName: TEdit;
    Label2: TLabel;
    edValue: TEdit;
    ActionList1: TActionList;
    actOk: TAction;
    rg: TRadioGroup;
    btnHelp: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    actHelp: TAction;
    lblID: TLabel;
    edID: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actOkUpdate(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
  end;

var
  st_dlgeditvalue: Tst_dlgeditvalue;

implementation

{$R *.DFM}

procedure Tst_dlgeditvalue.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult = mrNone then
    ModalResult := mrCancel;
end;

procedure Tst_dlgeditvalue.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := Trim(edName.Text) > '';
end;

procedure Tst_dlgeditvalue.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
