// ShlTanya, 25.02.2019

unit prp_DOCKFORM_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  ExtCtrls, StdCtrls, gd_createable_form, SuperPageControl, ActnList;

const
  cParentForm = 'ParentForm';
  cParentFormClass = 'ParentFormClass';
  cDockSite = 'DockSite';
  cNil = 'nil';
  cAlign = 'Align';
  cVisible = 'Visible';
  cLeft = 'Left';
  cTop = 'Top';
  cHeight = 'Height';
  cWidth = 'Width';
  cDockForm = 'DockForm';
  cDockable = 'Dockable';

type
  TDockableForm = class(TCreateableForm)
    alMain: TActionList;
    actDockable: TAction;
    pmMain: TPopupMenu;
    miDockable: TMenuItem;
    actStayOnTop: TAction;
    miSeparator: TMenuItem;
    miStayOnTop: TMenuItem;
    pCaption: TPanel;
    procedure FormDockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormGetSiteInfo(Sender: TObject; DockClient: TControl;
      var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    procedure actDockableExecute(Sender: TObject);
    procedure actDockableUpdate(Sender: TObject);
    procedure actStayOnTopExecute(Sender: TObject);
    procedure actStayOnTopUpdate(Sender: TObject);
  private
    FDockForm: TCreateableForm;
    FLocalVisible: Boolean;
    FDockable: Boolean;
    FHeight, FWidth: Integer;
    FBeginDockProcessing: Boolean;

    //Расчет зоны на которую будет докироваться форма
    function ComputeDockingRect(var DockRect: TRect; MousePos: TPoint): TAlign;
    procedure CMDockClient(var Message: TCMDockClient); message CM_DOCKCLIENT;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure SetDockForm(const Value: TCreateableForm);
    //поиск формы по имени
    function FormByName(Name: string): TCustomForm;
//    procedure SetVisible(Value: Boolean);
    procedure SetDockable(const Value: Boolean);
    function GetStayOnTop: Boolean;
  protected
    procedure VisibleChanging; override;
    procedure CreateWnd; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    function FormVisible: boolean;
    procedure SetZOrder(TopMost: Boolean); override;

    property BeginDockProcessing: Boolean read FBeginDockProcessing;
  public
    procedure SaveSettings; override;
    procedure LoadSettings; override;
    // сохранить настройки формы, вызывается при сохранении десктопа
    procedure SaveDesktopSettings; override;
    // загрузить настройки формы, вызывается при загрузке (смене) десктопа
    procedure LoadDesktopSettings; override;
//    procedure Show;
//    procedure Hide;
    procedure Close;

    property DockForm: TCreateableForm read FDockForm write SetDockForm;
  published
//    property Visible write SetVisible;
    property Dockable: Boolean read FDockable write SetDockable;
    property StayOnTop: Boolean read GetStayOnTop;
  end;

procedure CheckHandle(C: TWinControl);

implementation
{$R *.DFM}

uses ComCtrls, TabHost, ConjoinHost, prp_frm_unit, gsStorage, Storages;


procedure CheckHandle(C: TWinControl);
var
  TmpCursor: TCursor;

  procedure InCheck(C: TWinControl);
  var
    I: Integer;
  begin
    if not C.HandleAllocated then
      C.HandleNeeded;
    for I := 0 to C.ComponentCount - 1 do
    begin
      if (C.Components[I] is TWinControl) then
        InCheck(TWinControl(C.Components[I]));
    end;
  end;
begin
  TmpCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    InCheck(C);
{    if not C.HandleAllocated then
      C.HandleNeeded;
    for I := 0 to C.ComponentCount - 1 do
    begin
      if (C.Components[I] is TWinControl) then
        CheckHandle(TWinControl(C.Components[I]));
    end;
    }
  finally
    Screen.Cursor := TmpCursor;
  end;
end;

function GetForm(C: TControl): TCustomForm;
begin
  Result := nil;
  while (C <> nil) {and (not (csDestroying in C.ComponentState))} do
  begin
    if C is TCustomForm then
    begin
      Result := TCustomForm(C);
      Exit
    end;
    C := C.Parent;
  end;
end;

procedure TDockableForm.FormDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  ARect: TRect;
begin
  Accept := (Source.Control is TDockableForm) and
    (TDockableForm(Source.Control).Dockable) and
    (FDockable) and (ComputeDockingRect(ARect, Point(X, Y)) <> alNone);
  if Accept then
  begin
    FBeginDockProcessing := True;
    Source.DockRect := ARect;
  end;
end;

function TDockableForm.ComputeDockingRect(var DockRect: TRect; MousePos: TPoint): TAlign;
var
  DockTopRect,
  DockLeftRect,
  DockBottomRect,
  DockRightRect,
  DockCenterRect: TRect;
begin
  Result := alNone;
  //divide form up into docking "Zones"
  DockLeftRect.TopLeft := Point(0, 0);
  DockLeftRect.BottomRight := Point(ClientWidth div 5, ClientHeight);

  DockTopRect.TopLeft := Point(ClientWidth div 5, 0);
  DockTopRect.BottomRight := Point(ClientWidth div 5 * 4, ClientHeight div 5);

  DockRightRect.TopLeft := Point(ClientWidth div 5 * 4, 0);
  DockRightRect.BottomRight := Point(ClientWidth, ClientHeight);

  DockBottomRect.TopLeft := Point(ClientWidth div 5, ClientHeight div 5 * 4);
  DockBottomRect.BottomRight := Point(ClientWidth div 5 * 4, ClientHeight);

  DockCenterRect.TopLeft := Point(ClientWidth div 5, ClientHeight div 5);
  DockCenterRect.BottomRight := Point(ClientWidth div 5 * 4, ClientHeight div 5 * 4);

  //Find out where the mouse cursor is, to decide where to draw dock preview.
  if PtInRect(DockLeftRect, MousePos) then
    begin
      Result := alLeft;
      DockRect := DockLeftRect;
      DockRect.Right := ClientWidth div 2;
    end
  else
    if PtInRect(DockTopRect, MousePos) then
      begin
        Result := alTop;
        DockRect := DockTopRect;
        DockRect.Left := 0;
        DockRect.Right := ClientWidth;
        DockRect.Bottom := ClientHeight div 2;
      end
    else
      if PtInRect(DockRightRect, MousePos) then
        begin
          Result := alRight;
          DockRect := DockRightRect;
          DockRect.Left := ClientWidth div 2;
        end
      else
        if PtInRect(DockBottomRect, MousePos) then
          begin
            Result := alBottom;
            DockRect := DockBottomRect;
            DockRect.Left := 0;
            DockRect.Right := ClientWidth;
            DockRect.Top := ClientHeight div 2;
         end
        else
          if PtInRect(DockCenterRect, MousePos) then
          begin
            Result := alClient;
            DockRect := DockCenterRect;
          end;
  if Result = alNone then
  begin
//    Result := alClient;
    Exit;
  end;

  //DockRect is in screen coordinates.
  DockRect.TopLeft := ClientToScreen(DockRect.TopLeft);
  DockRect.BottomRight := ClientToScreen(DockRect.BottomRight);
end;

procedure TDockableForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  F: TCustomForm;
  W, H: Integer;
begin
  //the action taken depends on how the form is docked.

  if (HostDockSite is TConjoinDockHost) then
  begin
    //remove the form's caption from the conjoin dock host's caption list
    TConjoinDockHost(HostDockSite).UpdateCaption(Self);

    //if we're the last visible form on a conjoined form, hide the form
    if HostDockSite.VisibleDockClientCount <= 1 then
      HostDockSite.Hide;
  end;

  //if docked to a panel, tell the panel to hide itself. If there are other
  //visible dock clients on the panel, it ShowDockPanel won't allow it to
  //be hidden
  if (HostDockSite is TPanel) then
  begin
    F := GetForm(HostDockSite);
    if F <> nil then
    begin
      W := Width; H :=Height;
      Tprp_frm(F).ShowDockPanel(HostDockSite as TPanel, False, nil);
      Width := W; Height := H;
    end;
  end;

  Action := caHide;
end;

procedure TDockableForm.CMDockClient(var Message: TCMDockClient);
var
  ARect: TRect;
  DockType: TAlign;
  Pt: TPoint;
  DockSite: TWinControl;
  lAlign: TAlign;
  T: TTabDockHost;
  C: TConjoinDockHost;

  procedure DockControl(Control: TControl; Host: TWinControl; Align: TAlign);
  var
    DockSite: TWinControl;
    I: Integer;
  begin
    DockSite := nil;
    if Control is TTabDockHost then
      DockSite := TTabDockHost(Control).PageControl1
    else
    if Control is TConjoinDockHost then
      DockSite := TWinControl(Control);
    if DockSite <> nil then
    begin
      for I := DockSite.DockClientCount - 1 downto 0 do
        DockSite.DockClients[I].ManualDock(Host, nil, Align);
      if DockSite is TConjoinDockHost then
        PostMessage(DockSite.Handle, WM_CLOSE, 0, 0)
      else
        PostMessage(TWinControl(DockSite.Parent).Handle, WM_CLOSE, 0, 0);
    end else
      Message.DockSource.Control.ManualDock(Host, nil, Align);
  end;

begin
  //Overriding this message allows the dock form to create host forms
  //depending on the mouse position when docking occurs. If we don't override
  //this message, the form will use VCL's default DockManager.

  //NOTE: the only time ManualDock can be safely called during a drag
  //operation is we override processing of CM_DOCKCLIENT.

  if Message.DockSource.Control is TDockableForm then
  begin
    //Find out how to dock (Using a TAlign as the result of ComputeDockingRect)
    Pt.x := Message.MousePos.x;
    Pt.y := Message.MousePos.y;
    DockType := ComputeDockingRect(ARect, Pt);

    //if we are over a dockable form docked to a panel in the
    //main window, manually dock the dragged form to the panel with
    //the correct orientation.
    if DockType = alClient then
    begin
      if HostDockSite <> nil then
      begin
        if (HostDockSite is TPanel) or (HostDockSite is TConjoinDockHost) then
        begin
          ARect := BoundsRect;
          lAlign := Align;
          DockSite := HostDockSite;
          ManualFloat(Rect(0, 0, UndockHeight, UndockWidth));
          T := TTabDockHost.Create(Application);
          T.DockForm := DockForm;
          T.Show;
          T.ManualDock(DockSite, nil, lAlign);
          ManualDock(T.PageControl1, nil, alClient);
          DockControl(Message.DockSource.Control, T.PageControl1, alClient);
//          Message.DockSource.Control.ManualDock(T.PageControl1, nil, alClient);
        end else
        if HostDockSite is TSuperPageControl then
          DockControl(Message.DockSource.Control, HostDockSite, alClient);
      end else
      begin
        T := TTabDockHost.Create(Application);
        T.DockForm := DockForm;
        T.Show;
        ManualDock(T.PageControl1, nil, alClient);

        DockControl(Message.DockSource.Control, T.PageControl1, alClient);
      end;
    end else
    begin
      if HostDockSite <> nil then
      begin
        if (HostDockSite is TPanel) or (HostDockSite is TConjoinDockHost) then
        begin
          DockControl(Message.DockSource.Control, HostDockSite, DockType);
        end else
        if HostDockSite is TSuperPageControl then
        begin
          DockSite := HostDockSite.Parent.HostDockSite;

          if DockSite = nil then
          begin
            C := TConjoinDockHost.Create(Application);
            C.DockForm := DockForm;
            C.Show;
            C.BoundsRect := HostDockSite.Parent.BoundsRect;
            HostDockSite.Parent.ManualDock(C, nil, alClient);
          end;

          if Message.DockSource.Control is TTabDockHost then
            Message.DockSource.Control.ManualDock(DockSite, nil, DockType)
          else
            DockControl(Message.DockSource.Control, HostDockSite.Parent.HostDockSite, DockType);
        end;
      end else
      begin
        if Self is TConjoinDockHost then
        begin
          inherited;
          Exit;
//          DockControl(Message.DockSource.Control, Self, DockType);
        end else
        if Self is TTabDockHost then
        begin
          C := TConjoinDockHost.Create(Application);
          C.DockForm := DockForm;
          C.Show;
          C.BoundsRect := BoundsRect;
          ManualDock(C, nil, alClient);

          DockControl(Message.DockSource.Control, C, DockType);
        end else
        begin
          C := TConjoinDockHost.Create(Application);
          C.DockForm := DockForm;
          C.Show;
          ManualDock(C, nil, alClient);
          DockControl(Message.DockSource.Control, C, DockType);
        end;
      end;
    end;
    Message.result := 1;
  end;
end;

procedure TDockableForm.SetDockForm(const Value: TCreateableForm);
begin
  if FDockForm <> Value then
  begin
    if FDockForm <> nil then
      Tprp_frm(DockForm).UnSignForm(Self);

    FDockForm := Value;

    if FDockForm <> nil then
      Tprp_frm(FDockForm).SignForm(Self);
  end;
end;

procedure TDockableForm.FormDestroy(Sender: TObject);
//var
//  ARect: TRect;
begin
  if FDockForm <> nil then
    Tprp_frm(DockForm).UnSignForm(Self);

  if Assigned(DockForm) then
    Tprp_frm(DockForm).OnDockWindowDestroy(Self);

{  if HostDockSite <> nil then
  begin
    ARect.TopLeft := ClientToScreen(Point(0, 0));
    ARect.BottomRight := ClientToScreen(Point(Width, Height));
    ManualFloat(ARect);
  end;}
  inherited;
end;

procedure TDockableForm.LoadSettings;
var
  Path: String;
  F: TgsStorageFolder;
  Form: TCustomForm;
  FormName, FormClassName, DockSiteName, DF: string;
  A: TAlign;
  C: TWinControl;
  V, D: Boolean;
  L, T, H, W: Integer;

  procedure CheckBounds(var L, T, W, H: Integer);
  begin
    if L + W <= 40 then L := 40 - W;
    if T + H <= 40 then T := 40 - H;
    if L > Screen.Width - 40 then L := Screen.Width - 40;
    if T > Screen.Height - 40 then T := Screen.Height - 40;
    if W > Screen.Width then W := Screen.Width;
    if H > Screen.Height then H := Screen.Height;
  end;

begin
  inherited;
  if Assigned(UserStorage) then
  begin
    Path := 'frmGedeminProperty\' + Self.Name;
    F := UserStorage.OpenFolder(Path, True);
    //Считываем настройки из стораджа
    if F <> nil then
    begin
      FormName := F.ReadString(cParentForm, cNil);
      FormClassName := F.ReadString(cParentFormClass, '');
      DockSiteName := F.ReadString(cDockSite, cNil);
      DF := F.ReadString(cDockForm, cNil);
      A := TAlign(F.ReadInteger(cAlign));
      V := F.ReadBoolean(cVisible, True);
      L := F.ReadInteger(cLeft, Left);
      T := F.ReadInteger(cTop, Top);
      H := F.ReadInteger(cHeight, Height);
      W := F.ReadInteger(cWidth, Width);
      D := F.ReadBoolean(cDockable);
      UserStorage.CloseFolder(F);
      CheckBounds(L, T, W, H);
      //Устанавливаем координаты
      SetBounds(L, T, W, H);

      if (DF <> cNil) and (DF <> '') then
        DockForm := TCreateableForm(FormByName(DF));

      //Устанавливаем видимость
//      Visible := V;
      if FormName <> cNil then
      begin
        //Пытаемся найти формы
        Form := FormByName(FormName);
        if Form = nil then
        begin
          //Форма не найдена. Если форма имеет тип TabDockHost или ConjoinDockHost
          //то создаём форму
          if UpperCase(FormClassName) = 'TTABDOCKHOST' then
          begin
            Form := TTabDockHost.Create(Application);
            if Form.Name <> FormName then
            begin
              Form.Name := FormName;
              if Form.HostDockSite <> nil then
                Form.ManualFloat(Form.BoundsRect);
              TDockableForm(Form).LoadSettings;
            end;
          end else
          if UpperCase(FormClassName) = 'TCONJOINDOCKHOST' then
          begin
            Form := TConjoinDockHost.Create(Application);
            if Form.Name <> FormName then
            begin
              Form.Name := FormName;
              if Form.HostDockSite <> nil then
                Form.ManualFloat(Form.BoundsRect);
              TDockableForm(Form).LoadSettings;
            end;
          end else
          { TODO :
          Тут можно добавить поиск класса среди
          зарегестрированных классов }
            Exit;
        end;
        if DockSiteName <> FormName then
        begin
          C := TWinControl(Form.FindChildControl(DockSiteName));
          if C <> nil then
          begin
            ManualDock(C, nil, A);
            C.Realign;
          end;
        end else
        begin
          if Form.DockClientCount = 0 then
            Form.SetBounds(L, T, W, H);
          ManualDock(Form, nil, A);
          Form.Realign;
        end;
      end;
      Dockable := D;
      Visible := V;
    end;
  end;
end;

procedure TDockableForm.SaveSettings;
var
  Path: String;
  F: TgsStorageFolder;
  Form: TCustomForm;
begin
  inherited;
  if Assigned(UserStorage) then
  begin
    //Открываем папку в сторадже
    Path := 'frmGedeminProperty\' + Self.Name;
    F := UserStorage.OpenFolder(Path, True);
    if F <> nil then
    begin
      //Если форма никуда не задокирована то
      //сохраняем пустые имена
      if HostDockSite = nil then
      begin
        F.WriteString(cParentForm, cNil);
        F.WriteString(cParentFormClass, '');
        F.WriteString(cDockSite, cNil);
      end else
      begin
        //Получаем указатель на форму на которую задокированя данная ф.
        Form := GetForm(HostDockSite);
        if Form <> nil then
        begin
          if Form.Name = '' then
            raise Exception.Create('Имя формы не может быть пустой строкой');
          //Сохраняем имена
          F.WriteString(cParentForm, Form.Name);
          F.WriteString(cParentFormClass, Form.ClassName);
          F.WriteString(cDockSite, HostDockSite.Name)
        end;
      end;
      //Сохраняем координаты и тип выравнивания
      F.WriteInteger(cAlign, Integer(Align));
      F.WriteBoolean(cVisible, FLocalVisible);
      F.WriteInteger(cLeft, Left);
      F.WriteInteger(cTop, Top);
      F.WriteInteger(cHeight, Height);
      F.WriteInteger(cWidth, Width);
      F.WriteBoolean(cDockable, FDockable);
      if DockForm <> nil then
        F.WriteString(cDockForm, DockForm.Name)
      else
        F.WriteString(cDockForm, cNil);
        
      //закрываем папку
      UserStorage.CloseFolder(F);
    end;
  end;
end;

function TDockableForm.FormByName(Name: string): TCustomForm;
var
  I: Integer;
begin
 Result := nil;
 for I := 0 to Screen.FormCount - 1 do
 begin
   if UpperCase(Screen.Forms[I].Name) = UpperCase(Name) then
   begin
     Result := Screen.Forms[I];
     Break;
   end;
 end;
end;

procedure TDockableForm.FormEndDock(Sender, Target: TObject; X,
  Y: Integer);
begin
  if FBeginDockProcessing then
    FBeginDockProcessing := False;

  //Создаем хандлы для винконтролов
  CheckHandle(Self);
end;

procedure TDockableForm.VisibleChanging;
begin
  FHeight := Height;
  FWidth := Width;
  inherited;
end;

procedure TDockableForm.LoadDesktopSettings;
begin
//Здесь свой механизм сохранения
end;

procedure TDockableForm.SaveDesktopSettings;
begin
//Здесь свой механизм сохранения
end;

procedure TDockableForm.CreateWnd;
begin
  inherited;
  //Создаем хандлы для винконтролов
  CheckHandle(Self);
end;

{procedure TDockableForm.SetVisible(Value: Boolean);
var
  F: TCustomForm;
  B: Boolean;
  H, W: Integer;
begin
  H := Height; W := Width;
  if Value then
    inherited Show
  else
    inherited Hide;
//  inherited Visible := Value;
  Height := h; Width := W;
  if Value then
  begin
    if pCaption.Visible then
      pCaption.Top := 0;
    if HostDockSite <> nil then
    begin
      F := GetForm(HostDockSite);
      if F <> nil then
      begin
        //для TTABDOCKHOST показываем страницу
        if (F is TTABDOCKHOST) or (F is TConjoinDockHost) then
        begin
          TDockableForm(F).Show;
          if (F is TTABDOCKHOST) then
            Parent.Show
        end else
        if (F is Tprp_frm) and (Parent is TPanel) then
        begin
          B := Tprp_frm(F).ReCalcDockBounds;
          Tprp_frm(F).ReCalcDockBounds := False;
          try
            if TPanel(HostDockSite).Align = alBottom then
            begin
              if TPanel(HostDockSite).Height = 0 then
                TPanel(HostDockSite).ClientHeight := Height
            end else
            begin
              if TPanel(HostDockSite).Width = 0 then
                TPanel(HostDockSite).ClientWidth := Width;
            end;
            Tprp_frm(F).ShowDockPanel(TPanel(HostDockSite), True, Self);
          finally
            Tprp_frm(F).ReCalcDockBounds := B;
          end;
        end;
      end;
      HostDockSite.Realign;
    end;
  end else
  begin
    //Если форма задокирована и единственная на DickSite то необходимо
    //спрятать и DockSite
    //Проверяем задокирована ли форма
    if HostDockSite <> nil then
    begin
//      if HostDockSite.VisibleDockClientCount > 0 then Exit;
      //Получаем указатель на окно
      F := GetForm(HostDockSite);
      if F <> nil then
      begin
        if HostDockSite.VisibleDockClientCount = 0 then
        begin
          //Если форма задокирована на TTABDOCKHOST или TCONJOINDOCKHOST
          //то закрываем форму
          if (F is TTABDOCKHOST) or
            (F is TCONJOINDOCKHOST) then
             PostMessage(F.Handle, WM_CLOSE, 0, 0)
          else
          if (F is Tprp_frm) and (Parent is TPanel) then
            Tprp_frm(F).ShowDockPanel(TPanel(Parent), False, Self);
        end else
        begin
          //Для TTABDOCKHOST прячим страницу
          if (F is TTABDOCKHOST) then
            if HostDockSite.VisibleDockClientCount >= 1 then
              Parent.Hide
            else
              PostMessage(F.Handle, WM_CLOSE, 0, 0);
        end;
      end;
    end;
  end;
end;}

{procedure TDockableForm.Show;
begin
  Visible := True;
  BringToFront;
end;

procedure TDockableForm.Hide;
begin
  Visible := False;
end;}

procedure TDockableForm.Close;
var
  CloseAction: TCloseAction;
begin
  if fsModal in FormState then
    ModalResult := mrCancel
  else
    if CloseQuery then
    begin
      if FormStyle = fsMDIChild then
        if biMinimize in BorderIcons then
          CloseAction := caMinimize else
          CloseAction := caNone
      else
        CloseAction := caHide;
      DoClose(CloseAction);
      if CloseAction <> caNone then
        if Application.MainForm = Self then Application.Terminate
        else if CloseAction = caHide then Hide
        else if CloseAction = caMinimize then WindowState := wsMinimized
        else Release;
    end;
end;

procedure TDockableForm.FormResize(Sender: TObject);
begin
  UndockHeight := Height;
  UndockWidth := Width;
end;

procedure TDockableForm.FormCreate(Sender: TObject);
begin
  UseDesigner := False;
  FBeginDockProcessing := False;

//  FDockable := True;
end;

procedure TDockableForm.FormGetSiteInfo(Sender: TObject;
  DockClient: TControl; var InfluenceRect: TRect; MousePos: TPoint;
  var CanDock: Boolean);
var
  R: TRect;
begin
  CanDock := (DockClient is TDockableForm) and (DockClient <> Self) and
    (TDockableForm(DockClient).FDockable) and (FDockable);
  if CanDock then
  begin
    R := ClientRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
    CanDock := PtInRect(R, MousePos);
    if CanDock then
      ComputeDockingRect(InfluenceRect, MousePos);
  end;
end;

procedure TDockableForm.SetDockable(const Value: Boolean);
var
  R: TRect;
begin
  FDockable := Value;
  if not FDockable and (HostDockSite <> nil) then
  begin
    R.TopLeft := HostDockSite.ClientToScreen(BoundsRect.TopLeft);
    R.Right := R.Left + UndockWidth;
    R.Bottom := R.Top + UndockHeight;
    ManualFloat(R);
  end;
end;

procedure TDockableForm.actDockableExecute(Sender: TObject);
begin
  Dockable := not Dockable;
end;

procedure TDockableForm.actDockableUpdate(Sender: TObject);
var
  A: TAction;
begin
  A := TAction(Sender);
  if A.Checked <> FDockable then
    A.Checked := FDockable;
end;

procedure TDockableForm.actStayOnTopExecute(Sender: TObject);
begin
  if FormStyle = fsNormal then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TDockableForm.actStayOnTopUpdate(Sender: TObject);
begin
  TAction(Sender).Checked := StayOnTop;
end;

function TDockableForm.GetStayOnTop: Boolean;
begin
  Result := FormStyle = fsStayOnTop;
end;

procedure TDockableForm.AlignControls(AControl: TControl; var Rect: TRect);
var
  I: Integer;
begin
  if pCaption.Visible then
  begin
    pCaption.Top := 0;
    for I := 0 to ControlCount - 1 do
    begin
      if (Controls[I] <> pCaption) and
        (Controls[I].Align = alTop) then
        Controls[I].Top := Controls[I].Top + pCaption.Height;
    end
  end;

  inherited;
end;

procedure TDockableForm.CMVisibleChanged(var Message: TMessage);
var
  F: TCustomForm;
  B: Boolean;
begin
  inherited;

  Height := FHeight;
  Width := FWidth;
  if not (csDestroying in ComponentState) then
  //Сохраняем флаг видимости. Нужен при сохранении параметров окна, т.к.
  //при закрытии окна п процедуре SaveSettings Visible всегда фолсе
    FLocalVisible := Visible;

  if Visible then
  begin
    if pCaption.Visible then
      pCaption.Top := 0;
    if HostDockSite <> nil then
    begin
      F := GetForm(HostDockSite);
      if F <> nil then
      begin
        //для TTABDOCKHOST показываем страницу
        if (F is TTABDOCKHOST) or (F is TConjoinDockHost) then
        begin
          TDockableForm(F).Show;
          if (F is TTABDOCKHOST) then
            Parent.Show
        end else
        if (F is Tprp_frm) and (Parent is TPanel) then
        begin
          B := Tprp_frm(F).ReCalcDockBounds;
          Tprp_frm(F).ReCalcDockBounds := False;
          try
            if TPanel(HostDockSite).Align = alBottom then
            begin
              if TPanel(HostDockSite).Height = 0 then
                TPanel(HostDockSite).ClientHeight := Height
            end else
            begin
              if TPanel(HostDockSite).Width = 0 then
                TPanel(HostDockSite).ClientWidth := Width;
            end;
            Tprp_frm(F).ShowDockPanel(TPanel(HostDockSite), True, Self);
          finally
            Tprp_frm(F).ReCalcDockBounds := B;
          end;
        end;
      end;
      HostDockSite.Realign;
    end;
  end else
  begin
    //Если форма задокирована и единственная на DickSite то необходимо
    //спрятать и DockSite
    //Проверяем задокирована ли форма
    if HostDockSite <> nil then
    begin
//      if HostDockSite.VisibleDockClientCount > 0 then Exit;
      //Получаем указатель на окно
      F := GetForm(HostDockSite);
      if F <> nil then
      begin
        if HostDockSite.VisibleDockClientCount = 0 then
        begin
          //Если форма задокирована на TTABDOCKHOST или TCONJOINDOCKHOST
          //то закрываем форму
          if (F is TTABDOCKHOST) or
            (F is TCONJOINDOCKHOST) then
             PostMessage(F.Handle, WM_CLOSE, 0, 0)
          else
          if (F is Tprp_frm) and (Parent is TPanel) then
            Tprp_frm(F).ShowDockPanel(TPanel(Parent), False, Self);
        end else
        begin
          //Для TTABDOCKHOST прячим страницу
          if (F is TTABDOCKHOST) then
            if HostDockSite.VisibleDockClientCount >= 1 then
              Parent.Hide
            else
              PostMessage(F.Handle, WM_CLOSE, 0, 0);
        end;
      end;
    end;
  end;

end;

function TDockableForm.FormVisible: boolean;
var
  W: TWinControl;
begin
  if HostDockSite = nil then
    Result := Visible
  else
  begin
    W := self;
    Result := True;
    while (W <> nil) and Result do
    begin
      if W is TSuperPageControl then
      begin
        Result := Visible and Parent.Visible and W.Visible;
        W := TSuperPageControl(W).Parent;
        Continue;
      end else
      if W is TPanel then
      begin
        Result := (W.Width > 0) and (W.Height > 0);
        Exit;
      end else
      begin
        Result := W.Visible;
      end;
      W := W.HostDockSite;
    end;
  end;
end;

procedure TDockableForm.SetZOrder(TopMost: Boolean);
begin
  inherited;
  if TopMost and (Parent <> nil) then
  begin
    if parent is TSuperTabSheet then
    begin
      TSuperTabSheet(parent).PageControl.ActivePage := TSuperTabSheet(parent); 
    end;
  end;
end;

end.

