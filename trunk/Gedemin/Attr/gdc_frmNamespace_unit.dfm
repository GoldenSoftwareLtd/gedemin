inherited gdc_frmNamespace: Tgdc_frmNamespace
  Left = 326
  Top = 220
  Width = 1090
  Height = 742
  Caption = 'Пространство имен'
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 685
    Width = 1074
  end
  inherited TBDockTop: TTBDock
    Width = 1074
    inherited tbMainCustom: TTBToolbar
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
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 625
  end
  inherited TBDockRight: TTBDock
    Left = 1065
    Height = 625
  end
  inherited TBDockBottom: TTBDock
    Top = 676
    Width = 1074
  end
  inherited pnlWorkArea: TPanel
    Width = 1056
    Height = 625
    inherited sMasterDetail: TSplitter
      Width = 1056
    end
    inherited spChoose: TSplitter
      Top = 520
      Width = 1056
    end
    inherited pnlMain: TPanel
      Width = 1056
      inherited ibgrMain: TgsIBGrid
        Width = 896
      end
    end
    inherited pnChoose: TPanel
      Top = 526
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
      Height = 347
      inherited TBDockDetail: TTBDock
        Width = 1056
      end
      inherited pnlSearchDetail: TPanel
        Height = 321
        inherited sbSearchDetail: TScrollBox
          Height = 283
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 283
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 896
        Height = 321
      end
    end
  end
  inherited alMain: TActionList
    object actSetObjectPos: TAction
      Caption = 'actSetObjectPos'
      OnExecute = actSetObjectPosExecute
      OnUpdate = actSetObjectPosUpdate
    end
    object actCompareWithData: TAction
      Caption = 'actCompareWithData'
      OnExecute = actCompareWithDataExecute
      OnUpdate = actCompareWithDataUpdate
    end
    object actShowDuplicates: TAction
      Caption = 'actShowDuplicates'
      OnExecute = actShowDuplicatesExecute
      OnUpdate = actShowDuplicatesUpdate
    end
    object actShowRecursion: TAction
      Caption = 'actShowRecursion'
      OnExecute = actShowRecursionExecute
      OnUpdate = actShowRecursionUpdate
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
