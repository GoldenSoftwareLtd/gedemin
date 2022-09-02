// ShlTanya, 29.01.2019

unit dlgChooseGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Db, IBCustomDataSet, ComCtrls, gsDBTreeView, StdCtrls, ActnList,
  ImgList, Ibdatabase, dmDatabase_unit;

type
  TdlgChooseGroup = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ibdsGroup: TIBDataSet;
    dsGroup: TDataSource;
    gsdbtvGroup: TgsDBTreeView;
    btnOk: TButton;
    btnCancel: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    ilGoodGroup: TImageList;
    procedure actOkUpdate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure gsdbtvGroupGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure gsdbtvGroupGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
  private
    function GetGroupKey: TID;
    function GetGroupName: String;
    function GetGroupLB: TID;
    function GetGroupRB: TID;
    { Private declarations }
  public
    { Public declarations }
    property GroupKey: TID read GetGroupKey;
    property GroupRB: TID read GetGroupRB;
    property GroupLB: TID read GetGroupLB;
    property GroupName: String read GetGroupName;
    function ActiveDialog(aIBTransaction: TIBTransaction): boolean;
  end;

var
  dlgChooseGroup: TdlgChooseGroup;

implementation

{$R *.DFM}

{ TdlgChooseGroup }

function TdlgChooseGroup.GetGroupKey: TID;
begin
  if gsdbtvGroup.Selected <> nil then
    Result := gsdbtvGroup.ID
  else
    Result := -1;
end;

procedure TdlgChooseGroup.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := gsdbtvGroup.Selected <> nil;
end;

procedure TdlgChooseGroup.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOK;
end;

function TdlgChooseGroup.ActiveDialog(aIBTransaction: TIBTransaction): boolean;
begin
  ibdsGroup.Transaction := aIBTransaction;
  ibdsGroup.Open;
  Result := ShowModal = mrOk;
end;

procedure TdlgChooseGroup.gsdbtvGroupGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Expanded then
    Node.ImageIndex := 1
  else
    Node.ImageIndex := 0;

end;

procedure TdlgChooseGroup.gsdbtvGroupGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Expanded then
    Node.SelectedIndex := 1
  else
    Node.SelectedIndex := 0;
end;

function TdlgChooseGroup.GetGroupName: String;
begin
  if gsdbtvGroup.Selected <> nil then
    Result := gsdbtvGroup.Selected.Text
  else
    Result := '';
end;

function TdlgChooseGroup.GetGroupLB: TID;
begin
  if gsdbtvGroup.Selected <> nil  then
    Result := GetTID(ibdsGroup.FieldByName('lb'))
  else
    Result := 0;
end;

function TdlgChooseGroup.GetGroupRB: TID;
begin
  if gsdbtvGroup.Selected <> nil then
    Result := GetTID(ibdsGroup.FieldByName('rb'))
  else
    Result := 0;
end;

end.
