object dlgEntryFunctionWizard: TdlgEntryFunctionWizard
  Left = 220
  Top = 128
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Конструктор функции проводки'
  ClientHeight = 542
  ClientWidth = 666
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 666
    Height = 513
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object lblSFName: TLabel
      Left = 8
      Top = 10
      Width = 160
      Height = 13
      Caption = 'Имя скрипт-функции проводки:'
    end
    object lblDocType: TLabel
      Left = 8
      Top = 37
      Width = 135
      Height = 13
      Caption = 'Тип обработки документа:'
    end
    object edtSFName: TDBEdit
      Left = 184
      Top = 7
      Width = 473
      Height = 21
      DataField = 'name'
      DataSource = dsFunction
      MaxLength = 60
      TabOrder = 0
    end
    object gbEntrySign: TGroupBox
      Left = 8
      Top = 54
      Width = 649
      Height = 153
      Caption = 'Признаки проводки:'
      TabOrder = 2
      object lblDocName: TLabel
        Left = 102
        Top = 19
        Width = 537
        Height = 13
        AutoSize = False
        Caption = '   '
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
      object lblDocTitle: TLabel
        Left = 8
        Top = 19
        Width = 54
        Height = 13
        Caption = 'Документ:'
      end
      object lblAccountTypeTitle: TLabel
        Left = 8
        Top = 58
        Width = 53
        Height = 13
        Caption = 'Тип счета:'
      end
      object lblAccountType: TLabel
        Left = 102
        Top = 58
        Width = 65
        Height = 13
        Caption = 'дебетовый'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
      object lblCurrSignTitle: TLabel
        Left = 211
        Top = 58
        Width = 131
        Height = 13
        Caption = 'Валютный признак счета:'
      end
      object lblCurrSign: TLabel
        Left = 355
        Top = 58
        Width = 102
        Height = 13
        Caption = 'мультивалютный'
        Color = clBtnShadow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clCaptionText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
      end
      object Bevel1: TBevel
        Left = 8
        Top = 74
        Width = 631
        Height = 2
      end
      object lblNCUSumm: TLabel
        Left = 8
        Top = 83
        Width = 83
        Height = 13
        Caption = 'Сумма в рублях:'
      end
      object pnlCurr: TPanel
        Left = 2
        Top = 99
        Width = 645
        Height = 52
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
        object lblCURRSum: TLabel
          Left = 6
          Top = 31
          Width = 86
          Height = 13
          Caption = 'Сумма в валюте:'
        end
        object lblCurrTitle: TLabel
          Left = 6
          Top = 7
          Width = 41
          Height = 13
          Caption = 'Валюта:'
        end
        object cbCurKey: TComboBox
          Left = 100
          Top = 4
          Width = 538
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
        end
        object edtEditCURF: TBtnEdit
          Left = 100
          Top = 27
          Width = 538
          Height = 22
          Hint = 'Редактировать (Ctrl + E)'
          BtnCaption = 'Редактировать'
          BtnCursor = crArrow
          BtnShowHint = True
          BtnWidth = 90
          BtnOnClick = actEditSumFuncExecute
          Enabled = True
          ParentShowHint = False
          ReadOnly = True
          ShowHint = True
          TabOrder = 1
        end
      end
      object edtEditNCUF: TBtnEdit
        Left = 102
        Top = 79
        Width = 538
        Height = 22
        Hint = 'Редактировать (Ctrl + E)'
        BtnCaption = 'Редактировать'
        BtnCursor = crArrow
        BtnShowHint = True
        BtnWidth = 90
        BtnOnClick = actEditSumFuncExecute
        Enabled = True
        ParentShowHint = False
        ReadOnly = True
        ShowHint = True
        TabOrder = 2
      end
      object cbxAccount: TCheckBox
        Left = 8
        Top = 36
        Width = 85
        Height = 17
        Caption = 'Задать счет:'
        TabOrder = 0
        OnClick = cbxAccountClick
      end
      object cbAccountKey: TComboBox
        Left = 102
        Top = 34
        Width = 538
        Height = 21
        Style = csDropDownList
        Enabled = False
        ItemHeight = 13
        TabOrder = 1
      end
    end
    object cbDocumentPart: TComboBox
      Left = 184
      Top = 31
      Width = 88
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbDocumentPartChange
      Items.Strings = (
        'шапка'
        'позиция')
    end
    object gbAnalytics: TGroupBox
      Left = 8
      Top = 208
      Width = 649
      Height = 273
      Caption = 'Аналитики:'
      Enabled = False
      TabOrder = 3
      object lvAnalytics: TListView
        Left = 8
        Top = 17
        Width = 632
        Height = 88
        Columns = <
          item
            AutoSize = True
            Caption = 'Наименование аналитики'
          end
          item
            AutoSize = True
            Caption = 'Имя поля аналитики'
          end
          item
            AutoSize = True
            Caption = 'Значение аналитики'
          end>
        ColumnClick = False
        Enabled = False
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = lvAnalyticsSelectItem
      end
      object btnJoin: TBitBtn
        Left = 8
        Top = 110
        Width = 312
        Height = 22
        Caption = 'Присвоить значение'
        Enabled = False
        TabOrder = 1
        OnClick = btnJoinClick
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000C40E0000C40E00000001000000000000000000000000
          80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
          A6000020400000206000002080000020A0000020C0000020E000004000000040
          20000040400000406000004080000040A0000040C0000040E000006000000060
          20000060400000606000006080000060A0000060C0000060E000008000000080
          20000080400000806000008080000080A0000080C0000080E00000A0000000A0
          200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
          200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
          200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
          20004000400040006000400080004000A0004000C0004000E000402000004020
          20004020400040206000402080004020A0004020C0004020E000404000004040
          20004040400040406000404080004040A0004040C0004040E000406000004060
          20004060400040606000406080004060A0004060C0004060E000408000004080
          20004080400040806000408080004080A0004080C0004080E00040A0000040A0
          200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
          200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
          200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
          20008000400080006000800080008000A0008000C0008000E000802000008020
          20008020400080206000802080008020A0008020C0008020E000804000008040
          20008040400080406000804080008040A0008040C0008040E000806000008060
          20008060400080606000806080008060A0008060C0008060E000808000008080
          20008080400080806000808080008080A0008080C0008080E00080A0000080A0
          200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
          200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
          200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
          2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
          2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
          2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
          2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
          2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
          2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
          2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FDFDFDFDE0E0
          D8E0D8D8E0E0FDFDFDFDFDFDFDFDEBEBEBF309EB0909FDFDFDFDFDFDFDFDEBE2
          E1E1E1E1E2EBFDFDFDFDFDFDFDFDEBE1E1E1E1E1E1EBFDFDFDFDFDFDFDFDE1E1
          E1E1E1E1E1E1FDFDFDFDFDFDFDFDE1E1E1E1E1E1E1E1FDFDFDFDFDFDFDFDE1E0
          E0E0E0E0E0E0FDFDFDFDD8E0D8D8D9D8D8D8E0D8D8D8D8D8D8E1E1D9D9D8D8D8
          D8D8D8D8D8D8D8E1E1E1FDE1D9D9E1D9D9D9D9D9D9E1D9D9E1FDFDFDE1E1EBD9
          D9D9D9D9E1EBE1E1FDFDFDFDFDE1D9EBE1D9D9D9EBD9E1FDFDFDFDFDFDFDE1D9
          EBE1DAEBE1E1FDFDFDFDFDFDFDFDFDE1D9EBEBE1E1FDFDFDFDFDFDFDFDFDFDFD
          E1E1E1E1FDFDFDFDFDFDFDFDFDFDFDFDFDE1E1FDFDFDFDFDFDFD}
      end
      object btnDelJoin: TBitBtn
        Left = 327
        Top = 110
        Width = 313
        Height = 22
        Caption = 'Удалить значение'
        Enabled = False
        TabOrder = 2
        OnClick = btnDelJoinClick
        Glyph.Data = {
          E6010000424DE60100000000000036000000280000000C0000000C0000000100
          180000000000B0010000C40E0000C40E00000000000000000000FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732
          DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732DE07
          32DE0732DE0732DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732DE
          0732DEFF00FF0732DE0732DD0732DE0732DEFF00FFFF00FFFF00FFFF00FF0732
          DE0732DEFF00FFFF00FFFF00FF0534ED0732DF0732DE0732DDFF00FF0732DD07
          32DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732DD0633E60633E6
          0633E90732DCFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0633
          E30732E30534EFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF07
          32DD0534ED0533E90434EF0434F5FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          0335FC0534EF0533EBFF00FFFF00FF0434F40335F8FF00FFFF00FFFF00FFFF00
          FF0335FB0335FB0434F8FF00FFFF00FFFF00FFFF00FF0335FC0335FBFF00FFFF
          00FF0335FB0335FB0335FBFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          0335FBFF00FF0335FB0335FBFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FF}
      end
      object pcAnalyticsValue: TPageControl
        Left = 8
        Top = 136
        Width = 632
        Height = 128
        ActivePage = tsFields
        MultiLine = True
        TabOrder = 3
        object tsFields: TTabSheet
          Caption = 'Поля документа'
          OnShow = tsFieldsShow
          object lvDocFields: TListView
            Left = 0
            Top = 0
            Width = 624
            Height = 100
            Align = alClient
            Columns = <
              item
                Caption = 'Обработка'
                Width = 70
              end
              item
                AutoSize = True
                Caption = 'Наименование поля документа'
              end
              item
                AutoSize = True
                Caption = 'Локализованное имя поля документа'
              end>
            ColumnClick = False
            Enabled = False
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
          end
        end
        object tsKeys: TTabSheet
          Caption = 'Фиксированные значения'
          ImageIndex = 1
          OnShow = tsKeysShow
          object rfcValue: TrfControl
            Left = 3
            Top = 4
            Width = 617
            Height = 21
          end
        end
      end
    end
    object btnQuantity: TButton
      Left = 8
      Top = 485
      Width = 169
      Height = 21
      Caption = 'Количественные показатели'
      Enabled = False
      TabOrder = 4
      OnClick = btnQuantityClick
    end
  end
  object btnOk: TButton
    Left = 504
    Top = 520
    Width = 73
    Height = 21
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 584
    Top = 520
    Width = 73
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object btnEditDBP: TButton
    Left = 8
    Top = 520
    Width = 169
    Height = 21
    Hint = 'Редактировать метод DoBeforePost объекта проводки'
    Caption = 'Редактировать DoBeforePost'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = btnEditDBPClick
  end
  object gdcFunction: TgdcFunction
    Left = 226
    Top = 514
  end
  object alMain: TActionList
    Left = 266
    Top = 514
    object actAnalytics: TAction
      Caption = 'actAnalytics'
      OnUpdate = actAnalyticsUpdate
    end
  end
  object dsFunction: TDataSource
    DataSet = gdcFunction
    Left = 312
    Top = 512
  end
  object dsAcctTransactionEntry: TDataSource
    Left = 368
    Top = 512
  end
  object IBTransaction: TIBTransaction
    Active = False
    AutoStopAction = saNone
    Left = 184
    Top = 514
  end
end
