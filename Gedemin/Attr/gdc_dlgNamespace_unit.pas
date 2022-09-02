// ShlTanya, 03.02.2019

unit gdc_dlgNamespace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, at_Container, DBCtrls,
  StdCtrls, ComCtrls, Mask, SynEdit, SynDBEdit;

type
  Tgdc_dlgNamespace = class(Tgdc_dlgTRPC)
    Label1: TLabel;
    dbedName: TDBEdit;
    Label2: TLabel;
    dbedCaption: TDBEdit;
    Label3: TLabel;
    dbedFileName: TDBEdit;
    Label4: TLabel;
    Label5: TLabel;
    dbedFileTimestamp: TDBEdit;
    dbedVersion: TDBEdit;
    dbedDBVersion: TDBEdit;
    Label6: TLabel;
    dbchbxOptional: TDBCheckBox;
    dbchbxInternal: TDBCheckBox;
    dbmComment: TDBMemo;
    Label7: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgNamespace: Tgdc_dlgNamespace;

implementation

{$R *.DFM}

uses
  gd_ClassList;

initialization
  RegisterFRMClass(Tgdc_dlgNamespace);

finalization
  UnRegisterFRMClass(Tgdc_dlgNamespace);
end.
