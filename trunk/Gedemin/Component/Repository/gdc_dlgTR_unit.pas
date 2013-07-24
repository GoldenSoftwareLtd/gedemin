
unit gdc_dlgTR_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, IBDatabase, Db, ActnList, StdCtrls, dmDatabase_unit,
  gdc_frmMDH_unit, Menus;

type
  Tgdc_dlgTR = class(Tgdc_dlgG)
    ibtrCommon: TIBTransaction;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  protected
    procedure SetupTransaction; override;
    procedure DoDestroy; override;

  public
    constructor Create(AnOwner: TComponent); override;
  end;

var
  gdc_dlgTR: Tgdc_dlgTR;

implementation

{$R *.DFM}

uses
  IBCustomDataset, gd_ClassList;

procedure Tgdc_dlgTR.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;

  if ibtrCommon.InTransaction then
    ibtrCommon.Commit;
end;

procedure Tgdc_dlgTR.FormActivate(Sender: TObject);
begin
  inherited;

{ TODO :
с использованием методов Активэйт могут быть проблемы
так как колина компонента их постоянно вызывает }

  if (ibtrCommon.SQLObjectCount > 0) and (not ibtrCommon.InTransaction) then
    ibtrCommon.StartTransaction;
end;

procedure Tgdc_dlgTR.SetupTransaction;
begin
  // присваивание базы данных должно предворять присваивание
  // датасета в датасоурс, потому что при последнем будет
  // вызвана синхронизация лукапа, а тот в свою очередь
  // обратится к транзакции, а у нее нет датабэйза :(
  ibtrCommon.DefaultDatabase := gdcObject.Database;
end;

procedure Tgdc_dlgTR.FormCreate(Sender: TObject);
begin
  if ibtrCommon.DefaultDatabase = nil then
    ibtrCommon.DefaultDatabase := dmDatabase.ibdbGAdmin;

  inherited;
end;

constructor Tgdc_dlgTR.Create(AnOwner: TComponent);
begin
  inherited;
end;

procedure Tgdc_dlgTR.DoDestroy;
begin
  inherited;

  try
    if ibtrCommon.InTransaction then
      ibtrCommon.Commit;
  except
    Application.HandleException(Self);
  end;
end;

procedure Tgdc_dlgTR.FormDestroy(Sender: TObject);
begin
  inherited;
  //...
end;

initialization
  RegisterFrmClass(Tgdc_dlgTR);

finalization
  UnRegisterFrmClass(Tgdc_dlgTR);

end.
