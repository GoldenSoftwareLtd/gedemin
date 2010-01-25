unit prp_frmFromMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  prp_MainTestForm_unit, flt_sqlFilter, Menus, StdCtrls, OleCtrls,
  MSScriptControl_TLB, rp_ReportScriptControl, Db, DBClient, IBDatabase,
  IBCustomDataSet, IBQuery, syn_ManagerInterface_body_unit, ComCtrls,
  gd_ReportMenu, gd_MacrosMenu, ToolWin, gd_ClassList;

type
  TfrmFromMain = class(TMainTestForm)
    Edit2: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmFromMain: TfrmFromMain;
  //oleg_m
  Param: TgdcMethodParam;
  Method: TgdcMethod;

implementation

uses
  prp_i_MethodsList, TypInfo;

{$R *.DFM}

procedure TfrmFromMain.FormCreate(Sender: TObject);
begin
//
end;

procedure TfrmFromMain.FormDestroy(Sender: TObject);
begin
//
end;

initialization
  RegisterGdcClass(TfrmFromMain);

  Param := TgdcMethodParam.Create('Parameter', 'String', pfConst);
  try
    Method := TgdcMethod.Create('Hide', mkProcedure);
    try
      Method.AddParam(Param);

      RegisterGdcClassMethod(TfrmFromMain, Method);
    finally
      Method.Free;
    end;
  finally
    Param.Free;
  end;

end.
