object frmTypeInfo: TfrmTypeInfo
  Left = 164
  Top = 190
  Width = 303
  Height = 439
  Caption = '���������� � ����'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblVariable: TLabel
    Left = 8
    Top = 8
    Width = 67
    Height = 13
    Caption = '����������:'
  end
  object tvTypeInfo: TTreeView
    Left = 8
    Top = 31
    Width = 277
    Height = 274
    Anchors = [akLeft, akTop, akRight, akBottom]
    Images = dmImages.imTreeView
    Indent = 19
    TabOrder = 0
    OnChange = tvTypeInfoChange
    OnDblClick = tvTypeInfoDblClick
  end
  object edVariable: TEdit
    Left = 80
    Top = 3
    Width = 205
    Height = 21
    TabStop = False
    Anchors = [akLeft, akTop, akRight]
    Color = clInactiveCaptionText
    ReadOnly = True
    TabOrder = 1
  end
  object mmDescription: TMemo
    Left = 8
    Top = 310
    Width = 277
    Height = 33
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 2
  end
  object mmFullFunction: TMemo
    Left = 8
    Top = 356
    Width = 277
    Height = 45
    Anchors = [akLeft, akRight, akBottom]
    Lines.Strings = (
      '')
    TabOrder = 3
  end
end
