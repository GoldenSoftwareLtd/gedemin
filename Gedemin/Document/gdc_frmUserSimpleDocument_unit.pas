// ShlTanya, 24.02.2019

unit gdc_frmUserSimpleDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  IBCustomDataSet, gdcBase, gdcClasses, IBDatabase, gdcTree, gd_MacrosMenu,
  StdCtrls;

type
  Tgdc_frmUserSimpleDocument = class(Tgdc_frmSGR)
    gdcUserDocument: TgdcUserDocument;
    IBTransaction: TIBTransaction;
    actCreateEntry: TAction;
    actGotoEntry: TAction;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actCreateEntryExecute(Sender: TObject);
    procedure actGotoEntryExecute(Sender: TObject);
    procedure actCreateEntryUpdate(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmUserSimpleDocument: Tgdc_frmUserSimpleDocument;

implementation

{$R *.DFM}

uses
  dmDatabase_unit,
  gd_ClassList,
  gdcAcctEntryRegister,
  gdc_frmTransaction_unit,
  gdcBaseInterface,
  IBSQL,
  gd_resourcestring
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_frmUserSimpleDocument }

class function Tgdc_frmUserSimpleDocument.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  Result := nil;
end;

procedure Tgdc_frmUserSimpleDocument.FormCreate(Sender: TObject);
begin
  gdcObject := gdcUserDocument;
  inherited;
  Caption := gdcUserDocument.DocumentName;
end;

procedure Tgdc_frmUserSimpleDocument.actCreateEntryExecute(
  Sender: TObject);
var
  DidActivate: Boolean;
begin
  inherited;
  if MessageBox(HANDLE, 'Провести проводки по списку документов?', 'Внимание',
       mb_YesNo or mb_IconQuestion or mb_TaskModal) = idNo then
    exit;
  DidActivate := not gdcObject.Transaction.InTransaction;
  if DidActivate then
    gdcObject.Transaction.StartTransaction;
  try
    try
      if gdcObject.EOF then
        gdcObject.Prior;
      while not gdcObject.EOF do
      begin
        (gdcObject as TgdcDocument).CreateEntry;
        gdcObject.Next;
      end;
    except
      if DidActivate and gdcObject.Transaction.InTransaction then
        gdcObject.Transaction.Rollback;
      raise;
    end;
  finally
    if DidActivate and gdcObject.Transaction.InTransaction then
      gdcObject.Transaction.Commit;
  end;
end;

procedure Tgdc_frmUserSimpleDocument.actGotoEntryExecute(Sender: TObject);
begin
  Tgdc_frmTransaction.GoToEntries(Self, gdcObject);
end;

procedure Tgdc_frmUserSimpleDocument.actCreateEntryUpdate(Sender: TObject);
begin
  actCreateEntry.Enabled := (gdcObject <> nil) and (gdcObject.CanEdit);
end;

initialization
  RegisterFrmClass(Tgdc_frmUserSimpleDocument).AbstractBaseForm := True;

finalization
  UnRegisterFrmClass(Tgdc_frmUserSimpleDocument);
end.
