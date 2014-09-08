
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmInvPriceList_unit.pas

  Abstract

    Part of a business class. Price List document.

  Author

    Romanovski Denis (23-10-2001)

  Revisions history

    Initial  23-10-2001  Dennis  Initial version.

--}

unit gdc_frmInvPriceList_unit;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmMDHGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid,
  gsIBGrid, ToolWin, ComCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  gdcInvPriceList_unit, IBCustomDataSet, gdcBase, gdcClasses, gdcTree,
  gd_MacrosMenu, StdCtrls, gsDesktopManager;

type
  Tgdc_frmInvPriceList = class(Tgdc_frmMDHGR)
    gdcInvPriceList: TgdcInvPriceList;
    gdcInvPriceListLine: TgdcInvPriceListLine;
    procedure FormCreate(Sender: TObject);
  private


  public
    constructor Create(AnOwner: TComponent); override;
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    class procedure RegisterClassHierarchy; override;

    procedure SaveDesktopSettings; override;
  end;

var
  gdc_frmInvPriceList: Tgdc_frmInvPriceList;

implementation

{$R *.DFM}

uses
  gd_ClassList, Storages, IBSQL, gdcBaseInterface;

{ Tgdc_frmMDHGR1 }

constructor Tgdc_frmInvPriceList.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
end;

class function Tgdc_frmInvPriceList.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  Result := nil;
end;

procedure Tgdc_frmInvPriceList.FormCreate(Sender: TObject);
begin
  gdcObject := gdcInvPriceList;
  gdcDetailObject := gdcInvPriceListLine;

  gdcInvPriceList.SubType := FSubType;  
  gdcInvPriceListLine.SubType := FSubType;

  inherited;

  Caption := gdcInvPriceList.DocumentName[True];
end;

class procedure Tgdc_frmInvPriceList.RegisterClassHierarchy;

  procedure ReadFromDocumentType(ACE: TgdClassEntry);
  var
    CurrCE: TgdClassEntry;
    ibsql: TIBSQL;
    LSubType: string;
    LComment: String;
    LParentSubType: string;
  begin
    if ACE.Initialized then
      exit;

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text :=
        'SELECT '#13#10 +
        '  dt.name AS comment, '#13#10 +
        '  dt.classname AS classname, '#13#10 +
        '  dt.ruid AS subtype, '#13#10 +
        '  dt1.ruid AS parentsubtype '#13#10 +
        'FROM gd_documenttype dt '#13#10 +
        'LEFT JOIN gd_documenttype dt1 '#13#10 +
        '  ON dt1.id = dt.parent '#13#10 +
        '  AND dt1.documenttype = ''D'' '#13#10 +
        'WHERE '#13#10 +
        '  dt.documenttype = ''D'' '#13#10 +
        '  and dt.classname = ''TgdcInvPriceListType'' '#13#10 +  
        'ORDER BY dt.parent';

      ibsql.ExecQuery;

      while not ibsql.EOF do
      begin
        LSubType := ibsql.FieldByName('subtype').AsString;
        LComment := ibsql.FieldByName('comment').AsString;
        LParentSubType := ibsql.FieldByName('parentsubtype').AsString;

        CurrCE := gdClassList.Add(ACE.TheClass, LSubType, LComment, LParentSubType);

        CurrCE.Initialized := True;
        ibsql.Next;
      end;
    finally
      ibsql.Free;
    end;

    ACE.Initialized := True;
  end;

var
  CEBase: TgdClassEntry;

begin
  CEBase := gdClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromDocumentType(CEBase);
end;

procedure Tgdc_frmInvPriceList.SaveDesktopSettings;
begin
  inherited;
  if Assigned(DesktopManager) then
    DesktopManager.SaveDesktopItem(Self);

end;

initialization
  RegisterFrmClass(Tgdc_frmInvPriceList);

finalization
  UnRegisterFrmClass(Tgdc_frmInvPriceList);

end.
 
