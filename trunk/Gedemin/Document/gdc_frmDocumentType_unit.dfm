inherited gdc_frmDocumentType: Tgdc_frmDocumentType
  Left = 365
  Top = 169
  Width = 578
  Height = 433
  Caption = 'Типовые документы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 376
    Width = 562
  end
  inherited TBDockTop: TTBDock
    Width = 562
    inherited tbMainToolbar: TTBToolbar
      object TBSubmenuItem1: TTBSubmenuItem [1]
        Action = actNew
        DropdownCombo = True
        object TBItem1: TTBItem
          Action = actNew
        end
        object TBItem2: TTBItem
          Action = actNewSub
        end
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 309
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 316
  end
  inherited TBDockRight: TTBDock
    Left = 553
    Height = 316
  end
  inherited TBDockBottom: TTBDock
    Top = 367
    Width = 562
  end
  inherited pnlWorkArea: TPanel
    Width = 544
    Height = 316
    inherited sMasterDetail: TSplitter
      Height = 211
    end
    inherited spChoose: TSplitter
      Top = 211
      Width = 544
    end
    inherited pnlMain: TPanel
      Height = 211
      inherited pnlSearchMain: TPanel
        Height = 211
        inherited sbSearchMain: TScrollBox
          Height = 184
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 211
      end
    end
    inherited pnChoose: TPanel
      Top = 217
      Width = 544
      inherited pnButtonChoose: TPanel
        Left = 439
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 439
      end
      inherited pnlChooseCaption: TPanel
        Width = 544
      end
    end
    inherited pnlDetail: TPanel
      Width = 372
      Height = 211
      inherited TBDockDetail: TTBDock
        Width = 372
        inherited tbDetailToolbar: TTBToolbar
          object tbsmNew: TTBSubmenuItem [0]
            Caption = 'Добавить'
            DropdownCombo = True
            Hint = 'Добавить документ'
            ImageIndex = 0
            OnClick = tbsmNewClick
            object tbiAddUserDoc: TTBItem
              Action = actAddUserDoc
            end
            object tbiAddInvDocument: TTBItem
              Action = actAddInvDocument
            end
            object tbiAddInvPriceList: TTBItem
              Action = actAddInvPriceList
            end
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 286
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 185
        inherited sbSearchDetail: TScrollBox
          Height = 158
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 212
        Height = 185
      end
    end
  end
  inherited alMain: TActionList
    Top = 135
    object actNewSub: TAction [1]
      Category = 'Main'
      Caption = 'Добавить ветвь...'
      Hint = 'Добавить ветвь...'
      ImageIndex = 0
      OnExecute = actNewSubExecute
      OnUpdate = actNewSubUpdate
    end
    inherited actDetailNew: TAction
      Visible = False
      OnExecute = actAddUserDocExecute
    end
    object actAddUserDoc: TAction
      Category = 'Detail'
      Caption = 'Добавить документ пользователя'
      Hint = 'Добавить документ пользователя'
      ImageIndex = 0
      OnExecute = actAddUserDocExecute
      OnUpdate = actAddUserDocUpdate
    end
    object actAddInvDocument: TAction
      Category = 'Detail'
      Caption = 'Добавить складской документ'
      Hint = 'Добавить складской документ'
      ImageIndex = 0
      OnExecute = actAddInvDocumentExecute
      OnUpdate = actAddInvDocumentUpdate
    end
    object actAddInvPriceList: TAction
      Category = 'Detail'
      Caption = 'Добавить прайс-лист'
      Hint = 'Добавить прайс-лист'
      ImageIndex = 0
      OnExecute = actAddInvPriceListExecute
      OnUpdate = actAddInvPriceListUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Left = 113
    Top = 164
  end
  inherited dsMain: TDataSource
    DataSet = gdcDocumentBranch
    Top = 164
  end
  inherited dsDetail: TDataSource
    DataSet = gdcDocumentType
    Left = 398
    Top = 140
  end
  inherited pmDetail: TPopupMenu
    Left = 458
    Top = 140
  end
  object gdcDocumentType: TgdcDocumentType
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 428
    Top = 140
  end
  object gdcDocumentBranch: TgdcDocumentBranch
    Left = 113
    Top = 135
  end
end
