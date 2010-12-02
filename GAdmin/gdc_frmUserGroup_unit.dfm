inherited gdc_frmUserGroup: Tgdc_frmUserGroup
  Left = 372
  Top = 445
  Width = 692
  Height = 352
  HelpContext = 54
  Caption = 'Группы пользователей'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 297
    Width = 684
  end
  inherited TBDockTop: TTBDock
    Width = 684
    inherited tbMainCustom: TTBToolbar
      Left = 457
      Visible = True
      object TBControlItem1: TTBControlItem
        Control = chbxAllUsers
      end
      object TBControlItem2: TTBControlItem
        Control = ibcbUser
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem1: TTBItem
        Action = actAddGroupToUser
      end
      object chbxAllUsers: TCheckBox
        Left = 0
        Top = 0
        Width = 43
        Height = 21
        Caption = 'Все'
        TabOrder = 0
        OnClick = chbxAllUsersClick
      end
      object ibcbUser: TgsIBLookupComboBox
        Left = 43
        Top = 0
        Width = 145
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'gd_user'
        ListField = 'name'
        KeyField = 'ID'
        SortOrder = soAsc
        gdClassName = 'TgdcUser'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = ibcbUserChange
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 424
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 248
  end
  inherited TBDockRight: TTBDock
    Left = 675
    Height = 248
  end
  inherited TBDockBottom: TTBDock
    Top = 316
    Width = 684
  end
  inherited pnlWorkArea: TPanel
    Width = 666
    Height = 248
    inherited spChoose: TSplitter
      Top = 145
      Width = 666
    end
    inherited pnlMain: TPanel
      Width = 666
      Height = 145
      inherited pnlSearchMain: TPanel
        Height = 145
        inherited sbSearchMain: TScrollBox
          Height = 107
        end
        inherited pnlSearchMainButton: TPanel
          Top = 107
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 506
        Height = 145
      end
    end
    inherited pnChoose: TPanel
      Top = 149
      Width = 666
      inherited pnButtonChoose: TPanel
        Left = 561
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 561
      end
      inherited pnlChooseCaption: TPanel
        Width = 666
      end
    end
  end
  inherited alMain: TActionList
    object actAddGroupToUser: TAction [15]
      Caption = 'Добавить пользователя в группу...'
      Hint = 'Добавить пользователя в группу'
      ImageIndex = 35
      OnExecute = actAddGroupToUserExecute
      OnUpdate = actAddGroupToUserUpdate
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcUserGroup
  end
  object gdcUserGroup: TgdcUserGroup
    Left = 40
    Top = 107
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 504
    Top = 40
  end
end
