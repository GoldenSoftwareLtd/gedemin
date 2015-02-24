inherited gdc_frmMD2H: Tgdc_frmMD2H
  Left = 518
  Top = 180
  Width = 671
  Height = 538
  Caption = 'gdc_frmMD2H'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 481
    Width = 655
  end
  inherited TBDockTop: TTBDock
    Width = 655
  end
  inherited TBDockLeft: TTBDock
    Height = 421
  end
  inherited TBDockRight: TTBDock
    Left = 646
    Height = 421
  end
  inherited TBDockBottom: TTBDock
    Top = 472
    Width = 655
  end
  inherited pnlWorkArea: TPanel
    Width = 637
    Height = 421
    inherited sMasterDetail: TSplitter
      Width = 637
    end
    inherited spChoose: TSplitter
      Top = 316
      Width = 637
    end
    inherited pnlMain: TPanel
      Width = 637
    end
    inherited pnChoose: TPanel
      Top = 322
      Width = 637
      inherited pnButtonChoose: TPanel
        Left = 532
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 532
      end
      inherited pnlChooseCaption: TPanel
        Width = 637
      end
    end
    inherited pnlDetail: TPanel
      Width = 637
      Height = 143
      object sSubDetail: TSplitter [0]
        Left = 1
        Top = 62
        Width = 635
        Height = 4
        Cursor = crVSplit
        Align = alBottom
        Beveled = True
        MinSize = 20
      end
      inherited TBDockDetail: TTBDock
        Width = 635
      end
      inherited pnlSearchDetail: TPanel
        Height = 35
        inherited sbSearchDetail: TScrollBox
          Height = 8
        end
      end
      object pnlSubDetail: TPanel
        Left = 1
        Top = 66
        Width = 635
        Height = 76
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object TbDockSubDetail: TTBDock
          Left = 0
          Top = 0
          Width = 635
          Height = 26
          OnRequestDock = TbDockSubDetailRequestDock
          object tbSubDetailToolbar: TTBToolbar
            Left = 0
            Top = 0
            Caption = '������ ������������'
            CloseButton = False
            DockMode = dmCannotFloat
            Images = dmImages.il16x16
            TabOrder = 0
            object tbsiSubDetailNew: TTBSubmenuItem
              Action = actSubDetailNew
              OnPopup = tbsiSubDetailNewPopup
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
      Caption = '��������...'
      Hint = '��������'
      ImageIndex = 0
      OnExecute = actSubDetailNewExecute
      OnUpdate = actSubDetailNewUpdate
    end
    inherited actDetailReduction: TAction
      Caption = '�������...'
    end
    object actSubDetailEdit: TAction
      Category = 'SubDetail'
      Caption = '��������...'
      Hint = '��������'
      ImageIndex = 1
      OnExecute = actSubDetailEditExecute
      OnUpdate = actSubDetailEditUpdate
    end
    object actSubDetailDelete: TAction
      Category = 'SubDetail'
      Caption = '�������'
      Hint = '�������'
      ImageIndex = 2
      OnExecute = actSubDetailDeleteExecute
      OnUpdate = actSubDetailDeleteUpdate
    end
    object actSubDetailDuplicate: TAction
      Category = 'SubDetail'
      Caption = '����������'
      Hint = '����������'
      ImageIndex = 3
      OnExecute = actSubDetailDuplicateExecute
      OnUpdate = actSubDetailDuplicateUpdate
    end
    object actSubDetailPrint: TAction
      Category = 'SubDetail'
      Caption = '������'
      Hint = '������'
      ImageIndex = 15
      OnExecute = actSubDetailPrintExecute
      OnUpdate = actSubDetailPrintUpdate
    end
    object actSubDetailReduction: TAction
      Category = 'SubDetail'
      Caption = '�������...'
      Hint = '�������'
      ImageIndex = 4
      OnExecute = actSubDetailReductionExecute
      OnUpdate = actSubDetailReductionUpdate
    end
    object actSubDetailFilter: TAction
      Category = 'SubDetail'
      Caption = '������'
      Hint = '������'
      ImageIndex = 20
      OnExecute = actSubDetailFilterExecute
      OnUpdate = actSubDetailFilterUpdate
    end
    object actSubDetailProperties: TAction
      Category = 'SubDetail'
      Caption = '��������...'
      Hint = '��������'
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
