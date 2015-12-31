inherited gdc_frmNamespace: Tgdc_frmNamespace
  Left = 327
  Top = 117
  Width = 1090
  Height = 742
  Caption = 'Пространства имен'
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 684
    Width = 1074
  end
  inherited TBDockTop: TTBDock
    Width = 1074
    inherited tbMainCustom: TTBToolbar
      Images = dmImages.il16x16
      object TBItem1: TTBItem
        Action = actSetObjectPos
      end
      object TBItem2: TTBItem
        Action = actCompareWithData
      end
      object TBItem3: TTBItem
        Action = actShowDuplicates
      end
      object TBItem4: TTBItem
        Action = actShowRecursion
      end
      object TBItem6: TTBItem
        Action = actNSObjects
      end
      object TBItem7: TTBItem
        Action = actViewNS
        Caption = 'Зависимости файлов пространств имен'
        Hint = 'Показать зависимости между файлами пространств имен'
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 624
  end
  inherited TBDockRight: TTBDock
    Left = 1065
    Height = 624
  end
  inherited TBDockBottom: TTBDock
    Top = 675
    Width = 1074
  end
  inherited pnlWorkArea: TPanel
    Width = 1056
    Height = 624
    inherited sMasterDetail: TSplitter
      Width = 1056
    end
    inherited spChoose: TSplitter
      Top = 519
      Width = 1056
    end
    inherited pnlMain: TPanel
      Width = 1056
      inherited ibgrMain: TgsIBGrid
        Width = 896
      end
    end
    inherited pnChoose: TPanel
      Top = 525
      Width = 1056
      inherited pnButtonChoose: TPanel
        Left = 951
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 951
      end
      inherited pnlChooseCaption: TPanel
        Width = 1056
      end
    end
    inherited pnlDetail: TPanel
      Width = 1056
      Height = 346
      object splObjects: TSplitter [0]
        Left = 817
        Top = 26
        Width = 6
        Height = 320
        Cursor = crHSplit
      end
      inherited TBDockDetail: TTBDock
        Width = 1056
        inherited tbDetailCustom: TTBToolbar
          Images = dmImages.il16x16
          object TBItem5: TTBItem
            Action = actShowObject
          end
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 320
        inherited sbSearchDetail: TScrollBox
          Height = 293
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 657
        Height = 320
        Align = alLeft
      end
      object Panel1: TPanel
        Left = 823
        Top = 26
        Width = 233
        Height = 320
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 3
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 233
          Height = 21
          Align = alTop
          Caption = 'Зависит от объектов:'
          TabOrder = 0
        end
        object gsIBGrid1: TgsIBGrid
          Left = 0
          Top = 21
          Width = 233
          Height = 299
          Align = alClient
          BorderStyle = bsNone
          DataSource = dsObjects
          Options = [dgTabs, dgConfirmDelete, dgCancelOnExit]
          ParentFont = False
          ReadOnly = True
          TabOrder = 1
          TableFont.Charset = DEFAULT_CHARSET
          TableFont.Color = clWindowText
          TableFont.Height = -11
          TableFont.Name = 'Courier New'
          TableFont.Style = []
          SelectedFont.Charset = DEFAULT_CHARSET
          SelectedFont.Color = clHighlightText
          SelectedFont.Height = -11
          SelectedFont.Name = 'Tahoma'
          SelectedFont.Style = []
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
          Striped = False
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          TitlesExpanding = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.FirstColumn = False
          ScaleColumns = True
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
        end
      end
    end
  end
  inherited alMain: TActionList
    object actSetObjectPos: TAction
      Caption = 'Установить очередность объектов'
      Hint = 'Установить очередность объектов'
      ImageIndex = 206
      OnExecute = actSetObjectPosExecute
      OnUpdate = actSetObjectPosUpdate
    end
    object actCompareWithData: TAction
      Caption = 'Сравнить с файлом'
      Hint = 'Сравнить с файлом'
      ImageIndex = 131
      OnExecute = actCompareWithDataExecute
      OnUpdate = actCompareWithDataUpdate
    end
    object actShowDuplicates: TAction
      Caption = 'Показать дубликаты'
      Hint = 'Показать дубликаты'
      ImageIndex = 100
      OnExecute = actShowDuplicatesExecute
      OnUpdate = actShowDuplicatesUpdate
    end
    object actShowRecursion: TAction
      Caption = 'Показать рекурсивные зависимости'
      Hint = 'Показать рекурсивные зависимости'
      ImageIndex = 203
      OnExecute = actShowRecursionExecute
      OnUpdate = actShowRecursionUpdate
    end
    object actNSObjects: TAction
      Caption = 'Список объектов'
      Hint = 'Список объектов'
      ImageIndex = 181
      OnExecute = actNSObjectsExecute
      OnUpdate = actNSObjectsUpdate
    end
    object actShowObject: TAction
      Category = 'Detail'
      Caption = 'Открыть объект'
      Hint = 'Открыть объект'
      ImageIndex = 131
      OnExecute = actShowObjectExecute
      OnUpdate = actShowObjectUpdate
    end
    object actViewNS: TAction
      Caption = 'Показать файлы пространств имен'
      Hint = 'Показать файлы пространств имен'
      ImageIndex = 80
      OnExecute = actViewNSExecute
    end
  end
  object gdcNamespace: TgdcNamespace
    Left = 425
    Top = 129
  end
  object gdcNamespaceObject: TgdcNamespaceObject
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'namespacekey'
    SubSet = 'ByNamespace'
    Left = 337
    Top = 161
  end
  object ibdsObjects: TIBDataSet
    SelectSQL.Strings = (
      'WITH RECURSIVE'
      '  group_tree AS ('
      '    SELECT id, headobjectkey, objectname,'
      '      CAST('#39#39' AS VARCHAR(255)) AS indent'
      '    FROM at_object'
      '    WHERE id = :id'
      ''
      '    UNION ALL'
      ''
      '    SELECT g.id, g.headobjectkey, g.objectname,'
      '      h.indent || rpad('#39#39', 4)'
      '    FROM at_object g JOIN group_tree h'
      '    ON g.headobjectkey = h.id'
      ')'
      'SELECT'
      '  gt.indent || gt.objectname'
      'FROM'
      '  group_tree gt')
    DataSource = dsDetail
    Left = 521
    Top = 384
  end
  object dsObjects: TDataSource
    DataSet = ibdsObjects
    Left = 560
    Top = 384
  end
end
