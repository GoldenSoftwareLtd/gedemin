inherited gdc_frmTransaction: Tgdc_frmTransaction
  Left = 311
  Top = 383
  Width = 783
  Height = 540
  HelpContext = 158
  Caption = 'Журнал хозяйственных операций'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 483
    Width = 767
  end
  inherited TBDockTop: TTBDock
    Width = 767
  end
  inherited TBDockLeft: TTBDock
    Height = 423
  end
  inherited TBDockRight: TTBDock
    Left = 758
    Height = 423
  end
  inherited TBDockBottom: TTBDock
    Top = 474
    Width = 767
  end
  inherited pnlWorkArea: TPanel
    Width = 749
    Height = 423
    inherited sMasterDetail: TSplitter
      Height = 318
    end
    inherited spChoose: TSplitter
      Top = 318
      Width = 749
    end
    inherited pnlMain: TPanel
      Height = 318
      inherited pnlSearchMain: TPanel
        Height = 318
        inherited sbSearchMain: TScrollBox
          Height = 280
        end
        inherited pnlSearchMainButton: TPanel
          Top = 280
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 318
      end
    end
    inherited pnChoose: TPanel
      Top = 324
      Width = 749
      inherited pnButtonChoose: TPanel
        Left = 644
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 644
      end
      inherited pnlChooseCaption: TPanel
        Width = 749
      end
    end
    inherited pnlDetail: TPanel
      Width = 577
      Height = 318
      object splQuentity: TSplitter [0]
        Left = 0
        Top = 224
        Width = 577
        Height = 4
        Cursor = crVSplit
        Align = alBottom
      end
      object bvlSupport: TBevel [1]
        Left = 0
        Top = 223
        Width = 577
        Height = 1
        Align = alBottom
      end
      inherited TBDockDetail: TTBDock
        Width = 577
        Height = 51
        inherited tbDetailToolbar: TTBToolbar
          object TBItem1: TTBItem [0]
            Action = actBack
          end
          object TBItem2: TTBItem [1]
            Action = actDoReversalEntry
          end
          object TBSeparatorItem3: TTBSeparatorItem [2]
          end
          object tbiDetailEditLine: TTBItem [5]
            Action = actDetailEditLine
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 0
          Top = 26
          DockPos = -2
          DockRow = 1
          object TBControlItem1: TTBControlItem
            Control = cbGroupByDocument
          end
          object TBControlItem2: TTBControlItem
            Control = cbQuantity
          end
          object tbiShowAllEntries: TTBItem
            Action = actShowAllEntries
            DisplayMode = nbdmTextOnly
          end
          object cbGroupByDocument: TCheckBox
            Left = 0
            Top = 2
            Width = 169
            Height = 17
            Caption = 'Группировать по документу'
            TabOrder = 0
            OnClick = cbGroupByDocumentClick
          end
          object cbQuantity: TCheckBox
            Left = 169
            Top = 2
            Width = 240
            Height = 17
            Caption = 'Показывать количественные показатели'
            TabOrder = 1
            OnClick = cbQuantityClick
          end
        end
      end
      inherited pnlSearchDetail: TPanel
        Top = 51
        Height = 172
        inherited sbSearchDetail: TScrollBox
          Height = 134
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 134
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Top = 51
        Width = 417
        Height = 172
      end
      object pnlQuantity: TPanel
        Left = 0
        Top = 228
        Width = 577
        Height = 90
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
        object ibgrQuantity: TgsIBGrid
          Left = 0
          Top = 0
          Width = 577
          Height = 90
          HelpContext = 3
          Align = alClient
          BorderStyle = bsNone
          DataSource = dsQuantity
          Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
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
    end
  end
  inherited alMain: TActionList
    object actDetailEditLine: TAction [14]
      Category = 'Detail'
      Caption = 'Изменить позицию ...'
      Hint = 'Изменить позицию'
      ImageIndex = 121
      ShortCut = 49228
      OnExecute = actDetailEditLineExecute
      OnUpdate = actDetailEditLineUpdate
    end
    object actBack: TAction
      Caption = 'Назад'
      Hint = 'Назад'
      ImageIndex = 239
      OnExecute = actBackExecute
      OnUpdate = actBackUpdate
    end
    object actDoReversalEntry: TAction
      Category = 'Commands'
      Caption = 'Сторнировать проводку'
      Hint = 'Сторнировать проводку'
      ImageIndex = 236
      OnExecute = actDoReversalEntryExecute
      OnUpdate = actDoReversalEntryUpdate
    end
    object actShowAllEntries: TAction
      Category = 'Main'
      Caption = 'Отобразить все проводки'
      OnExecute = actShowAllEntriesExecute
      OnUpdate = actShowAllEntriesUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Left = 340
    Top = 193
  end
  inherited dsMain: TDataSource
    DataSet = gdcAcctTransaction
  end
  inherited dsDetail: TDataSource
    DataSet = gdcAcctViewEntryRegister
    Left = 504
    Top = 172
  end
  inherited pmDetail: TPopupMenu
    Left = 592
    Top = 176
    object nDetailEditLine: TMenuItem [2]
      Action = actDetailEditLine
    end
  end
  object gdcAcctTransaction: TgdcBaseAcctTransaction
    SubSet = 'ByCompany'
    Left = 109
    Top = 123
  end
  object gdcAcctViewEntryRegister: TgdcAcctViewEntryRegister
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 413
    Top = 177
  end
  object gdcAcctQuantity: TgdcAcctQuantity
    MasterSource = dsDetail
    MasterField = 'id'
    DetailField = 'entrykey'
    SubSet = 'ByEntry'
    Left = 416
    Top = 320
  end
  object dsQuantity: TDataSource
    DataSet = gdcAcctQuantity
    Left = 493
    Top = 321
  end
end
