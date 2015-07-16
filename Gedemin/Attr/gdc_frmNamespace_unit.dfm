inherited gdc_frmNamespace: Tgdc_frmNamespace
  Left = 622
  Top = 190
  Width = 1090
  Height = 742
  Caption = 'Пространства имен'
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 692
    Width = 1082
  end
  inherited TBDockTop: TTBDock
    Width = 1082
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
    Height = 632
  end
  inherited TBDockRight: TTBDock
    Left = 1073
    Height = 632
  end
  inherited TBDockBottom: TTBDock
    Top = 683
    Width = 1082
  end
  inherited pnlWorkArea: TPanel
    Width = 1064
    Height = 632
    inherited sMasterDetail: TSplitter
      Width = 1064
    end
    inherited spChoose: TSplitter
      Top = 527
      Width = 1064
    end
    inherited pnlMain: TPanel
      Width = 1064
      inherited ibgrMain: TgsIBGrid
        Width = 904
      end
    end
    inherited pnChoose: TPanel
      Top = 533
      Width = 1064
      inherited pnButtonChoose: TPanel
        Left = 959
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 959
      end
      inherited pnlChooseCaption: TPanel
        Width = 1064
      end
    end
    inherited pnlDetail: TPanel
      Width = 1064
      Height = 354
      inherited TBDockDetail: TTBDock
        Width = 1064
        inherited tbDetailCustom: TTBToolbar
          Images = dmImages.il16x16
          object TBItem5: TTBItem
            Action = actShowObject
          end
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 328
        inherited sbSearchDetail: TScrollBox
          Height = 301
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 904
        Height = 328
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
end
