inherited gdc_frmMDH: Tgdc_frmMDH
  Left = 536
  Top = 205
  Width = 732
  Height = 496
  HelpContext = 115
  Caption = 'gdc_frmMDH'
  Font.Charset = DEFAULT_CHARSET
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 446
    Width = 724
  end
  inherited TBDockTop: TTBDock
    Width = 724
    OnRequestDock = TBDockTopRequestDock
    inherited tbMainToolbar: TTBToolbar
      Caption = 'Панель инструментов (главная)'
    end
    inherited tbMainMenu: TTBToolbar
      DockPos = 8
      object tbsiMainMenuDetailObject: TTBSubmenuItem [1]
        Caption = 'Детальный'
        object tbi_mm_DetailNew: TTBItem
          Action = actDetailNew
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
    Height = 386
  end
  inherited TBDockRight: TTBDock
    Left = 715
    Height = 386
  end
  inherited TBDockBottom: TTBDock
    Top = 437
    Width = 724
  end
  inherited pnlWorkArea: TPanel
    Width = 706
    Height = 386
    TabOrder = 0
    object sMasterDetail: TSplitter [0]
      Left = 0
      Top = 167
      Width = 706
      Height = 6
      Cursor = crVSplit
      Align = alTop
      MinSize = 20
    end
    inherited spChoose: TSplitter
      Top = 281
      Width = 706
      Height = 6
    end
    inherited pnlMain: TPanel
      Width = 706
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
      Top = 287
      Width = 706
      TabOrder = 2
      inherited pnButtonChoose: TPanel
        Left = 601
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 601
      end
      inherited pnlChooseCaption: TPanel
        Width = 706
      end
    end
    object pnlDetail: TPanel
      Left = 0
      Top = 173
      Width = 706
      Height = 108
      Align = alClient
      BevelOuter = bvLowered
      Constraints.MinHeight = 100
      Constraints.MinWidth = 200
      TabOrder = 1
      object TBDockDetail: TTBDock
        Left = 1
        Top = 1
        Width = 704
        Height = 26
        OnRequestDock = TBDockDetailRequestDock
        object tbDetailToolbar: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'Панель инструментов (детальная)'
          CloseButton = False
          DockMode = dmCannotFloatOrChangeDocks
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          Stretch = True
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
          Caption = 'Дополнительная панель инструментов (детальная)'
          CloseButton = False
          DockMode = dmCannotFloatOrChangeDocks
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
        Height = 80
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
          Height = 53
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
            Caption = 'Найти похожие'
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
      Caption = 'Добавить...'
      Hint = 'Добавить'
      ImageIndex = 0
      ShortCut = 49230
      OnExecute = actDetailNewExecute
      OnUpdate = actDetailNewUpdate
    end
    object actDetailEdit: TAction [13]
      Category = 'Detail'
      Caption = 'Изменить ...'
      Hint = 'Изменить'
      ImageIndex = 1
      ShortCut = 49231
      OnExecute = actDetailEditExecute
      OnUpdate = actDetailEditUpdate
    end
    object actDetailDelete: TAction [14]
      Category = 'Detail'
      Caption = 'Удалить'
      Hint = 'Удалить'
      ImageIndex = 2
      ShortCut = 49220
      OnExecute = actDetailDeleteExecute
      OnUpdate = actDetailDeleteUpdate
    end
    object actDetailDuplicate: TAction [15]
      Category = 'Detail'
      Caption = 'Дубликат...'
      Hint = 'Дубликат'
      ImageIndex = 3
      ShortCut = 49237
      OnExecute = actDetailDuplicateExecute
      OnUpdate = actDetailDuplicateUpdate
    end
    object actDetailPrint: TAction [16]
      Category = 'Detail'
      Caption = 'Печать'
      Hint = 'Печать'
      ImageIndex = 15
      ShortCut = 49232
      OnExecute = actDetailPrintExecute
      OnUpdate = actDetailPrintUpdate
    end
    object actDetailCut: TAction [17]
      Category = 'Detail'
      Caption = 'Вырезать'
      Checked = True
      Hint = 'Вырезать'
      ImageIndex = 9
      Visible = False
      OnExecute = actDetailCutExecute
      OnUpdate = actDetailCutUpdate
    end
    object actDetailCopy: TAction [18]
      Category = 'Detail'
      Caption = 'Копировать'
      Checked = True
      Hint = 'Копировать'
      ImageIndex = 10
      Visible = False
      OnExecute = actDetailCopyExecute
      OnUpdate = actDetailCopyUpdate
    end
    object actDetailPaste: TAction [19]
      Category = 'Detail'
      Caption = 'Вставить'
      Checked = True
      Hint = 'Вставить'
      ImageIndex = 11
      Visible = False
      OnExecute = actDetailPasteExecute
      OnUpdate = actDetailPasteUpdate
    end
    object actDetailFind: TAction [22]
      Category = 'Detail'
      Caption = 'Поиск...'
      Hint = 'Поиск'
      ImageIndex = 23
      ShortCut = 49222
      OnExecute = actDetailFindExecute
      OnUpdate = actDetailFindUpdate
    end
    object actDetailReduction: TAction [23]
      Category = 'Detail'
      Caption = 'Слияние ...'
      Hint = 'Слияние'
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
      Caption = 'Фильтр'
      Hint = 'Фильтр'
      ImageIndex = 20
      OnExecute = actDetailFilterExecute
      OnUpdate = actDetailFilterUpdate
    end
    object actDetailProperties: TAction [31]
      Category = 'Detail'
      Caption = 'Свойства...'
      Hint = 'Свойства...'
      ImageIndex = 28
      OnExecute = actDetailPropertiesExecute
      OnUpdate = actDetailPropertiesUpdate
    end
    object actSearchDetail: TAction [41]
      Category = 'Detail'
      Caption = 'Найти'
      OnExecute = actSearchDetailExecute
    end
    object actSearchdetailClose: TAction [42]
      Category = 'Detail'
      Caption = 'Закрыть'
      OnExecute = actSearchdetailCloseExecute
    end
    object actDetailAddToSelected: TAction [43]
      Category = 'Detail'
      Caption = 'Добавить в отмеченные'
      ImageIndex = 5
      OnExecute = actDetailAddToSelectedExecute
      OnUpdate = actDetailAddToSelectedUpdate
    end
    object actDetailRemoveFromSelected: TAction [44]
      Category = 'Detail'
      Caption = 'Удалить из отмеченных'
      OnExecute = actDetailRemoveFromSelectedExecute
      OnUpdate = actDetailRemoveFromSelectedUpdate
    end
    object actDetailOnlySelected: TAction [45]
      Category = 'Detail'
      Caption = 'Только отмеченные'
      Hint = 'Только отмеченные'
      ImageIndex = 6
      OnExecute = actDetailOnlySelectedExecute
      OnUpdate = actDetailOnlySelectedUpdate
    end
    object actDetailQExport: TAction [46]
      Category = 'Detail'
      Caption = 'Экспорт...'
      Hint = 'Экспорт'
      OnExecute = actDetailQExportExecute
      OnUpdate = actDetailQExportUpdate
    end
    object actDetailToSetting: TAction [47]
      Caption = 'Пространство имен...'
      Hint = 'Добавить в пространство имен'
      ImageIndex = 81
      OnExecute = actDetailToSettingExecute
      OnUpdate = actDetailToSettingUpdate
    end
    object actDetailSaveToFile: TAction [48]
      Category = 'Detail'
      Caption = 'Сохранить объект в файл'
      Hint = 'Сохранить объект в файл'
      ImageIndex = 25
      OnExecute = actDetailSaveToFileExecute
      OnUpdate = actDetailSaveToFileUpdate
    end
    object actDetailLoadFromFile: TAction [49]
      Category = 'Detail'
      Caption = 'Загрузить объект из файла'
      Hint = 'Загрузить объект из файла'
      ImageIndex = 27
      OnExecute = actDetailLoadFromFileExecute
      OnUpdate = actDetailLoadFromFileUpdate
    end
    object actDetailEditInGrid: TAction
      Category = 'Detail'
      Caption = 'Редактирование в таблице'
      Hint = 'Редактирование в таблице'
      ImageIndex = 213
      Visible = False
    end
    object actDetailLinkObject: TAction
      Category = 'Detail'
      Caption = 'Прикрепить...'
      Hint = 'Прикрепления'
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
