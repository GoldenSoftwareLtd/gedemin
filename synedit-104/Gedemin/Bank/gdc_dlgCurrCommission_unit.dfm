inherited gdc_dlgCurrCommission: Tgdc_dlgCurrCommission
  Left = 282
  Top = 171
  Caption = 'Валютное платежное поручение'
  ClientHeight = 385
  ClientWidth = 536
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 357
  end
  inherited btnNew: TButton
    Left = 85
    Top = 357
  end
  inherited btnOK: TButton
    Left = 375
    Top = 357
  end
  inherited btnCancel: TButton
    Left = 455
    Top = 357
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 357
  end
  object PageControl1: TPageControl [5]
    Left = 0
    Top = 3
    Width = 534
    Height = 350
    ActivePage = tsMain
    TabOrder = 5
    object tsMain: TTabSheet
      Caption = 'Реквизиты'
      object pnlMain: TPanel
        Left = 0
        Top = 0
        Width = 526
        Height = 322
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Bevel1: TBevel
          Left = 5
          Top = 59
          Width = 509
          Height = 107
          Shape = bsFrame
        end
        object Label17: TLabel
          Left = 7
          Top = 218
          Width = 69
          Height = 29
          AutoSize = False
          Caption = 'Назначение платежа:'
          Transparent = True
          WordWrap = True
        end
        object Label1: TLabel
          Left = 16
          Top = 9
          Width = 35
          Height = 13
          Caption = 'Номер:'
          Transparent = True
        end
        object Label2: TLabel
          Left = 174
          Top = 9
          Width = 30
          Height = 13
          Caption = 'Дата:'
          Transparent = True
        end
        object Label4: TLabel
          Left = 301
          Top = 9
          Width = 88
          Height = 13
          Caption = 'Оплата со счета:'
          Transparent = True
        end
        object Label12: TLabel
          Left = 16
          Top = 119
          Width = 35
          Height = 13
          Caption = 'Сумма:'
          Transparent = True
        end
        object Label16: TLabel
          Left = 364
          Top = 174
          Width = 65
          Height = 13
          Caption = 'Очер. плат.:'
          Transparent = True
        end
        object Label6: TLabel
          Left = 8
          Top = 174
          Width = 63
          Height = 13
          Caption = 'Назн. плат.:'
          Transparent = True
        end
        object Label3: TLabel
          Left = 362
          Top = 68
          Width = 29
          Height = 13
          Caption = 'Счет:'
          Transparent = True
        end
        object Label18: TLabel
          Left = 16
          Top = 68
          Width = 65
          Height = 13
          Caption = 'Получатель:'
        end
        object Label23: TLabel
          Left = 238
          Top = 118
          Width = 28
          Height = 13
          Caption = 'Банк:'
          Transparent = True
        end
        object Label5: TLabel
          Left = 16
          Top = 93
          Width = 33
          Height = 13
          Caption = 'Текст:'
        end
        object Label15: TLabel
          Left = 7
          Top = 294
          Width = 80
          Height = 13
          Caption = 'Вид поручения:'
        end
        object Label20: TLabel
          Left = 167
          Top = 294
          Width = 115
          Height = 13
          Caption = 'Расходы по переводу:'
        end
        object Label21: TLabel
          Left = 16
          Top = 144
          Width = 179
          Height = 13
          Caption = 'Корреспондент банка получателя:'
        end
        object Label7: TLabel
          Left = 302
          Top = 35
          Width = 43
          Height = 13
          Caption = 'Валюта:'
        end
        object dbeCorrAccount: TgsIBLookupComboBox
          Left = 400
          Top = 65
          Width = 108
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'CORRACCOUNTKEY'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          gdClassName = 'TgdcAccount'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
          OnChange = dbeCorrAccountChange
        end
        object dbePaymentDestination: TDBMemo
          Left = 90
          Top = 195
          Width = 423
          Height = 91
          DataField = 'DESTINATION'
          DataSource = dsgdcBase
          TabOrder = 12
        end
        object dbeNumber: TDBEdit
          Left = 90
          Top = 5
          Width = 71
          Height = 21
          DataField = 'NUMBER'
          DataSource = dsgdcBase
          TabOrder = 0
        end
        object dbeDate: TxDateDBEdit
          Left = 220
          Top = 5
          Width = 74
          Height = 21
          DataField = 'DOCUMENTDATE'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 1
        end
        object dbeQueue: TDBEdit
          Left = 435
          Top = 170
          Width = 76
          Height = 21
          DataField = 'QUEUE'
          DataSource = dsgdcBase
          TabOrder = 11
        end
        object dbeDest: TgsIBLookupComboBox
          Left = 90
          Top = 170
          Width = 76
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'DESTCODEKEY'
          ListTable = 'BN_DESTCODE'
          ListField = 'CODE'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 10
        end
        object dbeCorrCompany: TgsIBLookupComboBox
          Left = 90
          Top = 65
          Width = 263
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'CORRCOMPANYKEY'
          Fields = 'CITY'
          ListTable = 'gd_contact join gd_company on gd_company.contactkey = id'
          ListField = 'name'
          KeyField = 'id'
          gdClassName = 'TgdcBaseContact'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          OnChange = dbeCorrCompanyChange
        end
        object edBank: TEdit
          Left = 280
          Top = 115
          Width = 226
          Height = 21
          Color = clBtnFace
          Ctl3D = True
          ParentCtl3D = False
          ReadOnly = True
          TabOrder = 8
        end
        object dbeAdditional: TDBEdit
          Left = 90
          Top = 90
          Width = 417
          Height = 21
          DataField = 'CORRCOMPTEXT'
          DataSource = dsgdcBase
          TabOrder = 6
        end
        object dbeAmount: TxDBCalculatorEdit
          Left = 90
          Top = 115
          Width = 112
          Height = 21
          TabOrder = 7
          Text = '0'
          DecDigits = 2
          DataField = 'AMOUNT'
          DataSource = dsgdcBase
        end
        object gsibluOwnAccount: TgsIBLookupComboBox
          Left = 390
          Top = 5
          Width = 117
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'ACCOUNTKEY'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          gdClassName = 'TgdcAccount'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnChange = gsibluOwnAccountChange
        end
        object cmbKind: TComboBox
          Left = 90
          Top = 290
          Width = 73
          Height = 21
          ItemHeight = 13
          TabOrder = 13
          Items.Strings = (
            'Обычное'
            'Срочное')
        end
        object cmbExpense: TComboBox
          Left = 285
          Top = 290
          Width = 226
          Height = 21
          ItemHeight = 13
          TabOrder = 14
          Items.Strings = (
            'За счет плательщика'
            'За счет бенефициара'
            'Отправление за счет плательщика, остальное - за счет бенефициара')
        end
        object dbeMidCorrBank: TDBEdit
          Left = 200
          Top = 140
          Width = 307
          Height = 21
          DataField = 'MIDCORRBANKTEXT'
          DataSource = dsgdcBase
          TabOrder = 9
        end
        object edCurrency: TEdit
          Left = 350
          Top = 30
          Width = 156
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 3
        end
      end
    end
    object tsAttribute: TTabSheet
      Caption = 'Атрибуты'
      ImageIndex = 1
      object atContainer: TatContainer
        Left = 0
        Top = 0
        Width = 526
        Height = 322
        DataSource = dsgdcBase
        Align = alClient
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Left = 481
    Top = 263
  end
  inherited dsgdcBase: TDataSource
    Left = 451
    Top = 263
  end
end
