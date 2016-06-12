object frmAnalyticSel: TfrmAnalyticSel
  Left = 442
  Top = 398
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 5
  Caption = 'Выбор значения аналитики'
  ClientHeight = 73
  ClientWidth = 302
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlAnalyticsSel: TPanel
    Left = 0
    Top = 0
    Width = 302
    Height = 44
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lAnalyticName: TLabel
      Left = 0
      Top = 6
      Width = 67
      Height = 13
      Caption = 'lAnalyticName'
    end
    object ibcbAnalytics: TgsIBLookupComboBox
      Left = 96
      Top = 2
      Width = 202
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = dmDatabase.ibtrGenUniqueID
      SortOrder = soAsc
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object cbNeedId: TCheckBox
      Left = 2
      Top = 26
      Width = 289
      Height = 17
      Caption = 'Получить ИД аналитики'
      TabOrder = 1
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 44
    Width = 302
    Height = 29
    Align = alBottom
    Anchors = []
    BevelOuter = bvNone
    TabOrder = 1
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 302
      Height = 3
      Align = alTop
      Shape = bsTopLine
    end
    object btnOk: TButton
      Left = 147
      Top = 8
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 227
      Top = 8
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akTop, akRight]
      Cancel = True
      ModalResult = 2
      TabOrder = 1
    end
  end
  object alMain: TActionList
    Left = 48
    Top = 26
    object actOk: TAction
      Caption = 'OK'
      ShortCut = 13
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
  end
end
