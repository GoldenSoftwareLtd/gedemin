{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgVariablesList_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgVariablesList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst, gd_createable_form;

type
  Tctl_dlgVariablesList = class(TCreateableForm)
    btnClose: TButton;
    btnOk: TButton;
    cblVariables: TCheckListBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ctl_dlgVariablesList: Tctl_dlgVariablesList;

implementation

{$R *.DFM}

end.
