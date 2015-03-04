object frmEditTrigger: TfrmEditTrigger
  Left = 283
  Top = 190
  Width = 500
  Height = 297
  Caption = #1048#1079#1084#1077#1085#1077#1085#1080#1077' '#1090#1088#1080#1075#1075#1077#1088#1072
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    492
    270)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 63
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 171
    Top = 8
    Width = 83
    Height = 13
    Caption = #1044#1083#1103' '#1090#1072#1073#1083#1080#1094#1099':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 339
    Top = 8
    Width = 27
    Height = 13
    Caption = #1058#1080#1087':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Bevel2: TBevel
    Left = 4
    Top = 48
    Width = 483
    Height = 6
    Anchors = [akLeft, akTop, akRight]
    Shape = bsTopLine
  end
  object Bevel1: TBevel
    Left = 4
    Top = 238
    Width = 483
    Height = 6
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object edtName: TXPEdit
    Left = 4
    Top = 24
    Width = 157
    Height = 19
    Enabled = False
    MaxLength = 31
    TabOrder = 0
  end
  object edtRelation: TXPEdit
    Left = 168
    Top = 24
    Width = 161
    Height = 19
    Enabled = False
    MaxLength = 31
    TabOrder = 1
  end
  object edtType: TXPEdit
    Left = 336
    Top = 24
    Width = 151
    Height = 19
    Enabled = False
    MaxLength = 31
    TabOrder = 2
  end
  object memTriggerBody: TXPMemo
    Left = 6
    Top = 56
    Width = 481
    Height = 177
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
  end
  object bExit: TXPButton
    Left = 412
    Top = 245
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 4
  end
  object bNext: TXPButton
    Left = 331
    Top = 245
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
end
