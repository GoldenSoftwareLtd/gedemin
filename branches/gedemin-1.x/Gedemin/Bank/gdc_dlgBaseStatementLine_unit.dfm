�
 TGDC_DLGBASESTATEMENTLINE 05  TPF0�Tgdc_dlgBaseStatementLinegdc_dlgBaseStatementLineLeftDTop� BorderWidthCaption������� ���������� �������ClientHeightOClientWidth�PixelsPerInch`
TextHeight � TLabelLabel2LeftTop}WidthFHeightCaption�����������:FocusControlibcmbCompany  �TLabelLabel3Left� Top4Width3HeightCaption� ���-��FocusControledtDocNumber  �TLabelLabel4Left� Top4WidthHeightCaption����FocusControldbeBank  �TLabelLabel5Left0Top4WidthHeightCaption����FocusControl
dbeAccount  �TLabelLabel6LeftTop4WidthLHeightCaption����� �������FocusControledtPaymentMode  �TLabelLabel7Left`Top4WidthFHeightCaption��� ��������FocusControledtOperationType  �TLabelLabel8LeftTop� WidthoHeightCaption���������� �������:FocusControl
memComment  �TLabelLabel9LeftTop� Width?HeightCaption
���������:FocusControl
edtCSumNCU  �TLabelLabel11LeftTop� Width<HeightCaption
����� ���:FocusControl
edtDSumNCU  �	TLabellbInfoLeftTopWidth%HeightCaption<Acc>Font.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.StylefsBold 
ParentFont  �
TLabellbInfo2LeftTopWidthBHeightCaption	<Company>Font.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.StylefsBold 
ParentFont  �TLabel
lbCurrencyLeftTop"Width&HeightCaption<Curr>Font.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.StylefsBold 
ParentFont  �TLabelLabel1LeftTop WidthsHeightCaption��������� ��������:FocusControledDoc  �TLabellblAcctAccountLeftTopWidth[HeightCaption���������� ����:  �TBevelBevel1Left Top1Width�HeightAlignalBottomShape	bsTopLine  �TButton	btnAccessLeft Top:AnchorsakLeftakBottom TabOrder  �TButtonbtnNewLeftGTop:AnchorsakLeftakBottom TabOrder  �TButtonbtnOKLeftTop:AnchorsakRightakBottom TabOrder
  �TgsIBLookupComboBoxibcmbCompanyLeft`TopyWidth>HeightHelpContextDatabasedmDatabase.ibdbGAdminTransaction
ibtrCommon
DataSource	dsgdcBase	DataFieldCOMPANYKEYLINE	ListTable
gd_contact	ListFieldnameKeyFieldid	Conditioncontacttype in (3,5)gdClassNameTgdcCompany
ItemHeightParentShowHintShowHint	TabOrder  �TDBEditedtDocNumberLeft� TopFWidthFHeight	DataField	DOCNUMBER
DataSource	dsgdcBaseTabOrder  �TDBEditedtOperationTypeLeft`TopFWidthMHeight	DataFieldOPERATIONTYPE
DataSource	dsgdcBaseTabOrder  �TDBEdit
edtCSumNCULeft`Top� WidthaHeight	DataFieldCSUMNCU
DataSource	dsgdcBaseTabOrder  �TDBEdit
edtDSumNCULeft`Top� WidthaHeight	DataFieldDSUMNCU
DataSource	dsgdcBaseTabOrder  �TDBEditedtPaymentModeLeftTopFWidthUHeight	DataFieldPAYMENTMODE
DataSource	dsgdcBaseTabOrder   �TDBMemo
memCommentLeft� Top� WidthHeight1	DataFieldCOMMENT
DataSource	dsgdcBaseTabOrder  �TButton	btnCancelLeft]Top:AnchorsakRightakBottom TabOrder  �TButtonbtnHelpLeft� Top:AnchorsakLeftakBottom TabOrder  �TEditedDocLeft� Top� WidthHeightReadOnly	TabOrder	  �TDBEdit
dbeAccountLeft0TopFWidthnHeight	DataFieldACCOUNT
DataSource	dsgdcBaseTabOrder  �TDBEditdbeBankLeft� TopFWidth1Height	DataFieldBANKCODE
DataSource	dsgdcBaseTabOrder  �	TCheckBoxcbDontRecalcLeftTop`Width� HeightCaption �� ������������� ������� �������TabOrder  �TgsIBLookupComboBoxiblkAccountKeyLeft� TopWidth� HeightHelpContextTransaction
ibtrCommon
DataSource	dsgdcBase	DataField
accountkey	ListTable
ac_account	ListFieldaliasKeyFieldID	Condition$ac_account.accounttype IN ('A', 'S')gdClassNameTgdcAcctAccount
ItemHeightParentShowHintShowHint	TabOrder  �TActionListalBaseLeftvTop�  TAction
actDocLinkCaption����������� ��������   �TDataSource	dsgdcBaseLeftXTop�   TIBSQLibsqlLeft� Top
   