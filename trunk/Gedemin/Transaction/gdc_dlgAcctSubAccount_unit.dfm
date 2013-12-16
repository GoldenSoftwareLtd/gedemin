inherited gdc_dlgAcctSubAccount: Tgdc_dlgAcctSubAccount
  Left = 392
  Top = 145
  Caption = '—убсчет'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pgcMain: TPageControl
    inherited tbsMain: TTabSheet
      inherited pAccountInfo: TPanel
        inherited Label2: TLabel
          Width = 80
          Caption = '—чет (субсчет):'
        end
        inherited gsiblcGroupAccount: TgsIBLookupComboBox
          ListTable = 'ac_account'
          ListField = 'alias'
          SortOrder = soAsc
          Condition = 'ACCOUNTTYPE IN ('#39'A'#39', '#39'F'#39', '#39'S'#39')'
          gdClassName = 'TgdcAcctAccount'
          ViewType = vtTree
        end
      end
    end
  end
end
