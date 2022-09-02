// ShlTanya, 09.02.2019

unit gdc_dlgSelectObject_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, dmDatabase_unit, ActnList, StdCtrls,
  gsIBLookupComboBox, IBDatabase;

type
  Tgdc_dlgSelectObject = class(TCreateableForm)
    btnOk: TButton;
    btnCancel: TButton;
    lkup: TgsIBLookupComboBox;
    lMessage: TLabel;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    IBTransaction: TIBTransaction;
    actHelp: TAction;
    btnHelp: TButton;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgSelectObject: Tgdc_dlgSelectObject;

implementation

{$R *.DFM}

  {$IFDEF LOCALIZATION}
uses
  {must be placed after Windows unit!}
  gd_localization_stub
  ;
  {$ENDIF}

procedure Tgdc_dlgSelectObject.actOkExecute(Sender: TObject);
begin

  if lkup.CurrentKey = '' then
    SetFocusedControl(btnOk);

  if lkup.CurrentKey = '' then
  begin
    MessageBox(Handle,
      'Необходимо выбрать объект в списке!',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION);
  end else
    ModalResult := mrOk;
end;

procedure Tgdc_dlgSelectObject.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgdc_dlgSelectObject.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
