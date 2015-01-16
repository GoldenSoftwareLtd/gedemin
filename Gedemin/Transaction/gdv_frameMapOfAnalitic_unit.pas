unit gdv_frameMapOfAnalitic_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, at_classes, Db, Mask, DBCtrls, ExtCtrls,
  contnrs, ActnList, Buttons, gdcBaseInterface;

type
  TAnalyticFieldType = (aftReference, aftString);

  TframeMapOfAnaliticLine = class(TFrame)
    lAnaliticName: TLabel;
    eAnalitic: TEdit;
    cbInputParam: TCheckBox;
    procedure eAnaliticChange(Sender: TObject);
  private
    FButtons, FLookUp: TObjectList;
    FField: TatRelationField;

    FActionList: TActionList;
    FactVisible: TAction;

    procedure SetField(const Value: TatRelationField);
    procedure SetValue(const Value: String);
    function GetValue: String;
    function CreateLookUp: TgsIBLookupComboBox;
    function CreateButton: TSpeedButton;
    procedure BtnPress(Sender: TObject);
    procedure OnVisibleUpdate(Sender: TObject);
    function FieldType: TAnalyticFieldType;
    procedure LookUpChange(Sender: TObject);
    function GetCount: Integer;
    
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ReSizeControls;
    procedure Clear;
    
    property Field: TatRelationField read FField write SetField;
    property Value: String read GetValue write SetValue;
    property Count: Integer read GetCount;
  end;

implementation

uses dmDataBase_unit;

{$R *.DFM}

const
  FrameHeight = 22;
  FrameWidth =  496;
  ButtonHeight = 18;
  ButtonWidth = 14;

{ TframeMapOfAnaliticLine }

constructor TframeMapOfAnaliticLine.Create(AOwner: TComponent);
begin
  inherited;

  FButtons := TObjectList.Create;
  FLookUp := TObjectList.Create;
  Height := FrameHeight;
  Width := FrameWidth;
  Width := FrameWidth;

  if not (csDesigning in ComponentState) then
  begin
    FActionList := TActionList.Create(nil);
    FActionList.Name := 'al' + Self.Name;

    FactVisible := TAction.Create(FActionList);
    FactVisible.ActionList := FActionList;
    FactVisible.OnUpdate := OnVisibleUpdate;
    FactVisible.Caption := 'X';
  end else
  begin
    FActionList := nil;
    FactVisible := nil;
  end;
end;

destructor TframeMapOfAnaliticLine.Destroy;
begin
  FLookUp.Free;
  FButtons.Free;
  FActionList.Free;

  inherited;  
end;

procedure TframeMapOfAnaliticLine.OnVisibleUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FButtons.Count > 1)
    or ((FButtons.Count = 1) and (FLookUp.Count = 1)
    and ((FLookUp[0] as TgsIBLookupComboBox).CurrentKey <> ''));
end;

function TframeMapOfAnaliticLine.FieldType: TAnalyticFieldType;
begin
  if FField.References <> nil then
    Result := aftReference
  else
    Result := aftString;
end;

procedure TframeMapOfAnaliticLine.LookUpChange(Sender: TObject);
var
  Index: Integer;
begin
  Index := FLookUp.IndexOf(Sender as TgsIBLookupComboBox);
  if (Index = FLookUp.Count - 1) and ((Sender as TgsIBLookupComboBox).CurrentKey <> '') then
  begin
    FLookUp.Add(CreateLookUp);
    FButtons.Add(CreateButton);
    ReSizeControls;
  end;
end;

function TframeMapOfAnaliticLine.GetCount: Integer;
var
  I: Integer;
  CurrKey: String;
begin
  Result := 0;

  case FieldType of
    aftReference:
    begin
      if FLookUp.Count > 0 then
      begin
        for I := 0 to FLookUp.Count - 1 do
        begin
          CurrKey := (FLookUp[I] as TgsIBLookupComboBox).CurrentKey;
          if CurrKey <> '' then
            Inc(Result);
        end;
      end;
    end;

    aftString:
    begin
      if Trim(eAnalitic.Text) <> '' then
        Result := Result + 1;
    end;
  end;
end;

procedure TframeMapOfAnaliticLine.ReSizeControls;
var
  AllHeight, I, LH: Integer;
begin
  if FField <> nil then
  begin
    AllHeight := FrameHeight;
    case FieldType of
      aftReference:
      begin
        if (FLookUp.Count > 0) and (FButtons.Count > 0) then
        begin
          LH := (FLookUp[0] as TgsIBLookupComboBox).Height + 2;
          for I := 0 to FLookUp.Count - 1 do
          begin
            (FLookUp[I] as TgsIBLookupComboBox).Top := AllHeight;
            (FLookUp[I] as TgsIBLookupComboBox).Width := FrameWidth - ButtonWidth - 2;
            (FButtons[I] as TSpeedButton).Top := AllHeight;
            (FButtons[I] as TSpeedButton).Left := FrameWidth - ButtonWidth - 2;
            AllHeight :=  AllHeight + LH;
          end;
        end;
      end;

      aftString:
      begin
        eAnalitic.Top := AllHeight;
        eAnalitic.Width := FrameWidth - 2;
        eAnalitic.Left := 2;
        AllHeight := AllHeight + eAnalitic.Height;
      end;
    end;

    cbInputParam.Left := Self.ClientWidth - cbInputParam.Width - 2;
    Self.Height := AllHeight + 2;
  end;
end;

procedure TframeMapOfAnaliticLine.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
  inherited;
  eAnalitic.Width := Width - eAnalitic.Left;
end;

procedure TframeMapOfAnaliticLine.SetField(const Value: TatRelationField);
begin
  FField := Value;
  if FField <> nil then
  begin
    lAnaliticName.Caption := FField.LName;
    if FField.References <> nil then
    begin
      FLookUp.Add(CreateLookUp);
      FButtons.Add(CreateButton);
    end
    else
      eAnalitic.Visible := True;
      
    ReSizeControls;
  end;
end;

procedure TframeMapOfAnaliticLine.SetValue(const Value: String);
var
  SL: TStringList;
  I: Integer;
begin
  case FieldType of
    aftReference:
    begin
      if Value > '' then
      begin
        SL := TStringList.Create;
        try
          SL.CommaText := Value;
          for I := 0 to SL.Count - 1 do
          begin
            if (I > (FLookUp.Count - 1)) then
            begin
              FLookUp.Add(CreateLookUp);
              FButtons.Add(CreateButton);
              ReSizeControls;
            end;
            (FLookUp[I] as TgsIBLookupComboBox).CurrentKey := SL[I];
          end;
        finally
          SL.Free;
        end;
      end;
    end;

    aftString:
    begin
      eAnalitic.Text := Value;
    end;
  end;
end;

function TframeMapOfAnaliticLine.GetValue: String;
var
  SL: TStringList;
  I: Integer;
  CurrKey: String;
begin
  Result := '';

  case FieldType of
    aftReference:
    begin
      if FLookUp.Count > 0 then
      begin
        SL := TStringList.Create;
        try
          for I := 0 to FLookUp.Count - 1 do
          begin
            CurrKey := (FLookUp[I] as TgsIBLookupComboBox).CurrentKey;
            if CurrKey <> '' then
              SL.Add(CurrKey);
          end;

          Result := SL.CommaText;
        finally
          SL.Free;
        end;
      end;
    end;

    aftString:
    begin
      Result := Trim(eAnalitic.Text);
    end;
  end;
end;

function TframeMapOfAnaliticLine.CreateLookUp: TgsIBLookupComboBox;
begin
  Result := TgsIBLookupComboBox.Create(Self);
  with Result do
  begin
    Parent := Self;
    
    Database := dmDatabase.ibdbGAdmin;
    Transaction := gdcBaseManager.ReadTransaction;
    SubType := FField.gdSubType;
    gdClassName := FField.gdClassName;
    ListTable := FField.References.RelationName;

    if FField.Field.RefListFieldName <> '' then
       ListField := FField.Field.RefListFieldName
    else
      ListField := FField.References.ListField.FieldName;

    KeyField := FField.ReferencesField.FieldName;
    ParentShowHint := False;
    SortOrder := soAsc;
    Left := 2;
    Width := Self.ClientWidth - ButtonWidth - 2;
    Visible := True;
    OnChange := LookUpChange;
  end;
end;

procedure TframeMapOfAnaliticLine.Clear;
begin
  if FField.References <> nil then
  begin
    While FLookUp.Count > 1 do
    begin
      FLookUp.Delete(0);
      FButtons.Delete(0);
    end;

    if FLookUp.Count = 1 then
      (FLookUp[0] as TgsIBLookupComboBox).CurrentKey := '';
  end;

  SetValue('');
end;

function TframeMapOfAnaliticLine.CreateButton: TSpeedButton;
begin
  Result := TSpeedButton.Create(Self);
  with Result do
  begin
    Parent := Self;
    Caption := 'X';
    Action := FactVisible;
    Visible := True;
    Height := ButtonHeight;
    Left := Self.ClientWidth - ButtonWidth;
    Width := ButtonWidth;
    OnClick := BtnPress;
  end;
end;

procedure TframeMapOfAnaliticLine.BtnPress(Sender: TObject);
var
  Index: Integer;
begin
  if FButtons.Count > 1 then
  begin
    Index := FButtons.IndexOf(Sender as TSpeedButton);
    if Index <> -1 then
    begin
      FLookUp.Delete(Index);
      FButtons.Delete(Index);
    end;
    ReSizeControls;
  end else
    if FButtons.Count = 1 then
      (FLookUp[0] as TgsIBLookupComboBox).CurrentKey := '';
end;

procedure TframeMapOfAnaliticLine.eAnaliticChange(Sender: TObject);
begin
  cbInputParam.Checked := False
end;

end.
