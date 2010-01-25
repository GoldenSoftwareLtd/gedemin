{++
  Copyright (c) 2002 by Golden Software of Belarus

  Module
    dlg_gsResizer_ObjectInspector_unit
  Abstract

    Object Inspector для gsResiser;

  Author

    Kornachenko Nikolai (nkornachenko@yahoo.com) (17-01-2002)

  Revisions history

    Initial  17-01-2002  Nick  Initial version.
--}

unit dlg_gsResizer_ObjectInspector_unit;

interface

uses
  Windows, Classes, ComCtrls, Forms, gsObjectInspector, StdCtrls,
  Controls, ExtCtrls, gsResizerInterface, Menus, Buttons;
type

  Tdlg_gsResizer_ObjectInspector = class(TForm, IgsObjectInspectorForm)
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    cbObjectInspector: TComboBox;
    pcObjectInspector: TPageControl;
    tsProperies: TTabSheet;
    tsEvents: TTabSheet;
    edInspector: TEdit;
    PopupMenu1: TPopupMenu;
    miStayOnTop: TMenuItem;
    SpeedButton1: TSpeedButton;
    procedure cbObjectInspectorClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure edInspectorClick(Sender: TObject);
    procedure miStayOnTopClick(Sender: TObject);
    procedure edInspectorChange(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure cbObjectInspectorDropDown(Sender: TObject);
    procedure pcObjectInspectorMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDeactivate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
    FManager: IgsResizeManager;
    FProperties: TgsObjectInspector;
    FEvents: TgsObjectInspector;
    FOldEditComponent: TComponent;
    //FOldShowHint: TShowHintEvent;
    function InternalAddComponent(AComponent: TComponent; const AShiftState: Boolean): Boolean;
    function GetManager: IgsResizeManager;

    //procedure DoShowHint(var HintStr: string; var CanShow: Boolean; var HintInfo: THintInfo);


  public
    { Public declarations }
    procedure SaveState;
    procedure RefreshList;
    procedure RefreshProperties;
    function AddEditComponent(AComponent: TComponent; const AShiftState: Boolean): boolean;
    function AddEditSubComponent(ASubComponent: TPersistent): boolean;
    procedure SetEditForm;
    property Manager: IgsResizeManager read GetManager;
    procedure Reset;
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    function GetSelf: TComponent;
    procedure EventSync(const AnObjectName, AnEventName: String);
    function  GetChangedEventFunctionID(AComp: TComponent; AEventName: string): integer;
  end;

var
  dlg_gsResizer_ObjectInspector: Tdlg_gsResizer_ObjectInspector;

implementation

uses
  gsResizer, gsComponentEmulator, Storages, Dialogs, sysutils, messages,
  dlg_gsResizer_ObjectInspectorFind_unit;

{$R *.DFM}

constructor Tdlg_gsResizer_ObjectInspector.Create(AnOwner: TComponent);
begin
  if Assigned(dlg_gsResizer_ObjectInspector) then
    raise Exception.Create('Можно создать только один экземпляр данного типа');

  inherited;

  if AnOwner is TgsResizeManager then
    FManager := TgsResizeManager(AnOwner)
  else
    FManager := nil;
  FOldEditComponent := nil;
  Assert(FManager <> nil);

  FProperties := TgsObjectInspector.Create(Self);
  FProperties.Parent := tsProperies;
  FProperties.Align := alClient;
  FProperties.ProperiesType := ptProperty;

  FEvents := TgsObjectInspector.Create(Self);
  FEvents.Parent := tsEvents;
  FEvents.Align := alClient;
  FEvents.ProperiesType := ptEvent;

  pcObjectInspector.ActivePageIndex := 0;
  FProperties.Manager := FManager;
  FEvents.Manager := FManager;

  dlg_gsResizer_ObjectInspector := Self;

  FProperties.LeftSideWidth := UserStorage.ReadInteger('\'+ Name,
    Name + 'SpliterPos', FProperties.LeftSideWidth);
  FEvents.LeftSideWidth := UserStorage.ReadInteger('\'+ Name,
    Name + 'SpliterEPos', FProperties.LeftSideWidth);
end;

procedure Tdlg_gsResizer_ObjectInspector.cbObjectInspectorClick(
  Sender: TObject);
var
  C: TControl;
begin
  if edInspector.Visible then
    edInspector.Visible := False;
  if cbObjectInspector.ItemIndex <> -1 then
  begin
    try
      if FOldEditComponent <> cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex] as TComponent then
      begin
        FOldEditComponent := cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex] as TComponent;
        InternalAddComponent(FOldEditComponent, False)
      end
      else
      begin
        FProperties.RefreshProperties;
        FEvents.RefreshProperties;
      end
    except
      FOldEditComponent := nil;
      InternalAddComponent(nil, False);
    end;
  end
  else
  begin
    InternalAddComponent(nil, False);
  end;

  if Sender <> nil then
    if cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex] is TControl then
    begin
      if cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex] is TTabSheet then
        TTabSheet(cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex]).PageControl.ActivePage :=
          TTabSheet(cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex]);
      if FManager.AddResizer(cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex] as TControl, False) then
        (cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex] as TControl).Show;
    end
    else
    begin
      C := FManager.AddComponent(cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex] as TComponent);
      if C <> nil then
      begin
        C.Show;
      end;
    end

end;

procedure Tdlg_gsResizer_ObjectInspector.SetEditForm;
begin
  cbObjectInspector.Items.Clear;
  FProperties.AddComponent(nil, False);
  FEvents.AddComponent(nil, False);
  if Assigned(FManager.EditForm) then
  begin
    RefreshList;
    cbObjectInspector.ItemIndex := cbObjectInspector.Items.IndexOfObject(FManager.EditForm);
    cbObjectInspectorClick(nil);
  end;
end;

function Tdlg_gsResizer_ObjectInspector.AddEditComponent(AComponent: TComponent; const AShiftState: Boolean): Boolean;
var
  I: Integer;
begin
  Result := True;
  if AShiftState then
  begin
    FOldEditComponent := nil;
    cbObjectInspector.ItemIndex := -1;
    Result := InternalAddComponent(AComponent, AShiftState);
  end
  else
  begin
    if not ((FOldEditComponent = AComponent) or ((AComponent is TgsComponentEmulator) and (FoldEditComponent = TgsComponentEmulator(AComponent).RelatedComponent)))  then
    begin
      I := cbObjectInspector.Items.IndexOfObject(AComponent);
      if  i < 0 then
      begin
        RefreshList;
        I := cbObjectInspector.Items.IndexOfObject(AComponent);
      end;
      cbObjectInspector.ItemIndex := I;
      cbObjectInspectorClick(nil);
    end;
  end;
  if not Result then
    Abort;
end;

procedure Tdlg_gsResizer_ObjectInspector.RefreshList;
  procedure FillList(AnOwner: TComponent; const APrefix: String);
  var
    I: Integer;
  begin
    for I := 0 to AnOwner.ComponentCount - 1 do
    begin
      if (AnOwner.Components[I].Name > '') AND (not (AnOwner.Components[I] is TgsComponentEmulator)) then
      begin
        cbObjectInspector.Items.AddObject(APrefix + AnOwner.Components[I].Name + ': ' + AnOwner.Components[I].ClassName, AnOwner.Components[I]);
        if AnOwner.Components[I] is TFrame then
          FillList(AnOwner.Components[I], APrefix + AnOwner.Components[I].Name + '.')
      end;

    end;
  end;

var
  I: Integer;
  O: TObject;
begin
  if cbObjectInspector.ItemIndex <> -1 then
    O := cbObjectInspector.Items.Objects[cbObjectInspector.ItemIndex]
  else
    O := nil;

  cbObjectInspector.Items.Clear;

  if Assigned(FManager.EditForm) then
  begin
    FillList(FManager.EditForm, '');
    cbObjectInspector.Items.AddObject(FManager.EditForm.Name + ': ' + FManager.EditForm.ClassName, FManager.EditForm);

    I := cbObjectInspector.Items.IndexOfObject(O);
    if I <> -1 then
    begin
      cbObjectInspector.ItemIndex := I;
      RefreshProperties;
    end
    else
    begin
      cbObjectInspector.ItemIndex := cbObjectInspector.Items.IndexOfObject(FManager.EditForm);
      cbObjectInspectorClick(nil);
    end;
  end;
end;

procedure Tdlg_gsResizer_ObjectInspector.RefreshProperties;
begin
  FProperties.RefreshProperties;
  FEvents.RefreshProperties;
end;

procedure Tdlg_gsResizer_ObjectInspector.FormDestroy(Sender: TObject);
begin
  if Assigned(UserStorage) then
  begin
    UserStorage.WriteInteger('\'+ Name, Name + 'Height', Height);
    UserStorage.WriteInteger('\'+ Name, Name + 'Top', Top);
    UserStorage.WriteInteger('\'+ Name, Name + 'Left', Left);
    UserStorage.WriteInteger('\'+ Name, Name + 'Width', Width);
    {Не знаю почему, но в Tdlg_gsResizer_ObjectInspector.Create возникала ошибка
     Win32 Error Code 2 Не удается найти указанный файл,
    что вызвало Tdlg_gsResizer_ObjectInspector.Destroy, что вызвало данный метод.
    При этом FEvents создаться не успели}
    if Assigned(FProperties) then
      UserStorage.WriteInteger('\'+ Name, Name + 'SpliterPos', FProperties.LeftSideWidth);
    if Assigned(FEvents) then
      UserStorage.WriteInteger('\'+ Name, Name + 'SpliterEPos', FEvents.LeftSideWidth);
    UserStorage.WriteBoolean('\'+ Name, Name + 'StayOnTop', FormStyle = fsStayOnTop);
  end;
  FProperties.Free;
  FEvents.Free;
end;

procedure Tdlg_gsResizer_ObjectInspector.Reset;
begin
  FOldEditComponent := nil;
end;

procedure Tdlg_gsResizer_ObjectInspector.SaveState;
begin
  InternalAddComponent(nil, False);
end;

function Tdlg_gsResizer_ObjectInspector.InternalAddComponent(
  AComponent: TComponent; const AShiftState: Boolean): Boolean;
begin
  Result := FProperties.AddComponent(AComponent, AShiftState);
  Result := FEvents.AddComponent(AComponent, AShiftState) and Result;
end;


procedure Tdlg_gsResizer_ObjectInspector.FormCreate(Sender: TObject);
begin
  if Assigned(UserStorage) then
  begin
    Height := UserStorage.ReadInteger('\'+ Name, Name + 'Height', Height);
    Top := UserStorage.ReadInteger('\'+ Name, Name + 'Top', Top);
    Left := UserStorage.ReadInteger('\'+ Name, Name + 'Left', Left);
    Width := UserStorage.ReadInteger('\'+ Name, Name + 'Width', Width);
    if Left > Screen.Width then
      Left := Screen.Width - Width;
    if Top > Screen.Height then
      Top := Screen.Height - Height;

    if UserStorage.ReadBoolean('\'+ Name, Name + 'StayOnTop', False) then
      FormStyle := fsStayOnTop
    else
      FormStyle := fsNormal;
  end;
end;

procedure Tdlg_gsResizer_ObjectInspector.FormHide(Sender: TObject);
begin
  FProperties.CloseUp(False);
  FEvents.CloseUp(False);
end;

function Tdlg_gsResizer_ObjectInspector.AddEditSubComponent(
  ASubComponent: TPersistent): Boolean;
begin
  Result := FProperties.AddComponent(ASubComponent, False);
  Result := FEvents.AddComponent(ASubComponent, False) and Result;
  if ASubComponent is TCollectionItem then
    edInspector.Text := TCollectionItem(ASubComponent).GetNamePath + ': ' + ASubComponent.ClassName
  else if ASubComponent is TComponent then
    edInspector.Text := TComponent(ASubComponent).Name + ': ' + ASubComponent.ClassName
  else
    edInspector.Text := '';
  edInspector.Visible := True;
  edInspector.BringToFront;
  FOldEditComponent := nil;
end;

procedure Tdlg_gsResizer_ObjectInspector.edInspectorClick(
  Sender: TObject);
begin
  cbObjectInspector.DroppedDown := True;
end;

function Tdlg_gsResizer_ObjectInspector.GetManager: IgsResizeManager;
begin
  Result := FManager;
end;

function Tdlg_gsResizer_ObjectInspector.GetSelf: TComponent;
begin
  Result := Self;
end;

procedure Tdlg_gsResizer_ObjectInspector.EventSync(const AnObjectName,
  AnEventName: String);
begin
  FEvents.EventSync(AnObjectName, AnEventName);
end;

destructor Tdlg_gsResizer_ObjectInspector.Destroy;
begin
  dlg_gsResizer_ObjectInspector := nil;
  
  inherited;
end;

procedure Tdlg_gsResizer_ObjectInspector.miStayOnTopClick(Sender: TObject);
begin
  if Self.FormStyle = fsStayOnTop then
    Self.FormStyle := fsNormal
  else
    Self.FormStyle := fsStayOnTop;
end;

procedure Tdlg_gsResizer_ObjectInspector.edInspectorChange(
  Sender: TObject);
begin
  edInspector.Hint := edInspector.Text;
end;

procedure Tdlg_gsResizer_ObjectInspector.PopupMenu1Popup(Sender: TObject);
begin
  miStayOnTop.Checked := Self.FormStyle = fsStayOnTop;
end;

procedure Tdlg_gsResizer_ObjectInspector.cbObjectInspectorDropDown(
  Sender: TObject);
var
  I: Integer;
  W: Integer;
  T: Integer;
  C: TControlCanvas;
begin
  W := cbObjectInspector.Width;
  C := TControlCanvas.Create;
  try
    C.Control := cbObjectInspector;
    C.Font := cbObjectInspector.Font;
    for I := 0 to cbObjectInspector.Items.Count - 1 do
    begin
      T := C.TextWidth(cbObjectInspector.Items[I]);
      if T > W then W := T + 10;
    end;
  finally
    C.Free;
  end;
  SendMessage(cbObjectInspector.Handle, CB_SETDROPPEDWIDTH, W, 0);

end;

procedure Tdlg_gsResizer_ObjectInspector.pcObjectInspectorMouseMove(
  Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  FProperties.ShowHintWindow;
  FEvents.ShowHintWindow;
end;

procedure Tdlg_gsResizer_ObjectInspector.FormDeactivate(Sender: TObject);
begin
  FProperties.UpdateProperty;
end;

procedure Tdlg_gsResizer_ObjectInspector.SpeedButton1Click(
  Sender: TObject);
var
  i: integer;
  frm: Tdlg_gsResizer_ObjectInspectorFind;
begin
  frm:= Tdlg_gsResizer_ObjectInspectorFind.Create(self);
  try
    i:= frm.FindObject(cbObjectInspector.Items);
    if i > 0 then begin
      cbObjectInspector.ItemIndex:= i;
      cbObjectInspectorClick(cbObjectInspector);
    end;
  finally
    frm.Free;
  end;
end;

function Tdlg_gsResizer_ObjectInspector.GetChangedEventFunctionID(
  AComp: TComponent; AEventName: string): integer;
var
  CEL: TChangedEventList;
  i: integer;
begin
  Result:= 0;
  CEL:= FManager.ChangedEventList;
  if Assigned(CEL) then begin
    i:= CEL.FindByCompAndEvent(AComp, AEventName);
    if i > -1 then
      Result:= CEL[i].NewFunctionID;
  end;
end;

end.
