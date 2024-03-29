// ShlTanya, 27.02.2019

unit rp_VBConsts;

interface

const
  DelphiConsts =
    'Public Const dmManual = 0'#13#10 +
    'Public Const dmAutomatic = 1'#13#10 +
    'Public Const dkDrag = 0'#13#10 +
    'Public Const dkDock = 1'#13#10 +
    'Public Const bvNone = 0'#13#10 +
    'Public Const bvLowered = 1'#13#10 +
    'Public Const bvRaised = 2'#13#10 +
    'Public Const bvSpase = 3'#13#10 +
    'Public Const bkNone = 0'#13#10 +
    'Public Const bkTile = 1'#13#10 +
    'Public Const bkSoft = 2'#13#10 +
    'Public Const bkFlat = 3'#13#10 +
    'Public Const imDisable = 0'#13#10 +
    'Public Const imClose = 1'#13#10 +
    'Public Const imOpen = 2'#13#10 +
    'Public Const imDontCare = 3'#13#10 +
    'Public Const imSAlpha = 4'#13#10 +
    'Public Const imAlpha = 5'#13#10 +
    'Public Const imHira = 6'#13#10 +
    'Public Const imSKata = 7'#13#10 +
    'Public Const imKata = 8'#13#10 +
    'Public Const imChinese = 9'#13#10 +
    'Public Const imSHanguel = 10'#13#10 +
    'Public Const imHanguel = 11'#13#10 +
    'Public Const mbLeft = 0'#13#10 +
    'Public Const mbRight = 1'#13#10 +
    'Public Const mbMiddle = 2'#13#10 +
    'Public Const bsNone = 0'#13#10 +
    'Public Const bsSingle = 1'#13#10 +
    'Public Const ecNormal = 0'#13#10 +
    'Public Const ecUpperCase = 1'#13#10 +
    'Public Const ecLowerCase = 2'#13#10 +
    'Public Const fbsNone = 0'#13#10 +
    'Public Const fbsSingle = 1'#13#10 +
    'Public Const fbsSizeable = 2'#13#10 +
    'Public Const fbsDialog = 3'#13#10 +
    'Public Const fbsToolWindow = 4'#13#10 +
    'Public Const fbsSizeToolWin = 5'#13#10 +
    'Public Const dmDesktop = 0'#13#10 +
    'Public Const dmPrimary = 1'#13#10 +
    'Public Const dmMainForm = 2'#13#10 +
    'Public Const dmActiveForm = 3'#13#10 +
    'Public Const fsNormal = 0'#13#10 +
    'Public Const fsMDIChild = 1'#13#10 +
    'Public Const fsMDIForm = 2'#13#10 +
    'Public Const fsStayInTop = 3'#13#10 +
    'Public Const poDesigned = 0'#13#10 +
    'Public Const poDefault = 1'#13#10 +
    'Public Const poDefaultPosOnly = 2'#13#10 +
    'Public Const poDefaultSizeOnly = 3'#13#10 +
    'Public Const poScreenCenter = 4'#13#10 +
    'Public Const poDesktopCenter = 5'#13#10 +
    'Public Const poMainFormCenter = 6'#13#10 +
    'Public Const poOwnerFormCenter = 7'#13#10 +
    'Public Const poNone = 0'#13#10 +
    'Public Const poProportional = 1'#13#10 +
    'Public Const poProntToFit = 2'#13#10 +
    'Public Const tbHorizontal = 0'#13#10 +
    'Public Const tbVertical = 1'#13#10 +
    'Public Const cbUnchecked = 0'#13#10 +
    'Public Const cbChecked = 1'#13#10 +
    'Public Const csDropDown = 0'#13#10 +
    'Public Const csSimple = 1'#13#10 +
    'Public Const csDropDownList = 2'#13#10 +
    'Public Const csOwnerDrawFixed = 3'#13#10 +
    'Public Const csOwnerDrawVariable = 4'#13#10 +
    'Public Const dpTop = 0'#13#10 +
    'Public Const dpBottom = 1'#13#10 +
    'Public Const dpLeft = 2'#13#10 +
    'Public Const dpRight = 3'#13#10 +
    'Public Const dmCanFloat = 0'#13#10 +
    'Public Const dmCannotFloat = 1'#13#10 +
    'Public Const dmCannotFloatOrChangeDocks = 2'#13#10 +
    'Public Const dhDouble = 0'#13#10 +
    'Public Const dhNone = 1'#13#10 +
    'Public Const dhSingle = 2'#13#10 +
    'Public Const tbsmNone = 0'#13#10 +
    'Public Const tbsmWrap = 1'#13#10 +
    'Public Const tbsmChevron = 2'#13#10 +
    'Public Const twshLeft = 0'#13#10 +
    'Public Const twshRight = 1'#13#10 +
    'Public Const twshTop = 2'#13#10 +
    'Public Const twshTopLeft = 3'#13#10 +
    'Public Const twshTopRight = 4'#13#10 +
    'Public Const twshBottom = 5'#13#10 +
    'Public Const twshBottomLeft = 6'#13#10 +
    'Public Const twshBottomRight = 7'#13#10 +
    'Public Const fmOnTopOfParentForm = 0'#13#10 +
    'Public Const fmOnTopOfAllForms = 1'#13#10 +
    'Public Const ctHard = 0'#13#10 +
    'Public Const ctHardReopen = 1'#13#10 +
    'Public Const ctRetaining = 2'#13#10 +
    'Public Const ctRetainingReopen = 3'#13#10 +
    'Public Const paLeft = 0'#13#10 +
    'Public Const paRight = 1'#13#10 +
    'Public Const paCenter = 2'#13#10 +
    'Public Const taLeftJustify = 0'#13#10 +
    'Public Const taRightJustify = 1'#13#10 +
    'Public Const taCenterJustify = 2'#13#10 +
    'Public Const ssNone = 0'#13#10 +
    'Public Const ssHorizontal = 1'#13#10 +
    'Public Const ssVertical = 2'#13#10 +
    'Public Const ssBoth = 3'#13#10 +
    'Public Const alNone = 0'#13#10 +
    'Public Const alTop = 1'#13#10 +
    'Public Const alBottom = 2'#13#10 +
    'Public Const alLeft = 3'#13#10 +
    'Public Const alRight = 4'#13#10 +
    'Public Const alClient = 5'#13#10 +
    'Public Const bdLeftToRight = 0'#13#10 +
    'Public Const bdRightToLeft = 1'#13#10 +
    'Public Const bdRightToLeftNoAlign = 2'#13#10 +
    'Public Const bdRightToLeftReadingOnly = 3'#13#10 +
    'Public Const doNoOrient = 0'#13#10 +
    'Public Const doHorizontal = 1'#13#10 +
    'Public Const doVertical = 2'#13#10 +
    'Public Const maAutomatic = 0'#13#10 +
    'Public Const maManual = 1'#13#10 +
    'Public Const maParent = 2'#13#10 +
    'Public Const lbStandard = 0'#13#10 +
    'Public Const lbOwnerDrawFixed = 1'#13#10 +
    'Public Const lbOwnerDrawVariable = 2'#13#10 +
    'Public Const sbHorizontal = 0'#13#10 +
    'Public Const sbVertical = 1'#13#10 +
    'Public Const rtRefresh = 0'#13#10 +
    'Public Const rtCloseOpen = 1'#13#10 +
    'Public Const rtNone = 2'#13#10 +
    'Public Const soNone = 0'#13#10 +
    'Public Const soAsc = 1'#13#10 +
    'Public Const soDesc = 2'#13#10 +
    'Public Const kDate = 0'#13#10 +
    'Public Const kTime = 1'#13#10 +
    'Public Const kDateTime = 2'#13#10 +
    'Public Const sdcNone = 0'#13#10 +
    'Public Const sdcZLib = 1'#13#10 +
    'Public Const mbNone = 0'#13#10 +
    'Public Const mbBreak = 1'#13#10 +
    'Public Const mbBarBreak = 2'#13#10 +
    'Public Const sa_None = 0'#13#10 +
    'Public Const sa_Rollback = 1'#13#10 +
    'Public Const sa_Commit = 2'#13#10 +
    'Public Const sa_RollbackRetaining = 3'#13#10 +
    'Public Const sa_CommitRetaining = 4'#13#10 +
    'Public Const ta_Rollback = 0'#13#10 +
    'Public Const ta_Commit = 1'#13#10 +
    'Public Const ta_RollbackRetaining = 2'#13#10 +
    'Public Const ta_CommitRetaining = 3'#13#10 +
    'Public Const ca_None = 0'#13#10 +
    'Public Const ca_Hide = 1'#13#10 +
    'Public Const ca_Free = 2'#13#10 +
    'Public Const ca_Minimize = 3'#13#10 +
    'Public Const sc_LineUp = 0'#13#10 +
    'Public Const sc_LineDown = 1'#13#10 +
    'Public Const sc_PageUp = 2'#13#10 +
    'Public Const sc_PageDown = 3'#13#10 +
    'Public Const sc_Position = 4'#13#10 +
    'Public Const sc_Track = 5'#13#10 +
    'Public Const sc_Top = 6'#13#10 +
    'Public Const sc_Bottom = 7'#13#10 +
    'Public Const sc_EndScroll = 8'#13#10 +
    'Public Const da_Fail = 0'#13#10 +
    'Public Const da_Abort = 1'#13#10 +
    'Public Const da_Retry = 2'#13#10 +
    'Public Const ua_Fail = 0'#13#10 +
    'Public Const ua_Abort = 1'#13#10 +
    'Public Const ua_Skip = 2'#13#10 +
    'Public Const ua_Retry = 3'#13#10 +
    'Public Const ua_Apply = 4'#13#10 +
    'Public Const ua_Applied = 5'#13#10 +
    'Public Const uk_Modify = 0'#13#10 +
    'Public Const uk_Insert = 1'#13#10 +
    'Public Const uk_Delete = 2'#13#10 +
    'Public Const gs_dsInactive = 0'#13#10 +
    'Public Const gs_dsBrowse = 1'#13#10 +
    'Public Const gs_dsEdit = 2'#13#10 +
    'Public Const gs_dsInsert = 3'#13#10 +
    'Public Const gs_dsSetKey = 4'#13#10 +
    'Public Const gs_dsCalcFields = 5'#13#10 +
    'Public Const gs_dsFilter = 6'#13#10 +
    'Public Const gs_dsNewValue = 7'#13#10 +
    'Public Const gs_dsOldValue = 8'#13#10 +
    'Public Const gs_dsCurValue = 9'#13#10 +
    'Public Const gs_dsBlockRead = 10'#13#10 +
    'Public Const gs_dsInternalCalc = 11'#13#10 +
    'Public Const gs_dsOpening = 12'#13#10 +
    'Public Const arNone = 0'#13#10 +
    'Public Const arAutoInc = 1'#13#10 +
    'Public Const arDefault = 2'#13#10 +
    'Public Const ft_Unknown = 0'#13#10 +
    'Public Const ft_String = 1'#13#10 +
    'Public Const ft_Smallint = 2'#13#10 +
    'Public Const ft_Integer = 3'#13#10 +
    'Public Const ft_Word = 4'#13#10 +
    'Public Const ft_Boolean = 5'#13#10 +
    'Public Const ft_Float = 6'#13#10 +
    'Public Const ft_Currency = 7'#13#10 +
    'Public Const ft_BCD = 8'#13#10 +
    'Public Const ft_Date = 9'#13#10 +
    'Public Const ft_Time = 10'#13#10 +
    'Public Const ft_DateTime = 11'#13#10 +
    'Public Const ft_Bytes = 12'#13#10 +
    'Public Const ft_VarBytes = 13'#13#10 +
    'Public Const ft_AutoInc = 14'#13#10 +
    'Public Const ft_Blob = 15'#13#10 +
    'Public Const ft_Memo = 16'#13#10 +
    'Public Const ft_Graphic = 17'#13#10 +
    'Public Const ft_FmtMemo = 18'#13#10 +
    'Public Const ft_ParadoxOle = 19'#13#10 +
    'Public Const ft_DBaseOle = 20'#13#10 +
    'Public Const ft_TypedBinary = 21'#13#10 +
    'Public Const ft_Cursor = 22'#13#10 +
    'Public Const ft_FixedChar = 23'#13#10 +
    'Public Const ft_WideString = 24'#13#10 +
    'Public Const ft_Largeint = 25'#13#10 +
    'Public Const ft_ADT = 26'#13#10 +
    'Public Const ft_Array = 27'#13#10 +
    'Public Const ft_Reference = 28'#13#10 +
    'Public Const ft_DataSet = 29'#13#10 +
    'Public Const ft_OraBlob = 30'#13#10 +
    'Public Const ft_OraClob = 31'#13#10 +
    'Public Const ft_Variant = 32'#13#10 +
    'Public Const ft_Interface = 33'#13#10 +
    'Public Const ft_IDispatch = 34'#13#10 +
    'Public Const ft_Guid = 35'#13#10 +
    'Public Const fkData = 0'#13#10 +
    'Public Const fkCalculated = 1'#13#10 +
    'Public Const fkLookup = 2'#13#10 +
    'Public Const fkInternalCalc = 3'#13#10 +
    'Public Const fkAggregate = 4'#13#10 +
    'Public Const dup_Ignore = 0'#13#10 +
    'Public Const dup_Accept = 1'#13#10 +
    'Public Const dup_Error = 2'#13#10 +
    'Public Const irstSubSelect = 0'#13#10 +
    'Public Const irstSimpleSum = 1'#13#10 +
    'Public Const us_Unmodified = 0'#13#10 +
    'Public Const us_Modified = 1'#13#10 +
    'Public Const us_Inserted = 2'#13#10 +
    'Public Const us_Deleted = 3'#13#10 +
    'Public Const up_WhereAll = 0'#13#10 +
    'Public Const up_WhereChanged = 1'#13#10 +
    'Public Const up_WhereKeyOnly = 2'#13#10 +
    'Public Const cus_Unmodified = 0'#13#10 +
    'Public Const cus_Modified = 1'#13#10 +
    'Public Const cus_Inserted = 2'#13#10 +
    'Public Const cus_Deleted = 3'#13#10 +
    'Public Const cus_Uninserted = 4'#13#10 +
    'Public Const bs_Box = 0'#13#10 +
    'Public Const bs_Frame = 1'#13#10 +
    'Public Const bs_TopLine = 2'#13#10 +
    'Public Const bs_BottomLine = 3'#13#10 +
    'Public Const bs_LeftLine = 4'#13#10 +
    'Public Const bs_RightLine = 5'#13#10 +
    'Public Const bs_Spacer = 6'#13#10 +
    'Public Const bs_Lowered = 0'#13#10 +
    'Public Const bs_Raised = 1'#13#10 +
    'Public Const ts_Tabs = 0'#13#10 +
    'Public Const ts_Buttons = 1'#13#10 +
    'Public Const ts_FlatButtons = 2'#13#10 +
    'Public Const tp_Top = 0'#13#10 +
    'Public Const tp_Bottom = 1'#13#10 +
    'Public Const tp_Left = 2'#13#10 +
    'Public Const tp_Right = 3'#13#10 +
    'Public Const bk_Custom = 0'#13#10 +
    'Public Const bk_OK = 1'#13#10 +
    'Public Const bk_Cancel = 2'#13#10 +
    'Public Const bk_Help = 3'#13#10 +
    'Public Const bk_Yes = 4'#13#10 +
    'Public Const bk_No = 5'#13#10 +
    'Public Const bk_Close = 6'#13#10 +
    'Public Const bk_Abort = 7'#13#10 +
    'Public Const bk_Retry = 8'#13#10 +
    'Public Const bl_GlyphLeft = 0'#13#10 +
    'Public Const bl_GlyphRight = 1'#13#10 +
    'Public Const bl_GlyphTop = 2'#13#10 +
    'Public Const bl_GlyphBottom = 3'#13#10 +
    'Public Const bs_AutoDetect = 0'#13#10 +
    'Public Const bs_Win31 = 1'#13#10 +
    'Public Const bs_New = 2'#13#10 +
    'Public Const rs_None = 0'#13#10 +
    'Public Const rs_Line = 1'#13#10 +
    'Public Const rs_Update = 2'#13#10 +
    'Public Const rs_Pattern = 3'#13#10 +
    'Public Const sbs_None = 0'#13#10 +
    'Public Const sbs_Single = 1'#13#10 +
    'Public Const sbs_Sunken = 2'#13#10 +
    'Public Const st_None = 0'#13#10 +
    'Public Const st_Data = 1'#13#10 +
    'Public Const st_Text = 2'#13#10 +
    'Public Const st_Both = 3'#13#10 +
    'Public Const vs_Icon = 0'#13#10 +
    'Public Const vs_SmallIcon = 1'#13#10 +
    'Public Const vs_List = 2'#13#10 +
    'Public Const vs_Report = 3'#13#10 +
    'Public Const ar_AlignBottom = 0'#13#10 +
    'Public Const ar_AlignLeft = 1'#13#10 +
    'Public Const ar_AlignRight = 2'#13#10 +
    'Public Const ar_AlignTop = 3'#13#10 +
    'Public Const ar_Default = 4'#13#10 +
    'Public Const ar_SnapToGrid = 5'#13#10 +
    'Public Const df_Binary = 0'#13#10 +
    'Public Const df_XML = 1'#13#10 +
    'Public Const nb_First = 0'#13#10 +
    'Public Const nb_Prior = 1'#13#10 +
    'Public Const nb_Next = 2'#13#10 +
    'Public Const nb_Last = 3'#13#10 +
    'Public Const nb_Insert = 4'#13#10 +
    'Public Const nb_Delete = 5'#13#10 +
    'Public Const nb_Edit = 6'#13#10 +
    'Public Const nb_Post = 7'#13#10 +
    'Public Const nb_Cancel = 8'#13#10 +
    'Public Const nb_Refresh = 9'#13#10 +
    'Public Const dcp_Header = 0'#13#10 +
    'Public Const dcp_Line = 1'#13#10 +
    'Public Const tt_Unknow = 0'#13#10 +
    'Public Const tt_SimpleTable = 1'#13#10 +
    'Public Const tt_Tree = 2'#13#10 +
    'Public Const tt_IntervalTree = 3'#13#10 +
    'Public Const tt_CustomTable = 4'#13#10 +
    'Public Const tt_Document = 5'#13#10 +
    'Public Const tt_DocumentLine = 6'#13#10 +
    'Public Const tt_InvSimple = 7'#13#10 +
    'Public Const tt_InvFeature = 8'#13#10 +
    'Public Const tt_InvInvent = 9'#13#10 +
    'Public Const tt_InvTransfrom = 10'#13#10 +
    'Public Const ipsm_Document = 0'#13#10 +
    'Public Const ipsm_Position = 1'#13#10 +
    'Public Const iec_NoErr = 0'#13#10 +
    'Public Const iec_GoodNotFound = 1'#13#10 +
    'Public Const iec_RemainsNotFound = 2'#13#10 +
    'Public Const iec_FoundOtherMovement = 3'#13#10 +
    'Public Const iec_FoundEarlyMovement = 4'#13#10 +
    'Public Const iec_DontDecreaseQuantity = 5'#13#10 +
    'Public Const iec_DontChangeDest = 6'#13#10 +
    'Public Const iec_DontChangeFeatures = 7'#13#10 +
    'Public Const iec_DontDeleteFoundMovement = 8'#13#10 +
    'Public Const iec_DontDeleteDecreaseQuantity = 9'#13#10 +
    'Public Const iec_RemainsLocked = 10'#13#10 +
    'Public Const iec_OtherIBError = 11'#13#10 +
    'Public Const iec_UnknowError = 12'#13#10 +
    'Public Const hs_Buttons = 0'#13#10 +
    'Public Const hs_Flat = 1'#13#10 +
    'Public Const ds_Focus = 0'#13#10 +
    'Public Const ds_Selected = 1'#13#10 +
    'Public Const ds_Normal = 2'#13#10 +
    'Public Const ds_Transparent = 3'#13#10 +
    'Public Const it_Image = 0'#13#10 +
    'Public Const it_Mask = 1'#13#10 +
    'Public Const rt_Bitmap = 0'#13#10 +
    'Public Const rt_Cursor = 1'#13#10 +
    'Public Const rt_Icon = 2'#13#10 +
    'Public Const os_Text = 0'#13#10 +
    'Public Const os_PlusMinusText = 1'#13#10 +
    'Public Const os_PictureText = 2'#13#10 +
    'Public Const os_PlusMinusPictureText = 3'#13#10 +
    'Public Const os_TreeText = 4'#13#10 +
    'Public Const os_TreePictureText = 5'#13#10 +
    'Public Const ot_Standard = 0'#13#10 +
    'Public Const ot_OwnerDraw = 1'#13#10 +
    'Public Const avi_None = 0'#13#10 +
    'Public Const avi_FindFolder = 1'#13#10 +
    'Public Const avi_FindFile = 2'#13#10 +
    'Public Const avi_FindComputer = 3'#13#10 +
    'Public Const avi_CopyFiles = 4'#13#10 +
    'Public Const avi_CopyFile = 5'#13#10 +
    'Public Const avi_RecycleFile = 6'#13#10 +
    'Public Const avi_EmptyRecycle = 7'#13#10 +
    'Public Const avi_DeleteFile = 8'#13#10 +
    'Public Const go_16x1 = 0'#13#10 +
    'Public Const go_8x2 = 1'#13#10 +
    'Public Const go_4x4 = 2'#13#10 +
    'Public Const go_2x8 = 3'#13#10 +
    'Public Const go_1x16 = 4'#13#10 +
    'Public Const co_LeftToRight = 0'#13#10 +
    'Public Const co_RightToLeft = 1'#13#10 +
    'Public Const fs_Surface = 0'#13#10 +
    'Public Const fs_Border = 1'#13#10 +
    'Public Const es_None = 0'#13#10 +
    'Public Const es_Raised = 1'#13#10 +
    'Public Const es_Lowered = 2'#13#10 +
    'Public Const bm_None = 0'#13#10 +
    'Public Const bm_Click = 1'#13#10 +
    'Public Const bm_DblClick = 2'#13#10 +
    'Public Const dta_Left = 0'#13#10 +
    'Public Const dta_Right = 1'#13#10 +
    'Public Const df_Short = 0'#13#10 +
    'Public Const df_Long = 1'#13#10 +
    'Public Const dm_ComboBox = 0'#13#10 +
    'Public Const dm_UpDown = 1'#13#10 +
    'Public Const dtk_Date = 0'#13#10 +
    'Public Const dtk_Time = 1'#13#10 +
    'Public Const tc_LowerCase = 0'#13#10 +
    'Public Const tc_UpperCase = 1'#13#10 +
    'Public Const gk_Text = 0'#13#10 +
    'Public Const gk_HorizontalBar = 1'#13#10 +
    'Public Const gk_VerticalBar = 2'#13#10 +
    'Public Const gk_Pie = 3'#13#10 +
    'Public Const gk_Needle = 4'#13#10 +
    'Public Const dow_Monday = 0'#13#10 +
    'Public Const dow_Tuesday = 1'#13#10 +
    'Public Const dow_Wednesday = 2'#13#10 +
    'Public Const dow_Thursday = 3'#13#10 +
    'Public Const dow_Friday = 4'#13#10 +
    'Public Const dow_Saturday = 5'#13#10 +
    'Public Const dow_Sunday = 6'#13#10 +
    'Public Const dow_LocaleDefault = 7'#13#10 +
    'Public Const so_Horizontal = 0'#13#10 +
    'Public Const so_Vertical = 1'#13#10 +
    'Public Const sb_First = 0'#13#10 +
    'Public Const sb_Last = 1'#13#10 +
    'Public Const bs_Normal = 0'#13#10 +
    'Public Const bs_Invisible = 1'#13#10 +
    'Public Const bs_Grayed = 2'#13#10 +
    'Public Const bs_Depressed = 3'#13#10 +
    'Public Const bs_Hot = 4'#13#10 +
    'Public Const pb_Horizontal = 0'#13#10 +
    'Public Const pb_Vertical = 1'#13#10 +
    'Public Const st_Rectangle = 0'#13#10 +
    'Public Const st_Square = 1'#13#10 +
    'Public Const st_RoundRect = 2'#13#10 +
    'Public Const st_RoundSquare = 3'#13#10 +
    'Public Const st_Ellipse = 4'#13#10 +
    'Public Const st_Circle = 5'#13#10 +
    'Public Const tbpa_Left = 0'#13#10 +
    'Public Const tbpa_Right = 1'#13#10 +
    'Public Const tbpa_Center = 2'#13#10 +
    'Public Const nbdm_Default = 0'#13#10 +
    'Public Const nbdm_TextOnly = 1'#13#10 +
    'Public Const nbdm_TextOnlyInMenus = 2'#13#10 +
    'Public Const nbdm_ImageAndText = 3'#13#10 +
    'Public Const tr_Horizontal = 0'#13#10 +
    'Public Const tr_Vertical = 1'#13#10 +
    'Public Const tm_BottomRight = 0'#13#10 +
    'Public Const tm_TopLeft = 1'#13#10 +
    'Public Const tm_Both = 2'#13#10 +
    'Public Const ts_None = 0'#13#10 +
    'Public Const ts_Auto = 1'#13#10 +
    'Public Const ts_Manual = 2'#13#10 +
    'Public Const ud_Left = 0'#13#10 +
    'Public Const ud_Right = 1'#13#10 +
    'Public Const ud_Horizontal = 0'#13#10 +
    'Public Const ud_Vertical = 1'#13#10 +
    'Public Const ces_None = 0'#13#10 +
    'Public Const ces_Ellipsis = 1'#13#10 +
    'Public Const ces_Lookup = 2'#13#10 +
    'Public Const ces_Date = 3'#13#10 +
    'Public Const ces_Memo = 4'#13#10 +
    'Public Const ces_Calculator = 5'#13#10 +
    'Public Const ces_ValueList = 6'#13#10 +
    'Public Const ces_SetGrid = 7'#13#10 +
    'Public Const ces_SetTree = 8'#13#10 +
    'Public Const ces_Graphic = 9'#13#10 +
    'Public Const By_Line = 0'#13#10 +
    'Public Const By_Chunk = 1'#13#10 +
    'Public Const gsTCP = 0'#13#10 +
    'Public Const gsSPX = 1'#13#10 +
    'Public Const gsNamedPipe = 2'#13#10 +
    'Public Const gsLocal = 3'#13#10 +
    'Public Const bmDIB = 0'#13#10 +
    'Public Const bmDDB = 1'#13#10 +
    'Public Const pfDevice = 0'#13#10 +
    'Public Const pf1bit = 1'#13#10 +
    'Public Const pf4bit = 2'#13#10 +
    'Public Const pf8bit = 3'#13#10 +
    'Public Const pf15bit = 4'#13#10 +
    'Public Const pf16bit = 5'#13#10 +
    'Public Const pf24bit = 6'#13#10 +
    'Public Const pf32bit = 7'#13#10 +
    'Public Const pfCustom = 8'#13#10 +
    'Public Const fsEdit = 0'#13#10 +
    'Public Const fsComboBox = 1'#13#10 +
    'Public Const IDOK = 1'#13#10 +
    'Public Const IDCANCEL = 2'#13#10 +
    'Public Const IDABORT = 3'#13#10 +
    'Public Const IDRETRY = 4'#13#10 +
    'Public Const IDIGNORE = 5'#13#10 +
    'Public Const IDYES = 6'#13#10 +
    'Public Const IDNO = 7';

implementation

end.
 