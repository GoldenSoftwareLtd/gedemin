inherited gdc_dlgAcctBaseAccount: Tgdc_dlgAcctBaseAccount
  Left = 621
  Top = 482
  BorderIcons = [biSystemMenu]
  BorderWidth = 5
  Caption = 'Счет'
  ClientHeight = 371
  ClientWidth = 443
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 1
    Top = 347
    TabOrder = 1
  end
  inherited btnNew: TButton
    Left = 80
    Top = 347
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 158
    Top = 347
  end
  inherited btnOK: TButton
    Left = 293
    Top = 347
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 373
    Top = 347
    TabOrder = 4
  end
  inherited pgcMain: TPageControl
    Left = 1
    Top = 1
    Width = 440
    Height = 339
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
      object Label3: TLabel
        Left = 8
        Top = 170
        Width = 53
        Height = 13
        Caption = 'Описание:'
      end
      object pAccountInfo: TPanel
        Left = 7
        Top = 78
        Width = 419
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
          Width = 207
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
          Width = 304
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
        Width = 306
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object DBMemo1: TDBMemo
        Left = 7
        Top = 186
        Width = 418
        Height = 121
        DataField = 'description'
        DataSource = dsgdcBase
        TabOrder = 3
      end
    end
    object TabSheet1: TTabSheet [1]
      Caption = 'Аналитика'
      ImageIndex = 2
      object lblValues: TLabel
        Left = 6
        Top = 165
        Width = 121
        Height = 13
        Caption = 'Ед.измерения по счету:'
      end
      object pnlAnalytics: TPanel
        Left = 5
        Top = 5
        Width = 419
        Height = 157
        BevelOuter = bvNone
        TabOrder = 0
        object pnlMainAnalytic: TPanel
          Left = 0
          Top = 0
          Width = 419
          Height = 23
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object lbRelation: TLabel
            Left = 0
            Top = 6
            Width = 103
            Height = 13
            Caption = 'Главная аналитика:'
          end
          object gsibRelationFields: TgsIBLookupComboBox
            Left = 135
            Top = 2
            Width = 284
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
            ItemHeight = 0
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
          end
        end
        object Panel1: TPanel
          Left = 0
          Top = 23
          Width = 419
          Height = 134
          Align = alClient
          BevelOuter = bvNone
          Caption = 'Panel1'
          TabOrder = 1
          object Label1: TLabel
            Left = 0
            Top = 4
            Width = 59
            Height = 13
            Caption = 'Аналитики:'
          end
          object atContainer: TatContainer
            Left = 0
            Top = 19
            Width = 419
            Height = 115
            DataSource = dsgdcBase
            Align = alBottom
            Anchors = [akLeft, akTop, akRight, akBottom]
            TabOrder = 0
            OnAdjustControl = atContainerAdjustControl
          end
        end
      end
      object sbValues: TScrollBox
        Left = 5
        Top = 182
        Width = 419
        Height = 122
        TabOrder = 1
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 432
        Height = 311
        OnAdjustControl = atcMainAdjustControl
      end
    end
  end
  inherited alBase: TActionList
    Left = 375
    Top = 10
  end
  inherited dsgdcBase: TDataSource
    Left = 345
    Top = 10
  end
end
