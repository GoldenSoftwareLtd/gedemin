inherited frDocumentTransactionEditFrame: TfrDocumentTransactionEditFrame
  Width = 442
  Constraints.MinHeight = 199
  inherited PageControl: TPageControl
    Width = 442
    inherited tsGeneral: TTabSheet
      inherited Label2: TLabel
        Top = 79
      end
      object lTransaction: TLabel [3]
        Left = 4
        Top = 49
        Width = 51
        Height = 26
        Caption = '������� ��������:'
        WordWrap = True
      end
      inherited cbName: TComboBox
        Width = 329
      end
      inherited mDescription: TMemo
        Top = 75
        Width = 329
        TabOrder = 3
      end
      inherited eLocalName: TEdit
        Width = 329
      end
      object iblTransaction: TgsIBLookupComboBox
        Left = 95
        Top = 51
        Width = 330
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = Transaction
        ListTable = 'ac_transaction'
        ListField = 'name'
        KeyField = 'ID'
        Condition = '(AUTOTRANSACTION IS NULL) OR (AUTOTRANSACTION = 0)'
        gdClassName = 'TgdcAcctTransaction'
        ViewType = vtTree
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
      end
    end
  end
  object Transaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 36
    Top = 144
  end
end
