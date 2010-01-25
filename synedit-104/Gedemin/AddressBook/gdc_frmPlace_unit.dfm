inherited gdc_frmPlace: Tgdc_frmPlace
  Left = 233
  Top = 148
  Width = 702
  Height = 561
  Caption = 'Населенные пункты'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 506
    Width = 694
  end
  inherited TBDockTop: TTBDock
    Width = 694
  end
  inherited TBDockLeft: TTBDock
    Height = 457
  end
  inherited TBDockRight: TTBDock
    Left = 685
    Height = 457
  end
  inherited TBDockBottom: TTBDock
    Top = 525
    Width = 694
  end
  inherited pnlWorkArea: TPanel
    Width = 676
    Height = 457
    inherited sMasterDetail: TSplitter
      Left = 328
      Height = 355
    end
    inherited spChoose: TSplitter
      Top = 355
      Width = 676
    end
    inherited pnlMain: TPanel
      Width = 328
      Height = 355
      inherited pnlSearchMain: TPanel
        Height = 355
        inherited sbSearchMain: TScrollBox
          Height = 317
        end
        inherited pnlSearchMainButton: TPanel
          Top = 317
        end
      end
      inherited tvGroup: TgsDBTreeView
        Width = 168
        Height = 355
        MainFolderHead = False
        MainFolder = False
      end
    end
    inherited pnChoose: TPanel
      Top = 358
      Width = 676
      inherited pnButtonChoose: TPanel
        Left = 571
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 571
      end
    end
    inherited pnlDetail: TPanel
      Left = 332
      Width = 344
      Height = 355
      inherited TBDockDetail: TTBDock
        Width = 344
      end
      inherited pnlSearchDetail: TPanel
        Height = 329
        inherited sbSearchDetail: TScrollBox
          Height = 291
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 291
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 184
        Height = 329
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
