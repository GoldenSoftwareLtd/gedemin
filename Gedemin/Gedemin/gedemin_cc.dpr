program gedemin_cc;





{$R '..\Component\indy\Indy50.res' '..\Component\indy\Indy50.rc'}

uses
  Forms,
  frm_gedemin_cc_unit in 'frm_gedemin_cc_unit.pas' {frm_gedemin_cc_main};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Tfrm_gedemin_cc_main, frm_gedemin_cc_main);
  Application.Run;
end.
