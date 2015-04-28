{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmInvDocument_unit.pas

  Abstract

    Part of a business class. Inventory document.

  Author

    Romanovski Denis (23-09-2001)

  Revisions history

    Initial  23-09-2001  Dennis  Initial version.

--}

unit gdc_frmInvDocument_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ComCtrls, ToolWin, ExtCtrls, gdcInvDocument_unit, gsDesktopManager,
  IBCustomDataSet, gdcBase, gdcClasses, TB2Item, TB2Dock, TB2Toolbar,
  gdcTree, StdCtrls, gd_MacrosMenu;

type
  Tgdc_frmInvDocument = class(Tgdc_frmMDHGR)
    gdcInvDocument: TgdcInvDocument;
    gdcInvDocumentLine: TgdcInvDocumentLine;
    actViewCard: TAction;
    TBItem1: TTBItem;
    N1: TMenuItem;
    actCreateEntry: TAction;
    TBItem2: TTBItem;
    actGotoEntry: TAction;
    TBItem3: TTBItem;
    actMainGotoEntry: TAction;
    TBItem4: TTBItem;
    actViewAllCard: TAction;
    TBItem5: TTBItem;

    procedure FormCreate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actViewCardExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actCreateEntryExecute(Sender: TObject);
    procedure actGotoEntryExecute(Sender: TObject);
    procedure actMainGotoEntryExecute(Sender: TObject);
    procedure actViewAllCardExecute(Sender: TObject);
    procedure actCreateEntryUpdate(Sender: TObject);
    procedure actDetailNewExecute(Sender: TObject);

  private

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure SaveDesktopSettings; override;
  end;

var
  gdc_frmInvDocument: Tgdc_frmInvDocument;

implementation

{$R *.DFM}

uses
  gd_ClassList,
  gdc_frmInvCard_unit,
  Storages,
  gdcAcctEntryRegister,
  gdc_frmTransaction_unit,
  IBDatabase,
  IBSQL,
  gdcBaseInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

class function Tgdc_frmInvDocument.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  Result := nil;
end;

procedure Tgdc_frmInvDocument.FormCreate(Sender: TObject);
begin
  gdcObject := gdcInvDocument;
  gdcDetailObject := gdcInvDocumentLine;

  gdcDetailObject.SubType := FSubType;

  inherited;

  Caption := gdcInvDocument.DocumentName;
end;

procedure Tgdc_frmInvDocument.SaveDesktopSettings;
begin
{ TODO : надо разобраться что здесь мы должны сохранять! }
  if Assigned(DesktopManager) then
    DesktopManager.SaveDesktopItem(Self);
end;

procedure Tgdc_frmInvDocument.actDeleteExecute(Sender: TObject);
begin
  inherited;
  //
end;

procedure Tgdc_frmInvDocument.actViewCardExecute(Sender: TObject);
begin

  with Tgdc_frmInvCard.Create(Self) as Tgdc_frmInvCard do
  try
    gdcInvCard.Close;
    gdcInvCard.gdcInvDocumentLine := gdcInvDocumentLine;
    gdcObject := gdcInvCard;
    RunCard;
    ShowModal;
  finally
    Free;
  end;

end;

procedure Tgdc_frmInvDocument.actNewExecute(Sender: TObject);
begin
  SaveGrid(ibgrDetail);
  inherited;
  LoadGrid(ibgrDetail);
end;

procedure Tgdc_frmInvDocument.actEditExecute(Sender: TObject);
begin
  SaveGrid(ibgrDetail);
  inherited;
  LoadGrid(ibgrDetail);
end;

procedure Tgdc_frmInvDocument.actCreateEntryExecute(Sender: TObject);
var
  DidActivate: Boolean;
begin
  inherited;
  if MessageBox(HANDLE, 'Провести проводки по списку документов?', 'Внимание',
       mb_YesNo or mb_IconQuestion or mb_TaskModal) = idNo then
    exit;    
{$IFDEF DEBUGMOVE}
  DeleteOldEntry := 0;
  InsertEntryLine := 0;
  PostEntryLine := 0;
  OpenEntry := 0;
  ExecuteFunction := 0;
  OpenTypeEntry := 0;
  AllEntryTime := 0;
  MakeBalance:= 0;
  DeleteZero:= 0;

{$ENDIF}
  DidActivate := not gdcInvDocument.Transaction.InTransaction;
  if DidActivate then
    gdcInvDocument.Transaction.StartTransaction;
  try
    try
      if gdcInvDocument.EOF then
        gdcInvDocument.Prior;
      while not gdcInvDocument.EOF do
      begin
        gdcInvDocument.CreateEntry;
        gdcInvDocument.Next;
      end;
    except
      if DidActivate and gdcInvDocument.Transaction.InTransaction then
        gdcInvDocument.Transaction.Rollback;
      raise;  
    end;
  finally
{$IFDEF DEBUGMOVE}
    MessageBox(HANDLE, PChar(Format('Удаление старой - %d, Вставка - %d, Post - %d, ' +
      ' Open - %d, ExecuteFunction - %d, OpenTrRecord - %d, MakeBalance - %d, DeleteZero - %d, AllTime - %d', [
      DeleteOldEntry, InsertEntryLine, PostEntryLine, OpenEntry, ExecuteFunction,
      OpenTypeEntry, MakeBalance, DeleteZero,  AllEntryTime])), 'Внимание', mb_OK);
{$ENDIF}
    if DidActivate and gdcInvDocument.Transaction.InTransaction then
      gdcInvDocument.Transaction.Commit;
  end;
end;

procedure Tgdc_frmInvDocument.actGotoEntryExecute(Sender: TObject);
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

procedure Tgdc_frmInvDocument.actMainGotoEntryExecute(Sender: TObject);
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

procedure Tgdc_frmInvDocument.actViewAllCardExecute(Sender: TObject);
begin
  with Tgdc_frmInvCard.Create(Self) as Tgdc_frmInvCard do
  try
    gdcInvCard.Close;
    gdcInvCard.gdcInvDocumentLine := gdcInvDocumentLine;
    gdcObject := gdcInvCard;
    gdcObject.SubSet := 'ByHolding,ByGoodOnly';
    RunCard;
    ShowModal;
  finally
    Free;
  end;
end;

procedure Tgdc_frmInvDocument.actCreateEntryUpdate(Sender: TObject);
begin
  actCreateEntry.Enabled := (gdcObject <> nil) and (gdcObject.CanEdit);
end;

procedure Tgdc_frmInvDocument.actDetailNewExecute(Sender: TObject);
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
  RegisterFrmClass(Tgdc_frmInvDocument);

finalization
  UnRegisterFrmClass(Tgdc_frmInvDocument);
end.
