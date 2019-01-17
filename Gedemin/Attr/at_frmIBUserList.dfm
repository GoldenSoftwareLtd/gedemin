object frmIBUserList: TfrmIBUserList
  Left = 414
  Top = 179
  BorderStyle = bsDialog
  Caption = 'Пользователи'
  ClientHeight = 366
  ClientWidth = 552
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblCapt: TLabel
    Left = 8
    Top = 8
    Width = 537
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = '  К базе подключены следующие пользователи:'
    Color = clBlack
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindow
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object lblCount: TLabel
    Left = 424
    Top = 303
    Width = 121
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
  end
  object lvUser: TgsListView
    Left = 7
    Top = 31
    Width = 539
    Height = 263
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        AutoSize = True
        Caption = 'Пользователь IB'
      end
      item
        AutoSize = True
        Caption = 'Имя пользователя'
      end
      item
        AutoSize = True
        Caption = 'Компьютер'
      end
      item
        AutoSize = True
        Caption = 'Время подключения'
      end>
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 327
    Width = 552
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 552
      Height = 2
      Align = alTop
    end
    object btnCancel: TButton
      Left = 374
      Top = 10
      Width = 82
      Height = 21
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Отменить'
      ModalResult = 2
      TabOrder = 0
    end
    object btnOk: TButton
      Left = 463
      Top = 10
      Width = 82
      Height = 21
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object btnDeleteUser: TButton
      Left = 7
      Top = 10
      Width = 108
      Height = 21
      Action = actDisconnect
      TabOrder = 2
    end
    object btnDeleteAll: TButton
      Left = 121
      Top = 10
      Width = 108
      Height = 21
      Action = actDisconnectAll
      TabOrder = 3
    end
  end
  object chbxShowNames: TCheckBox
    Left = 113
    Top = 302
    Width = 255
    Height = 17
    Caption = 'Показывать сетевые имена компьютеров'
    TabOrder = 2
  end
  object btnRefresh: TButton
    Left = 7
    Top = 300
    Width = 95
    Height = 21
    Action = actRefresh
    TabOrder = 1
  end
  object alIBUsers: TActionList
    Left = 272
    Top = 112
    object actOk: TAction
      Caption = 'Продолжить'
      Hint = 'Вы можете продолжить, только если подключен один пользователь'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actRefresh: TAction
      Caption = 'Обновить (F5)'
      ShortCut = 116
      OnExecute = actRefreshExecute
      OnUpdate = actRefreshUpdate
    end
    object actDisconnect: TAction
      Caption = 'Отключить одного'
      OnExecute = actDisconnectExecute
      OnUpdate = actDisconnectUpdate
    end
    object actDisconnectAll: TAction
      Caption = 'Отключить всех'
      OnExecute = actDisconnectAllExecute
      OnUpdate = actDisconnectAllUpdate
    end
  end
end
