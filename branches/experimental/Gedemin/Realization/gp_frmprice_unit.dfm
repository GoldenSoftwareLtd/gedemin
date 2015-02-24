inherited frmPrice: TfrmPrice
  Left = 81
  Top = 196
  Width = 904
  Height = 480
  Caption = 'Список прайс-листов'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  PixelsPerInch = 96
  TextHeight = 13
  inherited Splitter: TSplitter
    Width = 879
  end
  object Label1: TLabel [1]
    Left = 64
    Top = 424
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  inherited sbMain: TStatusBar
    Top = 437
    Width = 879
  end
  inherited pnlMain: TPanel
    Width = 879
    inherited ibgrMain: TgsIBGrid
      Width = 877
      Aliases = <
        item
          Alias = 'NAME'
          LName = 'Наименование'
        end
        item
          Alias = 'NAME1'
          LName = 'Подразделение'
        end>
    end
    inherited cbMain: TControlBar
      Width = 877
      inherited tbMain: TToolBar
        inherited tbtPrint: TToolButton
          DropdownMenu = pmPrint
        end
        object ToolButton1: TToolButton
          Left = 283
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 14
          Style = tbsSeparator
        end
        object ToolButton2: TToolButton
          Left = 291
          Top = 0
          Action = actOption
        end
      end
    end
  end
  inherited pnlDetails: TPanel
    Width = 879
    Height = 264
    inherited ibgrDetails: TgsIBGrid
      Width = 877
      Height = 236
      Aliases = <
        item
          Alias = 'VALUENAME'
          LName = 'Ед.изм.'
        end>
    end
    inherited cbDetails: TControlBar
      Width = 877
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      OnExecute = actNewExecute
    end
    inherited actEdit: TAction
      OnExecute = actEditExecute
    end
    inherited actDuplicate: TAction
      OnExecute = actDuplicateExecute
    end
    inherited actDetailNew: TAction
      Visible = False
    end
    inherited actDetailEdit: TAction
      Visible = False
    end
    inherited actDetailDelete: TAction
      OnExecute = actDetailDeleteExecute
    end
    inherited actDetailDuplicate: TAction
      Visible = False
    end
    object actOption: TAction
      Category = 'Master'
      Caption = 'actOption'
      Hint = 'Настройки'
      ImageIndex = 7
      OnExecute = actOptionExecute
    end
  end
  inherited dsMain: TDataSource [9]
  end
  object atSQLSetup: TatSQLSetup [10]
    Ignores = <>
    Left = 336
    Top = 244
  end
  object gsPriceFilter: TgsQueryFilter [11]
    OnFilterChanged = gsQFMainFilterChanged
    Database = dmDatabase.ibdbGAdmin
    IBDataSet = ibdsMain
    Left = 416
    Top = 80
  end
  inherited gsQFMain: TgsQueryFilter [12]
    IBDataSet = nil
  end
  object gsPriceDetFilter: TgsQueryFilter [13]
    OnFilterChanged = gsQFDetailFilterChanged
    Database = dmDatabase.ibdbGAdmin
    IBDataSet = ibdsDetails
    Left = 416
    Top = 112
  end
  inherited gsQFDetail: TgsQueryFilter [14]
    IBDataSet = nil
  end
  inherited ibdsMain: TIBDataSet [15]
    DeleteSQL.Strings = (
      'DELETE FROM gd_price WHERE id = :OLD_ID')
    RefreshSQL.Strings = (
      'SELECT p.*, c.Name FROM gd_price p '
      '  LEFT JOIN gd_contact c ON p.contactkey = c.id'
      'WHERE p.id = :OLD_ID')
    SelectSQL.Strings = (
      'SELECT p.*, c.Name FROM gd_price p '
      '  LEFT JOIN gd_contact c ON p.contactkey = c.id'
      'WHERE'
      
        '  g_sec_testall(p.aview, p.achag, p.afull,  /*<UserGroups>*/-1) ' +
        ' <> 0'
      ''
      '  ')
  end
  inherited ibdsDetails: TIBDataSet
    DeleteSQL.Strings = (
      'DELETE FROM gd_pricepos WHERE id = :OLD_ID')
    RefreshSQL.Strings = (
      'SELECT '
      '   pp.ID,'
      '   pp.PriceKey,'
      '   pp.GoodKey,'
      '   g.*,'
      '   v.Name as ValueName'
      'FROM '
      '  gd_pricepos pp JOIN gd_good g ON pp.GoodKey = g.ID '
      '   JOIN gd_value v ON g.valuekey = v.id'
      'WHERE '
      '   pp.id = :OLD_ID'
      '')
    SelectSQL.Strings = (
      'SELECT '
      '   pp.ID,'
      '   pp.PriceKey,'
      '   pp.GoodKey,'
      '   g.*,'
      '   v.Name as ValueName'
      'FROM '
      '  gd_pricepos pp JOIN gd_good g ON pp.GoodKey = g.ID AND'
      '  pp.PriceKey = :id JOIN gd_value v ON g.valuekey = v.id AND'
      
        '  g_sec_testall(g.aview, g.achag, g.afull,  /*<UserGroups>*/-1) ' +
        ' <> 0')
  end
  inherited IBTransaction: TIBTransaction [18]
  end
  inherited pmMainFilter: TPopupMenu [19]
  end
  inherited pmDetailFilter: TPopupMenu [20]
  end
  inherited gsMainReportManager: TgsReportManager
    PopupMenu = pmPrint
    GroupID = 2000003
  end
  object gsReportRegistry: TgsReportRegistry
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DataSource = dsDetail
    PopupMenu = pmPrint
    MenuType = mtSeparator
    Caption = 'Печать'
    GroupID = 1000400
    Left = 368
    Top = 244
  end
  object pmPrint: TPopupMenu
    Left = 168
    Top = 72
  end
end
