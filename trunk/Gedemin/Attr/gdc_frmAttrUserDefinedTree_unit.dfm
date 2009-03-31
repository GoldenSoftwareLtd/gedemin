inherited gdc_frmAttrUserDefinedTree: Tgdc_frmAttrUserDefinedTree
  Left = 360
  Top = 167
  Width = 607
  Height = 467
  Caption = 'Таблица пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 421
    Width = 599
  end
  inherited TBDockTop: TTBDock
    Width = 599
  end
  inherited TBDockLeft: TTBDock
    Height = 363
  end
  inherited TBDockRight: TTBDock
    Left = 590
    Height = 363
  end
  inherited TBDockBottom: TTBDock
    Top = 412
    Width = 599
  end
  inherited pnlWorkArea: TPanel
    Width = 581
    Height = 363
    inherited sMasterDetail: TSplitter
      Height = 261
    end
    inherited spChoose: TSplitter
      Top = 261
      Width = 581
    end
    inherited pnlMain: TPanel
      Height = 261
      inherited pnlSearchMain: TPanel
        Height = 261
        inherited sbSearchMain: TScrollBox
          Height = 223
        end
        inherited pnlSearchMainButton: TPanel
          Top = 223
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 261
        DisplayField = ''
        ReadOnly = True
        StateImages = nil
        MainFolder = False
        WithCheckBox = False
      end
    end
    inherited pnChoose: TPanel
      Top = 264
      Width = 581
      inherited pnButtonChoose: TPanel
        Left = 476
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 476
      end
    end
    inherited pnlDetail: TPanel
      Width = 377
      Height = 261
      inherited TBDockDetail: TTBDock
        Width = 377
      end
      inherited pnlSearchDetail: TPanel
        Height = 235
        inherited sbSearchDetail: TScrollBox
          Height = 197
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 197
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 217
        Height = 235
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
  object Master: TgdcAttrUserDefinedTree
    Left = 113
    Top = 174
  end
  object Detail: TgdcAttrUserDefinedTree
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'PARENT'
    Left = 436
    Top = 269
  end
end
