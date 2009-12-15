unit Chconst;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Xdblooku, Xtable, DB, DBTables, 
  Buttons, Xbkini, xMemTable, xCommon_anj;

type

  TChooseConstractForm = class(TForm)
    GroupBox1: TGroupBox;
    Label3: TLabel;
    xlcDebetKAU1: TxDBLookupCombo;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    xlcDebet: TxDBLookupCombo;
    Label2: TLabel;
    xlcKredit: TxDBLookupCombo;
    Label4: TLabel;
    xlcDebetKAU2: TxDBLookupCombo;
    Label5: TLabel;
    xlcDebetKAU3: TxDBLookupCombo;
    Label6: TLabel;
    xlcDebetKAU4: TxDBLookupCombo;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    xlcKreditKAU1: TxDBLookupCombo;
    xlcKreditKAU2: TxDBLookupCombo;
    xlcKreditKAU3: TxDBLookupCombo;
    xlcKreditKAU4: TxDBLookupCombo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    mtblConstract: TxMemTable;
    mtblConstractDebet: TStringField;
    mtblConstractKredit: TStringField;
    mtblConstractDebetKAU1: TSmallintField;
    mtblConstractDebetKAU2: TSmallintField;
    mtblConstractDebetKAU3: TSmallintField;
    mtblConstractDebetKAU4: TSmallintField;
    mtblConstractKreditKAU1: TSmallintField;
    mtblConstractKreditKAU2: TSmallintField;
    mtblConstractKreditKAU3: TSmallintField;
    mtblConstractKreditKAU4: TSmallintField;
    DSConstract: TDataSource;
    DSObject: TDataSource;
    tblObject: TxTable;
    tblMainMean: TxTable;
    DSMainMean: TDataSource;
    DSRefGoods: TDataSource;
    tblRefGoods: TxTable;
    tblIndExp: TxTable;
    DSIndExp: TDataSource;
    DSOtrsl: TDataSource;
    tblOtrsl: TxTable;
    DSDeptRef: TDataSource;
    tblDeptRef: TxTable;
    tblPeople: TxTable;
    DSPeople: TDataSource;
    DSKlient: TDataSource;
    tblKlient: TxTable;
    DSObject1: TDataSource;
    tblObject1: TxTable;
    tblMainMean1: TxTable;
    DSMainMean1: TDataSource;
    DSRefGoods1: TDataSource;
    tblRefGoods1: TxTable;
    tblIndExp1: TxTable;
    DSIndExp1: TDataSource;
    DSOtrsl1: TDataSource;
    tblOtrsl1: TxTable;
    DSDeptRef1: TDataSource;
    tblDeptRef1: TxTable;
    tblPeople1: TxTable;
    DSPeople1: TDataSource;
    DSKlient1: TDataSource;
    tblKlient1: TxTable;
    tblAccount: TxTable;
    tblAccountAcount: TStringField;
    tblAccountNameacount: TStringField;
    tblAccountKodform: TSmallintField;
    tblAccountActive: TSmallintField;
    tblAccountNameGroup: TStringField;
    DSAccount: TDataSource;
    tblRefKAU: TxTable;
    tblAccount1: TxTable;
    StringField1: TStringField;
    StringField2: TStringField;
    SmallintField1: TSmallintField;
    SmallintField2: TSmallintField;
    StringField3: TStringField;
    DSAccount1: TDataSource;
    tblObjectKod: TSmallintField;
    tblObjectName: TStringField;
    tblObject1Kod: TSmallintField;
    tblObject1Name: TStringField;
    tblMainMeanKod: TSmallintField;
    tblMainMeanName: TStringField;
    tblMainMean1Kod: TSmallintField;
    tblMainMean1Name: TStringField;
    tblRefGoodsShifrgoods: TSmallintField;
    tblRefGoodsNamegoods: TStringField;
    tblRefGoods1Shifrgoods: TSmallintField;
    tblRefGoods1Namegoods: TStringField;
    tblIndExpCode: TSmallintField;
    tblIndExpAlias: TStringField;
    tblIndExpName: TStringField;
    tblIndExp1Code: TSmallintField;
    tblIndExp1Alias: TStringField;
    tblIndExp1Name: TStringField;
    tblOtrslCode: TSmallintField;
    tblOtrslAlias: TStringField;
    tblOtrslName: TStringField;
    tblOtrsl1Code: TSmallintField;
    tblOtrsl1Alias: TStringField;
    tblOtrsl1Name: TStringField;
    tblDeptRefCode: TSmallintField;
    tblDeptRefAlias: TStringField;
    tblDeptRefName: TStringField;
    tblDeptRef1Code: TSmallintField;
    tblDeptRef1Alias: TStringField;
    tblDeptRef1Name: TStringField;
    tblPeopleKod: TSmallintField;
    tblPeopleFam: TStringField;
    tblPeopleImy: TStringField;
    tblPeopleOtch: TStringField;
    tblPeople1Kod: TSmallintField;
    tblPeople1Fam: TStringField;
    tblPeople1Imy: TStringField;
    tblPeople1Otch: TStringField;
    tblKlientKodKAU: TSmallintField;
    tblKlientName: TStringField;
    tblKlient1KodKAU: TSmallintField;
    tblKlient1Name: TStringField;
    xBookkeepIni: TxBookkeepIni;
    DSCurrency: TDataSource;
    DSKauEquip: TDataSource;
    DSKauOper: TDataSource;
    DSKauPaym: TDataSource;
    DSCurrency1: TDataSource;
    DSKAUEquip1: TDataSource;
    DSKAUOper1: TDataSource;
    DSKAUPaym1: TDataSource;
    tblKAUPaym: TxTable;
    tblKAUPaymCode: TSmallintField;
    tblKAUPaymAlias: TStringField;
    tblKAUPaymName: TStringField;
    tblKAUOper: TxTable;
    tblKAUOperCode: TSmallintField;
    tblKAUOperAlias: TStringField;
    tblKAUOperName: TStringField;
    tblKAUEquip: TxTable;
    tblKAUEquipCode: TSmallintField;
    tblKAUEquipAlias: TStringField;
    tblKAUEquipName: TStringField;
    tblCurrency: TxTable;
    tblCurrencyCurrency: TStringField;
    tblCurrency1: TxTable;
    tblKAUEquip1: TxTable;
    tblKAUOper1: TxTable;
    tblKAUPaym1: TxTable;
    tblKAUPaym1Code: TSmallintField;
    tblKAUPaym1Alias: TStringField;
    tblKAUPaym1Name: TStringField;
    tblKAUOper1Code: TSmallintField;
    tblKAUOper1Alias: TStringField;
    tblKAUOper1Name: TStringField;
    tblKAUEquip1Code: TSmallintField;
    tblKAUEquip1Alias: TStringField;
    tblKAUEquip1Name: TStringField;
    tblCurrency1Currency: TStringField;
    tblKAUchdp: TxTable;
    tblKAUchdpCode: TSmallintField;
    tblKAUchdpAlias: TStringField;
    tblKAUchdpName: TStringField;
    tblKAUProd: TxTable;
    tblKAUProdCode: TSmallintField;
    tblKAUProdAlias: TStringField;
    tblKAUProdName: TStringField;
    DSKAUChDp: TDataSource;
    DSKAUProd: TDataSource;
    tblKAUProd1: TxTable;
    DSKAUProd1: TDataSource;
    tblKAUChDp1: TxTable;
    DSKAUChDp1: TDataSource;
    tblKAUProd1Code: TSmallintField;
    tblKAUProd1Alias: TStringField;
    tblKAUProd1Name: TStringField;
    tblKAUChDp1Code: TSmallintField;
    tblKAUChDp1Alias: TStringField;
    tblKAUChDp1Name: TStringField;
    tblCurrencyCode: TSmallintField;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure xlcDebetExit(Sender: TObject);
    procedure xlcKreditExit(Sender: TObject);
    procedure mtblConstractDebetChange(Sender: TField);
    procedure mtblConstractKreditChange(Sender: TField);
  private
    { Private declarations }
    FDebet: String;
    FKredit: String;
    FDebetKAU: String;
    FKreditKAU: String;
    FDebetKAUName: String;
    FKreditKAUName: String;
    FStopKAU: TKAUTypes;
    procedure SetDebet(aValue: String);
    procedure SetKredit(aValue: String);
    procedure SetDebetKAU(aValue: String);
    procedure SetKreditKAU(aValue: String);

    procedure SetDebetKAUWindow;
    procedure SetKreditKAUWindow;
  public
    { Public declarations }
    property Debet: String read FDebet write SetDebet;
    property Kredit: String read FKredit write SetKredit;
    property DebetKAU: String read FDebetKAU write SetDebetKAU;
    property KreditKAU: String read FKreditKAU write SetKreditKAU;
    property DebetKAUName: String read FDebetKAUName;
    property KreditKAUName: String read FKreditKAUName;
    property StopKAU: TKAUTypes read FStopKAU write FStopKAU;
  end;

var
  ChooseConstractForm: TChooseConstractForm;

implementation

{$R *.DFM}

uses
  xPrgrFrm;

procedure TChooseConstractForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FDebet:= '';
  FKredit:= '';
  FDebetKAU:= '';
  FKreditKAU:= '';
  FStopKAU:= [];

  tblAccount.DatabaseName:= xBookkeepIni.MainDir;
  tblAccount1.DatabaseName:= xBookkeepIni.MainDir;

  tblRefKAU.DatabaseName:= xBookkeepIni.MainDir;

  xBookkeepIni.TypeReferency:= kau_Klient;
  tblKlient.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblKlient1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_People;
  tblPeople.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblPeople1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_Object;
  tblObject.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblObject1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_MainMean;
  tblMainMean.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblMainMean1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_Goods;
  tblRefGoods.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblRefGoods1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_DeptRef;
  tblDeptRef.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblDeptRef1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_IndExp;
  tblIndExp.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblIndExp1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_Otrsl;
  tblOtrsl.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblOtrsl1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_Otrsl;
  tblOtrsl.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblOtrsl1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_KindOperation;
  tblKAUOper.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblKAUoper1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_KindPayment;
  tblKAUPaym.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblKAUPaym1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_GroupEquipment;
  tblKAUEquip.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblKAUEquip1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_ChildDepartment;
  tblKAUChDp.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblKAUChDp1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_KindProduction;
  tblKAUProd.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblKAUProd1.DatabaseName:= xBookkeepIni.ReferencyDir;

  xBookkeepIni.TypeReferency:= kau_Currency;
  tblCurrency.DatabaseName:= xBookkeepIni.ReferencyDir;
  tblCurrency1.DatabaseName:= xBookkeepIni.ReferencyDir;

  OpenDataSets([
    tblRefKAU,
    tblAccount,
    tblAccount1,
    tblKlient,
    tblKlient1,
    tblPeople,
    tblPeople1,
    tblObject,
    tblObject1,
    tblDeptRef,
    tblDeptRef1,
    tblMainMean,
    tblMainMean1], False, False);

  mtblConstract.Open;
  mtblConstract.Append;
  for i:= 0 to 7 do
    mtblConstract.Fields[i + 2].AsInteger := -1;
end;

procedure TChooseConstractForm.SetDebetKAUWindow;

procedure SetLookup(xLookup: TxDBLookupCombo; typeKAU: Integer);
begin
  xLookup.Text:= '';
  xLookup.LookupField:= '';
  xLookup.LookupDisplay:= '';
  xLookup.Enabled:= true;
  case typeKAU of
  kau_Klient:
    begin
      xLookup.LookupSource:= DSKlient;
      if kauClient in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_People:
    begin
      xLookup.LookupSource:= DSPeople;
      if kauPeople in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_Object:
    begin
      xLookup.LookupSource:= DSObject;
      if kauObject in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_Goods:
    begin
      xLookup.LookupSource:= DSRefGoods;
      if kauGoods in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_MainMean:
    begin
      xLookup.LookupSource:= DSMainMean;
      if kauMainMean in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_IndExp:
    begin
      xLookup.LookupSource:= DSIndExp;
      if kauIndExp in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_DeptRef:
    begin
      xLookup.LookupSource:= DSDeptRef;
      if kauDeptRef in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_Otrsl:
    begin
      xLookup.LookupSource:= DSOtrsl;
      if kauOtrsl in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_KindOperation:
    begin
      xLookup.LookupSource:= DSKAUOper;
      if kauKindOperation in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_KindPayment:
    begin
      xLookup.LookupSource:= DSKAUPaym;
      if kauKindPayment in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_GroupEquipment:
    begin
      xLookup.LookupSource:= DSKAUEquip;
      if kauGroupEquipment in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_ChildDepartment:
    begin
      xLookup.LookupSource:= DSKAUChDp;
      if kauGroupEquipment in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_KindProduction:
    begin
      xLookup.LookupSource:= DSKAUProd;
      if kauGroupEquipment in StopKAU then
        xLookup.Enabled:= false;
    end;
  else
    begin
      xLookup.LookupSource:= nil;
      xLookup.Enabled:= False;
    end;
  end;
  if (xLookup.LookupSource = nil) or not xLookup.Enabled then exit;
  if not xLookup.LookupSource.DataSet.Active then
    xLookup.LookupSource.DataSet.Open;
  xLookup.LookupField:= xLookup.LookupSource.DataSet.Fields[0].FieldName;
  xLookup.LookupDisplay:= xLookup.LookupSource.DataSet.Fields[1].FieldName;
end;

var
  PerDebet: String[6];

begin
  if not tblRefKAU.Active then tblRefKAU.Open;
  if Pos('.', FDebet) <> 0 then
    PerDebet:= copy(FDebet, 1, Pos('.', FDebet) - 1)
  else
    PerDebet:= '';
  if tblRefKAU.FindKey([FDebet]) or ((PerDebet <> '') and tblRefKAU.FindKey([PerDebet]))
  then begin
    if (not tblRefKAU.Fields[1].IsNull) and (tblRefKAU.Fields[1].AsInteger <> 0)
    then
      SetLookup(xlcDebetKAU1, tblRefKAU.Fields[1].AsInteger)
    else begin
      xlcDebetKAU1.Text:= '';
      xlcDebetKAU1.Enabled:= false;
    end;

    if (not tblRefKAU.Fields[2].IsNull) and (tblRefKAU.Fields[2].AsInteger <> 0)
    then
      SetLookup(xlcDebetKAU2, tblRefKAU.Fields[2].AsInteger)
    else begin
      xlcDebetKAU2.Text:= '';
      xlcDebetKAU2.Enabled:= false;
    end;

    if (not tblRefKAU.Fields[3].IsNull) and (tblRefKAU.Fields[3].AsInteger <> 0)
    then
      SetLookup(xlcDebetKAU3, tblRefKAU.Fields[3].AsInteger)
    else begin
      xlcDebetKAU3.Text:= '';
      xlcDebetKAU3.Enabled:= false;
    end;

    if (not tblRefKAU.Fields[4].IsNull) and (tblRefKAU.Fields[4].AsInteger <> 0)
    then
      SetLookup(xlcDebetKAU4, tblRefKAU.Fields[4].AsInteger)
    else begin
      xlcDebetKAU4.Text:= '';
      xlcDebetKAU4.Enabled:= false;
    end;
  end
  else begin
    xlcDebetKAU1.Text:= '';
    xlcDebetKAU1.Enabled:= false;

    xlcDebetKAU2.Text:= '';
    xlcDebetKAU2.Enabled:= false;

    xlcDebetKAU3.Text:= '';
    xlcDebetKAU3.Enabled:= false;

    xlcDebetKAU4.Text:= '';
    xlcDebetKAU4.Enabled:= false;
  end;
end;

procedure TChooseConstractForm.SetKreditKAUWindow;

procedure SetLookup(xLookup: TxDBLookupCombo; typeKAU: Integer);
begin
  xLookup.Text:= '';
  xLookup.LookupField:= '';
  xLookup.LookupDisplay:= '';
  xLookup.Enabled:= true;
  case typeKAU of
  kau_Klient:
    begin
      xLookup.LookupSource:= DSKlient1;
      if kauClient in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_People:
    begin
      xLookup.LookupSource:= DSPeople1;
      if kauPeople in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_Object:
    begin
      xLookup.LookupSource:= DSObject1;
      if KAUObject in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_Goods:
    begin
      xLookup.LookupSource:= DSRefGoods1;
      if kauGoods in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_MainMean:
    begin
      xLookup.LookupSource:= DSMainMean1;
      if kauMainMean in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_IndExp:
    begin
      xLookup.LookupSource:= DSIndExp1;
      if kauIndExp in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_DeptRef:
    begin
      xLookup.LookupSource:= DSDeptRef1;
      if kauDeptRef in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_Otrsl:
    begin
      xLookup.LookupSource:= DSOtrsl1;
      if kauOtrsl in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_KindOperation:
    begin
      xLookup.LookupSource:= DSKAUOper1;
      if kauKindOperation in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_KindPayment:
    begin
      xLookup.LookupSource:= DSKAUPaym1;
      if kauKindPayment in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_GroupEquipment:
    begin
      xLookup.LookupSource:= DSKAUEquip1;
      if kauGroupEquipment in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_ChildDepartment:
    begin
      xLookup.LookupSource:= DSKAUChDp1;
      if kauGroupEquipment in StopKAU then
        xLookup.Enabled:= false;
    end;
  kau_KindProduction:
    begin
      xLookup.LookupSource:= DSKAUProd1;
      if kauGroupEquipment in StopKAU then
        xLookup.Enabled:= false;
    end;
  else
    begin
      xLookup.LookupSource:= nil;
      xLookup.Enabled:= False;
    end;
  end;

  if (xLookup.LookupSource = nil) or not xLookup.Enabled then exit;

  if not xLookup.LookupSource.DataSet.Active then
    xLookup.LookupSource.DataSet.Open;
  xLookup.LookupField:= xLookup.LookupSource.DataSet.Fields[0].FieldName;
  xLookup.LookupDisplay:= xLookup.LookupSource.DataSet.Fields[1].FieldName;
end;

var
  PerKredit: String[6];

begin
  if not tblRefKAU.Active then tblRefKAU.Open;
  if Pos('.', FKredit) <> 0 then
    PerKredit:= copy(FKredit, 1, Pos('.', FKredit) - 1)
  else
    PerKredit:= '';

  if tblRefKAU.FindKey([FKredit]) or ((PerKredit = '') and tblRefKAU.FindKey([PerKredit]))
  then begin
    if (not tblRefKAU.Fields[1].IsNull) and (tblRefKAU.Fields[1].AsInteger <> 0)
    then
      SetLookup(xlcKreditKAU1, tblRefKAU.Fields[1].AsInteger)
    else begin
      xlcKreditKAU1.Text:= '';
      xlcKreditKAU1.Enabled:= false;
    end;

    if (not tblRefKAU.Fields[2].IsNull) and (tblRefKAU.Fields[2].AsInteger <> 0)
    then
      SetLookup(xlcKreditKAU2, tblRefKAU.Fields[2].AsInteger)
    else begin
      xlcKreditKAU2.Text:= '';
      xlcKreditKAU2.Enabled:= false;
    end;

    if (not tblRefKAU.Fields[3].IsNull) and (tblRefKAU.Fields[3].AsInteger <> 0)
    then
      SetLookup(xlcKreditKAU3, tblRefKAU.Fields[3].AsInteger)
    else begin
      xlcKreditKAU3.Text:= '';
      xlcKreditKAU3.Enabled:= false;
    end;

    if (not tblRefKAU.Fields[4].IsNull) and (tblRefKAU.Fields[4].AsInteger <> 0)
    then
      SetLookup(xlcKreditKAU4, tblRefKAU.Fields[4].AsInteger)
    else begin
      xlcKreditKAU4.Text:= '';
      xlcKreditKAU4.Enabled:= false;
    end;
  end
  else begin
    xlcKreditKAU1.Text:= '';
    xlcKreditKAU1.Enabled:= false;

    xlcKreditKAU2.Text:= '';
    xlcKreditKAU2.Enabled:= false;

    xlcKreditKAU3.Text:= '';
    xlcKreditKAU3.Enabled:= false;

    xlcKreditKAU4.Text:= '';
    xlcKreditKAU4.Enabled:= false;
  end;
end;

procedure TChooseConstractForm.SetDebet(aValue: String);
begin
  if FDebet <> aValue then begin
    FDebet:= aValue;
    SetDebetKAUWindow;
    if aValue <> '00' then
      mtblConstractDebet.Value:= aValue
    else
      xlcDebet.Text:= '00';
  end;
end;

procedure TChooseConstractForm.SetKredit(aValue: String);
begin
  if FKredit <> aValue then begin
    FKredit:= aValue;
    SetKreditKAUWindow;
    if aValue <> '00' then
      mtblConstractKredit.Value:= aValue
    else
      xlcKredit.Text:= '00';
  end;
end;

procedure TChooseConstractForm.SetDebetKAU(aValue: String);
var
  S: String;
begin
  FDebetKAU:= aValue;
  if aValue = '' then exit;
  S:= aValue;
  if Pos('.', S) <> 0 then begin
    if copy(S, 1, Pos('.', S) - 1) <> '' then
      mtblConstractDebetKAU1.AsString:= copy(S, 1, Pos('.', S) - 1)
  end
  else begin
    if S <> '' then
      mtblConstractDebetKAU1.AsString:= S;
    exit;
  end;

  S:= copy(S, Pos('.', S) + 1, 255);
  if Pos('.', S) <> 0 then begin
    if copy(S, 1, Pos('.', S) - 1) <> '' then
      mtblConstractDebetKAU2.AsString:= copy(S, 1, Pos('.', S) - 1)
  end
  else begin
    if S <> '' then
      mtblConstractDebetKAU2.AsString:= S;
    exit;
  end;

  S:= copy(S, Pos('.', S) + 1, 255);
  if Pos('.', S) <> 0 then begin
    if copy(S, 1, Pos('.', S) - 1) <> '' then
      mtblConstractDebetKAU3.AsString:= copy(S, 1, Pos('.', S) - 1)
  end
  else begin
    if S <> '' then
      mtblConstractDebetKAU3.AsString:= S;
    exit;
  end;

  S:= copy(S, Pos('.', S) + 1, 255);
  if Pos('.', S) <> 0 then begin
    if copy(S, 1, Pos('.', S) - 1) <> '' then
      mtblConstractDebetKAU4.AsString:= copy(S, 1, Pos('.', S) - 1)
  end
  else
    if S <> '' then
      mtblConstractDebetKAU4.AsString:= S;
end;

procedure TChooseConstractForm.SetKreditKAU(aValue: String);
var
  S: String;
begin
  FKreditKAU:= aValue;
  if aValue = '' then exit;
  S:= aValue;
  if Pos('.', S) <> 0 then
  begin
    if copy(S, 1, Pos('.', S) - 1) <> '' then
      mtblConstractKreditKAU1.AsString:= copy(S, 1, Pos('.', S) - 1);
  end
  else begin
    if S <> '' then
      mtblConstractKreditKAU1.AsString:= S;
    exit;
  end;

  S:= copy(S, Pos('.', S) + 1, 255);
  if Pos('.', S) <> 0 then
  begin
    if copy(S, 1, Pos('.', S) - 1) <> '' then
      mtblConstractKreditKAU2.AsString:= copy(S, 1, Pos('.', S) - 1)
  end
  else begin
    if S <> '' then
      mtblConstractKreditKAU2.AsString:= S;
    exit;
  end;

  S:= copy(S, Pos('.', S) + 1, 255);
  if Pos('.', S) <> 0 then begin
    if copy(S, 1, Pos('.', S) - 1) <> '' then
      mtblConstractKreditKAU3.AsString:= copy(S, 1, Pos('.', S) - 1)
  end
  else begin
    if S <> '' then
      mtblConstractKreditKAU3.AsString:= S;
    exit;
  end;

  S:= copy(S, Pos('.', S) + 1, 255);
  if Pos('.', S) <> 0 then begin
    if copy(S, 1, Pos('.', S) - 1) <> '' then
      mtblConstractKreditKAU4.AsString:= copy(S, 1, Pos('.', S) - 1)
  end
  else
    if S <> '' then
      mtblConstractKreditKAU4.AsString:= S;
end;

procedure TChooseConstractForm.BitBtn1Click(Sender: TObject);
begin
  FDebet:= xlcDebet.Text;
  FKredit:= xlcKredit.Text;
  FDebetKAU:= '';
  if xlcDebetKAU1.Text <> '' then
    FDebetKAU:= mtblConstract.Fields[2].AsString;
  if xlcDebetKAU2.Text <> '' then
    FDebetKAU:= FDebetKAU + '.' + mtblConstract.Fields[3].AsString
  else
    FDebetKAU:= FDebetKAU + '.';
  if xlcDebetKAU3.Text <> '' then
    FDebetKAU:= FDebetKAU + '.' + mtblConstract.Fields[4].AsString
  else
    FDebetKAU:= FDebetKAU + '.';
  if xlcDebetKAU4.Text <> '' then
    FDebetKAU:= FDebetKAU + '.' + mtblConstract.Fields[5].AsString
  else
    FDebetKAU:= FDebetKAU + '.';

  FDebetKAUName:= xlcDebetKAU1.Text + ' ' + xlcDebetKAU2.Text + ' ' +
    xlcDebetKAU3.Text + ' ' + xlcDebetKAU4.Text;

  FKreditKAU:= '';
  if xlcKreditKAU1.Text <> '' then
    FKreditKAU:= mtblConstract.Fields[6].AsString;
  if xlcKreditKAU2.Text <> '' then
    FKreditKAU:= FKreditKAU + '.' + mtblConstract.Fields[7].AsString
  else
    FKreditKAU:= FKreditKAU + '.';
  if xlcKreditKAU3.Text <> '' then
    FKreditKAU:= FKreditKAU + '.' + mtblConstract.Fields[8].AsString
  else
    FKreditKAU:= FKreditKAU + '.';
  if xlcKreditKAU4.Text <> '' then
    FKreditKAU:= FKreditKAU + '.' + mtblConstract.Fields[9].AsString
  else
    FKreditKAU:= FKreditKAU + '.';

  FKreditKAUName:= xlcKreditKAU1.Text + ' ' + xlcKreditKAU2.Text + ' ' +
    xlcKreditKAU3.Text + ' ' + xlcKreditKAU4.Text;

end;

procedure TChooseConstractForm.xlcDebetExit(Sender: TObject);
begin
  if xlcDebet.NewEnter and (xlcDebet.Text <> '00') and (ModalResult <> mrCancel) then begin
    MessageBox(HANDLE, '”казанный счет не введен в справочник', '¬нимание',
      mb_Ok or mb_IconInformation);
    xlcDebet.SetFocus;
    abort;
  end;
end;

procedure TChooseConstractForm.xlcKreditExit(Sender: TObject);
begin
  if xlcKredit.NewEnter and (xlcKredit.Text <> '00') and (ModalResult <> mrCancel) then begin
    MessageBox(HANDLE, '”казанный счет не введен в справочник', '¬нимание',
      mb_Ok or mb_IconInformation);
    xlcKredit.SetFocus;
    abort;
  end;
end;

procedure TChooseConstractForm.mtblConstractDebetChange(Sender: TField);
begin
  if FDebet <> Sender.Text then begin
    FDebet:= Sender.Text;
    SetDebetKAUWindow;
  end;
end;

procedure TChooseConstractForm.mtblConstractKreditChange(Sender: TField);
begin
  if FKredit <> Sender.Text then begin
    FKredit:= Sender.Text;
    SetKreditKAUWindow;
  end;
end;

end.
