object Form1: TForm1
  Left = 154
  Top = 142
  Width = 541
  Height = 404
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object gsIBGrid1: TgsIBGrid
    Left = 8
    Top = 40
    Width = 521
    Height = 313
    DataSource = DataSource1
    PopupMenu = PopupMenu1
    TabOrder = 6
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    MinColWidth = 40
  end
  object Button1: TButton
    Left = 448
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 368
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = Button2Click
  end
  object fcTreeCombo1: TfcTreeCombo
    Left = 224
    Top = 8
    Width = 121
    Height = 21
    ButtonStyle = cbsDownArrow
    Text = 'fcTreeCombo1'
    DropDownCount = 8
    Items.StreamVersion = 1
    Items.Data = {
      020000002F00000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000
      00000000000000000000050000000331313100000000003100000000000000FF
      FFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000
      00053131312E31000000000001000000013100000000000000FFFFFFFFFFFFFF
      FFFFFFFFFF00000000000000000000000000000000000000000000053131312E
      32000000000001000000013100000000000000FFFFFFFFFFFFFFFFFFFFFFFF00
      000000000000000000000000000000000000000000053131312E310000000000
      01000000013100000000000000FFFFFFFFFFFFFFFFFFFFFFFF00000000000000
      000000000000000000000000000000053131312E310000000000010000000131
      00000000000000FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000
      000000000000000000053131312E320000000000010000000101000000012F00
      000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000
      00000000000000000332323200000000000100000001}
    Options = [icoExpanded, icoEndNodesOnly]
    ReadOnly = False
    ShowMatchText = True
    Sorted = False
    Style = csDropDown
    TabOrder = 2
  end
  object Button3: TButton
    Left = 96
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    OnClick = Button3Click
  end
  object gsComboButton1: TgsComboButton
    Left = 16
    Top = 8
    Width = 75
    Height = 25
    Caption = 'gsComboButton1'
    TabOrder = 4
    OnCloseUp = gsComboButton1CloseUp
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6')
    DropDownCount = 10
  end
  object Button4: TButton
    Left = 456
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 368
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button5'
    TabOrder = 7
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 456
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Button6'
    TabOrder = 8
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 368
    Top = 72
    Width = 75
    Height = 25
    Caption = 'SQL Editor'
    TabOrder = 9
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 456
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Button8'
    TabOrder = 10
    OnClick = Button8Click
  end
  object gsQueryFilter1: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    NoVisibleList.Strings = (
      'GD_GOOD|RESERVED')
    IBDataSet = IBQuery2
    Left = 192
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = IBQuery2
    Left = 40
  end
  object PopupMenu1: TPopupMenu
    Left = 272
    Top = 80
  end
  object IBQuery1: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    BeforeOpen = IBQuery1BeforeOpen
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT '
      '  m.*'
      '  , c.name as contact'
      '  , c.phone as phone'
      '  , u.name as username'
      
        '  , (SELECT COUNT(*) FROM msg_attachment WHERE messagekey = m.id' +
        ') as att '
      'FROM '
      '  gd_contact u JOIN msg_message m ON m.operatorkey = u.id'
      '   LEFT JOIN gd_contact c ON m.fromcontactkey = c.id '
      
        '    JOIN MSG_BOX b ON (b.LB >= :lb AND b.RB <= :rb AND b.id = m.' +
        'boxkey) '
      'WHERE '
      '  (g_sec_testall(m.afull, m.achag, m.aview, -1) <> 0) ')
    BeforeDatabaseDisconnect = IBQuery1BeforeDatabaseDisconnect
    BeforeTransactionEnd = IBQuery1BeforeTransactionEnd
    Left = 8
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'lb'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'rb'
        ParamType = ptUnknown
      end>
  end
  object MainMenu1: TMainMenu
    Left = 336
    Top = 8
    object N11: TMenuItem
      Caption = '1'
    end
    object N21: TMenuItem
      Caption = '2'
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 200
    Top = 56
  end
  object SaveDialog1: TSaveDialog
    Filter = '1|2'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 232
    Top = 56
  end
  object IBDataSet1: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrAttr
    BeforeOpen = IBQuery1BeforeOpen
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT '
      '  m.*'
      '  , c.name as contact'
      '  , c.phone as phone'
      '  , u.name as username'
      
        '  , (SELECT COUNT(*) FROM msg_attachment WHERE messagekey = m.id' +
        ') as att '
      'FROM '
      '  gd_contact u JOIN msg_message m ON m.operatorkey = u.id'
      '   LEFT JOIN gd_contact c ON m.fromcontactkey = c.id '
      
        '    JOIN MSG_BOX b ON (b.LB >= :lb AND b.RB <= :rb AND b.id = m.' +
        'boxkey) '
      'WHERE '
      '  (g_sec_testall(m.afull, m.achag, m.aview, -1) <> 0) ')
    Left = 8
    Top = 48
  end
  object IBTable1: TIBTable
    BufferChunks = 1000
    CachedUpdates = False
    Left = 208
    Top = 136
  end
  object ActionList1: TActionList
    Left = 328
    Top = 160
    object Action1: TAction
      Caption = 'Action1'
    end
    object Action2: TAction
      Caption = 'Action2'
    end
  end
  object IBQuery2: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrAttr
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  g.*'
      'FROM'
      '  gd_contact g')
    Left = 8
    Top = 88
  end
end
