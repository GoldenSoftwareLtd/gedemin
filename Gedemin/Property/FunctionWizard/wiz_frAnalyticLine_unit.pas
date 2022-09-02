// ShlTanya, 09.03.2019

unit wiz_frAnalyticLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, BtnEdit, at_Classes, wiz_FunctionBlock_unit, Menus, wiz_DocumentInfo_unit,
  gdc_frmAnalyticsSel_unit, ExtCtrls, gdcBaseInterface;

type
  TfrAnalyticLine = class(TFrame)
    lName: TLabel;
    eAnalytic: TBtnEdit;
    PopupMenu: TPopupMenu;
    Bevel1: TBevel;
    procedure eAnalyticBtnOnClick(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure eAnalyticChange(Sender: TObject);
  private
    FField: TatRelationField;
    FBlock: TVisualBlock;
    FAnalyticKey: TID;
    FActiveEdit: TEditSButton;
    procedure SetField(const Value: TatRelationField);
    procedure SetBlock(const Value: TVisualBlock);
    procedure ClickAnalytics(Sender: TObject);
    procedure ClickDocumentField(Sender: TObject);
    procedure SetAnalyticKey(const Value: TID);
    procedure ClickExpression(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    property Field: TatRelationField read FField write SetField;
    property Block: TVisualBlock read FBlock write SetBlock;
    property AnalyticKey: TID read FAnalyticKey write SetAnalyticKey;
  end;

implementation

{$R *.DFM}

{ TfrAnalyticLine }

procedure TfrAnalyticLine.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
end;

procedure TfrAnalyticLine.SetField(const Value: TatRelationField);
begin
  FField := Value;
  if FField <> nil then
  begin
    lName.Caption := FField.LName + ':'; 
  end;
end;

procedure TfrAnalyticLine.eAnalyticBtnOnClick(Sender: TObject);
var
  Point: TPoint;
begin
  if FField <> nil then
  begin
    if FField.ReferencesField <> nil then
    begin
      if Sender is TEditSButton then
      begin
        Point.x := 0;
        Point.y := TEditSButton(Sender).Height - 1;
        Point := TEditSButton(Sender).ClientToScreen(Point);
        FActiveEdit := TEditSButton(Sender);
        PopupMenu.Popup(Point.X, Point.Y);
      end;
    end else
    begin
      if FBlock <> nil then
      begin
        eAnalytic.Text := FBlock.EditExpression(eAnalytic.Text, FBlock);
        FAnalyticKey := 0;
      end;  
    end
  end;
end;

procedure TfrAnalyticLine.PopupMenuPopup(Sender: TObject);
var
  MI: TMenuItem;
  List: Tlist;
  I: Integer;
begin
  PopupMenu.Items.Clear;

  if (FField <> nil) then
  begin
    if (FField.References <> nil) and (FBlock <> nil) then
    begin
      MI := TmenuItem.Create(PopupMenu);
      MI.Caption := 'Выражение...';
      MI.OnClick := ClickExpression;
      PopupMenu.Items.Add(MI);
    end;

    if (FField.References <> nil) then
    begin
      MI := TmenuItem.Create(PopupMenu);
      MI.Caption := 'Аналитика...';
      MI.OnClick := ClickAnalytics;
      PopupMenu.Items.Add(MI);
    end;

    if (MainFunction <> nil) and (MainFunction is TTrEntryFunctionBlock) then
    begin
      with MainFunction as TTrEntryFunctionBlock do
      begin
        List := TList.Create;
        try
          if DocumentHead <> nil then
          begin
            if (FField.References <> nil) then
              DocumentHead.ForeignFields(FField.References.RelationName, List)
          end;
          if DocumentLine <> nil then
          begin
            if (FField.References <> nil) then
              DocumentLine.ForeignFields(FField.References.RelationName, List)
          end;

          if List.Count >0 then
          begin
            MI := TmenuItem.Create(Self.PopupMenu);
            MI.Caption := '-';
            Self.PopupMenu.Items.Add(MI);

            for I := 0 to List.Count - 1 do
            begin
              MI := TmenuItem.Create(Self.PopupMenu);
              MI.Caption := TDocumentField(List[I]).DisplayName;
              MI.OnClick := ClickDocumentField;
              MI.Tag := Integer(List[I]);
              Self.PopupMenu.Items.Add(MI);
            end;
          end;
        finally
          List.Free;
        end;
      end;
    end;
  end;
end;

procedure TfrAnalyticLine.ClickAnalytics(Sender: TObject);
var
  D: TfrmAnalyticSel;
begin
  if FField <> nil then
  begin
    D := TfrmAnalyticSel.Create(nil);
    try
      D.DataField := FField;

      if D.ShowModal = mrOk then
      begin
        eAnalytic.Text := D.AnalyticAlias;
        FAnalyticKey := D.AnalyticsKey;
      end;
    finally
      D.Free;
    end;
  end;
end;

procedure TfrAnalyticLine.SetAnalyticKey(const Value: TID);
begin
  FAnalyticKey := Value;
end;

procedure TfrAnalyticLine.eAnalyticChange(Sender: TObject);
begin
  FAnalyticKey := 0;
end;

procedure TfrAnalyticLine.ClickDocumentField(Sender: TObject);
begin
  eAnalytic.Text := TDocumentField(TMenuItem(Sender).Tag).Script;
  FAnalyticKey := 0;
end;

procedure TfrAnalyticLine.ClickExpression(Sender: TObject);
begin
  if FBlock <> nil then
    FActiveEdit.Edit.Text := FBlock.EditExpression(FActiveEdit.Edit.Text, FBlock);
end;

end.
