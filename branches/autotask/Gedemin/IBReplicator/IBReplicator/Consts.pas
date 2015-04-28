
{*******************************************************}
{                                                       }
{       Borland Delphi Visual Component Library         }
{                                                       }
{  Copyright (c) 1995-2001 Borland Software Corporation }
{                                                       }
{*******************************************************}

unit Consts;

interface

resourcestring
  SOpenFileTitle = 'Open';
  SCantWriteResourceStreamError = 'Can''t write to a read-only resource stream';
  SDuplicateReference = 'WriteObject called twice for the same instance';
  SClassMismatch = 'Resource %s is of incorrect class';
  SInvalidTabIndex = 'Tab index out of bounds';
  SInvalidTabPosition = 'Tab position incompatible with current tab style';
  SInvalidTabStyle = 'Tab style incompatible with current tab position';
  SInvalidBitmap = 'Bitmap image is not valid';
  SInvalidIcon = 'Icon image is not valid';
  SInvalidMetafile = 'Metafile is not valid';
  SInvalidPixelFormat = 'Invalid pixel format';
  SInvalidImage = 'Invalid image';
  SBitmapEmpty = 'Bitmap is empty';
  SScanLine = 'Scan line index out of range';
  SChangeIconSize = 'Cannot change the size of an icon';
  SOleGraphic = 'Invalid operation on TOleGraphic';
  SUnknownExtension = 'Unknown picture file extension (.%s)';
  SUnknownClipboardFormat = 'Unsupported clipboard format';
  SOutOfResources = 'Out of system resources';
  SNoCanvasHandle = 'Canvas does not allow drawing';
  SInvalidImageSize = 'Invalid image size';
  STooManyImages = 'Too many images';
  SDimsDoNotMatch = 'Image dimensions do not match image list dimensions';
  SInvalidImageList = 'Invalid ImageList';
  SReplaceImage = 'Unable to Replace Image';
  SImageIndexError = 'Invalid ImageList Index';
  SImageReadFail = 'Failed to read ImageList data from stream';
  SImageWriteFail = 'Failed to write ImageList data to stream';
  SWindowDCError = 'Error creating window device context';
  SClientNotSet = 'Client of TDrag not initialized';
  SWindowClass = 'Error creating window class';
  SWindowCreate = 'Error creating window';
  SCannotFocus = 'Cannot focus a disabled or invisible window';
  SParentRequired = 'Control ''%s'' has no parent window';
  SParentGivenNotAParent = 'Parent given is not a parent of ''%s''';
  SMDIChildNotVisible = 'Cannot hide an MDI Child Form';
  SVisibleChanged = 'Cannot change Visible in OnShow or OnHide';
  SCannotShowModal = 'Cannot make a visible window modal';
  SScrollBarRange = 'Scrollbar property out of range';
  SPropertyOutOfRange = '%s property out of range';
  SMenuIndexError = 'Menu index out of range';
  SMenuReinserted = 'Menu inserted twice';
  SMenuNotFound = 'Sub-menu is not in menu';
  SNoTimers = 'Not enough timers available';
  SNotPrinting = 'Printer is not currently printing';
  SPrinting = 'Printing in progress';
  SPrinterIndexError = 'Printer index out of range';
  SInvalidPrinter = 'Printer selected is not valid';
  SDeviceOnPort = '%s on %s';
  SGroupIndexTooLow = 'GroupIndex cannot be less than a previous menu item''s GroupIndex';
  STwoMDIForms = 'Cannot have more than one MDI form per application';
  SNoMDIForm = 'Cannot create form. No MDI forms are currently active';
  SImageCanvasNeedsBitmap = 'Can only modify an image if it contains a bitmap';
  SControlParentSetToSelf = 'A control cannot have itself as its parent';

  SOKButton = 'OK';
  SCancelButton = 'Cancel';
  SYesButton = '&Yes';
  SNoButton = '&No';
  SHelpButton = '&Help';
  SCloseButton = '&Close';
  SIgnoreButton = '&Ignore';
  SRetryButton = '&Retry';
  SAbortButton = 'Abort';
  SAllButton = '&All';

  SCannotDragForm = 'Cannot drag a form';
  SPutObjectError = 'PutObject to undefined item';
  SCardDLLNotLoaded = 'Could not load CARDS.DLL';
  SDuplicateCardId = 'Duplicate CardId found';

  SDdeErr = 'An error returned from DDE  ($0%x)';
  SDdeConvErr = 'DDE Error - conversation not established ($0%x)';
  SDdeMemErr = 'Error occurred when DDE ran out of memory ($0%x)';
  SDdeNoConnect = 'Unable to connect DDE conversation';

  SFB = 'FB';
  SFG = 'FG';
  SBG = 'BG';
  SOldTShape = 'Cannot load older version of TShape';
  SVMetafiles = 'Metafiles';
  SVEnhMetafiles = 'Enhanced Metafiles';
  SVIcons = 'Icons';
  SVBitmaps = 'Bitmaps';
  SGridTooLarge = 'Grid too large for operation';
  STooManyDeleted = 'Too many rows or columns deleted';
  SIndexOutOfRange = 'Grid index out of range';
  SFixedColTooBig = 'Fixed column count must be less than column count';
  SFixedRowTooBig = 'Fixed row count must be less than row count';
  SInvalidStringGridOp = 'Cannot insert or delete rows from grid';
  SInvalidEnumValue = 'Invalid Enum Value';
  SInvalidNumber = 'Invalid numeric value';
  SOutlineIndexError = 'Outline index not found';
  SOutlineExpandError = 'Parent must be expanded';
  SInvalidCurrentItem = 'Invalid value for current item';
  SMaskErr = 'Invalid input value';
  SMaskEditErr = 'Invalid input value.  Use escape key to abandon changes';
  SOutlineError = 'Invalid outline index';
  SOutlineBadLevel = 'Incorrect level assignment';
  SOutlineSelection = 'Invalid selection';
  SOutlineFileLoad = 'File load error';
  SOutlineLongLine = 'Line too long';
  SOutlineMaxLevels = 'Maximum outline depth exceeded';

  {$IFNDEF RP_ENG}
  SMsgDlgWarning = 'Предупреждение';
  SMsgDlgError = 'Ошибка';
  SMsgDlgInformation = 'Информация';
  SMsgDlgConfirm = 'Подтверждение';
  SMsgDlgYes = '&Да';
  SMsgDlgNo = '&Нет';
  SMsgDlgOK = 'OK';
  SMsgDlgCancel = 'Отмена';
  SMsgDlgHelp = '&Помощь';
  SMsgDlgHelpNone = 'No help available';
  SMsgDlgHelpHelp = 'Help';
  SMsgDlgAbort = '&Прервать';
  SMsgDlgRetry = '&Повторить';
  SMsgDlgIgnore = '&Пропустить';
  SMsgDlgAll = '&Все';
  SMsgDlgNoToAll = 'Н&ет для всех';
  SMsgDlgYesToAll = 'Да для &всех';
  {$ELSE}
  SMsgDlgWarning = 'Warning';
  SMsgDlgError = 'Error';
  SMsgDlgInformation = 'Information';
  SMsgDlgConfirm = 'Confirm';
  SMsgDlgYes = '&Yes';
  SMsgDlgNo = '&No';
  SMsgDlgOK = 'OK';
  SMsgDlgCancel = 'Cancel';
  SMsgDlgHelp = '&Help';
  SMsgDlgHelpNone = 'No help available';
  SMsgDlgHelpHelp = 'Help';
  SMsgDlgAbort = '&Abort';
  SMsgDlgRetry = '&Retry';
  SMsgDlgIgnore = '&Ignore';
  SMsgDlgAll = '&All';
  SMsgDlgNoToAll = 'N&o to All';
  SMsgDlgYesToAll = 'Yes to &All';
  {$ENDIF}

  SmkcBkSp = 'BkSp';
  SmkcTab = 'Tab';
  SmkcEsc = 'Esc';
  SmkcEnter = 'Enter';
  SmkcSpace = 'Space';
  SmkcPgUp = 'PgUp';
  SmkcPgDn = 'PgDn';
  SmkcEnd = 'End';
  SmkcHome = 'Home';
  SmkcLeft = 'Left';
  SmkcUp = 'Up';
  SmkcRight = 'Right';
  SmkcDown = 'Down';
  SmkcIns = 'Ins';
  SmkcDel = 'Del';
  SmkcShift = 'Shift+';
  SmkcCtrl = 'Ctrl+';
  SmkcAlt = 'Alt+';

  srUnknown = '(Unknown)';
  srNone = '(None)';
  SOutOfRange = 'Value must be between %d and %d';

  SDateEncodeError = 'Invalid argument to date encode';
  SDefaultFilter = 'All files (*.*)|*.*';
  sAllFilter = 'All';
  SNoVolumeLabel = ': [ - no volume label - ]';
  SInsertLineError = 'Unable to insert a line';

  SConfirmCreateDir = 'The specified directory does not exist. Create it?';
  SSelectDirCap = 'Select Directory';
  SDirNameCap = 'Directory &Name:';
  SDrivesCap = 'D&rives:';
  SDirsCap = '&Directories:';
  SFilesCap = '&Files: (*.*)';
  SNetworkCap = 'Ne&twork...';

  SColorPrefix = 'Color';               //!! obsolete - delete in 5.0
  SColorTags = 'ABCDEFGHIJKLMNOP';      //!! obsolete - delete in 5.0

  SInvalidClipFmt = 'Invalid clipboard format';
  SIconToClipboard = 'Clipboard does not support Icons';
  SCannotOpenClipboard = 'Cannot open clipboard';

  SDefault = 'Default';

  SInvalidMemoSize = 'Text exceeds memo capacity';
  SCustomColors = 'Custom Colors';
  SInvalidPrinterOp = 'Operation not supported on selected printer';
  SNoDefaultPrinter = 'There is no default printer currently selected';

  SIniFileWriteError = 'Unable to write to %s';

  SBitsIndexError = 'Bits index out of range';

  SUntitled = '(Untitled)';

  SInvalidRegType = 'Invalid data type for ''%s''';

  SUnknownConversion = 'Unknown RichEdit conversion file extension (.%s)';
  SDuplicateMenus = 'Menu ''%s'' is already being used by another form';

  SPictureLabel = 'Picture:';
  SPictureDesc = ' (%dx%d)';
  SPreviewLabel = 'Preview';

  SCannotOpenAVI = 'Cannot open AVI';

  SNotOpenErr = 'No MCI device open';
  SMPOpenFilter = 'All files (*.*)|*.*|Wave files (*.wav)|*.wav|Midi files (*.mid)|*.mid|Video for Windows (*.avi)|*.avi';
  SMCINil = '';
  SMCIAVIVideo = 'AVIVideo';
  SMCICDAudio = 'CDAudio';
  SMCIDAT = 'DAT';
  SMCIDigitalVideo = 'DigitalVideo';
  SMCIMMMovie = 'MMMovie';
  SMCIOther = 'Other';
  SMCIOverlay = 'Overlay';
  SMCIScanner = 'Scanner';
  SMCISequencer = 'Sequencer';
  SMCIVCR = 'VCR';
  SMCIVideodisc = 'Videodisc';
  SMCIWaveAudio = 'WaveAudio';
  SMCIUnknownError = 'Unknown error code';

  SBoldItalicFont = 'Bold Italic';
  SBoldFont = 'Bold';
  SItalicFont = 'Italic';
  SRegularFont = 'Regular';

  SPropertiesVerb = 'Properties';

  SServiceFailed = 'Service failed on %s: %s';
  SExecute = 'execute';
  SStart = 'start';
  SStop = 'stop';
  SPause = 'pause';
  SContinue = 'continue';
  SInterrogate = 'interrogate';
  SShutdown = 'shutdown';
  SCustomError = 'Service failed in custom message(%d): %s';
  SServiceInstallOK = 'Service installed successfully';
  SServiceInstallFailed = 'Service "%s" failed to install with error: "%s"';
  SServiceUninstallOK = 'Service uninstalled successfully';
  SServiceUninstallFailed = 'Service "%s" failed to uninstall with error: "%s"';

  SInvalidActionRegistration = 'Invalid action registration';
  SInvalidActionUnregistration = 'Invalid action unregistration';
  SInvalidActionEnumeration = 'Invalid action enumeration';
  SInvalidActionCreation = 'Invalid action creation';

  SDockedCtlNeedsName = 'Docked control must have a name';
  SDockTreeRemoveError = 'Error removing control from dock tree';
  SDockZoneNotFound = ' - Dock zone not found';
  SDockZoneHasNoCtl = ' - Dock zone has no control';

  SAllCommands = 'All Commands';

  SDuplicateItem = 'List does not allow duplicates ($0%x)';

  STextNotFound = 'Text not found: "%s"';
  SBrowserExecError = 'No default browser is specified';

  SColorBoxCustomCaption = 'Custom...';

  SMultiSelectRequired = 'Multiselect mode must be on for this feature';

  SKeyCaption = 'Key';
  SValueCaption = 'Value';
  SKeyConflict = 'A key with the name of "%s" already exists';
  SKeyNotFound = 'Key "%s" not found';
  SNoColumnMoving = 'goColMoving is not a supported option';
  SNoEqualsInKey = 'Key may not contain equals sign ("=")';

  SSendError = 'Error sending mail';
  SAssignSubItemError = 'Cannot assign a subitem to an actionbar when one of it''s parent''s is already assigned to an actionbar';
  SDeleteItemWithSubItems = 'Item %s has subitems, delete anyway?';
  SDeleteNotAllowed = 'You are not allowed to delete this item';
  SMoveNotAllowed = 'Item %s is not allowed to be moved';    
  SMoreButtons = 'More Buttons';
  SErrorDownloadingURL = 'Error downloading URL: %s';
  SUrlMonDllMissing = 'Unable to load %s';
  SAllActions = '(All Actions)';
  SNoCategory = '(No Category)';
  SExpand = 'Expand';
  SErrorSettingPath = 'Error setting path: "%s"';
  SLBPutError = 'Attempting to put items into a virtual style listbox';
  SErrorLoadingFile = 'Error loading previously saved settings file: %s'#13'Would you like to delete it?';
  SResetUsageData = 'Reset all usage data?';
  SFileRunDialogTitle = 'Run';
  SNoName = '(No Name)';      
  SErrorActionManagerNotAssigned = 'ActionManager must first be assigned';
  SAddRemoveButtons = '&Add or Remove Buttons';
  SResetActionToolBar = 'Reset Toolbar';
  SCustomize = '&Customize';
  SSeparator = 'Separator';
  SCirularReferencesNotAllowed = 'Circular references not allowed';
  SCannotHideActionBand = '%s does not allow hiding';
  SErrorSettingCount = 'Error setting %s.Count';
  SListBoxMustBeVirtual = 'Listbox (%s) style must be virtual in order to set Count';
  SUnableToSaveSettings = 'Unable to save settings';
  SRestoreDefaultSchedule = 'Would you like to reset to the default Priority Schedule?';
  SNoGetItemEventHandler = 'No OnGetItem event handler assigned';
  SInvalidColorMap = 'Invalid Colormap this ActionBand requires ColorMaps of type TCustomActionBarColorMapEx';
  SDuplicateActionBarStyleName = 'A style named %s has already been registered';
  SStandardStyleActionBars = 'Standard Style';
  SXPStyleActionBars = 'XP Style';
  SActionBarStyleMissing = 'No ActionBand style unit present in the uses clause.'#13 +
    'Your application must include either XPStyleActnCtrls, StdStyleActnCtrls or ' +
    'a third party ActionBand style unit in its uses clause.';

implementation

end.
