inherited gdc_frmUserComplexDocument: Tgdc_frmUserComplexDocument
  Left = 227
  Top = 166
  Width = 783
  Height = 540
  Caption = 'gdc_frmUserComplexDocument'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 494
    Width = 775
  end
  inherited TBDockTop: TTBDock
    Width = 775
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
    Height = 436
  end
  inherited TBDockRight: TTBDock
    Left = 766
    Height = 436
  end
  inherited TBDockBottom: TTBDock
    Top = 485
    Width = 775
  end
  inherited pnlWorkArea: TPanel
    Width = 757
    Height = 436
    inherited sMasterDetail: TSplitter
      Width = 757
    end
    inherited spChoose: TSplitter
      Top = 333
      Width = 757
    end
    inherited pnlMain: TPanel
      Width = 757
      inherited ibgrMain: TgsIBGrid
        Width = 597
      end
    end
    inherited pnChoose: TPanel
      Top = 337
      Width = 757
      inherited pnButtonChoose: TPanel
        Left = 652
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 652
      end
      inherited pnlChooseCaption: TPanel
        Width = 757
      end
    end
    inherited pnlDetail: TPanel
      Width = 757
      Height = 162
      inherited TBDockDetail: TTBDock
        Width = 757
        inherited tbDetailToolbar: TTBToolbar
          object TBItem2: TTBItem
            Action = actGotoEntry
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 298
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 136
        inherited sbSearchDetail: TScrollBox
          Height = 98
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 98
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 597
        Height = 136
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
