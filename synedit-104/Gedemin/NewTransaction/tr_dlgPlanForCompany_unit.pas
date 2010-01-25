unit tr_dlgPlanForCompany_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls, IBDatabase, Db,
  IBCustomDataSet, dmDatabase_unit, ActnList, IBSQL;

type
  TdlgPlanForCompany = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    gsibgrOurCompany: TgsIBGrid;
    ibdsOurCompany: TIBDataSet;
    IBTransaction: TIBTransaction;
    dsOurCompany: TDataSource;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Splitter2: TSplitter;
    Label2: TLabel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    gsibCardCompany: TgsIBGrid;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ibdsListCard: TIBDataSet;
    dsListCard: TDataSource;
    ibdsCardCompany: TIBDataSet;
    dsCardCompany: TDataSource;
    gsibgrListCard: TgsIBGrid;
    ibdsCardCompanyALIAS: TIBStringField;
    ibdsCardCompanyNAME: TIBStringField;
    ibdsCardCompanyCARDACCOUNTKEY: TIntegerField;
    ibdsCardCompanyACTIVECARD: TSmallintField;
    ibdsListCardID: TIntegerField;
    ibdsListCardPARENT: TIntegerField;
    ibdsListCardLB: TIntegerField;
    ibdsListCardRB: TIntegerField;
    ibdsListCardNAME: TIBStringField;
    ibdsListCardALIAS: TIBStringField;
    ibdsListCardTYPEACCOUNT: TIntegerField;
    ibdsListCardGRADE: TIntegerField;
    ibdsListCardACTIVECARD: TSmallintField;
    ibdsListCardMULTYCURR: TSmallintField;
    ibdsListCardOFFBALANCE: TSmallintField;
    ibdsListCardMAINANALYZE: TIntegerField;
    ibdsListCardDISABLED: TSmallintField;
    ibdsListCardAFULL: TIntegerField;
    ibdsListCardACHAG: TIntegerField;
    ibdsListCardAVIEW: TIntegerField;
    ibdsListCardRESERVED: TIntegerField;
    ibdsOurCompanyFULLNAME: TIBStringField;
    ibdsOurCompanyCOMPANYKEY: TIntegerField;
    bHelp: TButton;
    Panel8: TPanel;
    bOk: TButton;
    bCancel: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actHelp: TAction;
    actAddOne: TAction;
    actAddAll: TAction;
    actDelOne: TAction;
    actDelAll: TAction;
    ibsqlAddToOurCompany: TIBSQL;
    ibdsCardCompanyOURCOMPANYKEY: TIntegerField;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actAddOneExecute(Sender: TObject);
    procedure actAddOneUpdate(Sender: TObject);
    procedure actDelOneUpdate(Sender: TObject);
    procedure actAddAllExecute(Sender: TObject);
    procedure actDelOneExecute(Sender: TObject);
    procedure actDelAllExecute(Sender: TObject);
    procedure ibdsOurCompanyAfterScroll(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ibdsCardCompanyACTIVECARDGetText(Sender: TField;
      var Text: String; DisplayText: Boolean);
    procedure gsibCardCompanyDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure AddOneCard;
    procedure RefreshListCard;
    procedure RefreshCardCompany;
    function Save: Boolean;
    procedure Cancel;
  public
    { Public declarations }
    procedure SetupDialog;
  end;

var
  dlgPlanForCompany: TdlgPlanForCompany;

implementation

{$R *.DFM}

procedure TdlgPlanForCompany.actOkExecute(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

procedure TdlgPlanForCompany.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgPlanForCompany.actAddOneExecute(Sender: TObject);
begin
  {  Перенос текущего плана счетов в список планов для организации }
  AddOneCard;
  RefreshListCard;
end;

procedure TdlgPlanForCompany.actAddOneUpdate(Sender: TObject);
begin
  actAddOne.Enabled := ibdsListCard.FieldByName('ID').AsInteger > 0;
  actAddAll.Enabled := ibdsListCard.FieldByName('ID').AsInteger > 0;
end;

procedure TdlgPlanForCompany.actDelOneUpdate(Sender: TObject);
begin
  actDelOne.Enabled := ibdsCardCompany.FieldByName('cardaccountkey').AsInteger > 0;
  actDelAll.Enabled := ibdsCardCompany.FieldByName('cardaccountkey').AsInteger > 0;
end;

procedure TdlgPlanForCompany.AddOneCard;
begin
  ibsqlAddToOurCompany.Prepare;
  ibsqlAddToOurCompany.ParamByName('cak').AsInteger :=
    ibdsListCard.FieldByName('id').AsInteger;
  ibsqlAddToOurCompany.ParamByName('ck').AsInteger :=
    ibdsOurCompany.FieldByName('companykey').AsInteger;
  ibsqlAddToOurCompany.ParamByName('ac').AsInteger :=
    Integer(ibdsCardCompany.RecordCount = 0);
  ibsqlAddToOurCompany.ExecQuery;
  ibsqlAddToOurCompany.Close;
  ibdsCardCompany.Close;
  ibdsCardCompany.Open;
end;

procedure TdlgPlanForCompany.RefreshListCard;
begin
  ibdsListCard.Close;
  ibdsListCard.ParamByName('oc').AsInteger :=
    ibdsOurCompany.FieldByName('companykey').AsInteger;
  ibdsListCard.Open;
end;

procedure TdlgPlanForCompany.actAddAllExecute(Sender: TObject);
begin
{ Перенос всех планов для текущей организации }
  ibdsListCard.DisableControls;
  try
    ibdsListCard.First;
    while not ibdsListCard.EOF do
    begin
      AddOneCard;
      ibdsListCard.Next;
    end;
  finally
    RefreshListCard;
    ibdsListCard.EnableControls;
  end;
end;

procedure TdlgPlanForCompany.actDelOneExecute(Sender: TObject);
var
  isActive: Boolean;
begin
  { Удаление одного плана из доступных для текущей организации }
  isActive := ibdsCardCompany.FieldByName('activecard').AsInteger = 1;
  ibdsCardCompany.Delete;
  if isActive and (ibdsCardCompany.FieldByName('cardaccountkey').AsInteger > 0) then
  begin
    if not (ibdsCardCompany.State in [dsEdit, dsInsert]) then
      ibdsCardCompany.Edit;

    ibdsCardCompany.FieldByName('activecard').AsInteger := 1;
    ibdsCardCompany.Post;
  end;
  RefreshListCard;
end;

procedure TdlgPlanForCompany.actDelAllExecute(Sender: TObject);
begin
  ibdsCardCompany.DisableControls;
  try
    ibdsCardCompany.First;
    while not ibdsCardCompany.EOF do ibdsCardCompany.Delete;
  finally
    ibdsCardCompany.EnableControls;
  end;
  RefreshListCard;
end;

procedure TdlgPlanForCompany.RefreshCardCompany;
begin
  ibdsCardCompany.Close;
  ibdsCardCompany.Prepare;
  ibdsCardCompany.ParamByName('ock').AsInteger :=
    ibdsOurCompany.FieldByName('companykey').AsInteger;
  ibdsCardCompany.Open;  
end;

procedure TdlgPlanForCompany.ibdsOurCompanyAfterScroll(DataSet: TDataSet);
begin
  RefreshListCard;
  RefreshCardCompany;
end;

function TdlgPlanForCompany.Save: Boolean;
begin
  Result := True;
  try
    if IBTransaction.InTransaction then
      IBTransaction.Commit;
  except
    Result := False;
  end
end;

procedure TdlgPlanForCompany.Cancel;
begin
  try
    if IBTransaction.InTransaction then
      IBTransaction.RollBack;
  except
  end;   
end;

procedure TdlgPlanForCompany.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
    Cancel;
end;

procedure TdlgPlanForCompany.SetupDialog;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  ibdsOurCompany.Open;
{  RefreshListCard;
  RefreshCardCompany;}  
end;

procedure TdlgPlanForCompany.ibdsCardCompanyACTIVECARDGetText(
  Sender: TField; var Text: String; DisplayText: Boolean);
begin
  if Sender.AsInteger = 1 then
    Text := 'Да'
  else
    Text := 'Нет';  
end;

procedure TdlgPlanForCompany.gsibCardCompanyDblClick(Sender: TObject);
var
  ibsql: TIBSQL;
  Bookmark: TBookmark;
begin
  if ibdsCardCompany.FieldByName('activecard').AsInteger = 0 then
  begin
    if (ibdsCardCompany.State in [dsEdit, dsInsert]) then
      ibdsCardCompany.Post;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text := 'UPDATE gd_cardcompany SET activecard = 0 WHERE ourcompanykey = :ck';
      ibsql.Prepare;
      ibsql.ParamByName('ck').AsInteger := ibdsOurCompany.FieldByName('companykey').AsInteger;
      ibsql.ExecQuery;
    finally
      ibsql.Free;
    end;
    
    Bookmark := ibdsCardCompany.GetBookmark;
    try
      ibdsCardCompany.Edit;
      ibdsCardCompany.FieldByName('activecard').AsInteger := 1;
      ibdsCardCompany.Post;

      ibdsCardCompany.Close;
      ibdsCardCompany.Open;
    finally
      ibdsCardCompany.GotoBookmark(Bookmark);
      ibdsCardCompany.FreeBookmark(Bookmark);
    end;
  end;
end;

end.

