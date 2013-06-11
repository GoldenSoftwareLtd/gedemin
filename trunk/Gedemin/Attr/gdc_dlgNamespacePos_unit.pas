unit gdc_dlgNamespacePos_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, DBCtrls,
  ExtCtrls, IBCustomDataSet, gdcBase, gdcNamespace, Grids, DBGrids,
  gsDBGrid, gsIBGrid, gsIBLookupComboBox;

type
  Tgdc_dlgNamespacePos = class(Tgdc_dlgTR)
    Panel1: TPanel;
    lName: TLabel;
    dbchbxalwaysoverwrite: TDBCheckBox;
    dbchbxdontremove: TDBCheckBox;
    dbchbxincludesiblings: TDBCheckBox;
    dbtxtName: TDBText;
    gdcNSDependent: TgdcNamespaceObject;
    dsNSDependent: TDataSource;
    ibgr: TgsIBGrid;
    iblkupNamespace: TgsIBLookupComboBox;
    Label1: TLabel;
    Label2: TLabel;
    iblkupHeadObject: TgsIBLookupComboBox;
    Label3: TLabel;
    btnShowObject: TButton;
    actShowObject: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actShowObjectExecute(Sender: TObject);
    procedure actShowObjectUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgNamespacePos: Tgdc_dlgNamespacePos;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_dlgNamespacePos.FormCreate(Sender: TObject);
begin
  inherited;
  gdcNSDependent.Open;
end;

procedure Tgdc_dlgNamespacePos.actShowObjectExecute(Sender: TObject);
begin
  (gdcObject as TgdcNamespaceObject).ShowObject;
end;

procedure Tgdc_dlgNamespacePos.actShowObjectUpdate(Sender: TObject);
begin
  actShowObject.Enabled := gdcObject <> nil;
end;

initialization
  RegisterFRMClass(Tgdc_dlgNamespacePos);

finalization
  UnRegisterFRMClass(Tgdc_dlgNamespacePos);
end.
