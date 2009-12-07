object dmDocument: TdmDocument
  Left = 199
  Top = 148
  Height = 375
  Width = 544
  object qryGetDocumentType: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT documenttypekey FROM gd_document WHERE id = :id')
    Left = 70
    Top = 30
  end
  object qryNewDocument: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) v '
      'FROM RDB$DATABASE')
    Left = 70
    Top = 75
  end
  object qryNewNumber: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT number FROM gd_document '
      '  WHERE id = '
      
        '  (SELECT MAX(id) FROM gd_document WHERE documenttypekey = :doct' +
        'ypekey AND companykey = :companykey)')
    Left = 70
    Top = 125
  end
  object qryNewPaymentNumber: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT number FROM gd_document'
      '  WHERE id = '
      
        '  (SELECT MAX(id) FROM gd_document d, bn_payment p WHERE documen' +
        'ttypekey = :doctypekey AND accountkey = :accountkey '
      '  AND p.documentkey = d.id)')
    Left = 70
    Top = 170
  end
  object QRY: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT documenttypekey FROM gd_document WHERE id = :id')
    Left = 145
    Top = 80
  end
end
