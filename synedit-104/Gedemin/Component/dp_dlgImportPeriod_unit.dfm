object dlgImportPeriod: TdlgImportPeriod
  Left = 337
  Top = 211
  BorderStyle = bsDialog
  Caption = 'Период'
  ClientHeight = 82
  ClientWidth = 231
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 5
    Top = 5
    Width = 221
    Height = 41
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 15
    Top = 19
    Width = 6
    Height = 13
    Caption = 'с'
  end
  object Label2: TLabel
    Left = 115
    Top = 19
    Width = 12
    Height = 13
    Caption = 'по'
  end
  object btnOk: TButton
    Left = 69
    Top = 54
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'ОK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 151
    Top = 54
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object dtpStart: TDateTimePicker
    Left = 25
    Top = 15
    Width = 81
    Height = 21
    CalAlignment = dtaLeft
    Date = 36952.5348915046
    Time = 36952.5348915046
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 2
  end
  object dtpEnd: TDateTimePicker
    Left = 135
    Top = 15
    Width = 81
    Height = 21
    CalAlignment = dtaLeft
    Date = 36952.5348915046
    Time = 36952.5348915046
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 3
  end
end
