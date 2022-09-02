inherited gdc_dlgAddUserToGroup: Tgdc_dlgAddUserToGroup
  Left = 523
  Top = 242
  HelpContext = 56
  Caption = 'Группы пользователя'
  ClientHeight = 366
  ClientWidth = 343
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 268
    Top = 216
    Width = 35
    Height = 13
    Caption = 'Маска:'
  end
  object Label2: TLabel [1]
    Left = 268
    Top = 232
    Width = 3
    Height = 13
  end
  inherited btnAccess: TButton
    Left = 266
    Top = 141
    Enabled = False
    TabOrder = 6
    Visible = False
  end
  inherited btnNew: TButton
    Left = 266
    Top = 173
    Enabled = False
    TabOrder = 7
    Visible = False
  end
  inherited btnHelp: TButton
    Left = 265
    Top = 77
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 265
    Top = 13
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 265
    Top = 40
    TabOrder = 4
  end
  object gbGroups: TGroupBox [7]
    Left = 8
    Top = 56
    Width = 249
    Height = 217
    Caption = ' Входит в группы '
    TabOrder = 1
    object ibgrUserGroups: TgsIBGrid
      Left = 8
      Top = 17
      Width = 233
      Height = 120
      HelpContext = 3
      DataSource = dsUserGroup
      Options = [dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 0
      InternalMenuKind = imkNone
      Expands = <>
      ExpandsActive = False
      ExpandsSeparate = False
      TitlesExpanding = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.Visible = False
      CheckBox.FirstColumn = False
      MinColWidth = 40
      SaveSettings = False
      ColumnEditors = <>
      Aliases = <>
      ShowTotals = False
      Columns = <
        item
          Alignment = taLeftJustify
          Expanded = False
          FieldName = 'NAME'
          Title.Caption = 'NAME'
          Width = 124
          Visible = True
        end
        item
          Alignment = taRightJustify
          Expanded = False
          FieldName = 'ID'
          Title.Caption = 'ID'
          Width = -1
          Visible = False
        end>
    end
    object Memo1: TMemo
      Left = 8
      Top = 144
      Width = 233
      Height = 41
      BorderStyle = bsNone
      Color = clBtnFace
      Lines.Strings = (
        'Для исключения пользователя из группы '
        'выберите ее из списка и нажмите кнопку '
        'Исключить.')
      ReadOnly = True
      TabOrder = 2
    end
    object btnExclude: TButton
      Left = 8
      Top = 186
      Width = 75
      Height = 21
      Action = actDeleteGroup
      TabOrder = 1
    end
  end
  object gbInclude: TGroupBox [8]
    Left = 8
    Top = 280
    Width = 249
    Height = 78
    Caption = ' Включить в группу '
    TabOrder = 2
    object ibcbGroups: TgsIBLookupComboBox
      Left = 8
      Top = 20
      Width = 233
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrCommon
      ListTable = 'gd_usergroup'
      ListField = 'name'
      KeyField = 'ID'
      SortOrder = soAsc
      gdClassName = 'TgdcUserGroup'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object btnInclude: TButton
      Left = 8
      Top = 47
      Width = 75
      Height = 21
      Action = actAddGroup
      TabOrder = 1
    end
  end
  object gbUser: TGroupBox [9]
    Left = 8
    Top = 8
    Width = 249
    Height = 41
    Caption = ' Пользователь '
    TabOrder = 0
    object DBText1: TDBText
      Left = 8
      Top = 19
      Width = 41
      Height = 13
      AutoSize = True
      DataField = 'NAME'
      DataSource = dsgdcBase
    end
  end
  inherited alBase: TActionList
    Left = 214
    Top = 295
    object actAddGroup: TAction
      Caption = 'Включить'
      OnExecute = actAddGroupExecute
      OnUpdate = actAddGroupUpdate
    end
    object actDeleteGroup: TAction
      Caption = 'Исключить'
      OnExecute = actDeleteGroupExecute
      OnUpdate = actDeleteGroupUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 184
    Top = 295
  end
  inherited ibtrCommon: TIBTransaction
    Left = 216
    Top = 224
  end
  object gdcUserGroup: TgdcUserGroup
    Transaction = ibtrCommon
    SubSet = 'ByMask'
    ReadTransaction = ibtrCommon
    Left = 184
    Top = 256
  end
  object dsUserGroup: TDataSource
    DataSet = gdcUserGroup
    Left = 216
    Top = 256
  end
end
