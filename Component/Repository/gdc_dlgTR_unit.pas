
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
� �������������� ������� �������� ����� ���� ��������
��� ��� ������ ���������� �� ��������� �������� }

  if (ibtrCommon.SQLObjectCount > 0) and (not ibtrCommon.InTransaction) then
    ibtrCommon.StartTransaction;
end;

procedure Tgdc_dlgTR.SetupTransaction;
{var
  I: Integer;
  L: TList;}
begin
  //inherited;

  // ������������ ���� ������ ������ ���������� ������������
  // �������� � ���������, ������ ��� ��� ��������� �����
  // ������� ������������� ������, � ��� � ���� �������
  // ��������� � ����������, � � ��� ��� ��������� :(
  ibtrCommon.DefaultDatabase := gdcObject.Database;

  // � ������ �������������� ����� � � ������
  // ���������� ����� ���� ������ ��������, ����
  // � ����������
  {for I := 0 to ComponentCount - 1 do
    if Components[I].ClassNameIs('TIBDataSet') then
    begin
      if (Components[I] as TIBCustomDataSet).Transaction <> ibtrCommon then
      begin
        (Components[I] as TIBCustomDataSet).Active := False;
        (Components[I] as TIBCustomDataSet).DataBase := gdcObject.DataBase;
        (Components[I] as TIBCustomDataSet).Transaction := gdcObject.Transaction;
      end;
    end;}

  //
  {if FIsTransaction then
  begin
    L := TList.Create;
    try
      for I := 0 to ibtrCommon.SQLObjectCount - 1 do
      begin
        L.Add(ibtrCommon.SQLObjects[I]);
      end;

      for I := 0 to L.Count - 1 do
      begin
        TIBBase(L[I]).Transaction := gdcObject.Transaction;
      end;
    finally
      L.Free;
    end;
  end;}
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
