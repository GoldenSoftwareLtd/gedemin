inherited gdc_dlgCustomPayment: Tgdc_dlgCustomPayment
  Left = 167
  Top = 41
  Caption = 'Платежное поручение'
  ClientHeight = 486
  ClientWidth = 544
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 455
    Anchors = [akLeft, akBottom]
  end
  inherited btnNew: TButton
    Left = 85
    Top = 455
    Anchors = [akLeft, akBottom]
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 455
    Anchors = [akLeft, akBottom]
  end
  inherited btnOK: TButton
    Left = 380
    Top = 455
    Anchors = [akLeft, akBottom]
  end
  inherited btnCancel: TButton
    Left = 460
    Top = 455
    Anchors = [akLeft, akBottom]
  end
  object PageControl1: TPageControl [5]
    Left = 0
    Top = 5
    Width = 544
    Height = 442
    ActivePage = tsMain
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
    object tsMain: TTabSheet
      Caption = 'Реквизиты'
      object pnlMain: TPanel
        Left = 0
        Top = 0
        Width = 536
        Height = 414
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Bevel1: TBevel
          Left = 5
          Top = 35
          Width = 509
          Height = 83
          Shape = bsFrame
        end
        object Bevel3: TBevel
          Left = 5
          Top = 125
          Width = 510
          Height = 59
          Shape = bsFrame
        end
        object Label17: TLabel
          Left = 8
          Top = 192
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
          Top = 94
          Width = 35
          Height = 13
          Caption = 'Сумма:'
          Transparent = True
        end
        object Label10: TLabel
          Left = 11
          Top = 133
          Width = 48
          Height = 13
          Caption = 'Вид обр.:'
          Transparent = True
        end
        object Label16: TLabel
          Left = 359
          Top = 133
          Width = 65
          Height = 13
          Caption = 'Очер. плат.:'
          Transparent = True
        end
        object Label6: TLabel
          Left = 11
          Top = 158
          Width = 63
          Height = 13
          Caption = 'Назн. плат.:'
          Transparent = True
        end
        object Label7: TLabel
          Left = 191
          Top = 158
          Width = 76
          Height = 13
          Caption = 'Срок платежа:'
          Transparent = True
        end
        object Label3: TLabel
          Left = 362
          Top = 44
          Width = 29
          Height = 13
          Caption = 'Счет:'
          Transparent = True
        end
        object Label11: TLabel
          Left = 191
          Top = 133
          Width = 54
          Height = 13
          Caption = 'Вид опер.:'
          Transparent = True
        end
        object Label18: TLabel
          Left = 16
          Top = 44
          Width = 65
          Height = 13
          Caption = 'Получатель:'
        end
        object Label23: TLabel
          Left = 211
          Top = 94
          Width = 28
          Height = 13
          Caption = 'Банк:'
          Transparent = True
        end
        object Label5: TLabel
          Left = 16
          Top = 69
          Width = 33
          Height = 13
          Caption = 'Текст:'
        end
        object Label20: TLabel
          Left = 168
          Top = 388
          Width = 115
          Height = 13
          Caption = 'Расходы по переводу:'
        end
        object Label8: TLabel
          Left = 8
          Top = 360
          Width = 50
          Height = 13
          Caption = 'Операция'
        end
        object dbeCorrAccount: TgsIBLookupComboBox
          Left = 400
          Top = 40
          Width = 107
          Height = 21
          HelpContext = 1
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
          TabOrder = 4
          OnChange = dbeCorrAccountChange
        end
        object dbePaymentDestination: TDBMemo
          Left = 90
          Top = 190
          Width = 423
          Height = 86
          DataField = 'DESTINATION'
          DataSource = dsgdcBase
          TabOrder = 13
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
        object dbeOper: TDBEdit
          Left = 85
          Top = 129
          Width = 76
          Height = 21
          DataField = 'PROC'
          DataSource = dsgdcBase
          TabOrder = 8
        end
        object dbeQueue: TDBEdit
          Left = 425
          Top = 129
          Width = 76
          Height = 21
          DataField = 'QUEUE'
          DataSource = dsgdcBase
          TabOrder = 10
        end
        object dbeDest: TgsIBLookupComboBox
          Left = 85
          Top = 154
          Width = 76
          Height = 21
          HelpContext = 1
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
          TabOrder = 11
        end
        object dbeTerm: TxDateDBEdit
          Left = 275
          Top = 154
          Width = 76
          Height = 21
          DataField = 'TERM'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 12
        end
        object dbeOperKind: TDBEdit
          Left = 275
          Top = 129
          Width = 76
          Height = 21
          DataField = 'OPER'
          DataSource = dsgdcBase
          TabOrder = 9
        end
        object dbeCorrCompany: TgsIBLookupComboBox
          Left = 90
          Top = 40
          Width = 263
          Height = 21
          HelpContext = 1
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
          TabOrder = 3
          OnChange = dbeCorrCompanyChange
        end
        object edBank: TEdit
          Left = 280
          Top = 90
          Width = 224
          Height = 21
          Color = clBtnFace
          Ctl3D = True
          ParentCtl3D = False
          ReadOnly = True
          TabOrder = 7
        end
        object dbeAdditional: TDBEdit
          Left = 90
          Top = 65
          Width = 418
          Height = 21
          DataField = 'CORRCOMPTEXT'
          DataSource = dsgdcBase
          TabOrder = 5
        end
        object dbeAmount: TxDBCalculatorEdit
          Left = 90
          Top = 90
          Width = 112
          Height = 21
          TabOrder = 6
          DecDigits = 2
          DataField = 'AMOUNT'
          DataSource = dsgdcBase
        end
        object gsibluOwnAccount: TgsIBLookupComboBox
          Left = 400
          Top = 5
          Width = 107
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'ACCOUNTKEY'
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object cmbExpense: TComboBox
          Left = 288
          Top = 384
          Width = 225
          Height = 21
          ItemHeight = 13
          TabOrder = 14
          Items.Strings = (
            'За счет плательщика'
            'За счет бенефициара'
            'Отправление за счет плательщика, остальное - за счет бенефициара')
        end
        object gsTransactionComboBox: TgsTransactionComboBox
          Left = 90
          Top = 356
          Width = 423
          Height = 21
          Hint = 
            'Используйте клавиши: '#13#10'     F4 - просмотр и редактирование прово' +
            'док.'
          Style = csDropDownList
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 15
          DataSource = dsgdcBase
          DataField = 'TRTYPEKEY'
        end
      end
    end
    object tsAttribute: TTabSheet
      Caption = 'Атрибуты'
      ImageIndex = 1
      object atContainer: TatContainer
        Left = 0
        Top = 0
        Width = 536
        Height = 414
        DataSource = dsgdcBase
        Align = alClient
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Left = 481
    Top = 327
  end
  inherited dsgdcBase: TDataSource
    Left = 451
    Top = 327
  end
end
