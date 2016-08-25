object dlgSetCondValue: TdlgSetCondValue
  Left = 241
  Top = 101
  Width = 602
  Height = 203
  Caption = 'Установка значения'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object nValue: TNotebook
    Left = 8
    Top = 11
    Width = 489
    Height = 150
    PageIndex = 2
    TabOrder = 0
    object TPage
      Left = 0
      Top = 0
      Caption = 'SimpleDecimalValue'
      object Label2: TLabel
        Left = 8
        Top = 13
        Width = 44
        Height = 13
        Caption = 'Условие'
      end
      object medValue: TMaskEdit
        Left = 216
        Top = 9
        Width = 260
        Height = 21
        TabOrder = 1
      end
      object cbCond: TComboBox
        Left = 58
        Top = 9
        Width = 152
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          '= Равно'
          '> Больше'
          '< Меньше'
          '>= Больше или равно'
          '<= Меньше или равно')
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'SimpleCharValue'
      object Label3: TLabel
        Left = 8
        Top = 13
        Width = 44
        Height = 13
        Caption = 'Условие'
      end
      object cbCharCond: TComboBox
        Left = 58
        Top = 9
        Width = 152
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          'Равно'
          'Начинается'
          'Содержит')
      end
      object medChar: TMaskEdit
        Left = 216
        Top = 9
        Width = 260
        Height = 21
        TabOrder = 1
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'ReferencyValue'
      object gsibgrReferency: TgsIBGrid
        Left = 0
        Top = 0
        Width = 489
        Height = 150
        Align = alClient
        DataSource = dsReferency
        PopupMenu = pMenu
        TabOrder = 0
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = True
        MinColWidth = 40
      end
    end
  end
  object bOk: TButton
    Left = 508
    Top = 6
    Width = 84
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 508
    Top = 36
    Width = 84
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object bSelectAll: TButton
    Left = 508
    Top = 77
    Width = 84
    Height = 25
    Action = actSelectAll
    TabOrder = 3
    Visible = False
  end
  object bDeleteSel: TButton
    Left = 508
    Top = 106
    Width = 84
    Height = 25
    Action = actDeleteSel
    TabOrder = 4
    Visible = False
  end
  object bInvert: TButton
    Left = 508
    Top = 134
    Width = 84
    Height = 25
    Action = actInvert
    TabOrder = 5
    Visible = False
  end
  object ibdsReferency: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    Left = 272
    Top = 56
  end
  object dsReferency: TDataSource
    DataSet = ibdsReferency
    Left = 304
    Top = 56
  end
  object pMenu: TPopupMenu
    Left = 232
    Top = 104
    object N1: TMenuItem
      Action = actSelectAll
    end
    object N2: TMenuItem
      Action = actDeleteSel
    end
    object N3: TMenuItem
      Action = actInvert
    end
  end
  object ActionList1: TActionList
    Left = 272
    Top = 88
    object actSelectAll: TAction
      Caption = 'Отметить все'
      OnExecute = actSelectAllExecute
    end
    object actDeleteSel: TAction
      Caption = 'Снять отметку'
      OnExecute = actDeleteSelExecute
    end
    object actInvert: TAction
      Caption = 'Инвертировать'
      OnExecute = actInvertExecute
    end
  end
  object gsQueryFilter: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    IBDataSet = ibdsReferency
    Left = 304
    Top = 96
  end
end
