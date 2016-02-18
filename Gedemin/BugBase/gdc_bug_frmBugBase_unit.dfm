inherited gdc_bug_frmBugBase: Tgdc_bug_frmBugBase
  Left = 267
  Top = 126
  Width = 696
  Height = 480
  Caption = 'gdc_bug_frmBugBase'
  Font.Name = 'Tahoma'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 425
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
    inherited tbMainCustom: TTBToolbar
      Left = 366
      DockPos = 328
      object tbiUpdateBugRecord: TTBItem
        Action = actUpdateBugRecord
      end
      object TBControlItem1: TTBControlItem
        Control = DBComboBox1
      end
      object DBComboBox1: TDBComboBox
        Left = 23
        Top = 0
        Width = 42
        Height = 21
        DataField = 'PRIORITY'
        DataSource = dsMain
        ItemHeight = 13
        Items.Strings = (
          '1'
          '2'
          '3'
          '4'
          '5')
        TabOrder = 0
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 376
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 376
  end
  inherited TBDockBottom: TTBDock
    Top = 444
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 376
    inherited spChoose: TSplitter
      Top = 273
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      Height = 273
      inherited pnlSearchMain: TPanel
        Height = 273
        inherited sbSearchMain: TScrollBox
          Height = 235
        end
        inherited pnlSearchMainButton: TPanel
          Top = 235
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 273
      end
    end
    inherited pnChoose: TPanel
      Top = 277
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
      inherited pnlChooseCaption: TPanel
        Width = 670
      end
    end
  end
  inherited alMain: TActionList
    Top = 96
    object actUpdateBugRecord: TAction
      Category = 'BugBase'
      Caption = 'Изменить статус'
      ImageIndex = 61
      ShortCut = 16469
      OnExecute = actUpdateBugRecordExecute
      OnUpdate = actEditUpdate
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcBugBase
  end
  object gdcBugBase: TgdcBugBase
    Left = 89
    Top = 153
  end
end
