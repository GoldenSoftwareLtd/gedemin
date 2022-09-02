// ShlTanya, 26.02.2019

unit dm_i_ClientReport_unit;

interface

uses
  gd_KeyAssoc;

type
  IdmClientReport = interface(IDispatch)
//    procedure CreateGlObjArray;
//    procedure CreateVBConst;
//    procedure CreateVBClasses;
    function  GetStaticSFList: TgdKeyArray;

    procedure CreateGlobalSF;

    procedure DoConnect;
    procedure DoDisconnect;
  end;

var
  dm_i_ClientReport: IdmClientReport;

implementation

Initialization
  dm_i_ClientReport := nil;

end.
