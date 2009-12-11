unit gdc_frmMainGood_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security, Menus, StdCtrls, ExtCtrls, ActnList, ComCtrls, Db,
  IBCustomDataSet, IBQuery, ImgList, Grids, DBGrids, IBUpdateSQL,
  ToolWin, flt_sqlFilter, gsDBGrid, gsIBGrid, IBDatabase,
  gsDBTreeView, IBSQL,  gd_Createable_Form,
  at_sql_setup, gsReportRegistry, dmDatabase_unit, gsDBReduction,
  gsReportManager, gdc_frmMDVTree_unit, gdcGood, gdcBase,
  gdcConst, TB2Item, TB2Dock, TB2Toolbar, gdcTree, gd_MacrosMenu
  {$IFDEF INDY}, idtcpclient, idGlobal, gsTCPCommunicationHelper, at_frmSQLProcess{$ENDIF INDY};

type
{$IFDEF INDY}
    TClientHandleThread = class(TThread)
    private
      FReceivedTCPCommand: TgsTCPCommand;
      procedure HandleInput;
    protected
      procedure Execute; override;
    public
       Client: TIdTCPClient;
    end;
{$ENDIF INDY}

  Tgdc_frmMainGood = class(Tgdc_frmMDVTree)
    gdcGoodGroup: TgdcGoodGroup;
    gdcGood: TgdcGood;
    tbsiNew: TTBSubmenuItem;
    tbiSubNew: TTBItem;
    actNewSub: TAction;
    tblMenuNew: TTBItem;
    TBItem1: TTBItem;
    actSendToServer: TAction;
    eServerAddress: TEdit;
    TBControlItem1: TTBControlItem;
    TBItem2: TTBItem;
    actConnectToServer: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actNewSubExecute(Sender: TObject);
    procedure actSendToServerExecute(Sender: TObject);
    procedure actConnectToServerExecute(Sender: TObject);

  {$IFDEF INDY}
  private
    FTCPClient: TidTCPClient;
    FClientHandleThread: TClientHandleThread;
  {$ENDIF INDY}
  protected
    procedure RemoveSubSetList(S:TStrings); override;

  public
    class function CreateAndAssign(
      AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmMainGood: Tgdc_frmMainGood;

implementation

{$R *.DFM}

uses
  gd_ClassList;

class function Tgdc_frmMainGood.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmMainGood) then
    gdc_frmMainGood := Tgdc_frmMainGood.Create(AnOwner);
  Result := gdc_frmMainGood
end;

procedure Tgdc_frmMainGood.FormCreate(Sender: TObject);
begin
  gdcObject := gdcGoodGroup;
  gdcDetailObject := gdcGood;

  inherited;
end;

procedure Tgdc_frmMainGood.actNewSubExecute(Sender: TObject);
begin
  gdcGoodGroup.CreateChildrenDialog;
end;

procedure Tgdc_frmMainGood.RemoveSubSetList(S: TStrings);
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_MDH_REMOVESUBSETLIST('TGDC_FRMMAINGOOD', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_FRMMAINGOOD', KEYREMOVESUBSETLIST);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYREMOVESUBSETLIST]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_FRMMAINGOOD') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self), GetGdcInterface(S)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_FRMMAINGOOD',
  {M}        'REMOVESUBSETLIST', KEYREMOVESUBSETLIST, Params, LResult) then exit;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_FRMMAINGOOD' then
  {M}      begin
  {M}        Inherited;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  inherited;
  S.Add('byGroup');
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_FRMMAINGOOD', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_FRMMAINGOOD', 'REMOVESUBSETLIST', KEYREMOVESUBSETLIST);
  {M}end;
  {END MACRO}
end;

{$IFDEF INDY}
{ TClientHandleThread }
procedure TClientHandleThread.Execute;
begin
  while not Terminated do
  begin
    if not Client.Connected then
      Terminate
    else
      try
        Client.ReadBuffer(FReceivedTCPCommand, SizeOf(TgsTCPCommand));
        Synchronize(HandleInput);
      except
      end;
  end;
end;

procedure TClientHandleThread.HandleInput;
begin
  if FReceivedTCPCommand.Command = 'GOOD_INSERTED' then
  begin
    AddText('Товар передан успешно');
  end
  else if FReceivedTCPCommand.Command = 'GOOD_NOT_INSERTED' then
  begin
    AddText('Произошла ошибка при передаче товара');
  end;
end;
{$ENDIF INDY}

procedure Tgdc_frmMainGood.actSendToServerExecute(Sender: TObject);
{$IFDEF INDY}
var
  SentTCPCommand: TgsTCPCommand;
  BookmarkList: TBookmarkList;
  I: Integer;
{$ENDIF INDY}
begin
{$IFDEF INDY}

  BookmarkList := ibgrDetail.SelectedRows;
  SentTCPCommand.Command := 'INSERT_GOOD';
  for I := 0 to BookmarkList.Count - 1 do
  begin
    gdcGood.Bookmark := BookmarkList.Items[I];
    SentTCPCommand.Value := gdcGood.FieldByName('NAME').AsString;
    FTCPClient.WriteBuffer(SentTCPCommand, SizeOf(TgsTCPCommand), True);
  end;
{$ENDIF INDY}
end;

procedure Tgdc_frmMainGood.actConnectToServerExecute(Sender: TObject);
{$IFDEF INDY}
var
  IPText, IPPort: String;
{$ENDIF INDY}
begin
{$IFDEF INDY}
  if not Assigned(FTCPClient) then
  begin
    IPText := TgsTCPCommunicationHelper.GetIPFromString(eServerAddress.Text);
    IPPort := TgsTCPCommunicationHelper.GetPortFromString(eServerAddress.Text);
    if IPPort = '' then
      IPPort := '9099';

    FTCPClient := TidTCPClient.Create(Self);
    FTCPClient.Host := IPText;
    FTCPClient.Port := StrToInt(IPPort);
    FTCPClient.Connect;

    FClientHandleThread := TClientHandleThread.Create(True);
    FClientHandleThread.FreeOnTerminate := True;
    FClientHandleThread.Client := FTCPClient;
    FClientHandleThread.Resume;

    AddText('Подключен к серверу');
  end
  else
  begin
     // Остановим нить и закроем коннект
    FClientHandleThread.Terminate;
    FTCPClient.Disconnect;

    FreeAndNil(FClientHandleThread);
    FreeAndNil(FTCPClient);

    AddText('Отключен от сервера');
  end;
{$ENDIF INDY}  
end;

initialization
  RegisterFrmClass(Tgdc_frmMainGood);
  //RegisterClass(Tgdc_frmMainGood);
finalization
  UnRegisterFrmClass(Tgdc_frmMainGood);

end.

