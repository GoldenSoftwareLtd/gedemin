{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    03.06.03    tiptop        Initial version.
--}
unit wiz_dlgEntryCycleForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_dlgAccountCycleForm_unit, StdCtrls, ExtCtrls, Grids, DBGrids,
  gsDBGrid, gsIBGrid, BtnEdit, ComCtrls, Db, IBCustomDataSet, ActnList,
  Menus;

type
  TdlgEntryCycleForm = class(TdlgAccountCycleForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgEntryCycleForm: TdlgEntryCycleForm;

implementation

{$R *.DFM}

end.
