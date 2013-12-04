inherited dlgInvDocument: TdlgInvDocument
  Left = 806
  Top = 234
  Width = 560
  Height = 410
  BorderStyle = bsSizeable
  Caption = ''
  OnClose = FormClose
  OnDestroy = nil
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 2
    Top = 345
    Width = 550
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  inherited btnAccess: TButton
    Top = 353
  end
  inherited btnNew: TButton
    Top = 353
  end
  inherited btnHelp: TButton
    Top = 353
  end
  inherited btnOK: TButton
    Left = 398
    Top = 353
  end
  inherited btnCancel: TButton
    Left = 470
    Top = 353
  end
  object pnlMain: TPanel [6]
    Left = 0
    Top = 25
    Width = 552
    Height = 320
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 5
    object sptMain: TSplitter
      Left = 2
      Top = 147
      Width = 548
      Height = 6
      Cursor = crVSplit
      Align = alTop
    end
    object pnlAttributes: TPanel
      Left = 2
      Top = 2
      Width = 548
      Height = 145
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object pnlCommonAttributes: TPanel
        Left = 0
        Top = 0
        Width = 548
        Height = 145
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object atAttributes: TatContainer
          Left = 0
          Top = 0
          Width = 548
          Height = 145
          DataSource = dsgdcBase
          Align = alClient
          BorderStyle = bsNone
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
          OnRelationNames = atAttributesRelationNames
          OnAdjustControl = atAttributesAdjustControl
        end
      end
    end
    object pnlCommon: TPanel
      Left = 2
      Top = 153
      Width = 548
      Height = 165
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object pnlGrids: TPanel
        Left = 9
        Top = 26
        Width = 530
        Height = 130
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object ibgrdTop: TgsIBGrid
          Left = 0
          Top = 0
          Width = 530
          Height = 130
          Align = alClient
          BorderStyle = bsNone
          PopupMenu = pmDetailMenu
          TabOrder = 0
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
      object TBDockLeft: TTBDock
        Left = 0
        Top = 26
        Width = 9
        Height = 130
        Position = dpLeft
      end
      object TBDockRight: TTBDock
        Left = 539
        Top = 26
        Width = 9
        Height = 130
        Position = dpRight
      end
      object TBDockBottom: TTBDock
        Left = 0
        Top = 156
        Width = 548
        Height = 9
        Position = dpBottom
      end
      object TBDockTop: TTBDock
        Left = 0
        Top = 0
        Width = 548
        Height = 26
        object tbDetailToolbar: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'Панель инструментов'
          CloseButton = False
          DockMode = dmCannotFloatOrChangeDocks
          FullSize = True
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object tbiDetailNew: TTBItem
            Action = actDetailNew
          end
          object tbiDetailEdit: TTBItem
            Action = actDetailEdit
          end
          object tbiDetailDelete: TTBItem
            Action = actDetailDelete
          end
          object tbiDetailSecurity: TTBItem
            Action = actDetailSecurity
          end
          object TBItem5: TTBItem
            Action = actCommit
          end
          object tbiPrint: TTBItem
            Action = actPrint
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBItem1: TTBItem
            Action = actAddGoodsWithQuant
          end
          object TBSeparatorItem2: TTBSeparatorItem
          end
          object TBItem2: TTBItem
            Action = actGoodsRef
            Options = [tboToolbarStyle, tboToolbarSize]
          end
          object TBItem3: TTBItem
            Action = actRemainsRef
            Options = [tboToolbarStyle, tboToolbarSize]
          end
          object TBItem4: TTBItem
            Action = actSelectGood
            Options = [tboToolbarStyle, tboToolbarSize]
          end
          object TBItem6: TTBItem
            Action = actViewCard
          end
          object TBItem7: TTBItem
            Action = actViewFullCard
          end
          object tbMacro: TTBItem
            Action = actMacro
          end
        end
      end
    end
  end
  object pnlHolding: TPanel [7]
    Left = 0
    Top = 0
    Width = 552
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 6
    object lblCompany: TLabel
      Left = 8
      Top = 5
      Width = 53
      Height = 13
      Caption = 'Компания:'
    end
    object iblkCompany: TgsIBLookupComboBox
      Left = 88
      Top = 2
      Width = 193
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrCommon
      DataSource = dsgdcBase
      DataField = 'companykey'
      ListTable = 'gd_contact'
      ListField = 'name'
      KeyField = 'ID'
      Condition = 
        'exists (select companykey from gd_ourcompany where companykey=gd' +
        '_contact.id)'
      gdClassName = 'TgdcOurCompany'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  inherited alBase: TActionList
    Left = 40
    Top = 45
    inherited actNew: TAction
      Category = 'MainCommands'
    end
    inherited actHelp: TAction
      Category = 'MainCommands'
    end
    inherited actSecurity: TAction
      Category = 'MainCommands'
    end
    inherited actOk: TAction
      Category = 'MainCommands'
    end
    inherited actCancel: TAction
      Category = 'MainCommands'
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 10
    Top = 45
  end
  inherited ibtrCommon: TIBTransaction
    Left = 100
    Top = 45
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 70
    Top = 45
    object actDetailNew: TAction
      Category = 'Detail'
      Caption = 'Добавить...'
      Hint = 'Добавить'
      ImageIndex = 0
      ShortCut = 49230
      Visible = False
      OnExecute = actDetailNewExecute
      OnUpdate = actDetailNewUpdate
    end
    object actDetailEdit: TAction
      Category = 'Detail'
      Caption = 'Изменить ...'
      Hint = 'Изменить'
      ImageIndex = 1
      ShortCut = 49231
      Visible = False
      OnExecute = actDetailEditExecute
      OnUpdate = actDetailEditUpdate
    end
    object actDetailDelete: TAction
      Category = 'Detail'
      Caption = 'Удалить'
      Hint = 'Удалить'
      ImageIndex = 2
      ShortCut = 16430
      OnExecute = actDetailDeleteExecute
      OnUpdate = actDetailDeleteUpdate
    end
    object actGoodsRef: TAction
      Category = 'References'
      Caption = 'Справочник ТМЦ'
      Hint = 'Выбор товаров из справочника ТМЦ'
      OnExecute = actGoodsRefExecute
      OnUpdate = actGoodsRefUpdate
    end
    object actRemainsRef: TAction
      Category = 'References'
      Caption = 'Остатки ТМЦ'
      Hint = 'Выбор товаров из остатков ТМЦ'
      ShortCut = 16504
      OnExecute = actRemainsRefExecute
      OnUpdate = actRemainsRefUpdate
    end
    object actMacro: TAction
      Category = 'References'
      Caption = 'Макрос'
      Hint = 'Макрос'
      ImageIndex = 21
      OnExecute = actMacroExecute
    end
    object actSelectGood: TAction
      Category = 'References'
      Caption = 'Остатки по позиции'
      Hint = 'Выбрать остатки по товару из текущей позиции'
      ShortCut = 120
      OnExecute = actSelectGoodExecute
      OnUpdate = actSelectGoodUpdate
    end
    object actCommit: TAction
      Category = 'Detail'
      Caption = 'Сохранить'
      Hint = 'Сохранить документ'
      ImageIndex = 18
      OnExecute = actCommitExecute
      OnUpdate = actCommitUpdate
    end
    object actPrint: TAction
      Category = 'Detail'
      Caption = 'Печать'
      ImageIndex = 15
      OnExecute = actPrintExecute
      OnUpdate = actPrintUpdate
    end
    object actAddGoodsWithQuant: TAction
      Category = 'References'
      Caption = 'Справочник товаров с количеством'
      Hint = 'Справочник товаров с количеством'
      ImageIndex = 181
      OnExecute = actAddGoodsWithQuantExecute
      OnUpdate = actAddGoodsWithQuantUpdate
    end
    object actDetailSecurity: TAction
      Category = 'Detail'
      Caption = 'Свойства'
      Hint = 'Свойства'
      ImageIndex = 28
      Visible = False
      OnExecute = actDetailSecurityExecute
      OnUpdate = actDetailSecurityUpdate
    end
    object actViewCard: TAction
      Category = 'Detail'
      Caption = 'Карточка ТМЦ'
      Hint = 'Карточка ТМЦ'
      ImageIndex = 73
      OnExecute = actViewCardExecute
      OnUpdate = actViewCardUpdate
    end
    object actViewFullCard: TAction
      Category = 'Detail'
      Caption = 'Просмотр карточки по холдингу...'
      Hint = 'Просмотр карточки по холдингу...'
      ImageIndex = 74
      OnExecute = actViewFullCardExecute
    end
  end
  object pmDetailMenu: TPopupMenu
    Left = 184
    Top = 208
    object N8: TMenuItem
      Action = actDetailDelete
    end
    object N6: TMenuItem
      Action = actGoodsRef
    end
    object N5: TMenuItem
      Action = actRemainsRef
    end
    object N4: TMenuItem
      Action = actSelectGood
    end
  end
  object gdMacrosMenu: TgdMacrosMenu
    Left = 249
    Top = 111
  end
  object pmDetail2: TPopupMenu
    Left = 264
    Top = 224
    object MenuItem1: TMenuItem
      Action = actDetailDelete
    end
    object N3: TMenuItem
      Action = actRemainsRef
    end
    object N2: TMenuItem
      Action = actSelectGood
    end
  end
end
