{++

  Components 
  Copyright c) 1996 - 97 by Golden Software

  Module

    xMemo.pas

  Abstract
  
    Like TMemo but with multilangual support.

  Author

    Vladimir Belyi (March, 1997)

  Contact address

    andreik@gs.minsk.by

  Uses

    Units:

      xWorld

    Forms:

      xMemoEdF

    Other files:

  Revisions history

    1.00  16-mar-1997  belyi   Initial version

  Known bugs

    -

  Wishes

    -

  Notes/comments

    -

--}

unit xMemo;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DsgnIntF, StdCtrls, ExtCtrls, Menus,
  xBasics, xWorld;

type
  TxMemoLang = class
    Lang: string;
    Lines: TStringList;
    constructor Create; 
    destructor Destroy; override;
    procedure Assign(Source: TxMemoLang);
  end;

  TxMemo = class(TCustomMemo)
  private
    { Private declarations }
    LinesList: TClasslist;
    procedure ReadLinesList(Reader: TReader);
    procedure WriteLinesList(Writer: TWriter);
    procedure ReadStringData(Reader: TReader);

  protected
    { Protected declarations }
    procedure AddLanguage(Name: string);
    procedure AddLanguages;
    procedure WM_LANG(var Msg: TMessage); message WM_LANGUAGECHANGE;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Loaded; override;

  public
    { Public declarations }
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateLines;

  published
    { Published declarations }
    property Align;
    property Alignment;
    property BorderStyle;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property Lines;
    property MaxLength;
    property OEMConvert;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ScrollBars;
    property ShowHint;
    property Visible;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

uses
  xMemoEdF;

constructor TxMemoLang.Create;
begin
  inherited Create;
  Lang := '';
  Lines := TStringList.Create;
end;

destructor TxMemoLang.Destroy;
begin
  Lines.Free;
  inherited Destroy;
end;

procedure TxMemoLang.Assign(Source: TxMemoLang);
begin
  Lang := Source.Lang;
  Lines.Assign(Source.Lines);
end;

{ ================ TxMemo ========================= }
constructor TxMemo.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  LinesList := TClassList.Create;
  AddLanguages;
  TabStop := false;
  Color := clBtnFace;
  Ctl3D := false;
  ParentCtl3D := false;
  Cursor := crArrow;
end;

destructor TxMemo.Destroy;
begin
  LinesList.Free;
  inherited Destroy;
end;

procedure TxMemo.Loaded;
begin
  inherited Loaded;
  UpdateLines;
end;

procedure TxMemo.AddLanguage(Name: string);
var
  Ln: TxMemoLang;
begin
  Ln := TxMemoLang.create;
  Ln.Lang := Name;
  Ln.Lines.Add(name);
  LinesList.Add(Ln);
end;

procedure TxMemo.AddLanguages;
var
  i, j: Integer;
  Have: Boolean;
begin
  for i := 0 to Phrases.LanguagesCount - 1 do
   begin
     Have := false;
     for j := 0 to LinesList.Count - 1 do
       if CompareText(TxMemoLang(LinesList[j]).Lang,
            Phrases.Languages[i]) = 0
       then
         Have := true;
     if not Have then
       AddLanguage(Phrases.Languages[i]);
   end; 
end;

procedure TxMemo.WM_LANG(var Msg: TMessage);
begin
  AddLanguages;
  UpdateLines;
end;

procedure TxMemo.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('LinesList', ReadLinesList, WriteLinesList, true);
  Filer.DefineProperty('Text', ReadStringData, nil, False);
end;

procedure TxMemo.ReadLinesList(Reader: TReader);
var
  Ln: TxMemoLang;
begin
  LinesList.Clear;
  Reader.ReadListBegin;
  while not Reader.EndOfList do
   begin
     Ln := TxMemoLang.Create;
     Ln.Lang := Reader.ReadString;
     Reader.ReadListBegin;
     while not Reader.EndOfList do
       Ln.Lines.Add(Reader.ReadString);
     Reader.ReadListEnd;
     LinesList.Add(Ln);
   end;
  Reader.ReadListEnd;
end;

procedure TxMemo.WriteLinesList(Writer: TWriter);
var
  i, j: Integer;
begin
  Writer.WriteListBegin;
  for i := 0 to LinesList.Count - 1 do
   begin
     Writer.WriteString(TxMemoLang(LinesList[i]).Lang);
     Writer.WriteListBegin;
     for j := 0 to TxMemoLang(LinesList[i]).Lines.Count - 1 do
       Writer.WriteString(TxMemoLang(LinesList[i]).Lines[j]);
     Writer.WriteListEnd;
   end;
  Writer.WriteListEnd;
end;

procedure TxMemo.UpdateLines;
var
  j: Integer;
begin
  for j := 0 to LinesList.Count - 1 do
    if CompareText(TxMemoLang(LinesList[j]).Lang, Phrases.LanguageName) = 0
    then
      inherited Lines.Assign(TxMemoLang(LinesList[j]).Lines);
end;

procedure TxMemo.ReadStringData(Reader: TReader);
begin
  Reader.ReadString;
end;

{ ======== TxLinesProperty ========= }

type
  TxLinesProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
  end;

function TxLinesProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paMultiSelect, paReadOnly];
end;

function TxLinesProperty.GetValue: string;
begin
  Result := 'TStrings';
end;

procedure TxLinesProperty.Edit;
var
  Comp: TxMemo;
  Form: TxMemoLinesForm;
  i, j: Integer;
  Ln: TxMemoLang;
begin
  Application.CreateForm(TxMemoLinesForm, Form);
  try
    Comp := GetComponent(0) as TxMemo;

    { refresh languages structure(user might have added new languages) }
    Comp.AddLanguages;

    { copy languages list }
    Form.Languages.Tabs.Clear;
    for i := 0 to Comp.LinesList.Count - 1 do
      Form.Languages.Tabs.Add(TxMemoLang(Comp.LinesList[i]).Lang);

    { copy memo-lines }
    Form.LinesList.Clear;
    for i := 0 to Comp.LinesList.Count - 1 do
     begin
       Ln := TxMemoLang.Create;
       Ln.Assign(TxMemoLang(Comp.LinesList[i]));
       Form.LinesList.Add(Ln);
     end;

    { set current language }
    Form.SetLanguage(Phrases.LanguageName);

    if Form.ShowModal = mrOk then
      for i := 0 to PropCount - 1 do
       begin
        (GetComponent(i) as TxMemo).LinesList.Clear;
        for j := 0 to Form.LinesList.Count - 1 do
         begin
           Ln := TxMemoLang.Create;
           Ln.Assign(TxMemoLang(Form.LinesList[j]));
           (GetComponent(i) as TxMemo).LinesList.Add(Ln);
         end;
        (GetComponent(i) as TxMemo).UpdateLines;
       end;

  finally
    Form.Free;
  end;
end;

{ ============== registration section ============= }
procedure Register;
begin
  RegisterComponents('xWind', [TxMemo]);
  RegisterPropertyEditor(TypeInfo(TStrings), TxMemo, 'Lines',
    TxLinesProperty);
end;

end.
