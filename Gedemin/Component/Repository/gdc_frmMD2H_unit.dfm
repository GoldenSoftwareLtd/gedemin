inherited gdc_frmMD2H: Tgdc_frmMD2H
  Left = 518
  Top = 180
  Width = 671
  Height = 538
  Caption = 'gdc_frmMD2H'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 488
    Width = 663
  end
  inherited TBDockTop: TTBDock
    Width = 663
  end
  inherited TBDockLeft: TTBDock
    Height = 428
  end
  inherited TBDockRight: TTBDock
    Left = 654
    Height = 428
  end
  inherited TBDockBottom: TTBDock
    Top = 479
    Width = 663
  end
  inherited pnlWorkArea: TPanel
    Width = 645
    Height = 428
    inherited sMasterDetail: TSplitter
      Width = 645
    end
    inherited spChoose: TSplitter
      Top = 323
      Width = 645
    end
    inherited pnlMain: TPanel
      Width = 645
    end
    inherited pnChoose: TPanel
      Top = 329
      Width = 645
      inherited pnButtonChoose: TPanel
        Left = 540
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 540
      end
      inherited pnlChooseCaption: TPanel
        Width = 645
      end
    end
    inherited pnlDetail: TPanel
      Width = 645
      Height = 150
      object sSubDetail: TSplitter [0]
        Left = 1
        Top = 69
        Width = 643
        Height = 4
        Cursor = crVSplit
        Align = alBottom
        Beveled = True
        MinSize = 20
      end
      inherited TBDockDetail: TTBDock
        Width = 643
      end
      inherited pnlSearchDetail: TPanel
        Height = 42
        inherited sbSearchDetail: TScrollBox
          Height = 15
        end
      end
      object pnlSubDetail: TPanel
        Left = 1
        Top = 73
        Width = 643
        Height = 76
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object TbDockSubDetail: TTBDock
          Left = 0
          Top = 0
          Width = 643
          Height = 26
          OnRequestDock = TbDockSubDetailRequestDock
          object tbSubDetailToolbar: TTBToolbar
            Left = 0
            Top = 0
            Caption = 'Панель инструментов'
            CloseButton = False
            DockMode = dmCannotFloat
            Images = dmImages.il16x16
            TabOrder = 0
            object tbiSubDetailNew: TTBItem
              Action = actSubDetailNew
            end
            object tbiSubDetailEdit: TTBItem
              Action = actSubDetailEdit
            end
            object tbiSubDetailDel: TTBItem
              Action = actSubDetailDelete
            end
            object tbiSubDetailDup: TTBItem
              Action = actSubDetailDuplicate
            end
            object tbiSubDetailRed: TTBItem
              Action = actSubDetailReduction
            end
            object tbsSubdetail1: TTBSeparatorItem
            end
            object tbiSubDetailFilter: TTBItem
              Action = actSubDetailFilter
            end
            object tbiSubdetailPrint: TTBItem
              Action = actSubDetailPrint
            end
          end
        end
      end
    end
  end
  inherited alMain: TActionList
    object actSubDetailNew: TAction [0]
      Category = 'SubDetail'
      Caption = 'Добавить...'
      Hint = 'Добавить'
      ImageIndex = 0
      OnExecute = actSubDetailNewExecute
      OnUpdate = actSubDetailNewUpdate
    end
    inherited actDetailReduction: TAction
      Caption = 'Слияние...'
    end
    object actSubDetailEdit: TAction
      Category = 'SubDetail'
      Caption = 'Изменить...'
      Hint = 'Изменить'
      ImageIndex = 1
      OnExecute = actSubDetailEditExecute
      OnUpdate = actSubDetailEditUpdate
    end
    object actSubDetailDelete: TAction
      Category = 'SubDetail'
      Caption = 'Удалить'
      Hint = 'Удалить'
      ImageIndex = 2
      OnExecute = actSubDetailDeleteExecute
      OnUpdate = actSubDetailDeleteUpdate
    end
    object actSubDetailDuplicate: TAction
      Category = 'SubDetail'
      Caption = 'Копировать'
      Hint = 'Копировать'
      ImageIndex = 3
      OnExecute = actSubDetailDuplicateExecute
      OnUpdate = actSubDetailDuplicateUpdate
    end
    object actSubDetailPrint: TAction
      Category = 'SubDetail'
      Caption = 'Печать'
      Hint = 'Печать'
      ImageIndex = 15
      OnExecute = actSubDetailPrintExecute
      OnUpdate = actSubDetailPrintUpdate
    end
    object actSubDetailReduction: TAction
      Category = 'SubDetail'
      Caption = 'Слияние...'
      Hint = 'Слияние'
      ImageIndex = 4
      OnExecute = actSubDetailReductionExecute
      OnUpdate = actSubDetailReductionUpdate
    end
    object actSubDetailFilter: TAction
      Category = 'SubDetail'
      Caption = 'Фильтр'
      Hint = 'Фильтр'
      ImageIndex = 20
      OnExecute = actSubDetailFilterExecute
      OnUpdate = actSubDetailFilterUpdate
    end
    object actSubDetailProperties: TAction
      Category = 'SubDetail'
      Caption = 'Свойства...'
      Hint = 'Свойства'
      ImageIndex = 28
      OnExecute = actSubDetailPropertiesExecute
      OnUpdate = actSubDetailPropertiesUpdate
    end
  end
  object dsSubDetail: TDataSource
    Left = 400
    Top = 364
  end
end
