object frmValueSel: TfrmValueSel
  Left = 405
  Top = 222
  Width = 249
  Height = 112
  BorderWidth = 5
  Caption = 'Единицы измерения'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bvlSepar: TBevel
    Left = 0
    Top = 41
    Width = 231
    Height = 2
    Align = alTop
  end
  object pnlValue: TPanel
    Left = 0
    Top = 0
    Width = 231
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object iblcValue: TgsIBLookupComboBox
      Left = 0
      Top = 8
      Width = 233
      Height = 21
      Transaction = IBTransaction
      ListTable = 'gd_value'
      ListField = 'name'
      KeyField = 'ID'
      SortOrder = soAsc
      gdClassName = 'TgdcValue'
      Distinct = False
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object pnlButton: TPanel
    Left = 0
    Top = 43
    Width = 231
    Height = 32
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object btnOk: TButton
      Left = 72
      Top = 8
      Width = 75
      Height = 21
      Caption = 'ОК'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 154
      Top = 8
      Width = 75
      Height = 21
      Cancel = True
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object IBTransaction: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 16
    Top = 43
  end
end
