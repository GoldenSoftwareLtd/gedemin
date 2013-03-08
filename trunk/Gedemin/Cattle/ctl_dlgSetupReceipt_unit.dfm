inherited ctl_dlgSetupReceipt: Tctl_dlgSetupReceipt
  Left = 393
  Top = 306
  Caption = 'Настройка расчета приемной квитанции'
  ClientHeight = 326
  ClientWidth = 470
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 271
    Width = 53
    Height = 13
    Caption = 'Операция '
  end
  inherited btnOk: TButton
    Left = 228
    Top = 295
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Left = 308
    Top = 295
    Anchors = [akRight, akBottom]
  end
  inherited btnHelp: TButton
    Left = 388
    Top = 295
    Anchors = [akRight, akBottom]
  end
  object pnlMain: TPanel [4]
    Left = 0
    Top = 0
    Width = 470
    Height = 264
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object cbMain: TControlBar
      Left = 6
      Top = 6
      Width = 457
      Height = 26
      Anchors = [akLeft, akTop, akRight]
      AutoDock = False
      AutoSize = True
      BevelEdges = [beBottom]
      BevelInner = bvNone
      BevelOuter = bvNone
      BevelKind = bkNone
      Color = clBtnFace
      DockSite = False
      ParentColor = False
      TabOrder = 0
      object tbMain: TToolBar
        Left = 11
        Top = 2
        Width = 444
        Height = 22
        Align = alClient
        AutoSize = True
        EdgeBorders = []
        Flat = True
        Images = dmImages.ilToolBarSmall
        TabOrder = 0
        object tbtNew: TToolButton
          Left = 0
          Top = 0
          ImageIndex = 0
          ParentShowHint = False
          ShowHint = True
        end
        object tbtEdit: TToolButton
          Left = 23
          Top = 0
          ImageIndex = 1
          ParentShowHint = False
          ShowHint = True
        end
        object tbtDelete: TToolButton
          Left = 46
          Top = 0
          ImageIndex = 2
          ParentShowHint = False
          ShowHint = True
        end
        object tbtDuplicate: TToolButton
          Left = 69
          Top = 0
          ImageIndex = 3
          ParentShowHint = False
          ShowHint = True
        end
        object ToolButton1: TToolButton
          Left = 92
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 4
          Style = tbsSeparator
        end
        object cbVariables: TComboBox
          Left = 100
          Top = 0
          Width = 151
          Height = 21
          Style = csDropDownList
          DropDownCount = 12
          ItemHeight = 13
          TabOrder = 0
          OnClick = cbVariablesClick
          Items.Strings = (
            'Переменные:'
            '----------------------------------------------------'
            'Сумма_Общая'
            'Масса_Убойная'
            'Масса_Живая'
            'Масса_Живая_Скидка'
            'Количество_Голов'
            'Количество_Голов_Порочных'
            'Сумма_Транспорт'
            'Процент_Скидка_СХ'
            'Процент_НДС'
            'Процент_НДС_Трансп'
            'Орг_Накл_Расх_Коэфф')
        end
      end
    end
    object sgCalculate: TStringGrid
      Left = 7
      Top = 37
      Width = 456
      Height = 224
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 25
      DefaultRowHeight = 20
      RowCount = 10
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goEditing, goAlwaysShowEditor]
      ParentCtl3D = False
      TabOrder = 1
      OnSelectCell = sgCalculateSelectCell
      ColWidths = (
        25
        93
        181
        151)
      RowHeights = (
        20
        20
        20
        20
        20
        20
        20
        20
        20
        20)
    end
  end
  object iblcTransaction: TgsIBLookupComboBox [5]
    Left = 72
    Top = 267
    Width = 393
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrCalculation
    ListTable = 'GD_LISTTRTYPE'
    ListField = 'NAME'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  inherited ActionList: TActionList
    Left = 40
    Top = 110
  end
  object dsCalculation: TDataSource
    DataSet = ibdsCalculation
    Left = 70
    Top = 110
  end
  object ibdsCalculation: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT'
      '  C.ALIAS, C.NAME, C.DESCRIPTION, C.FORMULA'
      ''
      'FROM'
      '  CTL_REFERENCE C'
      ''
      'WHERE'
      '  C.PARENT = :ID')
    Left = 100
    Top = 110
  end
  object ibtrCalculation: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 130
    Top = 110
  end
  object ibsqlCalculate: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    Transaction = ibtrCalculation
    Left = 100
    Top = 140
  end
  object Calculator: TxFoCal
    Expression = '0'
    Left = 130
    Top = 140
    _variables_ = (
      'PI'
      3.14159265358979
      'E'
      2.71828182845905)
  end
end
