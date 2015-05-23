inherited gdc_dlgUserDocumentLine: Tgdc_dlgUserDocumentLine
  Left = 327
  Top = 180
  BorderWidth = 5
  Caption = 'Позиция документа'
  ClientHeight = 378
  ClientWidth = 520
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 0
    Top = 349
    Width = 520
    Height = 2
    Align = alTop
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 357
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 72
    Top = 357
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 357
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 380
    Top = 357
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 452
    Top = 357
    TabOrder = 2
  end
  object pnlAttributes: TPanel [6]
    Left = 0
    Top = 0
    Width = 520
    Height = 349
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object atAttributes: TatContainer
      Left = 3
      Top = 3
      Width = 514
      Height = 343
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
