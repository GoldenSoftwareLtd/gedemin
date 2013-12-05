unit gdc_dlgNamespacePos_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTRPC_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, DBCtrls,
  ExtCtrls, IBCustomDataSet, gdcBase, gdcNamespace, Grids, DBGrids,
  gsDBGrid, gsIBGrid, gsIBLookupComboBox, TB2Dock, TB2Toolbar,
  at_Container, ComCtrls, TB2Item;

type
  Tgdc_dlgNamespacePos = class(Tgdc_dlgTRPC)
    gdcNSDependent: TgdcNamespaceObject;
    dsNSDependent: TDataSource;
    actShowObject: TAction;
    Label2: TLabel;
    ibgr: TgsIBGrid;
    lName: TLabel;
    dbtxtName: TDBText;
    Label1: TLabel;
    iblkupNamespace: TgsIBLookupComboBox;
    Label3: TLabel;
    iblkupHeadObject: TgsIBLookupComboBox;
    dbchbxalwaysoverwrite: TDBCheckBox;
    dbchbxdontremove: TDBCheckBox;
    dbchbxincludesiblings: TDBCheckBox;
    btnShowObject: TButton;
    tsNS: TTabSheet;
    tbNS: TTBToolbar;
    ibgrNS: TgsIBGrid;
    ibdsNS: TIBDataSet;
    dsNS: TDataSource;
    actDeleteFromNS: TAction;
    TBItem1: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actShowObjectExecute(Sender: TObject);
    procedure actShowObjectUpdate(Sender: TObject);
    procedure pgcMainChange(Sender: TObject);
    procedure actDeleteFromNSUpdate(Sender: TObject);
    procedure actDeleteFromNSExecute(Sender: TObject);
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

procedure Tgdc_dlgNamespacePos.pgcMainChange(Sender: TObject);
begin
  inherited;

  if pgcMain.ActivePage = tsNS then
  begin
    if (gdcObject <> nil) and (not gdcObject.EOF) then
    begin
      ibdsNS.Close;
      ibdsNS.ParamByName('xid').AsInteger := gdcObject.FieldByName('xid').AsInteger;
      ibdsNS.ParamByName('dbid').AsInteger := gdcObject.FieldByName('dbid').AsInteger;
      ibdsNS.Open;
    end;
  end;
end;

procedure Tgdc_dlgNamespacePos.actDeleteFromNSUpdate(Sender: TObject);
begin
  actDeleteFromNS.Enabled := (gdcObject <> nil)
    and (not gdcObject.EOF)
    and ibdsNS.Active
    and (not ibdsNS.EOF)
    and (ibdsNS.FieldByName('objectid').AsInteger <> gdcObject.ID);
end;

procedure Tgdc_dlgNamespacePos.actDeleteFromNSExecute(Sender: TObject);
begin
  ibdsNS.Delete;
end;

initialization
  RegisterFRMClass(Tgdc_dlgNamespacePos);

finalization
  UnRegisterFRMClass(Tgdc_dlgNamespacePos);
end.
