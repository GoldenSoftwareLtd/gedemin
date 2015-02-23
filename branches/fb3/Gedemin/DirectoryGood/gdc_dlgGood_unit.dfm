inherited gdc_dlgGood: Tgdc_dlgGood
  Left = 420
  Top = 245
  HelpContext = 51
  Caption = 'ТМЦ:'
  ClientHeight = 370
  ClientWidth = 516
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 343
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 85
    Top = 343
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 343
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnOK: TButton
    Left = 355
    Top = 343
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Left = 435
    Top = 343
    Anchors = [akRight, akBottom]
  end
  inherited pgcMain: TPageControl
    Left = 0
    Top = 0
    Width = 516
    Height = 335
    Align = alTop
    ParentShowHint = False
    inherited tbsMain: TTabSheet
      Hint = 'Основные св-ва товара'
      Caption = 'Свойства'
      ParentShowHint = False
      ShowHint = True
      inherited labelID: TLabel
        Top = 10
      end
      inherited dbtxtID: TDBText
        Left = 146
        Top = 10
      end
      object Label1: TLabel
        Left = 8
        Top = 34
        Width = 77
        Height = 13
        Caption = 'Наименование:'
        FocusControl = dbeName
      end
      object Label2: TLabel
        Left = 8
        Top = 130
        Width = 53
        Height = 13
        Caption = 'Описание:'
        FocusControl = dbmDescription
      end
      object Label3: TLabel
        Left = 8
        Top = 183
        Width = 61
        Height = 13
        Caption = 'Штрих-код:'
        FocusControl = dbeBarCode
      end
      object Label4: TLabel
        Left = 8
        Top = 208
        Width = 59
        Height = 13
        Caption = 'Шифр ТМЦ:'
        FocusControl = dbeAlias
      end
      object Label7: TLabel
        Left = 8
        Top = 233
        Width = 31
        Height = 13
        Caption = 'ТНВД:'
        FocusControl = dblcbTNVD
      end
      object Label6: TLabel
        Left = 8
        Top = 58
        Width = 89
        Height = 13
        Caption = 'Базовая ед. изм.:'
        FocusControl = dblcbValue
      end
      object Label8: TLabel
        Left = 8
        Top = 106
        Width = 122
        Height = 13
        Caption = 'Краткое наименование:'
        FocusControl = dbedShortName
      end
      object Label9: TLabel
        Left = 8
        Top = 82
        Width = 40
        Height = 13
        Caption = 'Группа:'
        FocusControl = gdiblGoodGroup
      end
      object Label5: TLabel
        Left = 8
        Top = 261
        Width = 98
        Height = 13
        Caption = 'Учетная политика:'
      end
      object dbeName: TDBEdit
        Left = 145
        Top = 33
        Width = 342
        Height = 21
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbmDescription: TDBMemo
        Left = 145
        Top = 130
        Width = 343
        Height = 46
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object dbeBarCode: TDBEdit
        Left = 145
        Top = 179
        Width = 343
        Height = 21
        DataField = 'BARCODE'
        DataSource = dsgdcBase
        TabOrder = 5
      end
      object dbeAlias: TDBEdit
        Left = 145
        Top = 204
        Width = 343
        Height = 21
        DataField = 'ALIAS'
        DataSource = dsgdcBase
        TabOrder = 6
      end
      object dblcbTNVD: TgsIBLookupComboBox
        Left = 145
        Top = 229
        Width = 343
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'TNVDKEY'
        ListTable = 'gd_tnvd'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcTNVD'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
      end
      object dbcbSet: TDBCheckBox
        Left = 8
        Top = 286
        Width = 138
        Height = 17
        Caption = 'Является комплектом'
        DataField = 'ISASSEMBLY'
        DataSource = dsgdcBase
        TabOrder = 9
        ValueChecked = '1'
        ValueUnchecked = '0'
        OnClick = dbcbSetClick
      end
      object dblcbValue: TgsIBLookupComboBox
        Left = 145
        Top = 57
        Width = 343
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'VALUEKEY'
        ListTable = 'gd_value'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcValue'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object dbcbDisabled: TDBCheckBox
        Left = 145
        Top = 286
        Width = 97
        Height = 17
        Caption = 'Отключен'
        DataField = 'DISABLED'
        DataSource = dsgdcBase
        TabOrder = 10
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbedShortName: TDBEdit
        Left = 145
        Top = 105
        Width = 343
        Height = 21
        DataField = 'ShortName'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object gdiblGoodGroup: TgsIBLookupComboBox
        Left = 145
        Top = 81
        Width = 343
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'GROUPKEY'
        ListTable = 'gd_GoodGroup'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcGoodGroup'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
      end
      object dbrgDiscipline: TDBRadioGroup
        Left = 145
        Top = 250
        Width = 344
        Height = 31
        Columns = 2
        DataField = 'discipline'
        DataSource = dsgdcBase
        Items.Strings = (
          'FIFO'
          'LIFO')
        TabOrder = 8
        Values.Strings = (
          'F'
          'L')
      end
      object btnBarIndex: TButton
        Left = 413
        Top = 284
        Width = 75
        Height = 21
        Action = actBarIndex
        TabOrder = 11
      end
    end
    object tshBarCode: TTabSheet [1]
      Caption = 'Штрих коды'
      ImageIndex = 2
      OnEnter = tshBarCodeEnter
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 508
        Height = 307
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object btnNewBarCode: TButton
          Left = 430
          Top = 5
          Width = 75
          Height = 21
          Action = actNewBarCode
          Anchors = [akTop, akRight]
          TabOrder = 0
        end
        object btnEditBarCode: TButton
          Left = 430
          Top = 31
          Width = 75
          Height = 21
          Action = actEditBarCode
          Anchors = [akTop, akRight]
          TabOrder = 1
        end
        object btnDelBarCode: TButton
          Left = 430
          Top = 58
          Width = 75
          Height = 21
          Action = actDelBarcode
          Anchors = [akTop, akRight]
          TabOrder = 2
        end
        object gdibgrBarCode: TgsIBGrid
          Left = 0
          Top = 0
          Width = 424
          Height = 307
          HelpContext = 3
          Align = alLeft
          DataSource = dsBarCode
          Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
          TabOrder = 3
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          TitlesExpanding = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
        end
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 508
        Height = 307
      end
    end
  end
  inherited alBase: TActionList
    Left = 313
    Top = 26
    inherited actNextRecord: TAction [4]
    end
    inherited actCancel: TAction [5]
    end
    object actNewBarCode: TAction
      Caption = 'Добавить ...'
      OnExecute = actNewBarCodeExecute
    end
    object actEditBarCode: TAction
      Caption = 'Изменить ...'
      OnExecute = actEditBarCodeExecute
    end
    object actDelBarcode: TAction
      Caption = 'Удалить'
      OnExecute = actDelBarcodeExecute
    end
    object actBarIndex: TAction
      Caption = 'ШК Индекс'
      OnExecute = actBarIndexExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 275
    Top = 26
  end
  inherited pm_dlgG: TPopupMenu
    Left = 352
    Top = 24
  end
  inherited ibtrCommon: TIBTransaction
    Left = 392
    Top = 24
  end
  object gdcGoodBarCode: TgdcGoodBarCode
    MasterSource = dsgdcBase
    MasterField = 'ID'
    DetailField = 'GOODKEY'
    SubSet = 'ByGood'
    Left = 457
    Top = 26
  end
  object dsBarCode: TDataSource
    DataSet = gdcGoodBarCode
    Left = 427
    Top = 26
  end
end
