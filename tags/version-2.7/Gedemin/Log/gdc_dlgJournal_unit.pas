unit gdc_dlgJournal_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, StdCtrls, Mask, DBCtrls, IBDatabase, Menus, Db, ActnList,
  gsIBLookupComboBox;

type
  Tgdc_dlgJournal = class(Tgdc_dlgTR)
    lDate: TLabel;
    dbedDate: TDBEdit;
    dbmData: TDBMemo;
    iblkupUser: TgsIBLookupComboBox;
    lUser: TLabel;
    lSource: TLabel;
    dbedSource: TDBEdit;
    dbedID: TDBEdit;
    lID: TLabel;
    lData: TLabel;
    ActionList: TActionList;
    actOpenObject: TAction;
    btnOpenObject: TButton;
    procedure actOpenObjectExecute(Sender: TObject);
    procedure actOpenObjectUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_dlgJournal: Tgdc_dlgJournal;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcJournal;

procedure Tgdc_dlgJournal.actOpenObjectExecute(Sender: TObject);
begin
  (gdcObject as TgdcJournal).OpenObject;
end;

procedure Tgdc_dlgJournal.actOpenObjectUpdate(Sender: TObject);
begin
  actOpenObject.Enabled := (gdcObject.FieldByName('source').AsString > '')
    and (gdcObject.FieldByName('objectid').AsInteger >= 0);
end;

initialization
  RegisterFrmClass(Tgdc_dlgJournal);

finalization
  UnRegisterFrmClass(Tgdc_dlgJournal);
end.
