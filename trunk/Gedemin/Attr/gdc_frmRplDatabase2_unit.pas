unit gdc_frmRplDatabase2_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit;

type
  Tgdc_frmRplDatabase2 = class(Tgdc_frmSGR)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmRplDatabase2: Tgdc_frmRplDatabase2;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_frmRplDatabase2);

finalization
  UnRegisterFrmClass(Tgdc_frmRplDatabase2);
end.
