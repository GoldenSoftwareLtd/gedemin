inherited dlgReturnBill: TdlgReturnBill
  Left = 228
  Top = 106
  Width = 696
  Height = 480
  Caption = 'Накладная на возврат'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pcBill: TPageControl
    Width = 688
    Height = 141
    inherited tsMain: TTabSheet
      inherited Panel1: TPanel
        Width = 680
        Height = 113
        inherited Label5: TLabel
          Visible = False
        end
        inherited Label6: TLabel
          Visible = False
        end
        inherited Label7: TLabel
          Top = 117
          Visible = False
        end
        inherited Label8: TLabel
          Top = 125
          Visible = False
        end
        inherited Label25: TLabel
          Visible = False
        end
        inherited Label29: TLabel
          Visible = False
        end
        inherited SpeedButton1: TSpeedButton
          Top = 144
          Visible = False
        end
        inherited Label9: TLabel
          Top = 157
          Visible = False
        end
        inherited gsiblcFromContact: TgsIBLookupComboBox
          Fields = 'CITY'
          Condition = 'CONTACTTYPE > 1'
          gdClassName = 'TgdcBaseContact'
        end
        inherited gsiblcToContact: TgsIBLookupComboBox
          Width = 552
          Condition = 'CONTACTTYPE = 4'
          gdClassName = 'TgdcDepartment'
        end
        inherited gsiblcCurr: TgsIBLookupComboBox
          Visible = False
        end
        inherited dbedRate: TDBEdit
          Visible = False
        end
        inherited gsiblcPrice: TgsIBLookupComboBox
          Top = 120
          Visible = False
        end
        inherited cbPriceField: TComboBox
          Top = 129
          Visible = False
        end
        inherited ddeDatePayment: TxDateDBEdit
          Visible = False
        end
        inherited dbedContract: TDBEdit
          Top = 136
          Visible = False
        end
        inherited dbcbDelayed: TDBCheckBox
          Left = 13
          Top = 88
        end
      end
    end
    inherited TabSheet3: TTabSheet
      inherited atContainer: TatContainer
        Width = 680
        Height = 113
      end
    end
  end
  inherited Panel2: TPanel
    Top = 412
    Width = 688
    inherited Panel4: TPanel
      Left = 428
    end
  end
  inherited Panel3: TPanel
    Top = 141
    Width = 688
    Height = 271
    inherited gsibgrDocRealPos: TgsIBCtrlGrid
      Width = 676
      Height = 182
    end
    inherited ToolBar1: TToolBar
      Width = 676
    end
    inherited lvAmount: TListView
      Top = 213
      Width = 676
    end
  end
  inherited atSQLSetup: TatSQLSetup
    Left = 398
    Top = 106
  end
  inherited xFoCal: TxFoCal
    _variables_ = (
      'PI'
      3.14159265358979
      'E'
      2.71828182845905)
  end
end
