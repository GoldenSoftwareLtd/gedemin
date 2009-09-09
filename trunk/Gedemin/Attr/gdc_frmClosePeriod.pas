unit gdc_frmClosePeriod;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Mask, xDateEdits, gdc_createable_form, gd_ClassList,
  ComCtrls, Db, IBDatabase, IBCustomDataSet, gdcBase, gdcTree,
  gsIBLookupComboBox, TB2Item, ActnList, TB2Dock, TB2Toolbar, gdcBaseInterface,
  gd_KeyAssoc;

type
  TfrmClosePeriod = class(TgdcCreateableForm)
    pcMain: TPageControl;
    pnlBottom: TPanel;
    tbsMain: TTabSheet;
    GroupBox1: TGroupBox;
    eExtDatabase: TEdit;
    lblExtDatabase: TLabel;
    btnChooseDatabase: TButton;
    eExtUser: TEdit;
    lblExtUser: TLabel;
    lblExtPassword: TLabel;
    eExtPassword: TEdit;
    lblExtServer: TLabel;
    eExtServer: TEdit;
    GroupBox2: TGroupBox;
    odExtDatabase: TOpenDialog;
    pbMain: TProgressBar;
    btnRun: TButton;
    lblCloseDate: TLabel;
    xdeCloseDate: TxDateEdit;
    pnlBottomButtons: TPanel;
    btnClose: TButton;
    lblProcess: TLabel;
    ActionList1: TActionList;
    actChooseDontDeleteDocumentType: TAction;
    actDeleteDontDeleteDocumentType: TAction;
    mOutput: TMemo;
    tbsInvCardField: TTabSheet;
    GroupBox4: TGroupBox;
    lvAllInvCardField: TListView;
    lvCheckedInvCardField: TListView;
    tbsDocumentType: TTabSheet;
    gbDocumentType: TGroupBox;
    pnlDontDeleteDocumentType: TPanel;
    lvDontDeleteDocumentType: TListView;
    TBDock1: TTBDock;
    lblDontDeleteDocumentType: TLabel;
    TBToolbar1: TTBToolbar;
    TBItem2: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem1: TTBItem;
    Panel1: TPanel;
    lvDeleteUserDocumentType: TListView;
    TBDock4: TTBDock;
    Label1: TLabel;
    TBToolbar4: TTBToolbar;
    TBItem7: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem8: TTBItem;
    cbEntryCalculate: TCheckBox;
    cbRemainsCalculate: TCheckBox;
    cbReBindDepotCards: TCheckBox;
    cbEntryClearProcess: TCheckBox;
    cbRemainsClearProcess: TCheckBox;
    cbTransferEntryBalanceProcess: TCheckBox;
    cbUserDocClearProcess: TCheckBox;
    actChooseUserDocumentToDelete: TAction;
    actDeleteUserDocumentToDelete: TAction;
    procedure FormShow(Sender: TObject);
    procedure btnChooseDatabaseClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCloseClick(Sender: TObject);
    procedure actChooseDontDeleteDocumentTypeExecute(Sender: TObject);
    procedure actDeleteDontDeleteDocumentTypeExecute(Sender: TObject);
    procedure lvAllInvCardFieldDblClick(Sender: TObject);
    procedure lvCheckedInvCardFieldDblClick(Sender: TObject);
    procedure actDeleteDontDeleteDocumentTypeUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actChooseUserDocumentToDeleteExecute(Sender: TObject);
    procedure actDeleteUserDocumentToDeleteExecute(Sender: TObject);
    procedure actDeleteUserDocumentToDeleteUpdate(Sender: TObject);
  private
    FExtDatabasePath: String;
    FExtDatabaseServer: String;
    FExtDatabaseUser: String;
    FExtDatabasePassword: String;
    FCloseDate: TDateTime;
    // ������ ������� ������ �� �������:
    //   ��� ������� - ������-������ ������� ������
    FTableReferenceForeignKeysList: TStringList;
    // ������ �����-��������� ��������� �������� �� ��������
    FFeatureList: TStringList;

    FLocalStartTime: TDateTime;
    FGlobalStartTime: TDateTime;

    FMessageLog: TStringList;

    FUserDocumentTypesToDelete: TgdKeyArray;
    FDontDeleteDocumentTypes: TgdKeyArray;

    procedure ActivateControls(DoActivate: Boolean);
    procedure SetBold(ActiveControl: TCheckBox = nil);
    //procedure InsertDatabaseRecord(WriteTransaction: TIBTransaction);
    procedure SetTriggerActive(SetActive: Boolean; WriteTransaction: TIBTransaction);
    function GetClosePeriodParams: Boolean;
    function GetFeatureFieldList(AAlias: String): String;
    function IIF(Condition: Boolean; TrueString, FalseString: String): String;
    function AddLogMessage(const AMessage: String; const ALineNumber: Integer = -1): Integer;
    procedure SaveLogToFile;

    procedure InitialSetupForm;
    procedure InitialFillInvCardFields;
    procedure InitialFillOptions;
    procedure MoveInvCardField(FromList, ToList: TListView);
    procedure SaveSettingsToStorage;

    procedure CalculateRemains(WriteTransaction: TIBTransaction);
    procedure ReBindDepotCards(WriteTransaction: TIBTransaction);
    procedure DeleteEntry(WriteTransaction: TIBTransaction);

    procedure TryToDeleteDocumentReferences(AID: TID; AdditionalRelationName: String; Transaction: TIBTransaction);
    procedure DeleteDocuments(WriteTransaction: TIBTransaction);
    procedure DeleteUserDocuments(WriteTransaction: TIBTransaction);
    procedure TransferEntryBalance(WriteTransaction: TIBTransaction);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure SetProcessText(AText: String);
  end;

var                                  
  frmClosePeriod: TfrmClosePeriod;

implementation

uses
  IBSQL, AcctUtils, at_classes, gdv_frmCalculateBalance, contnrs,
  gdcInvDocument_unit, gd_security, gdcContacts, gdcClasses, Storages;

{$R *.DFM}

const
  InvDocumentRUID = '174849703_1094302532';
  REFRESH_CLOSING_INFO_INTERVAL = 50;

{ TfrmCalculateBalance }

class function TfrmClosePeriod.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmClosePeriod) then
    frmClosePeriod := TfrmClosePeriod.Create(AnOwner);
  Result := frmClosePeriod;
end;

procedure TfrmClosePeriod.FormCreate(Sender: TObject);
begin
  FUserDocumentTypesToDelete := TgdKeyArray.Create;
  FDontDeleteDocumentTypes := TgdKeyArray.Create;

  FTableReferenceForeignKeysList := TStringList.Create;
  FTableReferenceForeignKeysList.Sorted := True;
  // ��� ��������
  FMessageLog := TStringList.Create;
  // ������ �����-��������� ��������� �������� �� ��������
  FFeatureList := TStringList.Create;
end;

procedure TfrmClosePeriod.FormDestroy(Sender: TObject);
var
  StringCounter: Integer;
begin
  FFeatureList.Free;
  FMessageLog.Free;
  // ��������� ������� �� ������
  for StringCounter := 0 to FTableReferenceForeignKeysList.Count - 1 do
    if Assigned(FTableReferenceForeignKeysList.Objects[StringCounter]) then
      FTableReferenceForeignKeysList.Objects[StringCounter].Free;
  FTableReferenceForeignKeysList.Free;
  FDontDeleteDocumentTypes.Free;
  FUserDocumentTypesToDelete.Free;
end;

function TfrmClosePeriod.GetFeatureFieldList(AAlias: String): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FFeatureList.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + AAlias + FFeatureList.Strings[i];
  end;
end;

procedure TfrmClosePeriod.CalculateRemains(WriteTransaction: TIBTransaction);
var
  moveFieldList, balFieldList, cFieldList: String;
  FieldCounter: Integer;
  PseudoClient, InvDocumentTypeKey: TID;
  ibsql: TIBSQL;
  ibsqlInsertGdDocument, ibsqlInsertHeader, ibsqlInsertPosition, ibsqlInsertCard, ibsqlInsertMovement: TIBSQL;
  CurrentContactKey, NextSupplierKey, CurrentSupplierKey: TID;
  LineCount, MemoStringIndex: Integer;
  InvDocumentInField, InvDocumentOutField: ShortString;
  InvRelationName, InvRelationLineName: ShortString;
  AddLineKeyFieldExists: Boolean;
  DocumentParentKey: TID;
  SQLText: String;
  gdcObject: TgdcInvDocument;
  CurrentRefreshInfoStep: Integer;

  function AddDepotHeader(FromContact, ToContact, CompanyKey: TID): TID;
  var
    NextDocumentKey: TID;
  begin
    // ������� �� ��������� �����
    NextDocumentKey := gdcBaseManager.GetNextID;
    // ������� ������ � gd_document
    ibsqlInsertGdDocument.Close;
    ibsqlInsertGdDocument.ParamByName('ID').AsInteger := NextDocumentKey;
    ibsqlInsertGdDocument.ParamByName('PARENT').Clear;
    ibsqlInsertGdDocument.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
    ibsqlInsertGdDocument.ParamByName('DOCUMENTDATE').AsDateTime := FCloseDate;
    ibsqlInsertGdDocument.ExecQuery;

    // ������� ������ � �������������� ������� ��������� �����
    ibsqlInsertHeader.Close;
    ibsqlInsertHeader.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
    ibsqlInsertHeader.ParamByName('OUTCONTACT').AsInteger := FromContact;
    ibsqlInsertHeader.ParamByName('INCONTACT').AsInteger := ToContact;
    ibsqlInsertHeader.ExecQuery;

    Result := NextDocumentKey;
  end;

  function AddDepotPosition(FromContact, ToContact, CompanyKey, ADocumentParentKey, CardGoodkey: TID; GoodQuantity: Currency): TID;
  var
    NextDocumentKey, NextMovementKey, NextCardKey: TID;
    FieldCounter: Integer;
  begin
    // ������� �� ��������� �������
    NextDocumentKey := gdcBaseManager.GetNextID;
    // ������� ������ � gd_document
    ibsqlInsertGdDocument.Close;
    ibsqlInsertGdDocument.ParamByName('ID').AsInteger := NextDocumentKey;
    ibsqlInsertGdDocument.ParamByName('PARENT').AsInteger := ADocumentParentKey;
    ibsqlInsertGdDocument.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
    ibsqlInsertGdDocument.ParamByName('DOCUMENTDATE').AsDateTime := FCloseDate;
    ibsqlInsertGdDocument.ExecQuery;

    // ������� �� ����� ��������� ��������
    NextCardKey := gdcBaseManager.GetNextID;
    // �������� ����� ��������� ��������
    ibsqlInsertCard.Close;
    ibsqlInsertCard.ParamByName('ID').AsInteger := NextCardKey;
    ibsqlInsertCard.ParamByName('GOODKEY').AsInteger := CardGoodkey;
    ibsqlInsertCard.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
    ibsqlInsertCard.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
    for FieldCounter := 0 to FFeatureList.Count - 1 do
      ibsqlInsertCard.ParamByName(FFeatureList.Strings[FieldCounter]).AsVariant :=
        ibsql.FieldByName(FFeatureList.Strings[FieldCounter]).AsVariant;
    // �������� ���� USR$INV_ADDLINEKEY �������� ������ ������� ������� �� �������
    if AddLineKeyFieldExists then
      ibsqlInsertCard.ParamByName('USR$INV_ADDLINEKEY').AsInteger := NextDocumentKey;
    ibsqlInsertCard.ExecQuery;

    // ������� �� ���������� ��������
    NextMovementKey := gdcBaseManager.GetNextID;
    // �������� ��������� ����� ���������� ��������
    ibsqlInsertMovement.Close;
    ibsqlInsertMovement.ParamByName('MOVEMENTKEY').AsInteger := NextMovementKey;
    ibsqlInsertMovement.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
    ibsqlInsertMovement.ParamByName('CONTACTKEY').AsInteger := ToContact;
    ibsqlInsertMovement.ParamByName('CARDKEY').AsInteger := NextCardKey;
    ibsqlInsertMovement.ParamByName('DEBIT').AsCurrency := GoodQuantity;
    ibsqlInsertMovement.ParamByName('CREDIT').AsCurrency := 0;
    ibsqlInsertMovement.ExecQuery;
    // �������� ���������� ����� ���������� ��������
    ibsqlInsertMovement.Close;
    ibsqlInsertMovement.ParamByName('MOVEMENTKEY').AsInteger := NextMovementKey;
    ibsqlInsertMovement.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
    ibsqlInsertMovement.ParamByName('CONTACTKEY').AsInteger := FromContact;
    ibsqlInsertMovement.ParamByName('CARDKEY').AsInteger := NextCardKey;
    ibsqlInsertMovement.ParamByName('DEBIT').AsCurrency := 0;
    ibsqlInsertMovement.ParamByName('CREDIT').AsCurrency := GoodQuantity;
    ibsqlInsertMovement.ExecQuery;

    // ������� ������ � �������������� ������� ��������� �������
    ibsqlInsertPosition.Close;
    ibsqlInsertPosition.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
    ibsqlInsertPosition.ParamByName('MASTERKEY').AsInteger := ADocumentParentKey;
    ibsqlInsertPosition.ParamByName('FROMCARDKEY').AsInteger := NextCardKey;
    ibsqlInsertPosition.ParamByName('QUANTITY').AsCurrency := GoodQuantity;
    ibsqlInsertPosition.ExecQuery;

    Result := NextDocumentKey;
  end;

begin
  // ������� ����� ������ ������� ��������
  FLocalStartTime := Time;
  // ������������ ��������
  if Assigned(pbMain) then
  begin
    pbMain.Position := 0;
    pbMain.Max := 1;
    AddLogMessage(TimeToStr(FLocalStartTime) + ': ������������ ��������...');
    UpdateWindow(Self.Handle);
  end;

  // ������� ���� ���� ���������� ��������� ��� ��������
  InvDocumentTypeKey := gdcBaseManager.GetIDByRUIDString(InvDocumentRUID);

  // �������� ������ �����-��������� ��������� �������� �� ��������
  moveFieldList := GetFeatureFieldList('move.');
  balFieldList := GetFeatureFieldList('bal.');
  cFieldList := GetFeatureFieldList('c.');

  ibsql := TIBSQL.Create(Application);
  ibsqlInsertGdDocument := TIBSQL.Create(Application);
  ibsqlInsertHeader := TIBSQL.Create(Application);
  ibsqlInsertPosition := TIBSQL.Create(Application);
  ibsqlInsertCard := TIBSQL.Create(Application);
  ibsqlInsertMovement := TIBSQL.Create(Application);
  try
    // ������ �� ��������� �������
    // TODO: �������� ���� ��� ������ ���������� �� ����������
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text :=
      ' SELECT ' +
      '  move.contactkey, ' +
      '  cont.name AS ContactName, ' +
      '  move.SupplierKey, ' +
      '  move.goodkey, ' +
      '  move.companykey, ' +
      '  move.balance ' +
        IIF(moveFieldList <> '', ', ' + moveFieldList, '') +
      ' FROM ' +
      '  ( ' +
      '  SELECT ' +
      '    bal.contactkey, ' +
      '    inv_doc.usr$contactkey AS SupplierKey, ' +
      '    bal.goodkey, ' +
      '    bal.companykey, ' +
      '    SUM(bal.balance) AS balance ' +
        IIF(balFieldList <> '', ', ' + balFieldList, '') +
      '  FROM ' +
      '    ( ' +
      '    SELECT ' +
      '      b.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey, ' +
      '      SUM(b.balance) AS balance ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    FROM ' +
      '      inv_card c ' +
      '      JOIN inv_balance b ON b.cardkey = c.id and b.balance > 0 ' +
      '    GROUP BY ' +
      '      b.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      ' ' +
      '    UNION ALL ' +
      ' ' +
      '    SELECT ' +
      '      m.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey, ' +
      '      - SUM(m.debit - m.credit) AS balance ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    FROM ' +
      '      inv_movement m ' +
      '      JOIN inv_card c on m.cardkey = c.id ' +
      '    WHERE ' +
      '      m.movementdate > :remainsdate ' +
      '    GROUP BY ' +
      '      m.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    ) bal ' +
      '    LEFT JOIN usr$inv_addwbillline inv_line ON inv_line.documentkey = bal.usr$inv_addlinekey ' +
      '    LEFT JOIN usr$inv_addwbill inv_doc ON inv_doc.documentkey = inv_line.masterkey ' +
      '  GROUP BY ' +
      '    bal.contactkey, ' +
      '    inv_doc.usr$contactkey, ' +
      '    bal.goodkey, ' +
      '    bal.companykey ' +
        IIF(balFieldList <> '', ', ' + balFieldList, '') +
      '  HAVING ' +
      '    SUM(bal.balance) > 0 ' +
      '  ) move ' +
      '   LEFT JOIN gd_contact cont ON cont.id = move.contactkey ' +
      ' ORDER BY ' +
      '   cont.name, move.SupplierKey ';

    // �� ������������� ����� ���������� ������ ������ ��� ������������ ��������
    PseudoClient := gdcBaseManager.GetIDByRUID(147004309, 31587988);            // TODO: �������� ������ �� �� ����� �������� � ����������
    // ��������� �� ����-������ �� ������� �������
    AddLineKeyFieldExists := Assigned(atDatabase.FindRelationField('INV_CARD', 'USR$INV_ADDLINEKEY'));

    gdcObject := TgdcInvDocument.Create(Application);
    try
      gdcObject.Transaction := WriteTransaction;
      gdcObject.SubType := InvDocumentRUID;
      gdcObject.SubSet := 'ByID';
      // �������� �����-������ �� ��������, �� ������� � � ������� ����������� ���
      InvDocumentInField := gdcObject.MovementTarget.SourceFieldName;
      InvDocumentOutField := gdcObject.MovementSource.SourceFieldName;
      InvRelationName := gdcObject.RelationName;
      InvRelationLineName := gdcObject.RelationLineName;
    finally
      gdcObject.Free;
    end;
      
    // ������ �� ������� ������ � gd_document
    ibsqlInsertGdDocument.Transaction := WriteTransaction;
    ibsqlInsertGdDocument.SQL.Text := Format(
      'INSERT INTO gd_document ' +
      '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, creatorkey, editorkey) ' +
      'VALUES ' +
      '  (:id, :parent, %0:d, ''1'', :documentdate, :companykey, -1, -1, -1, %1:d, %1:d) ', [InvDocumentTypeKey, IBLogin.ContactKey]);
    ibsqlInsertGdDocument.Prepare;

    // ������ �� ������� ������ � ����� ���������� ���������
    ibsqlInsertHeader.Transaction := WriteTransaction;
    ibsqlInsertHeader.SQL.Text := Format(
      'INSERT INTO %0:s ' +
      '  (documentkey, %1:s, %2:s) ' +
      'VALUES ' +
      '  (:documentkey, :incontact, :outcontact) ', [InvRelationName, InvDocumentInField, InvDocumentOutField]);
    ibsqlInsertHeader.Prepare;

    // ������ �� ������� ������ � ������� ���������� ���������
    ibsqlInsertPosition.Transaction := WriteTransaction;
    ibsqlInsertPosition.SQL.Text := Format(
      'INSERT INTO %0:s ' +
      '  (documentkey, masterkey, fromcardkey, quantity) ' +
      'VALUES ' +
      '  (:documentkey, :masterkey, :fromcardkey, :quantity) ', [InvRelationLineName]);
    ibsqlInsertPosition.Prepare;

    // ������ �� �������� ��������� ��������
    ibsqlInsertCard.Transaction := WriteTransaction;
    SQLText :=
      'INSERT INTO inv_card ' +
      '  (id, goodkey, documentkey, firstdocumentkey, firstdate, companykey';
    // ����-��������
    for FieldCounter := 0 to FFeatureList.Count - 1 do
      SQLText := SQLText + ', ' + FFeatureList.Strings[FieldCounter];
    // ���� ��������� ����-������ �� ������� �������
    if AddLineKeyFieldExists then
      SQLText := SQLText + ', USR$INV_ADDLINEKEY';
    SQLText := SQLText + ') VALUES ' +
      '  (:id, :goodkey, :documentkey, :documentkey, :firstdate, :companykey';
    // ����-��������
    for FieldCounter := 0 to FFeatureList.Count - 1 do
      SQLText := SQLText + ', :' + FFeatureList.Strings[FieldCounter];
    // ���� ��������� ����-������ �� ������� �������
    if AddLineKeyFieldExists then
      SQLText := SQLText + ', :USR$INV_ADDLINEKEY';
    SQLText := SQLText + ')';
    ibsqlInsertCard.SQL.Text := SQLText;
    ibsqlInsertCard.ParamByName('FIRSTDATE').AsDateTime := FCloseDate;
    ibsqlInsertCard.Prepare;

    // ������ �� �������� ���������� ��������
    ibsqlInsertMovement.Transaction := WriteTransaction;
    ibsqlInsertMovement.SQL.Text :=
      'INSERT INTO inv_movement ' +
      '  (movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +
      'VALUES ' +
      '  (:movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';
    ibsqlInsertMovement.ParamByName('MOVEMENTDATE').AsDateTime := FCloseDate;
    ibsqlInsertMovement.Prepare;

    // ������� ��� ������� ���
    ibsql.Close;
    ibsql.ParamByName('REMAINSDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;

    LineCount := 0;
    MemoStringIndex := -1;
    CurrentContactKey := -1;
    CurrentSupplierKey := -1;
    DocumentParentKey := -1;
    CurrentRefreshInfoStep := 0;
    // ���� �� �������� ���
    while not ibsql.Eof do
    begin
      // ��� ������� Escape ������� �������
      if Self.Active and ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0) then
      begin
        if Application.MessageBox('���������� �������� �������?', '��������',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('���������� ��������');
      end;

      // ���� �� ���� USR$INV_ADDLINEKEY �������� ����� ����������, �������� ������ ������� � ����
      if not ibsql.FieldByName('SUPPLIERKEY').IsNull then
        NextSupplierKey := ibsql.FieldByName('SUPPLIERKEY').AsInteger
      else
        NextSupplierKey := PseudoClient;

      // ���� � ����� ������� �� ������ �������, ��� ������� ����������,
      //   ��� ���-�� ������� � ��������� ��������� 2000 (���������� �� ���������),
      //   �� �������� ����� ����� ���������
      if (ibsql.FieldByName('CONTACTKEY').AsInteger <> CurrentContactKey)
         or (NextSupplierKey <> CurrentSupplierKey)
         or ((LineCount mod 2000) = 0) then
      begin
        // ���� ������� �� ������ �������
        if ibsql.FieldByName('CONTACTKEY').AsInteger <> CurrentContactKey then
        begin
          // ������������ ��������
          if Assigned(pbMain) then
          begin
            // ������� �������� ����� ������� ����������� ��������
            if MemoStringIndex > 0 then
              AddLogMessage('  ' + IntToStr(LineCount) + ' �������', MemoStringIndex);
            CurrentRefreshInfoStep := 0;
            AddLogMessage(Format('> �������: %s', [ibsql.FieldByName('CONTACTNAME').AsString]));
            MemoStringIndex := AddLogMessage('  0 �������');
            UpdateWindow(Self.Handle);
          end;
          // ������� ������� �������
          LineCount := 0;
          // �������� ������� �������
          CurrentContactKey := ibsql.FieldByName('CONTACTKEY').AsInteger;
        end;
        // �������� �������� ����������
        CurrentSupplierKey := NextSupplierKey;
        // ������� ����� ��������� � ������� �� ID
        DocumentParentKey := AddDepotHeader(CurrentSupplierKey, CurrentContactKey, ibsql.FieldByName('COMPANYKEY').AsInteger);
      end;

      // �������� ������� ������� � ����� ���������
      Inc(LineCount);

      // ������������ ��������
      if Assigned(pbMain) then
      begin
        if CurrentRefreshInfoStep >= REFRESH_CLOSING_INFO_INTERVAL then
        begin
          CurrentRefreshInfoStep := 0;
          AddLogMessage('  ' + IntToStr(LineCount) + ' �������', MemoStringIndex);
          UpdateWindow(Self.Handle);
        end
        else
          Inc(CurrentRefreshInfoStep);
      end;

      // �������� ������� INV_DOCUMENT
      AddDepotPosition(CurrentSupplierKey, CurrentContactKey, ibsql.FieldByName('COMPANYKEY').AsInteger,
        DocumentParentKey, ibsql.FieldByName('GOODKEY').AsInteger, ibsql.FieldByName('BALANCE').AsCurrency);
          
      // TODO: ��� ������ ��������� �������� ������� ����� ��������� ����������, ��������� ���� ������� ���������
      //   �� ��������� ���������� ��������, ������������� ������������ ���, ��� ������ ����� ����� �����
      //   �������� ���������������� � ������

      ibsql.Next;
    end;

    // ������������ ��������
    if Assigned(pbMain) then
    begin
      pbMain.Max := pbMain.Position;
      AddLogMessage(TimeToStr(Time) + ': �������� ������� ������������ ��������...');
      AddLogMessage('����������������� ��������: ' + TimeToStr(Time - FLocalStartTime));
      UpdateWindow(Self.Handle);
    end;
  finally
    ibsqlInsertMovement.Free;
    ibsqlInsertCard.Free;
    ibsqlInsertPosition.Free;
    ibsqlInsertHeader.Free;
    ibsqlInsertGdDocument.Free;
    ibsql.Free;
  end;
end;

procedure TfrmClosePeriod.SetProcessText(AText: String);
begin
  lblProcess.Caption := AText;
  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure TfrmClosePeriod.FormShow(Sender: TObject);
begin
  pcMain.ActivePage := tbsMain;
  eExtDatabase.Text := '';
  eExtServer.Text := 'localhost';
  eExtUser.Text := 'SYSDBA';
  eExtPassword.Text := 'masterkey';

  // �������� ������ ����� ��������� ��������
  InitialSetupForm;
end;

procedure TfrmClosePeriod.btnChooseDatabaseClick(Sender: TObject);
begin
  if odExtDatabase.Execute then
    eExtDatabase.Text := odExtDatabase.Filename;
end;

procedure TfrmClosePeriod.btnRunClick(Sender: TObject);
var
  Tr: TIBTransaction;
begin
  if GetClosePeriodParams then
  begin
    FGlobalStartTime := Time;
    // ������������ ��������
    AddLogMessage(TimeToStr(FGlobalStartTime) + ': ����� ������� �������� �������...');

    Tr := TIBTransaction.Create(nil);
    try
      ActivateControls(False);

      Tr.DefaultDatabase := gdcBaseManager.Database;
      //Tr.Params.Add('no_auto_undo');    // TODO: �������� ������ �������� ����������, �� ��� ��� � IBDatabase.pas:2556

      // ���������� ���������
      SetTriggerActive(False, Tr);
      Tr.StartTransaction;
      try
        // ���������� ������ �� ���������
        if cbEntryCalculate.Checked then
        begin
          SetBold(cbEntryCalculate);
          CalculateBalance(FCloseDate, pbMain, Tr);
        end;

        // �������� ��������
        if cbEntryClearProcess.Checked then
        begin
          SetBold(cbEntryClearProcess);
          DeleteEntry(Tr);
        end;

        // ���������� ��������� ��������
        if cbRemainsCalculate.Checked then
        begin
          SetBold(cbRemainsCalculate);
          CalculateRemains(Tr);
        end;

        // ������������ ��������� ��������
        if cbReBindDepotCards.Checked then
        begin
          SetBold(cbReBindDepotCards);
          ReBindDepotCards(Tr);
        end;

        // �������� ����������
        if cbRemainsClearProcess.Checked then
        begin
          SetBold(cbRemainsClearProcess);
          DeleteDocuments(Tr);
        end;

        // �������� ���������������� ����������
        if cbUserDocClearProcess.Checked then
        begin
          SetBold(cbUserDocClearProcess);
          DeleteUserDocuments(Tr);
        end;

        // ������� ������������� ������ �� AC_ENTRY_BALANCE � AC_ENTRY
        if cbTransferEntryBalanceProcess.Checked then
        begin
          SetBold(cbTransferEntryBalanceProcess);
          TransferEntryBalance(Tr);
        end;  

        // ������� ���������� � ���������� ���� ������ � ���� ��������
        {
        InsertDatabaseRecord(Tr);
        }

        // ���������� ��������� � ����
        if Tr.InTransaction then
          Tr.Commit;
        // ������������ ��������
        AddLogMessage(TimeToStr(Time) + ': �������� ������� �������� �������...');
      except
        on E: Exception do
        begin
          AddLogMessage('���������� ������:'#13#10 + E.Message + #13#10'������� �������� �������!');
          if Tr.InTransaction then
            Tr.Rollback;
        end;
      end;
    finally
      // ��������� ���������
      SetTriggerActive(True, Tr);
      Tr.Free;
      
      ActivateControls(True);
      // ������������ ��������
      // ������ ��������� �� ���� ������� ��������
      SetBold(nil);
      AddLogMessage('����������������� ��������: ' + TimeToStr(Time - FGlobalStartTime));

      if MessageBox(Handle, '��������� ��� � ����?',
         '��������', MB_ICONQUESTION or MB_YESNO) = IDYES then
        SaveLogToFile;
    end;
  end;
end;

procedure TfrmClosePeriod.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
  SaveSettingsToStorage;
end;

procedure TfrmClosePeriod.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

function TfrmClosePeriod.IIF(Condition: Boolean; TrueString,
  FalseString: String): String;
begin
  if Condition then
    Result := TrueString
  else
    Result := FalseString;
end;

procedure TfrmClosePeriod.SetBold(ActiveControl: TCheckBox = nil);
begin
  cbEntryCalculate.Font.Style := [];
  cbRemainsCalculate.Font.Style := [];
  cbReBindDepotCards.Font.Style := [];
  cbEntryClearProcess.Font.Style := [];
  cbRemainsClearProcess.Font.Style := [];
  cbTransferEntryBalanceProcess.Font.Style := [];

  if Assigned(ActiveControl) then
    ActiveControl.Font.Style := [fsBold];

  Self.BringToFront;
  UpdateWindow(Self.Handle);
end;

procedure TfrmClosePeriod.ActivateControls(DoActivate: Boolean);
begin
  btnRun.Enabled := DoActivate;
  btnClose.Enabled := DoActivate;
  btnChooseDatabase.Enabled := DoActivate;

  cbEntryCalculate.Enabled := DoActivate;
  cbRemainsCalculate.Enabled := DoActivate;
  cbReBindDepotCards.Enabled := DoActivate;
  cbEntryClearProcess.Enabled := DoActivate;
  cbRemainsClearProcess.Enabled := DoActivate;
  cbUserDocClearProcess.Enabled := DoActivate;
  cbTransferEntryBalanceProcess.Enabled := DoActivate;
end;

procedure TfrmClosePeriod.DeleteDocuments(WriteTransaction: TIBTransaction);
const
  UPDATE_INV_CARD_SET_NULL = 'UPDATE inv_card SET %0:s = NULL WHERE %0:s = :dockey;';
var
  ibsqlDocument: TIBSQL;
  ibsqlDeleteMovement: TIBSQL;
  ibsqlDeleteAddRecord: TIBSQL;
  ibsqlDeleteDocument: TIBSQL;
  ibsqlDeleteEntry: TIBSQL;
  ibsqlUpdateInvCard: TIBSQL;
  ibsqlSavepointManager: TIBSQL;
  DeletedCount, ErrorDocumentCount: Integer;
  I, DocumentListIndex: Integer;
  GDDocumentReferenceFieldList: TStringList;
  SQLText: String;
  R: TatRelation;
  DocumentKeysToDelayedDelete: TgdKeyStringAssoc;        

  procedure DeleteSingleDocument(const AID: TID; const AdditionalTableName: String; const ForceDelete: Boolean = false);
  begin
    // ������ ������ �� ��������� �������� �� �����-��������� ��������� ��������
    ibsqlUpdateInvCard.Close;
    ibsqlUpdateInvCard.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlUpdateInvCard.ExecQuery;

    // ������ ������� ��������� �� �������������� �������
    try
      ibsqlDeleteAddRecord.Close;
      ibsqlDeleteAddRecord.SQL.Text :=
        ' DELETE FROM ' + AdditionalTableName + ' WHERE documentkey = :dockey ';
      ibsqlDeleteAddRecord.ParamByName('DOCKEY').AsInteger := AID;
      ibsqlDeleteAddRecord.ExecQuery;
    except
      if ForceDelete then
      begin
        // ������� ������� ������ �� ������� ������
        TryToDeleteDocumentReferences(AID, AdditionalTableName, WriteTransaction);
        // ����� ������� ������� ������
        ibsqlDeleteAddRecord.Close;
        ibsqlDeleteAddRecord.SQL.Text :=
          ' DELETE FROM ' + AdditionalTableName + ' WHERE documentkey = :dockey ';
        ibsqlDeleteAddRecord.ParamByName('DOCKEY').AsInteger := AID;
        ibsqlDeleteAddRecord.ExecQuery;
      end
      else
        raise;
    end;

    // ������ �������� �� ����� ���������
    ibsqlDeleteEntry.Close;
    ibsqlDeleteEntry.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlDeleteEntry.ExecQuery;

    // ������ ��������� �������� �� ����� ���������
    ibsqlDeleteMovement.Close;
    ibsqlDeleteMovement.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlDeleteMovement.ExecQuery;

    // ������ �������� �� GD_DOCUMENT
    try
      ibsqlDeleteDocument.Close;
      ibsqlDeleteDocument.ParamByName('DOCKEY').AsInteger := AID;
      ibsqlDeleteDocument.ExecQuery;
    except
      if ForceDelete then
      begin
        // ������� ������� ������ �� ������� ������
        TryToDeleteDocumentReferences(AID, 'GD_DOCUMENT', WriteTransaction);
        // ����� ������� ������� ������
        ibsqlDeleteDocument.Close;
        ibsqlDeleteDocument.ParamByName('DOCKEY').AsInteger := AID;
        ibsqlDeleteDocument.ExecQuery;
      end
      else
        raise;  
    end;
  end;

begin
  // ������������ ��������
  FLocalStartTime := Time;
  if Assigned(pbMain) then
  begin
    pbMain.Position := 0;
    pbMain.Max := 1000000;
    Self.SetProcessText('0 �������, 0 ������');
    AddLogMessage(TimeToStr(FLocalStartTime) + ': �������� ����������...');
    UpdateWindow(Self.Handle);
  end;

  ibsqlDocument := TIBSQL.Create(Application);
  ibsqlDeleteAddRecord := TIBSQL.Create(Application);
  ibsqlDeleteMovement := TIBSQL.Create(Application);
  ibsqlDeleteDocument := TIBSQL.Create(Application);
  ibsqlDeleteEntry := TIBSQL.Create(Application);
  ibsqlUpdateInvCard := TIBSQL.Create(Application);
  ibsqlSavepointManager := TIBSQL.Create(Application);

  // ������ ����������� �������� ����������
  DocumentKeysToDelayedDelete := TgdKeyStringAssoc.Create;
  try

    GDDocumentReferenceFieldList := TStringList.Create;
    try
      // ������� ��� ������ �� AC_ENTRY �� GD_DOCUMENT
      R := atDatabase.Relations.ByRelationName('AC_ENTRY');
      for I := 0 to R.RelationFields.Count - 1 do
      begin
        if Assigned(R.RelationFields[I].ForeignKey) and Assigned(R.RelationFields[I].References) then
          if R.RelationFields[I].References.RelationName = 'GD_DOCUMENT' then
            GDDocumentReferenceFieldList.Add(R.RelationFields[I].FieldName);
      end;
      // ������ �� �������� ��������
      ibsqlDeleteEntry.Transaction := WriteTransaction;
      SQLText := '';
      for I := 0 to GDDocumentReferenceFieldList.Count - 1 do
      begin
        if SQLText <> '' then
          SQLText := SQLText + ' OR ';
        SQLText := SQLText + ' ( ' + GDDocumentReferenceFieldList.Strings[I] + ' = :dockey ) ';
      end;
      ibsqlDeleteEntry.SQL.Text :=
        'DELETE FROM ac_entry WHERE ' + SQLText;
      ibsqlDeleteEntry.Prepare;

      // ������� ��� ���������������� ������ �� INV_CARD �� GD_DOCUMENT
      GDDocumentReferenceFieldList.Clear;
      R := atDatabase.Relations.ByRelationName('INV_CARD');
      for I := 0 to R.RelationFields.Count - 1 do
      begin
        if Assigned(R.RelationFields[I].ForeignKey) and Assigned(R.RelationFields[I].References) then
          if (R.RelationFields[I].References.RelationName = 'GD_DOCUMENT')
             and (R.RelationFields[I].IsUserDefined) then
            GDDocumentReferenceFieldList.Add(R.RelationFields[I].FieldName);
      end;
      // ������ �� �������� ������ �� ��������� ��������� �� ��������� ��������
      ibsqlUpdateInvCard.Transaction := WriteTransaction;
      SQLText := #13#10;
      for I := 0 to GDDocumentReferenceFieldList.Count - 1 do
        SQLText := SQLText + Format(UPDATE_INV_CARD_SET_NULL, [GDDocumentReferenceFieldList.Strings[I]]) + #13#10;
      ibsqlUpdateInvCard.SQL.Text :=
        'EXECUTE BLOCK (dockey INTEGER = :dockey) AS BEGIN ' + SQLText + ' END ';
      ibsqlUpdateInvCard.Prepare;
    finally
      GDDocumentReferenceFieldList.Free;
    end;

    // ������� ������ ���������� �� �������� ����������, ������� ����� �� ����������
    ibsqlDocument.Transaction := gdcBaseManager.ReadTransaction;
    ibsqlDeleteAddRecord.Transaction := WriteTransaction;
    // ������ �� �������� ���������� ��������, ������������ � ������������� ���������
    ibsqlDeleteMovement.Transaction := WriteTransaction;
    ibsqlDeleteMovement.SQL.Text :=
      ' DELETE FROM inv_movement WHERE documentkey = :dockey ';
    ibsqlDeleteMovement.Prepare;
    // ������ �� �������� ��������� �� gd_document
    ibsqlDeleteDocument.Transaction := WriteTransaction;
    ibsqlDeleteDocument.SQL.Text :=
      ' DELETE FROM gd_document WHERE id = :dockey ';
    ibsqlDeleteDocument.Prepare;
    // ��������\����������� savepoint
    ibsqlSavepointManager.Transaction := WriteTransaction;

    // ������ �� ��������� ���������� ��������, �������� ����������� �������� �� ������� ��������,
    //   ������� � �������� �������
    ibsqlDocument.SQL.Text :=
      'SELECT ' +
      '  doc.id AS documentkey, ' +
      '  IIF(doc.parent IS NULL, headtable.relationname, linetable.relationname) AS addtablename ' +
      'FROM ' +
      '  gd_document doc ' +
      '  LEFT JOIN gd_documenttype t ON t.id = doc.documenttypekey ' +
      '  LEFT JOIN at_relations headtable ON headtable.id = t.headerrelkey ' +
      '  LEFT JOIN at_relations linetable ON linetable.id = t.linerelkey ' +
      'WHERE ' +
      '  doc.documentdate < :closedate ' +
      '  AND t.classname = ''TgdcInvDocumentType'' ' +
      '  AND t.documenttype = ''D'' ' +
      '  AND NOT headtable.id IS NULL ' +
      '  AND NOT linetable.id IS NULL ' +
      'ORDER BY ' +
      '  doc.documentdate DESC, doc.id DESC ';
    ibsqlDocument.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlDocument.ExecQuery;

    DeletedCount := 0;
    ErrorDocumentCount := 0;

    // ���� �� ��������� ����������, ���������� ��������
    while not ibsqlDocument.Eof do
    begin
      // ��� ������� Escape ������� �������
      if Self.Active and ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0) then
      begin
        if Application.MessageBox('���������� �������� �������?', '��������',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
        begin
          // ������� ������ ����������, ������� �� ���������� �������
          if Assigned(pbMain) then
          begin
            AddLogMessage('�� ��������� ���������:');
            for I := 0 to DocumentKeysToDelayedDelete.Count - 1 do
              AddLogMessage(DocumentKeysToDelayedDelete.ValuesByIndex[I] +
                ' ( ' + IntToStr(DocumentKeysToDelayedDelete.Keys[I]) + ' )');
          end;

          raise Exception.Create('���������� ��������');
        end;
      end;

      // ������ ������� �������� � ��� ��������
      try
        // ������� ������� ��������
        DeleteSingleDocument(ibsqlDocument.FieldByName('DOCUMENTKEY').AsInteger,
          ibsqlDocument.FieldByName('ADDTABLENAME').AsString);
        Inc(DeletedCount);

        // ������ 100 ���������� ����� ��������� ���������� ��������
        if DeletedCount mod 100 = 0 then
          for I := 0 to DocumentKeysToDelayedDelete.Count - 1 do
          begin
            try
              // ������� ������� ��������
              DeleteSingleDocument(DocumentKeysToDelayedDelete.Keys[I],
                DocumentKeysToDelayedDelete.ValuesByIndex[I]);
              // ������� �������� �� ������ ����������
              DocumentKeysToDelayedDelete.Delete(I);
              Inc(DeletedCount);
              Dec(ErrorDocumentCount);
            except
              // ���� �� ���������� �������, �� ������ �� ������ - ������� ������� � ��������� ���
            end;
          end;
      except
        // ������������ ������ �������� ���������
        on E: Exception do
        begin
          // ������� �������� � ������ ����������� ��������
          DocumentListIndex := DocumentKeysToDelayedDelete.Add(ibsqlDocument.FieldByName('DOCUMENTKEY').AsInteger);
          DocumentKeysToDelayedDelete.ValuesByIndex[DocumentListIndex] := ibsqlDocument.FieldByName('ADDTABLENAME').AsString;

          Inc(ErrorDocumentCount);
          if Assigned(pbMain) then
          begin
            AddLogMessage(E.Message);
            AddLogMessage(ibsqlDocument.FieldByName('ADDTABLENAME').AsString +
              ' ( ' + ibsqlDocument.FieldByName('DOCUMENTKEY').AsString + ' )');
          end;
        end;
      end;

      // ������������ ��������
      if Assigned(pbMain) then
      begin
        pbMain.StepBy(1);
        if pbMain.Position >= pbMain.Max then
          pbMain.Max := pbMain.Max * 2;
        Self.SetProcessText(IntToStr(DeletedCount) + ' �������, ' + IntToStr(ErrorDocumentCount) + ' ������');
        UpdateWindow(Self.Handle);
      end;
      // �������� � ���������� ���������
      ibsqlDocument.Next;
    end;

    // ������������ ��������
    if Assigned(pbMain) then
    begin
      AddLogMessage('�� ��������� ���������:');
      // ��������� ��� ������� ������� ���������� ���������
      for I := 0 to DocumentKeysToDelayedDelete.Count - 1 do
      begin
        try
          // ������� ������� ��������
          DeleteSingleDocument(DocumentKeysToDelayedDelete.Keys[I],
            DocumentKeysToDelayedDelete.ValuesByIndex[I]);
          // ������� �������� �� ������ ����������
          DocumentKeysToDelayedDelete.Delete(I);
          Inc(DeletedCount);
          Dec(ErrorDocumentCount);
        except
          on E: Exception do
          begin
            AddLogMessage(E.Message);
            AddLogMessage(DocumentKeysToDelayedDelete.ValuesByIndex[I] +
              ' ( ' + IntToStr(DocumentKeysToDelayedDelete.Keys[I]) + ' )');
          end;
        end;
      end;
      // ������� ������ ����������, ������� �� ���������� �������
      for I := 0 to DocumentKeysToDelayedDelete.Count - 1 do
        AddLogMessage(DocumentKeysToDelayedDelete.ValuesByIndex[I] +
          ' ( ' + IntToStr(DocumentKeysToDelayedDelete.Keys[I]) + ' )');
      AddLogMessage(TimeToStr(Time) + ': �������� ������� �������� ����������...');
      AddLogMessage('����������������� ��������: ' + TimeToStr(Time - FLocalStartTime));

      pbMain.Max := pbMain.Position;
      Self.SetProcessText(IntToStr(DeletedCount) + ' �������, ' + IntToStr(ErrorDocumentCount) + ' ������');
      UpdateWindow(Self.Handle);
    end;

  finally
    DocumentKeysToDelayedDelete.Free;

    ibsqlUpdateInvCard.Free;
    ibsqlDeleteEntry.Free;
    ibsqlDeleteAddRecord.Free;
    ibsqlDeleteDocument.Free;
    ibsqlDeleteMovement.Free;
    ibsqlDocument.Free;
  end;
end;

procedure TfrmClosePeriod.DeleteUserDocuments(WriteTransaction: TIBTransaction);
var
  ibsqlSelectDocument: TIBSQL;
  ibsqlDeleteDocument, ibsqlDeleteUserRecord: TIBSQL;
  DocumentTypeCounter: Integer;
  DocumentTypeListStr: String;
  CurrentRelationName, NextRelationName: String;
  CurrentDocumentKey: Integer;
begin
  // ������������ ��������
  FLocalStartTime := Time;
  if Assigned(pbMain) then
  begin
    pbMain.Position := 0;
    pbMain.Max := 1;
    Self.SetProcessText('');
    AddLogMessage(TimeToStr(FLocalStartTime) + ': �������� ���������������� ����������...');
    UpdateWindow(Self.Handle);
  end;

  // ���� ������ ���� �� ���� ��� ���������������� ����������
  if FUserDocumentTypesToDelete.Count > 0 then
  begin
    // ���������� ������ � ID ����� ���������������� ����������
    for DocumentTypeCounter := 0 to FUserDocumentTypesToDelete.Count - 1 do
    begin
      if DocumentTypeListStr <> '' then
        DocumentTypeListStr := DocumentTypeListStr + ', ';
      DocumentTypeListStr := DocumentTypeListStr + IntToStr(FUserDocumentTypesToDelete.Keys[DocumentTypeCounter]);
    end;

    ibsqlSelectDocument := TIBSQL.Create(Application);
    ibsqlDeleteDocument := TIBSQL.Create(Application);
    ibsqlDeleteUserRecord := TIBSQL.Create(Application);
    try
      // ������ ��� �������� ������ �� gd_document �� ����������� ID
      ibsqlDeleteDocument.Transaction := WriteTransaction;
      ibsqlDeleteDocument.SQL.Text := 'DELETE FROM gd_document WHERE id = :documentkey';
      ibsqlDeleteDocument.Prepare;

      ibsqlDeleteUserRecord.Transaction := WriteTransaction;

      // ������ �������� ���������������� ��������� ���������� �����, ������� ������� �� ���� ��������
      //   ��������� �� � ������� �������� �� ����, ����� �� ID
      ibsqlSelectDocument.Transaction := WriteTransaction;
      ibsqlSelectDocument.SQL.Text := Format(
        'SELECT ' +
        '  d.id AS documentkey, ' +
        '  IIF(d.parent IS NULL, h_rel.relationname, l_rel.relationname) AS add_rel_name ' +
        'FROM ' +
        '  gd_document d ' +
        '  LEFT JOIN gd_documenttype t ON t.id = d.documenttypekey ' +
        '  LEFT JOIN at_relations h_rel ON h_rel.id = t.headerrelkey ' +
        '  LEFT JOIN at_relations l_rel ON l_rel.id = t.linerelkey ' +
        'WHERE ' +
        '  d.documentdate < :closedate ' +
        '  AND d.documenttypekey IN (%0:s) ' +
        '  AND NOT t.headerrelkey IS NULL ' +
        'ORDER BY ' +
        '  d.documentdate DESC, d.id DESC', [DocumentTypeListStr]);
      ibsqlSelectDocument.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
      ibsqlSelectDocument.ExecQuery;

      CurrentRelationName := '';
      while not ibsqlSelectDocument.Eof do
      begin
        CurrentDocumentKey := ibsqlSelectDocument.FieldByName('DOCUMENTKEY').AsInteger;
        NextRelationName := ibsqlSelectDocument.FieldByName('ADD_REL_NAME').AsString;
        if CurrentRelationName <> NextRelationName then
        begin
          CurrentRelationName := NextRelationName;
          ibsqlDeleteUserRecord.Close;
          ibsqlDeleteUserRecord.SQL.Text :=
            Format('DELETE FROM %0:s WHERE documentkey = :documentkey', [CurrentRelationName]);
          ibsqlDeleteUserRecord.Prepare;
        end;

        // ������ ������ �� ���������������� �������
        try
          ibsqlDeleteUserRecord.Close;
          ibsqlDeleteUserRecord.ParamByName('DOCUMENTKEY').AsInteger := CurrentDocumentKey;
          ibsqlDeleteUserRecord.ExecQuery;
        except
          // ������� ������� ������ �� ������� ������
          TryToDeleteDocumentReferences(CurrentDocumentKey, CurrentRelationName, WriteTransaction);
        end;
        // ������ ������ �� gd_document
        try
          ibsqlDeleteDocument.Close;
          ibsqlDeleteDocument.ParamByName('DOCUMENTKEY').AsInteger := CurrentDocumentKey;
          ibsqlDeleteDocument.ExecQuery;
        except
          // ������� ������� ������ �� ������� ������
          TryToDeleteDocumentReferences(CurrentDocumentKey, 'GD_DOCUMENT', WriteTransaction);
        end;

        ibsqlSelectDocument.Next;
      end;
    finally
      ibsqlDeleteUserRecord.Free;
      ibsqlDeleteDocument.Free;
      ibsqlSelectDocument.Free;
    end;
  end;

  // ������������ ��������
  if Assigned(pbMain) then
  begin
    pbMain.Max := pbMain.Position;
    AddLogMessage(TimeToStr(Time) + ': �������� ������� �������� ���������������� ����������...');
    AddLogMessage('����������������� ��������: ' + TimeToStr(Time - FLocalStartTime));
    UpdateWindow(Self.Handle);
  end;
end;

procedure TfrmClosePeriod.DeleteEntry(WriteTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
begin
  // ������������ ��������
  FLocalStartTime := Time;
  if Assigned(pbMain) then
  begin
    pbMain.Position := 0;
    pbMain.Max := 1;
    Self.SetProcessText('');
    AddLogMessage(TimeToStr(FLocalStartTime) + ': �������� ��������...');
    UpdateWindow(Self.Handle);
  end;

  ibsql := TIBSQL.Create(Application);
  try
    ibsql.Transaction := WriteTransaction;
    ibsql.SQL.Text := 'DELETE FROM ac_entry WHERE entrydate < :closedate ';
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;

  // ������������ ��������
  if Assigned(pbMain) then
  begin
    pbMain.Max := pbMain.Position;
    AddLogMessage(TimeToStr(Time) + ': �������� ������� �������� ��������...');
    AddLogMessage('����������������� ��������: ' + TimeToStr(Time - FLocalStartTime));
    UpdateWindow(Self.Handle);
  end;
end;

procedure TfrmClosePeriod.SetTriggerActive(SetActive: Boolean;
  WriteTransaction: TIBTransaction);
const
  AlterTriggerCount = 3;
  AlterTriggerArray: array[0 .. AlterTriggerCount - 1] of String =
    ('INV_BD_MOVEMENT', 'INV_BU_MOVEMENT', 'AC_ENTRY_DO_BALANCE');
var
  ibsql: TIBSQL;
  WasActive: Boolean;
  StateStr: String;
  I: Integer;
begin
  WasActive := WriteTransaction.Active;
  if not WasActive then
    WriteTransaction.StartTransaction;

  if SetActive then
    StateStr := 'ACTIVE'
  else
    StateStr := 'INACTIVE';

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := WriteTransaction;

    for I := 0 to AlterTriggerCount - 1 do
    begin
      ibsql.SQL.Text := 'ALTER TRIGGER ' + AlterTriggerArray[I] + ' '  + StateStr;
      ibsql.ExecQuery;
      ibsql.Close;
    end;
  finally
    ibsql.Free;
  end;

  WriteTransaction.Commit;
  if WasActive then
    WriteTransaction.StartTransaction;
end;

{procedure TfrmClosePeriod.InsertDatabaseRecord(WriteTransaction: TIBTransaction);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := WriteTransaction;
    ibsql.SQL.Text :=
      'INSERT INTO db_closehistory (databasepath, server, username, userpassword, closedate) ' +
      'VALUES (:path, :server, :username, :userpassword, :closedate) ';
    ibsql.ParamByName('PATH').AsString := FExtDatabasePath;
    ibsql.ParamByName('SERVER').AsString := FExtDatabaseServer;
    ibsql.ParamByName('USERNAME').AsString := FExtDatabaseUser;
    ibsql.ParamByName('USERPASSWORD').AsString := FExtDatabasePassword;
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;
end;}

function TfrmClosePeriod.GetClosePeriodParams: Boolean;
var
  ListElementCounter: Integer;
begin
  Result := True;

  FExtDatabasePath := eExtDatabase.Text;
  FExtDatabaseServer := eExtServer.Text;
  FExtDatabaseUser := eExtUser.Text;
  FExtDatabasePassword := eExtPassword.Text;
  FCloseDate := xdeCloseDate.Date;
  // �������� ������ ����� ��������� ����������, ������� ������ �������
  FDontDeleteDocumentTypes.Clear;
  for ListElementCounter := 0 to lvDontDeleteDocumentType.Items.Count - 1 do
    FDontDeleteDocumentTypes.Add(Integer(lvDontDeleteDocumentType.Items[ListElementCounter].Data));
  // �������� ������ ����� ���������������� ����������, ������� ����� �������
  FUserDocumentTypesToDelete.Clear;
  for ListElementCounter := 0 to lvDeleteUserDocumentType.Items.Count - 1 do
    FUserDocumentTypesToDelete.Add(Integer(lvDeleteUserDocumentType.Items[ListElementCounter].Data));
  // �������� ������ �����-��������� ��������� �������� �� ��������
  FFeatureList.Clear;
  for ListElementCounter := 0 to lvCheckedInvCardField.Items.Count - 1 do
    FFeatureList.Add(TatRelationField(lvCheckedInvCardField.Items[ListElementCounter].Data).FieldName);
end;

procedure TfrmClosePeriod.TransferEntryBalance(WriteTransaction: TIBTransaction);
begin

end;

procedure TfrmClosePeriod.ReBindDepotCards(WriteTransaction: TIBTransaction);
const
  UpdateDocumentCardkeyTemplate =
    'UPDATE ' + #13#10 +
    '  %0:s line ' + #13#10 +
    'SET ' + #13#10 +
    '  line.%1:s = :new_cardkey ' + #13#10 +
    'WHERE ' + #13#10 +
    '  line.%1:s = :old_cardkey ' + #13#10 +
    '  AND (SELECT doc.documentdate FROM gd_document doc WHERE doc.id = line.documentkey) >= :closedate ';
  SearchNewCardkeyTemplate =
    'SELECT FIRST(1) ' + #13#10 +
    '  card.id AS cardkey ' + #13#10 +
    'FROM ' + #13#10 +
    '  usr$inv_document head ' + #13#10 +
    '  LEFT JOIN gd_document doc ON doc.id = head.documentkey ' + #13#10 +
    '  LEFT JOIN usr$inv_documentline line ON line.masterkey = head.documentkey ' + #13#10 +
    '  LEFT JOIN inv_card card ON card.id = line.fromcardkey ' + #13#10 +
    'WHERE ' + #13#10 +
    '  doc.documentdate = :closedate ' + #13#10 +
    '  AND card.goodkey = :goodkey ' + #13#10 +
    '  AND ' + #13#10 +
    '    ((head.usr$in_contactkey = :contact_01) ' + #13#10 +
    '    OR (head.usr$in_contactkey = :contact_02)) ';
  SearchNewCardkeySimpleTemplate =
    'SELECT FIRST(1) ' + #13#10 +
    '  card.id AS cardkey ' + #13#10 +
    'FROM ' + #13#10 +
    '  usr$inv_documentline line ' + #13#10 +
    '  JOIN gd_document doc ON doc.id = line.documentkey ' + #13#10 +
    '  JOIN inv_card card ON card.id = line.fromcardkey ' + #13#10 +
    'WHERE ' + #13#10 +
    '  doc.documentdate = :closedate ' + #13#10 +
    '  AND doc.documenttypekey = :doctypekey ' + #13#10 +
    '  AND card.goodkey = :goodkey ';
  CardkeyFieldCount = 2;
  CardkeyFieldNames: array[0..CardkeyFieldCount - 1] of String = ('FROMCARDKEY', 'TOCARDKEY');
var
  ibsql: TIBSQL;
  ibsqlSearchNewCardkey: TIBSQL;
  ibsqlUpdateCard: TIBSQL;
  ibsqlUpdateInvMovement: TIBSQL;
  ibsqlUpdateDocumentCardkey: TIBSQL;
  CurrentCardKey, CurrentFromContactkey, CurrentToContactkey: Integer;
  CurrentRelationName: String;
  gdcObject: TgdcInvDocument;
  gdcDetail: TgdcInvDocumentLine;
  dsObject: TDataSource;

  NewCardKey: Integer;

  InvDocumentInField, InvDocumentOutField: String;
  AddLineKeyFieldExists: Boolean;
  FeatureCounter: Integer;
  cFeatureList: String;
  InvDocumentTypeKey: TID;

  procedure UpdateInvCard(const OldCardkey, NewCardkey: TID);
  begin
    // ������� ������ �� ������������ ��������
    ibsqlUpdateCard.Close;
    ibsqlUpdateCard.ParamByName('OLD_PARENT').AsInteger := OldCardkey;
    ibsqlUpdateCard.ParamByName('NEW_PARENT').AsInteger := NewCardkey;
    ibsqlUpdateCard.ExecQuery;
  end;

  procedure UpdateInvMovement(const OldCardkey, NewCardkey: TID);
  begin
    // ������� ������ �� �������� �� ��������
    ibsqlUpdateInvMovement.Close;
    ibsqlUpdateInvMovement.ParamByName('OLD_CARDKEY').AsInteger := OldCardkey;
    ibsqlUpdateInvMovement.ParamByName('NEW_CARDKEY').AsInteger := NewCardkey;
    ibsqlUpdateInvMovement.ExecQuery;
  end;

  procedure UpdateDocumentCardkey(const RelationName: String; const OldCardkey, NewCardkey: TID);
  var
    I: Integer;
  begin
    for I := 0 to CardkeyFieldCount - 1 do
    begin
      try
        ibsqlUpdateDocumentCardkey.Close;
        ibsqlUpdateDocumentCardkey.SQL.Text := Format(UpdateDocumentCardkeyTemplate, [RelationName, CardkeyFieldNames[I]]);
        ibsqlUpdateDocumentCardkey.ParamByName('OLD_CARDKEY').AsInteger := OldCardkey;
        ibsqlUpdateDocumentCardkey.ParamByName('NEW_CARDKEY').AsInteger := NewCardkey;
        ibsqlUpdateDocumentCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlUpdateDocumentCardkey.ExecQuery;
      except
        // � ��������� ���������� ��� ���� TOCARDKEY
        on E: Exception do
        begin
          AddLogMessage('---'#13#10 + RelationName + #13#10 + E.Message + #13#10'---');
        end
      end;
    end;
  end;

begin
  // ������������ ��������
  FLocalStartTime := Time;
  if Assigned(pbMain) then
  begin
    pbMain.Position := 0;
    pbMain.Max := 35000;
    Self.SetProcessText(IntToStr(pbMain.Position) + ' / ' + IntToStr(pbMain.Max));
    AddLogMessage(TimeToStr(FLocalStartTime) + ': ������������ ��������� ��������...');
    UpdateWindow(Self.Handle);
  end;

  ibsql := TIBSQL.Create(Application);
  ibsqlSearchNewCardkey := TIBSQL.Create(Application);
  ibsqlUpdateCard := TIBSQL.Create(Application);
  ibsqlUpdateInvMovement := TIBSQL.Create(Application);
  ibsqlUpdateDocumentCardkey := TIBSQL.Create(Application);

  gdcObject := TgdcInvDocument.Create(Application);
  dsObject := TDataSource.Create(Application);
  gdcDetail := TgdcInvDocumentLine.Create(Application);
  try
    gdcObject.Transaction := WriteTransaction;
    gdcObject.SubType := InvDocumentRUID;
    gdcObject.SubSet := 'ByID';

    dsObject.Dataset := gdcObject;

    gdcDetail.Transaction := WriteTransaction;
    gdcDetail.MasterSource := dsObject;
    gdcDetail.MasterField := 'ID';
    gdcDetail.DetailField := 'PARENT';
    gdcDetail.SubType := InvDocumentRUID;
    gdcDetail.SubSet := 'ByParent';

    gdcObject.Open;
    gdcDetail.Open;

    // �������� �����-������ �� ��������, �� ������� � � ������� ����������� ���
    InvDocumentInField := gdcObject.MovementTarget.SourceFieldName;
    InvDocumentOutField := gdcObject.MovementSource.SourceFieldName;

    AddLineKeyFieldExists := Assigned(gdcDetail.FindField('TO_USR$INV_ADDLINEKEY'));
    InvDocumentTypeKey := gdcBaseManager.GetIDByRUIDString(InvDocumentRUID);

    // ��������� ������ �� ������������ ��������
    ibsqlUpdateCard.Transaction := WriteTransaction;
    ibsqlUpdateCard.SQL.Text :=
      'UPDATE ' + #13#10 +
      '  inv_card c ' + #13#10 +
      'SET ' + #13#10 +
      '  c.parent = :new_parent ' + #13#10 +
      'WHERE ' + #13#10 +
      '  c.parent = :old_parent ' + #13#10 +
      '  AND (SELECT FIRST(1) m.movementdate FROM inv_movement m WHERE m.cardkey = c.id) >= :closedate ';
    ibsqlUpdateCard.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlUpdateCard.Prepare;
    // ��������� � �������� ������ �� ��������� ��������
    ibsqlUpdateInvMovement.Transaction := WriteTransaction;
    ibsqlUpdateInvMovement.SQL.Text :=
      'UPDATE ' + #13#10 +
      '  inv_movement m ' + #13#10 +
      'SET ' + #13#10 +
      '  m.cardkey = :new_cardkey ' + #13#10 +
      'WHERE ' + #13#10 +
      '  m.cardkey = :old_cardkey ' + #13#10 +
      '  AND m.movementdate >= :closedate ';
    ibsqlUpdateInvMovement.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlUpdateInvMovement.Prepare;
    // ��������� � ��������������� �������� ��������� ���������� ������ �� ��������� ��������
    ibsqlUpdateDocumentCardkey.Transaction := WriteTransaction;

    // ������� ���������� �������� � ��������� ��������
    ibsqlSearchNewCardkey.Transaction := WriteTransaction;

    // ������� ������ ��������� ��������� ��������� ��������
    cFeatureList := GetFeatureFieldList('c.');
    // �������� ��� �������� ������� ��������� � �������� �� ����� ��������
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text :=
      'SELECT ' + #13#10 +
      '  CAST(0 AS INTEGER), ' + #13#10 +
      '  mfrom.contactkey AS fromcontactkey, ' + #13#10 +
      '  mto.contactkey AS tocontactkey, ' + #13#10 +
      '  linerel.relationname, ' + #13#10 +
      '  c.goodkey, ' + #13#10 +
      '  c.id AS cardkey, ' + #13#10 +
      '  c.companykey ' + #13#10 +
        IIF(cFeatureList <> '', ', ' + cFeatureList + #13#10, '') +
      'FROM ' + #13#10 +
      '  inv_card c ' + #13#10 +
      '  LEFT JOIN inv_movement mfrom ON mfrom.cardkey = c.id ' + #13#10 +
      '  LEFT JOIN inv_movement mto ON mto.cardkey = c.id ' + #13#10 +
      '  LEFT JOIN gd_document doc ON doc.id = mto.documentkey ' + #13#10 +
      '  LEFT JOIN gd_documenttype t ON t.id = doc.documenttypekey ' + #13#10 +
      '  LEFT JOIN at_relations linerel ON linerel.id = t.linerelkey ' + #13#10 +
      'WHERE ' + #13#10 +
      '  mfrom.movementdate < :closedate AND mto.movementdate >= :closedate ' + #13#10 +
      '' + #13#10 +
      'UNION ALL ' + #13#10 +
      '' + #13#10 +
      'SELECT ' + #13#10 +
      '  CAST(1 AS INTEGER), ' + #13#10 +
      '  CAST(-1 AS INTEGER), ' + #13#10 +
      '  CAST(-1 AS INTEGER), ' + #13#10 +
      '  linerel.relationname,' + #13#10 +
      '  c.goodkey, ' + #13#10 +
      '  c.id AS cardkey, ' + #13#10 +
      '  c.companykey ' + #13#10 +
        IIF(cFeatureList <> '', ', ' + cFeatureList + #13#10, '') +
      'FROM ' + #13#10 +
      '  inv_card c ' + #13#10 +
      '  LEFT JOIN inv_card c_child ON c_child.parent = c.id' + #13#10 +
      '  LEFT JOIN gd_document d_parent ON d_parent.id = c.documentkey ' + #13#10 +
      '  LEFT JOIN gd_document d_child ON d_child.id = c_child.documentkey ' + #13#10 +
      '  LEFT JOIN gd_documenttype t ON t.id = d_child.documenttypekey ' + #13#10 +
      '  LEFT JOIN at_relations linerel ON linerel.id = t.linerelkey ' + #13#10 +
      'WHERE ' + #13#10 +
      '  d_parent.documentdate < :closedate AND d_child.documentdate >= :closedate ' + #13#10 +
      'ORDER BY ' + #13#10 +
      '  1, 6 ';
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;

    while not ibsql.Eof do
    begin
      // ��� ������� Escape ������� �������
      if Self.Active and ((GetAsyncKeyState(VK_ESCAPE) shr 1) <> 0) then
      begin
        if Application.MessageBox('���������� �������� �������?', '��������',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('���������� ��������');
      end;
      // ������������ ��������
      if Assigned(pbMain) then
      begin
        pbMain.StepBy(1);
        if pbMain.Position >= pbMain.Max then
          pbMain.Max := pbMain.Max * 2;
        Self.SetProcessText(IntToStr(pbMain.Position) + ' / ' + IntToStr(pbMain.Max));
        UpdateWindow(Self.Handle);
      end;

      CurrentCardKey := ibsql.FieldByName('CARDKEY').AsInteger;
      CurrentFromContactkey := ibsql.FieldByName('FROMCONTACTKEY').AsInteger;
      CurrentToContactkey := ibsql.FieldByName('TOCONTACTKEY').AsInteger;
      CurrentRelationName := ibsql.FieldByName('RELATIONNAME').AsString;

      if (CurrentFromContactkey > 0) or (CurrentToContactkey > 0) then
      begin
        // ������ ���������� �������� ��� ������ ���������
        ibsqlSearchNewCardkey.Close;
        ibsqlSearchNewCardkey.SQL.Text := SearchNewCardkeyTemplate;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s = :%0:s ', [FFeatureList.Strings[FeatureCounter]])
          else
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s IS NULL ', [FFeatureList.Strings[FeatureCounter]]);
        end;
        ibsqlSearchNewCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlSearchNewCardkey.ParamByName('GOODKEY').AsInteger := ibsql.FieldByName('GOODKEY').AsInteger;
        ibsqlSearchNewCardkey.ParamByName('CONTACT_01').AsInteger := CurrentFromContactkey;
        ibsqlSearchNewCardkey.ParamByName('CONTACT_02').AsInteger := CurrentToContactkey;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.ParamByName(FFeatureList.Strings[FeatureCounter]).AsVariant :=
              ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).AsVariant;
        end;
        ibsqlSearchNewCardkey.ExecQuery;

        // ���� �� ����� ���������� ��������, ��������� ���������� �������� INV_DOCUMENT
        if ibsqlSearchNewCardkey.RecordCount > 0 then
        begin
          NewCardKey := ibsqlSearchNewCardkey.FieldByName('CARDKEY').AsInteger;
        end
        else
        begin
          // ����� ������� �������� �������� �������, � ������������ �� ��������� �� ��������
          gdcObject.Insert;
          gdcObject.FieldByName('DOCUMENTDATE').AsDateTime := FCloseDate;
          gdcObject.FieldByName('COMPANYKEY').AsInteger := ibsql.FieldByName('COMPANYKEY').AsInteger;
          // ���� �� ���� USR$INV_ADDLINEKEY �������� ����� ����������, �������� ������ ������� � ����
          // TODO: �������� ���� ��� ������ ���������� �� ����������
          gdcObject.FieldByName(InvDocumentOutField).AsInteger := CurrentFromContactkey;
          gdcObject.FieldByName(InvDocumentInField).AsInteger := CurrentFromContactkey;
          gdcObject.Post;

          gdcDetail.Insert;
          gdcDetail.FieldByName('GOODKEY').AsInteger := ibsql.FieldByName('GOODKEY').AsInteger;
          gdcDetail.FieldByName('QUANTITY').AsCurrency := 0;
          // �������� ���� USR$INV_ADDLINEKEY �������� ������ ������� ������� �� �������
          // TODO: �������� ���� ��� ������ ���������� �� ���������� ��������
          if AddLineKeyFieldExists then
            gdcDetail.FieldByName('TO_USR$INV_ADDLINEKEY').AsInteger := gdcDetail.ID;
          gdcDetail.Post;

          AddLogMessage(Format('������ �������� �������� ������� ID = %0:d', [gdcObject.ID]));

          NewCardKey := gdcDetail.FieldByName('FROMCARDKEY').AsInteger;
        end;
      end
      else
      begin
        // ������ ���������� �������� ��� ������ ���������
        ibsqlSearchNewCardkey.Close;
        ibsqlSearchNewCardkey.SQL.Text := SearchNewCardkeySimpleTemplate;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s = :%0:s ', [FFeatureList.Strings[FeatureCounter]])
          else
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s IS NULL ', [FFeatureList.Strings[FeatureCounter]]);
        end;
        ibsqlSearchNewCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlSearchNewCardkey.ParamByName('DOCTYPEKEY').AsInteger := InvDocumentTypeKey;
        ibsqlSearchNewCardkey.ParamByName('GOODKEY').AsInteger := ibsql.FieldByName('GOODKEY').AsInteger;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.ParamByName(FFeatureList.Strings[FeatureCounter]).AsVariant :=
              ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).AsVariant;
        end;
        ibsqlSearchNewCardkey.ExecQuery;

        if ibsqlSearchNewCardkey.RecordCount > 0 then
          NewCardKey := ibsqlSearchNewCardkey.FieldByName('CARDKEY').AsInteger
        else
          NewCardKey := -1;
      end;

      if NewCardKey > 0 then
      begin
        UpdateInvCard(CurrentCardKey, NewCardKey);                                // ������� ������ �� ������������ ��������
        UpdateInvMovement(CurrentCardKey, NewCardKey);                            // ������� ������ �� �������� �� ��������
        UpdateDocumentCardkey(CurrentRelationName, CurrentCardKey, NewCardKey);   // ������� ������ �� �������� � ��������� ����������
      end;

      ibsql.Next;
    end;

    // ������������ ��������
    if Assigned(pbMain) then
    begin
      pbMain.Max := pbMain.Position;
      Self.SetProcessText(IntToStr(pbMain.Position) + ' / ' + IntToStr(pbMain.Max));
      AddLogMessage(TimeToStr(Time) + ': �������� ������� ������������ ��������� ��������...');
      AddLogMessage('����������������� ��������: ' + TimeToStr(Time - FLocalStartTime));
      UpdateWindow(Self.Handle);
    end;

    gdcDetail.Close;
    gdcObject.Close;
  finally
    gdcDetail.Free;
    dsObject.Free;
    gdcObject.Free;

    ibsqlUpdateDocumentCardkey.Free;
    ibsqlUpdateInvMovement.Free;
    ibsqlUpdateCard.Free;
    ibsqlSearchNewCardkey.Free;
    ibsql.Free;
  end;
end;

procedure TfrmClosePeriod.actChooseDontDeleteDocumentTypeExecute(Sender: TObject);
var
  gdcDocumentType: TgdcDocumentType;
  I: Integer;
  Item: TListItem;
  A: OleVariant;
begin
  gdcDocumentType := TgdcDocumentType.Create(Self);
  try
    gdcDocumentType.Transaction := gdcBaseManager.ReadTransaction;
    gdcDocumentType.ExtraConditions.Add('classname = ''TgdcInvDocumentType''');
    gdcDocumentType.Open;

    for I := 0 to lvDontDeleteDocumentType.Items.Count - 1 do
    begin
      gdcDocumentType.SelectedID.Add(Integer(lvDontDeleteDocumentType.Items.Item[I].Data));
    end;

    if gdcDocumentType.ChooseItems(A) then
    begin
      gdcDocumentType.Close;
      gdcDocumentType.SubSet := 'OnlySelected';
      gdcDocumentType.Open;
      gdcDocumentType.First;

      lvDontDeleteDocumentType.Items.Clear;

      while not gdcDocumentType.Eof do
      begin
        Item := lvDontDeleteDocumentType.Items.Add;
        Item.Caption := gdcDocumentType.FieldByName('NAME').AsString;
        Item.Data := Pointer(gdcDocumentType.FieldByName('ID').AsInteger);

        gdcDocumentType.Next;
      end;
    end;
  finally
    gdcDocumentType.Free;
  end;
end;

procedure TfrmClosePeriod.actDeleteDontDeleteDocumentTypeExecute(Sender: TObject);
var
  I: Integer;
begin
  if lvDontDeleteDocumentType.SelCount > 0 then
  begin
    if lvDontDeleteDocumentType.SelCount = 1 then
    begin
      lvDontDeleteDocumentType.Items.Item[lvDontDeleteDocumentType.Selected.Index].Delete;
    end
    else
    begin
      I := 0;
      while I < lvDontDeleteDocumentType.Items.Count do
      begin
        if lvDontDeleteDocumentType.Items[I].Selected then
          lvDontDeleteDocumentType.Items.Item[I].Delete
        else
          Inc(I);
      end;
    end;
  end;
end;

procedure TfrmClosePeriod.actDeleteDontDeleteDocumentTypeUpdate(Sender: TObject);
begin
  actDeleteDontDeleteDocumentType.Enabled := (lvDontDeleteDocumentType.Items.Count > 0);
end;

procedure TfrmClosePeriod.actChooseUserDocumentToDeleteExecute(Sender: TObject);
var
  gdcDocumentType: TgdcDocumentType;
  I: Integer;
  Item: TListItem;
  A: OleVariant;
begin
  gdcDocumentType := TgdcDocumentType.Create(Self);
  try
    gdcDocumentType.Transaction := gdcBaseManager.ReadTransaction;
    gdcDocumentType.ExtraConditions.Add('classname = ''TgdcUserDocumentType''');
    gdcDocumentType.Open;

    for I := 0 to lvDontDeleteDocumentType.Items.Count - 1 do
    begin
      gdcDocumentType.SelectedID.Add(Integer(lvDeleteUserDocumentType.Items.Item[I].Data));
    end;

    if gdcDocumentType.ChooseItems(A) then
    begin
      gdcDocumentType.Close;
      gdcDocumentType.SubSet := 'OnlySelected';
      gdcDocumentType.Open;
      gdcDocumentType.First;

      lvDeleteUserDocumentType.Items.Clear;

      while not gdcDocumentType.Eof do
      begin
        Item := lvDeleteUserDocumentType.Items.Add;
        Item.Caption := gdcDocumentType.FieldByName('NAME').AsString;
        Item.Data := Pointer(gdcDocumentType.FieldByName('ID').AsInteger);

        gdcDocumentType.Next;
      end;
    end;
  finally
    gdcDocumentType.Free;
  end;
end;

procedure TfrmClosePeriod.actDeleteUserDocumentToDeleteExecute(Sender: TObject);
var
  I: Integer;
begin
  if lvDeleteUserDocumentType.SelCount > 0 then
  begin
    if lvDeleteUserDocumentType.SelCount = 1 then
    begin
      lvDeleteUserDocumentType.Items.Item[lvDeleteUserDocumentType.Selected.Index].Delete;
    end
    else
    begin
      I := 0;
      while I < lvDeleteUserDocumentType.Items.Count do
      begin
        if lvDeleteUserDocumentType.Items[I].Selected then
          lvDeleteUserDocumentType.Items.Item[I].Delete
        else
          Inc(I);
      end;
    end;
  end;
end;

procedure TfrmClosePeriod.actDeleteUserDocumentToDeleteUpdate(Sender: TObject);
begin
  actDeleteUserDocumentToDelete.Enabled := (lvDeleteUserDocumentType.Items.Count > 0);
end;

procedure TfrmClosePeriod.InitialFillInvCardFields;
var
  INV_CARD: TatRelation;
  FieldCounter: Integer;
  Item: TListItem;
  SelectedFieldIndex: Integer;
begin
  INV_CARD := atDatabase.Relations.ByRelationName('INV_CARD');

  // ������� ��������� ����� �������� ��������� �������� �� ���������
  if Assigned(GlobalStorage) then
    FFeatureList.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'InvFeatureList', '')
  else
    FFeatureList.Clear;  

  // �������� ������ �����-��������� ��������� ��������
  for FieldCounter := 0 to INV_CARD.RelationFields.Count - 1 do
  begin
    if INV_CARD.RelationFields.Items[FieldCounter].IsUserDefined
       and (AnsiCompareStr(INV_CARD.RelationFields.Items[FieldCounter].FieldName, 'USR$INV_ADDLINEKEY') <> 0)
       and (AnsiCompareStr(INV_CARD.RelationFields.Items[FieldCounter].FieldName, 'USR$INV_MOVEDOCKEY') <> 0) then
    begin
      // ���� ����� ���� ������� ��� ��������, �� ������� ��� � ������ ���������
      SelectedFieldIndex := FFeatureList.IndexOf(INV_CARD.RelationFields[FieldCounter].FieldName);
      if SelectedFieldIndex > -1 then
        Item := lvCheckedInvCardField.Items.Add
      else
        Item := lvAllInvCardField.Items.Add;

      // ���� ������� �������������� ��� ����, ����� ������������ ���
      if INV_CARD.RelationFields[FieldCounter].LName > '' then
        Item.Caption := Trim(INV_CARD.RelationFields[FieldCounter].LName)
      else
        Item.Caption := Trim(INV_CARD.RelationFields[FieldCounter].FieldName);

      Item.Data := INV_CARD.RelationFields[FieldCounter];
    end;
  end;
end;

procedure TfrmClosePeriod.MoveInvCardField(FromList, ToList: TListView);
var
  Item: TListItem;
  Index: Integer;
begin
  if Assigned(FromList.Selected) then
  begin
    Item := ToList.Items.Add;
    Item.Caption := FromList.Selected.Caption;
    Item.Data := FromList.Selected.Data;

    Index := FromList.Selected.Index;
    FromList.Selected.Delete;

    if Index < FromList.Items.Count then
      FromList.Selected := FromList.Items[Index] else
    if FromList.Items.Count > 0 then
      FromList.Selected := FromList.Items[FromList.Items.Count - 1];
  end;
end;

procedure TfrmClosePeriod.lvAllInvCardFieldDblClick(Sender: TObject);
begin
  MoveInvCardField(lvAllInvCardField, lvCheckedInvCardField);
end;

procedure TfrmClosePeriod.lvCheckedInvCardFieldDblClick(Sender: TObject);
begin
  MoveInvCardField(lvCheckedInvCardField, lvAllInvCardField);
end;

procedure TfrmClosePeriod.InitialSetupForm;
begin
  // �������� ������ ����� ��������� ��������
  InitialFillInvCardFields;
  InitialFillOptions;
end;

procedure TfrmClosePeriod.InitialFillOptions;
var
  DefaultDate: TDateTime;
begin
  DefaultDate := EncodeDate(2009, 1, 1);
  if Assigned(GlobalStorage) then
  begin
    // ��������� ������� ���� �������� �� ���������
    xdeCloseDate.Date := GlobalStorage.ReadDateTime('Options\InvClosePeriod', 'CloseDate', DefaultDate);
    // ������� ������ '�����������' ���� �� ���������
    eExtDatabase.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'ExternalDatabase', '');
    eExtUser.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'ExternalUser', '');
    eExtServer.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'ExternalServer', '');
    eExtPassword.Text := GlobalStorage.ReadString('Options\InvClosePeriod', 'ExternalPassword', '');
  end
  else
  begin
    xdeCloseDate.Date := DefaultDate;
    eExtDatabase.Text := '';
    eExtUser.Text := '';
    eExtServer.Text := '';
    eExtPassword.Text := '';
  end;
end;

procedure TfrmClosePeriod.SaveSettingsToStorage;
begin
  if Assigned(GlobalStorage) then
  begin
    GlobalStorage.WriteDateTime('Options\InvClosePeriod', 'CloseDate', xdeCloseDate.Date);
    GlobalStorage.WriteString('Options\InvClosePeriod', 'ExternalDatabase', eExtDatabase.Text);
    GlobalStorage.WriteString('Options\InvClosePeriod', 'ExternalUser', eExtUser.Text);
    GlobalStorage.WriteString('Options\InvClosePeriod', 'ExternalServer', eExtServer.Text);
    GlobalStorage.WriteString('Options\InvClosePeriod', 'ExternalPassword', eExtPassword.Text);

    GlobalStorage.WriteString('Options\InvClosePeriod', 'InvFeatureList', FFeatureList.Text);
  end;
end;

procedure TfrmClosePeriod.TryToDeleteDocumentReferences(AID: TID; AdditionalRelationName: String; Transaction: TIBTransaction);
var
  TableReferenceIndex: Integer;
  OL: TObjectList;
  ibsql, ibsqlUpdate, ibsqlSelect: TIBSQL;
  ReferencesRelationName, ReferencesFieldName: String;
  AdditionalFieldName: String;
  ForeignKeyCounter: Integer;
begin
  // �������� ��� ���������� ������� ������ ������� ������, ���� ��� ��� ���
  if not FTableReferenceForeignKeysList.Find(AdditionalRelationName, TableReferenceIndex) then
  begin
    // �������� ����� ������ ������� ������ ����������� �� ���������� �������
    TableReferenceIndex := FTableReferenceForeignKeysList.AddObject(AdditionalRelationName, TObjectList.Create(False));
    OL := TObjectList.Create(False);
    try
      // ������� ������ ������� ������ ����������� �� ���������� �������
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(AdditionalRelationName, OL);
      // ������� ������ ������� ������� �����
      for ForeignKeyCounter := 0 to OL.Count - 1 do
      begin
        if TatForeignKey(OL.Items[ForeignKeyCounter]).IsSimpleKey
           and TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.IsUserDefined then
          TObjectList(FTableReferenceForeignKeysList.Objects[TableReferenceIndex]).Add(OL.Items[ForeignKeyCounter]);
      end;
    except
      OL.Free;
    end;
  end;

  // ������� �� ������ ������� ������, � ������ ������ ����������� �� ����������
  OL := TObjectList(FTableReferenceForeignKeysList.Objects[TableReferenceIndex]);
  ibsql := TIBSQL.Create(Self);
  ibsqlUpdate := TIBSQL.Create(Self);
  ibsqlSelect := TIBSQL.Create(Self);
  try
    ibsql.Transaction := Transaction;
    ibsqlUpdate.Transaction := Transaction;
    ibsqlSelect.Transaction := Transaction;
    // ���� �� ������� ������
    for ForeignKeyCounter := 0 to OL.Count - 1 do
    begin
      // ��� ������� ������� �������� ������ �� ���������� ������
      ReferencesRelationName := TatForeignKey(OL[ForeignKeyCounter]).Relation.RelationName;
      // ��� ����-������ �� ���������� ������
      ReferencesFieldName := TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.FieldName;
      // ��� ���� �� ������� AdditionalRelationName �� ������� ��������� ReferencesFieldName
      AdditionalFieldName := TatForeignKey(OL.Items[ForeignKeyCounter]).ReferencesField.FieldName;
      // ������ ������ ����������� �� ���������� ������ � ������� �� �������� �������� �����
      ibsql.Close;
      ibsql.SQL.Text := Format('SELECT * FROM %0:s WHERE %1:s = :aid', [ReferencesRelationName, ReferencesFieldName]);
      ibsql.ParamByName('AID').AsInteger := AID;
      ibsql.ExecQuery;
      // ���� ����� ������
      if ibsql.RecordCount > 0 then
      begin
        // ���� ����-������ ����� ��������, ������� ���.
        // TODO: ����� �������� ������ �� ����� ������ ���������� ������ ???
        if TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.IsNullable then
        begin
          ibsqlUpdate.Close;
          ibsqlUpdate.SQL.Text := Format('UPDATE %0:s SET %1:s = NULL WHERE %1:s = :aid', [ReferencesRelationName, ReferencesFieldName]);
          ibsqlUpdate.ParamByName('AID').AsInteger := AID;
          ibsqlUpdate.ExecQuery;
        end
        else
        begin
          ////
          AddLogMessage(Format('NOT NULL: %1:s(%2:s) -> %0:s', [AdditionalRelationName, ReferencesRelationName, ReferencesFieldName]));
          ////
          {ibsqlSelect.Close;
          ibsqlSelect.SQL.Text := Format('SELECT FIRST(1) %1:s FROM %0:s WHERE %1:s = :aid', [AdditionalRelationName, AdditionalFieldName]);
          ibsqlSelect.ExecQuery;

          if ibsqlSelect.RecordCount > 0 then
          begin

          end;}
        end;
      end;
    end;
  finally
    ibsqlSelect.Free;
    ibsqlUpdate.Free; 
    ibsql.Free;
  end;
end;

function TfrmClosePeriod.AddLogMessage(const AMessage: String; const ALineNumber: Integer = -1): Integer;
begin
  if ALineNumber > 0 then
  begin
    Result := ALineNumber;
    FMessageLog.Strings[ALineNumber] := AMessage;
    mOutput.Lines.Strings[ALineNumber] := AMessage;
  end
  else
  begin
    Result := FMessageLog.Add(AMessage);
    mOutput.Lines.Add(AMessage);
  end;
end;

procedure TfrmClosePeriod.SaveLogToFile;
var
  SD: TSaveDialog;
begin
  SD := TSaveDialog.Create(Self);
  try
    SD.Title := '��������� ��� � ���� ';
    SD.DefaultExt := 'txt';
    SD.Filter := '��������� ����� (*.txt)|*.TXT|' +
      '��� ����� (*.*)|*.*';
    SD.FileName := 'close_log';
    if SD.Execute then
      FMessageLog.SaveToFile(SD.FileName);
  finally
    SD.Free;
  end;
end;

initialization
  RegisterClass(TfrmClosePeriod);
finalization
  UnRegisterClass(TfrmClosePeriod);

end.
