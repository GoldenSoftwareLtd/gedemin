inherited gdc_frmPlace: Tgdc_frmPlace
  Left = 233
  Top = 148
  Width = 702
  Height = 561
  Caption = ''
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 502
    Width = 694
  end
  inherited TBDockTop: TTBDock
    Width = 694
  end
  inherited TBDockLeft: TTBDock
    Height = 451
  end
  inherited TBDockRight: TTBDock
    Left = 685
    Height = 451
  end
  inherited TBDockBottom: TTBDock
    Top = 521
    Width = 694
  end
  inherited pnlWorkArea: TPanel
    Width = 676
    Height = 451
    inherited sMasterDetail: TSplitter
      Left = 328
      Height = 346
    end
    inherited spChoose: TSplitter
      Top = 346
      Width = 676
    end
    inherited pnlMain: TPanel
      Width = 328
      Height = 346
      inherited pnlSearchMain: TPanel
        Height = 346
        inherited sbSearchMain: TScrollBox
          Height = 319
        end
      end
      inherited tvGroup: TgsDBTreeView
        Width = 168
        Height = 346
        MainFolderHead = False
        MainFolder = False
      end
    end
    inherited pnChoose: TPanel
      Top = 352
      Width = 676
      inherited pnButtonChoose: TPanel
        Left = 571
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 571
      end
      inherited pnlChooseCaption: TPanel
        Width = 676
      end
    end
    inherited pnlDetail: TPanel
      Left = 334
      Width = 342
      Height = 346
      inherited TBDockDetail: TTBDock
        Width = 342
      end
      inherited pnlSearchDetail: TPanel
        Height = 320
        inherited sbSearchDetail: TScrollBox
          Height = 293
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 182
        Height = 320
      end
    end
  end
  inherited alMain: TActionList
    Left = 50
    Top = 105
    object actCopyToClipboardDetail2: TAction
      Category = 'Detail'
      Caption = 'actCopyToClipboard'
      ImageIndex = 8
    end
    object actCutToClipboardDetail2: TAction
      Category = 'Detail'
      Caption = 'actCutToClipboardDetail'
      ImageIndex = 7
    end
    object actPasteFromClipboardDetail2: TAction
      Category = 'Detail'
      Caption = 'actPasteFromClipboardDetail'
      ImageIndex = 9
    end
  end
  inherited pmMain: TPopupMenu
    Left = 170
    Top = 105
  end
  inherited dsMain: TDataSource
    DataSet = gdcPlace
    Left = 20
    Top = 105
  end
  inherited dsDetail: TDataSource
    DataSet = gdcPlaceDetail
    Left = 405
    Top = 95
  end
  inherited pmDetail: TPopupMenu
    Left = 480
    Top = 155
  end
  object gdcPlace: TgdcPlace
    Left = 200
    Top = 106
  end
  object gdcPlaceDetail: TgdcPlace
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'parent'
    SubSet = 'ByParent'
    Left = 370
    Top = 95
  end
end
