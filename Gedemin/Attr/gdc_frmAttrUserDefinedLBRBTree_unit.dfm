inherited gdc_frmAttrUserDefinedLBRBTree: Tgdc_frmAttrUserDefinedLBRBTree
  Left = 241
  Top = 106
  Width = 607
  Height = 467
  Caption = 'Таблица пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 417
    Width = 599
  end
  inherited TBDockTop: TTBDock
    Width = 599
  end
  inherited TBDockLeft: TTBDock
    Height = 357
  end
  inherited TBDockRight: TTBDock
    Left = 590
    Height = 357
  end
  inherited TBDockBottom: TTBDock
    Top = 408
    Width = 599
  end
  inherited pnlWorkArea: TPanel
    Width = 581
    Height = 357
    inherited sMasterDetail: TSplitter
      Height = 252
    end
    inherited spChoose: TSplitter
      Top = 252
      Width = 581
    end
    inherited pnlMain: TPanel
      Height = 252
      inherited pnlSearchMain: TPanel
        Height = 252
        inherited sbSearchMain: TScrollBox
          Height = 225
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 252
        DisplayField = ''
        ReadOnly = True
        StateImages = nil
        MainFolder = False
        WithCheckBox = False
      end
    end
    inherited pnChoose: TPanel
      Top = 258
      Width = 581
      inherited pnButtonChoose: TPanel
        Left = 476
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 476
      end
      inherited pnlChooseCaption: TPanel
        Width = 581
      end
    end
    inherited pnlDetail: TPanel
      Width = 409
      Height = 252
      inherited TBDockDetail: TTBDock
        Width = 409
      end
      inherited pnlSearchDetail: TPanel
        Height = 226
        inherited sbSearchDetail: TScrollBox
          Height = 199
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 249
        Height = 226
      end
    end
  end
  inherited pmMain: TPopupMenu
    Left = 113
    Top = 145
  end
  inherited dsMain: TDataSource
    DataSet = Master
    Top = 174
  end
  inherited dsDetail: TDataSource
    DataSet = Detail
    Left = 436
    Top = 240
  end
  inherited pmDetail: TPopupMenu
    Left = 465
    Top = 269
  end
  object Master: TgdcAttrUserDefinedLBRBTree
    Left = 113
    Top = 174
  end
  object Detail: TgdcAttrUserDefinedLBRBTree
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 436
    Top = 269
  end
end
