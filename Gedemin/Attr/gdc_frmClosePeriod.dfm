object frmClosePeriod: TfrmClosePeriod
  Left = 525
  Top = 258
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Закрытие периода'
  ClientHeight = 487
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
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBack: TPanel
    Left = 0
    Top = 0
    Width = 698
    Height = 457
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object pcMain: TPageControl
      Left = 4
      Top = 4
      Width = 690
      Height = 449
      ActivePage = tbsMain
      Align = alClient
      TabOrder = 0
      object tbsMain: TTabSheet
        BorderWidth = 3
        Caption = 'Закрытие периода'
        object gbDatabase: TGroupBox
          Left = 0
          Top = 0
          Width = 676
          Height = 73
          Align = alTop
          Caption = ' Исходная база данных  '
          TabOrder = 0
          object lblExtDatabase: TLabel
            Left = 219
            Top = 23
            Width = 68
            Height = 13
            Caption = 'База данных:'
          end
          object lblExtUser: TLabel
            Left = 11
            Top = 47
            Width = 76
            Height = 13
            Caption = 'Пользователь:'
          end
          object lblExtPassword: TLabel
            Left = 219
            Top = 47
            Width = 41
            Height = 13
            Caption = 'Пароль:'
          end
          object lblExtServer: TLabel
            Left = 11
            Top = 23
            Width = 68
            Height = 13
            Caption = 'Сервер/порт:'
          end
          object eExtDatabase: TEdit
            Left = 296
            Top = 20
            Width = 349
            Height = 21
            Color = clWhite
            TabOrder = 1
            Text = 'eExtDatabase'
          end
          object btnChooseDatabase: TButton
            Left = 644
            Top = 19
            Width = 21
            Height = 21
            Caption = '...'
            TabOrder = 2
            OnClick = btnChooseDatabaseClick
          end
          object eExtUser: TEdit
            Left = 94
            Top = 44
            Width = 109
            Height = 21
            Color = clWhite
            TabOrder = 3
            Text = 'eExtUser'
          end
          object eExtPassword: TEdit
            Left = 296
            Top = 44
            Width = 109
            Height = 21
            Color = clWhite
            PasswordChar = '*'
            TabOrder = 4
            Text = 'eExtPassword'
          end
          object eExtServer: TEdit
            Left = 94
            Top = 20
            Width = 109
            Height = 21
            Color = clWhite
            TabOrder = 0
            Text = 'eExtServer'
          end
        end
        object gbClosePeriod: TGroupBox
          Left = 0
          Top = 73
          Width = 676
          Height = 102
          Align = alTop
          Caption = ' Закрытие периода '
          TabOrder = 3
          object lblCloseDate: TLabel
            Left = 11
            Top = 44
            Width = 126
            Height = 13
            Caption = 'Закрыть период на дату:'
          end
          object lblProcess: TLabel
            Left = 12
            Top = 21
            Width = 573
            Height = 13
            Caption = 
              'Перед запуском проверьте правильность заполнения параметров "Скл' +
              'адская карточка" и "Типы документов".'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clRed
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
          end
          object xdeCloseDate: TxDateEdit
            Left = 142
            Top = 41
            Width = 73
            Height = 21
            Kind = kDate
            CurrentDateTimeAtStart = True
            Color = 11141119
            EditMask = '!99\.99\.9999;1;_'
            MaxLength = 10
            TabOrder = 0
            Text = '22.12.2008'
          end
          object pnlObsoleteControls: TPanel
            Left = 616
            Top = 32
            Width = 33
            Height = 9
            TabOrder = 1
            Visible = False
            object cbEntryCalculate: TCheckBox
              Left = 32
              Top = 18
              Width = 235
              Height = 17
              Caption = 'Вычисление бухгалтерских остатков'
              Checked = True
              State = cbChecked
              TabOrder = 0
            end
            object cbEntryClearProcess: TCheckBox
              Left = 16
              Top = 58
              Width = 235
              Height = 17
              Caption = 'Удаление проводок'
              Checked = True
              State = cbChecked
              TabOrder = 1
            end
            object cbRemainsCalculate: TCheckBox
              Left = 8
              Top = 42
              Width = 235
              Height = 17
              Caption = 'Вычисление складских остатков'
              Checked = True
              State = cbChecked
              TabOrder = 2
            end
            object cbOnlyOurRemains: TCheckBox
              Left = 31
              Top = 82
              Width = 314
              Height = 17
              Caption = 'Вычислять остатки только для рабочих организаций'
              Checked = True
              State = cbChecked
              TabOrder = 3
            end
            object cbReBindDepotCards: TCheckBox
              Left = 8
              Top = 106
              Width = 235
              Height = 17
              Caption = 'Перепривязка складских карточек'
              Checked = True
              State = cbChecked
              TabOrder = 4
            end
            object cbRemainsClearProcess: TCheckBox
              Left = 8
              Top = 130
              Width = 235
              Height = 17
              Caption = 'Удаление документов'
              Checked = True
              State = cbChecked
              TabOrder = 5
            end
            object cbUserDocClearProcess: TCheckBox
              Left = 8
              Top = 154
              Width = 235
              Height = 17
              Caption = 'Удаление пользоват. документов'
              TabOrder = 6
            end
            object cbTransferEntryBalanceProcess: TCheckBox
              Left = 8
              Top = 178
              Width = 235
              Height = 17
              Caption = 'Копирование бухгалтерских остатков'
              Checked = True
              State = cbChecked
              TabOrder = 7
            end
          end
          object pnlProgressBar: TPanel
            Left = 2
            Top = 69
            Width = 672
            Height = 31
            Align = alBottom
            BevelOuter = bvNone
            BorderWidth = 11
            TabOrder = 2
            object pbMain: TProgressBar
              Left = 11
              Top = 4
              Width = 650
              Height = 16
              Align = alBottom
              Min = 0
              Max = 100
              Smooth = True
              Step = 0
              TabOrder = 0
            end
          end
          object btnRun: TButton
            Left = 220
            Top = 40
            Width = 73
            Height = 21
            Action = actRun
            TabOrder = 3
          end
        end
        object pnlGap: TPanel
          Left = 0
          Top = 175
          Width = 676
          Height = 5
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
        end
        object mOutput: TMemo
          Left = 0
          Top = 180
          Width = 676
          Height = 235
          Align = alClient
          Color = clBlack
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clLime
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          ScrollBars = ssVertical
          TabOrder = 2
          WantReturns = False
          WordWrap = False
        end
      end
      object tbsInvCardField: TTabSheet
        BorderWidth = 3
        Caption = 'Складская карточка'
        ImageIndex = 2
        object lblUnCheckedInvCard: TLabel
          Left = 8
          Top = 7
          Width = 111
          Height = 13
          Caption = 'Доступные признаки:'
        end
        object lblCheckedInvCard: TLabel
          Left = 356
          Top = 7
          Width = 113
          Height = 13
          Caption = 'Выбранные признаки:'
        end
        object lvAllInvCardField: TListView
          Left = 7
          Top = 22
          Width = 315
          Height = 383
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
        object btnInvCardSelectAll: TButton
          Left = 326
          Top = 176
          Width = 25
          Height = 23
          Action = actCardSelectAll
          TabOrder = 1
        end
        object btnInvCardSelectNone: TButton
          Left = 326
          Top = 200
          Width = 25
          Height = 23
          Action = actCardSelectNone
          TabOrder = 2
        end
        object lvCheckedInvCardField: TListView
          Left = 355
          Top = 22
          Width = 315
          Height = 383
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
          TabOrder = 3
          ViewStyle = vsReport
          OnDblClick = lvCheckedInvCardFieldDblClick
        end
      end
      object tbsDocumentType: TTabSheet
        BorderWidth = 3
        Caption = 'Типы документов'
        ImageIndex = 3
        object pnlDontDeleteDocumentType: TPanel
          Left = 6
          Top = 8
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
              Caption = 'Не удалять складские документы:'
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
          Left = 343
          Top = 7
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
              Caption = 'Удалять пользовательские документы:'
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
    Top = 457
    Width = 698
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object pnlBottomButtons: TPanel
      Left = 513
      Top = 0
      Width = 185
      Height = 30
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnClose: TButton
        Left = 105
        Top = 2
        Width = 75
        Height = 21
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
    object actCardSelectAll: TAction
      Category = 'InvCard'
      Caption = '>>'
      OnExecute = actCardSelectAllExecute
      OnUpdate = actCardSelectAllUpdate
    end
    object actCardSelectNone: TAction
      Category = 'InvCard'
      Caption = '<<'
      OnExecute = actCardSelectNoneExecute
      OnUpdate = actCardSelectNoneUpdate
    end
    object actRun: TAction
      Caption = 'Старт!'
      OnExecute = actRunExecute
      OnUpdate = actRunUpdate
    end
  end
end
