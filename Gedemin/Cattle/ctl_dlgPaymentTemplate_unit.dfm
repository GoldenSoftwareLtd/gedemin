object ctl_dlgPaymentTemplate: Tctl_dlgPaymentTemplate
  Left = 486
  Top = 111
  Width = 425
  Height = 449
  BorderWidth = 4
  Caption = 'Платежное поручение'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 379
    Width = 409
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 244
      Top = 7
      Width = 75
      Height = 25
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 334
      Top = 7
      Width = 75
      Height = 25
      Action = actCancel
      Anchors = [akTop, akRight]
      Cancel = True
      ModalResult = 2
      TabOrder = 1
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 409
    Height = 379
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'Реквизиты'
      object pnlMain: TPanel
        Left = 0
        Top = 0
        Width = 401
        Height = 351
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Bevel1: TBevel
          Left = 7
          Top = 9
          Width = 386
          Height = 95
          Shape = bsFrame
        end
        object Bevel3: TBevel
          Left = 7
          Top = 114
          Width = 386
          Height = 93
          Shape = bsFrame
        end
        object Label17: TLabel
          Left = 10
          Top = 280
          Width = 69
          Height = 29
          AutoSize = False
          Caption = 'Назначение платежа:'
          Transparent = True
          WordWrap = True
        end
        object Label19: TLabel
          Left = 9
          Top = 211
          Width = 72
          Height = 29
          AutoSize = False
          Caption = 'Дата товара, услуги:'
          Transparent = True
          WordWrap = True
        end
        object Label4: TLabel
          Left = 16
          Top = 40
          Width = 67
          Height = 26
          AutoSize = False
          Caption = 'Оплата со счета:'
          Transparent = True
          WordWrap = True
        end
        object Label10: TLabel
          Left = 18
          Top = 127
          Width = 46
          Height = 13
          Caption = 'Вид обр.:'
          Transparent = True
        end
        object Label16: TLabel
          Left = 207
          Top = 152
          Width = 60
          Height = 13
          Caption = 'Очер. плат.:'
          Transparent = True
        end
        object Label6: TLabel
          Left = 18
          Top = 154
          Width = 61
          Height = 13
          Caption = 'Назн. плат.:'
          Transparent = True
        end
        object Label7: TLabel
          Left = 18
          Top = 173
          Width = 56
          Height = 29
          AutoSize = False
          Caption = 'Срок платежа:'
          Transparent = True
          WordWrap = True
        end
        object Label11: TLabel
          Left = 207
          Top = 127
          Width = 52
          Height = 13
          Caption = 'Вид опер.:'
          Transparent = True
        end
        object Label14: TLabel
          Left = 9
          Top = 243
          Width = 61
          Height = 26
          AutoSize = False
          Caption = 'Уточнение платежа:'
          Transparent = True
          WordWrap = True
        end
        object Label2: TLabel
          Left = 16
          Top = 21
          Width = 29
          Height = 13
          Caption = 'Дата:'
          Transparent = True
        end
        object Label3: TLabel
          Left = 17
          Top = 70
          Width = 66
          Height = 26
          AutoSize = False
          Caption = 'Счет получателя:'
          Transparent = True
          WordWrap = True
        end
        object Label1: TLabel
          Left = 10
          Top = 328
          Width = 50
          Height = 13
          Caption = 'Операция'
        end
        object dbeOper: TEdit
          Left = 92
          Top = 123
          Width = 109
          Height = 21
          TabOrder = 3
        end
        object dbeQueue: TEdit
          Left = 270
          Top = 149
          Width = 111
          Height = 21
          TabOrder = 6
        end
        object dbeDest: TgsIBLookupComboBox
          Left = 92
          Top = 150
          Width = 109
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPaymentTemplate
          DataField = 'DESTCODEKEY'
          ListTable = 'BN_DESTCODE'
          ListField = 'CODE'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 5
        end
        object dbeOperKind: TEdit
          Left = 270
          Top = 123
          Width = 111
          Height = 21
          TabOrder = 4
        end
        object gsibluOwnAccount: TgsIBLookupComboBox
          Left = 92
          Top = 45
          Width = 291
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPaymentTemplate
          ListTable = 'GD_COMPANYACCOUNT'
          ListField = 'ACCOUNT'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object cbDate: TComboBox
          Left = 92
          Top = 18
          Width = 291
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Текущая дата'
            'Дата из квитании'
            'Дата из накладной')
        end
        object cbReceiverAccount: TComboBox
          Left = 92
          Top = 73
          Width = 291
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
          Items.Strings = (
            'Главный счет')
        end
        object cbGoodDate: TComboBox
          Left = 92
          Top = 217
          Width = 301
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 8
          Items.Strings = (
            'Текущая дата'
            'Дата из квитании'
            'Дата из накладной')
        end
        object cbSpecification: TComboBox
          Left = 92
          Top = 243
          Width = 301
          Height = 21
          ItemHeight = 13
          TabOrder = 9
          Items.Strings = (
            'Срочный платеж'
            'В счет неотложных нужд'
            'В счет бесспорного удержания'
            'В счет прожиточного минимума'
            '')
        end
        object edPaymentDestination: TMemo
          Left = 92
          Top = 269
          Width = 275
          Height = 51
          Lines.Strings = (
            'edPaymentDestination')
          TabOrder = 10
        end
        object cbTerm: TComboBox
          Left = 92
          Top = 177
          Width = 289
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 7
          Items.Strings = (
            'Текущая дата'
            'Дата из квитании'
            'Дата из накладной')
        end
        object btnVariables: TButton
          Left = 371
          Top = 269
          Width = 22
          Height = 21
          Caption = '...'
          TabOrder = 11
          OnClick = btnVariablesClick
        end
        object iblcTransaction: TgsIBLookupComboBox
          Left = 93
          Top = 326
          Width = 299
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPaymentTemplate
          ListTable = 'GD_LISTTRTYPE'
          ListField = 'NAME'
          KeyField = 'ID'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 12
        end
      end
    end
  end
  object ibtrPaymentTemplate: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 310
  end
  object ibsqlAccount: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '  C.COMPANYACCOUNTKEY'
      ''
      'FROM '
      '  GD_COMPANY C'
      ''
      'WHERE'
      '  C.CONTACTKEY = :COMPANYKEY')
    Transaction = ibtrPaymentTemplate
    Left = 280
  end
  object ActionList1: TActionList
    Left = 250
    object actOk: TAction
      Caption = 'Готово'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отменить'
      OnExecute = actCancelExecute
    end
  end
end
