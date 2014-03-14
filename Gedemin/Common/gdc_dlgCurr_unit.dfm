inherited gdc_dlgCurr: Tgdc_dlgCurr
  Left = 272
  Top = 188
  HelpContext = 48
  BorderIcons = [biSystemMenu]
  Caption = 'Валюта'
  ClientHeight = 334
  ClientWidth = 615
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel6: TBevel [0]
    Left = 5
    Top = 200
    Width = 306
    Height = 31
    Shape = bsFrame
  end
  object Bevel3: TBevel [1]
    Left = 315
    Top = 5
    Width = 296
    Height = 96
    Shape = bsFrame
  end
  object Bevel2: TBevel [2]
    Left = 5
    Top = 5
    Width = 306
    Height = 96
    Shape = bsFrame
  end
  object mmlFullName: TLabel [3]
    Left = 10
    Top = 10
    Width = 116
    Height = 13
    Caption = 'Полное наименование:'
  end
  object mmlShortName: TLabel [4]
    Left = 10
    Top = 54
    Width = 166
    Height = 13
    Caption = 'Краткое наименование валюты:'
  end
  object mmlCode: TLabel [5]
    Left = 10
    Top = 79
    Width = 68
    Height = 13
    Caption = 'Код валюты:'
  end
  object mmlSign: TLabel [6]
    Left = 11
    Top = 209
    Width = 72
    Height = 13
    Caption = 'Знак валюты:'
  end
  object mmlFullCentName: TLabel [7]
    Left = 320
    Top = 9
    Width = 155
    Height = 13
    Caption = 'Полное наименование центов:'
  end
  object mmlShortCentName: TLabel [8]
    Left = 320
    Top = 54
    Width = 161
    Height = 13
    Caption = 'Краткое наименование центов:'
  end
  object mmlDecdigits: TLabel [9]
    Left = 320
    Top = 79
    Width = 130
    Height = 13
    Caption = 'К-во десятичных знаков:'
  end
  object mmlCentbase: TLabel [10]
    Left = 485
    Top = 79
    Width = 94
    Height = 13
    Caption = 'Дробная единица:'
  end
  object Bevel1: TBevel [11]
    Left = -10
    Top = 300
    Width = 635
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object Label1: TLabel [12]
    Left = 166
    Top = 209
    Width = 66
    Height = 13
    Caption = 'ISO валюты:'
  end
  object Bevel4: TBevel [13]
    Left = 5
    Top = 105
    Width = 306
    Height = 86
    Shape = bsFrame
  end
  object Label2: TLabel [14]
    Left = 15
    Top = 110
    Width = 245
    Height = 26
    Caption = 
      'Наименование валюты в родительном падеже, если число заканчивает' +
      'ся на:'
    WordWrap = True
  end
  object Label3: TLabel [15]
    Left = 15
    Top = 145
    Width = 71
    Height = 13
    Caption = '0, 5, 6, 7, 8, 9'
  end
  object Label5: TLabel [16]
    Left = 15
    Top = 165
    Width = 32
    Height = 13
    Caption = '2, 3, 4'
  end
  object Bevel5: TBevel [17]
    Left = 315
    Top = 105
    Width = 296
    Height = 86
    Shape = bsFrame
  end
  object Label4: TLabel [18]
    Left = 325
    Top = 110
    Width = 240
    Height = 26
    Caption = 
      'Наименование центов в родительном падеже, если число заканчивает' +
      'ся на:'
    WordWrap = True
  end
  object Label6: TLabel [19]
    Left = 325
    Top = 145
    Width = 71
    Height = 13
    Caption = '0, 5, 6, 7, 8, 9'
  end
  object Label7: TLabel [20]
    Left = 325
    Top = 165
    Width = 32
    Height = 13
    Caption = '2, 3, 4'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 310
    TabOrder = 16
  end
  inherited btnNew: TButton
    Left = 85
    Top = 310
    TabOrder = 17
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 310
    TabOrder = 21
  end
  inherited btnOK: TButton
    Left = 455
    Top = 310
    TabOrder = 18
  end
  inherited btnCancel: TButton
    Left = 535
    Top = 310
    TabOrder = 20
  end
  object dbeFullName: TDBEdit [26]
    Left = 10
    Top = 25
    Width = 296
    Height = 21
    Ctl3D = True
    DataField = 'NAME'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 0
  end
  object dbeShortName: TDBEdit [27]
    Left = 185
    Top = 50
    Width = 121
    Height = 21
    Ctl3D = True
    DataField = 'SHORTNAME'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 1
  end
  object dbeCode: TDBEdit [28]
    Left = 185
    Top = 75
    Width = 121
    Height = 21
    Ctl3D = True
    DataField = 'CODE'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 2
    OnChange = dbeCodeChange
  end
  object dbeSign: TDBEdit [29]
    Left = 95
    Top = 205
    Width = 41
    Height = 21
    Ctl3D = True
    DataField = 'SIGN'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 11
  end
  object dbeFullCentName: TDBEdit [30]
    Left = 320
    Top = 25
    Width = 286
    Height = 21
    Ctl3D = True
    DataField = 'FULLCENTNAME'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 5
  end
  object dbeShortCentName: TDBEdit [31]
    Left = 485
    Top = 50
    Width = 121
    Height = 21
    Ctl3D = True
    DataField = 'SHORTCENTNAME'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 6
  end
  object dbeDecdigits: TDBEdit [32]
    Left = 450
    Top = 75
    Width = 26
    Height = 21
    Ctl3D = True
    DataField = 'DECDIGITS'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 8
    OnChange = dbeDecdigitsChange
  end
  object dbeCentbase: TDBEdit [33]
    Left = 580
    Top = 75
    Width = 26
    Height = 21
    Ctl3D = True
    DataField = 'CENTBASE'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 7
  end
  object dbrgPlace: TDBRadioGroup [34]
    Left = 315
    Top = 195
    Width = 296
    Height = 36
    Caption = 'Местоположение знака'
    Columns = 2
    DataField = 'PLACE'
    DataSource = dsgdcBase
    Items.Strings = (
      'До числа'
      'После числа')
    TabOrder = 13
    Values.Strings = (
      '0'
      '1')
  end
  object dbcbIsNCU: TDBCheckBox [35]
    Left = 5
    Top = 240
    Width = 202
    Height = 17
    Caption = 'Национальная денежная единица'
    DataField = 'ISNCU'
    DataSource = dsgdcBase
    TabOrder = 14
    ValueChecked = '1'
    ValueUnchecked = '0'
    OnClick = dbcbIsNCUClick
  end
  object dbcbDisabled: TDBCheckBox [36]
    Left = 465
    Top = 240
    Width = 107
    Height = 17
    Caption = 'Отключена'
    DataField = 'DISABLED'
    DataSource = dsgdcBase
    TabOrder = 15
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbcbEq: TDBCheckBox [37]
    Left = 265
    Top = 240
    Width = 101
    Height = 17
    Caption = 'Эквивалент'
    DataField = 'ISEQ'
    DataSource = dsgdcBase
    TabOrder = 19
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbeISO: TDBEdit [38]
    Left = 265
    Top = 205
    Width = 41
    Height = 21
    Ctl3D = True
    DataField = 'ISO'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 12
  end
  object dbeName_0: TDBEdit [39]
    Left = 95
    Top = 140
    Width = 211
    Height = 21
    Ctl3D = True
    DataField = 'NAME_0'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 3
  end
  object dbeName_1: TDBEdit [40]
    Left = 95
    Top = 165
    Width = 211
    Height = 21
    Ctl3D = True
    DataField = 'NAME_1'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 4
  end
  object dbeCentName_0: TDBEdit [41]
    Left = 405
    Top = 140
    Width = 201
    Height = 21
    Ctl3D = True
    DataField = 'CENTNAME_0'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 9
  end
  object dbeCentName_2: TDBEdit [42]
    Left = 405
    Top = 165
    Width = 201
    Height = 21
    Ctl3D = True
    DataField = 'CENTNAME_1'
    DataSource = dsgdcBase
    ParentCtl3D = False
    TabOrder = 10
  end
  object Memo1: TMemo [43]
    Left = 4
    Top = 260
    Width = 606
    Height = 34
    TabStop = False
    Color = clInfoBk
    Lines.Strings = (
      
        'Для ускорения доступа наименования валют кэшируются. Если, после' +
        ' произведенных изменений в печатных '
      'формах, вы видите старые значения, -- перезагрузите Гедымин.')
    ReadOnly = True
    TabOrder = 22
  end
end
