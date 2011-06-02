object frmParamLineSE: TfrmParamLineSE
  Left = 0
  Top = 0
  Width = 584
  Height = 81
  Align = alTop
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 584
    Height = 81
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object pcParam: TPageControl
      Left = 2
      Top = 2
      Width = 580
      Height = 77
      ActivePage = tsParam
      Align = alClient
      TabOrder = 0
      object tsParam: TTabSheet
        Caption = 'Параметр'
        object lblName: TLabel
          Left = 1
          Top = 4
          Width = 79
          Height = 13
          Caption = 'Наименование:'
        end
        object lblComment: TLabel
          Left = 1
          Top = 29
          Width = 59
          Height = 13
          Caption = 'Подсказка:'
        end
        object edDisplayName: TEdit
          Left = 88
          Top = 1
          Width = 349
          Height = 21
          Hint = 'Наименование параметра для отображения'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = edDisplayNameChange
        end
        object cbParamType: TComboBox
          Left = 439
          Top = 1
          Width = 133
          Height = 21
          Hint = 'Тип параметра'
          Style = csDropDownList
          Anchors = [akTop, akRight]
          DropDownCount = 16
          ItemHeight = 13
          TabOrder = 1
          OnChange = cbParamTypeChange
          Items.Strings = (
            'Целое число'
            'Число'
            'Дата'
            'Дата и время'
            'Время'
            'Строка'
            'Логический'
            'Ссылка на элемент'
            'Множество ссылок'
            'Не запрашивается'
            'Период'
            'Список значений'
            'Выбор значения'
            'Множество значений')
        end
        object edHint: TEdit
          Left = 88
          Top = 26
          Width = 349
          Height = 21
          Hint = 'Описание параметра'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
          OnChange = edDisplayNameChange
        end
        object chbxRequired: TCheckBox
          Left = 439
          Top = 28
          Width = 120
          Height = 17
          Hint = 'Параметр обязателен для заполнения'
          Anchors = [akTop, akRight]
          Caption = 'Обязательный '
          TabOrder = 3
          OnClick = chbxRequiredClick
        end
      end
      object tsValuesList: TTabSheet
        Caption = 'Список значений'
        ImageIndex = 1
        object lblExample: TLabel
          Left = 4
          Top = 29
          Width = 379
          Height = 13
          Caption = 
            'Пример заполнения: "НДС=1","Налог с продаж=2","Налог на прибыль=' +
            '3"'
        end
        object edValuesList: TEdit
          Left = 3
          Top = 1
          Width = 567
          Height = 21
          Hint = 
            'Список в формате "ОтобрСтрока1=Значение1","ОтобрСтрока2=Значение' +
            '2",...'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
      end
      object tsLink: TTabSheet
        Caption = 'Таблица и поля'
        ImageIndex = 2
        object lblTable: TLabel
          Left = 1
          Top = 4
          Width = 46
          Height = 13
          Caption = 'Таблица:'
        end
        object lblDisplay: TLabel
          Left = 1
          Top = 29
          Width = 120
          Height = 13
          Caption = 'Поле для отображения:'
        end
        object lblPrimary: TLabel
          Left = 424
          Top = 29
          Width = 49
          Height = 13
          Anchors = [akTop, akRight]
          Caption = 'Поле ИД:'
        end
        object edTableName: TEdit
          Left = 50
          Top = 1
          Width = 521
          Height = 21
          Hint = 'Наименование таблицы для параметра ссылка'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          Text = '<Имя таблицы>'
          OnChange = edDisplayNameChange
        end
        object edDisplayField: TEdit
          Left = 125
          Top = 26
          Width = 293
          Height = 21
          Hint = 'Наименование поля для отображения для параметра ссылка'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          Text = '<Поле для отображения>'
          OnChange = edDisplayNameChange
        end
        object edPrimaryField: TEdit
          Left = 475
          Top = 26
          Width = 96
          Height = 21
          Hint = 'Наименование ключа таблицы для параметра ссылки'
          Anchors = [akTop, akRight]
          TabOrder = 2
          Text = '<Поле ИД>'
          OnChange = edDisplayNameChange
        end
      end
      object tsLink2: TTabSheet
        Caption = 'Условие и сортировка'
        ImageIndex = 3
        object lblCondition: TLabel
          Left = 3
          Top = 4
          Width = 85
          Height = 13
          Caption = 'Условие отбора:'
        end
        object lblLanguage: TLabel
          Left = 4
          Top = 28
          Width = 31
          Height = 13
          Caption = 'Язык:'
        end
        object lblSort: TLabel
          Left = 318
          Top = 29
          Width = 63
          Height = 13
          Anchors = [akTop, akRight]
          Caption = 'Сортировка:'
        end
        object edConditionScript: TEdit
          Left = 91
          Top = 1
          Width = 479
          Height = 21
          Hint = 'Скрипт для получения условия выборки ссылки'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          Text = '<Условие отбора записей>'
          OnChange = edDisplayNameChange
        end
        object cbLanguage: TComboBox
          Left = 91
          Top = 26
          Width = 122
          Height = 21
          Hint = 'Язык написания скрипта'
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnChange = edDisplayNameChange
          Items.Strings = (
            'НЕТ'
            'VBScript'
            'JScript')
        end
        object cbSortOrder: TComboBox
          Left = 386
          Top = 26
          Width = 185
          Height = 21
          Hint = 'Порядок сортировки списка'
          Anchors = [akTop, akRight]
          ItemHeight = 13
          TabOrder = 2
          OnChange = edDisplayNameChange
          Items.Strings = (
            '<Без сортировки>'
            '<По наименованию, возр>'
            '<По наименованию, убыв>')
        end
      end
      object tsLink3: TTabSheet
        Caption = 'Шаблоны'
        ImageIndex = 4
        object lblTempl: TLabel
          Left = 7
          Top = 17
          Width = 306
          Height = 13
          Caption = 'Скопировать данные одного из существующих параметров:'
        end
        object btnTemplate: TButton
          Left = 320
          Top = 13
          Width = 81
          Height = 21
          Caption = 'Параметры...'
          TabOrder = 0
          OnClick = btnTemplateClick
        end
      end
    end
  end
end
