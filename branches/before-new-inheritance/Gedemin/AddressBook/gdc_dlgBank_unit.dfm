inherited gdc_dlgBank: Tgdc_dlgBank
  Left = 246
  Top = 178
  HelpContext = 32
  Caption = 'Банк'
  ClientHeight = 384
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 356
  end
  inherited btnNew: TButton
    Top = 356
  end
  inherited btnHelp: TButton
    Top = 356
  end
  inherited btnOK: TButton
    Top = 356
  end
  inherited btnCancel: TButton
    Top = 356
  end
  inherited pgcMain: TPageControl
    Height = 346
    inherited tbsMain: TTabSheet
      object LabelCode: TLabel [10]
        Left = 6
        Top = 129
        Width = 57
        Height = 13
        Caption = 'Код банка:'
      end
      object LabelMFO: TLabel [11]
        Left = 321
        Top = 129
        Width = 28
        Height = 13
        Caption = 'МФО:'
      end
      object lblSWIFT: TLabel [12]
        Left = 6
        Top = 154
        Width = 36
        Height = 13
        Caption = 'SWIFT:'
      end
      object lblBankBranch: TLabel [13]
        Left = 172
        Top = 129
        Width = 75
        Height = 13
        Caption = '№ отделения:'
      end
      inherited btnSaveRec: TButton
        TabOrder = 13
      end
      inherited pnAccount: TPanel
        Top = 170
        Height = 131
        TabOrder = 10
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
        Top = 302
        Caption = 'Банк не активен'
        TabOrder = 11
      end
      inherited dbeOkulp: TDBEdit
        TabOrder = 12
      end
      object dbeBankCode: TDBEdit
        Left = 74
        Top = 125
        Width = 95
        Height = 21
        DataField = 'BANKCODE'
        DataSource = dsgdcBase
        TabOrder = 7
      end
      object dbeBankMFO: TDBEdit
        Left = 365
        Top = 125
        Width = 107
        Height = 21
        DataField = 'BANKMFO'
        DataSource = dsgdcBase
        TabOrder = 9
      end
      object dbeSWIFT: TDBEdit
        Left = 74
        Top = 149
        Width = 241
        Height = 21
        DataField = 'SWIFT'
        DataSource = dsgdcBase
        TabOrder = 8
      end
      object dbedBankBranch: TDBEdit
        Left = 258
        Top = 125
        Width = 57
        Height = 21
        DataSource = dsgdcBase
        TabOrder = 14
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
