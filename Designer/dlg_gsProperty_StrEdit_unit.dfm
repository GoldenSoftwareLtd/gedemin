object dlgPropertyStrEdit: TdlgPropertyStrEdit
  Left = 260
  Top = 141
  Width = 460
  Height = 356
  HelpContext = 135
  Caption = 'Редактор строк'
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  PopupMenu = StringEditorMenu
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 435
    Height = 288
    Anchors = [akLeft, akTop, akRight, akBottom]
    Shape = bsFrame
  end
  object LineCount: TLabel
    Left = 104
    Top = 12
    Width = 77
    Height = 17
    AutoSize = False
    Caption = '0 '
  end
  object Label1: TLabel
    Left = 16
    Top = 12
    Width = 75
    Height = 13
    Caption = 'Кол-во строк:'
  end
  object HelpButton: TButton
    Left = 367
    Top = 303
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Помощь'
    TabOrder = 3
    OnClick = HelpButtonClick
  end
  object OKButton: TButton
    Left = 207
    Top = 303
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object CancelButton: TButton
    Left = 287
    Top = 303
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'О&тмена'
    ModalResult = 2
    TabOrder = 2
  end
  object Memo: TRichEdit
    Left = 16
    Top = 31
    Width = 419
    Height = 257
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideScrollBars = False
    PlainText = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
    OnChange = UpdateStatus
    OnKeyDown = Memo1KeyDown
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'TXT'
    Filter = 
      'Text files (*.TXT)|*.TXT|Config files (*.SYS;*.INI)|*.SYS;*.INI|' +
      'Batch files (*.BAT)|*.BAT|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofShowHelp, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Load string list'
    Left = 376
  end
  object SaveDialog: TSaveDialog
    Filter = 
      'Text files (*.TXT)|*.TXT|Config files (*.SYS;*.INI)|*.SYS;*.INI|' +
      'Batch files (*.BAT)|*.BAT|All files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofShowHelp, ofPathMustExist, ofEnableSizing]
    Title = 'Save string list'
    Left = 404
  end
  object StringEditorMenu: TPopupMenu
    Left = 344
    object LoadItem: TMenuItem
      Caption = '&Загрузить...'
      OnClick = FileOpen
    end
    object SaveItem: TMenuItem
      Caption = '&Сохранить...'
      OnClick = FileSave
    end
    object CodeEditorItem: TMenuItem
      Caption = '&Редактор кода...'
      Visible = False
    end
  end
end
