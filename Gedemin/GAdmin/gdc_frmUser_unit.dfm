inherited gdc_frmUser: Tgdc_frmUser
  Left = 237
  Top = 197
  Width = 749
  Height = 392
  HelpContext = 53
  Caption = 'Пользователи системы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 335
    Width = 733
  end
  inherited TBDockTop: TTBDock
    Width = 733
    inherited tbMainCustom: TTBToolbar
      Left = 483
      Visible = True
      object TBControlItem1: TTBControlItem
        Control = chbxAllGroups
      end
      object TBControlItem2: TTBControlItem
        Control = ibcbUserGroup
      end
      object TBSeparatorItem3: TTBSeparatorItem
      end
      object TBItem3: TTBItem
        Action = actUserGroups
      end
      object TBItem4: TTBItem
        Action = actRecreateAllUsers
      end
      object chbxAllGroups: TCheckBox
        Left = 0
        Top = 0
        Width = 41
        Height = 21
        Caption = 'Все'
        TabOrder = 0
        OnClick = chbxAllGroupsClick
      end
      object ibcbUserGroup: TgsIBLookupComboBox
        Left = 41
        Top = 0
        Width = 147
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'gd_usergroup'
        ListField = 'name'
        KeyField = 'ID'
        gdClassName = 'TgdcUserGroup'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = ibcbUserGroupChange
      end
    end
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuObject: TTBSubmenuItem
        object tbiUsersGroups: TTBItem [22]
          Action = actUserGroups
        end
        object tbiRecreateAllUsers: TTBItem [23]
          Action = actRecreateAllUsers
        end
        object tbi_mm_sep5_2: TTBSeparatorItem [24]
        end
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 450
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 275
  end
  inherited TBDockRight: TTBDock
    Left = 724
    Height = 275
  end
  inherited TBDockBottom: TTBDock
    Top = 326
    Width = 733
  end
  inherited pnlWorkArea: TPanel
    Width = 715
    Height = 275
    inherited spChoose: TSplitter
      Top = 172
      Width = 715
    end
    inherited pnlMain: TPanel
      Width = 715
      Height = 172
      inherited pnlSearchMain: TPanel
        Height = 172
        inherited sbSearchMain: TScrollBox
          Height = 134
        end
        inherited pnlSearchMainButton: TPanel
          Top = 134
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 555
        Height = 172
        ColumnEditors = <
          item
            Lookup.LookupListField = 'name'
            Lookup.LookupKeyField = 'id'
            Lookup.LookupTable = 'gd_contact'
            Lookup.gdClassName = 'TgdcContact'
            Lookup.Distinct = False
            EditorStyle = cesLookup
            FieldName = 'CONTACTKEY'
            DisplayField = 'CONTACTNAME'
            ValueList.Strings = ()
            DropDownCount = 8
          end>
      end
    end
    inherited pnChoose: TPanel
      Top = 176
      Width = 715
      inherited pnButtonChoose: TPanel
        Left = 610
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 610
      end
      inherited pnlChooseCaption: TPanel
        Width = 715
      end
    end
  end
  inherited alMain: TActionList
    object actUserGroups: TAction [15]
      Caption = 'Группы пользователя...'
      Hint = 'Группы пользователя'
      ImageIndex = 35
      OnExecute = actUserGroupsExecute
      OnUpdate = actEditUpdate
    end
    object actRecreateAllUsers: TAction [16]
      Caption = 'Пересоздать всех пользователей'
      Hint = 'Пересоздать всех пользователей'
      ImageIndex = 33
      OnExecute = actRecreateAllUsersExecute
      OnUpdate = actRecreateAllUsersUpdate
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcUser
  end
  object gdcUser: TgdcUser
    Left = 48
    Top = 108
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 440
    Top = 40
  end
end
