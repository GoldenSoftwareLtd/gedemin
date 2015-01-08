inherited gdc_frmMDH: Tgdc_frmMDH
  Left = 801
  Top = 345
  Width = 732
  Height = 496
  HelpContext = 115
  Caption = 'gdc_frmMDH'
  Font.Charset = DEFAULT_CHARSET
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 439
    Width = 716
  end
  inherited TBDockTop: TTBDock
    Width = 716
    OnRequestDock = TBDockTopRequestDock
    inherited tbMainToolbar: TTBToolbar
      Caption = '������ ������������ (�������)'
    end
    inherited tbMainMenu: TTBToolbar
      DockPos = 8
      object tbsiMainMenuDetailObject: TTBSubmenuItem [1]
        Caption = '���������'
        object tbsi_mm_DetailNew: TTBSubmenuItem
          Action = actDetailNew
          OnPopup = tbsi_mm_DetailNewPopup
        end
        object tbi_mm_DetailEdit: TTBItem
          Action = actDetailEdit
        end
        object tbi_mm_DetailDelete: TTBItem
          Action = actDetailDelete
        end
        object tbi_mm_DetailDuplicate: TTBItem
          Action = actDetailDuplicate
        end
        object tbi_mm_DetailReduction: TTBItem
          Action = actDetailReduction
        end
        object tbi_mm_DetailSep1: TTBSeparatorItem
        end
        object tbi_mm_DetailCopy: TTBItem
          Action = actDetailCopy
        end
        object tbi_mm_DetailCut: TTBItem
          Action = actDetailCut
        end
        object tbi_mm_DetailPaste: TTBItem
          Action = actDetailPaste
        end
        object tbi_mm_DetailSep2: TTBSeparatorItem
        end
        object m_DetailLoadFromFile: TTBItem
          Action = actDetailLoadFromFile
        end
        object m_DetailSaveToFile: TTBItem
          Action = actDetailSaveToFile
        end
        object TBSeparatorItem1: TTBSeparatorItem
        end
        object tbi_mm_DetailFind: TTBItem
          Action = actDetailFind
        end
        object tbi_mm_DetailFilter: TTBItem
          Action = actDetailFilter
        end
        object tbi_mm_DetailPrint: TTBItem
          Action = actDetailPrint
        end
        object tbiDetailMenuAddToSelected: TTBItem
          Action = actDetailOnlySelected
        end
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 379
  end
  inherited TBDockRight: TTBDock
    Left = 707
    Height = 379
  end
  inherited TBDockBottom: TTBDock
    Top = 430
    Width = 716
  end
  inherited pnlWorkArea: TPanel
    Width = 698
    Height = 379
    TabOrder = 0
    object sMasterDetail: TSplitter [0]
      Left = 0
      Top = 167
      Width = 698
      Height = 6
      Cursor = crVSplit
      Align = alTop
      MinSize = 20
    end
    inherited spChoose: TSplitter
      Top = 274
      Width = 698
      Height = 6
    end
    inherited pnlMain: TPanel
      Width = 698
      Height = 167
      Align = alTop
      Constraints.MinHeight = 1
      OnResize = pnlMainResize
      inherited pnlSearchMain: TPanel
        Height = 167
        inherited sbSearchMain: TScrollBox
          Height = 140
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 280
      Width = 698
      TabOrder = 2
      inherited pnButtonChoose: TPanel
        Left = 593
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 593
      end
      inherited pnlChooseCaption: TPanel
        Width = 698
      end
    end
    object pnlDetail: TPanel
      Left = 0
      Top = 173
      Width = 698
      Height = 101
      Align = alClient
      BevelOuter = bvLowered
      Constraints.MinHeight = 100
      Constraints.MinWidth = 200
      TabOrder = 1
      object TBDockDetail: TTBDock
        Left = 1
        Top = 1
        Width = 696
        Height = 26
        OnRequestDock = TBDockDetailRequestDock
        object tbDetailToolbar: TTBToolbar
          Left = 0
          Top = 0
          Caption = '������ ������������ (���������)'
          CloseButton = False
          DockMode = dmCannotFloat
          ParentShowHint = False
          ShowHint = True
          Stretch = True
          TabOrder = 0
          object tbsiDetailNew: TTBSubmenuItem
            Action = actDetailNew
            DropdownCombo = True
            OnPopup = tbsiDetailNewPopup
          end
          object tbiDetailEdit: TTBItem
            Action = actDetailEdit
          end
          object tbiDetailDelete: TTBItem
            Action = actDetailDelete
          end
          object tbiDetailDublicate: TTBItem
            Action = actDetailDuplicate
          end
          object tbiDetailReduction: TTBItem
            Action = actDetailReduction
          end
          object tbsDetailOne: TTBSeparatorItem
          end
          object tbiDetailEditInGrid: TTBItem
            Action = actDetailEditInGrid
          end
          object tbiDetailCopy: TTBItem
            Action = actDetailCopy
          end
          object tbiDetailCut: TTBItem
            Action = actDetailCut
          end
          object tbiDetailPaste: TTBItem
            Action = actDetailPaste
          end
          object tbsDetailTwo: TTBSeparatorItem
          end
          object tbiDetailFind: TTBItem
            Action = actDetailFind
          end
          object tbiDetailFilter: TTBItem
            Action = actDetailFilter
          end
          object tbiDetailPrint: TTBItem
            Action = actDetailPrint
          end
          object tbiDetailOnlySelected: TTBItem
            Action = actDetailOnlySelected
          end
          object tbiDetailLinkObject: TTBItem
            Action = actDetailLinkObject
          end
        end
        object tbDetailCustom: TTBToolbar
          Left = 256
          Top = 0
          Caption = '�������������� ������ ������������ (���������)'
          CloseButton = False
          DockMode = dmCannotFloat
          DockPos = 256
          ParentShowHint = False
          ShowHint = True
          Stretch = True
          TabOrder = 1
          Visible = False
        end
      end
      object pnlSearchDetail: TPanel
        Left = 1
        Top = 27
        Width = 160
        Height = 73
        Align = alLeft
        BevelOuter = bvNone
        Color = 14741233
        TabOrder = 1
        Visible = False
        OnEnter = pnlSearchDetailEnter
        OnExit = pnlSearchDetailExit
        object sbSearchDetail: TScrollBox
          Left = 0
          Top = 27
          Width = 160
          Height = 46
          HorzScrollBar.Style = ssFlat
          HorzScrollBar.Visible = False
          VertScrollBar.Style = ssFlat
          Align = alClient
          BorderStyle = bsNone
          TabOrder = 0
        end
        object pnlSearchDetailButton: TPanel
          Left = 0
          Top = 0
          Width = 160
          Height = 27
          Align = alTop
          BevelOuter = bvNone
          ParentColor = True
          TabOrder = 1
          object btnSearchDetail: TButton
            Left = 12
            Top = 4
            Width = 64
            Height = 19
            Action = actSearchDetail
            Default = True
            TabOrder = 1
          end
          object btnSearchDetailClose: TButton
            Left = 83
            Top = 4
            Width = 64
            Height = 19
            Action = actSearchdetailClose
            TabOrder = 2
          end
          object chbxFuzzyMatchDetail: TCheckBox
            Left = 12
            Top = -2
            Width = 97
            Height = 17
            Caption = '����� �������'
            TabOrder = 0
            Visible = False
          end
        end
      end
    end
  end
  inherited alMain: TActionList
    Left = 260
    Top = 136
    inherited actNew: TAction
      Category = 'Main'
    end
    inherited actEdit: TAction
      Category = 'Main'
    end
    inherited actDelete: TAction
      Category = 'Main'
    end
    inherited actDuplicate: TAction
      Category = 'Main'
    end
    inherited actPrint: TAction
      Category = 'Main'
    end
    inherited actCut: TAction
      Category = 'Main'
    end
    inherited actCopy: TAction
      Category = 'Main'
    end
    inherited actPaste: TAction
      Category = 'Main'
    end
    inherited actCommit: TAction
      Category = 'Main'
    end
    inherited actRollback: TAction
      Category = 'Main'
    end
    object actDetailNew: TAction [12]
      Category = 'Detail'
      Caption = '��������...'
      Hint = '��������'
      ImageIndex = 0
      ShortCut = 49230
      OnExecute = actDetailNewExecute
      OnUpdate = actDetailNewUpdate
    end
    object actDetailEdit: TAction [13]
      Category = 'Detail'
      Caption = '�������� ...'
      Hint = '��������'
      ImageIndex = 1
      ShortCut = 49231
      OnExecute = actDetailEditExecute
      OnUpdate = actDetailEditUpdate
    end
    object actDetailDelete: TAction [14]
      Category = 'Detail'
      Caption = '�������'
      Hint = '�������'
      ImageIndex = 2
      ShortCut = 49220
      OnExecute = actDetailDeleteExecute
      OnUpdate = actDetailDeleteUpdate
    end
    object actDetailDuplicate: TAction [15]
      Category = 'Detail'
      Caption = '��������...'
      Hint = '��������'
      ImageIndex = 3
      ShortCut = 49237
      OnExecute = actDetailDuplicateExecute
      OnUpdate = actDetailDuplicateUpdate
    end
    object actDetailPrint: TAction [16]
      Category = 'Detail'
      Caption = '������'
      Hint = '������'
      ImageIndex = 15
      ShortCut = 49232
      OnExecute = actDetailPrintExecute
      OnUpdate = actDetailPrintUpdate
    end
    object actDetailCut: TAction [17]
      Category = 'Detail'
      Caption = '��������'
      Checked = True
      Hint = '��������'
      ImageIndex = 9
      Visible = False
      OnExecute = actDetailCutExecute
      OnUpdate = actDetailCutUpdate
    end
    object actDetailCopy: TAction [18]
      Category = 'Detail'
      Caption = '����������'
      Checked = True
      Hint = '����������'
      ImageIndex = 10
      Visible = False
      OnExecute = actDetailCopyExecute
      OnUpdate = actDetailCopyUpdate
    end
    object actDetailPaste: TAction [19]
      Category = 'Detail'
      Caption = '��������'
      Checked = True
      Hint = '��������'
      ImageIndex = 11
      Visible = False
      OnExecute = actDetailPasteExecute
      OnUpdate = actDetailPasteUpdate
    end
    object actDetailFind: TAction [22]
      Category = 'Detail'
      Caption = '�����...'
      Hint = '�����'
      ImageIndex = 23
      ShortCut = 49222
      OnExecute = actDetailFindExecute
      OnUpdate = actDetailFindUpdate
    end
    object actDetailReduction: TAction [23]
      Category = 'Detail'
      Caption = '������� ...'
      Hint = '�������'
      ImageIndex = 4
      OnExecute = actDetailReductionExecute
      OnUpdate = actDetailReductionUpdate
    end
    inherited actLoadFromFile: TAction
      Category = 'Main'
    end
    inherited actSaveToFile: TAction
      Category = 'Main'
    end
    inherited actSearchMain: TAction
      Category = 'Main'
    end
    inherited actSearchMainClose: TAction
      Category = 'Main'
    end
    object actDetailFilter: TAction [30]
      Category = 'Detail'
      Caption = '������'
      Hint = '������'
      ImageIndex = 20
      OnExecute = actDetailFilterExecute
      OnUpdate = actDetailFilterUpdate
    end
    object actDetailProperties: TAction [31]
      Category = 'Detail'
      Caption = '��������...'
      Hint = '��������...'
      ImageIndex = 28
      OnExecute = actDetailPropertiesExecute
      OnUpdate = actDetailPropertiesUpdate
    end
    object actSearchDetail: TAction [41]
      Category = 'Detail'
      Caption = '�����'
      OnExecute = actSearchDetailExecute
    end
    object actSearchdetailClose: TAction [42]
      Category = 'Detail'
      Caption = '�������'
      OnExecute = actSearchdetailCloseExecute
    end
    object actDetailAddToSelected: TAction [43]
      Category = 'Detail'
      Caption = '�������� � ����������'
      ImageIndex = 5
      OnExecute = actDetailAddToSelectedExecute
      OnUpdate = actDetailAddToSelectedUpdate
    end
    object actDetailRemoveFromSelected: TAction [44]
      Category = 'Detail'
      Caption = '������� �� ����������'
      OnExecute = actDetailRemoveFromSelectedExecute
      OnUpdate = actDetailRemoveFromSelectedUpdate
    end
    object actDetailOnlySelected: TAction [45]
      Category = 'Detail'
      Caption = '������ ����������'
      Hint = '������ ����������'
      ImageIndex = 6
      OnExecute = actDetailOnlySelectedExecute
      OnUpdate = actDetailOnlySelectedUpdate
    end
    object actDetailQExport: TAction [46]
      Category = 'Detail'
      Caption = '�������...'
      Hint = '�������'
      OnExecute = actDetailQExportExecute
      OnUpdate = actDetailQExportUpdate
    end
    object actDetailToSetting: TAction [47]
      Caption = '������������ ����...'
      Hint = '�������� � ������������ ����'
      ImageIndex = 81
      OnExecute = actDetailToSettingExecute
      OnUpdate = actDetailToSettingUpdate
    end
    object actDetailSaveToFile: TAction [48]
      Category = 'Detail'
      Caption = '��������� ������ � ����'
      Hint = '��������� ������ � ����'
      ImageIndex = 25
      OnExecute = actDetailSaveToFileExecute
      OnUpdate = actDetailSaveToFileUpdate
    end
    object actDetailLoadFromFile: TAction [49]
      Category = 'Detail'
      Caption = '��������� ������ �� �����'
      Hint = '��������� ������ �� �����'
      ImageIndex = 27
      OnExecute = actDetailLoadFromFileExecute
      OnUpdate = actDetailLoadFromFileUpdate
    end
    object actDetailEditInGrid: TAction
      Category = 'Detail'
      Caption = '�������������� � �������'
      Hint = '�������������� � �������'
      ImageIndex = 213
      Visible = False
    end
    object actDetailLinkObject: TAction
      Category = 'Detail'
      Caption = '����������...'
      Hint = '������������'
      ImageIndex = 265
      OnExecute = actDetailLinkObjectExecute
      OnUpdate = actDetailLinkObjectUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Left = 292
    Top = 164
  end
  inherited dsMain: TDataSource
    Left = 260
    Top = 164
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Top = 95
  end
  object dsDetail: TDataSource
    Left = 408
    Top = 300
  end
  object pmDetail: TPopupMenu
    OnPopup = pmDetailPopup
    Left = 464
    Top = 304
    object nDetailNew: TMenuItem
      Action = actDetailNew
    end
    object nDetailEdit: TMenuItem
      Action = actDetailEdit
    end
    object nDetailDel: TMenuItem
      Action = actDetailDelete
    end
    object nDetailDup: TMenuItem
      Action = actDetailDuplicate
    end
    object nDetailProperties: TMenuItem
      Action = actDetailProperties
    end
    object nDetailQExport: TMenuItem
      Action = actDetailQExport
    end
    object nSepartor5: TMenuItem
      Caption = '-'
    end
    object nDetailFind: TMenuItem
      Action = actDetailFind
    end
    object nDetailReduction: TMenuItem
      Action = actDetailReduction
    end
    object actDetailAddToSelected1: TMenuItem
      Action = actDetailAddToSelected
    end
    object actDetailRemoveFromSelected1: TMenuItem
      Action = actDetailRemoveFromSelected
    end
    object sprDetailSetting: TMenuItem
      Caption = '-'
    end
    object miDetailSetting: TMenuItem
      Action = actDetailToSetting
    end
  end
end
