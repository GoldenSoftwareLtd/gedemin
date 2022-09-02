inherited gdc_ab_frmmain: Tgdc_ab_frmmain
  Left = 680
  Top = 207
  Width = 785
  Height = 405
  HelpContext = 31
  Caption = '�������� �����'
  OnCloseQuery = nil
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 355
    Width = 777
  end
  inherited TBDockTop: TTBDock
    Width = 777
    inherited tbMainCustom: TTBToolbar
      Left = 342
      DockPos = 317
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 295
  end
  inherited TBDockRight: TTBDock
    Left = 768
    Height = 295
  end
  inherited TBDockBottom: TTBDock
    Top = 346
    Width = 777
  end
  inherited pnlWorkArea: TPanel
    Width = 759
    Height = 295
    inherited sMasterDetail: TSplitter
      Left = 168
      Height = 190
    end
    inherited spChoose: TSplitter
      Top = 190
      Width = 759
    end
    inherited pnlMain: TPanel
      Width = 168
      Height = 190
      inherited pnlSearchMain: TPanel
        Height = 190
        inherited sbSearchMain: TScrollBox
          Height = 163
        end
      end
      inherited tvGroup: TgsDBTreeView
        Width = 8
        Height = 190
        ImageField = 'contacttype'
        ImageValueList.Strings = (
          '0=0'
          '1=1')
        Images = ilSmall
        RowSelect = True
      end
    end
    inherited pnChoose: TPanel
      Top = 196
      Width = 759
      inherited pnButtonChoose: TPanel
        Left = 654
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 654
      end
      inherited pnlChooseCaption: TPanel
        Width = 759
      end
    end
    inherited pnlDetail: TPanel
      Left = 174
      Width = 585
      Height = 190
      inherited TBDockDetail: TTBDock
        Width = 585
        inherited tbDetailToolbar: TTBToolbar
          object TBSubmenuItem2: TTBSubmenuItem [0]
            Action = actAddCompany
            DropdownCombo = True
            object TBItem4: TTBItem
              Action = actAddContact
            end
            object TBSeparatorItem2: TTBSeparatorItem
            end
            object TBItem3: TTBItem
              Action = actAddCompany
            end
            object TBItem5: TTBItem
              Action = actAddBank
            end
            object TBSeparatorItem3: TTBSeparatorItem
            end
            object TBItem2: TTBItem
              Action = actAddEmployee
            end
            object TBSeparatorItem4: TTBSeparatorItem
            end
            object TBItem1: TTBItem
              Action = actAddGroup
            end
          end
          inherited tbiDetailNew: TTBItem
            Visible = False
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 286
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 164
        inherited sbSearchDetail: TScrollBox
          Height = 137
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 425
        Height = 164
        Expands = <
          item
            LineCount = 1
            Options = []
          end>
        Columns = <
          item
            Alignment = taLeftJustify
            Expanded = False
            PickList.Strings = ()
            Width = 64
            Visible = True
          end>
      end
    end
  end
  inherited alMain: TActionList
    Left = 30
    Top = 115
    inherited actPrint: TAction
      Enabled = False
      Visible = False
    end
    inherited actDetailEdit: TAction
      Caption = '��������'
    end
    object actAddContact: TAction [21]
      Caption = '�������� �������'
      OnExecute = actAddContactExecute
    end
    object actAddBank: TAction [22]
      Caption = '�������� ����'
      OnExecute = actAddBankExecute
    end
    object actAddCompany: TAction [23]
      Caption = '�������� ��������'
      ImageIndex = 0
      OnExecute = actAddCompanyExecute
    end
    object actAddGroup: TAction [24]
      Caption = '�������� ������'
      ImageIndex = 3
      OnExecute = actAddGroupExecute
    end
    object actAddFolder: TAction [25]
      Caption = '�������� �����'
      ImageIndex = 0
      OnExecute = actAddFolderExecute
    end
    object actAddEmployee: TAction
      Caption = '�������� ����������'
      ImageIndex = 0
      OnExecute = actAddEmployeeExecute
    end
  end
  inherited pmMain: TPopupMenu
    Left = 120
    Top = 115
  end
  inherited dsMain: TDataSource
    DataSet = gdcFolder
    Left = 60
    Top = 115
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Top = 119
  end
  inherited dsDetail: TDataSource
    DataSet = gdcContacts
    Left = 405
    Top = 230
  end
  inherited pmDetail: TPopupMenu
    Left = 435
    Top = 230
    inherited nDetailNew: TMenuItem
      Action = nil
      Caption = '��������'
      ShortCut = 0
      OnClick = nil
      object nAddCompany2: TMenuItem
        Action = actAddCompany
      end
      object nAddContact2: TMenuItem
        Action = actAddContact
      end
      object nAddBank2: TMenuItem
        Action = actAddBank
      end
    end
  end
  object gdcContacts: TgdcBaseContact
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'RootID'
    SubSet = 'ByRootID,Contacts'
    Left = 375
    Top = 230
  end
  object ilSmall: TImageList
    Left = 150
    Top = 115
    Bitmap = {
      494C010102000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F6F6F600DFDFDF00D6D6
      D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6D600D6D6
      D600D6D6D600D6D6D600DFDFDF00F6F6F60084848400C6C6C600C6C6C600C6C6
      C600848484000000000000000000C6C6C600C6C6C60084848400000000000000
      0000C6C6C600C6C6C600C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F6F6F600C8C8C800838383006D6D
      6D006D6D6D006D6D6D006D6D6D006D6D6D006D6D6D006D6D6D006D6D6D006D6D
      6D006D6D6D006D6D6D0083838300C8C8C800FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      00000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000DFDFDF001D82B5001B81B300187E
      B000167CAE001379AB001076A8000D73A5000B71A300086EA000066C9E00046A
      9C0002689A00016799004C4C4C008383830000000000FF000000FF0000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      00000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000002287BA0067CCFF002085B80099FF
      FF006FD4FF006FD4FF006FD4FF006FD4FF006FD4FF006FD4FF006FD4FF006FD4
      FF003BA0D30099FFFF00016799006E6E6E00848484000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000008400000084
      00000084000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000258ABD0067CCFF00278CBF0099FF
      FF007BE0FF007BE0FF007BE0FF007BE0FF007BE0FF007BE0FF007BE0FF007BE0
      FF0044A9DC0099FFFF0002689A006D6D6D008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000288DC00067CCFF002D92C50099FF
      FF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EB
      FF004EB3E60099FFFF00046A9C006D6D6D00848484000000000000000000C6C6
      C60000000000C6C6C60000000000000000000000000000000000008400000084
      00000084000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000002A8FC20067CCFF003398CB0099FF
      FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7
      FF0057BCEF0099FFFF00066C9E006D6D6D008484840000000000000000000000
      0000C6C6C60000000000C6C6C60000000000C6C6C600C6C6C600000000000000
      00000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000002D92C5006FD4FF003499CC0099FF
      FF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FF
      FF0060C5F80099FFFF00086EA0006E6E6E000000000000000000000000000000
      000000000000C6C6C60000000000C6C6C60000000000C6C6C600000000000000
      00000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000002F94C7007BE0FF002D92C5000000
      0000000000000000000000000000000000000000000000000000000000000000
      000081E6FF00000000000B71A3008C8C8C000000000000000000000000000000
      0000C6C6C600000000008400000000000000C6C6C600C6C6C600C6C6C6000000
      00000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003196C90085EBFF0081E6FF002D92
      C5002D92C5002D92C5002D92C5002D92C5002D92C500288DC0002489BC002085
      B8001C81B4001B81B3001B81B300DFDFDF000000000000000000000000000000
      000000000000C6C6C60000000000000000000000000084000000000000000000
      00000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003398CB0091F7FF008EF4FF008EF4
      FF008EF4FF008EF4FF008EF4FF00000000000000000000000000000000000000
      0000167CAE008C8C8C00DEDEDE00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600000000008484
      8400848484008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003499CC000000000099FFFF0099FF
      FF0099FFFF0099FFFF0000000000258ABD002287BA001F84B7001D82B5001B81
      B300187EB000DFDFDF00F7F7F700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000003499CC00000000000000
      000000000000000000002A8FC200C8C8C800F6F6F60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000003499CC003398
      CB003196C9002F94C700DFDFDF00F6F6F6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF0420000000008000042000000000
      0000000C000000000000001C0000000000000804000000000000507C00000000
      00004A04000000000000141C0000000000000A1C000000001FF4140C00000000
      00000A1C0000000001F10001000000004201800F00000000BC7FC01F00000000
      C0FFF83F00000000FFFFFFFF0000000000000000000000000000000000000000
      000000000000}
  end
  object gdcFolder: TgdcFolder
    Left = 89
    Top = 115
  end
end
