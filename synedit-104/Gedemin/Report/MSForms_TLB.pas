unit MSForms_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.88.1.0.1.0  $
// File generated on 05.03.01 16:53:21 from Type Library described below.

// ************************************************************************ //
// Type Lib: C:\WINNT\system32\Fm20.dll (1)
// IID\LCID: {0D452EE1-E08F-101A-852E-02608C4D0BB4}\0
// Helpfile: C:\WINNT\System32\fm20.hlp
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\StdOle2.Tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
// Errors:
//   Hint: TypeInfo 'Label' changed to 'Label_'
//   Hint: Member 'Object' of 'IControl' changed to 'Object_'
//   Hint: Parameter 'Object' of IControl.Object changed to 'Object_'
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL, DbOleCtl;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  MSFormsMajorVersion = 2;
  MSFormsMinorVersion = 0;

  LIBID_MSForms: TGUID = '{0D452EE1-E08F-101A-852E-02608C4D0BB4}';

  IID_IFont: TGUID = '{BEF6E002-A874-101A-8BBA-00AA00300CAB}';
  DIID_Font: TGUID = '{BEF6E003-A874-101A-8BBA-00AA00300CAB}';
  IID_IDataAutoWrapper: TGUID = '{EC72F590-F375-11CE-B9E8-00AA006B1A69}';
  IID_IReturnInteger: TGUID = '{82B02370-B5BC-11CF-810F-00A0C9030074}';
  IID_IReturnBoolean: TGUID = '{82B02371-B5BC-11CF-810F-00A0C9030074}';
  IID_IReturnString: TGUID = '{82B02372-B5BC-11CF-810F-00A0C9030074}';
  IID_IReturnSingle: TGUID = '{8A683C90-BA84-11CF-8110-00A0C9030074}';
  IID_IReturnEffect: TGUID = '{8A683C91-BA84-11CF-8110-00A0C9030074}';
  CLASS_ReturnInteger: TGUID = '{82B02373-B5BC-11CF-810F-00A0C9030074}';
  CLASS_ReturnBoolean: TGUID = '{82B02374-B5BC-11CF-810F-00A0C9030074}';
  CLASS_ReturnString: TGUID = '{82B02375-B5BC-11CF-810F-00A0C9030074}';
  CLASS_ReturnSingle: TGUID = '{8A683C92-BA84-11CF-8110-00A0C9030074}';
  CLASS_ReturnEffect: TGUID = '{8A683C93-BA84-11CF-8110-00A0C9030074}';
  CLASS_DataObject: TGUID = '{1C3B4210-F441-11CE-B9EA-00AA006B1A69}';
  IID_IControl: TGUID = '{04598FC6-866C-11CF-AB7C-00AA00C08FCF}';
  IID_Controls: TGUID = '{04598FC7-866C-11CF-AB7C-00AA00C08FCF}';
  IID_IOptionFrame: TGUID = '{29B86A70-F52E-11CE-9BCE-00AA00608E01}';
  IID__UserForm: TGUID = '{04598FC8-866C-11CF-AB7C-00AA00C08FCF}';
  DIID_ControlEvents: TGUID = '{9A4BBF53-4E46-101B-8BBD-00AA003E3B29}';
  CLASS_Control: TGUID = '{909E0AE0-16DC-11CE-9E98-00AA00574A4F}';
  DIID_FormEvents: TGUID = '{5B9D8FC8-4A71-101B-97A6-00000B65C08B}';
  DIID_OptionFrameEvents: TGUID = '{CF3F94A0-F546-11CE-9BCE-00AA00608E01}';
  CLASS_UserForm: TGUID = '{C62A69F0-16DC-11CE-9E98-00AA00574A4F}';
  CLASS_Frame: TGUID = '{6E182020-F460-11CE-9BCD-00AA00608E01}';
  IID_ILabelControl: TGUID = '{04598FC1-866C-11CF-AB7C-00AA00C08FCF}';
  IID_ICommandButton: TGUID = '{04598FC4-866C-11CF-AB7C-00AA00C08FCF}';
  IID_IMdcText: TGUID = '{8BD21D13-EC42-11CE-9E0D-00AA006002F3}';
  IID_IMdcList: TGUID = '{8BD21D23-EC42-11CE-9E0D-00AA006002F3}';
  IID_IMdcCombo: TGUID = '{8BD21D33-EC42-11CE-9E0D-00AA006002F3}';
  IID_IMdcCheckBox: TGUID = '{8BD21D43-EC42-11CE-9E0D-00AA006002F3}';
  IID_IMdcOptionButton: TGUID = '{8BD21D53-EC42-11CE-9E0D-00AA006002F3}';
  IID_IMdcToggleButton: TGUID = '{8BD21D63-EC42-11CE-9E0D-00AA006002F3}';
  IID_IScrollbar: TGUID = '{04598FC3-866C-11CF-AB7C-00AA00C08FCF}';
  IID_Tab: TGUID = '{A38BFFC3-A5A0-11CE-8107-00AA00611080}';
  IID_Tabs: TGUID = '{944ACF93-A1E6-11CE-8104-00AA00611080}';
  IID_ITabStrip: TGUID = '{04598FC2-866C-11CF-AB7C-00AA00C08FCF}';
  IID_ISpinbutton: TGUID = '{79176FB3-B7F2-11CE-97EF-00AA006D2776}';
  IID_IImage: TGUID = '{4C599243-6926-101B-9992-00000B65C6F9}';
  IID_IWHTMLSubmitButton: TGUID = '{5512D111-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLImage: TGUID = '{5512D113-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLReset: TGUID = '{5512D115-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLCheckbox: TGUID = '{5512D117-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLOption: TGUID = '{5512D119-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLText: TGUID = '{5512D11B-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLHidden: TGUID = '{5512D11D-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLPassword: TGUID = '{5512D11F-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLSelect: TGUID = '{5512D123-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IWHTMLTextArea: TGUID = '{5512D125-5CC6-11CF-8D67-00AA00BDCE1D}';
  DIID_LabelControlEvents: TGUID = '{978C9E22-D4B0-11CE-BF2D-00AA003F40D0}';
  CLASS_Label_: TGUID = '{978C9E23-D4B0-11CE-BF2D-00AA003F40D0}';
  DIID_CommandButtonEvents: TGUID = '{7B020EC1-AF6C-11CE-9F46-00AA00574A4F}';
  CLASS_CommandButton: TGUID = '{D7053240-CE69-11CD-A777-00DD01143C57}';
  DIID_MdcTextEvents: TGUID = '{8BD21D12-EC42-11CE-9E0D-00AA006002F3}';
  CLASS_TextBox: TGUID = '{8BD21D10-EC42-11CE-9E0D-00AA006002F3}';
  DIID_MdcListEvents: TGUID = '{8BD21D22-EC42-11CE-9E0D-00AA006002F3}';
  CLASS_ListBox: TGUID = '{8BD21D20-EC42-11CE-9E0D-00AA006002F3}';
  DIID_MdcComboEvents: TGUID = '{8BD21D32-EC42-11CE-9E0D-00AA006002F3}';
  CLASS_ComboBox: TGUID = '{8BD21D30-EC42-11CE-9E0D-00AA006002F3}';
  DIID_MdcCheckBoxEvents: TGUID = '{8BD21D42-EC42-11CE-9E0D-00AA006002F3}';
  DIID_MdcOptionButtonEvents: TGUID = '{8BD21D52-EC42-11CE-9E0D-00AA006002F3}';
  DIID_MdcToggleButtonEvents: TGUID = '{8BD21D62-EC42-11CE-9E0D-00AA006002F3}';
  CLASS_CheckBox: TGUID = '{8BD21D40-EC42-11CE-9E0D-00AA006002F3}';
  CLASS_OptionButton: TGUID = '{8BD21D50-EC42-11CE-9E0D-00AA006002F3}';
  CLASS_ToggleButton: TGUID = '{8BD21D60-EC42-11CE-9E0D-00AA006002F3}';
  CLASS_NewFont: TGUID = '{AFC20920-DA4E-11CE-B943-00AA006887B4}';
  DIID_ScrollbarEvents: TGUID = '{7B020EC2-AF6C-11CE-9F46-00AA00574A4F}';
  CLASS_ScrollBar: TGUID = '{DFD181E0-5E2F-11CE-A449-00AA004A803D}';
  DIID_TabStripEvents: TGUID = '{7B020EC7-AF6C-11CE-9F46-00AA00574A4F}';
  CLASS_TabStrip: TGUID = '{EAE50EB0-4A62-11CE-BED6-00AA00611080}';
  DIID_SpinbuttonEvents: TGUID = '{79176FB2-B7F2-11CE-97EF-00AA006D2776}';
  CLASS_SpinButton: TGUID = '{79176FB0-B7F2-11CE-97EF-00AA006D2776}';
  DIID_ImageEvents: TGUID = '{4C5992A5-6926-101B-9992-00000B65C6F9}';
  CLASS_Image: TGUID = '{4C599241-6926-101B-9992-00000B65C6F9}';
  DIID_WHTMLControlEvents: TGUID = '{796ED650-5FE9-11CF-8D68-00AA00BDCE1D}';
  DIID_WHTMLControlEvents1: TGUID = '{47FF8FE0-6198-11CF-8CE8-00AA006CB389}';
  DIID_WHTMLControlEvents2: TGUID = '{47FF8FE1-6198-11CF-8CE8-00AA006CB389}';
  DIID_WHTMLControlEvents3: TGUID = '{47FF8FE2-6198-11CF-8CE8-00AA006CB389}';
  DIID_WHTMLControlEvents4: TGUID = '{47FF8FE3-6198-11CF-8CE8-00AA006CB389}';
  DIID_WHTMLControlEvents5: TGUID = '{47FF8FE4-6198-11CF-8CE8-00AA006CB389}';
  DIID_WHTMLControlEvents6: TGUID = '{47FF8FE5-6198-11CF-8CE8-00AA006CB389}';
  DIID_WHTMLControlEvents7: TGUID = '{47FF8FE6-6198-11CF-8CE8-00AA006CB389}';
  DIID_WHTMLControlEvents9: TGUID = '{47FF8FE8-6198-11CF-8CE8-00AA006CB389}';
  DIID_WHTMLControlEvents10: TGUID = '{47FF8FE9-6198-11CF-8CE8-00AA006CB389}';
  CLASS_HTMLSubmit: TGUID = '{5512D110-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLImage: TGUID = '{5512D112-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLReset: TGUID = '{5512D114-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLCheckbox: TGUID = '{5512D116-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLOption: TGUID = '{5512D118-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLText: TGUID = '{5512D11A-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLHidden: TGUID = '{5512D11C-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLPassword: TGUID = '{5512D11E-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLSelect: TGUID = '{5512D122-5CC6-11CF-8D67-00AA00BDCE1D}';
  CLASS_HTMLTextArea: TGUID = '{5512D124-5CC6-11CF-8D67-00AA00BDCE1D}';
  IID_IPage: TGUID = '{5CEF5613-713D-11CE-80C9-00AA00611080}';
  IID_Pages: TGUID = '{92E11A03-7358-11CE-80CB-00AA00611080}';
  IID_IMultiPage: TGUID = '{04598FC9-866C-11CF-AB7C-00AA00C08FCF}';
  DIID_MultiPageEvents: TGUID = '{7B020EC8-AF6C-11CE-9F46-00AA00574A4F}';
  CLASS_MultiPage: TGUID = '{46E31370-3F7A-11CE-BED6-00AA00611080}';
  CLASS_Page: TGUID = '{5CEF5610-713D-11CE-80C9-00AA00611080}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum fmDropEffect
type
  fmDropEffect = TOleEnum;
const
  fmDropEffectNone = $00000000;
  fmDropEffectCopy = $00000001;
  fmDropEffectMove = $00000002;
  fmDropEffectCopyOrMove = $00000003;

// Constants for enum fmAction
type
  fmAction = TOleEnum;
const
  fmActionCut = $00000000;
  fmActionCopy = $00000001;
  fmActionPaste = $00000002;
  fmActionDragDrop = $00000003;

// Constants for enum fmMode
type
  fmMode = TOleEnum;
const
  fmModeInherit = $FFFFFFFE;
  fmModeOn = $FFFFFFFF;
  fmModeOff = $00000000;

// Constants for enum fmMousePointer
type
  fmMousePointer = TOleEnum;
const
  fmMousePointerDefault = $00000000;
  fmMousePointerArrow = $00000001;
  fmMousePointerCross = $00000002;
  fmMousePointerIBeam = $00000003;
  fmMousePointerSizeNESW = $00000006;
  fmMousePointerSizeNS = $00000007;
  fmMousePointerSizeNWSE = $00000008;
  fmMousePointerSizeWE = $00000009;
  fmMousePointerUpArrow = $0000000A;
  fmMousePointerHourGlass = $0000000B;
  fmMousePointerNoDrop = $0000000C;
  fmMousePointerAppStarting = $0000000D;
  fmMousePointerHelp = $0000000E;
  fmMousePointerSizeAll = $0000000F;
  fmMousePointerCustom = $00000063;

// Constants for enum fmScrollBars
type
  fmScrollBars = TOleEnum;
const
  fmScrollBarsNone = $00000000;
  fmScrollBarsHorizontal = $00000001;
  fmScrollBarsVertical = $00000002;
  fmScrollBarsBoth = $00000003;

// Constants for enum fmScrollAction
type
  fmScrollAction = TOleEnum;
const
  fmScrollActionNoChange = $00000000;
  fmScrollActionLineUp = $00000001;
  fmScrollActionLineDown = $00000002;
  fmScrollActionPageUp = $00000003;
  fmScrollActionPageDown = $00000004;
  fmScrollActionBegin = $00000005;
  fmScrollActionEnd = $00000006;
  _fmScrollActionAbsoluteChange = $00000007;
  fmScrollActionPropertyChange = $00000008;
  fmScrollActionControlRequest = $00000009;
  fmScrollActionFocusRequest = $0000000A;

// Constants for enum fmCycle
type
  fmCycle = TOleEnum;
const
  fmCycleAllForms = $00000000;
  fmCycleCurrentForm = $00000002;

// Constants for enum fmZOrder
type
  fmZOrder = TOleEnum;
const
  fmZOrderFront = $00000000;
  fmZOrderBack = $00000001;

// Constants for enum fmBorderStyle
type
  fmBorderStyle = TOleEnum;
const
  fmBorderStyleNone = $00000000;
  fmBorderStyleSingle = $00000001;

// Constants for enum fmTextAlign
type
  fmTextAlign = TOleEnum;
const
  fmTextAlignLeft = $00000001;
  fmTextAlignCenter = $00000002;
  fmTextAlignRight = $00000003;

// Constants for enum fmAlignment
type
  fmAlignment = TOleEnum;
const
  fmAlignmentLeft = $00000000;
  fmAlignmentRight = $00000001;

// Constants for enum fmBorders
type
  fmBorders = TOleEnum;
const
  fmBordersNone = $00000000;
  fmBordersBox = $00000001;
  fmBordersLeft = $00000002;
  fmBordersTop = $00000003;

// Constants for enum fmBackStyle
type
  fmBackStyle = TOleEnum;
const
  fmBackStyleTransparent = $00000000;
  fmBackStyleOpaque = $00000001;

// Constants for enum fmButtonStyle
type
  fmButtonStyle = TOleEnum;
const
  fmButtonStylePushButton = $00000000;
  fmButtonStyleToggleButton = $00000001;

// Constants for enum fmPicPosition
type
  fmPicPosition = TOleEnum;
const
  fmPicPositionCenter = $00000000;
  fmPicPositionTopLeft = $00000001;
  fmPicPositionTopCenter = $00000002;
  fmPicPositionTopRight = $00000003;
  fmPicPositionCenterLeft = $00000004;
  fmPicPositionCenterRight = $00000005;
  fmPicPositionBottomLeft = $00000006;
  fmPicPositionBottomCenter = $00000007;
  fmPicPositionBottomRight = $00000008;

// Constants for enum fmVerticalScrollBarSide
type
  fmVerticalScrollBarSide = TOleEnum;
const
  fmVerticalScrollBarSideRight = $00000000;
  fmVerticalScrollBarSideLeft = $00000001;

// Constants for enum fmLayoutEffect
type
  fmLayoutEffect = TOleEnum;
const
  fmLayoutEffectNone = $00000000;
  fmLayoutEffectInitiate = $00000001;
  _fmLayoutEffectRespond = $00000002;

// Constants for enum fmSpecialEffect
type
  fmSpecialEffect = TOleEnum;
const
  fmSpecialEffectFlat = $00000000;
  fmSpecialEffectRaised = $00000001;
  fmSpecialEffectSunken = $00000002;
  fmSpecialEffectEtched = $00000003;
  fmSpecialEffectBump = $00000006;

// Constants for enum fmDragState
type
  fmDragState = TOleEnum;
const
  fmDragStateEnter = $00000000;
  fmDragStateLeave = $00000001;
  fmDragStateOver = $00000002;

// Constants for enum fmPictureSizeMode
type
  fmPictureSizeMode = TOleEnum;
const
  fmPictureSizeModeClip = $00000000;
  fmPictureSizeModeStretch = $00000001;
  fmPictureSizeModeZoom = $00000003;

// Constants for enum fmPictureAlignment
type
  fmPictureAlignment = TOleEnum;
const
  fmPictureAlignmentTopLeft = $00000000;
  fmPictureAlignmentTopRight = $00000001;
  fmPictureAlignmentCenter = $00000002;
  fmPictureAlignmentBottomLeft = $00000003;
  fmPictureAlignmentBottomRight = $00000004;

// Constants for enum fmButtonEffect
type
  fmButtonEffect = TOleEnum;
const
  fmButtonEffectFlat = $00000000;
  fmButtonEffectSunken = $00000002;

// Constants for enum fmOrientation
type
  fmOrientation = TOleEnum;
const
  fmOrientationAuto = $FFFFFFFF;
  fmOrientationVertical = $00000000;
  fmOrientationHorizontal = $00000001;

// Constants for enum fmSnapPoint
type
  fmSnapPoint = TOleEnum;
const
  fmSnapPointTopLeft = $00000000;
  fmSnapPointTopCenter = $00000001;
  fmSnapPointTopRight = $00000002;
  fmSnapPointCenterLeft = $00000003;
  fmSnapPointCenter = $00000004;
  fmSnapPointCenterRight = $00000005;
  fmSnapPointBottomLeft = $00000006;
  fmSnapPointBottomCenter = $00000007;
  fmSnapPointBottomRight = $00000008;

// Constants for enum fmPicturePosition
type
  fmPicturePosition = TOleEnum;
const
  fmPicturePositionLeftTop = $00000000;
  fmPicturePositionLeftCenter = $00000001;
  fmPicturePositionLeftBottom = $00000002;
  fmPicturePositionRightTop = $00000003;
  fmPicturePositionRightCenter = $00000004;
  fmPicturePositionRightBottom = $00000005;
  fmPicturePositionAboveLeft = $00000006;
  fmPicturePositionAboveCenter = $00000007;
  fmPicturePositionAboveRight = $00000008;
  fmPicturePositionBelowLeft = $00000009;
  fmPicturePositionBelowCenter = $0000000A;
  fmPicturePositionBelowRight = $0000000B;
  fmPicturePositionCenter = $0000000C;

// Constants for enum fmDisplayStyle
type
  fmDisplayStyle = TOleEnum;
const
  fmDisplayStyleText = $00000001;
  fmDisplayStyleList = $00000002;
  fmDisplayStyleCombo = $00000003;
  fmDisplayStyleCheckBox = $00000004;
  fmDisplayStyleOptionButton = $00000005;
  fmDisplayStyleToggle = $00000006;
  fmDisplayStyleDropList = $00000007;

// Constants for enum fmShowListWhen
type
  fmShowListWhen = TOleEnum;
const
  fmShowListWhenNever = $00000000;
  fmShowListWhenButton = $00000001;
  fmShowListWhenFocus = $00000002;
  fmShowListWhenAlways = $00000003;

// Constants for enum fmShowDropButtonWhen
type
  fmShowDropButtonWhen = TOleEnum;
const
  fmShowDropButtonWhenNever = $00000000;
  fmShowDropButtonWhenFocus = $00000001;
  fmShowDropButtonWhenAlways = $00000002;

// Constants for enum fmMultiSelect
type
  fmMultiSelect = TOleEnum;
const
  fmMultiSelectSingle = $00000000;
  fmMultiSelectMulti = $00000001;
  fmMultiSelectExtended = $00000002;

// Constants for enum fmListStyle
type
  fmListStyle = TOleEnum;
const
  fmListStylePlain = $00000000;
  fmListStyleOption = $00000001;

// Constants for enum fmEnterFieldBehavior
type
  fmEnterFieldBehavior = TOleEnum;
const
  fmEnterFieldBehaviorSelectAll = $00000000;
  fmEnterFieldBehaviorRecallSelection = $00000001;

// Constants for enum fmDragBehavior
type
  fmDragBehavior = TOleEnum;
const
  fmDragBehaviorDisabled = $00000000;
  fmDragBehaviorEnabled = $00000001;

// Constants for enum fmMatchEntry
type
  fmMatchEntry = TOleEnum;
const
  fmMatchEntryFirstLetter = $00000000;
  fmMatchEntryComplete = $00000001;
  fmMatchEntryNone = $00000002;

// Constants for enum fmDropButtonStyle
type
  fmDropButtonStyle = TOleEnum;
const
  fmDropButtonStylePlain = $00000000;
  fmDropButtonStyleArrow = $00000001;
  fmDropButtonStyleEllipsis = $00000002;
  fmDropButtonStyleReduce = $00000003;

// Constants for enum fmStyle
type
  fmStyle = TOleEnum;
const
  fmStyleDropDownCombo = $00000000;
  fmStyleDropDownList = $00000002;

// Constants for enum fmTabOrientation
type
  fmTabOrientation = TOleEnum;
const
  fmTabOrientationTop = $00000000;
  fmTabOrientationBottom = $00000001;
  fmTabOrientationLeft = $00000002;
  fmTabOrientationRight = $00000003;

// Constants for enum fmTabStyle
type
  fmTabStyle = TOleEnum;
const
  fmTabStyleTabs = $00000000;
  fmTabStyleButtons = $00000001;
  fmTabStyleNone = $00000002;

// Constants for enum fmIMEMode
type
  fmIMEMode = TOleEnum;
const
  fmIMEModeNoControl = $00000000;
  fmIMEModeOn = $00000001;
  fmIMEModeOff = $00000002;
  fmIMEModeDisable = $00000003;
  fmIMEModeHiragana = $00000004;
  fmIMEModeKatakana = $00000005;
  fmIMEModeKatakanaHalf = $00000006;
  fmIMEModeAlphaFull = $00000007;
  fmIMEModeAlpha = $00000008;
  fmIMEModeHangulFull = $00000009;
  fmIMEModeHangul = $0000000A;
  fmIMEModeHanziFull = $0000000B;
  fmIMEModeHanzi = $0000000C;

// Constants for enum fmTransitionEffect
type
  fmTransitionEffect = TOleEnum;
const
  fmTransitionEffectNone = $00000000;
  fmTransitionEffectCoverUp = $00000001;
  fmTransitionEffectCoverRightUp = $00000002;
  fmTransitionEffectCoverRight = $00000003;
  fmTransitionEffectCoverRightDown = $00000004;
  fmTransitionEffectCoverDown = $00000005;
  fmTransitionEffectCoverLeftDown = $00000006;
  fmTransitionEffectCoverLeft = $00000007;
  fmTransitionEffectCoverLeftUp = $00000008;
  fmTransitionEffectPushUp = $00000009;
  fmTransitionEffectPushRight = $0000000A;
  fmTransitionEffectPushDown = $0000000B;
  fmTransitionEffectPushLeft = $0000000C;

// Constants for enum fmListBoxStyles
type
  fmListBoxStyles = TOleEnum;
const
  _fmListBoxStylesNone = $00000000;
  _fmListBoxStylesListBox = $00000001;
  _fmListBoxStylesComboBox = $00000002;

// Constants for enum fmRepeatDirection
type
  fmRepeatDirection = TOleEnum;
const
  _fmRepeatDirectionHorizontal = $00000000;
  _fmRepeatDirectionVertical = $00000001;

// Constants for enum fmEnAutoSize
type
  fmEnAutoSize = TOleEnum;
const
  _fmEnAutoSizeNone = $00000000;
  _fmEnAutoSizeHorizontal = $00000001;
  _fmEnAutoSizeVertical = $00000002;
  _fmEnAutoSizeBoth = $00000003;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IFont = interface;
  Font = dispinterface;
  IDataAutoWrapper = interface;
  IDataAutoWrapperDisp = dispinterface;
  IReturnInteger = interface;
  IReturnIntegerDisp = dispinterface;
  IReturnBoolean = interface;
  IReturnBooleanDisp = dispinterface;
  IReturnString = interface;
  IReturnStringDisp = dispinterface;
  IReturnSingle = interface;
  IReturnSingleDisp = dispinterface;
  IReturnEffect = interface;
  IReturnEffectDisp = dispinterface;
  IControl = interface;
  IControlDisp = dispinterface;
  Controls = interface;
  ControlsDisp = dispinterface;
  IOptionFrame = interface;
  IOptionFrameDisp = dispinterface;
  _UserForm = interface;
  _UserFormDisp = dispinterface;
  ControlEvents = dispinterface;
  FormEvents = dispinterface;
  OptionFrameEvents = dispinterface;
  ILabelControl = interface;
  ILabelControlDisp = dispinterface;
  ICommandButton = interface;
  ICommandButtonDisp = dispinterface;
  IMdcText = interface;
  IMdcTextDisp = dispinterface;
  IMdcList = interface;
  IMdcListDisp = dispinterface;
  IMdcCombo = interface;
  IMdcComboDisp = dispinterface;
  IMdcCheckBox = interface;
  IMdcCheckBoxDisp = dispinterface;
  IMdcOptionButton = interface;
  IMdcOptionButtonDisp = dispinterface;
  IMdcToggleButton = interface;
  IMdcToggleButtonDisp = dispinterface;
  IScrollbar = interface;
  IScrollbarDisp = dispinterface;
  Tab = interface;
  TabDisp = dispinterface;
  Tabs = interface;
  TabsDisp = dispinterface;
  ITabStrip = interface;
  ITabStripDisp = dispinterface;
  ISpinbutton = interface;
  ISpinbuttonDisp = dispinterface;
  IImage = interface;
  IImageDisp = dispinterface;
  IWHTMLSubmitButton = interface;
  IWHTMLSubmitButtonDisp = dispinterface;
  IWHTMLImage = interface;
  IWHTMLImageDisp = dispinterface;
  IWHTMLReset = interface;
  IWHTMLResetDisp = dispinterface;
  IWHTMLCheckbox = interface;
  IWHTMLCheckboxDisp = dispinterface;
  IWHTMLOption = interface;
  IWHTMLOptionDisp = dispinterface;
  IWHTMLText = interface;
  IWHTMLTextDisp = dispinterface;
  IWHTMLHidden = interface;
  IWHTMLHiddenDisp = dispinterface;
  IWHTMLPassword = interface;
  IWHTMLPasswordDisp = dispinterface;
  IWHTMLSelect = interface;
  IWHTMLSelectDisp = dispinterface;
  IWHTMLTextArea = interface;
  IWHTMLTextAreaDisp = dispinterface;
  LabelControlEvents = dispinterface;
  CommandButtonEvents = dispinterface;
  MdcTextEvents = dispinterface;
  MdcListEvents = dispinterface;
  MdcComboEvents = dispinterface;
  MdcCheckBoxEvents = dispinterface;
  MdcOptionButtonEvents = dispinterface;
  MdcToggleButtonEvents = dispinterface;
  ScrollbarEvents = dispinterface;
  TabStripEvents = dispinterface;
  SpinbuttonEvents = dispinterface;
  ImageEvents = dispinterface;
  WHTMLControlEvents = dispinterface;
  WHTMLControlEvents1 = dispinterface;
  WHTMLControlEvents2 = dispinterface;
  WHTMLControlEvents3 = dispinterface;
  WHTMLControlEvents4 = dispinterface;
  WHTMLControlEvents5 = dispinterface;
  WHTMLControlEvents6 = dispinterface;
  WHTMLControlEvents7 = dispinterface;
  WHTMLControlEvents9 = dispinterface;
  WHTMLControlEvents10 = dispinterface;
  IPage = interface;
  IPageDisp = dispinterface;
  Pages = interface;
  PagesDisp = dispinterface;
  IMultiPage = interface;
  IMultiPageDisp = dispinterface;
  MultiPageEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  ReturnInteger = IReturnInteger;
  ReturnBoolean = IReturnBoolean;
  ReturnString = IReturnString;
  ReturnSingle = IReturnSingle;
  ReturnEffect = IReturnEffect;
  DataObject = IDataAutoWrapper;
  Control = IControl;
  UserForm = _UserForm;
  Frame = IOptionFrame;
  Label_ = ILabelControl;
  CommandButton = ICommandButton;
  TextBox = IMdcText;
  ListBox = IMdcList;
  ComboBox = IMdcCombo;
  CheckBox = IMdcCheckBox;
  OptionButton = IMdcOptionButton;
  ToggleButton = IMdcToggleButton;
  NewFont = Font;
  ScrollBar = IScrollbar;
  TabStrip = ITabStrip;
  SpinButton = ISpinbutton;
  Image = IImage;
  HTMLSubmit = IWHTMLSubmitButton;
  HTMLImage = IWHTMLImage;
  HTMLReset = IWHTMLReset;
  HTMLCheckbox = IWHTMLCheckbox;
  HTMLOption = IWHTMLOption;
  HTMLText = IWHTMLText;
  HTMLHidden = IWHTMLHidden;
  HTMLPassword = IWHTMLPassword;
  HTMLSelect = IWHTMLSelect;
  HTMLTextArea = IWHTMLTextArea;
  MultiPage = IMultiPage;
  Page = IPage;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  POleVariant1 = ^OleVariant; {*}
  PInteger1 = ^Integer; {*}

  OLE_COLOR = Integer; 
  OLE_HANDLE = Integer; 
  OLE_OPTEXCLUSIVE = WordBool; 
  PIROWSET = IUnknown; 

// *********************************************************************//
// Interface: IFont
// Flags:     (16) Hidden
// GUID:      {BEF6E002-A874-101A-8BBA-00AA00300CAB}
// *********************************************************************//
  IFont = interface(IUnknown)
    ['{BEF6E002-A874-101A-8BBA-00AA00300CAB}']
    function  Get_Name(out pname: WideString): HResult; stdcall;
    function  Set_Name(const pname: WideString): HResult; stdcall;
    function  Get_Size(out psize: Currency): HResult; stdcall;
    function  Set_Size(psize: Currency): HResult; stdcall;
    function  Get_Bold(out pbold: WordBool): HResult; stdcall;
    function  Set_Bold(pbold: WordBool): HResult; stdcall;
    function  Get_Italic(out pitalic: WordBool): HResult; stdcall;
    function  Set_Italic(pitalic: WordBool): HResult; stdcall;
    function  Get_Underline(out punderline: WordBool): HResult; stdcall;
    function  Set_Underline(punderline: WordBool): HResult; stdcall;
    function  Get_Strikethrough(out pstrikethrough: WordBool): HResult; stdcall;
    function  Set_Strikethrough(pstrikethrough: WordBool): HResult; stdcall;
    function  Get_Weight(out pweight: Smallint): HResult; stdcall;
    function  Set_Weight(pweight: Smallint): HResult; stdcall;
    function  Get_Charset(out pcharset: Smallint): HResult; stdcall;
    function  Set_Charset(pcharset: Smallint): HResult; stdcall;
    function  Get_hFont(out phfont: OLE_HANDLE): HResult; stdcall;
    function  Clone(out lplpfont: IFont): HResult; stdcall;
    function  IsEqual(const lpFontOther: IFont): HResult; stdcall;
    function  SetRatio(cyLogical: Integer; cyHimetric: Integer): HResult; stdcall;
    function  AddRefHfont(hFont: OLE_HANDLE): HResult; stdcall;
    function  ReleaseHfont(hFont: OLE_HANDLE): HResult; stdcall;
  end;

// *********************************************************************//
// DispIntf:  Font
// Flags:     (4096) Dispatchable
// GUID:      {BEF6E003-A874-101A-8BBA-00AA00300CAB}
// *********************************************************************//
  Font = dispinterface
    ['{BEF6E003-A874-101A-8BBA-00AA00300CAB}']
    property Name: WideString dispid 0;
    property Size: Currency dispid 2;
    property Bold: WordBool dispid 3;
    property Italic: WordBool dispid 4;
    property Underline: WordBool dispid 5;
    property Strikethrough: WordBool dispid 6;
    property Weight: Smallint dispid 7;
    property Charset: Smallint dispid 8;
  end;

// *********************************************************************//
// Interface: IDataAutoWrapper
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {EC72F590-F375-11CE-B9E8-00AA006B1A69}
// *********************************************************************//
  IDataAutoWrapper = interface(IDispatch)
    ['{EC72F590-F375-11CE-B9E8-00AA006B1A69}']
    procedure Clear; safecall;
    function  GetFormat(Format: OleVariant): WordBool; safecall;
    function  GetText(Format: OleVariant): WideString; safecall;
    procedure SetText(const Text: WideString; Format: OleVariant); safecall;
    procedure PutInClipboard; safecall;
    procedure GetFromClipboard; safecall;
    function  StartDrag(OKEffect: OleVariant): fmDropEffect; safecall;
  end;

// *********************************************************************//
// DispIntf:  IDataAutoWrapperDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {EC72F590-F375-11CE-B9E8-00AA006B1A69}
// *********************************************************************//
  IDataAutoWrapperDisp = dispinterface
    ['{EC72F590-F375-11CE-B9E8-00AA006B1A69}']
    procedure Clear; dispid 1610743808;
    function  GetFormat(Format: OleVariant): WordBool; dispid 1610743809;
    function  GetText(Format: OleVariant): WideString; dispid 1610743810;
    procedure SetText(const Text: WideString; Format: OleVariant); dispid 1610743811;
    procedure PutInClipboard; dispid 1610743812;
    procedure GetFromClipboard; dispid 1610743813;
    function  StartDrag(OKEffect: OleVariant): fmDropEffect; dispid 1610743814;
  end;

// *********************************************************************//
// Interface: IReturnInteger
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {82B02370-B5BC-11CF-810F-00A0C9030074}
// *********************************************************************//
  IReturnInteger = interface(IDispatch)
    ['{82B02370-B5BC-11CF-810F-00A0C9030074}']
    procedure Set_Value(Value: SYSINT); safecall;
    function  Get_Value: SYSINT; safecall;
    property Value: SYSINT read Get_Value write Set_Value;
  end;

// *********************************************************************//
// DispIntf:  IReturnIntegerDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {82B02370-B5BC-11CF-810F-00A0C9030074}
// *********************************************************************//
  IReturnIntegerDisp = dispinterface
    ['{82B02370-B5BC-11CF-810F-00A0C9030074}']
    property Value: SYSINT dispid 0;
  end;

// *********************************************************************//
// Interface: IReturnBoolean
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {82B02371-B5BC-11CF-810F-00A0C9030074}
// *********************************************************************//
  IReturnBoolean = interface(IDispatch)
    ['{82B02371-B5BC-11CF-810F-00A0C9030074}']
    procedure Set_Value(Value: WordBool); safecall;
    function  Get_Value: WordBool; safecall;
    property Value: WordBool read Get_Value write Set_Value;
  end;

// *********************************************************************//
// DispIntf:  IReturnBooleanDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {82B02371-B5BC-11CF-810F-00A0C9030074}
// *********************************************************************//
  IReturnBooleanDisp = dispinterface
    ['{82B02371-B5BC-11CF-810F-00A0C9030074}']
    property Value: WordBool dispid 0;
  end;

// *********************************************************************//
// Interface: IReturnString
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {82B02372-B5BC-11CF-810F-00A0C9030074}
// *********************************************************************//
  IReturnString = interface(IDispatch)
    ['{82B02372-B5BC-11CF-810F-00A0C9030074}']
    procedure Set_Value(const Value: WideString); safecall;
    function  Get_Value: WideString; safecall;
    property Value: WideString read Get_Value write Set_Value;
  end;

// *********************************************************************//
// DispIntf:  IReturnStringDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {82B02372-B5BC-11CF-810F-00A0C9030074}
// *********************************************************************//
  IReturnStringDisp = dispinterface
    ['{82B02372-B5BC-11CF-810F-00A0C9030074}']
    property Value: WideString dispid 0;
  end;

// *********************************************************************//
// Interface: IReturnSingle
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8A683C90-BA84-11CF-8110-00A0C9030074}
// *********************************************************************//
  IReturnSingle = interface(IDispatch)
    ['{8A683C90-BA84-11CF-8110-00A0C9030074}']
    procedure Set_Value(Value: Single); safecall;
    function  Get_Value: Single; safecall;
    property Value: Single read Get_Value write Set_Value;
  end;

// *********************************************************************//
// DispIntf:  IReturnSingleDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8A683C90-BA84-11CF-8110-00A0C9030074}
// *********************************************************************//
  IReturnSingleDisp = dispinterface
    ['{8A683C90-BA84-11CF-8110-00A0C9030074}']
    property Value: Single dispid 0;
  end;

// *********************************************************************//
// Interface: IReturnEffect
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8A683C91-BA84-11CF-8110-00A0C9030074}
// *********************************************************************//
  IReturnEffect = interface(IDispatch)
    ['{8A683C91-BA84-11CF-8110-00A0C9030074}']
    procedure Set_Value(Value: fmDropEffect); safecall;
    function  Get_Value: fmDropEffect; safecall;
    property Value: fmDropEffect read Get_Value write Set_Value;
  end;

// *********************************************************************//
// DispIntf:  IReturnEffectDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8A683C91-BA84-11CF-8110-00A0C9030074}
// *********************************************************************//
  IReturnEffectDisp = dispinterface
    ['{8A683C91-BA84-11CF-8110-00A0C9030074}']
    property Value: fmDropEffect dispid 0;
  end;

// *********************************************************************//
// Interface: IControl
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {04598FC6-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  IControl = interface(IDispatch)
    ['{04598FC6-866C-11CF-AB7C-00AA00C08FCF}']
    procedure Set_Cancel(Cancel: WordBool); safecall;
    function  Get_Cancel: WordBool; safecall;
    procedure Set_ControlSource(const ControlSource: WideString); safecall;
    function  Get_ControlSource: WideString; safecall;
    procedure Set_ControlTipText(const ControlTipText: WideString); safecall;
    function  Get_ControlTipText: WideString; safecall;
    procedure Set_Default(Default: WordBool); safecall;
    function  Get_Default: WordBool; safecall;
    procedure _SetHeight(Height: Integer); safecall;
    procedure _GetHeight(out Height: Integer); safecall;
    procedure Set_Height(Height: Single); safecall;
    function  Get_Height: Single; safecall;
    procedure Set_HelpContextID(HelpContextID: Integer); safecall;
    function  Get_HelpContextID: Integer; safecall;
    procedure Set_InSelection(InSelection: WordBool); safecall;
    function  Get_InSelection: WordBool; safecall;
    function  Get_LayoutEffect: fmLayoutEffect; safecall;
    procedure _SetLeft(Left: Integer); safecall;
    procedure _GetLeft(out Left: Integer); safecall;
    procedure Set_Left(Left: Single); safecall;
    function  Get_Left: Single; safecall;
    procedure Set_Name(const Name: WideString); safecall;
    function  Get_Name: WideString; safecall;
    procedure _GetOldHeight(out OldHeight: Integer); safecall;
    function  Get_OldHeight: Single; safecall;
    procedure _GetOldLeft(out OldLeft: Integer); safecall;
    function  Get_OldLeft: Single; safecall;
    procedure _GetOldTop(out OldTop: Integer); safecall;
    function  Get_OldTop: Single; safecall;
    procedure _GetOldWidth(out OldWidth: Integer); safecall;
    function  Get_OldWidth: Single; safecall;
    function  Get_Object_: IDispatch; safecall;
    function  Get_Parent: IDispatch; safecall;
    procedure Set_RowSource(const RowSource: WideString); safecall;
    function  Get_RowSource: WideString; safecall;
    procedure Set_RowSourceType(RowSourceType: Smallint); safecall;
    function  Get_RowSourceType: Smallint; safecall;
    procedure Set_TabIndex(TabIndex: Smallint); safecall;
    function  Get_TabIndex: Smallint; safecall;
    procedure Set_TabStop(TabStop: WordBool); safecall;
    function  Get_TabStop: WordBool; safecall;
    procedure Set_Tag(const Tag: WideString); safecall;
    function  Get_Tag: WideString; safecall;
    procedure _SetTop(Top: Integer); safecall;
    procedure _GetTop(out Top: Integer); safecall;
    procedure Set_Top(Top: Single); safecall;
    function  Get_Top: Single; safecall;
    procedure Set_BoundValue(var BoundValue: OleVariant); safecall;
    function  Get_BoundValue: OleVariant; safecall;
    procedure Set_Visible(Visible: WordBool); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure _SetWidth(Width: Integer); safecall;
    procedure _GetWidth(out Width: Integer); safecall;
    procedure Set_Width(Width: Single); safecall;
    function  Get_Width: Single; safecall;
    procedure Move(Left: OleVariant; Top: OleVariant; Width: OleVariant; Height: OleVariant; 
                   Layout: OleVariant); safecall;
    procedure ZOrder(zPosition: OleVariant); safecall;
    procedure Select(SelectInGroup: WordBool); safecall;
    procedure SetFocus; safecall;
    function  _GethWnd: SYSINT; safecall;
    function  _GetID: Integer; safecall;
    procedure _Move(Left: Integer; Top: Integer; Width: Integer; Height: Integer); safecall;
    procedure _ZOrder(zPosition: fmZOrder); safecall;
    property Cancel: WordBool read Get_Cancel write Set_Cancel;
    property ControlSource: WideString read Get_ControlSource write Set_ControlSource;
    property ControlTipText: WideString read Get_ControlTipText write Set_ControlTipText;
    property Default: WordBool read Get_Default write Set_Default;
    property Height: Single read Get_Height write Set_Height;
    property HelpContextID: Integer read Get_HelpContextID write Set_HelpContextID;
    property InSelection: WordBool read Get_InSelection write Set_InSelection;
    property LayoutEffect: fmLayoutEffect read Get_LayoutEffect;
    property Left: Single read Get_Left write Set_Left;
    property Name: WideString read Get_Name write Set_Name;
    property OldHeight: Single read Get_OldHeight;
    property OldLeft: Single read Get_OldLeft;
    property OldTop: Single read Get_OldTop;
    property OldWidth: Single read Get_OldWidth;
    property Object_: IDispatch read Get_Object_;
    property Parent: IDispatch read Get_Parent;
    property RowSource: WideString read Get_RowSource write Set_RowSource;
    property RowSourceType: Smallint read Get_RowSourceType write Set_RowSourceType;
    property TabIndex: Smallint read Get_TabIndex write Set_TabIndex;
    property TabStop: WordBool read Get_TabStop write Set_TabStop;
    property Tag: WideString read Get_Tag write Set_Tag;
    property Top: Single read Get_Top write Set_Top;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Width: Single read Get_Width write Set_Width;
  end;

// *********************************************************************//
// DispIntf:  IControlDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {04598FC6-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  IControlDisp = dispinterface
    ['{04598FC6-866C-11CF-AB7C-00AA00C08FCF}']
    property Cancel: WordBool dispid -2147418056;
    property ControlSource: WideString dispid -2147385343;
    property ControlTipText: WideString dispid -2147418043;
    property Default: WordBool dispid -2147418057;
    procedure _SetHeight(Height: Integer); dispid 1610743816;
    procedure _GetHeight(out Height: Integer); dispid 1610743817;
    property Height: Single dispid -2147418106;
    property HelpContextID: Integer dispid -2147418062;
    property InSelection: WordBool dispid -2147385341;
    property LayoutEffect: fmLayoutEffect readonly dispid -2147385340;
    procedure _SetLeft(Left: Integer); dispid 1610743825;
    procedure _GetLeft(out Left: Integer); dispid 1610743826;
    property Left: Single dispid -2147418109;
    property Name: WideString dispid -2147418112;
    procedure _GetOldHeight(out OldHeight: Integer); dispid 1610743831;
    property OldHeight: Single readonly dispid -2147385339;
    procedure _GetOldLeft(out OldLeft: Integer); dispid 1610743833;
    property OldLeft: Single readonly dispid -2147385338;
    procedure _GetOldTop(out OldTop: Integer); dispid 1610743835;
    property OldTop: Single readonly dispid -2147385337;
    procedure _GetOldWidth(out OldWidth: Integer); dispid 1610743837;
    property OldWidth: Single readonly dispid -2147385336;
    property Object_: IDispatch readonly dispid -2147385335;
    property Parent: IDispatch readonly dispid -2147418104;
    property RowSource: WideString dispid -2147385330;
    property RowSourceType: Smallint dispid -2147385329;
    property TabIndex: Smallint dispid -2147418097;
    property TabStop: WordBool dispid -2147418098;
    property Tag: WideString dispid -2147418101;
    procedure _SetTop(Top: Integer); dispid 1610743851;
    procedure _GetTop(out Top: Integer); dispid 1610743852;
    property Top: Single dispid -2147418108;
    function  BoundValue: {??POleVariant1} OleVariant; dispid -2147385328;
    property Visible: WordBool dispid -2147418105;
    procedure _SetWidth(Width: Integer); dispid 1610743859;
    procedure _GetWidth(out Width: Integer); dispid 1610743860;
    property Width: Single dispid -2147418107;
    procedure Move(Left: OleVariant; Top: OleVariant; Width: OleVariant; Height: OleVariant; 
                   Layout: OleVariant); dispid -2147385088;
    procedure ZOrder(zPosition: OleVariant); dispid -2147385083;
    procedure Select(SelectInGroup: WordBool); dispid -2147385086;
    procedure SetFocus; dispid -2147385085;
    function  _GethWnd: SYSINT; dispid 1610743867;
    function  _GetID: Integer; dispid 1610743868;
    procedure _Move(Left: Integer; Top: Integer; Width: Integer; Height: Integer); dispid 1610743869;
    procedure _ZOrder(zPosition: fmZOrder); dispid 1610743870;
  end;

// *********************************************************************//
// Interface: Controls
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {04598FC7-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  Controls = interface(IDispatch)
    ['{04598FC7-866C-11CF-AB7C-00AA00C08FCF}']
    function  Get_Count: Integer; safecall;
    function  Get__NewEnum: IUnknown; safecall;
    function  Item(varg: OleVariant): IDispatch; safecall;
    procedure Clear; safecall;
    procedure _Move(cx: Integer; cy: Integer); safecall;
    procedure SelectAll; safecall;
    function  _AddByClass(var clsid: Integer): Control; safecall;
    procedure AlignToGrid; safecall;
    procedure BringForward; safecall;
    procedure BringToFront; safecall;
    procedure Copy; safecall;
    procedure Cut; safecall;
    function  Enum: IUnknown; safecall;
    function  _GetItemByIndex(lIndex: Integer): Control; safecall;
    function  _GetItemByName(const pstr: WideString): Control; safecall;
    function  _GetItemByID(ID: Integer): Control; safecall;
    procedure SendBackward; safecall;
    procedure SendToBack; safecall;
    procedure Move(cx: Single; cy: Single); safecall;
    function  Add(const bstrProgID: WideString; Name: OleVariant; Visible: OleVariant): Control; safecall;
    procedure Remove(varg: OleVariant); safecall;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  ControlsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {04598FC7-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  ControlsDisp = dispinterface
    ['{04598FC7-866C-11CF-AB7C-00AA00C08FCF}']
    property Count: Integer readonly dispid 60;
    property _NewEnum: IUnknown readonly dispid -4;
    function  Item(varg: OleVariant): IDispatch; dispid 0;
    procedure Clear; dispid 62;
    procedure _Move(cx: Integer; cy: Integer); dispid 1610743812;
    procedure SelectAll; dispid 65;
    function  _AddByClass(var clsid: Integer): Control; dispid 1610743814;
    procedure AlignToGrid; dispid 1610743815;
    procedure BringForward; dispid 1610743816;
    procedure BringToFront; dispid 1610743817;
    procedure Copy; dispid 1610743818;
    procedure Cut; dispid 1610743819;
    function  Enum: IUnknown; dispid 1610743820;
    function  _GetItemByIndex(lIndex: Integer): Control; dispid 1610743821;
    function  _GetItemByName(const pstr: WideString): Control; dispid 1610743822;
    function  _GetItemByID(ID: Integer): Control; dispid 1610743823;
    procedure SendBackward; dispid 1610743824;
    procedure SendToBack; dispid 1610743825;
    procedure Move(cx: Single; cy: Single); dispid 63;
    function  Add(const bstrProgID: WideString; Name: OleVariant; Visible: OleVariant): Control; dispid 66;
    procedure Remove(varg: OleVariant); dispid 67;
  end;

// *********************************************************************//
// Interface: IOptionFrame
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {29B86A70-F52E-11CE-9BCE-00AA00608E01}
// *********************************************************************//
  IOptionFrame = interface(IDispatch)
    ['{29B86A70-F52E-11CE-9BCE-00AA00608E01}']
    function  Get_ActiveControl: Control; safecall;
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BorderColor(BorderColor: OLE_COLOR); safecall;
    function  Get_BorderColor: OLE_COLOR; safecall;
    procedure Set_BorderStyle(BorderStyle: fmBorderStyle); safecall;
    function  Get_BorderStyle: fmBorderStyle; safecall;
    function  Get_CanPaste: WordBool; safecall;
    function  Get_CanRedo: WordBool; safecall;
    function  Get_CanUndo: WordBool; safecall;
    procedure Set_Caption(const Caption: WideString); safecall;
    function  Get_Caption: WideString; safecall;
    function  Get_Controls: Controls; safecall;
    procedure Set_Cycle(Cycle: fmCycle); safecall;
    function  Get_Cycle: fmCycle; safecall;
    procedure Set_Enabled(Enabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure _GetInsideHeight(out InsideHeight: Integer); safecall;
    function  Get_InsideHeight: Single; safecall;
    procedure _GetInsideWidth(out InsideWidth: Integer); safecall;
    function  Get_InsideWidth: Single; safecall;
    procedure Set_KeepScrollBarsVisible(ScrollBars: fmScrollBars); safecall;
    function  Get_KeepScrollBarsVisible: fmScrollBars; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_PictureAlignment(PictureAlignment: fmPictureAlignment); safecall;
    function  Get_PictureAlignment: fmPictureAlignment; safecall;
    procedure _Set_Picture(const Picture: IPictureDisp); safecall;
    procedure Set_Picture(const Picture: IPictureDisp); safecall;
    function  Get_Picture: IPictureDisp; safecall;
    procedure Set_PictureSizeMode(PictureSizeMode: fmPictureSizeMode); safecall;
    function  Get_PictureSizeMode: fmPictureSizeMode; safecall;
    procedure Set_PictureTiling(PictureTiling: WordBool); safecall;
    function  Get_PictureTiling: WordBool; safecall;
    procedure Set_ScrollBars(ScrollBars: fmScrollBars); safecall;
    function  Get_ScrollBars: fmScrollBars; safecall;
    procedure _SetScrollHeight(ScrollHeight: Integer); safecall;
    procedure _GetScrollHeight(out ScrollHeight: Integer); safecall;
    procedure Set_ScrollHeight(ScrollHeight: Single); safecall;
    function  Get_ScrollHeight: Single; safecall;
    procedure _SetScrollLeft(ScrollLeft: Integer); safecall;
    procedure _GetScrollLeft(out ScrollLeft: Integer); safecall;
    procedure Set_ScrollLeft(ScrollLeft: Single); safecall;
    function  Get_ScrollLeft: Single; safecall;
    procedure _SetScrollTop(ScrollTop: Integer); safecall;
    procedure _GetScrollTop(out ScrollTop: Integer); safecall;
    procedure Set_ScrollTop(ScrollTop: Single); safecall;
    function  Get_ScrollTop: Single; safecall;
    procedure _SetScrollWidth(ScrollWidth: Integer); safecall;
    procedure _GetScrollWidth(out ScrollWidth: Integer); safecall;
    procedure Set_ScrollWidth(ScrollWidth: Single); safecall;
    function  Get_ScrollWidth: Single; safecall;
    function  Get_Selected: Controls; safecall;
    procedure Set_SpecialEffect(SpecialEffect: fmSpecialEffect); safecall;
    function  Get_SpecialEffect: fmSpecialEffect; safecall;
    procedure Set_VerticalScrollBarSide(side: fmVerticalScrollBarSide); safecall;
    function  Get_VerticalScrollBarSide: fmVerticalScrollBarSide; safecall;
    procedure Set_Zoom(Zoom: Smallint); safecall;
    function  Get_Zoom: Smallint; safecall;
    procedure Copy; safecall;
    procedure Cut; safecall;
    procedure Paste; safecall;
    procedure RedoAction; safecall;
    procedure Repaint; safecall;
    procedure Scroll(xAction: OleVariant; yAction: OleVariant); safecall;
    procedure SetDefaultTabOrder; safecall;
    procedure UndoAction; safecall;
    procedure Set_DesignMode(DesignMode: fmMode); safecall;
    function  Get_DesignMode: fmMode; safecall;
    procedure Set_ShowToolbox(ShowToolbox: fmMode); safecall;
    function  Get_ShowToolbox: fmMode; safecall;
    procedure Set_ShowGridDots(ShowGridDots: fmMode); safecall;
    function  Get_ShowGridDots: fmMode; safecall;
    procedure Set_SnapToGrid(SnapToGrid: fmMode); safecall;
    function  Get_SnapToGrid: fmMode; safecall;
    procedure Set_GridX(GridX: Single); safecall;
    function  Get_GridX: Single; safecall;
    procedure _SetGridX(GridX: Integer); safecall;
    procedure _GetGridX(out GridX: Integer); safecall;
    procedure Set_GridY(GridY: Single); safecall;
    function  Get_GridY: Single; safecall;
    procedure _SetGridY(GridY: Integer); safecall;
    procedure _GetGridY(out GridY: Integer); safecall;
    property ActiveControl: Control read Get_ActiveControl;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property BorderColor: OLE_COLOR read Get_BorderColor write Set_BorderColor;
    property BorderStyle: fmBorderStyle read Get_BorderStyle write Set_BorderStyle;
    property CanPaste: WordBool read Get_CanPaste;
    property CanRedo: WordBool read Get_CanRedo;
    property CanUndo: WordBool read Get_CanUndo;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Controls: Controls read Get_Controls;
    property Cycle: fmCycle read Get_Cycle write Set_Cycle;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property InsideHeight: Single read Get_InsideHeight;
    property InsideWidth: Single read Get_InsideWidth;
    property KeepScrollBarsVisible: fmScrollBars read Get_KeepScrollBarsVisible write Set_KeepScrollBarsVisible;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property PictureAlignment: fmPictureAlignment read Get_PictureAlignment write Set_PictureAlignment;
    property Picture: IPictureDisp read Get_Picture write _Set_Picture;
    property PictureSizeMode: fmPictureSizeMode read Get_PictureSizeMode write Set_PictureSizeMode;
    property PictureTiling: WordBool read Get_PictureTiling write Set_PictureTiling;
    property ScrollBars: fmScrollBars read Get_ScrollBars write Set_ScrollBars;
    property ScrollHeight: Single read Get_ScrollHeight write Set_ScrollHeight;
    property ScrollLeft: Single read Get_ScrollLeft write Set_ScrollLeft;
    property ScrollTop: Single read Get_ScrollTop write Set_ScrollTop;
    property ScrollWidth: Single read Get_ScrollWidth write Set_ScrollWidth;
    property Selected: Controls read Get_Selected;
    property SpecialEffect: fmSpecialEffect read Get_SpecialEffect write Set_SpecialEffect;
    property VerticalScrollBarSide: fmVerticalScrollBarSide read Get_VerticalScrollBarSide write Set_VerticalScrollBarSide;
    property Zoom: Smallint read Get_Zoom write Set_Zoom;
    property DesignMode: fmMode read Get_DesignMode write Set_DesignMode;
    property ShowToolbox: fmMode read Get_ShowToolbox write Set_ShowToolbox;
    property ShowGridDots: fmMode read Get_ShowGridDots write Set_ShowGridDots;
    property SnapToGrid: fmMode read Get_SnapToGrid write Set_SnapToGrid;
    property GridX: Single read Get_GridX write Set_GridX;
    property GridY: Single read Get_GridY write Set_GridY;
  end;

// *********************************************************************//
// DispIntf:  IOptionFrameDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {29B86A70-F52E-11CE-9BCE-00AA00608E01}
// *********************************************************************//
  IOptionFrameDisp = dispinterface
    ['{29B86A70-F52E-11CE-9BCE-00AA00608E01}']
    property ActiveControl: Control readonly dispid 256;
    property BackColor: OLE_COLOR dispid -501;
    property BorderColor: OLE_COLOR dispid -503;
    property BorderStyle: fmBorderStyle dispid -504;
    property CanPaste: WordBool readonly dispid 257;
    property CanRedo: WordBool readonly dispid 258;
    property CanUndo: WordBool readonly dispid 259;
    property Caption: WideString dispid -518;
    property Controls: Controls readonly dispid 0;
    property Cycle: fmCycle dispid 260;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property ForeColor: OLE_COLOR dispid -513;
    procedure _GetInsideHeight(out InsideHeight: Integer); dispid 1610743830;
    property InsideHeight: Single readonly dispid 262;
    procedure _GetInsideWidth(out InsideWidth: Integer); dispid 1610743832;
    property InsideWidth: Single readonly dispid 263;
    property KeepScrollBarsVisible: fmScrollBars dispid 264;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property PictureAlignment: fmPictureAlignment dispid 26;
    property Picture: IPictureDisp dispid -523;
    property PictureSizeMode: fmPictureSizeMode dispid 27;
    property PictureTiling: WordBool dispid 28;
    property ScrollBars: fmScrollBars dispid 265;
    procedure _SetScrollHeight(ScrollHeight: Integer); dispid 1610743852;
    procedure _GetScrollHeight(out ScrollHeight: Integer); dispid 1610743853;
    property ScrollHeight: Single dispid 266;
    procedure _SetScrollLeft(ScrollLeft: Integer); dispid 1610743856;
    procedure _GetScrollLeft(out ScrollLeft: Integer); dispid 1610743857;
    property ScrollLeft: Single dispid 267;
    procedure _SetScrollTop(ScrollTop: Integer); dispid 1610743860;
    procedure _GetScrollTop(out ScrollTop: Integer); dispid 1610743861;
    property ScrollTop: Single dispid 268;
    procedure _SetScrollWidth(ScrollWidth: Integer); dispid 1610743864;
    procedure _GetScrollWidth(out ScrollWidth: Integer); dispid 1610743865;
    property ScrollWidth: Single dispid 269;
    property Selected: Controls readonly dispid 270;
    property SpecialEffect: fmSpecialEffect dispid 12;
    property VerticalScrollBarSide: fmVerticalScrollBarSide dispid 271;
    property Zoom: Smallint dispid 272;
    procedure Copy; dispid 512;
    procedure Cut; dispid 513;
    procedure Paste; dispid 514;
    procedure RedoAction; dispid 515;
    procedure Repaint; dispid 516;
    procedure Scroll(xAction: OleVariant; yAction: OleVariant); dispid 517;
    procedure SetDefaultTabOrder; dispid 518;
    procedure UndoAction; dispid 519;
    property DesignMode: fmMode dispid 384;
    property ShowToolbox: fmMode dispid 385;
    property ShowGridDots: fmMode dispid 386;
    property SnapToGrid: fmMode dispid 387;
    property GridX: Single dispid 388;
    procedure _SetGridX(GridX: Integer); dispid 1610743893;
    procedure _GetGridX(out GridX: Integer); dispid 1610743894;
    property GridY: Single dispid 389;
    procedure _SetGridY(GridY: Integer); dispid 1610743897;
    procedure _GetGridY(out GridY: Integer); dispid 1610743898;
  end;

// *********************************************************************//
// Interface: _UserForm
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC8-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  _UserForm = interface(IOptionFrame)
    ['{04598FC8-866C-11CF-AB7C-00AA00C08FCF}']
    procedure Set_DrawBuffer(DrawBuffer: Integer); safecall;
    function  Get_DrawBuffer: Integer; safecall;
    property DrawBuffer: Integer read Get_DrawBuffer write Set_DrawBuffer;
  end;

// *********************************************************************//
// DispIntf:  _UserFormDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC8-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  _UserFormDisp = dispinterface
    ['{04598FC8-866C-11CF-AB7C-00AA00C08FCF}']
    property DrawBuffer: Integer dispid 395;
    property ActiveControl: Control readonly dispid 256;
    property BackColor: OLE_COLOR dispid -501;
    property BorderColor: OLE_COLOR dispid -503;
    property BorderStyle: fmBorderStyle dispid -504;
    property CanPaste: WordBool readonly dispid 257;
    property CanRedo: WordBool readonly dispid 258;
    property CanUndo: WordBool readonly dispid 259;
    property Caption: WideString dispid -518;
    property Controls: Controls readonly dispid 0;
    property Cycle: fmCycle dispid 260;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property ForeColor: OLE_COLOR dispid -513;
    procedure _GetInsideHeight(out InsideHeight: Integer); dispid 1610743830;
    property InsideHeight: Single readonly dispid 262;
    procedure _GetInsideWidth(out InsideWidth: Integer); dispid 1610743832;
    property InsideWidth: Single readonly dispid 263;
    property KeepScrollBarsVisible: fmScrollBars dispid 264;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property PictureAlignment: fmPictureAlignment dispid 26;
    property Picture: IPictureDisp dispid -523;
    property PictureSizeMode: fmPictureSizeMode dispid 27;
    property PictureTiling: WordBool dispid 28;
    property ScrollBars: fmScrollBars dispid 265;
    procedure _SetScrollHeight(ScrollHeight: Integer); dispid 1610743852;
    procedure _GetScrollHeight(out ScrollHeight: Integer); dispid 1610743853;
    property ScrollHeight: Single dispid 266;
    procedure _SetScrollLeft(ScrollLeft: Integer); dispid 1610743856;
    procedure _GetScrollLeft(out ScrollLeft: Integer); dispid 1610743857;
    property ScrollLeft: Single dispid 267;
    procedure _SetScrollTop(ScrollTop: Integer); dispid 1610743860;
    procedure _GetScrollTop(out ScrollTop: Integer); dispid 1610743861;
    property ScrollTop: Single dispid 268;
    procedure _SetScrollWidth(ScrollWidth: Integer); dispid 1610743864;
    procedure _GetScrollWidth(out ScrollWidth: Integer); dispid 1610743865;
    property ScrollWidth: Single dispid 269;
    property Selected: Controls readonly dispid 270;
    property SpecialEffect: fmSpecialEffect dispid 12;
    property VerticalScrollBarSide: fmVerticalScrollBarSide dispid 271;
    property Zoom: Smallint dispid 272;
    procedure Copy; dispid 512;
    procedure Cut; dispid 513;
    procedure Paste; dispid 514;
    procedure RedoAction; dispid 515;
    procedure Repaint; dispid 516;
    procedure Scroll(xAction: OleVariant; yAction: OleVariant); dispid 517;
    procedure SetDefaultTabOrder; dispid 518;
    procedure UndoAction; dispid 519;
    property DesignMode: fmMode dispid 384;
    property ShowToolbox: fmMode dispid 385;
    property ShowGridDots: fmMode dispid 386;
    property SnapToGrid: fmMode dispid 387;
    property GridX: Single dispid 388;
    procedure _SetGridX(GridX: Integer); dispid 1610743893;
    procedure _GetGridX(out GridX: Integer); dispid 1610743894;
    property GridY: Single dispid 389;
    procedure _SetGridY(GridY: Integer); dispid 1610743897;
    procedure _GetGridY(out GridY: Integer); dispid 1610743898;
  end;

// *********************************************************************//
// DispIntf:  ControlEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {9A4BBF53-4E46-101B-8BBD-00AA003E3B29}
// *********************************************************************//
  ControlEvents = dispinterface
    ['{9A4BBF53-4E46-101B-8BBD-00AA003E3B29}']
    procedure Enter; dispid -2147384830;
    procedure Exit(const Cancel: ReturnBoolean); dispid -2147384829;
    procedure BeforeUpdate(const Cancel: ReturnBoolean); dispid -2147384831;
    procedure AfterUpdate; dispid -2147384832;
  end;

// *********************************************************************//
// DispIntf:  FormEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {5B9D8FC8-4A71-101B-97A6-00000B65C08B}
// *********************************************************************//
  FormEvents = dispinterface
    ['{5B9D8FC8-4A71-101B-97A6-00000B65C08B}']
    procedure AddControl(const Control: Control); dispid 768;
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Control: Control; 
                             const Data: DataObject; X: Single; Y: Single; State: fmDragState; 
                             const Effect: ReturnEffect; Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; const Control: Control; 
                                Action: fmAction; const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Click; dispid -600;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure Layout; dispid 770;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
    procedure RemoveControl(const Control: Control); dispid 771;
    procedure Scroll(ActionX: fmScrollAction; ActionY: fmScrollAction; RequestDx: Single; 
                     RequestDy: Single; const ActualDx: ReturnSingle; const ActualDy: ReturnSingle); dispid 772;
    procedure Zoom(var Percent: Smallint); dispid 773;
  end;

// *********************************************************************//
// DispIntf:  OptionFrameEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {CF3F94A0-F546-11CE-9BCE-00AA00608E01}
// *********************************************************************//
  OptionFrameEvents = dispinterface
    ['{CF3F94A0-F546-11CE-9BCE-00AA00608E01}']
    procedure AddControl(const Control: Control); dispid 768;
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Control: Control; 
                             const Data: DataObject; X: Single; Y: Single; State: fmDragState; 
                             const Effect: ReturnEffect; Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; const Control: Control; 
                                Action: fmAction; const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Click; dispid -600;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure Layout; dispid 770;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
    procedure RemoveControl(const Control: Control); dispid 771;
    procedure Scroll(ActionX: fmScrollAction; ActionY: fmScrollAction; RequestDx: Single; 
                     RequestDy: Single; const ActualDx: ReturnSingle; const ActualDy: ReturnSingle); dispid 772;
    procedure Zoom(var Percent: Smallint); dispid 773;
  end;

// *********************************************************************//
// Interface: ILabelControl
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC1-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  ILabelControl = interface(IDispatch)
    ['{04598FC1-866C-11CF-AB7C-00AA00C08FCF}']
    procedure Set_AutoSize(fvbAutoSize: WordBool); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BackStyle(BackStyle: fmBackStyle); safecall;
    function  Get_BackStyle: fmBackStyle; safecall;
    procedure Set_BorderColor(BorderColor: OLE_COLOR); safecall;
    function  Get_BorderColor: OLE_COLOR; safecall;
    procedure Set_BorderStyle(BorderStyle: fmBorderStyle); safecall;
    function  Get_BorderStyle: fmBorderStyle; safecall;
    procedure Set_Caption(const bstrCaption: WideString); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Enabled(fEnabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_FontItalic(FontItalic: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontBold(FontBold: WordBool); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontName(const FontName: WideString); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontSize(FontSize: Currency); safecall;
    function  Get_FontSize: Currency; safecall;
    procedure Set_FontStrikethru(FontStrikethru: WordBool); safecall;
    function  Get_FontStrikethru: WordBool; safecall;
    procedure Set_FontUnderline(FontUnderline: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure _Set_Picture(const pPicture: IPictureDisp); safecall;
    procedure Set_Picture(const pPicture: IPictureDisp); safecall;
    function  Get_Picture: IPictureDisp; safecall;
    procedure Set_PicturePosition(PicPos: fmPicturePosition); safecall;
    function  Get_PicturePosition: fmPicturePosition; safecall;
    procedure Set_SpecialEffect(SpecialEffect: fmSpecialEffect); safecall;
    function  Get_SpecialEffect: fmSpecialEffect; safecall;
    procedure Set_TextAlign(TextAlign: fmTextAlign); safecall;
    function  Get_TextAlign: fmTextAlign; safecall;
    procedure Set_WordWrap(WordWrap: WordBool); safecall;
    function  Get_WordWrap: WordBool; safecall;
    procedure Set_Accelerator(const Accelerator: WideString); safecall;
    function  Get_Accelerator: WideString; safecall;
    procedure Set_FontWeight(FontWeight: Smallint); safecall;
    function  Get_FontWeight: Smallint; safecall;
    procedure Set__Value(const bstrCaption: WideString); safecall;
    function  Get__Value: WideString; safecall;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property BackStyle: fmBackStyle read Get_BackStyle write Set_BackStyle;
    property BorderColor: OLE_COLOR read Get_BorderColor write Set_BorderColor;
    property BorderStyle: fmBorderStyle read Get_BorderStyle write Set_BorderStyle;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontSize: Currency read Get_FontSize write Set_FontSize;
    property FontStrikethru: WordBool read Get_FontStrikethru write Set_FontStrikethru;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property Picture: IPictureDisp read Get_Picture write _Set_Picture;
    property PicturePosition: fmPicturePosition read Get_PicturePosition write Set_PicturePosition;
    property SpecialEffect: fmSpecialEffect read Get_SpecialEffect write Set_SpecialEffect;
    property TextAlign: fmTextAlign read Get_TextAlign write Set_TextAlign;
    property WordWrap: WordBool read Get_WordWrap write Set_WordWrap;
    property Accelerator: WideString read Get_Accelerator write Set_Accelerator;
    property FontWeight: Smallint read Get_FontWeight write Set_FontWeight;
    property _Value: WideString read Get__Value write Set__Value;
  end;

// *********************************************************************//
// DispIntf:  ILabelControlDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC1-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  ILabelControlDisp = dispinterface
    ['{04598FC1-866C-11CF-AB7C-00AA00C08FCF}']
    property AutoSize: WordBool dispid -500;
    property BackColor: OLE_COLOR dispid -501;
    property BackStyle: fmBackStyle dispid -502;
    property BorderColor: OLE_COLOR dispid -503;
    property BorderStyle: fmBorderStyle dispid -504;
    property Caption: WideString dispid 0;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontItalic: WordBool dispid 4;
    property FontBold: WordBool dispid 3;
    property FontName: WideString dispid 1;
    property FontSize: Currency dispid 2;
    property FontStrikethru: WordBool dispid 6;
    property FontUnderline: WordBool dispid 5;
    property ForeColor: OLE_COLOR dispid -513;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property Picture: IPictureDisp dispid -523;
    property PicturePosition: fmPicturePosition dispid 11;
    property SpecialEffect: fmSpecialEffect dispid 12;
    property TextAlign: fmTextAlign dispid 13;
    property WordWrap: WordBool dispid -536;
    property Accelerator: WideString dispid -543;
    property FontWeight: Smallint dispid 7;
    property _Value: WideString dispid -518;
  end;

// *********************************************************************//
// Interface: ICommandButton
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC4-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  ICommandButton = interface(IDispatch)
    ['{04598FC4-866C-11CF-AB7C-00AA00C08FCF}']
    procedure Set_AutoSize(fvbAutoSize: WordBool); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BackStyle(BackStyle: fmBackStyle); safecall;
    function  Get_BackStyle: fmBackStyle; safecall;
    procedure Set_Caption(const bstrCaption: WideString); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Enabled(fEnabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_FontBold(FontBold: WordBool); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontItalic(FontItalic: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontName(const FontName: WideString); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontSize(FontSize: Currency); safecall;
    function  Get_FontSize: Currency; safecall;
    procedure Set_FontStrikethru(FontStrikethru: WordBool); safecall;
    function  Get_FontStrikethru: WordBool; safecall;
    procedure Set_FontUnderline(FontUnderline: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set_TakeFocusOnClick(TakeFocusOnClick: WordBool); safecall;
    function  Get_TakeFocusOnClick: WordBool; safecall;
    procedure Set_Locked(fLocked: WordBool); safecall;
    function  Get_Locked: WordBool; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_MousePointer(mouseptr: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure _Set_Picture(const Picture: IPictureDisp); safecall;
    procedure Set_Picture(const Picture: IPictureDisp); safecall;
    function  Get_Picture: IPictureDisp; safecall;
    procedure Set_PicturePosition(PicturePosition: fmPicturePosition); safecall;
    function  Get_PicturePosition: fmPicturePosition; safecall;
    procedure Set_Accelerator(const Accelerator: WideString); safecall;
    function  Get_Accelerator: WideString; safecall;
    procedure Set_WordWrap(WordWrap: WordBool); safecall;
    function  Get_WordWrap: WordBool; safecall;
    procedure Set_Value(fValue: WordBool); safecall;
    function  Get_Value: WordBool; safecall;
    procedure Set_FontWeight(FontWeight: Smallint); safecall;
    function  Get_FontWeight: Smallint; safecall;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property BackStyle: fmBackStyle read Get_BackStyle write Set_BackStyle;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontSize: Currency read Get_FontSize write Set_FontSize;
    property FontStrikethru: WordBool read Get_FontStrikethru write Set_FontStrikethru;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property TakeFocusOnClick: WordBool read Get_TakeFocusOnClick write Set_TakeFocusOnClick;
    property Locked: WordBool read Get_Locked write Set_Locked;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property Picture: IPictureDisp read Get_Picture write _Set_Picture;
    property PicturePosition: fmPicturePosition read Get_PicturePosition write Set_PicturePosition;
    property Accelerator: WideString read Get_Accelerator write Set_Accelerator;
    property WordWrap: WordBool read Get_WordWrap write Set_WordWrap;
    property Value: WordBool read Get_Value write Set_Value;
    property FontWeight: Smallint read Get_FontWeight write Set_FontWeight;
  end;

// *********************************************************************//
// DispIntf:  ICommandButtonDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC4-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  ICommandButtonDisp = dispinterface
    ['{04598FC4-866C-11CF-AB7C-00AA00C08FCF}']
    property AutoSize: WordBool dispid -500;
    property BackColor: OLE_COLOR dispid -501;
    property BackStyle: fmBackStyle dispid -502;
    property Caption: WideString dispid -518;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontName: WideString dispid 1;
    property FontSize: Currency dispid 2;
    property FontStrikethru: WordBool dispid 6;
    property FontUnderline: WordBool dispid 5;
    property ForeColor: OLE_COLOR dispid -513;
    property TakeFocusOnClick: WordBool dispid 203;
    property Locked: WordBool dispid 10;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property Picture: IPictureDisp dispid -523;
    property PicturePosition: fmPicturePosition dispid 11;
    property Accelerator: WideString dispid -543;
    property WordWrap: WordBool dispid -536;
    property Value: WordBool dispid 0;
    property FontWeight: Smallint dispid 7;
  end;

// *********************************************************************//
// Interface: IMdcText
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D13-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcText = interface(IDispatch)
    ['{8BD21D13-EC42-11CE-9E0D-00AA006002F3}']
    procedure Set_AutoSize(AutoSize: WordBool); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_AutoTab(AutoTab: WordBool); safecall;
    function  Get_AutoTab: WordBool; safecall;
    procedure Set_AutoWordSelect(AutoWordSelect: WordBool); safecall;
    function  Get_AutoWordSelect: WordBool; safecall;
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BackStyle(BackStyle: fmBackStyle); safecall;
    function  Get_BackStyle: fmBackStyle; safecall;
    procedure Set_BorderColor(BorderColor: OLE_COLOR); safecall;
    function  Get_BorderColor: OLE_COLOR; safecall;
    procedure Set_BorderStyle(BorderStyle: fmBorderStyle); safecall;
    function  Get_BorderStyle: fmBorderStyle; safecall;
    procedure Set_BordersSuppress(BordersSuppress: WordBool); safecall;
    function  Get_BordersSuppress: WordBool; safecall;
    function  Get_CanPaste: WordBool; safecall;
    procedure Set_CurLine(CurLine: Integer); safecall;
    function  Get_CurLine: Integer; safecall;
    function  Get_CurTargetX: Integer; safecall;
    function  Get_CurTargetY: Integer; safecall;
    procedure Set_CurX(CurX: Integer); safecall;
    function  Get_CurX: Integer; safecall;
    procedure Set_CurY(CurY: Integer); safecall;
    function  Get_CurY: Integer; safecall;
    procedure Set_DropButtonStyle(DropButtonStyle: fmDropButtonStyle); safecall;
    function  Get_DropButtonStyle: fmDropButtonStyle; safecall;
    procedure Set_EnterKeyBehavior(EnterKeyBehavior: WordBool); safecall;
    function  Get_EnterKeyBehavior: WordBool; safecall;
    procedure Set_Enabled(Enabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_FontBold(FontBold: WordBool); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontItalic(FontItalic: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontName(const FontName: WideString); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontSize(FontSize: Currency); safecall;
    function  Get_FontSize: Currency; safecall;
    procedure Set_FontStrikethru(FontStrikethru: WordBool); safecall;
    function  Get_FontStrikethru: WordBool; safecall;
    procedure Set_FontUnderline(FontUnderline: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_FontWeight(FontWeight: Smallint); safecall;
    function  Get_FontWeight: Smallint; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set_HideSelection(HideSelection: WordBool); safecall;
    function  Get_HideSelection: WordBool; safecall;
    procedure Set_IntegralHeight(IntegralHeight: WordBool); safecall;
    function  Get_IntegralHeight: WordBool; safecall;
    function  Get_LineCount: Integer; safecall;
    procedure Set_Locked(Locked: WordBool); safecall;
    function  Get_Locked: WordBool; safecall;
    procedure Set_MaxLength(MaxLength: Integer); safecall;
    function  Get_MaxLength: Integer; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_MultiLine(MultiLine: WordBool); safecall;
    function  Get_MultiLine: WordBool; safecall;
    procedure Set_PasswordChar(const PasswordChar: WideString); safecall;
    function  Get_PasswordChar: WideString; safecall;
    procedure Set_ScrollBars(ScrollBars: fmScrollBars); safecall;
    function  Get_ScrollBars: fmScrollBars; safecall;
    procedure Set_SelectionMargin(SelectionMargin: WordBool); safecall;
    function  Get_SelectionMargin: WordBool; safecall;
    procedure Set_SelLength(SelLength: Integer); safecall;
    function  Get_SelLength: Integer; safecall;
    procedure Set_SelStart(SelStart: Integer); safecall;
    function  Get_SelStart: Integer; safecall;
    procedure Set_SelText(const SelText: WideString); safecall;
    function  Get_SelText: WideString; safecall;
    procedure Set_ShowDropButtonWhen(ShowDropButtonWhen: fmShowDropButtonWhen); safecall;
    function  Get_ShowDropButtonWhen: fmShowDropButtonWhen; safecall;
    procedure Set_SpecialEffect(SpecialEffect: fmSpecialEffect); safecall;
    function  Get_SpecialEffect: fmSpecialEffect; safecall;
    procedure Set_TabKeyBehavior(TabKeyBehavior: WordBool); safecall;
    function  Get_TabKeyBehavior: WordBool; safecall;
    procedure Set_Text(const Text: WideString); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_TextAlign(TextAlign: fmTextAlign); safecall;
    function  Get_TextAlign: fmTextAlign; safecall;
    function  Get_TextLength: Integer; safecall;
    function  Get_Valid: WordBool; safecall;
    procedure Set_Value(var Value: OleVariant); safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_WordWrap(WordWrap: WordBool); safecall;
    function  Get_WordWrap: WordBool; safecall;
    procedure Copy; safecall;
    procedure Cut; safecall;
    procedure Paste; safecall;
    procedure Set_IMEMode(IMEMode: fmIMEMode); safecall;
    function  Get_IMEMode: fmIMEMode; safecall;
    procedure Set_EnterFieldBehavior(EnterFieldBehavior: fmEnterFieldBehavior); safecall;
    function  Get_EnterFieldBehavior: fmEnterFieldBehavior; safecall;
    procedure Set_DragBehavior(DragBehavior: fmDragBehavior); safecall;
    function  Get_DragBehavior: fmDragBehavior; safecall;
    function  Get_DisplayStyle: fmDisplayStyle; safecall;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property AutoTab: WordBool read Get_AutoTab write Set_AutoTab;
    property AutoWordSelect: WordBool read Get_AutoWordSelect write Set_AutoWordSelect;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property BackStyle: fmBackStyle read Get_BackStyle write Set_BackStyle;
    property BorderColor: OLE_COLOR read Get_BorderColor write Set_BorderColor;
    property BorderStyle: fmBorderStyle read Get_BorderStyle write Set_BorderStyle;
    property BordersSuppress: WordBool read Get_BordersSuppress write Set_BordersSuppress;
    property CanPaste: WordBool read Get_CanPaste;
    property CurLine: Integer read Get_CurLine write Set_CurLine;
    property CurTargetX: Integer read Get_CurTargetX;
    property CurTargetY: Integer read Get_CurTargetY;
    property CurX: Integer read Get_CurX write Set_CurX;
    property CurY: Integer read Get_CurY write Set_CurY;
    property DropButtonStyle: fmDropButtonStyle read Get_DropButtonStyle write Set_DropButtonStyle;
    property EnterKeyBehavior: WordBool read Get_EnterKeyBehavior write Set_EnterKeyBehavior;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontSize: Currency read Get_FontSize write Set_FontSize;
    property FontStrikethru: WordBool read Get_FontStrikethru write Set_FontStrikethru;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property FontWeight: Smallint read Get_FontWeight write Set_FontWeight;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property HideSelection: WordBool read Get_HideSelection write Set_HideSelection;
    property IntegralHeight: WordBool read Get_IntegralHeight write Set_IntegralHeight;
    property LineCount: Integer read Get_LineCount;
    property Locked: WordBool read Get_Locked write Set_Locked;
    property MaxLength: Integer read Get_MaxLength write Set_MaxLength;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property MultiLine: WordBool read Get_MultiLine write Set_MultiLine;
    property PasswordChar: WideString read Get_PasswordChar write Set_PasswordChar;
    property ScrollBars: fmScrollBars read Get_ScrollBars write Set_ScrollBars;
    property SelectionMargin: WordBool read Get_SelectionMargin write Set_SelectionMargin;
    property SelLength: Integer read Get_SelLength write Set_SelLength;
    property SelStart: Integer read Get_SelStart write Set_SelStart;
    property SelText: WideString read Get_SelText write Set_SelText;
    property ShowDropButtonWhen: fmShowDropButtonWhen read Get_ShowDropButtonWhen write Set_ShowDropButtonWhen;
    property SpecialEffect: fmSpecialEffect read Get_SpecialEffect write Set_SpecialEffect;
    property TabKeyBehavior: WordBool read Get_TabKeyBehavior write Set_TabKeyBehavior;
    property Text: WideString read Get_Text write Set_Text;
    property TextAlign: fmTextAlign read Get_TextAlign write Set_TextAlign;
    property TextLength: Integer read Get_TextLength;
    property Valid: WordBool read Get_Valid;
    property WordWrap: WordBool read Get_WordWrap write Set_WordWrap;
    property IMEMode: fmIMEMode read Get_IMEMode write Set_IMEMode;
    property EnterFieldBehavior: fmEnterFieldBehavior read Get_EnterFieldBehavior write Set_EnterFieldBehavior;
    property DragBehavior: fmDragBehavior read Get_DragBehavior write Set_DragBehavior;
    property DisplayStyle: fmDisplayStyle read Get_DisplayStyle;
  end;

// *********************************************************************//
// DispIntf:  IMdcTextDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D13-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcTextDisp = dispinterface
    ['{8BD21D13-EC42-11CE-9E0D-00AA006002F3}']
    property AutoSize: WordBool dispid -500;
    property AutoTab: WordBool dispid 217;
    property AutoWordSelect: WordBool dispid 218;
    property BackColor: OLE_COLOR dispid -501;
    property BackStyle: fmBackStyle dispid -502;
    property BorderColor: OLE_COLOR dispid -503;
    property BorderStyle: fmBorderStyle dispid -504;
    property BordersSuppress: WordBool dispid 20;
    property CanPaste: WordBool readonly dispid 25;
    property CurLine: Integer dispid 212;
    property CurTargetX: Integer readonly dispid 210;
    property CurTargetY: Integer readonly dispid 221;
    property CurX: Integer dispid 208;
    property CurY: Integer dispid 209;
    property DropButtonStyle: fmDropButtonStyle dispid 305;
    property EnterKeyBehavior: WordBool dispid -544;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontName: WideString dispid 1;
    property FontSize: Currency dispid 2;
    property FontStrikethru: WordBool dispid 6;
    property FontUnderline: WordBool dispid 5;
    property FontWeight: Smallint dispid 7;
    property ForeColor: OLE_COLOR dispid -513;
    property HideSelection: WordBool dispid 207;
    property IntegralHeight: WordBool dispid 604;
    property LineCount: Integer readonly dispid 214;
    property Locked: WordBool dispid 10;
    property MaxLength: Integer dispid -533;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property MultiLine: WordBool dispid -537;
    property PasswordChar: WideString dispid -534;
    property ScrollBars: fmScrollBars dispid -535;
    property SelectionMargin: WordBool dispid 220;
    property SelLength: Integer dispid -548;
    property SelStart: Integer dispid -547;
    property SelText: WideString dispid -546;
    property ShowDropButtonWhen: fmShowDropButtonWhen dispid 304;
    property SpecialEffect: fmSpecialEffect dispid 12;
    property TabKeyBehavior: WordBool dispid -545;
    property Text: WideString dispid -517;
    property TextAlign: fmTextAlign dispid 10004;
    property TextLength: Integer readonly dispid 216;
    property Valid: WordBool readonly dispid -524;
    function  Value: {??POleVariant1} OleVariant; dispid 0;
    property WordWrap: WordBool dispid -536;
    procedure Copy; dispid 22;
    procedure Cut; dispid 21;
    procedure Paste; dispid 24;
    property IMEMode: fmIMEMode dispid -542;
    property EnterFieldBehavior: fmEnterFieldBehavior dispid 224;
    property DragBehavior: fmDragBehavior dispid 225;
    property DisplayStyle: fmDisplayStyle readonly dispid -540;
  end;

// *********************************************************************//
// Interface: IMdcList
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D23-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcList = interface(IDispatch)
    ['{8BD21D23-EC42-11CE-9E0D-00AA006002F3}']
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BorderColor(BorderColor: OLE_COLOR); safecall;
    function  Get_BorderColor: OLE_COLOR; safecall;
    procedure Set_BorderStyle(BorderStyle: fmBorderStyle); safecall;
    function  Get_BorderStyle: fmBorderStyle; safecall;
    procedure Set_BordersSuppress(BordersSuppress: WordBool); safecall;
    function  Get_BordersSuppress: WordBool; safecall;
    procedure Set_BoundColumn(var BoundColumn: OleVariant); safecall;
    function  Get_BoundColumn: OleVariant; safecall;
    procedure Set_ColumnCount(ColumnCount: Integer); safecall;
    function  Get_ColumnCount: Integer; safecall;
    procedure Set_ColumnHeads(ColumnHeads: WordBool); safecall;
    function  Get_ColumnHeads: WordBool; safecall;
    procedure Set_ColumnWidths(const ColumnWidths: WideString); safecall;
    function  Get_ColumnWidths: WideString; safecall;
    procedure Set_Enabled(Enabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_FontBold(FontBold: WordBool); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontItalic(FontItalic: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontName(const FontName: WideString); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontSize(FontSize: Currency); safecall;
    function  Get_FontSize: Currency; safecall;
    procedure Set_FontStrikethru(FontStrikethru: WordBool); safecall;
    function  Get_FontStrikethru: WordBool; safecall;
    procedure Set_FontUnderline(FontUnderline: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_FontWeight(FontWeight: Smallint); safecall;
    function  Get_FontWeight: Smallint; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set_IntegralHeight(IntegralHeight: WordBool); safecall;
    function  Get_IntegralHeight: WordBool; safecall;
    function  Get_ListCount: Integer; safecall;
    procedure Set_ListCursor(const ListCursor: PIROWSET); safecall;
    function  Get_ListCursor: PIROWSET; safecall;
    procedure Set_ListIndex(var ListIndex: OleVariant); safecall;
    function  Get_ListIndex: OleVariant; safecall;
    procedure Set_ListStyle(ListStyle: fmListStyle); safecall;
    function  Get_ListStyle: fmListStyle; safecall;
    procedure Set_ListWidth(var ListWidth: OleVariant); safecall;
    function  Get_ListWidth: OleVariant; safecall;
    procedure Set_Locked(Locked: WordBool); safecall;
    function  Get_Locked: WordBool; safecall;
    procedure Set_MatchEntry(MatchEntry: fmMatchEntry); safecall;
    function  Get_MatchEntry: fmMatchEntry; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_MultiSelect(MultiSelect: fmMultiSelect); safecall;
    function  Get_MultiSelect: fmMultiSelect; safecall;
    procedure Set_SpecialEffect(SpecialEffect: fmSpecialEffect); safecall;
    function  Get_SpecialEffect: fmSpecialEffect; safecall;
    procedure Set_Text(const Text: WideString); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_TextColumn(var TextColumn: OleVariant); safecall;
    function  Get_TextColumn: OleVariant; safecall;
    procedure Set_TopIndex(var TopIndex: OleVariant); safecall;
    function  Get_TopIndex: OleVariant; safecall;
    function  Get_Valid: WordBool; safecall;
    procedure Set_Value(var Value: OleVariant); safecall;
    function  Get_Value: OleVariant; safecall;
    function  Get_Column(var pvargColumn: OleVariant; var pvargIndex: OleVariant): OleVariant; safecall;
    procedure Set_Column(var pvargColumn: OleVariant; var pvargIndex: OleVariant; 
                         var pvargValue: OleVariant); safecall;
    function  Get_List(var pvargIndex: OleVariant; var pvargColumn: OleVariant): OleVariant; safecall;
    procedure Set_List(var pvargIndex: OleVariant; var pvargColumn: OleVariant; 
                       var pvargValue: OleVariant); safecall;
    function  Get_Selected(var pvargIndex: OleVariant): WordBool; safecall;
    procedure Set_Selected(var pvargIndex: OleVariant; pfvb: WordBool); safecall;
    procedure AddItem(var pvargItem: OleVariant; var pvargIndex: OleVariant); safecall;
    procedure Clear; safecall;
    procedure RemoveItem(var pvargIndex: OleVariant); safecall;
    procedure Set_IMEMode(IMEMode: fmIMEMode); safecall;
    function  Get_IMEMode: fmIMEMode; safecall;
    function  Get_DisplayStyle: fmDisplayStyle; safecall;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property BorderColor: OLE_COLOR read Get_BorderColor write Set_BorderColor;
    property BorderStyle: fmBorderStyle read Get_BorderStyle write Set_BorderStyle;
    property BordersSuppress: WordBool read Get_BordersSuppress write Set_BordersSuppress;
    property ColumnCount: Integer read Get_ColumnCount write Set_ColumnCount;
    property ColumnHeads: WordBool read Get_ColumnHeads write Set_ColumnHeads;
    property ColumnWidths: WideString read Get_ColumnWidths write Set_ColumnWidths;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontSize: Currency read Get_FontSize write Set_FontSize;
    property FontStrikethru: WordBool read Get_FontStrikethru write Set_FontStrikethru;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property FontWeight: Smallint read Get_FontWeight write Set_FontWeight;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property IntegralHeight: WordBool read Get_IntegralHeight write Set_IntegralHeight;
    property ListCount: Integer read Get_ListCount;
    property ListCursor: PIROWSET read Get_ListCursor write Set_ListCursor;
    property ListStyle: fmListStyle read Get_ListStyle write Set_ListStyle;
    property Locked: WordBool read Get_Locked write Set_Locked;
    property MatchEntry: fmMatchEntry read Get_MatchEntry write Set_MatchEntry;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property MultiSelect: fmMultiSelect read Get_MultiSelect write Set_MultiSelect;
    property SpecialEffect: fmSpecialEffect read Get_SpecialEffect write Set_SpecialEffect;
    property Text: WideString read Get_Text write Set_Text;
    property Valid: WordBool read Get_Valid;
    property Selected[var pvargIndex: OleVariant]: WordBool read Get_Selected write Set_Selected;
    property IMEMode: fmIMEMode read Get_IMEMode write Set_IMEMode;
    property DisplayStyle: fmDisplayStyle read Get_DisplayStyle;
  end;

// *********************************************************************//
// DispIntf:  IMdcListDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D23-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcListDisp = dispinterface
    ['{8BD21D23-EC42-11CE-9E0D-00AA006002F3}']
    property BackColor: OLE_COLOR dispid -501;
    property BorderColor: OLE_COLOR dispid -503;
    property BorderStyle: fmBorderStyle dispid -504;
    property BordersSuppress: WordBool dispid 20;
    function  BoundColumn: {??POleVariant1} OleVariant; dispid 501;
    property ColumnCount: Integer dispid 601;
    property ColumnHeads: WordBool dispid 602;
    property ColumnWidths: WideString dispid 603;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontName: WideString dispid 1;
    property FontSize: Currency dispid 2;
    property FontStrikethru: WordBool dispid 6;
    property FontUnderline: WordBool dispid 5;
    property FontWeight: Smallint dispid 7;
    property ForeColor: OLE_COLOR dispid -513;
    property IntegralHeight: WordBool dispid 604;
    property ListCount: Integer readonly dispid -531;
    property ListCursor: PIROWSET dispid 403;
    function  ListIndex: {??POleVariant1} OleVariant; dispid -526;
    property ListStyle: fmListStyle dispid 307;
    function  ListWidth: {??POleVariant1} OleVariant; dispid 606;
    property Locked: WordBool dispid 10;
    property MatchEntry: fmMatchEntry dispid 504;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property MultiSelect: fmMultiSelect dispid -532;
    property SpecialEffect: fmSpecialEffect dispid 12;
    property Text: WideString dispid -517;
    function  TextColumn: {??POleVariant1} OleVariant; dispid 502;
    function  TopIndex: {??POleVariant1} OleVariant; dispid 611;
    property Valid: WordBool readonly dispid -524;
    function  Value: {??POleVariant1} OleVariant; dispid 0;
    function  Column(var pvargColumn: OleVariant; var pvargIndex: OleVariant): OleVariant; dispid -529;
    function  List(var pvargIndex: OleVariant; var pvargColumn: OleVariant): OleVariant; dispid -528;
    property Selected[var pvargIndex: OleVariant]: WordBool dispid -527;
    procedure AddItem(var pvargItem: OleVariant; var pvargIndex: OleVariant); dispid -553;
    procedure Clear; dispid -554;
    procedure RemoveItem(var pvargIndex: OleVariant); dispid -555;
    property IMEMode: fmIMEMode dispid -542;
    property DisplayStyle: fmDisplayStyle readonly dispid -540;
  end;

// *********************************************************************//
// Interface: IMdcCombo
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D33-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcCombo = interface(IDispatch)
    ['{8BD21D33-EC42-11CE-9E0D-00AA006002F3}']
    procedure Set_AutoSize(AutoSize: WordBool); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_AutoTab(AutoTab: WordBool); safecall;
    function  Get_AutoTab: WordBool; safecall;
    procedure Set_AutoWordSelect(AutoWordSelect: WordBool); safecall;
    function  Get_AutoWordSelect: WordBool; safecall;
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BackStyle(BackStyle: fmBackStyle); safecall;
    function  Get_BackStyle: fmBackStyle; safecall;
    procedure Set_BorderColor(BorderColor: OLE_COLOR); safecall;
    function  Get_BorderColor: OLE_COLOR; safecall;
    procedure Set_BorderStyle(BorderStyle: fmBorderStyle); safecall;
    function  Get_BorderStyle: fmBorderStyle; safecall;
    procedure Set_BordersSuppress(BordersSuppress: WordBool); safecall;
    function  Get_BordersSuppress: WordBool; safecall;
    procedure Set_BoundColumn(var BoundColumn: OleVariant); safecall;
    function  Get_BoundColumn: OleVariant; safecall;
    function  Get_CanPaste: WordBool; safecall;
    procedure Set_ColumnCount(ColumnCount: Integer); safecall;
    function  Get_ColumnCount: Integer; safecall;
    procedure Set_ColumnHeads(ColumnHeads: WordBool); safecall;
    function  Get_ColumnHeads: WordBool; safecall;
    procedure Set_ColumnWidths(const ColumnWidths: WideString); safecall;
    function  Get_ColumnWidths: WideString; safecall;
    function  Get_CurTargetX: Integer; safecall;
    function  Get_CurTargetY: Integer; safecall;
    procedure Set_CurX(CurX: Integer); safecall;
    function  Get_CurX: Integer; safecall;
    procedure Set_DropButtonStyle(DropButtonStyle: fmDropButtonStyle); safecall;
    function  Get_DropButtonStyle: fmDropButtonStyle; safecall;
    procedure Set_Enabled(Enabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_FontBold(FontBold: WordBool); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontItalic(FontItalic: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontName(const FontName: WideString); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontSize(FontSize: Currency); safecall;
    function  Get_FontSize: Currency; safecall;
    procedure Set_FontStrikethru(FontStrikethru: WordBool); safecall;
    function  Get_FontStrikethru: WordBool; safecall;
    procedure Set_FontUnderline(FontUnderline: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_FontWeight(FontWeight: Smallint); safecall;
    function  Get_FontWeight: Smallint; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set_HideSelection(HideSelection: WordBool); safecall;
    function  Get_HideSelection: WordBool; safecall;
    function  Get_LineCount: Integer; safecall;
    function  Get_ListCount: Integer; safecall;
    procedure Set_ListCursor(const ListCursor: PIROWSET); safecall;
    function  Get_ListCursor: PIROWSET; safecall;
    procedure Set_ListIndex(var ListIndex: OleVariant); safecall;
    function  Get_ListIndex: OleVariant; safecall;
    procedure Set_ListRows(ListRows: Integer); safecall;
    function  Get_ListRows: Integer; safecall;
    procedure Set_ListStyle(ListStyle: fmListStyle); safecall;
    function  Get_ListStyle: fmListStyle; safecall;
    procedure Set_ListWidth(var ListWidth: OleVariant); safecall;
    function  Get_ListWidth: OleVariant; safecall;
    procedure Set_Locked(Locked: WordBool); safecall;
    function  Get_Locked: WordBool; safecall;
    procedure Set_MatchEntry(MatchEntry: fmMatchEntry); safecall;
    function  Get_MatchEntry: fmMatchEntry; safecall;
    function  Get_MatchFound: WordBool; safecall;
    procedure Set_MatchRequired(MatchRequired: WordBool); safecall;
    function  Get_MatchRequired: WordBool; safecall;
    procedure Set_MaxLength(MaxLength: Integer); safecall;
    function  Get_MaxLength: Integer; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_SelectionMargin(SelectionMargin: WordBool); safecall;
    function  Get_SelectionMargin: WordBool; safecall;
    procedure Set_SelLength(SelLength: Integer); safecall;
    function  Get_SelLength: Integer; safecall;
    procedure Set_SelStart(SelStart: Integer); safecall;
    function  Get_SelStart: Integer; safecall;
    procedure Set_SelText(const SelText: WideString); safecall;
    function  Get_SelText: WideString; safecall;
    procedure Set_ShowDropButtonWhen(ShowDropButtonWhen: fmShowDropButtonWhen); safecall;
    function  Get_ShowDropButtonWhen: fmShowDropButtonWhen; safecall;
    procedure Set_SpecialEffect(SpecialEffect: fmSpecialEffect); safecall;
    function  Get_SpecialEffect: fmSpecialEffect; safecall;
    procedure Set_Style(Style: fmStyle); safecall;
    function  Get_Style: fmStyle; safecall;
    procedure Set_Text(const Text: WideString); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_TextAlign(TextAlign: fmTextAlign); safecall;
    function  Get_TextAlign: fmTextAlign; safecall;
    procedure Set_TextColumn(var TextColumn: OleVariant); safecall;
    function  Get_TextColumn: OleVariant; safecall;
    function  Get_TextLength: Integer; safecall;
    procedure Set_TopIndex(var TopIndex: OleVariant); safecall;
    function  Get_TopIndex: OleVariant; safecall;
    function  Get_Valid: WordBool; safecall;
    procedure Set_Value(var Value: OleVariant); safecall;
    function  Get_Value: OleVariant; safecall;
    function  Get_Column(var pvargColumn: OleVariant; var pvargIndex: OleVariant): OleVariant; safecall;
    procedure Set_Column(var pvargColumn: OleVariant; var pvargIndex: OleVariant; 
                         var pvargValue: OleVariant); safecall;
    function  Get_List(var pvargIndex: OleVariant; var pvargColumn: OleVariant): OleVariant; safecall;
    procedure Set_List(var pvargIndex: OleVariant; var pvargColumn: OleVariant; 
                       var pvargValue: OleVariant); safecall;
    procedure AddItem(var pvargItem: OleVariant; var pvargIndex: OleVariant); safecall;
    procedure Clear; safecall;
    procedure DropDown; safecall;
    procedure RemoveItem(var pvargIndex: OleVariant); safecall;
    procedure Copy; safecall;
    procedure Cut; safecall;
    procedure Paste; safecall;
    procedure Set_IMEMode(IMEMode: fmIMEMode); safecall;
    function  Get_IMEMode: fmIMEMode; safecall;
    procedure Set_EnterFieldBehavior(EnterFieldBehavior: fmEnterFieldBehavior); safecall;
    function  Get_EnterFieldBehavior: fmEnterFieldBehavior; safecall;
    procedure Set_DragBehavior(DragBehavior: fmDragBehavior); safecall;
    function  Get_DragBehavior: fmDragBehavior; safecall;
    function  Get_DisplayStyle: fmDisplayStyle; safecall;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property AutoTab: WordBool read Get_AutoTab write Set_AutoTab;
    property AutoWordSelect: WordBool read Get_AutoWordSelect write Set_AutoWordSelect;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property BackStyle: fmBackStyle read Get_BackStyle write Set_BackStyle;
    property BorderColor: OLE_COLOR read Get_BorderColor write Set_BorderColor;
    property BorderStyle: fmBorderStyle read Get_BorderStyle write Set_BorderStyle;
    property BordersSuppress: WordBool read Get_BordersSuppress write Set_BordersSuppress;
    property CanPaste: WordBool read Get_CanPaste;
    property ColumnCount: Integer read Get_ColumnCount write Set_ColumnCount;
    property ColumnHeads: WordBool read Get_ColumnHeads write Set_ColumnHeads;
    property ColumnWidths: WideString read Get_ColumnWidths write Set_ColumnWidths;
    property CurTargetX: Integer read Get_CurTargetX;
    property CurTargetY: Integer read Get_CurTargetY;
    property CurX: Integer read Get_CurX write Set_CurX;
    property DropButtonStyle: fmDropButtonStyle read Get_DropButtonStyle write Set_DropButtonStyle;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontSize: Currency read Get_FontSize write Set_FontSize;
    property FontStrikethru: WordBool read Get_FontStrikethru write Set_FontStrikethru;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property FontWeight: Smallint read Get_FontWeight write Set_FontWeight;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property HideSelection: WordBool read Get_HideSelection write Set_HideSelection;
    property LineCount: Integer read Get_LineCount;
    property ListCount: Integer read Get_ListCount;
    property ListCursor: PIROWSET read Get_ListCursor write Set_ListCursor;
    property ListRows: Integer read Get_ListRows write Set_ListRows;
    property ListStyle: fmListStyle read Get_ListStyle write Set_ListStyle;
    property Locked: WordBool read Get_Locked write Set_Locked;
    property MatchEntry: fmMatchEntry read Get_MatchEntry write Set_MatchEntry;
    property MatchFound: WordBool read Get_MatchFound;
    property MatchRequired: WordBool read Get_MatchRequired write Set_MatchRequired;
    property MaxLength: Integer read Get_MaxLength write Set_MaxLength;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property SelectionMargin: WordBool read Get_SelectionMargin write Set_SelectionMargin;
    property SelLength: Integer read Get_SelLength write Set_SelLength;
    property SelStart: Integer read Get_SelStart write Set_SelStart;
    property SelText: WideString read Get_SelText write Set_SelText;
    property ShowDropButtonWhen: fmShowDropButtonWhen read Get_ShowDropButtonWhen write Set_ShowDropButtonWhen;
    property SpecialEffect: fmSpecialEffect read Get_SpecialEffect write Set_SpecialEffect;
    property Style: fmStyle read Get_Style write Set_Style;
    property Text: WideString read Get_Text write Set_Text;
    property TextAlign: fmTextAlign read Get_TextAlign write Set_TextAlign;
    property TextLength: Integer read Get_TextLength;
    property Valid: WordBool read Get_Valid;
    property IMEMode: fmIMEMode read Get_IMEMode write Set_IMEMode;
    property EnterFieldBehavior: fmEnterFieldBehavior read Get_EnterFieldBehavior write Set_EnterFieldBehavior;
    property DragBehavior: fmDragBehavior read Get_DragBehavior write Set_DragBehavior;
    property DisplayStyle: fmDisplayStyle read Get_DisplayStyle;
  end;

// *********************************************************************//
// DispIntf:  IMdcComboDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D33-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcComboDisp = dispinterface
    ['{8BD21D33-EC42-11CE-9E0D-00AA006002F3}']
    property AutoSize: WordBool dispid -500;
    property AutoTab: WordBool dispid 217;
    property AutoWordSelect: WordBool dispid 218;
    property BackColor: OLE_COLOR dispid -501;
    property BackStyle: fmBackStyle dispid -502;
    property BorderColor: OLE_COLOR dispid -503;
    property BorderStyle: fmBorderStyle dispid -504;
    property BordersSuppress: WordBool dispid 20;
    function  BoundColumn: {??POleVariant1} OleVariant; dispid 501;
    property CanPaste: WordBool readonly dispid 25;
    property ColumnCount: Integer dispid 601;
    property ColumnHeads: WordBool dispid 602;
    property ColumnWidths: WideString dispid 603;
    property CurTargetX: Integer readonly dispid 210;
    property CurTargetY: Integer readonly dispid 221;
    property CurX: Integer dispid 208;
    property DropButtonStyle: fmDropButtonStyle dispid 305;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontName: WideString dispid 1;
    property FontSize: Currency dispid 2;
    property FontStrikethru: WordBool dispid 6;
    property FontUnderline: WordBool dispid 5;
    property FontWeight: Smallint dispid 7;
    property ForeColor: OLE_COLOR dispid -513;
    property HideSelection: WordBool dispid 207;
    property LineCount: Integer readonly dispid 214;
    property ListCount: Integer readonly dispid -531;
    property ListCursor: PIROWSET dispid 403;
    function  ListIndex: {??POleVariant1} OleVariant; dispid -526;
    property ListRows: Integer dispid 605;
    property ListStyle: fmListStyle dispid 307;
    function  ListWidth: {??POleVariant1} OleVariant; dispid 606;
    property Locked: WordBool dispid 10;
    property MatchEntry: fmMatchEntry dispid 504;
    property MatchFound: WordBool readonly dispid 505;
    property MatchRequired: WordBool dispid 503;
    property MaxLength: Integer dispid -533;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property SelectionMargin: WordBool dispid 220;
    property SelLength: Integer dispid -548;
    property SelStart: Integer dispid -547;
    property SelText: WideString dispid -546;
    property ShowDropButtonWhen: fmShowDropButtonWhen dispid 304;
    property SpecialEffect: fmSpecialEffect dispid 12;
    property Style: fmStyle dispid 308;
    property Text: WideString dispid -517;
    property TextAlign: fmTextAlign dispid 10004;
    function  TextColumn: {??POleVariant1} OleVariant; dispid 502;
    property TextLength: Integer readonly dispid 216;
    function  TopIndex: {??POleVariant1} OleVariant; dispid 611;
    property Valid: WordBool readonly dispid -524;
    function  Value: {??POleVariant1} OleVariant; dispid 0;
    function  Column(var pvargColumn: OleVariant; var pvargIndex: OleVariant): OleVariant; dispid -529;
    function  List(var pvargIndex: OleVariant; var pvargColumn: OleVariant): OleVariant; dispid -528;
    procedure AddItem(var pvargItem: OleVariant; var pvargIndex: OleVariant); dispid -553;
    procedure Clear; dispid -554;
    procedure DropDown; dispid 1001;
    procedure RemoveItem(var pvargIndex: OleVariant); dispid -555;
    procedure Copy; dispid 22;
    procedure Cut; dispid 21;
    procedure Paste; dispid 24;
    property IMEMode: fmIMEMode dispid -542;
    property EnterFieldBehavior: fmEnterFieldBehavior dispid 224;
    property DragBehavior: fmDragBehavior dispid 225;
    property DisplayStyle: fmDisplayStyle readonly dispid -540;
  end;

// *********************************************************************//
// Interface: IMdcCheckBox
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D43-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcCheckBox = interface(IDispatch)
    ['{8BD21D43-EC42-11CE-9E0D-00AA006002F3}']
    procedure Set_Accelerator(const Accelerator: WideString); safecall;
    function  Get_Accelerator: WideString; safecall;
    procedure Set_Alignment(Alignment: fmAlignment); safecall;
    function  Get_Alignment: fmAlignment; safecall;
    procedure Set_AutoSize(AutoSize: WordBool); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BackStyle(BackStyle: fmBackStyle); safecall;
    function  Get_BackStyle: fmBackStyle; safecall;
    procedure Set_BordersSuppress(BordersSuppress: WordBool); safecall;
    function  Get_BordersSuppress: WordBool; safecall;
    procedure Set_Caption(const Caption: WideString); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Enabled(Enabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_FontBold(FontBold: WordBool); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontItalic(FontItalic: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontName(const FontName: WideString); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontSize(FontSize: Currency); safecall;
    function  Get_FontSize: Currency; safecall;
    procedure Set_FontStrikethru(FontStrikethru: WordBool); safecall;
    function  Get_FontStrikethru: WordBool; safecall;
    procedure Set_FontUnderline(FontUnderline: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_FontWeight(FontWeight: Smallint); safecall;
    function  Get_FontWeight: Smallint; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set_Locked(Locked: WordBool); safecall;
    function  Get_Locked: WordBool; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_MultiSelect(MultiSelect: fmMultiSelect); safecall;
    function  Get_MultiSelect: fmMultiSelect; safecall;
    procedure _Set_Picture(const Picture: IPictureDisp); safecall;
    procedure Set_Picture(const Picture: IPictureDisp); safecall;
    function  Get_Picture: IPictureDisp; safecall;
    procedure Set_PicturePosition(PicPos: fmPicturePosition); safecall;
    function  Get_PicturePosition: fmPicturePosition; safecall;
    procedure Set_SpecialEffect(SpecialEffect: fmButtonEffect); safecall;
    function  Get_SpecialEffect: fmButtonEffect; safecall;
    procedure Set_TripleState(TripleState: WordBool); safecall;
    function  Get_TripleState: WordBool; safecall;
    function  Get_Valid: WordBool; safecall;
    procedure Set_Value(var Value: OleVariant); safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_WordWrap(WordWrap: WordBool); safecall;
    function  Get_WordWrap: WordBool; safecall;
    function  Get_DisplayStyle: fmDisplayStyle; safecall;
    procedure Set_GroupName(const GroupName: WideString); safecall;
    function  Get_GroupName: WideString; safecall;
    property Accelerator: WideString read Get_Accelerator write Set_Accelerator;
    property Alignment: fmAlignment read Get_Alignment write Set_Alignment;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property BackStyle: fmBackStyle read Get_BackStyle write Set_BackStyle;
    property BordersSuppress: WordBool read Get_BordersSuppress write Set_BordersSuppress;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontSize: Currency read Get_FontSize write Set_FontSize;
    property FontStrikethru: WordBool read Get_FontStrikethru write Set_FontStrikethru;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property FontWeight: Smallint read Get_FontWeight write Set_FontWeight;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property Locked: WordBool read Get_Locked write Set_Locked;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property MultiSelect: fmMultiSelect read Get_MultiSelect write Set_MultiSelect;
    property Picture: IPictureDisp read Get_Picture write _Set_Picture;
    property PicturePosition: fmPicturePosition read Get_PicturePosition write Set_PicturePosition;
    property SpecialEffect: fmButtonEffect read Get_SpecialEffect write Set_SpecialEffect;
    property TripleState: WordBool read Get_TripleState write Set_TripleState;
    property Valid: WordBool read Get_Valid;
    property WordWrap: WordBool read Get_WordWrap write Set_WordWrap;
    property DisplayStyle: fmDisplayStyle read Get_DisplayStyle;
    property GroupName: WideString read Get_GroupName write Set_GroupName;
  end;

// *********************************************************************//
// DispIntf:  IMdcCheckBoxDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D43-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcCheckBoxDisp = dispinterface
    ['{8BD21D43-EC42-11CE-9E0D-00AA006002F3}']
    property Accelerator: WideString dispid -543;
    property Alignment: fmAlignment dispid 710;
    property AutoSize: WordBool dispid -500;
    property BackColor: OLE_COLOR dispid -501;
    property BackStyle: fmBackStyle dispid -502;
    property BordersSuppress: WordBool dispid 20;
    property Caption: WideString dispid -518;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontName: WideString dispid 1;
    property FontSize: Currency dispid 2;
    property FontStrikethru: WordBool dispid 6;
    property FontUnderline: WordBool dispid 5;
    property FontWeight: Smallint dispid 7;
    property ForeColor: OLE_COLOR dispid -513;
    property Locked: WordBool dispid 10;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property MultiSelect: fmMultiSelect dispid -532;
    property Picture: IPictureDisp dispid -523;
    property PicturePosition: fmPicturePosition dispid 11;
    property SpecialEffect: fmButtonEffect dispid 12;
    property TripleState: WordBool dispid 700;
    property Valid: WordBool readonly dispid -524;
    function  Value: {??POleVariant1} OleVariant; dispid 0;
    property WordWrap: WordBool dispid -536;
    property DisplayStyle: fmDisplayStyle readonly dispid -540;
    property GroupName: WideString dispid -541;
  end;

// *********************************************************************//
// Interface: IMdcOptionButton
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D53-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcOptionButton = interface(IMdcCheckBox)
    ['{8BD21D53-EC42-11CE-9E0D-00AA006002F3}']
  end;

// *********************************************************************//
// DispIntf:  IMdcOptionButtonDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D53-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcOptionButtonDisp = dispinterface
    ['{8BD21D53-EC42-11CE-9E0D-00AA006002F3}']
    property Accelerator: WideString dispid -543;
    property Alignment: fmAlignment dispid 710;
    property AutoSize: WordBool dispid -500;
    property BackColor: OLE_COLOR dispid -501;
    property BackStyle: fmBackStyle dispid -502;
    property BordersSuppress: WordBool dispid 20;
    property Caption: WideString dispid -518;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontName: WideString dispid 1;
    property FontSize: Currency dispid 2;
    property FontStrikethru: WordBool dispid 6;
    property FontUnderline: WordBool dispid 5;
    property FontWeight: Smallint dispid 7;
    property ForeColor: OLE_COLOR dispid -513;
    property Locked: WordBool dispid 10;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property MultiSelect: fmMultiSelect dispid -532;
    property Picture: IPictureDisp dispid -523;
    property PicturePosition: fmPicturePosition dispid 11;
    property SpecialEffect: fmButtonEffect dispid 12;
    property TripleState: WordBool dispid 700;
    property Valid: WordBool readonly dispid -524;
    function  Value: {??POleVariant1} OleVariant; dispid 0;
    property WordWrap: WordBool dispid -536;
    property DisplayStyle: fmDisplayStyle readonly dispid -540;
    property GroupName: WideString dispid -541;
  end;

// *********************************************************************//
// Interface: IMdcToggleButton
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D63-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcToggleButton = interface(IMdcCheckBox)
    ['{8BD21D63-EC42-11CE-9E0D-00AA006002F3}']
  end;

// *********************************************************************//
// DispIntf:  IMdcToggleButtonDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {8BD21D63-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  IMdcToggleButtonDisp = dispinterface
    ['{8BD21D63-EC42-11CE-9E0D-00AA006002F3}']
    property Accelerator: WideString dispid -543;
    property Alignment: fmAlignment dispid 710;
    property AutoSize: WordBool dispid -500;
    property BackColor: OLE_COLOR dispid -501;
    property BackStyle: fmBackStyle dispid -502;
    property BordersSuppress: WordBool dispid 20;
    property Caption: WideString dispid -518;
    property Enabled: WordBool dispid -514;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontName: WideString dispid 1;
    property FontSize: Currency dispid 2;
    property FontStrikethru: WordBool dispid 6;
    property FontUnderline: WordBool dispid 5;
    property FontWeight: Smallint dispid 7;
    property ForeColor: OLE_COLOR dispid -513;
    property Locked: WordBool dispid 10;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property MultiSelect: fmMultiSelect dispid -532;
    property Picture: IPictureDisp dispid -523;
    property PicturePosition: fmPicturePosition dispid 11;
    property SpecialEffect: fmButtonEffect dispid 12;
    property TripleState: WordBool dispid 700;
    property Valid: WordBool readonly dispid -524;
    function  Value: {??POleVariant1} OleVariant; dispid 0;
    property WordWrap: WordBool dispid -536;
    property DisplayStyle: fmDisplayStyle readonly dispid -540;
    property GroupName: WideString dispid -541;
  end;

// *********************************************************************//
// Interface: IScrollbar
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC3-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  IScrollbar = interface(IDispatch)
    ['{04598FC3-866C-11CF-AB7C-00AA00C08FCF}']
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set_Enabled(Enabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_Value(Value: Integer); safecall;
    function  Get_Value: Integer; safecall;
    procedure Set_Min(Min: Integer); safecall;
    function  Get_Min: Integer; safecall;
    procedure Set_Max(Max: Integer); safecall;
    function  Get_Max: Integer; safecall;
    procedure Set_SmallChange(SmallChange: Integer); safecall;
    function  Get_SmallChange: Integer; safecall;
    procedure Set_LargeChange(LargeChange: Integer); safecall;
    function  Get_LargeChange: Integer; safecall;
    procedure Set_ProportionalThumb(ProportionalThumb: WordBool); safecall;
    function  Get_ProportionalThumb: WordBool; safecall;
    procedure Set_Orientation(Orientation: fmOrientation); safecall;
    function  Get_Orientation: fmOrientation; safecall;
    procedure Set_Delay(Delay: Integer); safecall;
    function  Get_Delay: Integer; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property Value: Integer read Get_Value write Set_Value;
    property Min: Integer read Get_Min write Set_Min;
    property Max: Integer read Get_Max write Set_Max;
    property SmallChange: Integer read Get_SmallChange write Set_SmallChange;
    property LargeChange: Integer read Get_LargeChange write Set_LargeChange;
    property ProportionalThumb: WordBool read Get_ProportionalThumb write Set_ProportionalThumb;
    property Orientation: fmOrientation read Get_Orientation write Set_Orientation;
    property Delay: Integer read Get_Delay write Set_Delay;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
  end;

// *********************************************************************//
// DispIntf:  IScrollbarDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC3-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  IScrollbarDisp = dispinterface
    ['{04598FC3-866C-11CF-AB7C-00AA00C08FCF}']
    property BackColor: OLE_COLOR dispid -501;
    property ForeColor: OLE_COLOR dispid -513;
    property Enabled: WordBool dispid -514;
    property MousePointer: fmMousePointer dispid -521;
    property Value: Integer dispid 0;
    property Min: Integer dispid 100;
    property Max: Integer dispid 101;
    property SmallChange: Integer dispid 102;
    property LargeChange: Integer dispid 103;
    property ProportionalThumb: WordBool dispid 104;
    property Orientation: fmOrientation dispid 105;
    property Delay: Integer dispid 106;
    property MouseIcon: IPictureDisp dispid -522;
  end;

// *********************************************************************//
// Interface: Tab
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A38BFFC3-A5A0-11CE-8107-00AA00611080}
// *********************************************************************//
  Tab = interface(IDispatch)
    ['{A38BFFC3-A5A0-11CE-8107-00AA00611080}']
    procedure Set_Caption(const Caption: WideString); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_ControlTipText(const ControlTipText: WideString); safecall;
    function  Get_ControlTipText: WideString; safecall;
    procedure Set_Enabled(fEnabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Index(Index: Integer); safecall;
    function  Get_Index: Integer; safecall;
    procedure Set_Name(const Name: WideString); safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_Tag(const Tag: WideString); safecall;
    function  Get_Tag: WideString; safecall;
    procedure Set_Visible(Visible: WordBool); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Accelerator(const Accelerator: WideString); safecall;
    function  Get_Accelerator: WideString; safecall;
    property Caption: WideString read Get_Caption write Set_Caption;
    property ControlTipText: WideString read Get_ControlTipText write Set_ControlTipText;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Index: Integer read Get_Index write Set_Index;
    property Name: WideString read Get_Name write Set_Name;
    property Tag: WideString read Get_Tag write Set_Tag;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Accelerator: WideString read Get_Accelerator write Set_Accelerator;
  end;

// *********************************************************************//
// DispIntf:  TabDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {A38BFFC3-A5A0-11CE-8107-00AA00611080}
// *********************************************************************//
  TabDisp = dispinterface
    ['{A38BFFC3-A5A0-11CE-8107-00AA00611080}']
    property Caption: WideString dispid -518;
    property ControlTipText: WideString dispid -2147418043;
    property Enabled: WordBool dispid -514;
    property Index: Integer dispid 1;
    property Name: WideString dispid -2147418112;
    property Tag: WideString dispid -2147418101;
    property Visible: WordBool dispid -2147418105;
    property Accelerator: WideString dispid -543;
  end;

// *********************************************************************//
// Interface: Tabs
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {944ACF93-A1E6-11CE-8104-00AA00611080}
// *********************************************************************//
  Tabs = interface(IDispatch)
    ['{944ACF93-A1E6-11CE-8104-00AA00611080}']
    function  Get_Count: Integer; safecall;
    function  Get__NewEnum: IUnknown; safecall;
    function  _GetItemByIndex(lIndex: Integer): Tab; safecall;
    function  _GetItemByName(const bstr: WideString): Tab; safecall;
    function  Item(varg: OleVariant): IDispatch; safecall;
    function  Enum: IUnknown; safecall;
    function  Add(bstrName: OleVariant; bstrCaption: OleVariant; lIndex: OleVariant): Tab; safecall;
    function  _Add(const bstrName: WideString; const bstrCaption: WideString): Tab; safecall;
    function  _Insert(const bstrName: WideString; const bstrCaption: WideString; lIndex: Integer): Tab; safecall;
    procedure Remove(varg: OleVariant); safecall;
    procedure Clear; safecall;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  TabsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {944ACF93-A1E6-11CE-8104-00AA00611080}
// *********************************************************************//
  TabsDisp = dispinterface
    ['{944ACF93-A1E6-11CE-8104-00AA00611080}']
    property Count: Integer readonly dispid 60;
    property _NewEnum: IUnknown readonly dispid -4;
    function  _GetItemByIndex(lIndex: Integer): Tab; dispid 1610743810;
    function  _GetItemByName(const bstr: WideString): Tab; dispid 1610743811;
    function  Item(varg: OleVariant): IDispatch; dispid 0;
    function  Enum: IUnknown; dispid 1610743813;
    function  Add(bstrName: OleVariant; bstrCaption: OleVariant; lIndex: OleVariant): Tab; dispid 66;
    function  _Add(const bstrName: WideString; const bstrCaption: WideString): Tab; dispid 1610743815;
    function  _Insert(const bstrName: WideString; const bstrCaption: WideString; lIndex: Integer): Tab; dispid 1610743816;
    procedure Remove(varg: OleVariant); dispid 67;
    procedure Clear; dispid 62;
  end;

// *********************************************************************//
// Interface: ITabStrip
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC2-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  ITabStrip = interface(IDispatch)
    ['{04598FC2-866C-11CF-AB7C-00AA00C08FCF}']
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_FontName(const FontName: WideString); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontBold(FontBold: WordBool); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontItalic(FontItalic: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontUnderline(FontUnder: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_FontStrikethru(FontStrike: WordBool); safecall;
    function  Get_FontStrikethru: WordBool; safecall;
    procedure Set_FontSize(FontSize: Currency); safecall;
    function  Get_FontSize: Currency; safecall;
    procedure Set_Enabled(fnabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_MultiRow(MultiRow: WordBool); safecall;
    function  Get_MultiRow: WordBool; safecall;
    procedure Set_Style(TabStyle: fmTabStyle); safecall;
    function  Get_Style: fmTabStyle; safecall;
    procedure Set_TabOrientation(TabOrientation: fmTabOrientation); safecall;
    function  Get_TabOrientation: fmTabOrientation; safecall;
    procedure _SetTabFixedWidth(TabFixedWidth: Integer); safecall;
    procedure _GetTabFixedWidth(out TabFixedWidth: Integer); safecall;
    procedure _SetTabFixedHeight(TabFixedHeight: Integer); safecall;
    procedure _GetTabFixedHeight(out TabFixedHeight: Integer); safecall;
    procedure _GetClientTop(out ClientTop: Integer); safecall;
    function  Get_ClientTop: Single; safecall;
    procedure _GetClientLeft(out ClientLeft: Integer); safecall;
    function  Get_ClientLeft: Single; safecall;
    procedure _GetClientWidth(out ClientWidth: Integer); safecall;
    function  Get_ClientWidth: Single; safecall;
    procedure _GetClientHeight(out ClientHeight: Integer); safecall;
    function  Get_ClientHeight: Single; safecall;
    function  Get_Tabs: Tabs; safecall;
    function  Get_SelectedItem: Tab; safecall;
    procedure Set_Value(Index: Integer); safecall;
    function  Get_Value: Integer; safecall;
    procedure Set_TabFixedWidth(TabFixedWidth: Single); safecall;
    function  Get_TabFixedWidth: Single; safecall;
    procedure Set_TabFixedHeight(TabFixedHeight: Single); safecall;
    function  Get_TabFixedHeight: Single; safecall;
    procedure Set_FontWeight(FontWeight: Smallint); safecall;
    function  Get_FontWeight: Smallint; safecall;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property FontStrikethru: WordBool read Get_FontStrikethru write Set_FontStrikethru;
    property FontSize: Currency read Get_FontSize write Set_FontSize;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property MultiRow: WordBool read Get_MultiRow write Set_MultiRow;
    property Style: fmTabStyle read Get_Style write Set_Style;
    property TabOrientation: fmTabOrientation read Get_TabOrientation write Set_TabOrientation;
    property ClientTop: Single read Get_ClientTop;
    property ClientLeft: Single read Get_ClientLeft;
    property ClientWidth: Single read Get_ClientWidth;
    property ClientHeight: Single read Get_ClientHeight;
    property Tabs: Tabs read Get_Tabs;
    property SelectedItem: Tab read Get_SelectedItem;
    property Value: Integer read Get_Value write Set_Value;
    property TabFixedWidth: Single read Get_TabFixedWidth write Set_TabFixedWidth;
    property TabFixedHeight: Single read Get_TabFixedHeight write Set_TabFixedHeight;
    property FontWeight: Smallint read Get_FontWeight write Set_FontWeight;
  end;

// *********************************************************************//
// DispIntf:  ITabStripDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC2-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  ITabStripDisp = dispinterface
    ['{04598FC2-866C-11CF-AB7C-00AA00C08FCF}']
    property BackColor: OLE_COLOR dispid -501;
    property ForeColor: OLE_COLOR dispid -513;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontName: WideString dispid 1;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontUnderline: WordBool dispid 5;
    property FontStrikethru: WordBool dispid 6;
    property FontSize: Currency dispid 2;
    property Enabled: WordBool dispid -514;
    property MouseIcon: IPictureDisp dispid -522;
    property MousePointer: fmMousePointer dispid -521;
    property MultiRow: WordBool dispid 514;
    property Style: fmTabStyle dispid 513;
    property TabOrientation: fmTabOrientation dispid 512;
    procedure _SetTabFixedWidth(TabFixedWidth: Integer); dispid 1610743840;
    procedure _GetTabFixedWidth(out TabFixedWidth: Integer); dispid 1610743841;
    procedure _SetTabFixedHeight(TabFixedHeight: Integer); dispid 1610743842;
    procedure _GetTabFixedHeight(out TabFixedHeight: Integer); dispid 1610743843;
    procedure _GetClientTop(out ClientTop: Integer); dispid 1610743844;
    property ClientTop: Single readonly dispid 548;
    procedure _GetClientLeft(out ClientLeft: Integer); dispid 1610743846;
    property ClientLeft: Single readonly dispid 547;
    procedure _GetClientWidth(out ClientWidth: Integer); dispid 1610743848;
    property ClientWidth: Single readonly dispid 549;
    procedure _GetClientHeight(out ClientHeight: Integer); dispid 1610743850;
    property ClientHeight: Single readonly dispid 546;
    property Tabs: Tabs readonly dispid 0;
    property SelectedItem: Tab readonly dispid 545;
    property Value: Integer dispid 528;
    property TabFixedWidth: Single dispid 515;
    property TabFixedHeight: Single dispid 516;
    property FontWeight: Smallint dispid 7;
  end;

// *********************************************************************//
// Interface: ISpinbutton
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {79176FB3-B7F2-11CE-97EF-00AA006D2776}
// *********************************************************************//
  ISpinbutton = interface(IDispatch)
    ['{79176FB3-B7F2-11CE-97EF-00AA006D2776}']
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_ForeColor(ForeColor: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set_Enabled(Enabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_Value(Value: Integer); safecall;
    function  Get_Value: Integer; safecall;
    procedure Set_Min(Min: Integer); safecall;
    function  Get_Min: Integer; safecall;
    procedure Set_Max(Max: Integer); safecall;
    function  Get_Max: Integer; safecall;
    procedure Set_SmallChange(SmallChange: Integer); safecall;
    function  Get_SmallChange: Integer; safecall;
    procedure Set_Orientation(Orientation: fmOrientation); safecall;
    function  Get_Orientation: fmOrientation; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_Delay(Delay: Integer); safecall;
    function  Get_Delay: Integer; safecall;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property Value: Integer read Get_Value write Set_Value;
    property Min: Integer read Get_Min write Set_Min;
    property Max: Integer read Get_Max write Set_Max;
    property SmallChange: Integer read Get_SmallChange write Set_SmallChange;
    property Orientation: fmOrientation read Get_Orientation write Set_Orientation;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property Delay: Integer read Get_Delay write Set_Delay;
  end;

// *********************************************************************//
// DispIntf:  ISpinbuttonDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {79176FB3-B7F2-11CE-97EF-00AA006D2776}
// *********************************************************************//
  ISpinbuttonDisp = dispinterface
    ['{79176FB3-B7F2-11CE-97EF-00AA006D2776}']
    property BackColor: OLE_COLOR dispid -501;
    property ForeColor: OLE_COLOR dispid -513;
    property Enabled: WordBool dispid -514;
    property MousePointer: fmMousePointer dispid -521;
    property Value: Integer dispid 0;
    property Min: Integer dispid 100;
    property Max: Integer dispid 101;
    property SmallChange: Integer dispid 102;
    property Orientation: fmOrientation dispid 105;
    property MouseIcon: IPictureDisp dispid -522;
    property Delay: Integer dispid 106;
  end;

// *********************************************************************//
// Interface: IImage
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {4C599243-6926-101B-9992-00000B65C6F9}
// *********************************************************************//
  IImage = interface(IDispatch)
    ['{4C599243-6926-101B-9992-00000B65C6F9}']
    procedure Set_Enabled(fEnabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_MousePointer(MousePointer: fmMousePointer); safecall;
    function  Get_MousePointer: fmMousePointer; safecall;
    procedure Set_AutoSize(fAutoSize: WordBool); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_BackColor(BackColor: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_BackStyle(BackStyle: fmBackStyle); safecall;
    function  Get_BackStyle: fmBackStyle; safecall;
    procedure Set_BorderColor(BorderColor: OLE_COLOR); safecall;
    function  Get_BorderColor: OLE_COLOR; safecall;
    procedure Set_BorderStyle(Style: fmBorderStyle); safecall;
    function  Get_BorderStyle: fmBorderStyle; safecall;
    procedure _Set_Picture(const Picture: IPictureDisp); safecall;
    procedure Set_Picture(const Picture: IPictureDisp); safecall;
    function  Get_Picture: IPictureDisp; safecall;
    procedure _Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    procedure Set_MouseIcon(const MouseIcon: IPictureDisp); safecall;
    function  Get_MouseIcon: IPictureDisp; safecall;
    procedure Set_PictureSizeMode(PictureSizeMode: fmPictureSizeMode); safecall;
    function  Get_PictureSizeMode: fmPictureSizeMode; safecall;
    procedure Set_PictureAlignment(PictureAlignment: fmPictureAlignment); safecall;
    function  Get_PictureAlignment: fmPictureAlignment; safecall;
    procedure Set_PictureTiling(PictureTiling: WordBool); safecall;
    function  Get_PictureTiling: WordBool; safecall;
    procedure Set_SpecialEffect(SpecialEffect: fmSpecialEffect); safecall;
    function  Get_SpecialEffect: fmSpecialEffect; safecall;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property MousePointer: fmMousePointer read Get_MousePointer write Set_MousePointer;
    property AutoSize: WordBool read Get_AutoSize write Set_AutoSize;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property BackStyle: fmBackStyle read Get_BackStyle write Set_BackStyle;
    property BorderColor: OLE_COLOR read Get_BorderColor write Set_BorderColor;
    property BorderStyle: fmBorderStyle read Get_BorderStyle write Set_BorderStyle;
    property Picture: IPictureDisp read Get_Picture write _Set_Picture;
    property MouseIcon: IPictureDisp read Get_MouseIcon write _Set_MouseIcon;
    property PictureSizeMode: fmPictureSizeMode read Get_PictureSizeMode write Set_PictureSizeMode;
    property PictureAlignment: fmPictureAlignment read Get_PictureAlignment write Set_PictureAlignment;
    property PictureTiling: WordBool read Get_PictureTiling write Set_PictureTiling;
    property SpecialEffect: fmSpecialEffect read Get_SpecialEffect write Set_SpecialEffect;
  end;

// *********************************************************************//
// DispIntf:  IImageDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {4C599243-6926-101B-9992-00000B65C6F9}
// *********************************************************************//
  IImageDisp = dispinterface
    ['{4C599243-6926-101B-9992-00000B65C6F9}']
    property Enabled: WordBool dispid -514;
    property MousePointer: fmMousePointer dispid -521;
    property AutoSize: WordBool dispid -500;
    property BackColor: OLE_COLOR dispid -501;
    property BackStyle: fmBackStyle dispid -502;
    property BorderColor: OLE_COLOR dispid -503;
    property BorderStyle: fmBorderStyle dispid -504;
    property Picture: IPictureDisp dispid -523;
    property MouseIcon: IPictureDisp dispid -522;
    property PictureSizeMode: fmPictureSizeMode dispid 27;
    property PictureAlignment: fmPictureAlignment dispid 26;
    property PictureTiling: WordBool dispid 28;
    property SpecialEffect: fmSpecialEffect dispid 12;
  end;

// *********************************************************************//
// Interface: IWHTMLSubmitButton
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D111-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLSubmitButton = interface(IDispatch)
    ['{5512D111-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_Action(const Action: WideString); safecall;
    function  Get_Action: WideString; safecall;
    procedure Set_Caption(const Caption: WideString); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Encoding(const Encoding: WideString); safecall;
    function  Get_Encoding: WideString; safecall;
    procedure Set_Method(const Method: WideString); safecall;
    function  Get_Method: WideString; safecall;
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_HTMLType(const HTMLType: WideString); safecall;
    function  Get_HTMLType: WideString; safecall;
    property Action: WideString read Get_Action write Set_Action;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Encoding: WideString read Get_Encoding write Set_Encoding;
    property Method: WideString read Get_Method write Set_Method;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property HTMLType: WideString read Get_HTMLType write Set_HTMLType;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLSubmitButtonDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D111-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLSubmitButtonDisp = dispinterface
    ['{5512D111-5CC6-11CF-8D67-00AA00BDCE1D}']
    property Action: WideString dispid 601;
    property Caption: WideString dispid 602;
    property Encoding: WideString dispid 603;
    property Method: WideString dispid 604;
    property HTMLName: WideString dispid -541;
    property HTMLType: WideString dispid 618;
  end;

// *********************************************************************//
// Interface: IWHTMLImage
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D113-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLImage = interface(IDispatch)
    ['{5512D113-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_Action(const Action: WideString); safecall;
    function  Get_Action: WideString; safecall;
    procedure Set_Source(const Source: WideString); safecall;
    function  Get_Source: WideString; safecall;
    procedure Set_Encoding(const Encoding: WideString); safecall;
    function  Get_Encoding: WideString; safecall;
    procedure Set_Method(const Method: WideString); safecall;
    function  Get_Method: WideString; safecall;
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_HTMLType(const HTMLType: WideString); safecall;
    function  Get_HTMLType: WideString; safecall;
    property Action: WideString read Get_Action write Set_Action;
    property Source: WideString read Get_Source write Set_Source;
    property Encoding: WideString read Get_Encoding write Set_Encoding;
    property Method: WideString read Get_Method write Set_Method;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property HTMLType: WideString read Get_HTMLType write Set_HTMLType;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLImageDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D113-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLImageDisp = dispinterface
    ['{5512D113-5CC6-11CF-8D67-00AA00BDCE1D}']
    property Action: WideString dispid 601;
    property Source: WideString dispid 606;
    property Encoding: WideString dispid 603;
    property Method: WideString dispid 604;
    property HTMLName: WideString dispid -541;
    property HTMLType: WideString dispid 618;
  end;

// *********************************************************************//
// Interface: IWHTMLReset
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D115-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLReset = interface(IDispatch)
    ['{5512D115-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_Caption(const Caption: WideString); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_HTMLType(const HTMLType: WideString); safecall;
    function  Get_HTMLType: WideString; safecall;
    property Caption: WideString read Get_Caption write Set_Caption;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property HTMLType: WideString read Get_HTMLType write Set_HTMLType;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLResetDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D115-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLResetDisp = dispinterface
    ['{5512D115-5CC6-11CF-8D67-00AA00BDCE1D}']
    property Caption: WideString dispid 602;
    property HTMLName: WideString dispid -541;
    property HTMLType: WideString dispid 618;
  end;

// *********************************************************************//
// Interface: IWHTMLCheckbox
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D117-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLCheckbox = interface(IDispatch)
    ['{5512D117-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_Value(const Value: WideString); safecall;
    function  Get_Value: WideString; safecall;
    procedure Set_Checked(Checked: WordBool); safecall;
    function  Get_Checked: WordBool; safecall;
    procedure Set_HTMLType(const HTMLType: WideString); safecall;
    function  Get_HTMLType: WideString; safecall;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property Value: WideString read Get_Value write Set_Value;
    property Checked: WordBool read Get_Checked write Set_Checked;
    property HTMLType: WideString read Get_HTMLType write Set_HTMLType;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLCheckboxDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D117-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLCheckboxDisp = dispinterface
    ['{5512D117-5CC6-11CF-8D67-00AA00BDCE1D}']
    property HTMLName: WideString dispid -541;
    property Value: WideString dispid 607;
    property Checked: WordBool dispid 0;
    property HTMLType: WideString dispid 618;
  end;

// *********************************************************************//
// Interface: IWHTMLOption
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D119-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLOption = interface(IDispatch)
    ['{5512D119-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_Value(const Value: WideString); safecall;
    function  Get_Value: WideString; safecall;
    procedure Set_Checked(Checked: WordBool); safecall;
    function  Get_Checked: WordBool; safecall;
    procedure Set_HTMLType(const HTMLType: WideString); safecall;
    function  Get_HTMLType: WideString; safecall;
    function  Get_DisplayStyle: fmDisplayStyle; safecall;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property Value: WideString read Get_Value write Set_Value;
    property Checked: WordBool read Get_Checked write Set_Checked;
    property HTMLType: WideString read Get_HTMLType write Set_HTMLType;
    property DisplayStyle: fmDisplayStyle read Get_DisplayStyle;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLOptionDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D119-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLOptionDisp = dispinterface
    ['{5512D119-5CC6-11CF-8D67-00AA00BDCE1D}']
    property HTMLName: WideString dispid -541;
    property Value: WideString dispid 607;
    property Checked: WordBool dispid 0;
    property HTMLType: WideString dispid 618;
    property DisplayStyle: fmDisplayStyle readonly dispid -540;
  end;

// *********************************************************************//
// Interface: IWHTMLText
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D11B-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLText = interface(IDispatch)
    ['{5512D11B-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_Value(const Value: WideString); safecall;
    function  Get_Value: WideString; safecall;
    procedure Set_MaxLength(MaxLength: Integer); safecall;
    function  Get_MaxLength: Integer; safecall;
    procedure Set_Width(Width: Integer); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_HTMLType(const HTMLType: WideString); safecall;
    function  Get_HTMLType: WideString; safecall;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property Value: WideString read Get_Value write Set_Value;
    property MaxLength: Integer read Get_MaxLength write Set_MaxLength;
    property Width: Integer read Get_Width write Set_Width;
    property HTMLType: WideString read Get_HTMLType write Set_HTMLType;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLTextDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D11B-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLTextDisp = dispinterface
    ['{5512D11B-5CC6-11CF-8D67-00AA00BDCE1D}']
    property HTMLName: WideString dispid -541;
    property Value: WideString dispid 0;
    property MaxLength: Integer dispid 609;
    property Width: Integer dispid 610;
    property HTMLType: WideString dispid 618;
  end;

// *********************************************************************//
// Interface: IWHTMLHidden
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D11D-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLHidden = interface(IDispatch)
    ['{5512D11D-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_Value(const Value: WideString); safecall;
    function  Get_Value: WideString; safecall;
    procedure Set_HTMLType(const HTMLType: WideString); safecall;
    function  Get_HTMLType: WideString; safecall;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property Value: WideString read Get_Value write Set_Value;
    property HTMLType: WideString read Get_HTMLType write Set_HTMLType;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLHiddenDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D11D-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLHiddenDisp = dispinterface
    ['{5512D11D-5CC6-11CF-8D67-00AA00BDCE1D}']
    property HTMLName: WideString dispid -541;
    property Value: WideString dispid 0;
    property HTMLType: WideString dispid 618;
  end;

// *********************************************************************//
// Interface: IWHTMLPassword
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D11F-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLPassword = interface(IDispatch)
    ['{5512D11F-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_Value(const Value: WideString); safecall;
    function  Get_Value: WideString; safecall;
    procedure Set_MaxLength(MaxLength: Integer); safecall;
    function  Get_MaxLength: Integer; safecall;
    procedure Set_Width(Width: Integer); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_HTMLType(const HTMLType: WideString); safecall;
    function  Get_HTMLType: WideString; safecall;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property Value: WideString read Get_Value write Set_Value;
    property MaxLength: Integer read Get_MaxLength write Set_MaxLength;
    property Width: Integer read Get_Width write Set_Width;
    property HTMLType: WideString read Get_HTMLType write Set_HTMLType;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLPasswordDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D11F-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLPasswordDisp = dispinterface
    ['{5512D11F-5CC6-11CF-8D67-00AA00BDCE1D}']
    property HTMLName: WideString dispid -541;
    property Value: WideString dispid 0;
    property MaxLength: Integer dispid 609;
    property Width: Integer dispid 610;
    property HTMLType: WideString dispid 618;
  end;

// *********************************************************************//
// Interface: IWHTMLSelect
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D123-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLSelect = interface(IDispatch)
    ['{5512D123-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_Values(var Values: OleVariant); safecall;
    function  Get_Values: OleVariant; safecall;
    procedure Set_DisplayValues(var DisplayValues: OleVariant); safecall;
    function  Get_DisplayValues: OleVariant; safecall;
    procedure Set_Selected(const Selected: WideString); safecall;
    function  Get_Selected: WideString; safecall;
    procedure Set_MultiSelect(MultiSelect: WordBool); safecall;
    function  Get_MultiSelect: WordBool; safecall;
    procedure Set_Size(Size: Integer); safecall;
    function  Get_Size: Integer; safecall;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property Selected: WideString read Get_Selected write Set_Selected;
    property MultiSelect: WordBool read Get_MultiSelect write Set_MultiSelect;
    property Size: Integer read Get_Size write Set_Size;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLSelectDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D123-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLSelectDisp = dispinterface
    ['{5512D123-5CC6-11CF-8D67-00AA00BDCE1D}']
    property HTMLName: WideString dispid -541;
    function  Values: {??POleVariant1} OleVariant; dispid 611;
    function  DisplayValues: {??POleVariant1} OleVariant; dispid 612;
    property Selected: WideString dispid 613;
    property MultiSelect: WordBool dispid 614;
    property Size: Integer dispid 619;
  end;

// *********************************************************************//
// Interface: IWHTMLTextArea
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D125-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLTextArea = interface(IDispatch)
    ['{5512D125-5CC6-11CF-8D67-00AA00BDCE1D}']
    procedure Set_HTMLName(const HTMLName: WideString); safecall;
    function  Get_HTMLName: WideString; safecall;
    procedure Set_Value(const Value: WideString); safecall;
    function  Get_Value: WideString; safecall;
    procedure Set_Rows(Rows: Integer); safecall;
    function  Get_Rows: Integer; safecall;
    procedure Set_Columns(Columns: Integer); safecall;
    function  Get_Columns: Integer; safecall;
    procedure Set_WordWrap(const WordWrap: WideString); safecall;
    function  Get_WordWrap: WideString; safecall;
    property HTMLName: WideString read Get_HTMLName write Set_HTMLName;
    property Value: WideString read Get_Value write Set_Value;
    property Rows: Integer read Get_Rows write Set_Rows;
    property Columns: Integer read Get_Columns write Set_Columns;
    property WordWrap: WideString read Get_WordWrap write Set_WordWrap;
  end;

// *********************************************************************//
// DispIntf:  IWHTMLTextAreaDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5512D125-5CC6-11CF-8D67-00AA00BDCE1D}
// *********************************************************************//
  IWHTMLTextAreaDisp = dispinterface
    ['{5512D125-5CC6-11CF-8D67-00AA00BDCE1D}']
    property HTMLName: WideString dispid -541;
    property Value: WideString dispid 0;
    property Rows: Integer dispid 615;
    property Columns: Integer dispid 616;
    property WordWrap: WideString dispid 617;
  end;

// *********************************************************************//
// DispIntf:  LabelControlEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {978C9E22-D4B0-11CE-BF2D-00AA003F40D0}
// *********************************************************************//
  LabelControlEvents = dispinterface
    ['{978C9E22-D4B0-11CE-BF2D-00AA003F40D0}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Click; dispid -600;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  CommandButtonEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {7B020EC1-AF6C-11CE-9F46-00AA00574A4F}
// *********************************************************************//
  CommandButtonEvents = dispinterface
    ['{7B020EC1-AF6C-11CE-9F46-00AA00574A4F}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Click; dispid -600;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  MdcTextEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {8BD21D12-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  MdcTextEvents = dispinterface
    ['{8BD21D12-EC42-11CE-9E0D-00AA006002F3}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure DropButtonClick; dispid 2002;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  MdcListEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {8BD21D22-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  MdcListEvents = dispinterface
    ['{8BD21D22-EC42-11CE-9E0D-00AA006002F3}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Click; dispid -610;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  MdcComboEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {8BD21D32-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  MdcComboEvents = dispinterface
    ['{8BD21D32-EC42-11CE-9E0D-00AA006002F3}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Click; dispid -610;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure DropButtonClick; dispid 2002;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  MdcCheckBoxEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {8BD21D42-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  MdcCheckBoxEvents = dispinterface
    ['{8BD21D42-EC42-11CE-9E0D-00AA006002F3}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Click; dispid -610;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  MdcOptionButtonEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {8BD21D52-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  MdcOptionButtonEvents = dispinterface
    ['{8BD21D52-EC42-11CE-9E0D-00AA006002F3}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Click; dispid -610;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  MdcToggleButtonEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {8BD21D62-EC42-11CE-9E0D-00AA006002F3}
// *********************************************************************//
  MdcToggleButtonEvents = dispinterface
    ['{8BD21D62-EC42-11CE-9E0D-00AA006002F3}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Click; dispid -610;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  ScrollbarEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {7B020EC2-AF6C-11CE-9F46-00AA00574A4F}
// *********************************************************************//
  ScrollbarEvents = dispinterface
    ['{7B020EC2-AF6C-11CE-9F46-00AA00574A4F}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure Scroll; dispid 7;
  end;

// *********************************************************************//
// DispIntf:  TabStripEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {7B020EC7-AF6C-11CE-9F46-00AA00574A4F}
// *********************************************************************//
  TabStripEvents = dispinterface
    ['{7B020EC7-AF6C-11CE-9F46-00AA00574A4F}']
    procedure BeforeDragOver(Index: Integer; const Cancel: ReturnBoolean; const Data: DataObject; 
                             X: Single; Y: Single; DragState: fmDragState; 
                             const Effect: ReturnEffect; Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(Index: Integer; const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Click(Index: Integer); dispid -600;
    procedure DblClick(Index: Integer; const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure MouseDown(Index: Integer; Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Index: Integer; Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Index: Integer; Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  SpinbuttonEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {79176FB2-B7F2-11CE-97EF-00AA006D2776}
// *********************************************************************//
  SpinbuttonEvents = dispinterface
    ['{79176FB2-B7F2-11CE-97EF-00AA006D2776}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure SpinUp; dispid 5;
    procedure SpinDown; dispid 6;
  end;

// *********************************************************************//
// DispIntf:  ImageEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {4C5992A5-6926-101B-9992-00000B65C6F9}
// *********************************************************************//
  ImageEvents = dispinterface
    ['{4C5992A5-6926-101B-9992-00000B65C6F9}']
    procedure BeforeDragOver(const Cancel: ReturnBoolean; const Data: DataObject; X: Single; 
                             Y: Single; DragState: fmDragState; const Effect: ReturnEffect; 
                             Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(const Cancel: ReturnBoolean; Action: fmAction; 
                                const Data: DataObject; X: Single; Y: Single; 
                                const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Click; dispid -600;
    procedure DblClick(const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Number: Smallint; const Description: ReturnString; SCode: Integer; 
                    const Source: WideString; const HelpFile: WideString; HelpContext: Integer; 
                    const CancelDisplay: ReturnBoolean); dispid -608;
    procedure MouseDown(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {796ED650-5FE9-11CF-8D68-00AA00BDCE1D}
// *********************************************************************//
  WHTMLControlEvents = dispinterface
    ['{796ED650-5FE9-11CF-8D68-00AA00BDCE1D}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents1
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE0-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents1 = dispinterface
    ['{47FF8FE0-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents2
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE1-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents2 = dispinterface
    ['{47FF8FE1-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents3
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE2-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents3 = dispinterface
    ['{47FF8FE2-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents4
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE3-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents4 = dispinterface
    ['{47FF8FE3-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents5
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE4-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents5 = dispinterface
    ['{47FF8FE4-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents6
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE5-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents6 = dispinterface
    ['{47FF8FE5-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents7
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE6-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents7 = dispinterface
    ['{47FF8FE6-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents9
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE8-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents9 = dispinterface
    ['{47FF8FE8-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// DispIntf:  WHTMLControlEvents10
// Flags:     (4112) Hidden Dispatchable
// GUID:      {47FF8FE9-6198-11CF-8CE8-00AA006CB389}
// *********************************************************************//
  WHTMLControlEvents10 = dispinterface
    ['{47FF8FE9-6198-11CF-8CE8-00AA006CB389}']
    procedure Click; dispid -600;
  end;

// *********************************************************************//
// Interface: IPage
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5CEF5613-713D-11CE-80C9-00AA00611080}
// *********************************************************************//
  IPage = interface(IDispatch)
    ['{5CEF5613-713D-11CE-80C9-00AA00611080}']
    function  Get_Controls: Controls; safecall;
    function  Get_Selected: Controls; safecall;
    function  Get_ActiveControl: Control; safecall;
    function  Get_CanPaste: WordBool; safecall;
    function  Get_CanRedo: WordBool; safecall;
    function  Get_CanUndo: WordBool; safecall;
    procedure Set_Cycle(Cycle: fmCycle); safecall;
    function  Get_Cycle: fmCycle; safecall;
    procedure Set_Caption(const Caption: WideString); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_ControlTipText(const tooltip: WideString); safecall;
    function  Get_ControlTipText: WideString; safecall;
    procedure Set_Enabled(fEnabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Index(Index: Integer); safecall;
    function  Get_Index: Integer; safecall;
    procedure _GetInsideHeight(out InsideHeight: Integer); safecall;
    function  Get_InsideHeight: Single; safecall;
    procedure _GetInsideWidth(out InsideWidth: Integer); safecall;
    function  Get_InsideWidth: Single; safecall;
    procedure Set_KeepScrollBarsVisible(ScrollBars: fmScrollBars); safecall;
    function  Get_KeepScrollBarsVisible: fmScrollBars; safecall;
    procedure Set_Name(const Name: WideString); safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_PictureAlignment(PictureAlignment: fmPictureAlignment); safecall;
    function  Get_PictureAlignment: fmPictureAlignment; safecall;
    procedure _Set_Picture(const Picture: IPictureDisp); safecall;
    procedure Set_Picture(const Picture: IPictureDisp); safecall;
    function  Get_Picture: IPictureDisp; safecall;
    procedure Set_PictureSizeMode(PictureSizeMode: fmPictureSizeMode); safecall;
    function  Get_PictureSizeMode: fmPictureSizeMode; safecall;
    procedure Set_PictureTiling(PictureTiling: WordBool); safecall;
    function  Get_PictureTiling: WordBool; safecall;
    procedure Set_ScrollBars(ScrollBars: fmScrollBars); safecall;
    function  Get_ScrollBars: fmScrollBars; safecall;
    procedure _SetScrollHeight(ScrollHeight: Integer); safecall;
    procedure _GetScrollHeight(out ScrollHeight: Integer); safecall;
    procedure Set_ScrollHeight(ScrollHeight: Single); safecall;
    function  Get_ScrollHeight: Single; safecall;
    procedure _SetScrollLeft(ScrollLeft: Integer); safecall;
    procedure _GetScrollLeft(out ScrollLeft: Integer); safecall;
    procedure Set_ScrollLeft(ScrollLeft: Single); safecall;
    function  Get_ScrollLeft: Single; safecall;
    procedure _SetScrollTop(ScrollTop: Integer); safecall;
    procedure _GetScrollTop(out ScrollTop: Integer); safecall;
    procedure Set_ScrollTop(ScrollTop: Single); safecall;
    function  Get_ScrollTop: Single; safecall;
    procedure _SetScrollWidth(ScrollWidth: Integer); safecall;
    procedure _GetScrollWidth(out ScrollWidth: Integer); safecall;
    procedure Set_ScrollWidth(ScrollWidth: Single); safecall;
    function  Get_ScrollWidth: Single; safecall;
    procedure Set_Tag(const Tag: WideString); safecall;
    function  Get_Tag: WideString; safecall;
    procedure Set_TransitionEffect(TransitionEffect: fmTransitionEffect); safecall;
    function  Get_TransitionEffect: fmTransitionEffect; safecall;
    procedure Set_TransitionPeriod(TransitionPeriod: Integer); safecall;
    function  Get_TransitionPeriod: Integer; safecall;
    procedure Set_VerticalScrollBarSide(side: fmVerticalScrollBarSide); safecall;
    function  Get_VerticalScrollBarSide: fmVerticalScrollBarSide; safecall;
    procedure Set_Visible(fVisible: WordBool); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Zoom(Zoom: Smallint); safecall;
    function  Get_Zoom: Smallint; safecall;
    procedure Set_DesignMode(DesignMode: fmMode); safecall;
    function  Get_DesignMode: fmMode; safecall;
    procedure Set_ShowToolbox(ShowToolbox: fmMode); safecall;
    function  Get_ShowToolbox: fmMode; safecall;
    procedure Set_ShowGridDots(ShowGridDots: fmMode); safecall;
    function  Get_ShowGridDots: fmMode; safecall;
    procedure Set_SnapToGrid(SnapToGrid: fmMode); safecall;
    function  Get_SnapToGrid: fmMode; safecall;
    procedure Set_GridX(GridX: Single); safecall;
    function  Get_GridX: Single; safecall;
    procedure _SetGridX(GridX: Integer); safecall;
    procedure _GetGridX(out GridX: Integer); safecall;
    procedure Set_GridY(GridY: Single); safecall;
    function  Get_GridY: Single; safecall;
    procedure _SetGridY(GridY: Integer); safecall;
    procedure _GetGridY(out GridY: Integer); safecall;
    procedure Copy; safecall;
    procedure Cut; safecall;
    procedure Paste; safecall;
    procedure RedoAction; safecall;
    procedure Repaint; safecall;
    procedure Scroll(xAction: OleVariant; yAction: OleVariant); safecall;
    procedure SetDefaultTabOrder; safecall;
    procedure UndoAction; safecall;
    procedure Set_Accelerator(const Accelerator: WideString); safecall;
    function  Get_Accelerator: WideString; safecall;
    function  Get_Parent: IDispatch; safecall;
    property Controls: Controls read Get_Controls;
    property Selected: Controls read Get_Selected;
    property ActiveControl: Control read Get_ActiveControl;
    property CanPaste: WordBool read Get_CanPaste;
    property CanRedo: WordBool read Get_CanRedo;
    property CanUndo: WordBool read Get_CanUndo;
    property Cycle: fmCycle read Get_Cycle write Set_Cycle;
    property Caption: WideString read Get_Caption write Set_Caption;
    property ControlTipText: WideString read Get_ControlTipText write Set_ControlTipText;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Index: Integer read Get_Index write Set_Index;
    property InsideHeight: Single read Get_InsideHeight;
    property InsideWidth: Single read Get_InsideWidth;
    property KeepScrollBarsVisible: fmScrollBars read Get_KeepScrollBarsVisible write Set_KeepScrollBarsVisible;
    property Name: WideString read Get_Name write Set_Name;
    property PictureAlignment: fmPictureAlignment read Get_PictureAlignment write Set_PictureAlignment;
    property Picture: IPictureDisp read Get_Picture write _Set_Picture;
    property PictureSizeMode: fmPictureSizeMode read Get_PictureSizeMode write Set_PictureSizeMode;
    property PictureTiling: WordBool read Get_PictureTiling write Set_PictureTiling;
    property ScrollBars: fmScrollBars read Get_ScrollBars write Set_ScrollBars;
    property ScrollHeight: Single read Get_ScrollHeight write Set_ScrollHeight;
    property ScrollLeft: Single read Get_ScrollLeft write Set_ScrollLeft;
    property ScrollTop: Single read Get_ScrollTop write Set_ScrollTop;
    property ScrollWidth: Single read Get_ScrollWidth write Set_ScrollWidth;
    property Tag: WideString read Get_Tag write Set_Tag;
    property TransitionEffect: fmTransitionEffect read Get_TransitionEffect write Set_TransitionEffect;
    property TransitionPeriod: Integer read Get_TransitionPeriod write Set_TransitionPeriod;
    property VerticalScrollBarSide: fmVerticalScrollBarSide read Get_VerticalScrollBarSide write Set_VerticalScrollBarSide;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Zoom: Smallint read Get_Zoom write Set_Zoom;
    property DesignMode: fmMode read Get_DesignMode write Set_DesignMode;
    property ShowToolbox: fmMode read Get_ShowToolbox write Set_ShowToolbox;
    property ShowGridDots: fmMode read Get_ShowGridDots write Set_ShowGridDots;
    property SnapToGrid: fmMode read Get_SnapToGrid write Set_SnapToGrid;
    property GridX: Single read Get_GridX write Set_GridX;
    property GridY: Single read Get_GridY write Set_GridY;
    property Accelerator: WideString read Get_Accelerator write Set_Accelerator;
    property Parent: IDispatch read Get_Parent;
  end;

// *********************************************************************//
// DispIntf:  IPageDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {5CEF5613-713D-11CE-80C9-00AA00611080}
// *********************************************************************//
  IPageDisp = dispinterface
    ['{5CEF5613-713D-11CE-80C9-00AA00611080}']
    property Controls: Controls readonly dispid 0;
    property Selected: Controls readonly dispid 270;
    property ActiveControl: Control readonly dispid 256;
    property CanPaste: WordBool readonly dispid 257;
    property CanRedo: WordBool readonly dispid 258;
    property CanUndo: WordBool readonly dispid 259;
    property Cycle: fmCycle dispid 260;
    property Caption: WideString dispid -518;
    property ControlTipText: WideString dispid -2147418043;
    property Enabled: WordBool dispid -514;
    property Index: Integer dispid -2147356416;
    procedure _GetInsideHeight(out InsideHeight: Integer); dispid 1610743824;
    property InsideHeight: Single readonly dispid 262;
    procedure _GetInsideWidth(out InsideWidth: Integer); dispid 1610743826;
    property InsideWidth: Single readonly dispid 263;
    property KeepScrollBarsVisible: fmScrollBars dispid 264;
    property Name: WideString dispid -2147418112;
    property PictureAlignment: fmPictureAlignment dispid 26;
    property Picture: IPictureDisp dispid -523;
    property PictureSizeMode: fmPictureSizeMode dispid 27;
    property PictureTiling: WordBool dispid 28;
    property ScrollBars: fmScrollBars dispid 265;
    procedure _SetScrollHeight(ScrollHeight: Integer); dispid 1610743843;
    procedure _GetScrollHeight(out ScrollHeight: Integer); dispid 1610743844;
    property ScrollHeight: Single dispid 266;
    procedure _SetScrollLeft(ScrollLeft: Integer); dispid 1610743847;
    procedure _GetScrollLeft(out ScrollLeft: Integer); dispid 1610743848;
    property ScrollLeft: Single dispid 267;
    procedure _SetScrollTop(ScrollTop: Integer); dispid 1610743851;
    procedure _GetScrollTop(out ScrollTop: Integer); dispid 1610743852;
    property ScrollTop: Single dispid 268;
    procedure _SetScrollWidth(ScrollWidth: Integer); dispid 1610743855;
    procedure _GetScrollWidth(out ScrollWidth: Integer); dispid 1610743856;
    property ScrollWidth: Single dispid 269;
    property Tag: WideString dispid -2147418101;
    property TransitionEffect: fmTransitionEffect dispid -2147356415;
    property TransitionPeriod: Integer dispid -2147356414;
    property VerticalScrollBarSide: fmVerticalScrollBarSide dispid 271;
    property Visible: WordBool dispid -2147418105;
    property Zoom: Smallint dispid 272;
    property DesignMode: fmMode dispid 384;
    property ShowToolbox: fmMode dispid 385;
    property ShowGridDots: fmMode dispid 386;
    property SnapToGrid: fmMode dispid 387;
    property GridX: Single dispid 388;
    procedure _SetGridX(GridX: Integer); dispid 1610743881;
    procedure _GetGridX(out GridX: Integer); dispid 1610743882;
    property GridY: Single dispid 389;
    procedure _SetGridY(GridY: Integer); dispid 1610743885;
    procedure _GetGridY(out GridY: Integer); dispid 1610743886;
    procedure Copy; dispid 512;
    procedure Cut; dispid 513;
    procedure Paste; dispid 514;
    procedure RedoAction; dispid 515;
    procedure Repaint; dispid 516;
    procedure Scroll(xAction: OleVariant; yAction: OleVariant); dispid 517;
    procedure SetDefaultTabOrder; dispid 518;
    procedure UndoAction; dispid 519;
    property Accelerator: WideString dispid -543;
    property Parent: IDispatch readonly dispid -2147418104;
  end;

// *********************************************************************//
// Interface: Pages
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {92E11A03-7358-11CE-80CB-00AA00611080}
// *********************************************************************//
  Pages = interface(IDispatch)
    ['{92E11A03-7358-11CE-80CB-00AA00611080}']
    function  Get_Count: Integer; safecall;
    function  Get__NewEnum: IUnknown; safecall;
    function  Item(varg: OleVariant): IDispatch; safecall;
    function  Enum: IUnknown; safecall;
    function  Add(bstrName: OleVariant; bstrCaption: OleVariant; lIndex: OleVariant): Page; safecall;
    function  _AddCtrl(var clsid: Integer; const bstrName: WideString; const bstrCaption: WideString): Page; safecall;
    function  _InsertCtrl(var clsid: Integer; const bstrName: WideString; 
                          const bstrCaption: WideString; lIndex: Integer): Page; safecall;
    function  _GetItemByIndex(lIndex: Integer): Control; safecall;
    function  _GetItemByName(const pstrName: WideString): Control; safecall;
    procedure Remove(varg: OleVariant); safecall;
    procedure Clear; safecall;
    property Count: Integer read Get_Count;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// DispIntf:  PagesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {92E11A03-7358-11CE-80CB-00AA00611080}
// *********************************************************************//
  PagesDisp = dispinterface
    ['{92E11A03-7358-11CE-80CB-00AA00611080}']
    property Count: Integer readonly dispid 60;
    property _NewEnum: IUnknown readonly dispid -4;
    function  Item(varg: OleVariant): IDispatch; dispid 0;
    function  Enum: IUnknown; dispid 1610743811;
    function  Add(bstrName: OleVariant; bstrCaption: OleVariant; lIndex: OleVariant): Page; dispid 66;
    function  _AddCtrl(var clsid: Integer; const bstrName: WideString; const bstrCaption: WideString): Page; dispid 1610743813;
    function  _InsertCtrl(var clsid: Integer; const bstrName: WideString; 
                          const bstrCaption: WideString; lIndex: Integer): Page; dispid 1610743814;
    function  _GetItemByIndex(lIndex: Integer): Control; dispid 1610743815;
    function  _GetItemByName(const pstrName: WideString): Control; dispid 1610743816;
    procedure Remove(varg: OleVariant); dispid 67;
    procedure Clear; dispid 62;
  end;

// *********************************************************************//
// Interface: IMultiPage
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC9-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  IMultiPage = interface(IDispatch)
    ['{04598FC9-866C-11CF-AB7C-00AA00C08FCF}']
    procedure Set_BackColor(color: OLE_COLOR); safecall;
    function  Get_BackColor: OLE_COLOR; safecall;
    procedure Set_ForeColor(color: OLE_COLOR); safecall;
    function  Get_ForeColor: OLE_COLOR; safecall;
    procedure Set__Font_Reserved(const Param1: IFontDisp); safecall;
    procedure Set_Font(const Font: IFontDisp); safecall;
    function  Get_Font: IFontDisp; safecall;
    procedure Set_FontName(const FontName: WideString); safecall;
    function  Get_FontName: WideString; safecall;
    procedure Set_FontBold(fBold: WordBool); safecall;
    function  Get_FontBold: WordBool; safecall;
    procedure Set_FontItalic(fItalic: WordBool); safecall;
    function  Get_FontItalic: WordBool; safecall;
    procedure Set_FontUnderline(fUnder: WordBool); safecall;
    function  Get_FontUnderline: WordBool; safecall;
    procedure Set_FontStrikethru(fStrike: WordBool); safecall;
    function  Get_FontStrikethru: WordBool; safecall;
    procedure Set_FontSize(Size: Currency); safecall;
    function  Get_FontSize: Currency; safecall;
    procedure Set_MultiRow(fMultiRow: WordBool); safecall;
    function  Get_MultiRow: WordBool; safecall;
    procedure Set_Style(Style: fmTabStyle); safecall;
    function  Get_Style: fmTabStyle; safecall;
    procedure Set_TabOrientation(Layout: fmTabOrientation); safecall;
    function  Get_TabOrientation: fmTabOrientation; safecall;
    procedure _SetTabFixedWidth(Width: Integer); safecall;
    procedure _GetTabFixedWidth(out Width: Integer); safecall;
    procedure _SetTabFixedHeight(Height: Integer); safecall;
    procedure _GetTabFixedHeight(out Height: Integer); safecall;
    procedure Set_Enabled(Enabled: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    function  Get_SelectedItem: Page; safecall;
    function  Get_Pages: Pages; safecall;
    procedure Set_Value(Index: Integer); safecall;
    function  Get_Value: Integer; safecall;
    procedure Set_TabFixedWidth(Width: Single); safecall;
    function  Get_TabFixedWidth: Single; safecall;
    procedure Set_TabFixedHeight(Height: Single); safecall;
    function  Get_TabFixedHeight: Single; safecall;
    procedure Set_FontWeight(FontWeight: Smallint); safecall;
    function  Get_FontWeight: Smallint; safecall;
    property BackColor: OLE_COLOR read Get_BackColor write Set_BackColor;
    property ForeColor: OLE_COLOR read Get_ForeColor write Set_ForeColor;
    property _Font_Reserved: IFontDisp write Set__Font_Reserved;
    property Font: IFontDisp read Get_Font write Set_Font;
    property FontName: WideString read Get_FontName write Set_FontName;
    property FontBold: WordBool read Get_FontBold write Set_FontBold;
    property FontItalic: WordBool read Get_FontItalic write Set_FontItalic;
    property FontUnderline: WordBool read Get_FontUnderline write Set_FontUnderline;
    property FontStrikethru: WordBool read Get_FontStrikethru write Set_FontStrikethru;
    property FontSize: Currency read Get_FontSize write Set_FontSize;
    property MultiRow: WordBool read Get_MultiRow write Set_MultiRow;
    property Style: fmTabStyle read Get_Style write Set_Style;
    property TabOrientation: fmTabOrientation read Get_TabOrientation write Set_TabOrientation;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property SelectedItem: Page read Get_SelectedItem;
    property Pages: Pages read Get_Pages;
    property Value: Integer read Get_Value write Set_Value;
    property TabFixedWidth: Single read Get_TabFixedWidth write Set_TabFixedWidth;
    property TabFixedHeight: Single read Get_TabFixedHeight write Set_TabFixedHeight;
    property FontWeight: Smallint read Get_FontWeight write Set_FontWeight;
  end;

// *********************************************************************//
// DispIntf:  IMultiPageDisp
// Flags:     (4432) Hidden Dual OleAutomation Dispatchable
// GUID:      {04598FC9-866C-11CF-AB7C-00AA00C08FCF}
// *********************************************************************//
  IMultiPageDisp = dispinterface
    ['{04598FC9-866C-11CF-AB7C-00AA00C08FCF}']
    property BackColor: OLE_COLOR dispid -501;
    property ForeColor: OLE_COLOR dispid -513;
    property _Font_Reserved: IFontDisp writeonly dispid 2147483135;
    property Font: IFontDisp dispid -512;
    property FontName: WideString dispid 1;
    property FontBold: WordBool dispid 3;
    property FontItalic: WordBool dispid 4;
    property FontUnderline: WordBool dispid 5;
    property FontStrikethru: WordBool dispid 6;
    property FontSize: Currency dispid 2;
    property MultiRow: WordBool dispid 514;
    property Style: fmTabStyle dispid 513;
    property TabOrientation: fmTabOrientation dispid 512;
    procedure _SetTabFixedWidth(Width: Integer); dispid 1610743833;
    procedure _GetTabFixedWidth(out Width: Integer); dispid 1610743834;
    procedure _SetTabFixedHeight(Height: Integer); dispid 1610743835;
    procedure _GetTabFixedHeight(out Height: Integer); dispid 1610743836;
    property Enabled: WordBool dispid -514;
    property SelectedItem: Page readonly dispid 545;
    property Pages: Pages readonly dispid 0;
    property Value: Integer dispid 528;
    property TabFixedWidth: Single dispid 515;
    property TabFixedHeight: Single dispid 516;
    property FontWeight: Smallint dispid 7;
  end;

// *********************************************************************//
// DispIntf:  MultiPageEvents
// Flags:     (4112) Hidden Dispatchable
// GUID:      {7B020EC8-AF6C-11CE-9F46-00AA00574A4F}
// *********************************************************************//
  MultiPageEvents = dispinterface
    ['{7B020EC8-AF6C-11CE-9F46-00AA00574A4F}']
    procedure AddControl(Index: Integer; const Control: Control); dispid 768;
    procedure BeforeDragOver(Index: Integer; const Cancel: ReturnBoolean; const Control: Control; 
                             const Data: DataObject; X: Single; Y: Single; State: fmDragState; 
                             const Effect: ReturnEffect; Shift: Smallint); dispid 3;
    procedure BeforeDropOrPaste(Index: Integer; const Cancel: ReturnBoolean; 
                                const Control: Control; Action: fmAction; const Data: DataObject; 
                                X: Single; Y: Single; const Effect: ReturnEffect; Shift: Smallint); dispid 4;
    procedure Change; dispid 2;
    procedure Click(Index: Integer); dispid -600;
    procedure DblClick(Index: Integer; const Cancel: ReturnBoolean); dispid -601;
    procedure Error(Index: Integer; Number: Smallint; const Description: ReturnString; 
                    SCode: Integer; const Source: WideString; const HelpFile: WideString;
                    HelpContext: Integer; const CancelDisplay: ReturnBoolean); dispid -608;
    procedure KeyDown(const KeyCode: ReturnInteger; Shift: Smallint); dispid -602;
    procedure KeyPress(const KeyAscii: ReturnInteger); dispid -603;
    procedure KeyUp(const KeyCode: ReturnInteger; Shift: Smallint); dispid -604;
    procedure Layout(Index: Integer); dispid 770;
    procedure MouseDown(Index: Integer; Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -605;
    procedure MouseMove(Index: Integer; Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -606;
    procedure MouseUp(Index: Integer; Button: Smallint; Shift: Smallint; X: Single; Y: Single); dispid -607;
    procedure RemoveControl(Index: Integer; const Control: Control); dispid 771;
    procedure Scroll(Index: Integer; ActionX: fmScrollAction; ActionY: fmScrollAction; 
                     RequestDx: Single; RequestDy: Single; const ActualDx: ReturnSingle; 
                     const ActualDy: ReturnSingle); dispid 772;
    procedure Zoom(Index: Integer; var Percent: Smallint); dispid 773;
  end;

// *********************************************************************//
// The Class CoReturnInteger provides a Create and CreateRemote method to          
// create instances of the default interface IReturnInteger exposed by              
// the CoClass ReturnInteger. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.                                            
// *********************************************************************//
  CoReturnInteger = class
    class function Create: IReturnInteger;
    class function CreateRemote(const MachineName: string): IReturnInteger;
  end;

// *********************************************************************//
// The Class CoReturnBoolean provides a Create and CreateRemote method to          
// create instances of the default interface IReturnBoolean exposed by              
// the CoClass ReturnBoolean. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoReturnBoolean = class
    class function Create: IReturnBoolean;
    class function CreateRemote(const MachineName: string): IReturnBoolean;
  end;

// *********************************************************************//
// The Class CoReturnString provides a Create and CreateRemote method to          
// create instances of the default interface IReturnString exposed by              
// the CoClass ReturnString. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoReturnString = class
    class function Create: IReturnString;
    class function CreateRemote(const MachineName: string): IReturnString;
  end;

// *********************************************************************//
// The Class CoReturnSingle provides a Create and CreateRemote method to          
// create instances of the default interface IReturnSingle exposed by              
// the CoClass ReturnSingle. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoReturnSingle = class
    class function Create: IReturnSingle;
    class function CreateRemote(const MachineName: string): IReturnSingle;
  end;

// *********************************************************************//
// The Class CoReturnEffect provides a Create and CreateRemote method to          
// create instances of the default interface IReturnEffect exposed by              
// the CoClass ReturnEffect. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoReturnEffect = class
    class function Create: IReturnEffect;
    class function CreateRemote(const MachineName: string): IReturnEffect;
  end;

// *********************************************************************//
// The Class CoDataObject provides a Create and CreateRemote method to          
// create instances of the default interface IDataAutoWrapper exposed by              
// the CoClass DataObject. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the
// server of this typelibrary.                                            
// *********************************************************************//
  CoDataObject = class
    class function Create: IDataAutoWrapper;
    class function CreateRemote(const MachineName: string): IDataAutoWrapper;
  end;

// *********************************************************************//
// The Class CoControl provides a Create and CreateRemote method to          
// create instances of the default interface IControl exposed by              
// the CoClass Control. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.
// *********************************************************************//
  CoControl = class
    class function Create: IControl;
    class function CreateRemote(const MachineName: string): IControl;
  end;

  CoUserForm = class
    class function Create: _UserForm;
  end;

// *********************************************************************//
// The Class CoNewFont provides a Create and CreateRemote method to
// create instances of the default interface Font exposed by              
// the CoClass NewFont. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoNewFont = class
    class function Create: Font;
    class function CreateRemote(const MachineName: string): Font;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TImage
// Help String      : 
// Default Interface: IImage
// Def. Intf. DISP? : No
// Event   Interface: ImageEvents
// TypeFlags        : (34) CanCreate Control
// *********************************************************************//
  TImageBeforeDragOver = procedure(Sender: TObject; const Cancel: ReturnBoolean; 
                                                    const Data: DataObject; X: Single; Y: Single; 
                                                    DragState: fmDragState; 
                                                    const Effect: ReturnEffect; Shift: Smallint) of object;
  TImageBeforeDropOrPaste = procedure(Sender: TObject; const Cancel: ReturnBoolean; 
                                                       Action: fmAction; const Data: DataObject; 
                                                       X: Single; Y: Single; 
                                                       const Effect: ReturnEffect; Shift: Smallint) of object;
  TImageError = procedure(Sender: TObject; Number: Smallint; const Description: ReturnString; 
                                           SCode: Integer; const Source: WideString; 
                                           const HelpFile: WideString; HelpContext: Integer; 
                                           const CancelDisplay: ReturnBoolean) of object;

  TImage = class(TDBOleControl)
  private
    FOnBeforeDragOver: TImageBeforeDragOver;
    FOnBeforeDropOrPaste: TImageBeforeDropOrPaste;
    FOnError: TImageError;
    FIntf: IImage;
    function  GetControlInterface: IImage;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    property  ControlInterface: IImage read GetControlInterface;
    property  DefaultInterface: IImage read GetControlInterface;
  published
    property Enabled: WordBool index -514 read GetWordBoolProp write SetWordBoolProp stored False;
    property MousePointer: TOleEnum index -521 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property AutoSize: WordBool index -500 read GetWordBoolProp write SetWordBoolProp stored False;
    property BackColor: TColor index -501 read GetTColorProp write SetTColorProp stored False;
    property BackStyle: TOleEnum index -502 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property BorderColor: TColor index -503 read GetTColorProp write SetTColorProp stored False;
    property BorderStyle: TOleEnum index -504 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Picture: TPicture index -523 read GetTPictureProp write SetTPictureProp stored False;
    property MouseIcon: TPicture index -522 read GetTPictureProp write SetTPictureProp stored False;
    property PictureSizeMode: TOleEnum index 27 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property PictureAlignment: TOleEnum index 26 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property PictureTiling: WordBool index 28 read GetWordBoolProp write SetWordBoolProp stored False;
    property SpecialEffect: TOleEnum index 12 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property OnBeforeDragOver: TImageBeforeDragOver read FOnBeforeDragOver write FOnBeforeDragOver;
    property OnBeforeDropOrPaste: TImageBeforeDropOrPaste read FOnBeforeDropOrPaste write FOnBeforeDropOrPaste;
    property OnError: TImageError read FOnError write FOnError;
  end;

// *********************************************************************//
// The Class CoPage provides a Create and CreateRemote method to          
// create instances of the default interface IPage exposed by              
// the CoClass Page. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPage = class
    class function Create: IPage;
    class function CreateRemote(const MachineName: string): IPage;
  end;

procedure Register;

implementation

uses ComObj;

class function CoReturnInteger.Create: IReturnInteger;
begin
  Result := CreateComObject(CLASS_ReturnInteger) as IReturnInteger;
end;

class function CoReturnInteger.CreateRemote(const MachineName: string): IReturnInteger;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ReturnInteger) as IReturnInteger;
end;

class function CoReturnBoolean.Create: IReturnBoolean;
begin
  Result := CreateComObject(CLASS_ReturnBoolean) as IReturnBoolean;
end;

class function CoReturnBoolean.CreateRemote(const MachineName: string): IReturnBoolean;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ReturnBoolean) as IReturnBoolean;
end;

class function CoReturnString.Create: IReturnString;
begin
  Result := CreateComObject(CLASS_ReturnString) as IReturnString;
end;

class function CoReturnString.CreateRemote(const MachineName: string): IReturnString;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ReturnString) as IReturnString;
end;

class function CoReturnSingle.Create: IReturnSingle;
begin
  Result := CreateComObject(CLASS_ReturnSingle) as IReturnSingle;
end;

class function CoReturnSingle.CreateRemote(const MachineName: string): IReturnSingle;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ReturnSingle) as IReturnSingle;
end;

class function CoReturnEffect.Create: IReturnEffect;
begin
  Result := CreateComObject(CLASS_ReturnEffect) as IReturnEffect;
end;

class function CoReturnEffect.CreateRemote(const MachineName: string): IReturnEffect;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ReturnEffect) as IReturnEffect;
end;

class function CoDataObject.Create: IDataAutoWrapper;
begin
  Result := CreateComObject(CLASS_DataObject) as IDataAutoWrapper;
end;

class function CoDataObject.CreateRemote(const MachineName: string): IDataAutoWrapper;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DataObject) as IDataAutoWrapper;
end;

class function CoUserForm.Create: _UserForm;
begin
  Result := CreateComObject(CLASS_UserForm) as _UserForm;
end;

class function CoControl.Create: IControl;
begin
  Result := CreateComObject(CLASS_Control) as IControl;
end;

class function CoControl.CreateRemote(const MachineName: string): IControl;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Control) as IControl;
end;

class function CoNewFont.Create: Font;
begin
  Result := CreateComObject(CLASS_NewFont) as Font;
end;

class function CoNewFont.CreateRemote(const MachineName: string): Font;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_NewFont) as Font;
end;

procedure TImage.InitControlData;
const
  CEventDispIDs: array [0..2] of DWORD = (
    $00000003, $00000004, $FFFFFDA0);
  CTPictureIDs: array [0..1] of DWORD = (
    $FFFFFDF5, $FFFFFDF6);
  CControlData: TControlData2 = (
    ClassID: '{4C599241-6926-101B-9992-00000B65C6F9}';
    EventIID: '{4C5992A5-6926-101B-9992-00000B65C6F9}';
    EventCount: 3;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil (*HR:$80040154*);
    Flags: $00000009;
    Version: 401;
    FontCount: 0;
    FontIDs: nil;
    PictureCount: 2;
    PictureIDs: @CTPictureIDs);
begin
  ControlData := @CControlData;
  TControlData2(CControlData).FirstEventOfs := Cardinal(@@FOnBeforeDragOver) - Cardinal(Self);
end;

procedure TImage.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IImage;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TImage.GetControlInterface: IImage;
begin
  CreateControl;
  Result := FIntf;
end;

class function CoPage.Create: IPage;
begin
  Result := CreateComObject(CLASS_Page) as IPage;
end;

class function CoPage.CreateRemote(const MachineName: string): IPage;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Page) as IPage;
end;

procedure Register;
begin
  RegisterComponents('ActiveX',[TImage]);
end;

end.
