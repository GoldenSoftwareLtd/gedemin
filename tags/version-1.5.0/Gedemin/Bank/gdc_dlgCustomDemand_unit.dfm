inherited gdc_dlgCustomDemand: Tgdc_dlgCustomDemand
  Left = 187
  Top = 81
  Caption = 'Платежное требование'
  ClientHeight = 482
  ClientWidth = 568
  PixelsPerInch = 96
  TextHeight = 13
  object lblAccept: TLabel [0]
    Left = 8
    Top = 427
    Width = 41
    Height = 13
    Caption = 'Акцепт:'
  end
  inherited btnOK: TButton
    Left = 405
  end
  inherited btnCancel: TButton
    Left = 485
  end
  inherited PageControl1: TPageControl
    Width = 561
    Height = 447
    inherited tsMain: TTabSheet
      inherited pnlMain: TPanel
        Width = 553
        Height = 419
        inherited Bevel1: TBevel
          Width = 541
        end
        inherited Bevel3: TBevel
          Top = 205
          Width = 541
          Height = 66
        end
        inherited Label17: TLabel
          Left = 11
          Top = 277
        end
        inherited Label10: TLabel
          Top = 218
        end
        inherited Label16: TLabel
          Left = 363
          Top = 218
        end
        inherited Label6: TLabel
          Top = 243
        end
        inherited Label7: TLabel
          Left = 196
          Top = 243
        end
        inherited Label11: TLabel
          Left = 196
          Top = 218
        end
        inherited Label20: TLabel
          Left = 203
          Top = 394
        end
        inherited Label8: TLabel
          Left = 11
          Top = 370
        end
        object Label9: TLabel [18]
          Left = 11
          Top = 397
          Width = 41
          Height = 13
          Caption = 'Акцепт:'
        end
        object Bevel2: TBevel [19]
          Left = 5
          Top = 120
          Width = 541
          Height = 83
          Shape = bsFrame
        end
        object Label13: TLabel [20]
          Left = 16
          Top = 129
          Width = 99
          Height = 13
          Caption = 'Грузоотправитель:'
          Transparent = True
        end
        object Label14: TLabel [21]
          Left = 16
          Top = 154
          Width = 93
          Height = 13
          Caption = 'Грузополучатель:'
          Transparent = True
        end
        object Label15: TLabel [22]
          Left = 16
          Top = 179
          Width = 47
          Height = 13
          Caption = 'Договор:'
          Transparent = True
        end
        object Label19: TLabel [23]
          Left = 363
          Top = 179
          Width = 69
          Height = 13
          Caption = 'Кв./накл. №:'
          Transparent = True
        end
        object Label21: TLabel [24]
          Left = 363
          Top = 154
          Width = 79
          Height = 13
          Caption = 'Дата отгрузки:'
          Transparent = True
        end
        object Label22: TLabel [25]
          Left = 196
          Top = 179
          Width = 81
          Height = 13
          Caption = 'Дата отправки:'
          Transparent = True
        end
        object Label24: TLabel [26]
          Left = 363
          Top = 244
          Width = 47
          Height = 13
          Caption = 'Процент:'
          Transparent = True
        end
        inherited dbeCorrAccount: TgsIBLookupComboBox
          Width = 137
        end
        inherited dbePaymentDestination: TDBMemo
          Left = 85
          Top = 275
          Width = 461
          TabOrder = 22
        end
        inherited dbeOper: TDBEdit
          Top = 214
          TabOrder = 16
        end
        inherited dbeQueue: TDBEdit
          Left = 450
          Top = 214
          TabOrder = 18
        end
        inherited dbeDest: TgsIBLookupComboBox
          Top = 239
          TabOrder = 19
        end
        inherited dbeTerm: TxDateDBEdit
          Left = 280
          Top = 239
          TabOrder = 20
        end
        inherited dbeOperKind: TDBEdit
          Left = 280
          Top = 214
          TabOrder = 17
        end
        inherited edBank: TEdit
          Width = 256
        end
        inherited dbeAdditional: TDBEdit
          Width = 446
        end
        inherited gsibluOwnAccount: TgsIBLookupComboBox
          Width = 136
        end
        inherited cmbExpense: TComboBox
          Left = 320
          Top = 390
          TabOrder = 23
        end
        inherited gsTransactionComboBox: TgsTransactionComboBox
          Left = 85
          Top = 366
          Width = 461
          TabOrder = 24
        end
        object cmbAccept: TComboBox
          Left = 85
          Top = 390
          Width = 97
          Height = 21
          ItemHeight = 13
          TabOrder = 25
          Items.Strings = (
            'Без акцепта'
            'С акцептом')
        end
        object dbeContract: TDBEdit
          Left = 120
          Top = 175
          Width = 71
          Height = 21
          DataField = 'CONTRACT'
          DataSource = dsgdcBase
          TabOrder = 13
        end
        object dbePaper: TDBEdit
          Left = 450
          Top = 175
          Width = 76
          Height = 21
          DataField = 'PAPER'
          DataSource = dsgdcBase
          TabOrder = 15
        end
        object dbeCargoSendDate: TxDateDBEdit
          Left = 450
          Top = 150
          Width = 76
          Height = 21
          DataField = 'CARGOSENDDATE'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 12
        end
        object dbePaperSendDate: TxDateDBEdit
          Left = 280
          Top = 175
          Width = 77
          Height = 21
          DataField = 'PAPERSENDDATE'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 14
        end
        object cbCargoSender: TDBComboBox
          Left = 120
          Top = 125
          Width = 216
          Height = 21
          DataField = 'CARGOSENDER'
          DataSource = dsgdcBase
          ItemHeight = 13
          Items.Strings = (
            'Он же')
          TabOrder = 8
        end
        object cbCargoReceiver: TDBComboBox
          Left = 120
          Top = 150
          Width = 216
          Height = 21
          DataField = 'CARGORECIEVER'
          DataSource = dsgdcBase
          ItemHeight = 13
          Items.Strings = (
            'Он же')
          TabOrder = 10
        end
        object btnChooseSender: TButton
          Left = 335
          Top = 125
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 9
          OnClick = btnChooseSenderClick
        end
        object btnChooseReceiver: TButton
          Left = 335
          Top = 150
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 11
          OnClick = btnChooseReceiverClick
        end
        object dbePercent: TDBEdit
          Left = 450
          Top = 240
          Width = 76
          Height = 21
          DataField = 'PERCENT'
          DataSource = dsgdcBase
          TabOrder = 21
        end
      end
    end
    inherited tsAttribute: TTabSheet
      inherited atContainer: TatContainer
        Width = 553
        Height = 419
      end
    end
  end
  inherited alBase: TActionList
    Left = 534
    Top = 303
  end
  inherited dsgdcBase: TDataSource
    Left = 504
    Top = 303
  end
  object gdcCompany: TgdcCompany
    CachedUpdates = False
    Left = 475
    Top = 305
  end
end
