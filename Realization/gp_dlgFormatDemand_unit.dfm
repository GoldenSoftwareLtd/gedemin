object dlgFormatDemand: TdlgFormatDemand
  Left = 193
  Top = 115
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Шаблон формирования требования'
  ClientHeight = 409
  ClientWidth = 582
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 582
    Height = 409
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel2: TBevel
      Left = 7
      Top = 97
      Width = 566
      Height = 115
      Shape = bsFrame
    end
    object Bevel1: TBevel
      Left = 7
      Top = 33
      Width = 566
      Height = 60
      Shape = bsFrame
    end
    object Bevel3: TBevel
      Left = 7
      Top = 217
      Width = 566
      Height = 58
      Shape = bsFrame
    end
    object Label17: TLabel
      Left = 18
      Top = 278
      Width = 69
      Height = 29
      AutoSize = False
      Caption = 'Назначение платежа:'
      Transparent = True
      WordWrap = True
    end
    object Label2: TLabel
      Left = 17
      Top = 12
      Width = 29
      Height = 13
      Caption = 'Дата:'
      Transparent = True
    end
    object Label4: TLabel
      Left = 353
      Top = 12
      Width = 96
      Height = 13
      Caption = 'Зачислить на счет:'
      Transparent = True
    end
    object Label12: TLabel
      Left = 18
      Top = 69
      Width = 37
      Height = 13
      Caption = 'Сумма:'
      Transparent = True
    end
    object Label10: TLabel
      Left = 18
      Top = 227
      Width = 46
      Height = 13
      Caption = 'Вид обр.:'
      Transparent = True
    end
    object Label16: TLabel
      Left = 395
      Top = 227
      Width = 60
      Height = 13
      Caption = 'Очер. плат.:'
      Transparent = True
    end
    object Label6: TLabel
      Left = 18
      Top = 253
      Width = 61
      Height = 13
      Caption = 'Назн. плат.:'
      Transparent = True
    end
    object Label7: TLabel
      Left = 208
      Top = 253
      Width = 74
      Height = 13
      Caption = 'Срок платежа:'
      Transparent = True
    end
    object Label11: TLabel
      Left = 208
      Top = 227
      Width = 52
      Height = 13
      Caption = 'Вид опер.:'
      Transparent = True
    end
    object Label18: TLabel
      Left = 18
      Top = 42
      Width = 67
      Height = 13
      Caption = 'Плательщик:'
    end
    object Label8: TLabel
      Left = 19
      Top = 109
      Width = 96
      Height = 13
      Caption = 'Грузоотправитель:'
      Transparent = True
    end
    object Label9: TLabel
      Left = 19
      Top = 134
      Width = 89
      Height = 13
      Caption = 'Грузополучатель:'
      Transparent = True
    end
    object Label13: TLabel
      Left = 19
      Top = 160
      Width = 47
      Height = 13
      Caption = 'Договор:'
      Transparent = True
    end
    object Label14: TLabel
      Left = 19
      Top = 185
      Width = 65
      Height = 13
      Caption = 'Кв./накл. №:'
      Transparent = True
    end
    object Label15: TLabel
      Left = 389
      Top = 134
      Width = 77
      Height = 13
      Caption = 'Дата отгрузки:'
      Transparent = True
    end
    object Label19: TLabel
      Left = 389
      Top = 160
      Width = 79
      Height = 13
      Caption = 'Дата отправки:'
      Transparent = True
    end
    object sbSum: TSpeedButton
      Left = 542
      Top = 65
      Width = 21
      Height = 21
      Caption = '...'
      OnClick = sbSumClick
    end
    object sbContract: TSpeedButton
      Left = 364
      Top = 155
      Width = 21
      Height = 21
      Caption = '...'
      OnClick = sbContractClick
    end
    object sbBill: TSpeedButton
      Left = 542
      Top = 181
      Width = 21
      Height = 21
      Caption = '...'
      OnClick = sbBillClick
    end
    object sbDestanation: TSpeedButton
      Left = 542
      Top = 279
      Width = 22
      Height = 22
      Caption = '...'
      OnClick = sbDestanationClick
    end
    object Bevel4: TBevel
      Left = 1
      Top = 363
      Width = 581
      Height = 5
      Shape = bsTopLine
    end
    object sbDatePayment: TSpeedButton
      Left = 542
      Top = 249
      Width = 21
      Height = 21
      Caption = '...'
      OnClick = sbDatePaymentClick
    end
    object Label1: TLabel
      Left = 18
      Top = 309
      Width = 50
      Height = 13
      Caption = 'Операция'
    end
    object dbeDest: TgsIBLookupComboBox
      Left = 122
      Top = 249
      Width = 76
      Height = 21
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTransaction
      ListTable = 'BN_DESTCODE'
      ListField = 'CODE'
      KeyField = 'ID'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
    end
    object cbPayer: TComboBox
      Left = 122
      Top = 40
      Width = 441
      Height = 21
      Hint = 'CORRCOMPANYKEY%BN_DEMANDPAYMENT'
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
    end
    object edSum: TEdit
      Left = 122
      Top = 65
      Width = 419
      Height = 21
      Hint = 'AMOUNT%BN_DEMANDPAYMENT'
      TabOrder = 3
    end
    object cbCargoSender: TComboBox
      Left = 122
      Top = 105
      Width = 441
      Height = 21
      Hint = 'CARGOSENDER%BN_DEMANDPAYMENT'
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
    end
    object cbCargoReceiver: TComboBox
      Left = 122
      Top = 130
      Width = 263
      Height = 21
      Hint = 'CARGORECIEVER%BN_DEMANDPAYMENT'
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 5
    end
    object cbDocumentDate: TComboBox
      Left = 122
      Top = 7
      Width = 220
      Height = 21
      Hint = 'DOCUMENTDATE%GD_DOCUMENT'
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object cbDateShip: TComboBox
      Left = 470
      Top = 130
      Width = 93
      Height = 21
      Hint = 'CARGOSENDDATE%BN_DEMANDPAYMENT'
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 6
    end
    object cbDateSend: TComboBox
      Left = 470
      Top = 155
      Width = 93
      Height = 21
      Hint = 'PAPERSENDDATE%BN_DEMANDPAYMENT'
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 8
    end
    object edContract: TEdit
      Left = 122
      Top = 155
      Width = 241
      Height = 21
      Hint = 'CONTRACT%BN_DEMANDPAYMENT'
      TabOrder = 7
    end
    object edOper: TEdit
      Left = 122
      Top = 224
      Width = 76
      Height = 21
      Hint = 'PROC%BN_DEMANDPAYMENT'
      TabOrder = 10
    end
    object edOperKind: TEdit
      Left = 306
      Top = 224
      Width = 76
      Height = 21
      Hint = 'OPER%BN_DEMANDPAYMENT'
      TabOrder = 11
    end
    object edQueue: TEdit
      Left = 470
      Top = 224
      Width = 93
      Height = 21
      Hint = 'QUEUE%BN_DEMANDPAYMENT'
      TabOrder = 12
    end
    object edTerm: TEdit
      Left = 306
      Top = 249
      Width = 235
      Height = 21
      Hint = 'TERM%BN_DEMANDPAYMENT'
      TabOrder = 14
    end
    object gsiblcOurAccount: TgsIBLookupComboBox
      Left = 457
      Top = 7
      Width = 104
      Height = 21
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTransaction
      ListTable = 'GD_COMPANYACCOUNT'
      ListField = 'ACCOUNT'
      KeyField = 'ID'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object edPaper: TEdit
      Left = 122
      Top = 181
      Width = 419
      Height = 21
      Hint = 'PAPER%BN_DEMANDPAYMENT'
      TabOrder = 9
    end
    object edPaymentDestination: TEdit
      Left = 122
      Top = 279
      Width = 419
      Height = 21
      Hint = 'DESTINATION%BN_DEMANDPAYMENT'
      TabOrder = 15
    end
    object bOk: TButton
      Left = 182
      Top = 379
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 18
      OnClick = bOkClick
    end
    object bCancel: TButton
      Left = 325
      Top = 379
      Width = 75
      Height = 25
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 19
    end
    object cbUnionBill: TCheckBox
      Left = 19
      Top = 338
      Width = 230
      Height = 14
      Caption = 'Объединять накладные по плательщику'
      TabOrder = 16
    end
    object cbUseReturn: TCheckBox
      Left = 256
      Top = 338
      Width = 81
      Height = 17
      Caption = 'Зачет тары'
      TabOrder = 17
    end
    object gsiblcTransaction: TgsIBLookupComboBox
      Left = 122
      Top = 304
      Width = 442
      Height = 21
      Database = dmDatabase.ibdbGAdmin
      Transaction = IBTransaction
      ListTable = 'GD_LISTTRTYPE'
      ListField = 'NAME'
      KeyField = 'ID'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 20
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 428
    Top = 256
  end
end
