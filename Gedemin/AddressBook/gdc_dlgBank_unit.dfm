inherited gdc_dlgBank: Tgdc_dlgBank
  Left = 416
  Top = 206
  HelpContext = 32
  Caption = 'Банк'
  ClientHeight = 371
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 343
  end
  inherited btnNew: TButton
    Top = 343
  end
  inherited btnHelp: TButton
    Top = 343
  end
  inherited btnOK: TButton
    Top = 343
  end
  inherited btnCancel: TButton
    Top = 343
  end
  inherited pgcMain: TPageControl
    Height = 333
    inherited tbsMain: TTabSheet
      object LabelCode: TLabel [10]
        Left = 6
        Top = 130
        Width = 21
        Height = 13
        Caption = 'BIC:'
      end
      object LabelMFO: TLabel [11]
        Left = 172
        Top = 182
        Width = 94
        Height = 13
        Caption = 'БИК (бывш. МФО):'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clBtnShadow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Visible = False
      end
      object lblSWIFT: TLabel [12]
        Left = 6
        Top = 181
        Width = 36
        Height = 13
        Caption = 'SWIFT:'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clBtnShadow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Visible = False
      end
      object lblBankBranch: TLabel [13]
        Left = 176
        Top = 130
        Width = 180
        Height = 13
        Caption = 'ЦБУ (номер отделения, если есть):'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      inherited btnSaveRec: TButton
        Top = 180
        TabOrder = 11
      end
      inherited pnAccount: TPanel
        Top = 148
        Height = 131
        TabOrder = 12
        inherited Label23: TLabel
          Left = 5
          Top = 26
        end
        inherited Bevel2: TBevel
          Top = 33
        end
        inherited Label29: TLabel
          Left = 5
          Top = 6
          Width = 64
          Caption = 'Главн. счет:'
        end
        inherited Bevel1: TBevel
          Left = 73
          Top = 65
          Visible = False
        end
        inherited btnNewBank: TButton
          Top = 25
        end
        inherited btnEditBank: TButton
          Top = 46
        end
        inherited btnDeleteBank: TButton
          Top = 67
        end
        inherited dbgAccount: TgsIBGrid
          Top = 43
          Height = 88
        end
        inherited btnRefreshBank: TButton
          Top = 88
        end
        inherited gsiblkupMainAccount: TgsIBLookupComboBox
          Left = 73
          Top = 3
        end
        inherited btnAccRed: TButton
          Top = 110
        end
      end
      inherited dbcbDisabled: TDBCheckBox
        Top = 285
        Caption = 'Банк не активен'
        TabOrder = 13
      end
      inherited dbeOkulp: TDBEdit
        TabStop = False
        TabOrder = 14
      end
      object dbeBankCode: TDBEdit
        Left = 74
        Top = 126
        Width = 95
        Height = 21
        DataField = 'BANKCODE'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object dbeBankMFO: TDBEdit
        Left = 109
        Top = 234
        Width = 107
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'BANKMFO'
        DataSource = dsgdcBase
        TabOrder = 10
        Visible = False
      end
      object dbeSWIFT: TDBEdit
        Left = 114
        Top = 210
        Width = 95
        Height = 21
        TabStop = False
        Color = clBtnFace
        DataField = 'SWIFT'
        DataSource = dsgdcBase
        TabOrder = 9
        Visible = False
      end
      object dbedBankBranch: TDBEdit
        Left = 365
        Top = 126
        Width = 106
        Height = 21
        DataField = 'BANKBRANCH'
        DataSource = dsgdcBase
        TabOrder = 8
      end
    end
    inherited TabSheet3: TTabSheet
      inherited gsiblkupAddress: TgsIBLookupComboBox
        ItemHeight = 13
      end
      inherited gsIBlcHeadCompany: TgsIBLookupComboBox
        ItemHeight = 13
      end
      inherited gsiblkupChiefAccountant: TgsIBLookupComboBox
        ItemHeight = 13
      end
      inherited gsiblkupDirector: TgsIBLookupComboBox
        ItemHeight = 13
      end
    end
    inherited tbsLogo: TTabSheet
      inherited JvDBImage: TJvDBImage
        Height = 283
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Height = 305
      end
    end
  end
  inherited alBase: TActionList
    Left = 255
    Top = 350
  end
  inherited ibtrCommon: TIBTransaction
    Left = 344
    Top = 240
  end
  inherited gdcAccount: TgdcAccount
    Left = 219
    Top = 22
  end
  inherited dsAccount: TDataSource
    Left = 181
    Top = 22
  end
end
