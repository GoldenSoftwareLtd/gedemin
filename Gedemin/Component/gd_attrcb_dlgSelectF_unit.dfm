object dlgSelectF: TdlgSelectF
  Left = 126
  Top = 108
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор элемента множества'
  ClientHeight = 455
  ClientWidth = 656
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object Image1: TImage
    Left = 550
    Top = 76
    Width = 32
    Height = 32
    AutoSize = True
    Picture.Data = {
      055449636F6E0000010001002020100000000000E80200001600000028000000
      2000000040000000010004000000000080020000000000000000000000000000
      0000000000000000000080000080000000808000800000008000800080800000
      80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
      FFFFFF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000788888888888800000888888
      8888880078888888880008707800088888888800780000000088800700888000
      00000800787FFFFFFF00088788000FFFFFFF08007870000000888F878F888000
      000008007877888888FFFF478FFF4CEC088008007877FFFFFFFFFF478FF4CEEC
      0F8008007877FFFFFFFFF4878F4CEECC0F8000007877FFFFFF444F8784CEECC0
      FF8066607877FF4444FFFF874CEECC0FFF80EE607877FFFFFFFFFF84CEECC0FF
      FF80EE607877FFFFFFFFFF4CEECC0FFFFF8066607877FFF00000078787C0FFFF
      FF8033307877F00666666008770FFFFFFF80BB3078777EFEFE4E466070444FFF
      FF80BB307877EFE4E4EFEF660FFFF4444F8033307877FEFEFEFEFE8604FFFFFF
      FF8088807877EFEFEFE4EFE760444FFFFF80FF80787EFE4E4EFEFE4E60FFF444
      4F80FF807877EFEFEFEFE4E760FFFFFFFF808880787EFEFEFE4E4E8E60444FFF
      FF8011107877EFE4E4EFEFE760FFF4444F8099107877FEFEFEFEFE8E0FFFFFFF
      FF8099107777EFEFEFEFE7E607FFFFFFFF80111000077EFEFE7E7E6000777FFF
      FF80000000077777E7E8E0000000077777700000000000077777000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FFFFFFFFFFFFFFFF0000000100000001000000010000000100000001
      0000000100000001000000010000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000E000C00FE001F80FFE07FFFFFFFFFFFF
      FFFFFFFF}
  end
  object Panel1: TPanel
    Left = 12
    Top = 6
    Width = 469
    Height = 94
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 18
      Width = 103
      Height = 16
      Caption = 'Наименование'
    end
    object Label2: TLabel
      Left = 12
      Top = 54
      Width = 57
      Height = 16
      Caption = 'Условие'
    end
    object edName: TEdit
      Left = 117
      Top = 14
      Width = 338
      Height = 24
      TabOrder = 0
      OnKeyDown = edNameKeyDown
    end
    object cbCondition: TComboBox
      Left = 118
      Top = 49
      Width = 336
      Height = 24
      ItemHeight = 16
      TabOrder = 1
      Text = 'cbCondition'
      Items.Strings = (
        'Начинается'
        'Содержит'
        'Заканчивается')
    end
  end
  object Button1: TButton
    Left = 492
    Top = 6
    Width = 155
    Height = 26
    Action = actFind
    Default = True
    TabOrder = 1
  end
  object Button2: TButton
    Left = 492
    Top = 36
    Width = 155
    Height = 26
    Caption = 'Все'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Panel2: TPanel
    Left = 12
    Top = 108
    Width = 469
    Height = 310
    BevelOuter = bvNone
    TabOrder = 3
  end
  object Panel4: TPanel
    Left = 9
    Top = 421
    Width = 475
    Height = 31
    BevelInner = bvLowered
    BevelOuter = bvNone
    BevelWidth = 2
    BorderWidth = 2
    TabOrder = 4
    object lItemsCount: TLabel
      Left = 10
      Top = 6
      Width = 3
      Height = 16
    end
  end
  object btnOk: TButton
    Left = 492
    Top = 396
    Width = 155
    Height = 26
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object btnCancel: TButton
    Left = 492
    Top = 426
    Width = 155
    Height = 26
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 6
  end
  object tvAttrSet: TTreeView
    Left = 11
    Top = 103
    Width = 470
    Height = 317
    AutoExpand = True
    HideSelection = False
    Indent = 19
    RowSelect = True
    ShowLines = False
    TabOrder = 7
  end
  object Button3: TButton
    Left = 492
    Top = 134
    Width = 155
    Height = 26
    Action = actNext
    TabOrder = 8
  end
  object ibqryFind: TIBQuery
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT '
      '  * '
      'FROM'
      '  :tablename')
    Left = 401
    Top = 248
    ParamData = <
      item
        DataType = ftString
        Name = 'tablename'
        ParamType = ptUnknown
      end>
  end
  object PopupMenu1: TPopupMenu
    Left = 210
    Top = 174
    object N1: TMenuItem
      Caption = 'Добавить...'
    end
    object N2: TMenuItem
      Caption = 'Свойства...'
    end
    object N3: TMenuItem
      Caption = 'Удалить'
    end
  end
  object ActionList1: TActionList
    Left = 401
    Top = 216
    object actFind: TAction
      Caption = 'Поиск'
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
    object actNext: TAction
      Caption = 'Дальше'
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
  end
  object ibsqlTree: TIBSQL
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '  1'
      'FROM'
      '  rdb$relation_constraints rc1 '
      '  , rdb$ref_constraints refc'
      '  , rdb$relation_constraints rc2 '
      '  , rdb$relation_fields rf1'
      '  , rdb$relation_fields rf2'
      'WHERE'
      '  rc1.rdb$relation_name = :tablename'
      '  AND refc.rdb$constraint_name = rc1.rdb$constraint_name'
      '  AND rc2.rdb$constraint_name = refc.rdb$const_name_uq'
      '  AND rc2.rdb$relation_name = rc1.rdb$relation_name'
      '  AND rf1.rdb$relation_name = rc1.rdb$relation_name'
      '  AND rf1.rdb$field_name = '#39'LB'#39
      '  AND rf2.rdb$relation_name = rc1.rdb$relation_name'
      '  AND rf2.rdb$field_name = '#39'RB'#39)
    Left = 432
    Top = 216
  end
end
