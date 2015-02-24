inherited gdc_frmInvDocument: Tgdc_frmInvDocument
  Left = 380
  Top = 184
  Caption = 'Складской документ'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuObject: TTBSubmenuItem
        Caption = 'Документ'
      end
      inherited tbsiMainMenuDetailObject: TTBSubmenuItem
        Caption = 'Позиция'
      end
    end
    inherited tbMainInvariant: TTBToolbar
      object TBItem2: TTBItem
        Action = actCreateEntry
      end
      object TBItem4: TTBItem
        Action = actMainGotoEntry
      end
    end
  end
  inherited pnlWorkArea: TPanel
    inherited pnlDetail: TPanel
      inherited TBDockDetail: TTBDock
        inherited tbDetailToolbar: TTBToolbar
          object TBItem3: TTBItem
            Action = actGotoEntry
          end
          object TBItem1: TTBItem
            Action = actViewCard
          end
          object TBItem5: TTBItem
            Action = actViewAllCard
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 355
        end
      end
    end
  end
  inherited alMain: TActionList
    Left = 236
    Top = 80
    object actViewCard: TAction
      Category = 'Detail'
      Caption = 'Карточка по ТМЦ'
      Hint = 'Карточка по ТМЦ'
      ImageIndex = 73
      OnExecute = actViewCardExecute
    end
    object actCreateEntry: TAction
      Category = 'Main'
      Caption = 'Провести проводки'
      Hint = 'Провести проводки по документам'
      ImageIndex = 104
      OnExecute = actCreateEntryExecute
      OnUpdate = actCreateEntryUpdate
    end
    object actGotoEntry: TAction
      Category = 'Detail'
      Caption = 'Перейти на проводку'
      Hint = 'Перейти на проводку'
      ImageIndex = 53
      OnExecute = actGotoEntryExecute
    end
    object actMainGotoEntry: TAction
      Category = 'Main'
      Caption = 'Перейти на проводку'
      Hint = 'Перейти на проводку по шапке документа'
      ImageIndex = 53
      OnExecute = actMainGotoEntryExecute
    end
    object actViewAllCard: TAction
      Category = 'Detail'
      Caption = 'Просмотр карточки по холдингу...'
      Hint = 'Просмотр карточки по холдингу...'
      ImageIndex = 74
      OnExecute = actViewAllCardExecute
    end
  end
  inherited pmMain: TPopupMenu
    Left = 114
    Top = 110
  end
  inherited dsMain: TDataSource
    DataSet = gdcInvDocument
    Left = 204
    Top = 78
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Left = 161
    Top = 79
  end
  inherited dsDetail: TDataSource
    DataSet = gdcInvDocumentLine
  end
  inherited pmDetail: TPopupMenu
    Left = 438
    Top = 258
    object N1: TMenuItem [8]
      Action = actViewCard
    end
  end
  object gdcInvDocument: TgdcInvDocument
    Left = 114
    Top = 80
  end
  object gdcInvDocumentLine: TgdcInvDocumentLine
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'parent'
    SubSet = 'ByParent'
    Left = 438
    Top = 228
  end
end
