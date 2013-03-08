inherited ctl_dlgSetupPrice: Tctl_dlgSetupPrice
  Left = 251
  Top = 144
  Caption = '��������� ����������� ������ ������������'
  ClientHeight = 267
  ClientWidth = 362
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnOk: TButton
    Left = 121
    Top = 237
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Left = 201
    Top = 237
    Anchors = [akRight, akBottom]
  end
  inherited btnHelp: TButton
    Left = 281
    Top = 237
    Anchors = [akRight, akBottom]
  end
  object pcSetup: TPageControl [3]
    Left = 0
    Top = 0
    Width = 362
    Height = 230
    ActivePage = tsSuppliers
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    object tsPriceList: TTabSheet
      Caption = '�����-����'
      object GroupBox1: TGroupBox
        Left = 10
        Top = 10
        Width = 335
        Height = 81
        Caption = ' ���� ��� �����������: '
        TabOrder = 0
        object Label2: TLabel
          Left = 10
          Top = 20
          Width = 90
          Height = 13
          Caption = '- �� ������ ����:'
        end
        object Label3: TLabel
          Left = 10
          Top = 50
          Width = 49
          Height = 13
          Caption = '- �� ����:'
        end
        object luCompanyCattle: TgsIBLookupComboBox
          Left = 120
          Top = 18
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 
            'RELATIONNAME = '#39'GD_PRICEPOS                    '#39' AND FIELDNAME L' +
            'IKE '#39'USR$%'#39
          ItemHeight = 0
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object luCompanyMeatCattle: TgsIBLookupComboBox
          Left = 120
          Top = 48
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 
            'RELATIONNAME = '#39'GD_PRICEPOS                    '#39' AND FIELDNAME L' +
            'IKE '#39'USR$%'#39
          ItemHeight = 0
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
      end
      object GroupBox2: TGroupBox
        Left = 10
        Top = 100
        Width = 335
        Height = 81
        Caption = ' ���� ��� ���������� ���:'
        TabOrder = 1
        object Label1: TLabel
          Left = 10
          Top = 20
          Width = 90
          Height = 13
          Caption = '- �� ������ ����:'
        end
        object Label4: TLabel
          Left = 10
          Top = 50
          Width = 49
          Height = 13
          Caption = '- �� ����:'
        end
        object luFaceCattle: TgsIBLookupComboBox
          Left = 120
          Top = 18
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 
            'RELATIONNAME = '#39'GD_PRICEPOS                    '#39' AND FIELDNAME L' +
            'IKE '#39'USR$%'#39
          ItemHeight = 0
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object luFaceMeatCattle: TgsIBLookupComboBox
          Left = 120
          Top = 48
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 
            'RELATIONNAME = '#39'GD_PRICEPOS                    '#39' AND FIELDNAME L' +
            'IKE '#39'USR$%'#39
          ItemHeight = 0
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
      end
    end
    object tsSuppliers: TTabSheet
      Caption = '����������'
      ImageIndex = 1
      object GroupBox3: TGroupBox
        Left = 10
        Top = 10
        Width = 335
        Height = 106
        Caption = ' ������ � ����������: '
        TabOrder = 0
        object Label5: TLabel
          Left = 10
          Top = 20
          Width = 89
          Height = 13
          Caption = '- ������ ���, %:'
        end
        object Label6: TLabel
          Left = 10
          Top = 50
          Width = 106
          Height = 13
          Caption = '- ���������� �/�, %:'
        end
        object Label9: TLabel
          Left = 10
          Top = 80
          Width = 97
          Height = 13
          Caption = '- ��� ������.., %:'
        end
        object luVAT: TgsIBLookupComboBox
          Left = 120
          Top = 18
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 'RELATIONNAME = '#39'GD_CONTACTPROPS'#39' AND FIELDNAME LIKE '#39'USR$%'#39
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
        object luFarmTax: TgsIBLookupComboBox
          Left = 120
          Top = 48
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 'RELATIONNAME = '#39'GD_CONTACTPROPS'#39' AND FIELDNAME LIKE '#39'USR$%'#39
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object luNDSTrans: TgsIBLookupComboBox
          Left = 120
          Top = 78
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 'RELATIONNAME = '#39'GD_CONTACTPROPS'#39' AND FIELDNAME LIKE '#39'USR$%'#39
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
      end
      object GroupBox4: TGroupBox
        Left = 10
        Top = 125
        Width = 335
        Height = 51
        Caption = ' ������ ����������:'
        TabOrder = 1
        object Label7: TLabel
          Left = 10
          Top = 20
          Width = 88
          Height = 13
          Caption = '- ����������, ��:'
        end
        object luDistance: TgsIBLookupComboBox
          Left = 120
          Top = 18
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 'RELATIONNAME = '#39'GD_CONTACTPROPS'#39' AND FIELDNAME LIKE '#39'USR$%'#39
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
      end
    end
    object tsOther: TTabSheet
      Caption = '������'
      ImageIndex = 2
      object GroupBox5: TGroupBox
        Left = 10
        Top = 10
        Width = 335
        Height = 51
        Caption = ' ������ ����� (����):'
        TabOrder = 0
        object Label8: TLabel
          Left = 10
          Top = 20
          Width = 104
          Height = 13
          Caption = '- �����. ���������:'
        end
        object luCoefficient: TgsIBLookupComboBox
          Left = 120
          Top = 18
          Width = 201
          Height = 21
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrPriceField
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'LNAME'
          KeyField = 'FIELDNAME'
          Condition = 'RELATIONNAME = '#39'GD_GOODGROUP'#39' AND FIELDNAME LIKE '#39'USR$%'#39
          ItemHeight = 0
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
      end
    end
  end
  inherited ActionList: TActionList
    Left = 220
    Top = 30
  end
  object ibtrPriceField: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 250
    Top = 30
  end
end
