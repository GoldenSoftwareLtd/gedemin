inherited gdc_dlgUserDocumentLine: Tgdc_dlgUserDocumentLine
  Left = 327
  Top = 180
  Caption = 'Позиция документа'
  ClientHeight = 388
  ClientWidth = 530
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'Tahoma'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 0
    Top = 356
    Width = 530
    Height = 2
    Align = alTop
  end
  inherited btnAccess: TButton
    Left = 4
    Top = 362
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 76
    Top = 362
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 148
    Top = 362
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 385
    Top = 362
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 457
    Top = 362
    TabOrder = 2
  end
  object pnlAttributes: TPanel [6]
    Left = 0
    Top = 0
    Width = 530
    Height = 356
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object atAttributes: TatContainer
      Left = 4
      Top = 4
      Width = 522
      Height = 348
      VertScrollBar.Style = ssFlat
      DataSource = dsgdcBase
      Align = alClient
      BorderStyle = bsNone
      Color = clBtnFace
      Ctl3D = True
      ParentColor = False
      ParentCtl3D = False
      TabOrder = 0
    end
  end
end
