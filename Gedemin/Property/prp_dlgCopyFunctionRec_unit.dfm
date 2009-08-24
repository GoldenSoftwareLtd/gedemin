object dlgCopyFunctionRec: TdlgCopyFunctionRec
  Left = 306
  Top = 234
  AutoSize = True
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Внимание !'
  ClientHeight = 256
  ClientWidth = 406
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object stMessage: TStaticText
    Left = 0
    Top = 0
    Width = 406
    Height = 73
    Align = alTop
    AutoSize = False
    BorderStyle = sbsSingle
    Caption = '  Внимание. "%s" ссылается на функцию "%s"'#39' '
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 73
    Width = 406
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 64
      Top = 8
      Width = 91
      Height = 25
      Caption = 'Создать копию'
      ModalResult = 1
      TabOrder = 0
    end
    object Button2: TButton
      Left = 160
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Изменить'
      ModalResult = 6
      TabOrder = 1
    end
    object Button3: TButton
      Left = 312
      Top = 8
      Width = 91
      Height = 25
      Caption = 'Подробнее >>'
      TabOrder = 2
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 240
      Top = 8
      Width = 65
      Height = 25
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 3
    end
  end
  object pExtraInfo: TPanel
    Left = 0
    Top = 114
    Width = 406
    Height = 142
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    BorderWidth = 5
    Caption = 'pExtraInfo'
    TabOrder = 2
    Visible = False
    object stExtraInfo: TStaticText
      Left = 5
      Top = 5
      Width = 396
      Height = 17
      Align = alTop
      AutoSize = False
      Caption = 'На данную запись имеются следующие ссылки:'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBtnText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 0
    end
    object sbInfoLines: TScrollBox
      Left = 5
      Top = 22
      Width = 396
      Height = 115
      HorzScrollBar.Style = ssFlat
      VertScrollBar.Style = ssFlat
      Align = alTop
      BorderStyle = bsNone
      TabOrder = 1
    end
  end
  object DataSource: TDataSource
    DataSet = IBDataSet
    Left = 40
    Top = 81
  end
  object IBDataSet: TIBDataSet
    BufferChunks = 1000
    CachedUpdates = False
    Left = 8
    Top = 81
  end
end
