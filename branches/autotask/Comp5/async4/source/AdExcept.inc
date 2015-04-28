(***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower Async Professional
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 1991-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{*********************************************************}
{*                   ADEXCEPT.INC 4.06                   *}
{*        STRING RESOURCES FOR ERRORS AND STATUS         *}
{*********************************************************}

(*
  All string resources have been moved into this resourcestring file in
  APRO 4.03.  The APRO String Resource Manager is still available, but
  not used by default.  Disable the {$DEFINE UseResourceStrings} define
  in AwDefine.inc to revert back to the string resource manager if desired.
  AdExcept.inc contains English strings
  AdExcept.fra contains French strings
  AdExcept.deu contains German strings
  AdExcept.esp contains Spanish strings
  AdExcept.sw contains Swedish strings
  AdExcept.nor constains Norwegian strings
  AdExcept.dk contains Danish strings

  Where a translation was not available, the English version was used.
  If you have a translation for the strings, please send them to us
  through the mailsupport@turbopower.com email address, or through
  the turbopower.public.third-party.internationalization newsgroup.
  We will include the translation in the next release of APRO. Thanks.
*)

resourcestring
{ Numbers in the comments correspond to the ErrorCode passed in many of our }
{ events.  Strings without the numbers do not have corresponding ErrorCodes }
  {No error}
  secOK                             {   0} = 'OK';

  {egDOS}
  secFileNotFound                   {   2} = 'Файл не найден';
  secPathNotFound                   {   3} = 'Путь не найден';
  secTooManyFiles                   {   4} = 'Много открытых файлов';
  secAccessDenied                   {   5} = 'Отказано в доступе к файлу';
  secInvalidHandle                  {   6} = 'Неверный указатель файла';
  secOutOfMemory                    {   8} = 'Недостаточно памяти';
  secInvalidDrive                   {  15} = 'Неверное имя диска';
  secNoMoreFiles                    {  18} = 'Нет файлов';
  secDiskRead                       { 100} = 'Попытка чтения за пределами конца файла';
  secDiskFull                       { 101} = 'Диск полон';
  secNotAssigned                    { 102} = 'Файл/устройство не назначены';
  secNotOpen                        { 103} = 'Файл/устройство не открыто';
  secNotOpenInput                   { 104} = 'Файл/устройство не открыто для ввода';
  secNotOpenOutput                  { 105} = 'Файл/устройство не открыто для вывода';
  secWriteProtected                 { 150} = 'Диск защищен от записи';
  secUnknownUnit                    { 151} = 'Unknown disk unit';
  secDriveNotReady                  { 152} = 'Диск не готов';
  secUnknownCommand                 { 153} = 'Неизвестная комманда';
  secCrcError                       { 154} = 'Ошибка данных';
  secBadStructLen                   { 155} = 'Bad request structure length';
  secSeekError                      { 156} = 'Искать ошибку';
  secUnknownMedia                   { 157} = 'Неизвестный тип носителя';
  secSectorNotFound                 { 158} = 'Сектор диска не найден';
  secOutOfPaper                     { 159} = 'В принтере нет бумаги';
  secDeviceWrite                    { 160} = 'Ошибка записи на устройство';
  secDeviceRead                     { 161} = 'Ошибка чтения с устройства';
  secHardwareFailure                { 162} = 'Общий сбой';

  {egGeneral}
  secBadHandle                      {1001} = 'Функции com передан неверный указатель';
  secBadArgument                    {1002} = 'Функции передан неверный аргумент';
  secGotQuitMsg                     {1003} = 'Получено сообщение о выходе';
  secBufferTooBig                   {1004} = 'Буфер терминала больше 65521';
  secPortNotAssigned                {1005} = 'Компонет ComPort не назначен';
  secInternal                       {1006} = 'Внутренняя ошибка создания класса окнаs';
  secModemNotAssigned               {1007} = 'Компонент модема не назначен';
  secPhonebookNotAssigned           {1008} = 'Компонент телефонной книги не назначен';
  secCannotUseWithWinSock           {1009} = 'Компонент не совместим с WinSock';

  {egOpenComm}
  secBadId                          {2001} = 'ie_BadId - указанный ком порт не существует';
  secBaudRate                       {2002} = 'ie_Baudrate - неподдерживаемая скорость передачи';
  secByteSize                       {2003} = 'ie_Bytesize - неверный размер в байтах';
  secDefault                        {2004} = 'ie_Default - ошибка в параметрах по умолчанию';
  secHardware                       {2005} = 'ie_Hardware - указанный ком порт занят';
  secMemory                         {2006} = 'ie_Memory - невозможно зарезервировать очередь';
  secCommNotOpen                    {2007} = 'ie_NOpen - устройство не открыто';
  secAlreadyOpen                    {2008} = 'ie_Open - устройство уже открыто';
  secNoHandles                      {2009} = 'Нет указателей, невозможно открыть порт';
  secNoTimers                       {2010} = 'Нет таймеров';
  secNoPortSelected                 {2011} = 'Свойство ComNumber TApdComPort не установлено';
  secNotOpenedByTapi                {2012} = 'Com порт не открыт с помощью Tapi';

  {egSerialIO}
  secNullApi                        {3001} = 'Не указан уровень устройства No device layer specified';
  secNotSupported                   {3002} = 'Функция не поддерживается драйвером';
  secRegisterHandlerFailed          {3003} = 'EnableCommNotification не сработало';
  secPutBlockFail                   {3004} = 'Сбой записи целого блока';
  secGetBlockFail                   {3005} = 'Сбой чтения целого блока';
  secOutputBufferTooSmall           {3006} = 'Выходной буфер мал для блока';
  secBufferIsEmpty                  {3007} = 'Буфер пуст';
  secTracingNotEnabled              {3008} = 'Трасировка не включена';
  secLoggingNotEnabled              {3009} = 'Запись в лог не включена';
  secBaseAddressNotSet              {3010} = 'Базовый адрес не установлен';

  {Modem/Pager}
  secModemNotStarted                {4001} = 'Стартовый модем не вызывался';
  secModemBusy                      {4002} = 'Иодем где-то занят';
  secModemNotDialing                {4003} = 'Сейчас модем не производит набор номера';
  secNotDialing                     {4004} = 'Нет набора номера';
  secAlreadyDialing                 {4005} = 'Номер уже набирается';
  secModemNotResponding             {4006} = 'Модем не отвечает';
  secModemRejectedCommand           {4007} = 'Модему послана неверная комманда';
  secModemStatusMismatch            {4008} = 'Запрос состояния не того модема';

  secDeviceNotSelected              {4009} = 'Устройство не выбрано';
  secModemDetectedBusy              {4010} = 'Занято';
  secModemNoDialtone                {4011} = 'Нет сигнала в линии';
  secModemNoCarrier                 {4012} = 'Соединение потеряно';
  secModemNoAnswer                  {4013} = 'Нет ответа';

  { Pager }
  secInitFail                       {4014} = 'Modem Initialization Failure';
  secLoginFail                      {4015} = 'Failed to Login';
  secMinorSrvErr                    {4016} = 'Minor Server Error';
  secFatalSrvErr                    {4017} = 'Fatal Server Error';

  {LibModem}
  secModemNotFound                  {4020} = 'Модем не найден';
  secInvalidFile                    {4021} = 'Неверный файл модема';

  {deprecated, duplicate values different names}
  {TApdPhoneBookEditor}
  spbeDeleteQuery                   {4101} = 'Вы уверены, что хотите удалить эту запись?';
  {TApdSModem}
  sdsmMsgBase                       {4200} = '';
  sdsmMsgReady                      {4201} = 'Готов';
  sdsmMsgInitialize                 {4202} = 'Инициализация модема';
  sdsmMsgInitializeTimeout          {4203} = 'Инициализация тайм аута';
  sdsmMsgAutoAnswerBackground       {4204} = 'Ато ответ в фоновом режиме';
  sdsmMsgAutoAnswerWait             {4205} = 'Ожидание входящих звонков';
  sdsmMsgAnswerWait                 {4206} = 'Ответ на звонок';
  sdsmMsgDialWait                   {4207} = 'Набор номера';
  sdsmMsgDialCycle                  {4208} = 'Пауза перед новым набором номера';
  sdsmMsgNoDialtone                 {4209} = 'Нет сигнала в линии';
  sdsmMsgConnectWait                {4210} = 'Связь установлена и влючен режим ожидания';
  sdsmMsgConnected                  {4211} = 'Связь установлена';
  sdsmMsgHangup                     {4212} = 'Отключение связи';
  sdsmMsgCancel                     {4213} = 'Отмена';
  {TApdDialerDialog}
  sdddCycling                       {4301} = 'Циклическая попытка нобра номера . . .';
  sdddRetryWaiting                  {4302} = 'Ожидаем . . .';
  sdddRetryWaitOver                 {4303} = 'Ожидание закончено, новый набор . . .';
  sdddDialing                       {4304} = 'Набор номера . . .';
  sdddModemConnect                  {4305} = 'Связь с модемом установлена!';
  sdddModemConnectAt                {4306} = 'Соединение на скорости %d бод';
  sdddModemVoice                    {4307} = 'Результат соединения: Удаленный отвечает голосом';
  sdddModemError                    {4308} = 'Результат соединения: Модем возвратил ошибку';
  sdddModemNoCarrier                {4309} = 'Результат соединения: нет ответа, соединение не установлено';
  sdddModemBusy                     {4310} = 'Результат соединения: удаленный номер занят';
  sdddModemNoDialTone               {4311} = 'Результат соединения: Нет сигнала в линии, проверьте провода';
  sdddDialTimedOut                  {4312} = 'Попытка нобора номера - тайм аут';
  {TPhoneBookEntryForm}
  sdpeMustEnterName                 {4401} = 'Введите имя записи';
  sdpeMustEnterNumber               {4402} = 'Введите номер';
  sdpeNameExists                    {4403} = 'Запись в телефонной книге с таким именем уже существует';

  {RAS connection status codes}
  scsOpenPort                       {4500} = 'OpenPort';
  scsPortOpened                     {4501} = 'PortOpened';
  scsConnectDevice                  {4502} = 'ConnectDevice';
  scsDeviceConnected                {4503} = 'DeviceConnected';
  scsAllDevicesConnected            {4504} = 'AllDevicesConnected';
  scsAuthenticate                   {4505} = 'Authenticate';
  scsAuthNotify                     {4506} = 'AuthNotify';
  scsAuthRetry                      {4507} = 'AuthRetry';
  scsAuthCallback                   {4508} = 'AuthCallback';
  scsAuthChangePassword             {4509} = 'AuthChangePassword';
  scsAuthProject                    {4510} = 'AuthProject';
  scsAuthLinkSpeed                  {4511} = 'AuthLinkSpeed';
  scsAuthAck                        {4512} = 'AuthAck';
  scsReAuthenticate                 {4513} = 'ReAuthenticate';
  scsAuthenticated                  {4514} = 'Authenticated';
  scsPrepareForCallback             {4515} = 'PrepareForCallback';
  scsWaitForModemReset              {4516} = 'WaitForModemReset';
  scsWaitForCallback                {4517} = 'WaitForCallback';
  scsProjected                      {4518} = 'Projected';
  scsStartAuthentication            {4519} = 'StartAuthentication';
  scsCallbackComplete               {4520} = 'CallbackComplete';
  scsLogonNetwork                   {4521} = 'LogonNetwork';
  scsSubEntryConnected              {4522} = 'SubEntryConnected';
  scsSubEntryDisconnected           {4523} = 'SubEntryDisconnected';
  scsRasInteractive                 {4550} = 'Interactive';
  scsRasRetryAuthentication         {4551} = 'RetryAuthentication';
  scsRasCallbackSetByCaller         {4552} = 'CallbackSetByCaller';
  scsRasPasswordExpired             {4553} = 'PasswordExpired';
  scsRasDeviceConnected             {4599} = 'DeviceConnected';

  { Pager TDialingStatus }
  sPDS_NONE                         {4600} = '';
  sPDS_OFFHOOK                      {4601} = 'Off Hook';
  sPDS_DIALING                      {4602} = 'Dialing';
  sPDS_RINGING                      {4603} = 'Ringing';
  sPDS_WAITFORCONNECT               {4604} = 'Wait For Connect';
  sPDS_CONNECTED                    {4605} = 'Connected';
  sPDS_WAITINGTOREDIAL              {4606} = 'Waiting To Redial';
  sPDS_REDIALING                    {4607} = 'Redialing';
  sPDS_MSGNOTSENT                   {4608} = 'Message Not Sent';
  sPDS_CANCELLING                   {4609} = 'Cancelling';
  sPDS_DISCONNECT                   {4610} = 'Disconnect';
  sPDS_CLEANUP                      {4611} = 'Cleanup';

  { PDialingError }
  sPDE_NONE                         {4630} = '';
  sPDE_NODIALTONE                   {4631} = 'Нет сигнала в линии';
  sPDE_LINEBUSY                     {4632} = 'Занято';
  sPDE_NOCONNECTION                 {4633} = 'Соединение не установлено';

  { TTapStatus }
  sTAPS_NONE                        {4660} = '';
  sTAPS_LOGINPROMPT                 {4661} = 'Введите логин';
  sTAPS_LOGGEDIN                    {4662} = 'Вход в сеть';
  sTAPS_LOGINERR                    {4663} = 'Ошибка входа в сеть';
  sTAPS_LOGINFAIL                   {4664} = 'Сбой входа в сеть';
  sTAPS_MSGOKTOSEND                 {4665} = 'Послать сообщение ОК';
  sTAPS_SENDINGMSG                  {4666} = 'Отправка сообщения';
  sTAPS_MSGACK                      {4667} = 'Сообщение принято';
  sTAPS_MSGNAK                      {4668} = 'сообщение не принято';
  sTAPS_MSGRS                       {4669} = 'Ошибка сообщения';
  sTAPS_MSGCOMPLETED                {4670} = 'Сообющение завершено';
  sTAPS_DONE                        {4671} = 'Готово';

  { Protocol status }
  spsOK                             {4700} = 'OK';
  spsProtocolHandshake              {4701} = 'Protocol handshaking in progress';
  spsInvalidDate                    {4702} = 'Bad date/time stamp received and ignored';
  spsFileRejected                   {4703} = 'File rejected';
  spsFileRenamed                    {4704} = 'File renamed';
  spsSkipFile                       {4705} = 'File skipped';
  spsFileDoesntExist                {4706} = 'File doesn''t exist locally, skipped';
  spsCantWriteFile                  {4707} = 'File skipped ';
  spsTimeout                        {4708} = 'Time out in protocol';
  spsBlockCheckError                {4709} = 'Bad checksum or CRC';
  spsLongPacket                     {4710} = 'Block too long';
  spsDuplicateBlock                 {4711} = 'Duplicate block received and ignored ';
  spsProtocolError                  {4712} = 'Error in protocol';
  spsCancelRequested                {4713} = 'Cancel requested';
  spsEndFile                        {4714} = 'At end of file';
  spsResumeBad                      {4715} = 'B+ host refused resume request';
  spsSequenceError                  {4716} = 'Block was out of sequence';
  spsAbortNoCarrier                 {4717} = 'Aborting on carrier loss';

  {Specific to certain protocols}
  spsGotCrcE                        {4718} = 'Got CrcE packet (Zmodem)';
  spsGotCrcG                        {4719} = 'Got CrcG packet (Zmodem)';
  spsGotCrcW                        {4720} = 'Got CrcW packet (Zmodem)';
  spsGotCrcQ                        {4721} = 'Got CrcQ packet (Zmodem)';
  spsTryResume                      {4722} = 'B+ is trying to resume a download';
  spsHostResume                     {4723} = 'B+ host is resuming';
  spsWaitAck                        {4724} = 'Waiting for B+ ACK';

  {Internal protocol codes}
  spsNoHeader                       {4725} = '';
  spsGotHeader                      {4726} = '';
  spsGotData                        {4727} = '';
  spsNoData                         {4728} = '';
  spsAbort                          {4730} = '';

  {Fax progress codes, sending}
  sfpInitModem                      {4801} = 'Initializing modem for fax processing';
  sfpDialing                        {4802} = 'Dialing';
  sfpBusyWait                       {4803} = 'Busy, waiting until redial...';
  sfpSendPage                       {4804} = 'Sending page data';
  sfpSendPageStatus                 {4805} = 'Sending EOP';
  sfpPageError                      {4806} = 'Error sending page';
  sfpPageOK                         {4807} = 'Page accepted by remote';
  sfpConnecting                     {4808} = 'Connecting...';

  {Fax progress codes, receiving}
  sfpWaiting                        {4820} = 'Waiting for incoming call';
  sfpNoConnect                      {4821} = 'No connect on this call';
  sfpAnswer                         {4822} = 'Answering incoming call';
  sfpIncoming                       {4823} = 'Incoming call validated as fax';
  sfpGetPage                        {4824} = 'Getting page data';
  sfpGetPageResult                  {4825} = 'Getting end-of-page signal';
  sfpCheckMorePages                 {4826} = 'Getting end-of-document status';
  sfpGetHangup                      {4827} = 'Getting hangup command';
  sfpGotHangup                      {4828} = 'Got Class 2 FHNG code';

  {Fax server codes }
  sfpSwitchModes                    {4830} = 'Switching modes';
  sfpMonitorEnabled                 {4831} = 'Monitoring for incoming faxes';
  sfpMonitorDisabled                {4832} = 'Not monitoring for incoming faxes';

  {Fax progress codes, common}
  sfpSessionParams                  {4840} = 'Getting connection params';
  sfpGotRemoteID                    {4841} = 'Got called-station ID';
  sfpCancel                         {4842} = 'User abort';
  sfpFinished                       {4843} = 'Finished';

  {Trigger errors}
  secNoMoreTriggers                 {5001} = 'Нет места для триггера';
  secTriggerTooLong                 {5002} = 'Тригер данных слишком длинный';
  secBadTriggerHandle               {5003} = 'Неверный указатель триггера';

  {Packet errors}
  secStartStringEmpty               {5501} = 'Стартовая строка пустая';
  secPacketTooSmall                 {5502} = 'Размер пакета не может быть меньше стартовой строки';
  secNoEndCharCount                 {5503} = 'Пакеты CharCount должны иметь условия окончания';
  secEmptyEndString                 {5504} = 'Конечная строка пустая';
  secZeroSizePacket                 {5505} = 'Размер пакета не может быть нулевым';
  secPacketTooLong                  {5506} = 'Пакет слишком длинный';

  {Protocol errors}
  secBadFileList                    {6001} = 'Неверный формат в списке файлов';
  secNoSearchMask                   {6002} = 'Во время передачи не указана Маска поиска';
  secNoMatchingFiles                {6003} = 'No files matched search mask';
  secDirNotFound                    {6004} = 'Directory in search mask doesn''t exist';
  secCancelRequested                {6005} = 'Cancel requested';
  secTimeout                        {6006} = 'Fatal time out';
  secProtocolError                  {6007} = 'Unrecoverable event during protocol';
  secTooManyErrors                  {6008} = 'Too many errors during protocol';
  secSequenceError                  {6009} = 'Block sequence error in Xmodem';
  secNoFilename                     {6010} = 'No filename specified in protocol receive';
  secFileRejected                   {6011} = 'File was rejected';
  secCantWriteFile                  {6012} = 'Cant write file';
  secTableFull                      {6013} = 'Kermit window table is full, fatal error';
  secAbortNoCarrier                 {6014} = 'Aborting due to carrier loss';
  secBadProtocolFunction            {6015} = 'Function not supported by protocol';
  secProtocolAbort                  {6016} = 'Protocol aborted';

  {INI database}
  secKeyTooLong                     {7001} = 'Ключевая строка слишком длинная';
  secDataTooLarge                   {7002} = 'Строка данных слишком длинная';
  secNoFieldsDefined                {7003} = 'В базе данных поля не определены';
  secIniWrite                       {7004} = 'Ошибка записи в Generic INI-файл';
  secIniRead                        {7005} = 'Ошибка чтения из Generic INI-файла';
  secNoIndexKey                     {7006} = 'Не определен индекс для базы данных';
  secRecordExists                   {7007} = 'Запись уже существует';
  secRecordNotFound                 {7008} = 'Запись не найдена в базе данных';
  secMustHaveIdxVal                 {7009} = 'Неверное ключевое имя индекса';
  secDatabaseFull                   {7010} = 'Достигнуто максимальное кол-во записей в БД (999)';
  secDatabaseEmpty                  {7011} = 'В БД нет записей';
  secDatabaseNotPrepared            {7012} = 'iPrepareIniDatabase не вызван';
  secBadFieldList                   {7013} = 'В INI компоненте неверный список файлов';
  secBadFieldForIndex               {7014} = 'В INI компоненте неверный индекс поля';

  {State Machine}
  secNoStateMachine                 {7500} = 'Машина состояния не указана'; {!!.04}
  secNoStartState                   {7501} = 'Стартовое состояние не установлено';       {!!.04}
  secNoSapiEngine                   {7502} = 'Движок SAPI не указан'; {!!.04}

  { fax codes }
  secFaxBadFormat                   {8001} = 'File is not an APF file';
  secBadGraphicsFormat              {8002} = 'Unsupported graphics file format';
  secConvertAbort                   {8003} = 'User aborted fax conversion';
  secUnpackAbort                    {8004} = 'User aborted fax unpack';
  secCantMakeBitmap                 {8005} = 'CreateBitmapIndirect API failure';
  secNoImageLoaded                  {8050} = 'No image loaded into viewer';
  secNoImageBlockMarked             {8051} = 'No block of image marked';
  secFontFileNotFound               {8052} = 'APFAX.FNT not found, or resource bad';
  secInvalidPageNumber              {8053} = 'Invalid page number specified for fax';
  secBmpTooBig                      {8054} = 'BMP size exceeds Windows'' maxheight of 32767';
  secEnhFontTooBig                  {8055} = 'Font selected for enhanced text converter too large';

  secFaxBadMachine                  {8060} = 'Fax incompatible with remote fax';
  secFaxBadModemResult              {8061} = 'Bad response from modem';
  secFaxTrainError                  {8062} = 'Modems failed to train';
  secFaxInitError                   {8063} = 'Error while initializing modem';
  secFaxBusy                        {8064} = 'Called fax number was busy';
 secFaxVoiceCall                   {8065} = 'Called fax number answered with voice';
 secFaxDataCall                    {8066} = 'Incoming data call';
  secFaxNoDialTone                  {8067} = 'No dial tone';
  secFaxNoCarrier                   {8068} = 'Failed to connect to remote fax';
  secFaxSessionError                {8069} = 'Fax failed in mid-session';
  secFaxPageError                   {8070} = 'Fax failed at page end';
  secFaxGDIPrintError               {8071} = 'NextBand GDI error in fax print driver';
  secFaxMixedResolution             {8072} = 'Multiple resolutions per session not supported';
  secFaxConverterInitFail           {8073} = 'Initialization of fax converter failed';
  secNoAnswer                       {8074} = 'Remote fax did not answer';
  secAlreadyMonitored               {8075} = 'Directory already being monitored';

  { Printer driver installation codes }
  secUniAlreadyInstalled            {8080} = 'Unidrv support files already installed';
  secUniCannotGetSysDir             {8081} = 'Cannot determine windows system dir';
  secUniCannotGetWinDir             {8082} = 'Cannot determine windows dir';
  secUniUnknownLayout               {8083} = 'Cannot determine setup file layout';
  secUniCannotInstallFile           {8085} = 'Cannot install Unidrv files to system dir';
  secDrvCopyError                   {8087} = 'Error copying printer driver';
  secCannotAddPrinter               {8088} = '32-bit AddPrinter call failed';
  secDrvBadResources                {8089} = 'Bad/missing resources in driver';
  secDrvDriverNotFound              {8090} = 'Driver file not found';
  secUniCannotGetPrinterDriverDir   {8091} = 'Cannot determine Win NT printer driver dir';
  secInstallDriverFailed            {8092} = 'AddPrinterDriver API failed';

  { TApdGSMPhone error codes }
  secSMSBusy                        {8100} = 'Busy with another command';
  secSMSTimedOut                    {8101} = 'Timed out, no response back';
  secSMSTooLong                     {8102} = 'SMS message too long';
  secSMSUnknownStatus               {8103} = 'Status unknown';
  secSMSInvalidNumber               {8138} = 'Invalid Number or Network out of order';  {!!.06}
  secMEFailure                      {8300} = 'Mobile equipment failure';
  secServiceRes                     {8301} = 'SMS service of ME reserved';
  secBadOperation                   {8302} = 'Operation not allowed';
  secUnsupported                    {8303} = 'Operation not supported';
  secInvalidPDU                     {8304} = 'Invalid PDU mode parameter';
  secInvalidText                    {8305} = 'Invalid Text mode parameter';
  secSIMInsert                      {8310} = 'SIM card not inserted';
  secSIMPin                         {8311} = 'SIM PIN required';
  secSIMPH                          {8312} = 'PH-SIM PIN required';
  secSIMFailure                     {8313} = 'SIM failure';
  secSIMBusy                        {8314} = 'SIM busy';
  secSIMWrong                       {8315} = 'SIM wrong';
  secSIMPUK                         {8316} = 'SIM PUK required';
  secSIMPIN2                        {8317} = 'SIM PIN2 required';
  secSIMPUK2                        {8318} = 'SIM PUK2 required';
  secMemFail                        {8320} = 'Memory failure';
  secInvalidMemIndex                {8321} = 'Invalid memory index';
  secMemFull                        {8322} = 'Memory is full';
  secSMSCAddUnknown                 {8330} = 'SMS Center Address unknown';
  secNoNetwork                      {8331} = 'No network service';
  secNetworkTimeout                 {8332} = 'Network timeout';
  secCNMAAck                        {8340} = 'No +CNMA acknowledgement expected';
  secUnknown                        {8500} = 'Unknown error';

  { Winsock codes }
  secADWSERROR                      {9001} = 'Async Professional Error';
  secADWSLOADERROR                  {9002} = 'Error loading Winsock DLL';
  secADWSVERSIONERROR               {9003} = 'Incorrect version of Winsock';
  secADWSNOTINIT                    {9004} = 'Winsock not initialized - %s';
  secADWSINVPORT                    {9005} = 'Specified port is not valid';
  secADWSCANTCHANGE                 {9006} = 'Cannot change parameter while socket is connected';
  secADWSCANTRESOLVE                {9007} = 'Cannot resolve destination address';

  { All Windows Sockets error constants are biased by 10000 from the "normal" }
  swsaBaseErr                       {10000} = '';
  { Windows Sockets definitions of regular Microsoft C error constants }
  swsaEIntr                         {10004} = 'Interrupted function call';
  swsaEBadF                         {10009} = 'Bad file number';
  swsaEAcces                        {10013} = 'Permission denied';
  swsaEFault                        {10014} = 'Unknown error';
  swsaEInVal                        {10022} = 'Invalid argument';
  swsaEMFile                        {10024} = 'Too many open files';

  { Windows Sockets definitions of regular Berkeley error constants }
  swsaEWouldBlock                   {10035} = 'Warning : the socket would block on this call';
  swsaEInProgress                   {10036} = 'A blocking call is in progress';
  swsaEAlReady                      {10037} = 'WSAEALREADY: watch out, Al is ready';
  swsaENotSock                      {10038} = 'Socket descriptor is (1) not a socket, or (2) is of wrong type';
  swsaEDestAddrReq                  {10039} = 'The destination address is required for this operation';
  swsaEMsgSize                      {10040} = 'The datagram was too large to fit into the buffer and was truncated';
  swsaEPrototype                    {10041} = 'WSAEPROTOTYPE';
  swsaENoProtoOpt                   {10042} = 'The option is unknown or not supported';
  swsaEProtoNoSupport               {10043} = 'Either (1) not enough buffer space to create socket (2) protocol not supported';
  swsaESocktNoSupport               {10044} = 'Specified socket type not supported in this address family';
  swsaEOpNotSupp                    {10045} = 'Operation is not supported by this socket';
  swsaEPfNoSupport                  {10046} = 'Specified protocol family is not supported';
  swsaEAfNoSupport                  {10047} = 'Specified address family is not supported by this protocol';
  swsaEAddrInUse                    {10048} = 'The address is already in use for this operation';
  swsaEAddrNotAvail                 {10049} = 'The address is not available from this machine';
  swsaENetDown                      {10050} = 'The network subsystem has failed';
  swsaENetUnreach                   {10051} = 'The network is unreachable from this machine at this time';
  swsaENetReset                     {10052} = 'The network has been reset';
  swsaEConnAborted                  {10053} = 'The virtual circuit has been aborted due to timeout, etc';
  swsaEConnReset                    {10054} = 'The virtual circuit has been reset by the partner';
  swsaENoBufs                       {10055} = 'The descriptor is not a socket, or no buffer space is available';
  swsaEIsConn                       {10056} = 'The socket is already connected';
  swsaENotConn                      {10057} = 'The socket is not connected';
  swsaEShutDown                     {10058} = 'The socket has been shutdown';
  swsaETooManyRefs                  {10059} = 'WSAETOOMANYREFS';
  swsaETimedOut                     {10060} = 'The operation timed out';
  swsaEConnRefused                  {10061} = 'The attempt to connect was forcibly refused';
  swsaELoop                         {10062} = 'WSAELOOP: see WSAELOOP';
  swsaENameTooLong                  {10063} = 'The name is too long';
  swsaEHostDown                     {10064} = 'The host machine is down';
  swsaEHostUnreach                  {10065} = 'The host machine is unreachable';
  swsaENotEmpty                     {10066} = 'WSAENOTEMPTY';
  swsaEProcLim                      {10067} = 'WSAEPROCLIM';
  swsaEUsers                        {10068} = 'WSAEUSERS';
  swsaEDQuot                        {10069} = 'WSAEDQUOT';
  swsaEStale                        {10070} = 'WSAESTALE';
  swsaERemote                       {10071} = 'WSAEREMOTE';

  { Extended Windows Sockets error constant definitions }
  swsaSysNotReady                   {10091} = 'Network subsystem unusable';
  swsaVerNotSupported               {10092} = 'Version requested by WSAStartUp not supported by loaded Winsock DLL';
  swsaNotInitialised                {10093} = 'WSAStartUp not yet called';
  swsaEDiscOn                       {10101} = 'WSAEDISCON';
  swsaHost_Not_Found                {11001} = 'Host not found';
  swsaTry_Again                     {11002} = 'Host not found, or SERVERFAIL, can try again';
  swsaNo_Recovery                   {11003} = 'Non recoverable errors, FORMERR, REFUSED, NOTIMP';
  swsaNo_Data                       {11004} = 'Valid name, but no data record of requested type';

  { The string resource range 13500 - 13800 is used for TAPI }
  { status messages, which do not require constants here     }
  {TAPI CallState}
  stcs_Idle                         {13501} = 'Линия свободна';
  stcs_Offering                     {13502} = 'Поиск линии...';
  stcs_Accepted                     {13503} = 'Принятие звонка...';
  stcs_Dialtone                     {13504} = 'Есть сигнал в линии';
  stcs_Dialing                      {13505} = 'Набор...';
  stcs_Ringback                     {13506} = 'Ответный звонок';
  stcs_Busy                         {13507} = 'Вызываемый номер занят';
  stcs_SpecialInfo                  {13508} = 'Специальная информация';
  stcs_Connected                    {13509} = 'Соединение установлено!';
  stcs_Proceeding                   {13510} = 'Продолжаем...';
  stcs_OnHold                       {13511} = 'Удерживается...';
  stcs_Conferenced                  {13512} = 'Звонок переключен в коференц-режим';
  stcs_OnHoldPendConf               {13513} = 'On hold pending conference...';
  stcs_OnHoldPendTransfer           {13514} = 'On hold pending transfer...';
  stcs_Disconnected                 {13515} = 'Отключение (%s)';
  stcs_Unknown                      {13516} = 'Неизвестное состояние';
  {TAPI DevState}
  stds_Other                        {13533} = 'Другое';
  stds_Ringing                      {13534} = 'Входящий звонок';
  stds_Connected                    {13535} = 'Соединение установлено';
  stds_Disconnected                 {13536} = 'Соединение разорвано';
  stds_MsgWaitOn                    {13537} = 'Ожидание сообщения включено';
  stds_MsgWaitOff                   {13538} = 'Ожидание сообщения выключено';
  stds_InService                    {13539} = 'Работает';
  stds_OutOfService                 {13540} = 'Не работает';
  stds_Maintenance                  {13541} = 'Обслуживание изменено';
  stds_Open                         {13542} = 'Открыт ';
  stds_Close                        {13543} = 'Закрыт';
  stds_NumCalls                     {13544} = 'Кол-во звонков изменено';
  stds_NumCompletions               {13545} = 'Кол-во завершений изменено';
  stds_Terminals                    {13546} = 'Терминалы изменены';
  stds_RoamMode                     {13547} = 'Режим роуминга изменен';
  stds_Battery                      {13548} = 'Батарейка заменена';
  stds_Signal                       {13549} = 'Сигнал изменен';
  stds_DevSpecific                  {13550} = 'Специфичесое изменение устройства';
  stds_ReInit                       {13551} = 'Новая инициализация';
  stds_Lock                         {13552} = 'Lock change';
  stds_CapsChange                   {13553} = 'Caps change';
  stds_ConfigChange                 {13554} = 'Конфигурация изменена';
  stds_TranslateChange              {13555} = 'Смена трансляции';
  stds_ComplCancel                  {13556} = 'Завершение отменено';
  stds_Removed                      {13557} = 'Удалено';

  { TAPI APRO-specific }
  sTAPILineReply                    {13565} = 'TAPI ответ линии';
  sTAPIStateChange                  {13597} = 'TAPI смена состояния';
  sTAPICalledBusy                   {13598} = 'Вызываемый номер занят';
  sTAPIDialFail                     {13599} = 'Сбой набора номера/соединение не установлено';
  sTAPIRetryWait                    {13600} = 'Ожидание повтора через %d секунд';
  sTAPIDeviceInUse                  {13601} = 'Устройство занято другим приложением';

  { TAPI Disconnect Reasons }
  sTAPIDisconnect_Unspecified       {13650} = 'Причина не указана';
  sTAPIDisconnect_Normal            {13651} = 'Нормальное разъединение удаленным';
  sTAPIDisconnect_Unknown           {13652} = 'Причина не известна';
  sTAPIDisconnect_Reject            {13653} = 'Удаленный отверг звонок';
  sTAPIDisconnect_PickUp            {13654} = 'Звонок принят где-то в другом месте';
  sTAPIDisconnect_Forwarded         {13655} = 'Звонок перенаправлен';
  sTAPIDisconnect_Busy              {13656} = 'Линия была занята';
  sTAPIDisconnect_NoAnswer          {13657} = 'Удаленный не отвечает';
  sTAPIDisconnect_BadAddress        {13658} = 'Неверный адрес назначения';
  sTAPIDisconnect_Unreachable       {13659} = 'Удаленный не доступен';
  sTAPIDisconnect_Congestion        {13660} = 'Network Congestion';
  sTAPIDisconnect_Incompatible      {13661} = 'Удаленное оборудование не совместимо';
  sTAPIDisconnect_Unavail           {13662} = 'Причина не ясна';
  sTAPIDisconnect_NoDialtone        {13663} = 'Нет сигнала в линии';
  sTAPIDisconnect_NumberChanged     {13664} = 'Номер изменен';
  sTAPIDisconnect_OutOfOrder        {13665} = 'Сломано';
  sTAPIDisconnect_TempFailure       {13666} = 'Временный сбой';
  sTAPIDisconnect_QOSUnavail        {13667} = 'Качество обслуживания недоступно';
  sTAPIDisconnect_Blocked           {13668} = 'Заблокировано';
  sTAPIDisconnect_DoNotDisturb      {13669} = 'Не беспокоить';
  sTAPIDisconnect_Cancelled         {13670} = 'Отменено';

  {Adjusted TAPI error codes}
  secAllocated                      {13801} = 'Уже зарезервировано';
  secBadDeviceID                    {13802} = 'Неверный ID устройства';
  secBearerModeUnavail              {13803} = 'Режим носителя недоступен';
  secCallUnavail                    {13805} = 'Звонок не возможен';
  secCompletionOverrun              {13806} = 'Завершение';
  secConferenceFull                 {13807} = 'Конференц-режим полон';
  secDialBilling                    {13808} = 'Сбой набора номера';
  secDialDialtone                   {13809} = 'Сбой набора номера, нет сигнала в линии';
  secDialPrompt                     {13810} = 'Сбой набора номера';
  secDialQuiet                      {13811} = 'Сбой набора номера';
  secIncompatibleApiVersion         {13812} = 'Несовместимая версия API';
  secIncompatibleExtVersion         {13813} = 'Несовместимая версия EXT';
  secIniFileCorrupt                 {13814} = 'INI-файл поврежден';
  secInUse                          {13815} = 'Ресурс используется';
  secInvalAddress                   {13816} = 'Неверный адрес';
  secInvalAddressID                 {13817} = 'Неверный адрес ID';
  secInvalAddressMode               {13818} = 'Неверный режим адрес';
  secInvalAddressState              {13819} = 'Неверное состояние адреса ';
  secInvalAppHandle                 {13820} = 'Неверный указатель приложения';
  secInvalAppName                   {13821} = 'Неверное имя приложения';
  secInvalBearerMode                {13822} = 'Неверный режим носителя';
  secInvalCallComplMode             {13823} = 'Неверный режим завершения';
  secInvalCallHandle                {13824} = 'Неверный указатель звонка';
  secInvalCallParams                {13825} = 'Неверный параметр звонка';
  secInvalCallPrivilege             {13826} = 'Неверная привилегия звонка';
  secInvalCallSelect                {13827} = 'Неверный выбор звонка';
  secInvalCallState                 {13828} = 'Неверное состояние звонка';
  secInvalCallStatelist             {13829} = 'Неверный список состояния звоноков';
  secInvalCard                      {13830} = 'Неверная каточка';
  secInvalCompletionID              {13831} = 'Неверный ID завершения';
  secInvalConfCallHandle            {13832} = 'Неверный указатель конференц-звонков';
  secInvalConsultCallHandle         {13833} = 'Неверный указатель консультационных звонков';
  secInvalCountryCode               {13834} = 'Неверный код страны';
  secInvalDeviceClass               {13835} = 'Неверный класс устройства';
  secInvalDeviceHandle              {13836} = 'Неверный указатель устройства';
  secInvalDialParams                {13837} = 'Неверные параметры набора';
  secInvalDigitList                 {13838} = 'Неверный список цифр';
  secInvalDigitMode                 {13839} = 'Неверный цифровой режим';
  secInvalDigits                    {13840} = 'Неверные цифры';
  secInvalExtVersion                {13841} = 'Неверная версия EXT';
  secInvalGroupID                   {13842} = 'Неверный ID группы';
  secInvalLineHandle                {13843} = 'Неверный указатель линии';
  secInvalLineState                 {13844} = 'Неверное состояние линии';
  secInvalLocation                  {13845} = 'Неверное размещение';
  secInvalMediaList                 {13846} = 'Неверный список медиа';
  secInvalMediaMode                 {13847} = 'Неверный режим медиа';
  secInvalMessageID                 {13848} = 'Неверный ID сообщений';
  secInvalParam                     {13850} = 'Неверный параметр';
  secInvalParkID                    {13851} = 'Неверный ID парковки';
  secInvalParkMode                  {13852} = 'Неверный режим парковки';
  secInvalPointer                   {13853} = 'Неверный выделенный указатель';
  secInvalPrivSelect                {13854} = 'Неверный селектор привилегий';
  secInvalRate                      {13855} = 'Неверная скорость';
  secInvalRequestMode               {13856} = 'Неверный режим запроса';
  secInvalTerminalID                {13857} = 'Неверный ID терминала';
  secInvalTerminalMode              {13858} = 'Неверный режим терминала';
  secInvalTimeout                   {13859} = 'Неверный тайм аут';
  secInvalTone                      {13860} = 'Неверный тон';
  secInvalToneList                  {13861} = 'Неверный список тонов';
  secInvalToneMode                  {13862} = 'Неверный режим тона';
  secInvalTransferMode              {13863} = 'Неверный режим передачи';
  secLineMapperFailed               {13864} = 'Сбой маппера линии';
  secNoConference                   {13865} = 'Нет конференц-режима';
  secNoDevice                       {13866} = 'Нет устройства';
  secNoDriver                       {13867} = 'Нет драйвера';
  secNoMem                          {13868} = 'Не хватает памяти';
  secNoRequest                      {13869} = 'Нет запроса';
  secNotOwner                       {13870} = 'Нет владельца';
  secNotRegistered                  {13871} = 'Не зарегистрирован';
  secOperationFailed                {13872} = 'Сбой операции';
  secOperationUnavail               {13873} = 'Операция не доступна';
  secRateUnavail                    {13874} = 'Скорость не доступна';
  secResourceUnavail                {13875} = 'Ресурс не доступен';
  secRequestOverrun                 {13876} = 'Запрос overrun';
  secStructureTooSmall              {13877} = 'Структура слишком мала';
  secTargetNotFound                 {13878} = 'Цель не найдена';
  secTargetSelf                     {13879} = 'Цель - сама цель (SELF)';
  secUninitialized                  {13880} = 'Не инициализированно';
  secUserUserInfoTooBig             {13881} = 'Инфа о пользователе слишком большая';
  secReinit                         {13882} = 'Сбой Реинициализации';
  secAddressBlocked                 {13883} = 'Адрес блокирован';
  secBillingRejected                {13884} = 'Отказано в биллинге';
  secInvalFeature                   {13885} = 'Неверное свойство';
  secNoMultipleInstance             {13886} = 'Нет множественных итераций';

  {Apro encounters a few of its own TAPI errors, place these error
   codes after the native TAPI error codes, but leave a little bit
   of room for expansion of the TAPI error codes.}
  secTapiBusy                       {13928} = 'TAPI уже открыт на звонок или ответ';
  secTapiNotSet                     {13929} = 'TapiMode не установлен в TApdComPort';
  secTapiNoSelect                   {13930} = 'Не выбрано TAPI устройство';
  secTapiLoadFail                   {13931} = 'Сбой поска/загрузки TAPI.DLL';
  secTapiGetAddrFail                {13932} = 'Сбой в получении TAPI адреса';
  sTAPIdisabled16bit                {13933} = 'TAPI отключен для 16-битной среды';
  secTapiUnexpected                 {13934} = 'Неожиданная ошибка TAPI';
  secTapiVoiceNotSupported          {13935} = 'TAPI Устройство не поддерживает голосовых расширений';
  secTapiWaveFail                   {13936} = 'Сбой TAPI wave-фала с сообщением об ошибке ';
  secTapiCIDBlocked                 {13937} = 'ID Вызывающего блокирован';
  secTapiCIDOutOfArea               {13938} = 'Звонок за пределы региона';
  secTapiWaveFormatError            {13939} = 'Выбранный файл - не wave-файл';
  secTapiWaveReadError              {13940} = 'невозможно чтение данных из wave-файла';
  secTapiWaveBadFormat              {13941} = 'Неподдерживаемый wave-формат';
  secTapiTranslateFail              {13942} = 'Невозможно транслировать адрес';
  secTapiWaveDeviceInUse            {13943} = 'Wave-устройство занято';
  secTapiWaveFileExists             {13944} = 'Wave-файл уже существует';
  secTapiWaveNoData                 {13945} = 'Нет доступных Wave-данных';

  secVoIPNotSupported               {13950} = 'Голосовой IP не доступен (требуется Windows 2000 или выше)';
  secVoIPCallBusy                   {13951} = 'Удаленный был занят';
  secVoIPBadAddress                 {13952} = 'Неверный адрес назначения';
  secVoIPNoAnswer                   {13953} = 'Удаленный не ответил';
  secVoIPCancelled                  {13954} = 'Отменено';
  secVoIPRejected                   {13955} = 'Удаленный отверг звонок';
  secVoIPFailed                     {13956} = 'Общий сбой';
  secVoIPTapi3NotInstalled          {13957} = 'Сбой интерфейса ITTapi';
  secVoIPH323NotFound               {13958} = 'Линия H.323 не найдена';
  secVoIPTapi3EventFailure          {13959} = 'Сбой уведомления о событиях';

  {RAS error codes}
  secRasLoadFail                    {13980} = 'Ошибка поиска/загрузки RASAPI32.DLL';

  { Logging - It is unlikely that these should change, these strings are }
  { used in the dispatcher log.  Translating them into another language  }
  { could make it difficult for TurboPower Tech Support to decipher it.  }
  { Dispatch type. Instead of duplicating the strings in the different   }
  { language include files, we'll just include a common file here.       }
  {$I AdDispLog.inc}

  {XML strings}
  sIENotInstalled       = 'Cannot open WININET, Microsoft IE required';
  sOpenFileFailed       = 'Unable to open file ';
  sFileNotFound         = 'File %s could not be found';
  sAllocSrcMemFailed    = 'Unable to allocate memory for XML source';
  sHttpReadReqFailed    = 'Http read request failed';
  sHttpDataNotAvail     = 'Http data not available';
  sHttpReqSendFailed    = 'Unable to send http request';
  sHttpReqOpenFailed    = 'Unable to open http request';
  sInetConnectFailed    = 'Unable to make Internet connection';
  sInetOpenFailed       = 'Unable to open Internet';
  sInvalidFtpLoc        = 'Invalid ftp location';
  sInvalidFtpDir        = 'Invalid ftp directory';
  sFtpReadReqFailed     = 'Ftp read request failed';
  sFtpDataNotAvail      = 'Ftp data not available';
  sFtpOpenFileFailed    = 'Unable to open ftp file';
  sFtpPutFileFailed     = 'Could not save file via ftp to %s';
  sSrcLoadFailed        = 'Unable to load source ';
  sInvalidMemPtr        = 'Invalid memory Pointer';
  sFmtErrorMsg          = 'Line: %d Col: %d Error: %s';
  sIndexOutOfBounds     = 'ERROR INDEX OUT OF BOUNDS';
  sExpMarkupDecl        = 'Expected markup declaration, but found: ';
  sIllAttrType          = 'Illegal attribute type: ';
  sIllAttrDefKeyw       = 'Illegal keyword for attribute default value: ';
  sSysIdMissing         = 'System identifier missing ';
  sExtModifMissing      = 'External modifier missing: ';
  sIllCondSectStart     = 'Conditional section must begin with INCLUDE or IGNORE';
  sBadSepInModel        = 'Bad separator in content model: ';
  sExpCommentOrCDATA    = 'Expected comment or CDATA section ';
  sUnexpectedEof        = 'Unexpected end of file ';
  sMismatchEndTag       = 'Mismatched end tag: ';
  sIllCharInRef         = 'Illegal character in reference';
  sUndeclaredEntity     = 'Reference to undeclared entity: ';
  sExpectedString       = 'Expected String: ';
  sSpaceExpectedAt      = 'Whitespace expected at byte ';
  sUnexpEndOfInput      = 'End of input while looking for delimiter: ';
  sQuoteExpected        = 'Expected " or ' + Chr (39);
  sInvalidXMLVersion    = 'XMLPartner does not support XML specification greater than %s';
  sUnableCreateStr      = 'Unable to create stream for input.';
  sInvalidName          = 'Invalid XML name: ';
  sInvalidCommentText   = 'Invalid comment text';
  sCommentBeforeXMLDecl = 'Document cannot start with a comment if it also contains an XML declaration';
  sInvalidCDataSection  = 'Invalid characters in CDATA section';
  sRedefinedAttr        = 'Attributes cannot be redefined in a start tag';
  sCircularEntRef       = 'Circular reference to: ';
  sInvAttrChar          = 'Invalid character in attribute value: ';
  sInvPCData            = 'Invalid characters in element''s character data: ';
  sDataAfterValDoc      = 'There is invalid data after valid XML document';
  sNoIntConditional     = 'Conditional sections not allowed in internal subset of document type declaration';
  sNotationNotDeclared  = 'Notation not declared: ';
  sInvPubIDChar         = 'Invalid PublicID character: ';
  sNoNDATAInPeDecl      = 'NDATA not allowed in parameter entity declaration';
  sInvStandAloneVal     = 'Standalone value must equal ''yes'' or ''no''';
  sInvEncName           = 'Invalid encoding declaration: ';
  sInvVerNum            = 'Invalid XML version number: ';
  sInvEntityValue       = 'Invalid character in entity value: ';
  sNoCommentInMarkup    = 'Comments can not be placed within other markup';
  sNoPEInIntDTD         = 'Parameter entities not allowed in DTD internal subset';
  sXMLDecNotAtBeg       =  'The XML declaration must appear before the first element';
  sInvalidElementName   = 'Invalid element name: ';
  sBadParamEntNesting   = 'Parameter-entity text must be properly nested: ';
  sInvalidCharEncoding  = 'Invalid character encoding specified.';
  sAttrNotNum           = 'Attribute %s of element %s does not have an integer value.';
  sUnknownAxis          = 'Unknown axis specifier: %s';

  {xpchrstm related errors}
  sInvalidXMLChar       = 'Invalid XML Character found';
  sInvalidBEChar        = 'Invalid (big-endian) UTF-16 character encoding';
  sInvalidLEChar        = 'Invalid (little-endian) UTF-16 character encoding';
  sBadUTF8Char          = 'Badly formed UTF-8 character in stream';
  sErrEndOfDocument     = 'Unexpected end of document stream';
  sUCS_ISOConvertErr    = 'Cannot convert UCS-4 character to ISO-8859-1';
  sUCS_U16ConvertErr    = 'Cannot convert UCS-4 character to UTF-16';
  sUCS_U8ConverErr      = 'Cannot convert UCS-4 character to UTF-8';

  {EModem error string resource}
  sModemDetectedBusy    = 'Линия занята';
  sModemNoDialtone      = 'Нет гудка в линии';
  sModemNoCarrier       = 'No Carrier';

  {TApdPager string resource}
  sInitFail             = 'Modem Initialization Failure';
  sLoginFail            = 'Failed to Login';
  sMinorSrvErr          = 'Minor Server Error';
  sFatalSrvErr          = 'Fatal Server Error';
  sConnected            = 'Modem Connected';
  sCancelled            = 'Cancel Requested';
  sLineBusy             = 'Line Busy';
  sDisconnect           = 'Disconnecing';
  sNoDialtone           = 'No Dialtone';
  sMsgNotSent           = 'Message not sent';
  sWaitingToRedial      = 'Waiting to Redial';
  sLoginPrompt          = 'Received Prompt for Login';
  sLoggedIn             = 'Successful Login';
  sDialing              = 'Now Dialing';
  sRedialing            = 'Now Redialing';
  sLoginRetry           = 'Retry Password for Login';
  sMsgOkToSend          = 'Ready to Send Message';
  sSendingMsg           = 'Now sending Message';
  sMsgAck               = 'Received, Send next block or end';
  sMsgNak               = 'Received Error, Resend Message';
  sMsgRs                = 'Unable to Send Page';
  sMsgCompleted         = 'Page Complete - Logging out if done';
  sSendTimedOut         = 'Timed Out - No Response';
  sLoggingOut           = 'Logging Out';
  sDone                 = 'Done with Page'; 

  {TApdVoIP error string resource}
  sVoIPNotAvailable     = 'Voice over IP not available (requires Windows 2000 and above)';

  {TFaxLogCode description strings, used by TApdAbstractFax.LogMsg method}
  slfaxNone             = 'none';
  slfaxTransmitStart    = 'transmit started';
  slfaxTransmitOk       = 'transmit finished okay';
  slfaxTransmitFail     = 'transmit failed';
  slfaxReceiveStart     = 'receive started';
  slfaxReceiveOk        = 'receive finished okay';
  slfaxReceiveSkip      = 'receive skipped on request';
  slfaxReceiveFail      = 'receive failed';


