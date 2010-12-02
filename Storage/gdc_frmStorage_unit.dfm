inherited gdc_frmStorage: Tgdc_frmStorage
  Left = 252
  Top = 176
  Width = 870
  Height = 640
  Caption = 'gdc_frmStorage'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 594
    Width = 862
  end
  inherited TBDockTop: TTBDock
    Width = 862
    inherited tbMainCustom: TTBToolbar
      Left = 508
      object TBControlItem2: TTBControlItem
        Control = lblStorage
      end
      object TBControlItem1: TTBControlItem
        Control = lkupStorage
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object TBItem1: TTBItem
        Action = actDeleteUnused
        Hint = 
          'Хранилища компаний или пользователей, которые были удалены из ба' +
          'зы данных.'
      end
      object lblStorage: TLabel
        Left = 0
        Top = 4
        Width = 99
        Height = 13
        Caption = 'Выбор хранилища: '
      end
      object lkupStorage: TgsIBLookupComboBox
        Left = 99
        Top = 0
        Width = 145
        Height = 21
        HelpContext = 1
        ListTable = 'GD_STORAGE_DATA'
        ListField = 'NAME'
        KeyField = 'ID'
        SortOrder = soAsc
        Condition = 'data_type IN ('#39'G'#39', '#39'U'#39', '#39'O'#39', '#39'T'#39') AND parent IS NULL'
        OnCreateNewObject = lkupStorageCreateNewObject
        ItemHeight = 13
        TabOrder = 0
        OnChange = lkupStorageChange
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 536
  end
  inherited TBDockRight: TTBDock
    Left = 853
    Height = 536
  end
  inherited TBDockBottom: TTBDock
    Top = 585
    Width = 862
  end
  inherited pnlWorkArea: TPanel
    Width = 844
    Height = 536
    inherited sMasterDetail: TSplitter
      Height = 433
    end
    inherited spChoose: TSplitter
      Top = 433
      Width = 844
    end
    inherited pnlMain: TPanel
      Height = 433
      inherited pnlSearchMain: TPanel
        Height = 433
        inherited sbSearchMain: TScrollBox
          Height = 395
        end
        inherited pnlSearchMainButton: TPanel
          Top = 395
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 433
        Font.Style = [fsBold]
        Images = dmImages.il16x16
        ParentFont = False
        StateImages = nil
        MainFolderHead = False
        MainFolder = False
        WithCheckBox = False
      end
    end
    inherited pnChoose: TPanel
      Top = 437
      Width = 844
      inherited pnButtonChoose: TPanel
        Left = 739
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 739
      end
      inherited pnlChooseCaption: TPanel
        Width = 844
      end
    end
    inherited pnlDetail: TPanel
      Width = 674
      Height = 433
      inherited TBDockDetail: TTBDock
        Width = 674
      end
      inherited pnlSearchDetail: TPanel
        Height = 407
        inherited sbSearchDetail: TScrollBox
          Height = 369
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 369
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 514
        Height = 407
      end
    end
  end
  inherited alMain: TActionList
    object actDeleteUnused: TAction
      Caption = 'actDeleteUnused'
      OnExecute = actDeleteUnusedExecute
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcStorageFolder
  end
  inherited dsDetail: TDataSource
    DataSet = gdcStorageValue
  end
  object gdcStorageFolder: TgdcStorageFolder
    SubSet = 'ByRootIDInc'
    Left = 240
    Top = 328
  end
  object gdcStorageValue: TgdcStorageValue
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'PARENT'
    SubSet = 'ByParent'
    Left = 464
    Top = 184
  end
end
