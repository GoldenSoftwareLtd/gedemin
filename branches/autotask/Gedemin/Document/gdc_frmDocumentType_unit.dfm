inherited gdc_frmDocumentType: Tgdc_frmDocumentType
  Left = 365
  Top = 169
  Width = 795
  Height = 542
  Caption = 'Типовые документы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 485
    Width = 779
  end
  inherited TBDockTop: TTBDock
    Width = 779
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
    Height = 425
  end
  inherited TBDockRight: TTBDock
    Left = 770
    Height = 425
  end
  inherited TBDockBottom: TTBDock
    Top = 476
    Width = 779
  end
  inherited pnlWorkArea: TPanel
    Width = 761
    Height = 425
    inherited sMasterDetail: TSplitter
      Height = 320
    end
    inherited spChoose: TSplitter
      Top = 320
      Width = 761
    end
    inherited pnlMain: TPanel
      Height = 320
      inherited pnlSearchMain: TPanel
        Height = 320
        inherited sbSearchMain: TScrollBox
          Height = 293
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 320
        Images = dmImages.ilTree
        OnGetImageIndex = tvGroupGetImageIndex
      end
    end
    inherited pnChoose: TPanel
      Top = 326
      Width = 761
      inherited pnButtonChoose: TPanel
        Left = 656
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 656
      end
      inherited pnlChooseCaption: TPanel
        Width = 761
      end
    end
    inherited pnlDetail: TPanel
      Width = 589
      Height = 320
      inherited TBDockDetail: TTBDock
        Width = 589
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
        Height = 294
        inherited sbSearchDetail: TScrollBox
          Height = 267
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 429
        Height = 294
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
  object gdcBaseDocumentType: TgdcBaseDocumentType
    Left = 72
    Top = 128
  end
end
