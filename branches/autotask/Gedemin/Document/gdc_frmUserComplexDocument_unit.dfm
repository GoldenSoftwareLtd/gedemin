inherited gdc_frmUserComplexDocument: Tgdc_frmUserComplexDocument
  Left = 227
  Top = 166
  Width = 783
  Height = 540
  Caption = 'gdc_frmUserComplexDocument'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 483
    Width = 767
  end
  inherited TBDockTop: TTBDock
    Width = 767
    inherited tbMainInvariant: TTBToolbar
      object TBItem1: TTBItem
        Action = actCreateEntry
      end
      object TBItem3: TTBItem
        Action = actMainGotoEntry
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 423
  end
  inherited TBDockRight: TTBDock
    Left = 758
    Height = 423
  end
  inherited TBDockBottom: TTBDock
    Top = 474
    Width = 767
  end
  inherited pnlWorkArea: TPanel
    Width = 749
    Height = 423
    inherited sMasterDetail: TSplitter
      Width = 749
    end
    inherited spChoose: TSplitter
      Top = 318
      Width = 749
    end
    inherited pnlMain: TPanel
      Width = 749
      inherited ibgrMain: TgsIBGrid
        Width = 589
      end
    end
    inherited pnChoose: TPanel
      Top = 324
      Width = 749
      inherited pnButtonChoose: TPanel
        Left = 644
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 644
      end
      inherited pnlChooseCaption: TPanel
        Width = 749
      end
    end
    inherited pnlDetail: TPanel
      Width = 749
      Height = 145
      inherited TBDockDetail: TTBDock
        Width = 749
        inherited tbDetailToolbar: TTBToolbar
          object TBItem2: TTBItem
            Action = actGotoEntry
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 309
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 119
        inherited sbSearchDetail: TScrollBox
          Height = 92
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 589
        Height = 119
      end
    end
  end
  inherited alMain: TActionList
    object actCreateEntry: TAction
      Category = 'Commands'
      Caption = 'Провести проводки'
      Hint = 'Провести проводки по документам'
      ImageIndex = 104
      OnExecute = actCreateEntryExecute
      OnUpdate = actCreateEntryUpdate
    end
    object actGotoEntry: TAction
      Category = 'Detail'
      Caption = 'Перейти на проводку'
      Hint = 'Перейти на проводку'
      ImageIndex = 53
      OnExecute = actGotoEntryExecute
    end
    object actMainGotoEntry: TAction
      Category = 'Main'
      Caption = 'Перейти на проводку'
      Hint = 'Перейти на проводку по шапке документа'
      ImageIndex = 53
      OnExecute = actMainGotoEntryExecute
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcUserDocument
  end
  inherited dsDetail: TDataSource
    DataSet = gdcUserDocumentLine
  end
  object gdcUserDocumentLine: TgdcUserDocumentLine
    MasterSource = dsMain
    MasterField = 'documentkey'
    DetailField = 'parent'
    SubSet = 'ByParent'
    Left = 409
    Top = 332
  end
  object gdcUserDocument: TgdcUserDocument
    Left = 177
    Top = 145
  end
end
