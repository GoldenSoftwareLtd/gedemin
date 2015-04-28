
unit gdc_frmUserComplexDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  IBCustomDataSet, gdcBase, gdcClasses, IBDatabase, gdcTree, gd_MacrosMenu,
  StdCtrls;

type
  Tgdc_frmUserComplexDocument = class(Tgdc_frmMDHGR)
    gdcUserDocumentLine: TgdcUserDocumentLine;
    gdcUserDocument: TgdcUserDocument;
    actCreateEntry: TAction;
    TBItem1: TTBItem;
    actGotoEntry: TAction;
    TBItem2: TTBItem;
    actMainGotoEntry: TAction;
    TBItem3: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure actCreateEntryExecute(Sender: TObject);
    procedure actGotoEntryExecute(Sender: TObject);
    procedure actMainGotoEntryExecute(Sender: TObject);
    procedure actCreateEntryUpdate(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmUserComplexDocument: Tgdc_frmUserComplexDocument;

implementation

{$R *.DFM}

uses
  dmDatabase_unit,
  gd_ClassList,
  gdcAcctEntryRegister,
  gdc_frmTransaction_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgdc_frmUserComplexDocument }

class function Tgdc_frmUserComplexDocument.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  Result := nil;
end;

procedure Tgdc_frmUserComplexDocument.FormCreate(Sender: TObject);
begin
  gdcObject := gdcUserDocument;

  gdcDetailObject := gdcUserDocumentLine;
  gdcDetailObject.SubType := FSubType;
  gdcDetailObject.SubSet := 'ByParent';

  inherited;

  gdcDetailObject.Open;

  Caption := gdcUserDocument.DocumentName;
end;

procedure Tgdc_frmUserComplexDocument.actCreateEntryExecute(
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

procedure Tgdc_frmUserComplexDocument.actGotoEntryExecute(Sender: TObject);
begin
  if Self.gdcDetailObject.FieldByName('transactionkey').AsInteger > 0 then
  begin
    with Tgdc_frmTransaction.CreateAndAssignWithID(Application, Self.gdcDetailObject.FieldByName('id').AsInteger, esDocumentKey) as Tgdc_frmTransaction do
    begin
      cbGroupByDocument.Checked := False; 
      tvGroup.GoToID(Self.gdcDetailObject.FieldByName('transactionkey').AsInteger);
      gdcAcctViewEntryRegister.Locate('DOCUMENTKEY', Self.gdcDetailObject.FieldByName('id').AsInteger, []);
      Show;
    end;
  end
  else
  begin
    MessageBox(HANDLE, 'По данной позиции не установлена операция.', 'Внимание',
      mb_OK or mb_IconInformation);
  end;
end;

procedure Tgdc_frmUserComplexDocument.actMainGotoEntryExecute(
  Sender: TObject);
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
  begin
    MessageBox(HANDLE, 'По данной позиции не установлена операция.', 'Внимание',
      mb_OK or mb_IconInformation);
  end;
end;

procedure Tgdc_frmUserComplexDocument.actCreateEntryUpdate(
  Sender: TObject);
begin
  actCreateEntry.Enabled := (gdcObject <> nil) and gdcObject.CanEdit;
end;

procedure Tgdc_frmUserComplexDocument.actDetailNewExecute(Sender: TObject);
var
  OldID: Integer;
  C: TgdcFullClass;
begin
  if not gdcDetailObject.IsEmpty then
    OldID := gdcDetailObject.ID
  else
    OldID := -1;

  C := gdcObject.GetCurrRecordClass;
  C.gdClass := CgdcBase(gdcDetailObject.ClassType);
  gdcDetailObject.CreateDialog(C);

  if OldID <> gdcDetailObject.ID then
  begin
    if ibgrDetail.SelectedRows.Count > 0 then
      ibgrDetail.SelectedRows.Clear;
  end;
end;

initialization
  RegisterFrmClass(Tgdc_frmUserComplexDocument);

finalization
  UnRegisterFrmClass(Tgdc_frmUserComplexDocument);
end.
