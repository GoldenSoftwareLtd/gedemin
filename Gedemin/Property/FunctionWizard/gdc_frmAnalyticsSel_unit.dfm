object frmAnalyticSel: TfrmAnalyticSel
  Left = 442
  Top = 398
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  BorderWidth = 5
  Caption = 'Выбор значения аналитики'
  ClientHeight = 79
  ClientWidth = 325
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object pnlAnalyticsSel: TPanel
    Left = 0
    Top = 0
    Width = 325
    Height = 47
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lAnalyticName: TLabel
      Left = 0
      Top = 6
      Width = 68
      Height = 14
      Caption = 'lAnalyticName'
    end
    object ibcbAnalytics: TgsIBLookupComboBox
      Left = 103
      Top = 2
      Width = 218
      Height = 22
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = dmDatabase.ibtrGenUniqueID
      SortOrder = soAsc
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 14
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object cbNeedId: TCheckBox
      Left = 2
      Top = 28
      Width = 311
      Height = 18
      Caption = 'Получить ИД аналитики'
      TabOrder = 1
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 47
    Width = 325
    Height = 32
    Align = alBottom
    Anchors = []
    BevelOuter = bvNone
    TabOrder = 1
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 325
      Height = 3
      Align = alTop
      Shape = bsTopLine
    end
    object btnOk: TButton
      Left = 158
      Top = 9
      Width = 81
      Height = 22
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 244
      Top = 9
      Width = 81
      Height = 22
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
