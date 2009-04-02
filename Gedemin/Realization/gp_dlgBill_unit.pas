unit gp_dlgBill_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, ExtCtrls, ComCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid,
  gsIBCtrlGrid, Mask, xDateEdits, StdCtrls, DBCtrls, gsIBLookupComboBox,
  IBDatabase, Db, IBCustomDataSet, gd_security, dmDatabase_unit, ToolWin,
  ActnList, IBSQL, at_sql_setup, at_Controls, at_Classes, contnrs, xCalc,
  boCurrency,  Menus, at_Container,
  FrmPlSvr, Buttons;

type
  Tgp_dlgBill = class(TCreateableForm)
    pcBill: TPageControl;               
    tsMain: TTabSheet;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    gsibgrDocRealPos: TgsIBCtrlGrid;
    Label1: TLabel;
    dbedNumber: TDBEdit;
    Label2: TLabel;
    ddbDocumentDate: TxDateDBEdit;
    Label3: TLabel;
    gsiblcFromContact: TgsIBLookupComboBox;
    Label4: TLabel;
    gsiblcToContact: TgsIBLookupComboBox; 
    Label5: TLabel;
    gsiblcCurr: TgsIBLookupComboBox;
    Label6: TLabel;
    dbedRate: TDBEdit;
    Button1: TButton;
    Panel4: TPanel;
    bOk: TButton;
    Button3: TButton;
    Button4: TButton;
    ibdsDocument: TIBDataSet;
    IBTransaction: TIBTransaction;
    ibdsDocRealization: TIBDataSet;
    ibdsDocRealPos: TIBDataSet;
    Label7: TLabel;
    gsiblcPrice: TgsIBLookupComboBox;
    Label8: TLabel;
    dsDocRealPos: TDataSource;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ActionList1: TActionList;
    actChoose: TAction;
    actDelete: TAction;
    ToolButton2: TToolButton;
    gsiblcGood: TgsIBLookupComboBox;
    gsiblcValue: TgsIBLookupComboBox;
    gsiblcWeight: TgsIBLookupComboBox;
    gsiblcPack: TgsIBLookupComboBox;
    edCostCurr: TEdit;
    actOk: TAction;
    actCancel: TAction;
    actNext: TAction;
    actHelp: TAction;
    dsDocRealization: TDataSource;
    dsDocument: TDataSource;
    ibsqlGood: TIBSQL;
    ibsqlValue: TIBSQL;
    ibdsDocRealInfo: TIBDataSet;
    dsDocRealInfo: TDataSource;
    TabSheet3: TTabSheet;
    atSQLSetup: TatSQLSetup;
    cbPriceField: TComboBox;
    xFoCal: TxFoCal;
    Label25: TLabel;
    ddeDatePayment: TxDateDBEdit;
    actDolg: TAction;
    actAmount: TAction;
    cbAmount: TCheckBox;
    lvAmount: TListView;
    boCurrency: TboCurrency;
    pGridMenu: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    actSetTrType: TAction;
    N3: TMenuItem;
    actChangeTransaction: TAction;
    N4: TMenuItem;
    atContainer: TatContainer;
    PopupMenu1: TPopupMenu;
    ibsqlCheckNumber: TIBSQL;
    FormPlaceSaver: TFormPlaceSaver;
    edCostNCU: TEdit;
    actCalcAmount: TAction;
    dbedContract: TDBEdit;
    Label29: TLabel;
    ibsqlPack: TIBSQL;
    SpeedButton1: TSpeedButton;
    actAddContract: TAction;
    dbcbDelayed: TDBCheckBox;
    Label9: TLabel;
    dbedDescription: TDBEdit;
    IBTranLookup: TIBTransaction;
    procedure actDeleteExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actNextExecute(Sender: TObject);

    procedure edCostNCUExit(Sender: TObject);
    procedure edCostCurrExit(Sender: TObject);
    procedure ibdsDocumentCURRKEYChange(Sender: TField);
    procedure FormDestroy(Sender: TObject);
    procedure gsibgrDocRealPosSetCtrl(Sender: TObject; Ctrl: TWinControl;
      Column: TColumn; var Show: Boolean);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDolgExecute(Sender: TObject);
    procedure cbAmountClick(Sender: TObject);
    procedure ibdsDocRealPosAfterPost(DataSet: TDataSet);
    procedure ibdsDocRealPosAfterDelete(DataSet: TDataSet);
    procedure ibdsDocRealPosAfterInsert(DataSet: TDataSet);
    procedure ibdsDocRealPosBeforeInsert(DataSet: TDataSet);
    procedure gsiblcFromContactChange(Sender: TObject);
    procedure ibdsDocRealPosBeforePost(DataSet: TDataSet);
    procedure ibdsDocRealPosAfterScroll(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure gsiblcGoodExit(Sender: TObject);
    procedure gsibgrDocRealPosEnter(Sender: TObject);
    procedure actCalcAmountExecute(Sender: TObject);
    procedure ibdsDocRealInfoAfterInsert(DataSet: TDataSet);
    procedure actAddContractExecute(Sender: TObject);
    procedure gsiblcGoodEnter(Sender: TObject);
    procedure gsiblcGoodKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FDocumentKey: Integer;         // Ключ текущего документа
    FCheckNumber: Boolean;         // Контроль номера накладной
    FisAppend: Boolean;             // Режим добавления
    FDocumentType: Integer;
    FisTransactionChange: Boolean;  // Изменена операция по позиции

    FisCurrChange: Boolean;         // Изменена Цена в валюте
    FisNCUChange: Boolean;          // Изменена Цена в НДЕ

    FisAmountNCUChange: Boolean;    // Изменена Сумма в валюте
    FisAmountCurrChange: Boolean;   // Изменена Сумма в НДЕ
    FTaraGroup: TStringList;        // Список кодов с группами тары

    FisLocalQuantity: Boolean;         // Изменено количество в коде
    FisLocalPackQuantChange: Boolean;  // Изменено кол-во упаковок в коде

    FPriceKey: Integer;           // Ключ текущего прайс-листа

    FTaxList: TObjectList;        // Список налогов
    FWeightKey: Integer;          // Единица измерения для веса
    FPriceWithContact: Boolean;   // Жесткая привязка прайс-листа к контакту


    FTypeShowDisabledGood: Integer; // Тип отображения отключенного ТМЦ

    FCity: String;
    FCityCustomer: String;
    FAutoMakeTransaction: Boolean; // Автоматически формировать операцию

    FLocalChange: Boolean; // Изменения данных производится программно при этом игнорируются
                           // все Event

    procedure AppendDocument;     // Формирует новый документ
    procedure CopyDocument(const aCopyID: Integer); // Создает новый документ путем копирования
    procedure JoinRecord;         // Объединение записей

    function CheckDublicate: Boolean; // Поиск совпадений номеров
    function SaveData: Boolean;       // Сохранение документа
    procedure CancelData;             // Отмена изменений
    procedure CalcPack;               // Расчет количество упаковок
    procedure CalcWeight;             // Расчет веса
    procedure CalcAmount;             // Расчет суммы по позиции
    procedure CalcCurr;               // Расчет валютной цены от рублевой
    procedure CalcNCU;                // Расчет рублевой цены от валютной
    procedure SetCurrencyField;       // Устанавливает или скрывает валютные поля
    procedure SetPriceField;          // Выбор доступных полей из прайс листа
    procedure SetDocRealPosField;     // Добавление дополнительных полей по позициям накладной
    procedure SetChangeField;         // Установка Event на изменения нужных полей

    procedure SetCurPriceField(aFieldName: String); // Установка текущего поля прайс-листа
    procedure ToContactKeyChange(Sender: TField);   // Действие на изменение поля кому
    procedure DoOtherFieldChange(Sender: TField);   // Действия на изменения полей с налогами
    procedure DoPriceKeyChange(Sender: TField);     // Действие на изменение поля прайс-лист
    procedure DocumentDateChange(Sender: TField);   // Действие на изменение поля Дата
    procedure TransSumNCUChange(Sender: TField);    // Действие на изменение поля Сумма трансп.НДЕ
    procedure TransSumCurrChange(Sender: TField);   // Действие на изменение поля Сумма трансп.Вал
    procedure DocumentNumberChange(Sender: TField); // Действие на изменение поля номер документа
    procedure CalcTax;                              // Расчет налогов
    procedure CalcAmountBill;                       // Расчет сумм по накладной
    procedure CalcAmountTax(Num: Integer);          // Расчет суммы с налогом
    procedure DoChangeField(Sender: TField);        // Стандартное действие на изменение прочих полей

    procedure ibdsDocRealPosGOODKEYChange(Sender: TField); // Действие на изменение поля Товар
    procedure ibdsDocRealPosVALUEKEYChange(Sender: TField); // Действие на изменение поля ед.изм.
    procedure ibdsDocRealPosWEIGHTKEYChange(Sender: TField); // Действие на изменение поля ед.изм. вес
    procedure ibdsDocRealPosPACKKEYChange(Sender: TField); // Действие на изменение поля вид упак.
    procedure ibdsDocRealPosPACKINQUANTChange(Sender: TField); // Действие на изменение поля кол-во в упак
    procedure ibdsDocRealPosQUANTITYChange(Sender: TField);  // Действие на изменение поля количество
    procedure ibdsDocRealPosPackQUANTITYChange(Sender: TField); // Дейчтвие на изменение кол-во упаковок
    procedure ibdsDocRealPosCostNCUChange(Sender: TField); // Действие на изменение поля цена НДЕ
    procedure ibdsDocRealPosCOSTCURRChange(Sender: TField); // Действие на изменение поля цена вал.
    procedure ibdsDocRealPosAmountNCUChange(Sender: TField); // Действие на изменение поля сумма НДЕ
    procedure ibdsDocRealPosAMOUNTCURRChange(Sender: TField); // Действие на изменение поля сумма вал.
    function CalcTransTax(const Current: Integer): Currency; // Расчет налогов с транспорта
    procedure SetConditionGood;
    procedure SetGroupTara;

  protected

    function BeforeSave: Boolean; virtual;
    function BeforeSetup: Boolean; virtual;
    function AfterSetup: Boolean; virtual;
    function AfterSave: Boolean; virtual;

    procedure MakeOnChangeField(Sender: TField); virtual;

    property AutoMakeTransaction: Boolean read FAutoMakeTransaction;
    property LocalChange: Boolean read FLocalChange write FLocalChange;

  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure SetupDialog(const aDocumentKey, aCopyBill: Integer); // Инициализация документа
    property DocumentType: Integer read FDocumentType write FDocumentType;
    property DocumentKey: Integer read FDocumentKey; // Код документа
  end;

var
  gp_dlgBill: Tgp_dlgBill;

implementation

{$R *.DFM}

uses
  tr_type_unit, gp_dlgContractSell_unit, gp_common_real_unit, Storages;

{ Tgp_dlgBill }

procedure Tgp_dlgBill.ToContactKeyChange(Sender: TField);
var
  ibsql: TIBSQL;
  DocNumber: String;
  DocDate: TDate;
  DocId: Integer;
begin
  SetCurPriceField('');
  if (Sender.AsInteger > 0) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := IBTransaction;

      DocNumber := '';
      DocDate := 0;
      DocID := -1;

      ibsql.SQL.Text := 'SELECT doc.id, doc.number, doc.documentdate FROM gd_contract c ' +
        ' JOIN gd_document doc ON c.documentkey = doc.id and c.contactkey = :ck ' +
        ' ORDER BY doc.documentdate ';
      ibsql.ParamByName('ck').AsInteger := Sender.AsInteger;
      ibsql.ExecQuery;
      while not ibsql.EOF do
      begin
        if ibsql.FieldByName('documentdate').AsDateTime >
           ibdsDocument.FieldByName('documentdate').AsDateTime
        then
          Break;
        DocNumber := ibsql.FieldByName('number').AsString;
        DocDate := ibsql.FieldByName('documentdate').AsDateTime;
        DocId := ibsql.FieldByName('id').AsInteger;
        ibsql.Next;
      end;
      ibsql.Close;
      if DocDate <> 0 then
      begin
        if not (ibdsDocRealInfo.State in [dsEdit, dsInsert]) then
          ibdsDocRealInfo.Edit;
        ibdsDocRealInfo.FieldByName('contractkey').AsInteger := DocID;
        ibdsDocRealInfo.FieldByName('contractnum').AsString := Format('N %s от %s',
          [DocNumber, DateToStr(DocDate)]);
      end;

      if (ibdsDocRealInfo.FieldByName('UnLoadingpoint').AsString = '') then
      begin
        ibsql.SQL.Text := 'SELECT CITY FROM gd_contact WHERE id = :id';
        ibsql.Prepare;
        ibsql.ParamByName('id').AsInteger := Sender.AsInteger;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          FCityCustomer := ibsql.Fields[0].AsString
        else
          FCityCustomer := '';
        ibsql.Close;
        if ibdsDocRealInfo.State in [dsEdit, dsInsert] then
          ibdsDocRealInfo.FieldByName('UnLoadingPoint').AsString := FCityCustomer;
      end;
    finally
      ibsql.Free;
    end;
  end;
end;

procedure Tgp_dlgBill.actDeleteExecute(Sender: TObject);
begin
  { Удаление позиции }
  if MessageBox(HANDLE, PChar(Format('Удалить позицию ''%s?''',
    [ibdsDocRealPos.FieldByName('name').AsString])),
    'Внимание', mb_YesNo or mb_IconQuestion) = id_Yes
  then
    ibdsDocRealPos.Delete;
end;

procedure Tgp_dlgBill.AppendDocument;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text :=
      Format(
      'SELECT * FROM gd_price WHERE ' +
      'relevancedate = (SELECT MAX(relevanceDATE) FROM gd_price WHERE relevanceDATE <= ''%S'' ' +
      ' and pricetype = ''C'') and pricetype = ''C''',
      [DateToStr(Date)]);
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      FPriceKey := ibsql.FieldByName('id').AsInteger
    else
      FPriceKey := -1;
    ibsql.Close;
    FDocumentKey := GenUniqueID;
    ibsql.SQL.Text := 'INSERT INTO gd_document (' +
      'id, documenttypekey, trtypekey, number, documentdate, ' +
      'afull, achag, aview, companykey, creatorkey, creationdate, editorkey, editiondate, ' +
      'disabled, delayed, reserved) ' +
      'VALUES (' +
      ':id, :documenttypekey, :trtypekey, :number, :documentdate, ' +
      ':afull, :achag, :aview, :companykey, :creatorkey, :creationdate, :editorkey, :editiondate, ' +
      ':disabled, :delayed, :reserved) ';
    ibsql.Prepare;
    ibsql.Params.ByName('id').AsInteger := FDocumentKey;
    ibsql.Params.ByName('documenttypekey').AsInteger := FDocumentType; //!
    ibsql.Params.ByName('trtypekey').Clear;
    ibsql.Params.ByName('number').AsString := '';
    ibsql.Params.ByName('documentdate').AsDateTime := Date;
    ibsql.Params.ByName('afull').AsInteger := -1;
    ibsql.Params.ByName('achag').AsInteger := -1;
    ibsql.Params.ByName('aview').AsInteger := -1;
    ibsql.Params.ByName('companykey').AsInteger := IBLogin.CompanyKey;
    ibsql.Params.ByName('creatorkey').AsInteger := IBLogin.ContactKey;
    ibsql.Params.ByName('creationdate').AsDateTime := Now;
    ibsql.Params.ByName('editorkey').AsInteger := IBLogin.ContactKey;
    ibsql.Params.ByName('editiondate').AsDateTime := Now;
    ibsql.Params.ByName('disabled').AsInteger := 0;
    ibsql.Params.ByName('delayed').AsInteger := 0;
    ibsql.Params.ByName('reserved').Clear;
    ibsql.ExecQuery;
    ibsql.Close;

    ibsql.SQL.Text := 'SELECT city FROM gd_contact WHERE id = :id';
    ibsql.Prepare;
    ibsql.ParamByName('id').AsInteger := IBLogin.CompanyKey;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      FCity := ibsql.Fields[0].AsString;
    ibsql.Close;

  finally
    ibsql.Free;
  end;
end;

procedure Tgp_dlgBill.FormCreate(Sender: TObject);
var
  OldOnExit: TNotifyEvent;
  OldOnKeyDown: TKeyEvent;
begin
  FLocalChange := False;
  
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  if not IBTranLookup.InTransaction then
    IBTranLookup.StartTransaction;  

  FTaraGroup := TStringList.Create;


  FisLocalQuantity := False;
  FisLocalPackQuantChange := False;
  FTaxList := TObjectList.Create;

  OldOnExit := gsiblcGood.OnExit;
  OldOnKeyDown := gsiblcGood.OnKeyDown;
  gsibgrDocRealPos.AddControl('NAME', gsiblcGood, OldOnExit,
    OldOnKeyDown);
  gsiblcGood.OnExit := OldOnExit;
  gsiblcGood.OnKeyDown := OldOnKeyDown;

  OldOnExit := gsiblcValue.OnExit;
  OldOnKeyDown := gsiblcValue.OnKeyDown;
  gsibgrDocRealPos.AddControl('VALUENAME', gsiblcValue, OldOnExit,
    OldOnKeyDown);
  gsiblcValue.OnExit := OldOnExit;
  gsiblcValue.OnKeyDown := OldOnKeyDown;

  OldOnExit := gsiblcWeight.OnExit;
  OldOnKeyDown := gsiblcWeight.OnKeyDown;
  gsibgrDocRealPos.AddControl('WEIGHTNAME', gsiblcWeight, OldOnExit,
    OldOnKeyDown);
  gsiblcWeight.OnExit := OldOnExit;
  gsiblcWeight.OnKeyDown := OldOnKeyDown;

  OldOnExit := gsiblcPack.OnExit;
  OldOnKeyDown := gsiblcPack.OnKeyDown;
  gsibgrDocRealPos.AddControl('PACKNAME', gsiblcPack, OldOnExit,
    OldOnKeyDown);
  gsiblcPack.OnExit := OldOnExit;
  gsiblcPack.OnKeyDown := OldOnKeyDown;

  OldOnExit := edCostNCU.OnExit;
  OldOnKeyDown := edCostNCU.OnKeyDown;
  gsibgrDocRealPos.AddControl('CostNCU', edCostNCU, OldOnExit,
    OldOnKeyDown);
  edCostNCU.OnExit := OldOnExit;
  edCostNCU.OnKeyDown := OldOnKeyDown;

  OldOnExit := edCostCURR.OnExit;
  OldOnKeyDown := edCostCURR.OnKeyDown;
  gsibgrDocRealPos.AddControl('COSTCURR', edCostCURR, OldOnExit,
    OldOnKeyDown);
  edCostCURR.OnExit := OldOnExit;
  edCostCURR.OnKeyDown := OldOnKeyDown;

  SetPriceField;
  SetDocRealPosField;

  UserStorage.LoadComponent(gsibgrDocRealPos, gsibgrDocRealPos.LoadFromStream);
end;

procedure Tgp_dlgBill.SetupDialog(const aDocumentKey, aCopyBill: Integer);
var
  i: Integer;
  LC: TListColumn;
  R: TatRelationField;
  S: String;
begin
  FLocalChange := False;
  
  if not BeforeSetup then abort;

  FTypeShowDisabledGood := GlobalStorage.ReadInteger('realzaitionoption', 'disabledgoodshow', 0);
  FAutoMakeTransaction :=
    GlobalStorage.ReadInteger('realzaitionoption', 'automaketransaction', 0) = 1;
  FCheckNumber :=
    UserStorage.ReadInteger('realzaitionoption', 'checknumber', 0) = 1;
  FPriceWithContact :=
    GlobalStorage.ReadInteger('realzaitionoption', 'pricewithcontact', 0) = 1;
  FWeightKey := GlobalStorage.ReadInteger('realzaitionoption', 'weightkey', 0);

  if FTypeShowDisabledGood = 0 then
    gsiblcGood.Condition := 'DISABLED = 0 AND ' +
      ' ((gr.lb >= (SELECT lb FROM gd_goodgroup WHERE id = 147000003) and ' +
      '   gr.rb <= (SELECT rb FROM gd_goodgroup WHERE id = 147000003)) OR ' +
      '  (gr.lb >= (SELECT lb FROM gd_goodgroup WHERE id = 147003071) and ' +
      '   gr.rb <= (SELECT rb FROM gd_goodgroup WHERE id = 147003071))) '

  else
    gsiblcGood.Condition :=
      ' ((gr.lb >= (SELECT lb FROM gd_goodgroup WHERE id = 147000003) and ' +
      '   gr.rb <= (SELECT rb FROM gd_goodgroup WHERE id = 147000003)) OR ' +
      '  (gr.lb >= (SELECT lb FROM gd_goodgroup WHERE id = 147003071) and ' +
      '   gr.rb <= (SELECT rb FROM gd_goodgroup WHERE id = 147003071))) ';


  FCityCustomer := '';

  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  SetGroupTara;


  FPriceKey := -1;

  FisAppend := aDocumentKey = -1;

  if aDocumentKey = -1 then
  begin
    if aCopyBill = -1 then
      AppendDocument
    else
      CopyDocument(aCopyBill);
  end
  else
    FDocumentKey := aDocumentKey;

  ibdsDocument.ParamByName('id').AsInteger := FDocumentKey;
  ibdsDocument.Open;

  ibdsDocRealization.ParamByName('id').AsInteger := FDocumentKey;
  ibdsDocRealization.Open;

  ibdsDocRealInfo.ParamByName('id').AsInteger := FDocumentKey;
  ibdsDocRealInfo.Open;

  ibdsDocRealPos.ParamByName('dockey').AsInteger := FDocumentKey;
  ibdsDocRealPos.Open;

  for i:= 0 to gsibgrDocRealPos.Columns.Count - 1 do
    if UpperCase(gsibgrDocRealPos.Columns[i].Field.FieldName) = 'NAME' then
    begin
      gsibgrDocRealPos.Columns[i].Index := 0;
      Break;
    end;

  for i:= 0 to ibdsDocRealPos.FieldCount - 1 do
    ibdsDocRealPos.Fields[i].Required := False;


  if lvAmount.Columns.Count = 9 then
  begin
    for i:= 0 to FTaxList.Count - 1 do
    begin
      LC := lvAmount.Columns.Add;
      LC.AutoSize := True;
      R := atDatabase.FindRelationField(Trim(TTaxField(FTaxList[i]).RelationName),
        Trim(TTaxField(FTaxList[i]).FieldName));
      if Assigned(R) then
        LC.Caption := R.LName
      else
        LC.Caption := Trim(TTaxField(FTaxList[i]).FieldName);
      LC.Width := 90;
    end;

    for i:= 0 to FTaxList.Count - 1 do
      TListItem(lvAmount.Items[0]).SubItems.Add('0');
  end;

  ibdsDocument.Edit;

  if aDocumentKey = -1 then
  begin
    if aCopyBill = -1 then
    begin
      ibdsDocRealization.Insert;
      ibdsDocRealization.FieldByName('documentkey').AsInteger := FDocumentKey;
      if FPriceKey <> -1 then
        ibdsDocRealization.FieldByName('pricekey').AsInteger := FPriceKey;

      ibdsDocRealization.FieldByName('isrealization').AsInteger := 1;
      ibdsDocRealization.FieldByName('typetransport').AsString := 'C';

      ibdsDocRealInfo.Insert;
      ibdsDocRealInfo.FieldByName('documentkey').AsInteger := FDocumentKey;
    end;

    DateTimeToString(S, 'dd.mm.yyyy', Date);
    gsiblcPrice.Condition := 'pricetype = ''C''';
    SetCurPriceField('');

    lvAmount.Items[0].Caption := '0';
    lvAmount.Items[0].SubItems[0] := '0';
    lvAmount.Items[0].SubItems[1] := '0';
    lvAmount.Items[0].SubItems[2] := '0';
    lvAmount.Items[0].SubItems[3] := '0';
    lvAmount.Items[0].SubItems[4] := '0';
    lvAmount.Items[0].SubItems[5] := '0';
    lvAmount.Items[0].SubItems[6] := '0';
    lvAmount.Items[0].SubItems[7] := '0';

    for i:= 0 to FTaxList.Count - 1 do
      lvAmount.Items[0].SubItems[8 + i] := '0';

  end
  else
  begin
    ibdsDocRealization.Edit;
    ibdsDocRealInfo.Edit;
    if ibdsDocRealInfo.FieldByName('documentkey').IsNull then
      ibdsDocRealInfo.FieldByName('documentkey').AsInteger := FDocumentKey;
    actNext.Enabled := False;
    SetCurPriceField(ibdsDocRealization.FieldByName('pricefield').AsString);
    if cbAmount.Checked then
      CalcAmountBill;

  end;

  SetConditionGood;

  FisCurrChange := False;
  FisNCUChange := False;
  FisAmountNCUChange := False;
  FisAmountCurrChange := False;
  SetChangeField;
  SetCurrencyField;

  
  FisTransactionChange := False;

  pcBill.ActivePageIndex := 0;
  if Visible then
    dbedNumber.SetFocus;

  if not AfterSetup then exit;  
end;

procedure Tgp_dlgBill.actOkExecute(Sender: TObject);
begin
  if SaveData then
    ModalResult := mrOk;
end;

procedure Tgp_dlgBill.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure Tgp_dlgBill.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (ModalResult <> mrOk) and (MessageBox(HANDLE, 'Выйти без сохранения?', 'Внимание',
    mb_YesNo or mb_IconQuestion) = idYes)
  then
    CancelData
  else
    if ModalResult <> mrOk then
    begin
      ModalResult := mrNone;
      abort;
    end;
  if IBTranLookup.InTransaction then
    IBTranLookup.Commit;
end;

function Tgp_dlgBill.SaveData: Boolean;
var
  isNull: Boolean;
  i: Integer;
begin
  try
    Result := False;
    
    if not BeforeSave then exit;

    if ibdsDocument.FieldByName('DocumentDate').AsDateTime = 0 then
    begin
      MessageBox(HANDLE, 'Необходимо указать дату документа!', 'Внимание',
        mb_Ok or mb_IconInformation);
      ddbDocumentDate.SetFocus;
      abort;
    end;

    if ibdsDocRealization.FieldByName('FromContactKey').IsNull then
    begin
      MessageBox(HANDLE, 'Необходимо указать от кого отпускаются ТМЦ!', 'Внимание',
        mb_Ok or mb_IconInformation);
      gsiblcFromContact.SetFocus;
      abort;
    end;

    if ibdsDocRealization.FieldByName('ToContactKey').IsNull then
    begin
      MessageBox(HANDLE, 'Необходимо указать кому отпускаются ТМЦ!', 'Внимание',
        mb_Ok or mb_IconInformation);
      gsiblcToContact.SetFocus;
      abort;
    end;

    if FCheckNumber and not CheckDublicate then
      abort;

    if ibdsDocument.State in [dsEdit, dsInsert] then
      ibdsDocument.Post;

    if not (ibdsDocRealization.State in [dsEdit, dsInsert]) then
      ibdsDocRealization.Edit;

    if cbPriceField.ItemIndex >= 0 then
      ibdsDocRealization.FieldByName('pricefield').AsString :=
        TPriceField(cbPriceField.Items.Objects[cbPriceField.ItemIndex]).FieldName;

    ibdsDocRealization.Post;

    if ibdsDocRealInfo.State in [dsEdit, dsInsert] then
      ibdsDocRealInfo.Post;

    if ibdsDocRealPos.State in [dsEdit, dsInsert] then
    begin
      isNull := True;
      for i:= 0 to gsibgrDocRealPos.Columns.Count - 1 do
        if gsibgrDocRealPos.Columns[i].Visible and not gsibgrDocRealPos.Columns[i].Field.IsNull then
        begin
          isNull := False;
          Break;
        end;

      if not isNull then
        ibdsDocRealPos.Post
      else
        ibdsDocRealPos.Cancel;
    end;

    if (GlobalStorage.ReadInteger('realzaitionoption', 'joinrecord', 0) = 1)
    then
      JoinRecord;

    ibdsDocRealPos.ApplyUpdates;

    if not AfterSave then
      exit;

    ibdsDocRealPos.ApplyUpdates;

    if IBTransaction.InTransaction then
      IBTransaction.Commit;

    Result := True;
  except
    Result := False;
  end;
end;

procedure Tgp_dlgBill.CancelData;
begin
  try
    if ibdsDocRealPos.State in [dsEdit, dsInsert] then
      ibdsDocRealPos.Cancel;

    if ibdsDocRealization.State in [dsEdit, dsInsert] then
      ibdsDocRealization.Cancel;

    if ibdsDocRealInfo.State in [dsEdit, dsInsert] then
      ibdsDocRealInfo.Cancel;

    if ibdsDocument.State in [dsEdit, dsInsert] then
      ibdsDocument.Cancel;

    ibdsDocRealPos.CancelUpdates;
  except
  end;  

  if IBTransaction.InTransaction then
    IBTransaction.RollBack;
end;

procedure Tgp_dlgBill.actNextExecute(Sender: TObject);
begin
  if SaveData then
  begin
    SetupDialog(-1, FDocumentKey);
  end;
end;

procedure Tgp_dlgBill.ibdsDocRealPosGOODKEYChange(Sender: TField);
var
  ibsql: TIBSQL;
begin
  if gsiblcGood.Focused or LocalChange then
    exit;
  if not ibsqlGood.Prepared then
    ibsqlGood.Prepare;
  ibsqlGood.ParamByName('id').AsInteger := Sender.AsInteger;
  ibsqlGood.ExecQuery;
  try
    if (ibsqlGood.RecordCount = 1) then
    begin
      if (FTypeShowDisabledGood = 1) and (ibsqlGood.FieldByName('Disabled').AsInteger = 1) then
      begin
        MessageBox(HANDLE,
        PChar(Format('Выбранный ТМЦ -  %s отключен ' + #13#10 +
              '(возможно он снят с производства ' + #13#10 +
              'или на него закончился сертификат.)' + #13#10 + 'Выбор его невозможен.',
              [ibsqlGood.FieldByName('name').AsString])), 'Внимание',
              mb_Ok or mb_IconQuestion);
        ibsqlGood.Close;
        if gsiblcGood.Visible then
          gsiblcGood.Visible := False;
        abort;
      end;
      ibdsDocRealPos.FieldByName('NAME').AsString := ibsqlGood.FieldByName('NAME').AsString;
      ibdsDocRealPos.FieldByName('goodvaluekey').AsInteger :=
        ibsqlGood.FieldByName('valuekey').AsInteger;
      ibdsDocRealPos.FieldByName('GroupKey').AsInteger :=
        ibsqlGood.FieldByName('GroupKey').AsInteger;  
      gsiblcValue.Condition :=
        Format('ID IN (SELECT valuekey FROM gd_goodvalue WHERE goodkey = %d) OR (ID = %d)',
        [Sender.AsInteger, ibsqlGood.FieldByName('VALUEKEY').AsInteger]);

      ibdsDocRealPos.FieldByName('VALUEKEY').AsInteger := ibsqlGood.FieldByName('VALUEKEY').AsInteger;
      if (FWeightKey > 0) and (ibdsDocRealPos.FieldByName('WeightKey').AsInteger = 0) then
        ibdsDocRealPos.FieldByName('WeightKey').AsInteger := FWeightKey;

      ibsqlPack.ParamByName('gk').AsInteger := Sender.AsInteger;
      ibsqlPack.ExecQuery;
      try
        if (ibsqlPack.RecordCount > 0) then
        begin
          ibdsDocRealPos.FieldByName('PACKKEY').AsInteger := ibsqlPack.FieldByName('valuekey').AsInteger;
          ibdsDocRealPos.FieldByName('PACKINQUANT').AsFloat := ibsqlPack.FieldByName('Scale').AsInteger;
        end;
      finally
        ibsqlPack.Close;
      end;

      if ibdsDocRealPos.FieldByName('Quantity').AsCurrency = 0 then
        ibdsDocRealPos.FieldByName('Quantity').AsCurrency := 1;

      if (ibdsDocRealization.FieldByName('pricekey').AsInteger > 0) and
         (cbPriceField.ItemIndex >= 0)
      then
      begin
        ibsql := TIBSQL.Create(Self);
        try
          ibsql.Transaction := IBTransaction;
          ibsql.SQL.Text := Format(
            'SELECT %s FROM gd_pricepos WHERE goodkey = %d and pricekey = %d',
            [TPriceField(cbPriceField.Items.Objects[cbPriceField.ItemIndex]).FieldName,
             Sender.AsInteger,
             ibdsDocRealization.FieldByName('pricekey').AsInteger]);
          ibsql.ExecQuery;
          if ibsql.RecordCount = 1 then
          begin
            if TPriceField(cbPriceField.Items.Objects[cbPriceField.ItemIndex]).CurrKey > 0 then
            begin
              if TPriceField(cbPriceField.Items.Objects[cbPriceField.ItemIndex]).CurrKey =
                 ibdsDocument.FieldByName('currkey').AsInteger
              then
                ibdsDocRealPos.FieldByName('CostCurr').AsCurrency := ibsql.Fields[0].AsCurrency;
            end
            else
              ibdsDocRealPos.FieldByName('CostNCU').AsCurrency := ibsql.Fields[0].AsCurrency;
          end;
          ibsql.Close;
        finally
          ibsql.Free;
        end;
      end;
    end
    else
      if ibsqlGood.RecordCount = 0 then
      begin
        ibdsDocRealPos.FieldByName('Name').Clear;
        ibdsDocRealPos.FieldByName('VALUEKEY').Clear;
      end;
  finally
    ibsqlGood.Close;
  end;
  MakeOnChangeField(Sender);
end;

procedure Tgp_dlgBill.ibdsDocRealPosVALUEKEYChange(Sender: TField);
var
  Koef: Currency;
begin
  if LocalChange then exit;
  
  if not ibsqlValue.Prepared then
    ibsqlValue.Prepare;
  ibsqlValue.ParamByName('id').AsInteger := Sender.AsInteger;
  ibsqlValue.ParamByName('gk').AsInteger := ibdsDocRealPos.FieldByName('goodkey').AsInteger;
  ibsqlValue.ExecQuery;
  if ibsqlValue.RecordCount = 1 then
  begin
    ibdsDocRealPos.FieldByName('VALUENAME').AsString := ibsqlValue.FieldByName('Name').AsString;
    ibdsDocRealPos.FieldByName('scale').AsCurrency := ibsqlValue.FieldByName('scale').AsCurrency;
    if (ibdsDocRealPos.FieldByName('Quantity').AsCurrency <> 0) then
    begin
      FisLocalQuantity := True;    
      if (ibdsDocRealPos.FieldByName('scale').AsCurrency <> 0) then
        Koef := ibdsDocRealPos.FieldByName('scale').AsCurrency *
          ibdsDocRealPos.FieldByName('MainQuantity').AsCurrency /
          ibdsDocRealPos.FieldByName('Quantity').AsCurrency
      else
        Koef := ibdsDocRealPos.FieldByName('MainQuantity').AsCurrency /
          ibdsDocRealPos.FieldByName('Quantity').AsCurrency;
      if ibdsDocRealPos.FieldByName('CostNCU').AsCurrency <> 0 then
        ibdsDocRealPos.FieldByName('CostNCU').AsCurrency :=
          ibdsDocRealPos.FieldByName('CostNCU').AsCurrency /
          Koef;
      if ibdsDocRealPos.FieldByName('CostCurr').AsCurrency <> 0 then
        ibdsDocRealPos.FieldByName('CostCurr').AsCurrency :=
          ibdsDocRealPos.FieldByName('CostCurr').AsCurrency /
          Koef;
      if ibdsDocRealPos.FieldByName('scale').AsCurrency <> 0 then
        ibdsDocRealPos.FieldByName('Quantity').AsCurrency :=
          ibdsDocRealPos.FieldByName('MainQuantity').AsCurrency *
          ibdsDocRealPos.FieldByName('scale').AsCurrency
      else
        ibdsDocRealPos.FieldByName('Quantity').AsCurrency :=
          ibdsDocRealPos.FieldByName('MainQuantity').AsCurrency;
      FisLocalQuantity := False;    
    end;
  end
  else
  begin
    ibdsDocRealPos.FieldByName('VALUENAME').Clear;
    ibdsDocRealPos.FieldByName('scale').Clear;
  end;
  ibsqlValue.Close;
  MakeOnChangeField(Sender);
end;

procedure Tgp_dlgBill.ibdsDocRealPosWEIGHTKEYChange(
  Sender: TField);
begin
  if LocalChange then exit;
  if not ibsqlValue.Prepared then
    ibsqlValue.Prepare;
  ibsqlValue.ParamByName('id').AsInteger := Sender.AsInteger;
  ibsqlValue.ParamByName('gk').AsInteger := ibdsDocRealPos.FieldByName('goodkey').AsInteger;
  ibsqlValue.ExecQuery;
  if ibsqlValue.RecordCount = 1 then
  begin
    ibdsDocRealPos.FieldByName('WeightName').AsString := ibsqlValue.FieldByName('Name').AsString;
    ibdsDocRealPos.FieldByName('WeightScale').AsCurrency := ibsqlValue.FieldByName('scale').AsCurrency;
  end
  else
  begin
    ibdsDocRealPos.FieldByName('WeightName').Clear;
    ibdsDocRealPos.FieldByName('WeightScale').Clear;
  end;
  ibsqlValue.Close;
  
  if ibdsDocRealPos.FieldByName('valuekey').AsInteger =
     ibdsDocRealPos.FieldByName('weightkey').AsInteger
  then
    ibdsDocRealPos.FieldByName('Weight').AsCurrency :=
      ibdsDocRealPos.FieldByName('Quantity').AsCurrency;     
end;

procedure Tgp_dlgBill.ibdsDocRealPosPACKKEYChange(Sender: TField);
begin
  if LocalChange then exit;
  if not ibsqlValue.Prepared then
    ibsqlValue.Prepare;
  ibsqlValue.ParamByName('id').AsInteger := Sender.AsInteger;
  ibsqlValue.ParamByName('gk').AsInteger := ibdsDocRealPos.FieldByName('goodkey').AsInteger;
  ibsqlValue.ExecQuery;
  if ibsqlValue.RecordCount = 1 then
  begin
    ibdsDocRealPos.FieldByName('PackName').AsString := ibsqlValue.FieldByName('Name').AsString;
    ibdsDocRealPos.FieldByName('PackScale').AsCurrency := ibsqlValue.FieldByName('scale').AsCurrency;
    ibdsDocRealPos.FieldByName('PACKINQUANT').AsCurrency := ibsqlValue.FieldByName('scale').AsCurrency;
  end
  else
  begin
    ibdsDocRealPos.FieldByName('PackName').Clear;
    ibdsDocRealPos.FieldByName('PackScale').Clear;
  end;
  ibsqlValue.Close;
  MakeOnChangeField(Sender);
end;

procedure Tgp_dlgBill.ibdsDocRealPosPACKINQUANTChange(
  Sender: TField);
begin
  if not LocalChange then
  begin
    CalcPack;
    MakeOnChangeField(Sender);
  end;  
end;

procedure Tgp_dlgBill.CalcWeight;
var
  Koef: Currency;
begin
  if ibdsDocRealPos.FieldByName('WeightKey').AsInteger > 0 then
  begin
    if ibdsDocRealPos.FieldByName('WeightKey').AsInteger =
       ibdsDocRealPos.FieldByName('ValueKey').AsInteger
    then
      ibdsDocRealPos.FieldByName('Weight').AsCurrency :=
        ibdsDocRealPos.FieldByName('Quantity').AsCurrency
    else
    begin
      if ibdsDocRealPos.FieldByName('WeightScale').AsCurrency = 0 then
        Koef := 1
      else
        Koef := ibdsDocRealPos.FieldByName('WeightScale').AsCurrency;
      ibdsDocRealPos.FieldByName('Weight').AsCurrency :=
        ibdsDocRealPos.FieldByName('Quantity').AsCurrency * Koef;
    end;    
  end;
end;

procedure Tgp_dlgBill.CalcPack;
var
  Val: Currency;
begin
  if FisLocalPackQuantChange then exit;
  FisLocalPackQuantChange := True;
  if (ibdsDocRealPos.FieldByName('Quantity').AsCurrency <> 0) and
     (ibdsDocRealPos.FieldByName('PackInQuant').AsCurrency <> 0)
  then
  begin
    Val := ibdsDocRealPos.FieldByName('Quantity').AsCurrency /
                ibdsDocRealPos.FieldByName('PackInQuant').AsCurrency;
    ibdsDocRealPos.FieldByName('PackQuantity').AsInteger := Trunc(Val);
    if Frac(Val) > 0 then
      ibdsDocRealPos.FieldByName('PackQuantity').AsInteger :=
        ibdsDocRealPos.FieldByName('PackQuantity').AsInteger + 1;
  end;
  FisLocalPackQuantChange := False;
end;

procedure Tgp_dlgBill.ibdsDocRealPosQUANTITYChange(Sender: TField);
begin
  if FisLocalQuantity or LocalChange then exit;
  if ibdsDocRealPos.FieldByName('scale').AsCurrency <> 0 then
    ibdsDocRealPos.FieldByName('mainquantity').AsCurrency :=
       ibdsDocRealPos.FieldByName('quantity').AsCurrency /
       ibdsDocRealPos.FieldByName('scale').AsCurrency
  else
    ibdsDocRealPos.FieldByName('mainquantity').AsCurrency :=
       ibdsDocRealPos.FieldByName('quantity').AsCurrency;
  CalcPack;
  CalcWeight;
  FisNCUChange := True;
  FisCurrChange := True;
  try
    CalcAmount;
  finally
    FisNCUChange := False;
    FisCurrChange := False;
  end;
  MakeOnChangeField(Sender);
end;

procedure Tgp_dlgBill.edCostNCUExit(Sender: TObject);
begin
  try
    if (ibdsDocRealPos.State in [dsEdit, dsInsert]) then
      ibdsDocRealPos.FieldByName('CostNCU').AsCurrency := StrToFloat(edCostNCU.Text);
  except
  end;
  SendMessage(gsibgrDocRealPos.Handle, WM_KEYDOWN, VK_TAB, 0);
end;

procedure Tgp_dlgBill.edCostCurrExit(Sender: TObject);
begin
  try
    if (ibdsDocRealPos.State in [dsEdit, dsInsert]) then
      ibdsDocRealPos.FieldByName('CostCurr').AsCurrency := StrToFloat(edCostCurr.Text);
  except
  end;
  SendMessage(gsibgrDocRealPos.Handle, WM_KEYDOWN, VK_TAB, 0);
end;

procedure Tgp_dlgBill.ibdsDocRealPosCostNCUChange(Sender: TField);
begin
  if FisLocalQuantity or LocalChange then exit;
  FisNCUChange := True;
  try
    if (ibdsDocument.FieldByName('CurrKey').AsInteger > 0) and not FisCurrChange then
      CalcCurr;
    if not FisAmountNCUChange then
      CalcAmount;
    MakeOnChangeField(Sender);  
  finally
    FisNCUChange := False;
  end;
end;

procedure Tgp_dlgBill.ibdsDocRealPosCOSTCURRChange(Sender: TField);
begin
  if FisLocalQuantity or LocalChange then exit;
  FisCurrChange := True;
  try
    if not FisNCUChange then
      CalcNCU;
    if not FisAmountCurrChange then
      CalcAmount;
    MakeOnChangeField(Sender);  
  finally
    FisCurrChange := False;
  end;
end;

procedure Tgp_dlgBill.CalcNCU;
begin
  ibdsDocRealPos.FieldByName('CostNCU').AsCurrency :=
    ibdsDocRealPos.FieldByName('CostCurr').AsCurrency *
    ibdsDocRealization.FieldByName('Rate').AsCurrency;
end;

procedure Tgp_dlgBill.CalcCurr;
begin
  if ibdsDocRealization.FieldByName('Rate').AsCurrency <> 0 then
    ibdsDocRealPos.FieldByName('CostCurr').AsCurrency :=
      ibdsDocRealPos.FieldByName('CostNCU').AsCurrency /
      ibdsDocRealization.FieldByName('Rate').AsCurrency;
end;

procedure Tgp_dlgBill.CalcAmount;
begin
  if not (ibdsDocRealPos.State in [dsEdit, dsInsert]) then
    ibdsDocRealPos.Edit;
  if not FisAmountNCUChange then
    ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency :=
      ibdsDocRealPos.FieldByName('CostNCU').AsCurrency *
      ibdsDocRealPos.FieldByName('Quantity').AsCurrency;

  if not FisAmountCurrChange and (ibdsDocument.FieldByName('CurrKey').AsInteger > 0) then
    ibdsDocRealPos.FieldByName('AmountCurr').AsCurrency :=
      ibdsDocRealPos.FieldByName('CostCurr').AsCurrency *
      ibdsDocRealPos.FieldByName('Quantity').AsCurrency;

  CalcTax;
end;

procedure Tgp_dlgBill.CalcTax;
var
  ibsql: TIBSQL;
  i, j: Integer;
  Rate, Value: Currency;
  RF: TatRelationField;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT gt.*, t.shot FROM gd_goodtax gt JOIN gd_tax t ON gt.taxkey = t.id ' +
                      'WHERE goodkey = :gk and taxkey = :tk and ' +
                      'datetax = (SELECT MAX(gt1.datetax) FROM gd_goodtax gt1 WHERE gt1.datetax <= :d and ' +
                      'gt1.goodkey = :gk and gt1.taxkey = :tk)';
    ibsql.Prepare;
    ibsql.ParamByName('gk').AsInteger := ibdsDocRealPos.FieldByName('goodkey').AsInteger;
    ibsql.ParamByName('d').AsDateTime := ibdsDocument.FieldByName('documentdate').AsDateTime;
    for i:= 0 to FTaxList.Count - 1 do
      if (Trim(TTaxField(FTaxList[i]).RelationName) = 'GD_DOCREALPOS') and
         (TTaxField(FTaxList[i]).TaxKey > 0) then
      begin

        ibsql.ParamByName('tk').AsInteger := TTaxField(FTaxList[i]).TaxKey;
        ibsql.ExecQuery;
        if ibsql.RecordCount = 1 then
          Rate := ibsql.FieldByName('rate').AsCurrency
        else
          Rate := 0;
        ibsql.Close;
        if TTaxField(FTaxList[i]).expression > '' then
        begin
          xFocal.ClearVariablesList;
          xFocal.AssignVariable(ibsql.FieldByName('shot').AsString, Rate);
          RF := atDatabase.FindRelationField('GD_DOCREALPOS', 'AmountNCU');
          if Assigned(RF) and Assigned(RF.Relation) then
            xFocal.AssignVariable(RF.Relation.LShortName + '_' + RF.LShortName,
              ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency);
          RF := atDatabase.FindRelationField('GD_DOCREALPOS', 'AMOUNTCURR');
          if Assigned(RF) and Assigned(RF.Relation) then
            xFocal.AssignVariable(RF.Relation.LShortName + '_' + RF.LShortName,
              ibdsDocRealPos.FieldByName('AmountCURR').AsCurrency);
          RF := atDatabase.FindRelationField('GD_DOCREALPOS', 'Quantity');
          if Assigned(RF) and Assigned(RF.Relation) then
            xFocal.AssignVariable(RF.Relation.LShortName + '_' + RF.LShortName,
              ibdsDocRealPos.FieldByName('Quantity').AsCurrency);
          for j:= 0 to ibdsDocRealPos.FieldCount - 1 do
          begin
            if POS(UserPrefix, ibdsDocRealPos.Fields[i].FieldName) > 0 then
            begin
              RF := atDatabase.FindRelationField('GD_DOCREALPOS', ibdsDocRealPos.Fields[i].FieldName);
              if Assigned(RF) and Assigned(RF.Relation) then
                try
                  xFocal.AssignVariable(RF.Relation.LShortName + '_' + RF.LShortName,
                    ibdsDocRealPos.Fields[i].AsCurrency);
                except
                end;
            end;
          end;
          xFocal.Expression := TTaxField(FTaxList[i]).expression;
          ibdsDocRealPos.FieldByName(TTaxField(FTaxList[i]).FieldName).AsCurrency :=
            RoundCurrency(xFocal.Value, TTaxField(FTaxList[i]).Rounding);
        end
        else
        begin
          if TTaxField(FTaxList[i]).IsCurrency then
            Value := ibdsDocRealPos.FieldByName('AmountCurr').AsCurrency
          else
            Value := ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency;
          if TTaxField(FTaxList[i]).IsInclude then
            Rate := Rate / (100 + Rate)
          else
            Rate := Rate / 100;
          ibdsDocRealPos.FieldByName(TTaxField(FTaxList[i]).FieldName).AsCurrency :=
            RoundCurrency(Value * Rate, TTaxField(FTaxList[i]).Rounding);
          CalcAmountTax(i);
        end;
      end;
  finally
    ibsql.Free;
  end;
end;

procedure Tgp_dlgBill.ibdsDocRealPosAmountNCUChange(
  Sender: TField);
begin
  if not FisNCUChange and not FisAmountNCUChange and not LocalChange then
  begin
    FisAmountNCUChange := True;
    try
      if ibdsDocRealPos.FieldByName('Quantity').AsCurrency <> 0 then
        ibdsDocRealPos.FieldByName('CostNCU').AsCurrency :=
          ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency /
          ibdsDocRealPos.FieldByName('Quantity').AsCurrency
      else
        ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency := 0;
      CalcTax;
      MakeOnChangeField(Sender);
    finally
      FisAmountNCUChange := False;
    end;
  end;
end;

procedure Tgp_dlgBill.ibdsDocRealPosAMOUNTCURRChange(
  Sender: TField);
begin
  if not FisCurrChange and not FisAmountCurrChange and not LocalChange then
  begin
    FisAmountCurrChange := True;
    try
      if ibdsDocRealPos.FieldByName('Quantity').AsCurrency <> 0 then
        ibdsDocRealPos.FieldByName('CostCurr').AsCurrency :=
          ibdsDocRealPos.FieldByName('AmountCurr').AsCurrency /
          ibdsDocRealPos.FieldByName('Quantity').AsCurrency
      else
        ibdsDocRealPos.FieldByName('AmountCurr').AsCurrency := 0;
      CalcTax;
      MakeOnChangeField(Sender);  
    finally
      FisAmountCurrChange := False;
    end;
  end;
end;

procedure Tgp_dlgBill.ibdsDocumentCURRKEYChange(Sender: TField);
begin
  SetCurrencyField;
  if not (ibdsDocRealization.State in [dsEdit, dsInsert]) then
    ibdsDocRealization.Edit;
  if ibdsDocument.FieldByName('currkey').AsInteger > 0 then
    ibdsDocRealization.FieldByName('rate').AsCurrency :=
      boCurrency.GetRate(
        ibdsDocument.FieldByName('currkey').AsInteger,
        200010,
        ibdsDocument.FieldByName('documentdate').asDateTime)
  else
    ibdsDocRealization.FieldByName('rate').Clear;

end;

procedure Tgp_dlgBill.SetCurrencyField;
var
  i: Integer;

function IsCurrencyTax(const NameField: String): Boolean;
var
  j: Integer;
begin
  Result := False;
  for j:= 0 to FTaxList.Count - 1 do
  begin
    if (TTaxField(FTaxList[j]).RelationName = 'GD_DOCREALPOS') and
       ((TTaxField(FTaxList[j]).FieldName = NameField) or
       (NameField = 'E' + TTaxField(FTaxList[j]).FieldName))
    then
    begin
      Result := TTaxField(FTaxList[j]).IsCurrency;
      Break;
    end;  
  end;
end;  

begin
  for i:= 0 to gsibgrDocRealPos.Columns.Count - 1 do
  begin
    if gsibgrDocRealPos.Columns[i].Field = ibdsDocRealPos.FieldByName('CostCurr')
    then
      gsibgrDocRealPos.Columns[i].Visible :=
        ibdsDocument.FieldByName('CurrKey').AsInteger > 0;
    if gsibgrDocRealPos.Columns[i].Field = ibdsDocRealPos.FieldByName('AmountCurr')
    then
      gsibgrDocRealPos.Columns[i].Visible :=
        ibdsDocument.FieldByName('CurrKey').AsInteger > 0;
    if (gsibgrDocRealPos.Columns[i].Field <> nil) and IsCurrencyTax(gsibgrDocRealPos.Columns[i].Field.FieldName) then
      gsibgrDocRealPos.Columns[i].Visible :=
        ibdsDocument.FieldByName('CurrKey').AsInteger > 0;
  end;

  for i:= 0 to lvAmount.Columns.Count - 1 do
  begin
    if (lvAmount.Column[i].Caption = 'Итого вал.') or (lvAmount.Column[i].Caption = 'По накл. в вал.')
    then
      lvAmount.Columns[i].Width := 80 * Integer(ibdsDocument.FieldByName('CurrKey').AsInteger > 0);
  end;
end;

procedure Tgp_dlgBill.SetCurPriceField(aFieldName: String);
var
  ibsql: TIBSQL;
  i: Integer;
  isOk: Boolean;
  S: String;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    if ibdsDocRealization.FieldByName('TOCONTACTKEY').AsInteger > 0 then
    begin
      if aFieldName = '' then
      begin
        ibsql.SQL.Text :=
        Format(
          'SELECT fieldname FROM gd_pricefieldrel ' +
          'WHERE ' +
          '  CONTACTKEY IN ( ' +
          '    SELECT c.id FROM gd_contact c JOIN gd_contact c1 ' +
          '      ON (c.LB <= c1.LB) AND (c.RB >= c1.RB) and (C1.id = %d))',
          [ibdsDocRealization.FieldByName('TOCONTACTKEY').AsInteger]);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 1 then
          aFieldName := ibsql.FieldByName('fieldname').AsString;
        ibsql.Close;
      end;
    end;
    if aFieldName = '' then
    begin
      ibsql.SQL.Text :=
        'SELECT fieldname, relationname, docfieldname, valuetext FROM gd_pricedocrel ';
      ibsql.ExecQuery;
      if ibsql.RecordCount = 1 then
      begin
        S := '';
        isOk := False;
        while not ibsql.EOF do
        begin
          if S <> ibsql.FieldByName('fieldname').AsString then
          begin
            if isOk then
            begin
              aFieldName := S;
              Break;
            end;
            S := Trim(ibsql.FieldByName('fieldname').AsString);
            isOK := True;
          end;

          if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCUMENT' then
            isOk := isOK and
            (ibdsDocument.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).AsString =
            ibsql.FieldByName('valuetext').AsString)
          else
            if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCREALIZATION' then
              isOk := isOK and
                (ibdsDocRealization.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).AsString =
                ibsql.FieldByName('valuetext').AsString)
            else
              if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCREALINFO' then
                isOk := isOK and
                  (ibdsDocRealInfo.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).AsString =
                  ibsql.FieldByName('valuetext').AsString);
          ibsql.Next;
        end;
        if (aFieldName = '') and isOk then
          aFieldName := S;
      end;
      ibsql.Close;
    end;
    
    if aFieldName > '' then
    begin
      for i := 0 to cbPriceField.Items.Count - 1 do
        if Assigned(cbPriceField.Items.Objects[i]) AND (UPPERCASE(Trim(TPriceField(cbPriceField.Items.Objects[i]).FieldName)) =
           UPPERCASE(Trim(aFieldName)))
        then
        begin
          cbPriceField.ItemIndex := i;
          Break;
        end;
    end;
  finally
    ibsql.Free;
  end;

end;

procedure Tgp_dlgBill.SetPriceField;
var
  R: TatRelation;
  i: Integer;
  ibsql: TIBSQL;
begin
  R := atDatabase.Relations.ByRelationName('GD_PRICEPOS');
  if Assigned(R) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.SQL.Text := 'SELECT currkey FROM gd_priceposoption WHERE fieldname = :fn';
      ibsql.Transaction := IBTransaction;
      ibsql.Prepare;
      for i:= 0 to R.RelationFields.Count - 1 do
        if R.RelationFields[i].IsUserDefined then
        begin
          ibsql.ParamByName('fn').AsString := R.RelationFields[i].FieldName;
          ibsql.ExecQuery;
          if ibsql.RecordCount = 1 then
            cbPriceField.Items.AddObject(R.RelationFields[i].LName,
              TPriceField.Create(R.RelationFields[i].FieldName,
                R.RelationFields[i].LShortName, ibsql.FieldByName('currkey').AsInteger))
          else
            cbPriceField.Items.AddObject(R.RelationFields[i].LName,
              TPriceField.Create(R.RelationFields[i].FieldName,
                R.RelationFields[i].LShortName, 0));
          ibsql.Close;
        end;
    finally
      ibsql.Free;
    end;
  end;
end;

procedure Tgp_dlgBill.SetDocRealPosField;
var
  ibsql: TIBSQL;
  S: String;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT * FROM gd_docrealposoption ';
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      FTaxList.Add(TTaxField.Create(UpperCase(Trim(ibsql.FieldByName('relationname').AsString)),
        Trim(ibsql.FieldByName('fieldname').AsString),
        Trim(ibsql.FieldByName('expression').AsString),
        ibsql.FieldByName('taxkey').AsInteger,
        ibsql.FieldByName('includetax').AsInteger = 1,
        ibsql.FieldByName('iscurrency').AsInteger = 1,
        ibsql.FieldByName('rounding').AsCurrency,
        ibsql.FieldByName('rate').AsCurrency));
      if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCREALPOS' then
      begin
        S := ibdsDocRealPos.SelectSQL.Text;
        if ibsql.FieldByName('includetax').AsInteger = 0 then
        begin
          if ibsql.FieldByName('iscurrency').AsInteger = 1 then
            Insert(' AmountCurr + ' +
              Trim(ibsql.FieldByName('fieldname').AsString) + ' as E' +
              Trim(ibsql.FieldByName('fieldname').AsString) + ', ',  S,
              Pos('SELECT', UpperCase(ibdsDocRealPos.SelectSQL.Text)) + 6)
          else
            Insert(' AmountNCU + ' +
              Trim(ibsql.FieldByName('fieldname').AsString) + ' as E' +
              Trim(ibsql.FieldByName('fieldname').AsString) + ', ',  S,
              Pos('SELECT', UpperCase(ibdsDocRealPos.SelectSQL.Text)) + 6)
        end
        else
          if ibsql.FieldByName('iscurrency').AsInteger = 1 then
            Insert(' AmountCurr - ' +
              Trim(ibsql.FieldByName('fieldname').AsString) + ' as E' +
              Trim(ibsql.FieldByName('fieldname').AsString) + ', ', S,
              Pos('SELECT', UpperCase(ibdsDocRealPos.SelectSQL.Text)) + 6)
          else
            Insert(' AmountNCU - ' +
              Trim(ibsql.FieldByName('fieldname').AsString) + ' as E' +
              Trim(ibsql.FieldByName('fieldname').AsString) + ', ', S,
              Pos('SELECT', UpperCase(ibdsDocRealPos.SelectSQL.Text)) + 6);
        ibdsDocRealPos.SelectSQL.Text := S;
      end;
      ibsql.Next;
    end;
    ibsql.Close;
  finally
    ibsql.Free;
  end;
end;

procedure Tgp_dlgBill.SetChangeField;
var
  i: Integer;
  ibsql: TIBSQL;
begin
  ibdsDocRealPos.FieldByName('GoodKey').OnChange := ibdsDocRealPosGOODKEYChange;
  ibdsDocRealPos.FieldByName('ValueKey').OnChange := ibdsDocRealPosVALUEKEYChange;
  ibdsDocRealPos.FieldByName('WeightKey').OnChange := ibdsDocRealPosWEIGHTKEYChange;
  ibdsDocRealPos.FieldByName('PackKey').OnChange := ibdsDocRealPosPACKKEYChange;
  ibdsDocRealPos.FieldByName('PackInQuant').OnChange := ibdsDocRealPosPACKINQUANTChange;
  ibdsDocRealPos.FieldByName('PackQuantity').OnChange := ibdsDocRealPosPackQUANTITYChange;
  ibdsDocRealPos.FieldByName('Quantity').OnChange := ibdsDocRealPosQUANTITYChange;
  ibdsDocRealPos.FieldByName('CostNCU').OnChange := ibdsDocRealPosCostNCUChange;
  ibdsDocRealPos.FieldByName('CostCurr').OnChange := ibdsDocRealPosCOSTCURRChange;
  ibdsDocRealPos.FieldByName('AmountNCU').OnChange := ibdsDocRealPosAmountNCUChange;
  ibdsDocRealPos.FieldByName('AmountCurr').OnChange := ibdsDocRealPosAMOUNTCURRChange;

  ibdsDocument.FieldByName('currkey').OnChange := ibdsDocumentCURRKEYChange;
  ibdsDocRealization.FieldByName('tocontactkey').OnChange := ToContactKeyChange;
  ibdsDocument.FieldByName('documentdate').OnChange := DocumentDateChange;
  ibdsDocument.FieldByName('number').OnChange := DocumentNumberChange;
  ibdsDocRealization.FieldByName('pricekey').OnChange := DoPriceKeyChange;
  ibdsDocRealization.FieldByName('transsumncu').OnChange := TransSumNCUChange;
  ibdsDocRealization.FieldByName('transsumcurr').OnChange := TransSumCurrChange;

  for i:= 0 to FTaxList.Count - 1 do
    if TTaxField(FTaxList[i]).RelationName = 'GD_DOCREALPOS' then
      ibdsDocRealPos.FieldByName(TTaxField(FTaxList[i]).FieldName).OnChange := DoOtherFieldChange;

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT DISTINCT relationname, docfieldname FROM gd_pricedocrel '+
      'WHERE documenttypekey = 802001';
    ibsql.ExecQuery;
    while not ibsql.EOF do
    begin
      if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCUMENT' then
      begin
        if not Assigned(ibdsDocument.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).OnChange)
        then
          ibdsDocument.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).OnChange :=
             DoChangeField;
      end
      else
        if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCREALIZATION' then
        begin
          if not Assigned(ibdsDocRealization.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).OnChange)
          then
            ibdsDocRealization.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).OnChange :=
               DoChangeField;
        end
        else
          if UpperCase(Trim(ibsql.FieldByName('relationname').AsString)) = 'GD_DOCREALINFO' then
          begin
            if not Assigned(ibdsDocRealInfo.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).OnChange)
            then
              ibdsDocRealInfo.FieldByName(Trim(ibsql.FieldByName('docfieldname').AsString)).OnChange :=
                 DoChangeField;
          end;
      ibsql.Next;
    end;
    ibsql.Close;
  finally
    ibsql.Free;
  end;
end;

procedure Tgp_dlgBill.FormDestroy(Sender: TObject);
begin
  UserStorage.SaveComponent(gsibgrDocRealPos, gsibgrDocRealPos.SaveToStream);
  if Assigned(FTaxList) then
    FreeAndNil(FTaxList);
end;

procedure Tgp_dlgBill.gsibgrDocRealPosSetCtrl(Sender: TObject;
  Ctrl: TWinControl; Column: TColumn; var Show: Boolean);
begin
  if not (ibdsDocRealPos.State in [dsEdit, dsInsert]) then
    ibdsDocRealPos.Edit;
  if UpperCase(gsibgrDocRealPos.SelectedField.FieldName) = 'COSTNCU' then
    edCostNCU.Text := gsibgrDocRealPos.SelectedField.AsString
  else
    if UpperCase(gsibgrDocRealPos.SelectedField.FieldName) = 'COSTCURR' then
      edCostCurr.Text := gsibgrDocRealPos.SelectedField.AsString
end;

procedure Tgp_dlgBill.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := ibdsDocRealPos.Active and not ibdsDocRealPos.FieldByName('id').IsNull;
end;

procedure Tgp_dlgBill.actDolgExecute(Sender: TObject);
var
  ibsql: TIBSQL;
  FirstSum: Currency;
  S: String;
begin
  if ibdsDocRealization.FieldByName('tocontactkey').AsInteger > 0 then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text := Format('SELECT SUM(b.CSUMNCU - b.DSUMNCU) FROM ' +
        'BN_BANKSTATEMENTLINE b WHERE b.companykey = %d',
        [ibdsDocRealization.FieldByName('tocontactkey').AsInteger]);
      ibsql.ExecQuery;
      FirstSum := ibsql.Fields[0].AsCurrency;
      ibsql.Close;
      ibsql.SQL.Text := Format('SELECT SUM(p.AmountNCU + p.USR$AmountVAT) FROM ' +
        'gd_docrealpos p JOIN gd_docrealization d ON p.documentkey = d.documentkey AND' +
        ' d.tocontactkey = %d',
        [ibdsDocRealization.FieldByName('tocontactkey').AsInteger]);
      ibsql.ExecQuery;
      FirstSum := ibsql.Fields[0].AsCurrency - FirstSum;
      ibsql.Close;
      S := Format('Задолженность клиента составляет: %m', [FirstSum]);
      MessageBox(HANDLE, Pchar(S), 'Внимание', mb_Ok or mb_IconInformation);
    finally
      ibsql.Free;
    end;
  end;
end;

procedure Tgp_dlgBill.CalcAmountBill;
var
  Bookmark: TBookmark;

  AllAmountNCU: Currency;
  AllAmountCurr: Currency;
  AmountNCU: Currency;
  AmountCurr: Currency;
  Weight, WeightWTara: Currency;
  Quantity, QuantityWTara: Currency;
  CountPack: Integer;
  ListOtherAmount: TObjectList;
  i: Integer;
begin
  AmountNCU := 0;
  AmountCurr := 0;
  Weight := 0;
  Quantity := 0;
  QuantityWTara := 0;
  WeightWTara := 0;
  CountPack := 0;


  Bookmark := ibdsDocRealPos.GetBookmark;
  ibdsDocRealPos.DisableControls;
  ListOtherAmount := TObjectList.Create;
  try
    for i:= 0 to FTaxList.Count - 1 do
      ListOtherAmount.Add(TTaxAmountField.Create(TTaxField(FTaxList[i]).RelationName,
        TTaxField(FTaxList[i]).FieldName, 0));

    ibdsDocRealPos.First;
    while not ibdsDocRealPos.EOF do
    begin
      AmountNCU := AmountNCU + ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency;
      AmountCurr := AmountCurr + ibdsDocRealPos.FieldByName('AmountCurr').AsCurrency;
      Weight := Weight + ibdsDocRealPos.FieldByName('Weight').AsCurrency;

      Quantity := Quantity + ibdsDocRealPos.FieldByName('Quantity').AsCurrency;
      if FTaraGroup.IndexOf(ibdsDocRealPos.FieldByName('GroupKey').AsString) < 0 then
      begin
        QuantityWTara := QuantityWTara + ibdsDocRealPos.FieldByName('Quantity').AsCurrency;
        WeightWTara := WeightWTara + ibdsDocRealPos.FieldByName('Weight').AsCurrency;
      end;  

      CountPack := CountPack + ibdsDocRealPos.FieldByName('PackQuantity').AsInteger;
      for i:= 0 to FTaxList.Count - 1 do
        if TTaxAmountField(ListOtherAmount[i]).RelationName = 'GD_DOCREALPOS' then
          TTaxAmountField(ListOtherAmount[i]).AddAmount(ibdsDocRealPos);
      ibdsDocRealPos.Next;
    end;

    for i:= 0 to FTaxList.Count - 1 do
      if TTaxAmountField(ListOtherAmount[i]).RelationName <> 'GD_DOCREALPOS' then
        TTaxAmountField(ListOtherAmount[i]).AddAmount(ibdsDocRealization);

    AllAmountNCU := AmountNCU;
    AllAmountCurr := AmountCurr;
    for i := 0 to FTaxList.Count - 1 do
      if not TTaxField(FTaxList[i]).IsInclude and
         (TTaxField(FTaxList[i]).RelationName = 'GD_DOCREALPOS')
      then
      begin
        if not TTaxField(FTaxList[i]).IsCurrency then
          AllAmountNCU := AllAmountNCU + TTaxAmountField(ListOtherAmount[i]).Amount
        else
          AllAmountCurr := AllAmountCurr + TTaxAmountField(ListOtherAmount[i]).Amount
      end;

    lvAmount.Items[0].Caption := Format('%m', [AmountNCU]);
    lvAmount.Items[0].SubItems[0] := Format('%f', [Quantity]);
    lvAmount.Items[0].SubItems[1] := Format('%f', [QuantityWTara]);
    lvAmount.Items[0].SubItems[2] := Format('%f', [Weight]);
    lvAmount.Items[0].SubItems[3] := Format('%f', [WeightWTara]);
    lvAmount.Items[0].SubItems[4] := Format('%d', [CountPack]);
    lvAmount.Items[0].SubItems[5] := Format('%m', [AmountCurr]);
    lvAmount.Items[0].SubItems[6] := Format('%m', [AllAmountNCU]);
    lvAmount.Items[0].SubItems[7] := Format('%m', [AllAmountCurr]);
    for i:= 0 to FTaxList.Count - 1 do
      lvAmount.Items[0].SubItems[8 + i] := Format('%m', [TTaxAmountField(ListOtherAmount[i]).Amount]);
  finally
    ListOtherAmount.Free;
    ibdsDocRealPos.GotoBookmark(Bookmark);
    ibdsDocRealPos.FreeBookmark(Bookmark);
    ibdsDocRealPos.EnableControls;
  end;
end;

procedure Tgp_dlgBill.cbAmountClick(Sender: TObject);
begin
  if cbAmount.Checked then
    CalcAmountBill;
end;

procedure Tgp_dlgBill.ibdsDocRealPosAfterPost(DataSet: TDataSet);
begin

  if cbAmount.Checked then
    CalcAmountBill;
end;

procedure Tgp_dlgBill.ibdsDocRealPosAfterDelete(DataSet: TDataSet);
begin
  if cbAmount.Checked then
    CalcAmountBill;
end;

procedure Tgp_dlgBill.ibdsDocRealPosAfterInsert(DataSet: TDataSet);
begin
  ibdsDocRealPos.FieldByName('documentkey').AsInteger := FDocumentKey;
  ibdsDocRealPos.FieldByName('id').AsInteger := GenUniqueID;
  ibdsDocRealPos.FieldByName('afull').AsInteger := -1;
  ibdsDocRealPos.FieldByName('achag').AsInteger := -1;
  ibdsDocRealPos.FieldByName('aview').AsInteger := -1;
end;

procedure Tgp_dlgBill.ibdsDocRealPosBeforeInsert(
  DataSet: TDataSet);
begin
  gsibgrDocRealPos.SelectedField := ibdsDocRealPos.FieldByName('Name');
end;

procedure Tgp_dlgBill.gsiblcFromContactChange(Sender: TObject);
var
  ibsql: TIBSQL;
begin
  if FPriceWithContact and (gsiblcFromContact.CurrentKey > '') then
  begin
    if FisAppend then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := IBTransaction;
        ibsql.SQL.Text :=
          'SELECT * FROM gd_price p WHERE ' +
          '  p.relevancedate = ' +
          '  (SELECT MAX(p1.relevanceDATE) FROM gd_price p1 WHERE p1.relevanceDATE <= :d and ' +
          '          p1.pricetype = ''C'' and p1.contactkey = :c) AND p.contactkey = :c and p.pricetype = ''C''';
        ibsql.Prepare;
        ibsql.ParamByName('d').AsDateTime := ibdsDocument.FieldByName('documentdate').AsDateTime;
        ibsql.ParamByName('c').AsInteger := StrToInt(gsiblcFromContact.CurrentKey);
        ibsql.ExecQuery;
        if ibsql.RecordCount = 1 then
        begin
          if not (ibdsDocRealization.State in [dsEdit, dsInsert]) then
            ibdsDocRealization.Edit;
          ibdsDocRealization.FieldByName('PriceKey').AsInteger := ibsql.FieldByName('id').AsInteger;
        end;
        ibsql.Close;
      finally
        ibsql.Free;
      end;
    end;
    gsiblcPrice.Condition :=
      Format(
          ' pricetype = ''C'' and contactkey = %0:s ', [gsiblcFromContact.CurrentKey]);
  end;
end;

procedure Tgp_dlgBill.ibdsDocRealPosBeforePost(DataSet: TDataSet);
var
  i: Integer;
  isNull: Boolean;
begin
  isNull := True;
  for i:= 0 to gsibgrDocRealPos.Columns.Count - 1 do
    if gsibgrDocRealPos.Columns[i].Visible and not gsibgrDocRealPos.Columns[i].Field.IsNull then
    begin
      isNull := False;
      Break;
    end;

  if isNull then
  begin
    ibdsDocRealPos.Cancel;
    abort;
  end;

  if DataSet.FieldByName('GoodKey').IsNull then
  begin
    MessageBox(HANDLE, 'Необходимо указать наименование ТМЦ!', 'Внимание', mb_Ok or mb_IconInformation);
    gsibgrDocRealPos.SelectedField := DataSet.FieldByName('Name');
    abort;
  end;

  if DataSet.FieldByName('Quantity').AsCurrency = 0 then
  begin
    MessageBox(HANDLE, 'Необходимо указать количество!', 'Внимание', mb_Ok or mb_IconInformation);
    gsibgrDocRealPos.SelectedField := DataSet.FieldByName('Quantity');
    abort;
  end;

end;

procedure Tgp_dlgBill.DoOtherFieldChange(Sender: TField);
var
  i, Num: Integer;
begin
  if LocalChange then exit;
  
  Num := -1;
  for i:= 0 to FTaxList.Count - 1 do
    if UpperCase(TTaxField(FTaxList[i]).FieldName) = UpperCase(Sender.FieldName) then
    begin
      Num := i;
      Break;
    end;

  if UpperCase(Sender.FieldName) = 'TRTYPEKEY' then
    FisTransactionChange := True;

  if Num = -1 then exit;
  CalcAmountTax(Num);
end;

procedure Tgp_dlgBill.CalcAmountTax(Num: Integer);
begin
  if TTaxField(FTaxList[Num]).RelationName <> 'GD_DOCREALPOS' then exit;
  if TTaxField(FTaxList[Num]).IsInclude then
  begin
    if TTaxField(FTaxList[Num]).IsCurrency then
      ibdsDocRealPos.FieldByName('E' + TTaxField(FTaxList[Num]).FieldName).AsCurrency :=
        ibdsDocRealPos.FieldByName('AmountCurr').AsCurrency -
        ibdsDocRealPos.FieldByName(TTaxField(FTaxList[Num]).FieldName).AsCurrency
    else
      ibdsDocRealPos.FieldByName('E' + TTaxField(FTaxList[Num]).FieldName).AsCurrency :=
        ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency -
        ibdsDocRealPos.FieldByName(TTaxField(FTaxList[Num]).FieldName).AsCurrency;
  end
  else
  begin
    if TTaxField(FTaxList[Num]).IsCurrency then
      ibdsDocRealPos.FieldByName('E' + TTaxField(FTaxList[Num]).FieldName).AsCurrency :=
        ibdsDocRealPos.FieldByName('AmountCurr').AsCurrency +
        ibdsDocRealPos.FieldByName(TTaxField(FTaxList[Num]).FieldName).AsCurrency
    else
      ibdsDocRealPos.FieldByName('E' + TTaxField(FTaxList[Num]).FieldName).AsCurrency :=
        ibdsDocRealPos.FieldByName('AmountNCU').AsCurrency +
        ibdsDocRealPos.FieldByName(TTaxField(FTaxList[Num]).FieldName).AsCurrency;
  end;

end;

procedure Tgp_dlgBill.ibdsDocRealPosAfterScroll(DataSet: TDataSet);
begin
  gsiblcValue.Condition :=
    Format('ID IN (SELECT valuekey FROM gd_goodvalue WHERE goodkey = %d) OR (id = %d)',
    [ibdsDocRealPos.FieldByName('goodkey').AsInteger,
     ibdsDocRealPos.FieldByName('goodvaluekey').AsInteger]);

end;

procedure Tgp_dlgBill.DocumentDateChange(Sender: TField);
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text :=
      Format(
      'SELECT * FROM gd_price WHERE ' +
      'relevancedate = (SELECT MAX(relevanceDATE) FROM gd_price WHERE pricetype = ''C'' ' +
      ' and relevanceDATE <= ''%S'')',
      [Sender.AsString]);
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      FPriceKey := ibsql.FieldByName('id').AsInteger
    else
      FPriceKey := -1;
    ibsql.Close;
    if FPriceKey <> ibdsDocRealization.FieldByName('pricekey').AsInteger then
    begin

      if not (ibdsDocument.State in [dsEdit, dsInsert]) then
        ibdsDocument.Edit;

      if FPriceKey <> -1 then
        ibdsDocRealization.FieldByName('pricekey').AsInteger := FPriceKey
      else
        ibdsDocRealization.FieldByName('pricekey').Clear;
        
    end;    
  finally
    ibsql.Free;
  end;
end;

procedure Tgp_dlgBill.DoPriceKeyChange(Sender: TField);
begin
  if not Sender.IsNull and (Sender.AsInteger > 0) then
  begin
    FPriceKey := Sender.AsInteger;
    SetConditionGood;
  end
  else
    FPriceKey := -1;  
end;

procedure Tgp_dlgBill.FormShow(Sender: TObject);
begin
  dbedNumber.SetFocus;
end;

procedure Tgp_dlgBill.DoChangeField(Sender: TField);
begin
  SetCurPriceField('');
end;

procedure Tgp_dlgBill.gsiblcGoodExit(Sender: TObject);
begin
  try
    if ibdsDocRealPos.State in [dsEdit, dsInsert] then
      ibdsDocRealPosGOODKEYChange(ibdsDocRealPos.FieldByName('GoodKey'));
    SendMessage(gsibgrDocRealPos.Handle, WM_KEYDOWN, VK_TAB, 0);
  finally
    bOk.Default := True;
  end;
end;

procedure Tgp_dlgBill.gsibgrDocRealPosEnter(Sender: TObject);
begin
  if ibdsDocRealPos.FieldByName('ID').IsNull then
    gsibgrDocRealPos.SelectedField := ibdsDocRealPos.FieldByName('Name');
end;

procedure Tgp_dlgBill.actCalcAmountExecute(Sender: TObject);
begin
  if ibdsDocRealPos.State in [dsEdit, dsInsert] then
    ibdsDocRealPos.Post;
  CalcAmountBill;
end;

procedure Tgp_dlgBill.JoinRecord;
var
  Bookmark: TBookmark;
  Quantity: Currency;
  Code: Longint;
  CostNCU: Currency;
  CostCurr: Currency;
  isOk: Boolean;
  Weight, OldWeight: Currency;
  DateWork: TDateTime;
begin
  ibdsDocRealPos.DisableControls;
  try
    ibdsDocRealPos.Last;
    while not ibdsDocRealPos.BOF do
    begin
      Bookmark := ibdsDocRealPos.GetBookmark;
      Quantity := ibdsDocRealPos.FieldByName('Quantity').AsCurrency;
      CostNCU := ibdsDocRealPos.FieldByName('CostNCU').AsCurrency;
      CostCurr := ibdsDocRealPos.FieldByName('CostCurr').AsCurrency;
      Code := ibdsDocRealPos.FieldByName('GoodKey').AsInteger;
      Weight := ibdsDocRealPos.FieldByName('Weight').AsCurrency;
      if ibdsDocRealPos.FindField('USR$DATAWORK') <> nil then
        DateWork := ibdsDocRealPos.FieldByName('USR$DATAWORK').AsCurrency
      else
        DateWork := 0;

      isOk := False;

      ibdsDocRealPos.Prior;
      while not ibdsDocRealPos.BOF do
      begin
        if (ibdsDocRealPos.FieldByName('GoodKey').AsInteger = Code) and
           (ibdsDocRealPos.FieldByName('CostNCU').AsCurrency = CostNCU) and
           (ibdsDocRealPos.FieldByName('CostCurr').AsCurrency = CostCurr) and
           (
            (ibdsDocRealPos.FindField('USR$DATAWORK') = nil) or
            (ibdsDocRealPos.FieldByName('USR$DATAWORK').AsDateTime = DateWork)
           ) 
        then
        begin
          ibdsDocRealPos.Edit;
          OldWeight := ibdsDocRealPos.FieldByName('Weight').AsCurrency;
          ibdsDocRealPos.FieldByName('Quantity').AsCurrency :=
            ibdsDocRealPos.FieldByName('Quantity').AsCurrency + Quantity;
          ibdsDocRealPos.FieldByName('Weight').AsCurrency :=
            OldWeight + Weight;
          ibdsDocRealPos.Post;
          isOk := True;
          Break;
        end;
        ibdsDocRealPos.Prior;
      end;
      ibdsDocRealPos.GotoBookmark(Bookmark);
      ibdsDocRealPos.FreeBookmark(Bookmark);
      if isOk then
        ibdsDocRealPos.Delete
      else
        ibdsDocRealPos.Prior;
    end;
  finally
    ibdsDocRealPos.EnableControls;
  end;
end;

function Tgp_dlgBill.CheckDublicate: Boolean;
begin
  Result := False;

  ibsqlCheckNumber.Prepare;
  ibsqlCheckNumber.ParamByName('dt').AsInteger :=
    FDocumentType;
  ibsqlCheckNumber.ParamByName('ck').AsInteger :=
    IBLogin.CompanyKey;
  ibsqlCheckNumber.ParamByName('cid').AsInteger :=
    FDocumentKey;
  ibsqlCheckNumber.ParamByName('number').AsString :=
    ibdsDocument.FieldByName('number').AsString;
  ibsqlCheckNumber.ExecQuery;
  try
    if ibsqlCheckNumber.RecordCount = 1 then
    begin
      MessageBox(HANDLE, 'Дублируется номер документа! ', 'Внимание',
        mb_OK or mb_IconInformation);
      dbedNumber.SetFocus;
      exit;
    end;
  finally
    ibsqlCheckNumber.Close;
  end;

  Result := True;

end;

function Tgp_dlgBill.CalcTransTax(const Current: Integer): Currency;
var
  j: Integer;
  R: TatRelationField;
begin
  xFocal.ClearVariablesList;
  R := atDatabase.FindRelationField('GD_DOCREALIZATION', 'TRANSSUMCURR');
  xFocal.AssignVariable(R.LShortName,
    ibdsDocRealization.FieldByName('TransSumCurr').AsCurrency);
  R := atDatabase.FindRelationField('GD_DOCREALIZATION', 'TRANSSUMNCU');
  xFocal.AssignVariable(R.LShortName,
    ibdsDocRealization.FieldByName('TransSumNCU').AsCurrency);
  R := atDatabase.FindRelationField('GD_DOCREALIZATION', 'RATE');
  xFocal.AssignVariable(R.LShortName,
    ibdsDocRealization.FieldByName('Rate').AsCurrency);
  for j:= 0 to Current do
  begin
    R := atDatabase.FindRelationField('GD_DOCREALIZATION',
      TTaxField(FTaxList[j]).FieldName);
    xFocal.AssignVariable(R.LShortName,
      ibdsDocRealization.FieldByName(TTaxField(FTaxList[j]).FieldName).AsCurrency);
    xFocal.AssignVariable(R.LShortName + '_Ставка', TTaxField(FTaxList[j]).Rate);
  end;
  xFocal.Expression := TTaxField(FTaxList[Current]).Expression;
  Result := RoundCurrency(xFocal.Value, TTaxField(FTaxList[Current]).Rounding);

end;

procedure Tgp_dlgBill.TransSumCurrChange(Sender: TField);
var
  i: Integer;
  Value: Currency;
begin
  for i:= 0 to FTaxList.Count - 1 do
    if (TTaxField(FTaxList[i]).RelationName <> 'GD_DOCREALPOS') and
       TTaxField(FTaxList[i]).IsCurrency
    then
    begin
      if TTaxField(FTaxList[i]).Expression = '' then
      begin
        if TTaxField(FTaxList[i]).IsInclude then
          Value := RoundCurrency(Sender.AsCurrency * TTaxField(FTaxList[i]).Rate /
            (100 + TTaxField(FTaxList[i]).Rate), TTaxField(FTaxList[i]).Rounding)
        else
          Value := RoundCurrency(Sender.AsCurrency * TTaxField(FTaxList[i]).Rate / 100,
                     TTaxField(FTaxList[i]).Rounding);
      end
      else
        Value := CalcTransTax(i);

      if not (ibdsDocRealization.State in [dsEdit, dsInsert]) then
        ibdsDocRealization.Edit;
        
      ibdsDocRealization.FieldByName(TTaxField(FTaxList[i]).FieldName).AsCurrency :=
        Value;
    end;
end;

procedure Tgp_dlgBill.TransSumNCUChange(Sender: TField);
var
  i: Integer;
  Value: Currency;
begin
  for i:= 0 to FTaxList.Count - 1 do
    if (TTaxField(FTaxList[i]).RelationName <> 'GD_DOCREALPOS') and
       not TTaxField(FTaxList[i]).IsCurrency
    then
    begin
      if TTaxField(FTaxList[i]).Expression = '' then
      begin
        if TTaxField(FTaxList[i]).IsInclude then
          Value := RoundCurrency(Sender.AsCurrency * TTaxField(FTaxList[i]).Rate /
            (100 + TTaxField(FTaxList[i]).Rate), TTaxField(FTaxList[i]).Rounding)
        else
          Value := RoundCurrency(Sender.AsCurrency * TTaxField(FTaxList[i]).Rate / 100,
                     TTaxField(FTaxList[i]).Rounding);
      end
      else
        Value := CalcTransTax(i);

      if not (ibdsDocRealization.State in [dsEdit, dsInsert]) then
        ibdsDocRealization.Edit;

      ibdsDocRealization.FieldByName(TTaxField(FTaxList[i]).FieldName).AsCurrency :=
        Value;
    end;
end;

procedure Tgp_dlgBill.DocumentNumberChange(Sender: TField);
begin
  if FCheckNumber and not CheckDublicate then
  begin
    dbedNumber.SetFocus;
    abort;
  end;
end;

procedure Tgp_dlgBill.ibdsDocRealPosPackQUANTITYChange(
  Sender: TField);
begin
  if FisLocalPackQuantChange or LocalChange then exit;
  FisLocalPackQuantChange := True;
  if ibdsDocRealPos.FieldByName('PACKINQUANT').AsCurrency <> 0 then
  begin
    ibdsDocRealPos.FieldByName('Quantity').AsCurrency :=
      ibdsDocRealPos.FieldByName('PACKQUANTITY').AsCurrency *
      ibdsDocRealPos.FieldByName('PACKINQUANT').AsCurrency;
  end;
  MakeOnChangeField(Sender);
  FisLocalPackQuantChange := False;
end;

procedure Tgp_dlgBill.ibdsDocRealInfoAfterInsert(
  DataSet: TDataSet);
begin
  if ibdsDocRealInfo.FieldByName('Loadingpoint').AsString = '' then
    ibdsDocRealInfo.FieldByName('Loadingpoint').AsString := FCity;
  if ibdsDocRealInfo.FieldByName('UnLoadingpoint').AsString = '' then
    ibdsDocRealInfo.FieldByName('UnLoadingpoint').AsString := FCityCustomer;
end;

procedure Tgp_dlgBill.actAddContractExecute(Sender: TObject);
var
  CustomerKey: Integer;
begin
  with Tdlg_gpContractSell.Create(Self) do
    try
      CustomerKey := ibdsDocRealization.FieldByName('tocontactkey').AsInteger;
      if CustomerKey = 0 then
        CustomerKey := -1;
      SetupDialog(-1, CustomerKey);
      ShowModal;
      if isOk then
      begin
        if not (ibdsDocRealInfo.State in [dsEdit, dsInsert]) then
          ibdsDocRealInfo.Edit;
        ibdsDocRealInfo.FieldByName('contractkey').AsInteger := DocumentKey;
        ibdsDocRealInfo.FieldByName('contractnum').AsString := DocumentInfo;  
      end;
    finally
      Free;
    end;
end;

procedure Tgp_dlgBill.gsiblcGoodEnter(Sender: TObject);
begin
  bOk.Default := False;
end;

procedure Tgp_dlgBill.gsiblcGoodKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SendMessage((Sender as TWinControl).Handle, WM_KEYDOWN, VK_TAB, 0);
end;

procedure Tgp_dlgBill.SetConditionGood;
begin

  if FTypeShowDisabledGood = 0 then
    gsiblcGood.Condition := 'DISABLED = 0 AND ' +
      ' ((gr.lb >= (SELECT lb FROM gd_goodgroup WHERE id = 147000003) and ' +
      '   gr.rb <= (SELECT rb FROM gd_goodgroup WHERE id = 147000003)) OR ' +
      '  (gr.lb >= (SELECT lb FROM gd_goodgroup WHERE id = 147003071) and ' +
      '   gr.rb <= (SELECT rb FROM gd_goodgroup WHERE id = 147003071))) '
  else
    gsiblcGood.Condition :=
      ' ((gr.lb >= (SELECT lb FROM gd_goodgroup WHERE id = 147000003) and ' +
      '   gr.rb <= (SELECT rb FROM gd_goodgroup WHERE id = 147000003)) OR ' +
      '  (gr.lb >= (SELECT lb FROM gd_goodgroup WHERE id = 147003071) and ' +
      '   gr.rb <= (SELECT rb FROM gd_goodgroup WHERE id = 147003071))) ';


  if (FPriceKey <> -1) and
     (UserStorage.ReadInteger('realzaitionoption', 'onlypricegood', 0) = 1)
  then
  begin
    if FTypeShowDisabledGood = 0 then
      gsiblcGood.Condition := 'DISABLED = 0 AND ';
    gsiblcGood.Condition := gsiblcGood.Condition +
      Format('id IN (SELECT goodkey FROM gd_pricepos WHERE pricekey = %d)',
        [FPriceKey]);
  end;

end;

procedure Tgp_dlgBill.CopyDocument(const aCopyID: Integer);
var
  ibsql: TIBSQL;

function MakeFields(IncludeField, ExcludeField: array of String; const aNameTable: String): String;
var
  R: TatRelation;
  i: Integer;
  S: String;

function SearchIncludeExclude(const NameField: String): String;
var
  j: Integer;
begin
  Result := NameField;
  for j:= Low(ExcludeField) to High(ExcludeField) do
    if (ExcludeField[j] > '') and (UpperCase(ExcludeField[j]) = UpperCase(Trim(NameField))) then
    begin
      Result := IncludeField[j];
      Break;
    end;
end;

begin
  Assert(High(IncludeField) = High(ExcludeField),
    'Исключаемых полей должно быть столько же сколько включаемых');

  Result := '';
  R := atDatabase.Relations.ByRelationName(aNameTable);
  if Assigned(R) and Assigned(R.RelationFields) then
    for i:= 0 to R.RelationFields.Count - 1 do
    begin
      S := SearchIncludeExclude(R.RelationFields[i].FieldName);
      if S > '' then
      begin
        if Result > '' then
          Result := Result + ',';
        Result := Result + S;
      end
    end;
end;

begin
  ibsql:= TIBSQL.Create(Self);
  try
    FDocumentKey := GenUniqueID;

    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := Format(
      'INSERT INTO gd_document (' + MakeFields([''], [''], 'GD_DOCUMENT') + ')' +
      ' SELECT ' + MakeFields(['%d'], ['ID'], 'GD_DOCUMENT') + ' FROM GD_DOCUMENT WHERE ID = %d',
      [FDocumentKey, aCopyID]);
    ibsql.ExecQuery;
    ibsql.Close;

    ibsql.SQL.Text := Format(
      'INSERT INTO GD_DOCREALIZATION (' + MakeFields([''], [''], 'GD_DOCREALIZATION') + ')' +
      ' SELECT ' + MakeFields(['%d'], ['DOCUMENTKEY'], 'GD_DOCREALIZATION') +
      ' FROM GD_DOCREALIZATION WHERE DOCUMENTKEY = %d',
      [FDocumentKey, aCopyID]);
    ibsql.ExecQuery;
    ibsql.Close;

    ibsql.SQL.Text := Format(
      'INSERT INTO GD_DOCREALINFO (' + MakeFields([''], [''], 'GD_DOCREALINFO') + ')' +
      ' SELECT ' + MakeFields(['%d'], ['DOCUMENTKEY'], 'GD_DOCREALINFO') +
      ' FROM GD_DOCREALINFO WHERE DOCUMENTKEY = %d',
      [FDocumentKey, aCopyID]);
    ibsql.ExecQuery;
    ibsql.Close;

    if GlobalStorage.ReadInteger('realizationoption', 'typecopybill', 1) = 0 then
    begin
      ibsql.SQL.Text := Format(
        'INSERT INTO GD_DOCREALPOS (' + MakeFields([''], [''], 'GD_DOCREALPOS') + ')' +
        ' SELECT ' + MakeFields(['%d', 'NULL'], ['DOCUMENTKEY', 'ID'], 'GD_DOCREALPOS') +
        ' FROM GD_DOCREALPOS WHERE DOCUMENTKEY = %d',
        [FDocumentKey, aCopyID]);
      ibsql.ExecQuery;
      ibsql.Close;
    end;
  finally
    ibsql.Free;
  end;
end;

procedure Tgp_dlgBill.SetGroupTara;
var
  CountGroup, i: Integer;
begin
  FTaraGroup.Clear;
  CountGroup := GlobalStorage.ReadInteger('realizationoption', 'countprintgroup', 0);
  for i:= 1 to CountGroup do
    FTaraGroup.Add(
    IntToStr(
    GlobalStorage.ReadInteger('realizationoption', Format('printgroupkey%d', [i]), 0)));

end;

function Tgp_dlgBill.BeforeSave: Boolean;
begin
  Result := True;
end;

function Tgp_dlgBill.BeforeSetup: Boolean;
begin
  Result := True;
end;

function Tgp_dlgBill.AfterSetup: Boolean;
begin
  Result := True;
end;

function Tgp_dlgBill.AfterSave: Boolean;
begin
  Result := True;
end;

procedure Tgp_dlgBill.MakeOnChangeField(Sender: TField);
begin
  // EmptyMethod
end;

class function Tgp_dlgBill.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gp_dlgBill) then
  begin
    gp_dlgBill := Tgp_dlgBill.Create(AnOwner);
    gp_dlgBill.DocumentType := 802004;
  end;  

  Result := gp_dlgBill;

end;

initialization
  gp_dlgBill := nil;

end.

