inherited gdc_dlgAcctSubAccount: Tgdc_dlgAcctSubAccount
  Left = 457
  Top = 410
  Caption = '�������'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pgcMain: TPageControl
    inherited tbsMain: TTabSheet
      inherited pAccountInfo: TPanel
        inherited Label2: TLabel
          Width = 80
          Caption = '���� (�������):'
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
    inherited TabSheet1: TTabSheet
      inherited pnlAnalytics: TPanel
        inherited pnlMainAnalytic: TPanel
          inherited lbRelation: TLabel
            Top = 7
          end
        end
      end
    end
  end
end
