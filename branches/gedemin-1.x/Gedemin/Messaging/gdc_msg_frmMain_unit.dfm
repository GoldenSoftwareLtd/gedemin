inherited gdc_msg_frmMain: Tgdc_msg_frmMain
  Left = 319
  Top = 265
  Width = 696
  Height = 659
  Caption = 'gdc_msg_frmMain'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 613
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 555
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 555
  end
  inherited TBDockBottom: TTBDock
    Top = 604
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 555
    inherited sMasterDetail: TSplitter
      Height = 452
    end
    inherited spChoose: TSplitter
      Top = 452
      Width = 670
    end
    inherited pnlMain: TPanel
      Height = 452
      inherited pnlSearchMain: TPanel
        Height = 452
        inherited sbSearchMain: TScrollBox
          Height = 414
        end
        inherited pnlSearchMainButton: TPanel
          Top = 414
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 452
        MainFolder = False
      end
    end
    inherited pnChoose: TPanel
      Top = 456
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
      inherited pnlChooseCaption: TPanel
        Width = 670
      end
    end
    inherited pnlDetail: TPanel
      Width = 500
      Height = 452
      object sMessageBottom: TSplitter [0]
        Left = 0
        Top = 182
        Width = 500
        Height = 4
        Cursor = crVSplit
        Align = alBottom
      end
      inherited TBDockDetail: TTBDock
        Width = 500
        inherited tbDetailToolbar: TTBToolbar
          object TBItem1: TTBItem
            Caption = 'Attachment'
            OnClick = TBItem1Click
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 343
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 156
        inherited sbSearchDetail: TScrollBox
          Height = 118
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 118
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 340
        Height = 156
      end
      object pnlMessageBody: TPanel
        Left = 0
        Top = 186
        Width = 500
        Height = 266
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
        object Splitter1: TSplitter
          Left = 0
          Top = 130
          Width = 500
          Height = 4
          Cursor = crVSplit
          Align = alTop
        end
        object TBDockMessage: TTBDock
          Left = 0
          Top = 0
          Width = 500
          Height = 9
        end
        object Panel1: TPanel
          Left = 0
          Top = 9
          Width = 500
          Height = 51
          Align = alTop
          BevelOuter = bvNone
          Color = clBtnHighlight
          TabOrder = 1
          object sbShowAttachment: TSpeedButton
            Left = 459
            Top = 0
            Width = 41
            Height = 51
            Action = actSaveAttachments
            Anchors = [akTop, akRight]
            Flat = True
            Glyph.Data = {
              36080000424D3608000000000000360400002800000020000000200000000100
              0800000000000004000000000000000000000001000000000000000000000000
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
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F70000000000F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              00FBFBFBFBFB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F700
              FBFB00A4A4A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7A4FB
              FB00F70000F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7A4FB
              A4F700FBFB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7A4FB
              A4A4FBA4A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7A4FB
              A4A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7A4FB
              A4F7A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7A4
              FB00F7A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              A4FB00F7A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7A4FB00F7A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7A4FB00F7A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7A4FB00F7A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7A4FB00F7A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7A4FB00F7A4FB00F7A4FB00F7A4FB00F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7A4FB00F7A4FB00F7A4A4F7F7A4FB00F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7A4FB00F7A4FB00F7F7F7F700FB00F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7A4FB00F7A4FB00F7F7F700FB00F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7A4FB00F7A4FB00000000FB00F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7A4FB00F7A4FBFBFBFB00F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7A4FB00F7A4A4A4A4F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7A4A4F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7
              F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7}
            ParentShowHint = False
            ShowHint = True
          end
          object Label1: TLabel
            Left = 7
            Top = 3
            Width = 44
            Height = 13
            Caption = 'От кого:'
          end
          object Label2: TLabel
            Left = 7
            Top = 19
            Width = 29
            Height = 13
            Caption = 'Кому:'
          end
          object DBText1: TDBText
            Left = 56
            Top = 3
            Width = 41
            Height = 13
            AutoSize = True
            DataField = 'FROMCONTACTNAME'
            DataSource = dsDetail
          end
          object DBText2: TDBText
            Left = 56
            Top = 19
            Width = 41
            Height = 13
            AutoSize = True
            DataField = 'TOCONTACTNAME'
            DataSource = dsDetail
          end
          object Label3: TLabel
            Left = 7
            Top = 35
            Width = 28
            Height = 13
            Caption = 'Тема:'
          end
          object DBText3: TDBText
            Left = 56
            Top = 35
            Width = 41
            Height = 13
            AutoSize = True
            DataField = 'SUBJECT'
            DataSource = dsDetail
          end
        end
        object dbmMessage: TDBMemo
          Left = 0
          Top = 60
          Width = 500
          Height = 70
          Align = alTop
          Constraints.MinHeight = 24
          DataField = 'BODY'
          DataSource = dsDetail
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 2
        end
        object ibgrHistory: TgsIBGrid
          Left = 0
          Top = 134
          Width = 500
          Height = 132
          HelpContext = 3
          Align = alClient
          BorderStyle = bsNone
          Ctl3D = True
          DataSource = dsbmHistory
          Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
          ParentCtl3D = False
          PopupMenu = pmDetail
          TabOrder = 3
          OnDblClick = ibgrDetailDblClick
          OnDragDrop = ibgrDetailDragDrop
          OnDragOver = ibgrDetailDragOver
          OnEnter = ibgrDetailEnter
          OnKeyDown = ibgrDetailKeyDown
          OnMouseMove = ibgrDetailMouseMove
          OnStartDrag = ibgrDetailStartDrag
          InternalMenuKind = imkWithSeparator
          Expands = <>
          ExpandsActive = False
          ExpandsSeparate = False
          TitlesExpanding = False
          Conditions = <>
          ConditionsActive = False
          CheckBox.Visible = False
          CheckBox.CheckBoxEvent = ibgrDetailClickCheck
          CheckBox.FirstColumn = False
          MinColWidth = 40
          ColumnEditors = <>
          Aliases = <>
          OnClickCheck = ibgrDetailClickCheck
        end
      end
    end
  end
  inherited alMain: TActionList
    object actSaveAttachments: TAction
      OnExecute = actSaveAttachmentsExecute
      OnUpdate = actSaveAttachmentsUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Left = 140
    Top = 89
  end
  inherited dsMain: TDataSource
    DataSet = gdcMessageBox
    Left = 148
    Top = 125
  end
  inherited dsDetail: TDataSource
    DataSet = gdcMessage
    Left = 448
    Top = 140
  end
  inherited pmDetail: TPopupMenu
    Left = 488
    Top = 144
  end
  object gdcMessageBox: TgdcMessageBox
    Left = 113
    Top = 121
  end
  object gdcMessage: TgdcBaseMessage
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByBoxLBRB'
    Left = 405
    Top = 137
  end
  object gdcAttachment: TgdcAttachment
    MasterSource = dsDetail
    MasterField = 'id'
    DetailField = 'messagekey'
    SubSet = 'ByMessage'
    Left = 565
    Top = 161
  end
  object gdcbmHistory: TgdcBaseMessage
    MasterSource = dsDetail
    MasterField = 'fromcontactkey'
    DetailField = 'CK'
    OnGetOrderClause = gdcbmHistoryGetOrderClause
    Left = 405
    Top = 249
  end
  object dsbmHistory: TDataSource
    DataSet = gdcbmHistory
    Left = 440
    Top = 252
  end
end
