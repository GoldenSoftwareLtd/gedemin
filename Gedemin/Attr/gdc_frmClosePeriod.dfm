object frmClosePeriod: TfrmClosePeriod
  Left = 365
  Top = 70
  BorderStyle = bsDialog
  Caption = 'Закрытие периода'
  ClientHeight = 505
  ClientWidth = 698
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 698
    Height = 465
    ActivePage = tbsMain
    Align = alClient
    TabOrder = 0
    object tbsMain: TTabSheet
      Caption = 'Закрытие периода'
      object GroupBox1: TGroupBox
        Left = 3
        Top = 1
        Width = 681
        Height = 104
        Caption = ' Параметры "закрытой" базы '
        TabOrder = 0
        object lblExtDatabase: TLabel
          Left = 11
          Top = 24
          Width = 68
          Height = 13
          Caption = 'База данных:'
        end
        object lblExtUser: TLabel
          Left = 11
          Top = 48
          Width = 76
          Height = 13
          Caption = 'Пользователь:'
        end
        object lblExtPassword: TLabel
          Left = 11
          Top = 72
          Width = 41
          Height = 13
          Caption = 'Пароль:'
        end
        object lblExtServer: TLabel
          Left = 283
          Top = 48
          Width = 40
          Height = 13
          Caption = 'Сервер:'
        end
        object eExtDatabase: TEdit
          Left = 94
          Top = 20
          Width = 547
          Height = 21
          Color = 11141119
          TabOrder = 0
          Text = 'eExtDatabase'
        end
        object btnChooseDatabase: TButton
          Left = 644
          Top = 20
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 1
          OnClick = btnChooseDatabaseClick
        end
        object eExtUser: TEdit
          Left = 94
          Top = 44
          Width = 153
          Height = 21
          Color = 11141119
          TabOrder = 2
          Text = 'eExtUser'
        end
        object eExtPassword: TEdit
          Left = 94
          Top = 68
          Width = 153
          Height = 21
          Color = 11141119
          PasswordChar = '*'
          TabOrder = 3
          Text = 'eExtPassword'
        end
        object eExtServer: TEdit
          Left = 332
          Top = 44
          Width = 153
          Height = 21
          Color = clWhite
          TabOrder = 4
          Text = 'eExtServer'
        end
      end
      object GroupBox2: TGroupBox
        Left = 3
        Top = 108
        Width = 681
        Height = 323
        Caption = ' Закрытие периода '
        TabOrder = 1
        object lblCloseDate: TLabel
          Left = 16
          Top = 24
          Width = 81
          Height = 13
          Caption = 'Дата закрытия:'
        end
        object lblProcess: TLabel
          Left = 16
          Top = 76
          Width = 649
          Height = 13
          Alignment = taCenter
          AutoSize = False
        end
        object pbMain: TProgressBar
          Left = 16
          Top = 57
          Width = 649
          Height = 16
          Min = 0
          Max = 100
          Smooth = True
          Step = 0
          TabOrder = 0
        end
        object btnRun: TButton
          Left = 200
          Top = 17
          Width = 75
          Height = 25
          Caption = 'Выполнить'
          TabOrder = 1
          OnClick = btnRunClick
        end
        object xdeCloseDate: TxDateEdit
          Left = 112
          Top = 20
          Width = 73
          Height = 21
          Kind = kDate
          Color = 11141119
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 2
          Text = '22.12.2008'
        end
        object mOutput: TMemo
          Left = 255
          Top = 90
          Width = 415
          Height = 221
          Color = clBtnFace
          ScrollBars = ssVertical
          TabOrder = 3
          WantReturns = False
          WordWrap = False
        end
        object cbEntryCalculate: TCheckBox
          Left = 15
          Top = 90
          Width = 235
          Height = 17
          Caption = 'Вычисление бухгалтерских остатков'
          TabOrder = 4
        end
        object cbRemainsCalculate: TCheckBox
          Left = 15
          Top = 138
          Width = 235
          Height = 17
          Caption = 'Вычисление складских остатков'
          TabOrder = 5
        end
        object cbReBindDepotCards: TCheckBox
          Left = 15
          Top = 162
          Width = 235
          Height = 17
          Caption = 'Перепривязка складских карточек'
          TabOrder = 6
        end
        object cbEntryClearProcess: TCheckBox
          Left = 15
          Top = 114
          Width = 235
          Height = 17
          Caption = 'Удаление проводок'
          TabOrder = 7
        end
        object cbRemainsClearProcess: TCheckBox
          Left = 15
          Top = 186
          Width = 235
          Height = 17
          Caption = 'Удаление документов'
          TabOrder = 8
        end
        object cbTransferEntryBalanceProcess: TCheckBox
          Left = 15
          Top = 234
          Width = 235
          Height = 17
          Caption = 'Копирование бухгалтерских остатков'
          TabOrder = 9
        end
        object cbUserDocClearProcess: TCheckBox
          Left = 15
          Top = 210
          Width = 235
          Height = 17
          Caption = 'Удаление пользоват. документов'
          TabOrder = 10
        end
      end
    end
    object tbsInvCardField: TTabSheet
      Caption = 'Складская карточка'
      ImageIndex = 2
      object GroupBox4: TGroupBox
        Left = 3
        Top = 1
        Width = 681
        Height = 430
        Caption = ' Поля складской карточки '
        TabOrder = 0
        object lvAllInvCardField: TListView
          Left = 10
          Top = 19
          Width = 325
          Height = 400
          Columns = <
            item
              AutoSize = True
              Caption = 'Выбранные типы документов'
            end>
          MultiSelect = True
          ReadOnly = True
          RowSelect = True
          ShowColumnHeaders = False
          SortType = stText
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = lvAllInvCardFieldDblClick
        end
        object lvCheckedInvCardField: TListView
          Left = 345
          Top = 19
          Width = 325
          Height = 400
          Columns = <
            item
              AutoSize = True
              Caption = 'Выбранные типы документов'
            end>
          MultiSelect = True
          ReadOnly = True
          RowSelect = True
          ShowColumnHeaders = False
          SortType = stText
          TabOrder = 1
          ViewStyle = vsReport
          OnDblClick = lvCheckedInvCardFieldDblClick
        end
      end
    end
    object tbsDocumentType: TTabSheet
      Caption = 'Типы документов'
      ImageIndex = 3
      object gbDocumentType: TGroupBox
        Left = 3
        Top = 1
        Width = 681
        Height = 430
        Caption = ' Типы документов '
        TabOrder = 0
        object pnlDontDeleteDocumentType: TPanel
          Left = 10
          Top = 19
          Width = 325
          Height = 400
          BevelOuter = bvNone
          TabOrder = 0
          object lvDontDeleteDocumentType: TListView
            Left = 0
            Top = 26
            Width = 325
            Height = 374
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Выбранные типы документов'
              end>
            MultiSelect = True
            ReadOnly = True
            RowSelect = True
            ShowColumnHeaders = False
            SortType = stText
            TabOrder = 0
            ViewStyle = vsReport
          end
          object TBDock1: TTBDock
            Left = 0
            Top = 0
            Width = 325
            Height = 26
            object lblDontDeleteDocumentType: TLabel
              Left = 56
              Top = 6
              Width = 266
              Height = 13
              Alignment = taCenter
              AutoSize = False
              Caption = 'Не удалять эти складские документы'
            end
            object TBToolbar1: TTBToolbar
              Left = 0
              Top = 0
              BorderStyle = bsNone
              Caption = 'TBToolbar1'
              DockMode = dmCannotFloatOrChangeDocks
              DragHandleStyle = dhNone
              Images = dmImages.il16x16
              TabOrder = 0
              object TBItem2: TTBItem
                Action = actChooseDontDeleteDocumentType
              end
              object TBSeparatorItem1: TTBSeparatorItem
              end
              object TBItem1: TTBItem
                Action = actDeleteDontDeleteDocumentType
              end
            end
          end
        end
        object Panel1: TPanel
          Left = 345
          Top = 19
          Width = 325
          Height = 400
          BevelOuter = bvNone
          TabOrder = 1
          object lvDeleteUserDocumentType: TListView
            Left = 0
            Top = 26
            Width = 325
            Height = 374
            Align = alClient
            Columns = <
              item
                AutoSize = True
                Caption = 'Выбранные типы документов'
              end>
            MultiSelect = True
            ReadOnly = True
            RowSelect = True
            ShowColumnHeaders = False
            SortType = stText
            TabOrder = 0
            ViewStyle = vsReport
          end
          object TBDock4: TTBDock
            Left = 0
            Top = 0
            Width = 325
            Height = 26
            object Label1: TLabel
              Left = 56
              Top = 6
              Width = 266
              Height = 13
              Alignment = taCenter
              AutoSize = False
              Caption = 'Удалять эти пользовательские документы'
            end
            object TBToolbar4: TTBToolbar
              Left = 0
              Top = 0
              BorderStyle = bsNone
              Caption = 'TBToolbar1'
              DockMode = dmCannotFloatOrChangeDocks
              DragHandleStyle = dhNone
              Images = dmImages.il16x16
              TabOrder = 0
              object TBItem7: TTBItem
                Action = actChooseDontDeleteDocumentType
              end
              object TBSeparatorItem4: TTBSeparatorItem
              end
              object TBItem8: TTBItem
                Action = actDeleteDontDeleteDocumentType
              end
            end
          end
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 465
    Width = 698
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object pnlBottomButtons: TPanel
      Left = 513
      Top = 0
      Width = 185
      Height = 40
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnClose: TButton
        Left = 102
        Top = 8
        Width = 75
        Height = 25
        Caption = 'Закрыть'
        TabOrder = 0
        OnClick = btnCloseClick
      end
    end
  end
  object odExtDatabase: TOpenDialog
    DefaultExt = 'FDB'
    Filter = 'Database|*.GDB;*.FDB|All|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 39
    Top = 449
  end
  object ActionList1: TActionList
    Images = dmImages.il16x16
    Left = 71
    Top = 449
    object actChooseDontDeleteDocumentType: TAction
      Category = 'DocumentType'
      Caption = 'Выбрать типовые документы'
      ImageIndex = 30
      OnExecute = actChooseDontDeleteDocumentTypeExecute
    end
    object actDeleteDontDeleteDocumentType: TAction
      Category = 'DocumentType'
      Caption = 'Удалить выбранные позиции'
      ImageIndex = 2
      OnExecute = actDeleteDontDeleteDocumentTypeExecute
      OnUpdate = actDeleteDontDeleteDocumentTypeUpdate
    end
    object actChooseUserDocumentToDelete: TAction
      Category = 'DocumentType'
      Caption = 'actChooseUserDocumentToDelete'
      ImageIndex = 30
      OnExecute = actChooseUserDocumentToDeleteExecute
    end
    object actDeleteUserDocumentToDelete: TAction
      Category = 'DocumentType'
      Caption = 'actDeleteUserDocumentToDelete'
      ImageIndex = 2
      OnExecute = actDeleteUserDocumentToDeleteExecute
      OnUpdate = actDeleteUserDocumentToDeleteUpdate
    end
  end
end
