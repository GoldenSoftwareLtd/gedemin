inherited gdc_dlgAttrUserDefined: Tgdc_dlgAttrUserDefined
  Left = 691
  Top = 279
  Width = 491
  Height = 346
  BorderStyle = bsSizeable
  Caption = 'Таблица пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 283
    TabOrder = 1
  end
  inherited btnNew: TButton
    Left = 79
    Top = 283
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Top = 283
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 327
    Top = 283
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 401
    Top = 283
    TabOrder = 4
  end
  object pnlMain: TPanel [5]
    Left = 0
    Top = 0
    Width = 475
    Height = 274
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object atAttributes: TatContainer
      Left = 0
      Top = 0
      Width = 475
      Height = 274
      DataSource = dsgdcBase
      Align = alClient
      BorderStyle = bsNone
      TabOrder = 0
    end
  end
  inherited alBase: TActionList
    Left = 46
    Top = 15
  end
  inherited dsgdcBase: TDataSource
    Left = 16
    Top = 15
  end
end
