
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
  IBSQL
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
  if Self.gdcObject.FieldByName('transactionkey').AsInteger > 0 then
  begin

    with Tgdc_frmTransaction.CreateAndAssignWithID(Application, Self.gdcObject.FieldByName('id').AsInteger, esDocumentKey) as Tgdc_frmTransaction do
    begin
      cbGroupByDocument.Checked := False;
      tvGroup.GoToID(Self.gdcObject.FieldByName('transactionkey').AsInteger);
      gdcAcctViewEntryRegister.Locate('DOCUMENTKEY', Self.gdcObject.FieldByName('id').AsInteger, []);
      Show;
    end;

  end
  else
    MessageBox(HANDLE, 'По данной позиции не установлена операция.', 'Внимание',
      mb_OK or mb_IconInformation);
end;

procedure Tgdc_frmUserSimpleDocument.actCreateEntryUpdate(Sender: TObject);
begin
  actCreateEntry.Enabled := (gdcObject <> nil) and (gdcObject.CanEdit);
end;

initialization
  RegisterFrmClass(Tgdc_frmUserSimpleDocument);

finalization
  UnRegisterFrmClass(Tgdc_frmUserSimpleDocument);
end.
