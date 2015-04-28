unit gdc_dlgRplDatabase2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit;

type
  Tgdc_dlgRplDatabase2 = class(Tgdc_dlgG)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgRplDatabase2: Tgdc_dlgRplDatabase2;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgRplDatabase2);

finalization
  UnRegisterFrmClass(Tgdc_dlgRplDatabase2);
end.
