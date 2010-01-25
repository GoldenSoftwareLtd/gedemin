inherited dlgRealizationBill: TdlgRealizationBill
  Left = 305
  Top = 102
  Width = 696
  Height = 505
  Caption = 'Документ на реализацию'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pcBill: TPageControl
    Width = 688
    Height = 225
    inherited tsMain: TTabSheet
      inherited Panel1: TPanel
        Width = 680
        Height = 197
        inherited Label7: TLabel
          Top = 120
        end
        inherited Label8: TLabel
          Top = 120
        end
        inherited Label25: TLabel
          Left = 344
          Top = 145
        end
        inherited Label9: TLabel
          Left = 192
          Top = 225
          Visible = False
        end
        object Label24: TLabel [12]
          Left = 13
          Top = 93
          Width = 90
          Height = 13
          Caption = 'Транспортировка'
        end
        object Label26: TLabel [13]
          Left = 13
          Top = 145
          Width = 111
          Height = 13
          Caption = 'Сумма трансп. с НДС'
        end
        inherited gsiblcPrice: TgsIBLookupComboBox
          Top = 115
          TabOrder = 8
        end
        inherited cbPriceField: TComboBox
          Top = 116
          TabOrder = 9
        end
        inherited ddeDatePayment: TxDateDBEdit
          Left = 476
          Top = 141
          Width = 189
          TabOrder = 11
        end
        inherited dbcbDelayed: TDBCheckBox
          Left = 12
          Top = 169
          TabOrder = 12
        end
        inherited dbedDescription: TDBEdit
          Left = 325
          Top = 221
          TabOrder = 14
          Visible = False
        end
        object dbgrTypeTransport: TDBRadioGroup
          Left = 115
          Top = 83
          Width = 549
          Height = 30
          Columns = 5
          DataField = 'TYPETRANSPORT'
          DataSource = dsDocRealization
          Items.Strings = (
            'Центровывоз'
            'Самовывоз'
            'Аренда'
            'Ж/Д'
            'Прочее')
          TabOrder = 7
          Values.Strings = (
            'C'
            'S'
            'R'
            'W'
            'O')
        end
        object dbedTransSumNCU: TDBEdit
          Left = 150
          Top = 140
          Width = 190
          Height = 21
          DataField = 'TRANSSUMNCU'
          DataSource = dsDocRealization
          TabOrder = 10
        end
        object dbcbIsRealization: TDBCheckBox
          Left = 185
          Top = 169
          Width = 152
          Height = 14
          Caption = 'Включать в реализацию'
          DataField = 'ISREALIZATION'
          DataSource = dsDocRealization
          TabOrder = 13
          ValueChecked = '1'
          ValueUnchecked = '0'
        end
      end
    end
    object tsAddInfo: TTabSheet [1]
      Caption = '&2. Дополнительно'
      ImageIndex = 2
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 680
        Height = 197
        Align = alClient
        BevelInner = bvLowered
        BevelOuter = bvNone
        BorderWidth = 4
        TabOrder = 0
        object Label10: TLabel
          Left = 10
          Top = 15
          Width = 86
          Height = 13
          Caption = 'Грузополучатель'
        end
        object Label11: TLabel
          Left = 336
          Top = 15
          Width = 62
          Height = 13
          Caption = 'Автомобиль'
        end
        object Label12: TLabel
          Left = 10
          Top = 64
          Width = 90
          Height = 13
          Caption = 'Владелец трансп.'
        end
        object Label13: TLabel
          Left = 336
          Top = 64
          Width = 48
          Height = 13
          Caption = 'Водитель'
        end
        object Label14: TLabel
          Left = 10
          Top = 89
          Width = 79
          Height = 13
          Caption = 'Пункт погрузки'
        end
        object Label15: TLabel
          Left = 336
          Top = 89
          Width = 53
          Height = 13
          Caption = 'Разгрузки'
        end
        object Label16: TLabel
          Left = 10
          Top = 39
          Width = 38
          Height = 13
          Caption = 'Прицеп'
        end
        object Label17: TLabel
          Left = 10
          Top = 114
          Width = 45
          Height = 13
          Caption = 'Маршрут'
        end
        object Label18: TLabel
          Left = 336
          Top = 114
          Width = 59
          Height = 13
          Caption = 'Переадрес.'
        end
        object Label19: TLabel
          Left = 528
          Top = 114
          Width = 62
          Height = 13
          Caption = '№ пут.листа'
        end
        object Label20: TLabel
          Left = 10
          Top = 139
          Width = 50
          Height = 13
          Caption = 'Сдал груз'
        end
        object Label21: TLabel
          Left = 336
          Top = 139
          Width = 38
          Height = 13
          Caption = 'Принял'
        end
        object Label22: TLabel
          Left = 336
          Top = 164
          Width = 35
          Height = 13
          Caption = '№ дов.'
        end
        object Label23: TLabel
          Left = 529
          Top = 164
          Width = 26
          Height = 13
          Caption = 'Дата'
        end
        object Label27: TLabel
          Left = 10
          Top = 164
          Width = 60
          Height = 13
          Caption = 'Экспедитор'
        end
        object Label30: TLabel
          Left = 336
          Top = 40
          Width = 32
          Height = 13
          Caption = 'Гараж'
        end
        object iblcCargoReceiver: TgsIBLookupComboBox
          Left = 103
          Top = 11
          Width = 223
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = IBTranLookup
          DataSource = dsDocRealInfo
          DataField = 'CARGORECEIVERKEY'
          ListTable = 'GD_CONTACT'
          ListField = 'NAME'
          KeyField = 'ID'
          Condition = 'contacttype=3'
          gdClassName = 'TgdcCompany'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object ibdblcCarOwner: TgsIBLookupComboBox
          Left = 103
          Top = 60
          Width = 223
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = IBTranLookup
          DataSource = dsDocRealInfo
          DataField = 'CAROWNERKEY'
          Fields = 'CITY'
          ListTable = 'GD_CONTACT'
          ListField = 'NAME'
          KeyField = 'ID'
          Condition = 'contacttype=3'
          gdClassName = 'TgdcCompany'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object dbedDriver: TDBEdit
          Left = 403
          Top = 60
          Width = 266
          Height = 21
          DataField = 'DRIVER'
          DataSource = dsDocRealInfo
          TabOrder = 5
        end
        object dbedLOADINGPOINT: TDBEdit
          Left = 103
          Top = 85
          Width = 223
          Height = 21
          DataField = 'LOADINGPOINT'
          DataSource = dsDocRealInfo
          TabOrder = 6
        end
        object dbedUNLOADINGPOINT: TDBEdit
          Left = 403
          Top = 85
          Width = 266
          Height = 21
          DataField = 'UNLOADINGPOINT'
          DataSource = dsDocRealInfo
          TabOrder = 7
        end
        object dbedHooked: TDBEdit
          Left = 103
          Top = 35
          Width = 223
          Height = 21
          DataField = 'HOOKED'
          DataSource = dsDocRealInfo
          TabOrder = 2
        end
        object dbedROUTE: TDBEdit
          Left = 103
          Top = 110
          Width = 223
          Height = 21
          DataField = 'ROUTE'
          DataSource = dsDocRealInfo
          TabOrder = 8
        end
        object dbedREADDRESSING: TDBEdit
          Left = 403
          Top = 110
          Width = 121
          Height = 21
          DataField = 'READDRESSING'
          DataSource = dsDocRealInfo
          TabOrder = 9
        end
        object dbedWAYSHEETNUMBER: TDBEdit
          Left = 596
          Top = 110
          Width = 71
          Height = 21
          DataField = 'WAYSHEETNUMBER'
          DataSource = dsDocRealInfo
          TabOrder = 10
        end
        object gsiblcSURRENDER: TgsIBLookupComboBox
          Left = 103
          Top = 135
          Width = 225
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = IBTranLookup
          DataSource = dsDocRealInfo
          DataField = 'SURRENDERKEY'
          ListTable = 'GD_CONTACT'
          ListField = 'NAME'
          KeyField = 'ID'
          Condition = 'contacttype=2'
          gdClassName = 'TgdcContact'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 11
        end
        object dbedWarrantNumber: TDBEdit
          Left = 403
          Top = 160
          Width = 121
          Height = 21
          DataField = 'WARRANTNUMBER'
          DataSource = dsDocRealInfo
          TabOrder = 14
        end
        object ddbWarrantDate: TxDateDBEdit
          Left = 597
          Top = 160
          Width = 71
          Height = 21
          DataField = 'WARRANTDATE'
          DataSource = dsDocRealInfo
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 15
        end
        object dbedReception: TDBEdit
          Left = 403
          Top = 135
          Width = 266
          Height = 21
          DataField = 'RECEPTION'
          DataSource = dsDocRealInfo
          TabOrder = 12
        end
        object gsiblcForwarder: TgsIBLookupComboBox
          Left = 103
          Top = 160
          Width = 225
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = IBTranLookup
          DataSource = dsDocRealInfo
          DataField = 'FORWARDERKEY'
          ListTable = 'GD_CONTACT'
          ListField = 'NAME'
          KeyField = 'ID'
          Condition = 'contacttype=2'
          gdClassName = 'TgdcContact'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 13
        end
        object dbcbCar: TDBComboBox
          Left = 403
          Top = 10
          Width = 266
          Height = 21
          DataField = 'CAR'
          DataSource = dsDocRealInfo
          ItemHeight = 13
          Items.Strings = (
            'МАЗ'
            'КАМАЗ'
            'ЗИЛ'
            'ГАЗ'
            'ИВЕКО'
            'МЕРСЕДЕС'
            'КРАЗ')
          TabOrder = 1
        end
        object dbedGarage: TDBEdit
          Left = 403
          Top = 35
          Width = 266
          Height = 21
          DataField = 'GARAGE'
          DataSource = dsDocRealInfo
          TabOrder = 3
        end
      end
    end
    inherited TabSheet3: TTabSheet
      Caption = '&3. Атрибуты'
      inherited atContainer: TatContainer
        Width = 680
        Height = 197
      end
    end
  end
  inherited Panel2: TPanel
    Top = 437
    Width = 688
    inherited Panel4: TPanel
      Left = 428
    end
  end
  inherited Panel3: TPanel
    Top = 225
    Width = 688
    Height = 212
    inherited gsibgrDocRealPos: TgsIBCtrlGrid
      Width = 676
      Height = 123
    end
    inherited ToolBar1: TToolBar
      Width = 676
      ButtonWidth = 80
      inherited ToolButton2: TToolButton
        Left = 80
      end
      inherited cbAmount: TCheckBox
        Left = 160
      end
      object ToolButton3: TToolButton
        Left = 384
        Top = 0
        Action = actChooseBill
      end
    end
    inherited lvAmount: TListView
      Top = 154
      Width = 676
    end
  end
  inherited ibdsDocRealization: TIBDataSet
    InsertSQL.Strings = (
      'insert into gd_docrealization'
      '  (DOCUMENTKEY, TOCONTACTKEY, FROMCONTACTKEY, '
      '   TRANSSUMNCU, TRANSSUMCURR, '
      '   PRICEKEY, PRICEFIELD, RATE, ISREALIZATION, TYPETRANSPORT)'
      'values'
      '  (:DOCUMENTKEY, :TOCONTACTKEY, :FROMCONTACTKEY, '
      '   :TRANSSUMNCU, :TRANSSUMCURR,'
      
        '   :PRICEKEY, :PRICEFIELD, :RATE, :ISREALIZATION, :TYPETRANSPORT' +
        ')')
    ModifySQL.Strings = (
      'update gd_docrealization'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  TOCONTACTKEY = :TOCONTACTKEY,'
      '  FROMCONTACTKEY = :FROMCONTACTKEY,'
      '  TRANSSUMNCU = :TRANSSUMNCU,'
      '  TRANSSUMCURR = :TRANSSUMCURR,'
      '  PRICEKEY = :PRICEKEY,'
      '  PRICEFIELD = :PRICEFIELD,'
      '  ISREALIZATION = :ISREALIZATION,'
      '  TYPETRANSPORT = :TYPETRANSPORT,'
      '  RATE = :RATE'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
  end
  inherited ActionList1: TActionList
    object actChooseBill: TAction
      Caption = 'Выбор счета...'
      OnExecute = actChooseBillExecute
    end
  end
  inherited ibdsDocRealInfo: TIBDataSet
    InsertSQL.Strings = (
      'insert into gd_docrealinfo'
      '  (DOCUMENTKEY, CARGORECEIVERKEY, CAR, CAROWNERKEY, DRIVER, '
      'LOADINGPOINT, '
      '   UNLOADINGPOINT, ROUTE, READDRESSING, HOOKED, WAYSHEETNUMBER, '
      'SURRENDERKEY, '
      '   RECEPTION, WARRANTNUMBER, WARRANTDATE, CONTRACTNUM, '
      'DATEPAYMENT,'
      '   FORWARDERKEY, CONTRACTKEY)'
      'values'
      
        '  (:DOCUMENTKEY, :CARGORECEIVERKEY, :CAR, :CAROWNERKEY, :DRIVER,' +
        ' '
      ':LOADINGPOINT, '
      '   :UNLOADINGPOINT, :ROUTE, :READDRESSING, :HOOKED, '
      ':WAYSHEETNUMBER, :SURRENDERKEY, '
      '   :RECEPTION, :WARRANTNUMBER, :WARRANTDATE, :CONTRACTNUM, '
      ':DATEPAYMENT, '
      ' :FORWARDERKEY, :CONTRACTKEY)')
  end
  inherited xFoCal: TxFoCal
    _variables_ = (
      'PI'
      3.14159265358979
      'E'
      2.71828182845905)
  end
end
