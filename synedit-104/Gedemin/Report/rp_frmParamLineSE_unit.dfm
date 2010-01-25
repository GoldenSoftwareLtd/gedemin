object frmParamLineSE: TfrmParamLineSE
  Left = 0
  Top = 0
  Width = 443
  Height = 111
  Align = alTop
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 443
    Height = 111
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 109
      Width = 443
      Height = 2
      Align = alBottom
      Shape = bsBottomLine
    end
    object pnlSimple: TPanel
      Left = 0
      Top = 0
      Width = 443
      Height = 56
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object lblParamName: TLabel
        Left = 8
        Top = 7
        Width = 68
        Height = 13
        Hint = 'Наименование параметра'
        Caption = 'lblParamName'
      end
      object edDisplayName: TEdit
        Left = 176
        Top = 4
        Width = 130
        Height = 21
        Hint = 'Наименование параметра для отображения'
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = edDisplayNameChange
      end
      object cbParamType: TComboBox
        Left = 310
        Top = 4
        Width = 133
        Height = 21
        Hint = 'Тип параметра'
        Style = csDropDownList
        Anchors = [akTop, akRight]
        DropDownCount = 10
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbParamTypeChange
        Items.Strings = (
          'Число целое'
          'Число дробное'
          'Дата'
          'Дата и время'
          'Время'
          'Строка'
          'Логический'
          'Ссылка на элемент'
          'Ссылка на множество'
          'Не запрашивается')
      end
      object edHint: TEdit
        Left = 8
        Top = 28
        Width = 298
        Height = 21
        Hint = 'Описание параметра'
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        OnChange = edDisplayNameChange
      end
      object chbxRequired: TCheckBox
        Left = 310
        Top = 30
        Width = 120
        Height = 17
        Hint = 'Параметр обязателен для заполнения'
        Anchors = [akTop, akRight]
        Caption = 'Обязательный '
        TabOrder = 3
        OnClick = chbxRequiredClick
      end
    end
    object pnlLink: TPanel
      Left = 0
      Top = 56
      Width = 443
      Height = 53
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object edTableName: TEdit
        Left = 8
        Top = 4
        Width = 209
        Height = 21
        Hint = 'Наименование таблицы для параметра ссылка'
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = '<Имя таблицы>'
        OnChange = edDisplayNameChange
      end
      object edDisplayField: TEdit
        Left = 222
        Top = 4
        Width = 148
        Height = 21
        Hint = 'Наименование поля для отображения для параметра ссылка'
        Anchors = [akTop, akRight]
        TabOrder = 1
        Text = '<Поле для отображения>'
        OnChange = edDisplayNameChange
      end
      object edPrimaryField: TEdit
        Left = 375
        Top = 4
        Width = 68
        Height = 21
        Hint = 'Наименование ключа таблицы для параметра ссылки'
        Anchors = [akTop, akRight]
        TabOrder = 2
        Text = '<Поле ИД>'
        OnChange = edDisplayNameChange
      end
      object edConditionScript: TEdit
        Left = 8
        Top = 28
        Width = 209
        Height = 21
        Hint = 'Скрипт для получения условия выборки ссылки'
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 3
        Text = '<Условие отбора записей>'
        OnChange = edDisplayNameChange
      end
      object cbLanguage: TComboBox
        Left = 222
        Top = 28
        Width = 108
        Height = 21
        Hint = 'Язык написания скрипта'
        Style = csDropDownList
        Anchors = [akTop, akRight]
        ItemHeight = 13
        TabOrder = 4
        OnChange = edDisplayNameChange
        Items.Strings = (
          'НЕТ'
          'VBScript'
          'JScript')
      end
      object cbSortOrder: TComboBox
        Left = 335
        Top = 28
        Width = 108
        Height = 21
        Hint = 'Порядок сортировки списка'
        Style = csDropDownList
        Anchors = [akTop, akRight]
        ItemHeight = 13
        TabOrder = 5
        OnChange = edDisplayNameChange
        Items.Strings = (
          ''
          'По возрастанию'
          'По убыванию')
      end
    end
  end
end
