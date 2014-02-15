object dlgToNamespace: TdlgToNamespace
  Left = 703
  Top = 218
  BorderStyle = bsDialog
  Caption = 'Добавление объекта в пространство имен'
  ClientHeight = 504
  ClientWidth = 721
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlGrid: TPanel
    Left = 0
    Top = 112
    Width = 721
    Height = 392
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 1
    object pnlButtons: TPanel
      Left = 8
      Top = 356
      Width = 705
      Height = 28
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object pnlRightBottom: TPanel
        Left = 481
        Top = 0
        Width = 224
        Height = 28
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnOk: TButton
          Left = 68
          Top = 7
          Width = 75
          Height = 21
          Action = actOK
          Default = True
          TabOrder = 0
        end
        object btnCancel: TButton
          Left = 148
          Top = 7
          Width = 75
          Height = 21
          Cancel = True
          Caption = '&Отмена'
          ModalResult = 2
          TabOrder = 1
        end
      end
    end
    object sb: TScrollBox
      Left = 8
      Top = 8
      Width = 705
      Height = 348
      Align = alClient
      TabOrder = 1
    end
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 721
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lMessage: TLabel
      Left = 8
      Top = 8
      Width = 102
      Height = 13
      Caption = 'Пространство имен:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object chbxIncludeSiblings: TCheckBox
      Left = 344
      Top = 55
      Width = 337
      Height = 17
      Caption = 'Для древовидных иерархий включать вложенные объекты'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
    object chbxDontRemove: TCheckBox
      Left = 344
      Top = 39
      Width = 331
      Height = 17
      Caption = 'Не удалять объекты при удалении пространства имен'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
    object chbxAlwaysOverwrite: TCheckBox
      Left = 344
      Top = 22
      Width = 233
      Height = 17
      Caption = 'Всегда перезаписывать при загрузке'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object lkupNS: TgsIBLookupComboBox
      Left = 8
      Top = 24
      Width = 305
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = Tr
      ListTable = 'at_namespace'
      ListField = 'name'
      KeyField = 'ID'
      gdClassName = 'TgdcNamespace'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object dsLink: TDataSource
    Left = 304
    Top = 216
  end
  object ActionList: TActionList
    Left = 400
    Top = 216
    object actOK: TAction
      Caption = '&ОК'
      OnExecute = actOKExecute
      OnUpdate = actOKUpdate
    end
  end
  object Tr: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 184
    Top = 216
  end
end
