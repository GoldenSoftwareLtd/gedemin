// ShlTanya, 24.02.2019

unit gdc_dlgRplDomainClass_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask;

type
  Tgdc_dlgRplDomainClass = class(Tgdc_dlgTRPC)
    DBEdit1: TDBEdit;
    Label1: TLabel;
    DBEdit2: TDBEdit;
    Label2: TLabel;
    Label3: TLabel;
    DBEdit3: TDBEdit;
    Label4: TLabel;
    DBEdit4: TDBEdit;
    Label5: TLabel;
    DBEdit5: TDBEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgRplDomainClass: Tgdc_dlgRplDomainClass;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgRplDomainClass);

finalization
  UnRegisterFrmClass(Tgdc_dlgRplDomainClass);
end.
