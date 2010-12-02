object dlgSelectAttr: TdlgSelectAttr
  Left = 131
  Top = 108
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор элемента множества'
  ClientHeight = 370
  ClientWidth = 533
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 447
    Top = 62
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
    Left = 10
    Top = 5
    Width = 381
    Height = 76
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 15
      Width = 76
      Height = 13
      Caption = 'Наименование'
    end
    object Label2: TLabel
      Left = 10
      Top = 44
      Width = 44
      Height = 13
      Caption = 'Условие'
    end
    object edName: TEdit
      Left = 95
      Top = 11
      Width = 275
      Height = 21
      TabOrder = 0
      OnKeyDown = edNameKeyDown
    end
    object cbCondition: TComboBox
      Left = 96
      Top = 40
      Width = 273
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Text = 'cbCondition'
      Items.Strings = (
        'Начинается'
        'Содержит'
        'Заканчивается')
    end
  end
  object Button1: TButton
    Left = 400
    Top = 5
    Width = 126
    Height = 21
    Action = actFind
    Default = True
    TabOrder = 1
  end
  object Button2: TButton
    Left = 400
    Top = 29
    Width = 126
    Height = 21
    Caption = 'Все'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Panel2: TPanel
    Left = 10
    Top = 88
    Width = 381
    Height = 252
    BevelOuter = bvNone
    TabOrder = 3
  end
  object Panel4: TPanel
    Left = 7
    Top = 342
    Width = 386
    Height = 25
    BevelInner = bvLowered
    BevelOuter = bvNone
    BevelWidth = 2
    BorderWidth = 2
    TabOrder = 4
    object lItemsCount: TLabel
      Left = 8
      Top = 5
      Width = 3
      Height = 13
    end
  end
  object btnOk: TButton
    Left = 400
    Top = 322
    Width = 126
    Height = 21
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object btnCancel: TButton
    Left = 400
    Top = 346
    Width = 126
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 6
  end
  object tvAttrSet: TTreeView
    Left = 9
    Top = 84
    Width = 382
    Height = 257
    AutoExpand = True
    HideSelection = False
    Indent = 19
    RowSelect = True
    ShowLines = False
    TabOrder = 7
  end
  object Button3: TButton
    Left = 400
    Top = 109
    Width = 126
    Height = 21
    Action = actNext
    TabOrder = 8
  end
  object btnProperty: TButton
    Left = 400
    Top = 181
    Width = 126
    Height = 21
    Action = actEdit
    TabOrder = 9
  end
  object Button4: TButton
    Left = 400
    Top = 205
    Width = 126
    Height = 21
    Action = actDelete
    TabOrder = 10
  end
  object Button5: TButton
    Left = 400
    Top = 157
    Width = 126
    Height = 21
    Action = actAdd
    TabOrder = 11
  end
  object ibqryFind: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGAdmin
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
    object actAdd: TAction
      Caption = 'Добавить...'
      OnExecute = actAddExecute
    end
    object actEdit: TAction
      Caption = 'Изменить...'
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actDelete: TAction
      Caption = 'Удалить...'
      OnExecute = actDeleteExecute
      OnUpdate = actEditUpdate
    end
  end
end
