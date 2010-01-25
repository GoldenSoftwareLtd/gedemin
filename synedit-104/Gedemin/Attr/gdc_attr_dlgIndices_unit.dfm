inherited gdc_dlgIndices: Tgdc_dlgIndices
  Left = 227
  Top = 142
  HelpContext = 85
  ActiveControl = dbeIndexName
  Caption = 'Индексы'
  ClientHeight = 296
  ClientWidth = 424
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 23
    Top = 13
    Width = 97
    Height = 13
    Caption = 'Название индекса:'
  end
  object Label2: TLabel [1]
    Left = 171
    Top = 221
    Width = 48
    Height = 13
    Caption = 'Порядок:'
  end
  inherited btnAccess: TButton
    Left = 18
    Top = 267
  end
  inherited btnNew: TButton
    Left = 90
    Top = 267
    Enabled = False
  end
  inherited btnOK: TButton
    Left = 265
    Top = 267
  end
  inherited btnCancel: TButton
    Left = 337
    Top = 267
  end
  inherited btnHelp: TButton
    Left = 162
    Top = 267
  end
  object lbFields: TListBox [7]
    Left = 21
    Top = 36
    Width = 173
    Height = 169
    DragMode = dmAutomatic
    ItemHeight = 13
    TabOrder = 5
    OnDblClick = actAddToIndexExecute
    OnDragDrop = lbFieldsDragDrop
    OnDragOver = lbFieldsDragOver
    OnStartDrag = lbFieldsStartDrag
  end
  object lbIndexFields: TListBox [8]
    Left = 233
    Top = 36
    Width = 173
    Height = 169
    DragMode = dmAutomatic
    ItemHeight = 13
    TabOrder = 6
    OnDblClick = actRemoveFromIndexExecute
    OnDragDrop = lbIndexFieldsDragDrop
    OnDragOver = lbIndexFieldsDragOver
    OnStartDrag = lbIndexFieldsStartDrag
  end
  object dbeIndexName: TDBEdit [9]
    Left = 154
    Top = 8
    Width = 255
    Height = 21
    CharCase = ecUpperCase
    DataField = 'indexname'
    DataSource = dsgdcBase
    TabOrder = 7
  end
  object btnRight: TBitBtn [10]
    Left = 197
    Top = 68
    Width = 33
    Height = 41
    Action = actAddToIndex
    TabOrder = 8
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      33333FF3333333333333447333333333333377FFF33333333333744473333333
      333337773FF3333333333444447333333333373F773FF3333333334444447333
      33333373F3773FF3333333744444447333333337F333773FF333333444444444
      733333373F3333773FF333334444444444733FFF7FFFFFFF77FF999999999999
      999977777777777733773333CCCCCCCCCC3333337333333F7733333CCCCCCCCC
      33333337F3333F773333333CCCCCCC3333333337333F7733333333CCCCCC3333
      333333733F77333333333CCCCC333333333337FF7733333333333CCC33333333
      33333777333333333333CC333333333333337733333333333333}
    Layout = blGlyphBottom
    NumGlyphs = 2
  end
  object btnLeft: TBitBtn [11]
    Left = 197
    Top = 124
    Width = 33
    Height = 41
    Action = actRemoveFromIndex
    TabOrder = 9
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
      333333333333333333FF3333333333333744333333333333F773333333333337
      44473333333333F777F3333333333744444333333333F7733733333333374444
      4433333333F77333733333333744444447333333F7733337F333333744444444
      433333F77333333733333744444444443333377FFFFFFF7FFFFF999999999999
      9999733777777777777333CCCCCCCCCC33333773FF333373F3333333CCCCCCCC
      C333333773FF3337F333333333CCCCCCC33333333773FF373F3333333333CCCC
      CC333333333773FF73F33333333333CCCCC3333333333773F7F3333333333333
      CCC333333333333777FF33333333333333CC3333333333333773}
    Layout = blGlyphTop
    NumGlyphs = 2
  end
  object cmbOrder: TComboBox [12]
    Left = 233
    Top = 216
    Width = 175
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 10
    Items.Strings = (
      'По возрастанию'
      'По убыванию')
  end
  object dbcUnique: TDBCheckBox [13]
    Left = 21
    Top = 242
    Width = 97
    Height = 17
    Caption = 'Уникальный'
    DataField = 'unique_flag'
    DataSource = dsgdcBase
    TabOrder = 11
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbcActive: TDBCheckBox [14]
    Left = 21
    Top = 221
    Width = 97
    Height = 17
    Caption = 'Активный'
    DataField = 'index_inactive'
    DataSource = dsgdcBase
    TabOrder = 12
    ValueChecked = '0'
    ValueUnchecked = '1'
  end
  inherited alBase: TActionList
    Left = 318
    Top = 55
    object actAddToIndex: TAction
      Hint = 'Добавить поле в индекс'
      OnExecute = actAddToIndexExecute
    end
    object actRemoveFromIndex: TAction
      Hint = 'Удалить поле из индекса'
      OnExecute = actRemoveFromIndexExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 288
    Top = 55
  end
  inherited pm_dlgG: TPopupMenu
    Left = 360
    Top = 56
  end
end
