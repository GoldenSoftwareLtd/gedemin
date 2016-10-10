inherited gdc_dlgAddGroupToUser: Tgdc_dlgAddGroupToUser
  Left = 389
  Top = 148
  HelpContext = 57
  Caption = 'Пользователи группы'
  ClientHeight = 366
  ClientWidth = 343
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 265
    Top = 141
    Enabled = False
    TabOrder = 6
    Visible = False
  end
  inherited btnNew: TButton
    Left = 265
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
  object gbUsers: TGroupBox [5]
    Left = 8
    Top = 56
    Width = 249
    Height = 217
    Caption = ' Содержит пользователей '
    TabOrder = 1
    object ibgrUsers: TgsIBGrid
      Left = 8
      Top = 17
      Width = 233
      Height = 120
      HelpContext = 3
      DataSource = dsUser
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
        'выберите его из списка и нажмите кнопку '
        'Исключить.')
      ReadOnly = True
      TabOrder = 2
    end
    object btnExclude: TButton
      Left = 8
      Top = 186
      Width = 75
      Height = 21
      Action = actDeleteUser
      TabOrder = 1
    end
  end
  object gbInclude: TGroupBox [6]
    Left = 8
    Top = 280
    Width = 249
    Height = 78
    Caption = ' Добавить пользователя  '
    TabOrder = 2
    object ibcbUser: TgsIBLookupComboBox
      Left = 8
      Top = 20
      Width = 233
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrCommon
      ListTable = 'gd_user'
      ListField = 'name'
      KeyField = 'ID'
      SortOrder = soAsc
      gdClassName = 'TgdcUser'
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
      Action = actAddUser
      TabOrder = 1
    end
  end
  object gbGroup: TGroupBox [7]
    Left = 8
    Top = 8
    Width = 249
    Height = 41
    Caption = ' Группа '
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
    object actAddUser: TAction
      Caption = 'Добавить'
      ShortCut = 45
      OnExecute = actAddUserExecute
      OnUpdate = actAddUserUpdate
    end
    object actDeleteUser: TAction
      Caption = 'Исключить'
      ShortCut = 46
      OnExecute = actDeleteUserExecute
      OnUpdate = actDeleteUserUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 184
    Top = 295
  end
  inherited ibtrCommon: TIBTransaction
    Left = 264
    Top = 232
  end
  object dsUser: TDataSource
    DataSet = gdcUser
    Left = 216
    Top = 256
  end
  object gdcUser: TgdcUser
    SubSet = 'ByUserGroup'
    Left = 184
    Top = 256
  end
end
