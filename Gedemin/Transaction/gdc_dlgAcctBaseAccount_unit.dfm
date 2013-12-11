inherited gdc_dlgAcctBaseAccount: Tgdc_dlgAcctBaseAccount
  Left = 451
  Top = 116
  BorderIcons = [biSystemMenu]
  BorderWidth = 5
  Caption = 'Счет'
  ClientHeight = 465
  ClientWidth = 494
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 1
    Top = 441
    TabOrder = 1
  end
  inherited btnNew: TButton
    Left = 80
    Top = 441
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 158
    Top = 441
  end
  inherited btnOK: TButton
    Left = 344
    Top = 441
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 424
    Top = 441
    TabOrder = 4
  end
  inherited pgcMain: TPageControl
    Left = 1
    Top = 1
    Width = 489
    Height = 432
    inherited tbsMain: TTabSheet
      inherited dbtxtID: TDBText
        Left = 121
      end
      object lblAlias: TLabel
        Left = 8
        Top = 33
        Width = 67
        Height = 13
        Caption = 'Номер счета:'
      end
      object lblName: TLabel
        Left = 8
        Top = 58
        Width = 109
        Height = 13
        Caption = 'Наименование счета:'
      end
      object lbRelation: TLabel
        Left = 8
        Top = 177
        Width = 193
        Height = 13
        Caption = 'Аналитика для развернутого сальдо:'
      end
      object pAccountInfo: TPanel
        Left = 7
        Top = 78
        Width = 466
        Height = 91
        BevelOuter = bvNone
        TabOrder = 2
        object Label2: TLabel
          Left = 1
          Top = 74
          Width = 40
          Height = 13
          Caption = 'Раздел:'
        end
        object GroupBox1: TGroupBox
          Left = 0
          Top = 0
          Width = 207
          Height = 66
          Caption = ' Параметры счета '
          TabOrder = 0
          object dbcbCurrAccount: TDBCheckBox
            Left = 9
            Top = 16
            Width = 97
            Height = 17
            Caption = 'Валютный счет'
            DataField = 'MULTYCURR'
            DataSource = dsgdcBase
            TabOrder = 0
            ValueChecked = '1'
            ValueUnchecked = '0'
          end
          object dbcbOffBalance: TDBCheckBox
            Left = 9
            Top = 39
            Width = 144
            Height = 17
            Caption = 'Забалансовый счет'
            DataField = 'OFFBALANCE'
            DataSource = dsgdcBase
            TabOrder = 1
            ValueChecked = '1'
            ValueUnchecked = '0'
          end
        end
        object dbrgTypeAccount: TDBRadioGroup
          Left = 212
          Top = 0
          Width = 248
          Height = 66
          Caption = ' Тип счета '
          DataField = 'ACTIVITY'
          DataSource = dsgdcBase
          Items.Strings = (
            'Активный'
            'Пассивный'
            'Активно-пассивный')
          TabOrder = 1
          Values.Strings = (
            'A'
            'P'
            'B')
        end
        object gsiblcGroupAccount: TgsIBLookupComboBox
          Left = 115
          Top = 70
          Width = 347
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'PARENT'
          ListTable = 'AC_ACCOUNT'
          ListField = 'ALIAS'
          KeyField = 'ID'
          gdClassName = 'TgdcAcctFolder'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
      end
      object dbedAlias: TDBEdit
        Left = 120
        Top = 29
        Width = 122
        Height = 21
        DataField = 'ALIAS'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbedName: TDBEdit
        Left = 120
        Top = 54
        Width = 349
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object dbcbDisabled: TDBCheckBox
        Left = 8
        Top = 382
        Width = 138
        Height = 17
        Caption = 'Запись отключена'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 3
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object gsibRelationFields: TgsIBLookupComboBox
        Left = 207
        Top = 173
        Width = 262
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'analyticalfield'
        ListTable = 'AT_RELATION_FIELDS'
        ListField = 'LNAME'
        KeyField = 'ID'
        Condition = 'RELATIONNAME = '#39'AC_ACCOUNT'#39' AND FIELDNAME LIKE '#39'USR$%'#39
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
      object bbAnalyze: TBitBtn
        Left = 6
        Top = 199
        Width = 227
        Height = 25
        Action = actAnalyze
        Caption = 'Аналитика'
        TabOrder = 5
      end
      object sbAnalyze: TScrollBox
        Left = 7
        Top = 224
        Width = 225
        Height = 152
        TabOrder = 6
      end
      object sbValues: TScrollBox
        Left = 239
        Top = 224
        Width = 225
        Height = 152
        TabOrder = 7
      end
      object bbValues: TBitBtn
        Left = 239
        Top = 200
        Width = 227
        Height = 25
        Action = actValues
        Caption = 'Ед.изм.'
        TabOrder = 8
      end
    end
    object TabSheet1: TTabSheet [1]
      Caption = 'Описание'
      ImageIndex = 2
      object DBMemo1: TDBMemo
        Left = 0
        Top = 0
        Width = 481
        Height = 404
        Align = alClient
        DataField = 'description'
        DataSource = dsgdcBase
        TabOrder = 0
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 481
        Height = 404
      end
    end
  end
  inherited alBase: TActionList
    Left = 375
    Top = 10
    object actSelectedAnalytics: TAction
      Caption = 'Только отмеченные'
    end
    object actSelectedValues: TAction
      Caption = 'Только отмеченные'
    end
    object actAnalyze: TAction
      Caption = 'Аналитика'
      OnExecute = actAnalyzeExecute
    end
    object actValues: TAction
      Caption = 'Ед.изм.'
      OnExecute = actValuesExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 345
    Top = 10
  end
end
