inherited gdc_dlgHGR: Tgdc_dlgHGR
  Left = 524
  Top = 339
  Width = 600
  Height = 410
  BorderStyle = bsSizeable
  Caption = 'gdc_dlgHGR'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 9
    Top = 357
  end
  inherited btnNew: TButton
    Left = 85
    Top = 357
  end
  inherited btnHelp: TButton
    Left = 161
    Top = 357
  end
  inherited btnOK: TButton
    Left = 438
    Top = 357
  end
  inherited btnCancel: TButton
    Left = 514
    Top = 357
  end
  object pnlMain: TPanel [5]
    Left = 0
    Top = 0
    Width = 584
    Height = 352
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 5
    object splMain: TSplitter
      Left = 0
      Top = 152
      Width = 584
      Height = 4
      Cursor = crVSplit
      Align = alTop
    end
    object pnlDetail: TPanel
      Left = 0
      Top = 156
      Width = 584
      Height = 196
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object ibgrDetail: TgsIBGrid
        Left = 9
        Top = 26
        Width = 566
        Height = 161
        Align = alClient
        DataSource = dsDetail
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 0
        OnEnter = ibgrDetailEnter
        OnExit = ibgrDetailExit
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
      object tbdTop: TTBDock
        Left = 0
        Top = 0
        Width = 584
        Height = 26
        object tbDetail: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'tbDetail'
          DockMode = dmCannotFloat
          Images = dmImages.il16x16
          Stretch = True
          TabOrder = 0
          object tbNew: TTBItem
            Action = actDetailNew
          end
          object tbEdit: TTBItem
            Action = actDetailEdit
          end
          object tbDelete: TTBItem
            Action = actDetailDelete
          end
          object tbDuplicate: TTBItem
            Action = actDetailDuplicate
          end
          object tbiDetailProperties: TTBItem
            Action = actDetailProp
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object tbCopy: TTBItem
            Action = actDetailCopy
          end
          object tbCut: TTBItem
            Action = actDetailCut
          end
          object tbPaste: TTBItem
            Action = actDetailPaste
          end
          object TBSeparatorItem2: TTBSeparatorItem
          end
          object tbMacro: TTBItem
            Action = actDetailMacro
            Options = [tboDropdownArrow]
          end
        end
      end
      object tbdLeft: TTBDock
        Left = 0
        Top = 26
        Width = 9
        Height = 161
        Position = dpLeft
      end
      object tbdRight: TTBDock
        Left = 575
        Top = 26
        Width = 9
        Height = 161
        Position = dpRight
      end
      object tbdBottom: TTBDock
        Left = 0
        Top = 187
        Width = 584
        Height = 9
        Position = dpBottom
      end
    end
    object pnlMaster: TPanel
      Left = 0
      Top = 0
      Width = 584
      Height = 152
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
    end
  end
  inherited alBase: TActionList
    Left = 388
    Top = 8
    inherited actNextRecord: TAction
      ShortCut = 16462
    end
    inherited actPrevRecord: TAction
      ShortCut = 16464
    end
    object actDetailNew: TAction
      Category = 'Detail'
      Caption = 'Новый'
      Hint = 'Новый'
      ImageIndex = 0
      ShortCut = 49230
      OnExecute = actDetailNewExecute
      OnUpdate = actDetailNewUpdate
    end
    object actDetailEdit: TAction
      Category = 'Detail'
      Caption = 'Редактировать'
      Hint = 'Редактировать'
      ImageIndex = 1
      ShortCut = 49231
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
    object actDetailDuplicate: TAction
      Category = 'Detail'
      Caption = 'Дубликат'
      Hint = 'Дубликат'
      ImageIndex = 3
      ShortCut = 49237
      OnExecute = actDetailDuplicateExecute
      OnUpdate = actDetailDuplicateUpdate
    end
    object actDetailPrint: TAction
      Category = 'Detail'
      Caption = 'Печать'
      Hint = 'Печать'
      ImageIndex = 15
      ShortCut = 49232
    end
    object actDetailCut: TAction
      Category = 'Detail'
      Caption = 'Вырезать'
      Enabled = False
      Hint = 'Вырезать'
      ImageIndex = 9
      ShortCut = 49240
      Visible = False
      OnExecute = actDetailCutExecute
      OnUpdate = actDetailCutUpdate
    end
    object actDetailCopy: TAction
      Category = 'Detail'
      Caption = 'Копировать'
      Enabled = False
      Hint = 'Копировать'
      ImageIndex = 10
      ShortCut = 49219
      Visible = False
      OnExecute = actDetailCopyExecute
      OnUpdate = actDetailCopyUpdate
    end
    object actDetailPaste: TAction
      Category = 'Detail'
      Caption = 'Вставить'
      Enabled = False
      Hint = 'Вставить'
      ImageIndex = 11
      ShortCut = 49232
      Visible = False
      OnExecute = actDetailPasteExecute
      OnUpdate = actDetailPasteUpdate
    end
    object actDetailMacro: TAction
      Category = 'Detail'
      Caption = 'Макрос'
      Hint = 'Макрос'
      ImageIndex = 21
    end
    object actDetailProp: TAction
      Category = 'Detail'
      Caption = 'Свойства...'
      Hint = 'Свойства'
      ImageIndex = 28
      OnExecute = actDetailPropExecute
      OnUpdate = actDetailPropUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 421
    Top = 7
  end
  object dsDetail: TDataSource
    Left = 421
    Top = 38
  end
end
