unit Ditron_Unit;

interface

uses
  ComObj, ActiveX, gsDRV_TLB, StdVcl, OleCtrls, COECRCOMLib_TLB, SysUtils, Dialogs;

type
  TDitronEU200CS = class(TAutoObject, IDitronEU200CS)
  private
    CoEcrCom1: TCoEcrCom;
  protected
    { Protected declarations }
    function Get_ResultCode: SYSINT; safecall;
    function Close: SYSINT; safecall;
    function EcrCMD(const Command: WideString; out ResStr: WideString): SYSINT;
      safecall;
    function Open(const Options: WideString): SYSINT; safecall;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ;

procedure TDitronEU200CS.Initialize;
begin
  inherited;

  CoEcrCom1 := TCoEcrCom.Create(nil);
end;

destructor TDitronEU200CS.Destroy;
begin
  FreeAndNil(CoEcrCom1);

  inherited;
end;

function TDitronEU200CS.Open(const Options: WideString): SYSINT;
begin
  result := CoEcrCom1.Open(Options);
end;

function TDitronEU200CS.Close: SYSINT;
begin
  result := CoEcrCom1.Close;
end;

function TDitronEU200CS.EcrCMD(const Command: WideString;
  out ResStr: WideString): SYSINT;
begin
  result := CoEcrCom1.EcrCMD(Command, ResStr);
end;

function TDitronEU200CS.Get_ResultCode: SYSINT;
begin
  result := CoEcrCom1.ResultCode;
end;



initialization
  TAutoObjectFactory.Create(ComServer, TDitronEU200CS, Class_DitronEU200CS,
    ciMultiInstance, tmApartment);
end.
