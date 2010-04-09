unit FindReplace;

//------------------------------------------------------------------------------
// Module:           FindReplace                                               .
// Version:          1.0                                                       .
// Date:             16 March 2003                                             .
// Compilers:        Delphi 3 - Delphi 7                                       .
// Author:           Angus Johnson - angusj-AT-myrealbox-DOT-com               .
// Copyright:        © 2001 -2003  Angus Johnson                               .
//                                                                             .
// Description:      Dialogs to aid find & replace text                        .
//------------------------------------------------------------------------------


interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  StdCtrls, ExtCtrls, Graphics, dmImages_unit;

type
  TReplaceType = (rtOK, rtSkip, rtAll, rtCancel);

  TFindInfo = record
    findStr: string;
    replaceStr: string;
    directionDown: boolean;
    ignoreCase: boolean;
    wholeWords: boolean;
    replacePrompt: boolean;
    replaceAll: boolean;
  end;

//find dialog ( text to find can be passed via fi.findStr ) ...
function GetFindInfo(aOwner: TCustomForm; var fi: TFindInfo): boolean;

//find replace dialog ( text to find can be passed via fi.findStr ) ...
function GetReplaceInfo(aOwner: TCustomForm; var fi: TFindInfo): boolean;

//replace prompt dialog ( requires a previous call to GetReplaceInfo() ) ...
function ReplacePrompt(aOwner: TCustomForm; Point: TPoint): TReplaceType;

procedure FindFree; //forcibly free resources
                    //nb:resources will automatically be freed on app close
                    //as FindForm is owned by application.mainform.

implementation

type
  TFindForm = class(TForm)
  private
    fOwner: TCustomForm;
    fReplaceAll: boolean;
    FindText: TEdit;
    FindLabel: TLabel;
    ReplaceLabel: TLabel;
    ReplaceText: TEdit;
    GroupBox1: TGroupBox;
    CaseSensitive: TCheckBox;
    WholeWords: TCheckBox;
    Prompt: TCheckBox;
    GroupBox2: TGroupBox;
    Forwards: TRadioButton;
    Backwards: TRadioButton;
    OKBtn: TButton;
    AllBtn: TButton;
    CancelBtn: TButton;
    procedure FindTextChange(Sender: TObject);
    procedure CenterForm;
  public
    constructor create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TReplaceForm = class(TForm)
  private
    fOwner: TCustomForm;
    FindText: TEdit;
    FindLabel: TLabel;
    ReplaceText: TEdit;
    ReplaceLabel: TLabel;
    OKBtn: TButton;
    SkipBtn: TButton;
    AllBtn: TButton;
    CancelBtn: TButton;
  public
    constructor create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

//------------------------------------------------------------------------------
// TFindForm methods ...
//------------------------------------------------------------------------------

constructor TFindForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  width := 304;
  height := 231;
  caption := 'Замена';
  BorderIcons := [biSystemMenu];
  BorderStyle := bsDialog;
  Font.Assign(TCustomForm(AOwner).Font);
  Position := poDesktopCenter;

  FindText := TEdit.Create(self);
  FindText.parent := self;
  FindText.left := 100;
  FindText.top := 14;
  FindText.width := 178;
  FindText.OnChange := FindTextChange;

  FindLabel := TLabel.Create(self);
  FindLabel.parent := self;
  FindLabel.left := 15;
  FindLabel.top := 17;
  FindLabel.caption := 'Искомый текст:';
  FindLabel.focusControl := FindText;

  ReplaceText := TEdit.Create(self);
  ReplaceText.parent := self;
  ReplaceText.left := 100;
  ReplaceText.top := 41;
  ReplaceText.width := 178;

  ReplaceLabel := TLabel.Create(self);
  ReplaceLabel.parent := self;
  ReplaceLabel.left := 15;
  ReplaceLabel.top := 44;
  ReplaceLabel.caption := 'Заменить:';
  ReplaceLabel.focusControl := ReplaceText;

  GroupBox1 := TGroupBox.Create(self);
  GroupBox1.Parent := self;
  GroupBox1.Caption := 'Опции';
  GroupBox1.setbounds(15,72,148,84);

  CaseSensitive := TCheckBox.Create(self);
  CaseSensitive.Parent := GroupBox1;
  CaseSensitive.Caption := 'С учётом регистра';
  CaseSensitive.setbounds(12,19,120,18);

  WholeWords := TCheckBox.Create(self);
  WholeWords.Parent := GroupBox1;
  WholeWords.Caption := 'Слово целиком';
  WholeWords.setbounds(12,39,120,18);

  Prompt := TCheckBox.Create(self);
  Prompt.Parent := GroupBox1;
  Prompt.Caption := 'Запрос на замену';
  Prompt.setbounds(12,59,120,18);
  Prompt.Checked := true;

  GroupBox2 := TGroupBox.Create(self);
  GroupBox2.Parent := self;
  GroupBox2.Caption := 'Направление';
  GroupBox2.setbounds(176,72,102,84);

  Forwards := TRadioButton.Create(self);
  Forwards.Parent := GroupBox2;
  Forwards.Caption := 'Вперёд';
  Forwards.setbounds(12,26,80,18);
  Forwards.Checked := true;
  //Forwards.Enabled := false;

  Backwards := TRadioButton.Create(self);
  Backwards.Parent := GroupBox2;
  Backwards.Caption := 'Назад';
  Backwards.setbounds(12,47,80,18);
  //Backwards.Enabled := false;

  OKBtn := TButton.create(self);
  OKBtn.Parent := self;
  OKBtn.Default := true;
  OKBtn.caption := 'Заменить';
  OKBtn.Enabled := false;
  OKBtn.ModalResult := mrOK;
  OKBtn.SetBounds(15,165,75,25);

  AllBtn := TButton.create(self);
  AllBtn.Parent := self;
  AllBtn.Enabled := false;
  AllBtn.caption := 'Заменить все';
  AllBtn.ModalResult := mrYes;
  AllBtn.SetBounds(111,165,80,25);

  CancelBtn := TButton.create(self);
  CancelBtn.Parent := self;
  CancelBtn.Cancel := true;
  CancelBtn.Enabled := true;
  CancelBtn.caption := 'Отмена';
  CancelBtn.ModalResult := mrCancel;
  CancelBtn.SetBounds(204,165,75,25);
end;
//------------------------------------------------------------------------------

procedure TFindForm.FindTextChange(Sender: TObject);
begin
  if FindText.text = '' then begin
    OKBtn.enabled := false;
    AllBtn.enabled := false;
    end
  else begin
    OKBtn.enabled := true;
    AllBtn.enabled := true;
  end;
end;
//------------------------------------------------------------------------------

procedure TFindForm.CenterForm;
//var
//  l,t: integer;
begin
//  if not assigned(fOwner) then exit;
//  l := fOwner.left + (fOwner.width-width) div 2;
//  t := fOwner.top + (fOwner.height-height) div 2;
//  setbounds(l,t,width,height);
end;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// TReplaceForm methods ...
//------------------------------------------------------------------------------

constructor TReplaceForm.create(AOwner: TComponent);
begin
  inherited  CreateNew(AOwner);
  width := 313;
  height := 126;
  caption := 'Запрос на замену';
  BorderIcons := [biSystemMenu];
  BorderStyle := bsDialog;
  Font.Assign(TCustomForm(AOwner).Font);

  FindText := TEdit.Create(self);
  FindText.parent := self;
  FindText.left := 69;
  FindText.top := 10;
  FindText.width := 220;
  FindText.color := clBtnFace;
  FindText.ReadOnly := true;
  FindText.TabStop := false;

  FindLabel := TLabel.Create(self);
  FindLabel.parent := self;
  FindLabel.left := 15;
  FindLabel.top := 14;
  FindLabel.caption := 'Заменить:';
  FindLabel.focusControl := FindText;

  ReplaceText := TEdit.Create(self);
  ReplaceText.parent := self;
  ReplaceText.left := 69;
  ReplaceText.top := 34;
  ReplaceText.width := 220;
  ReplaceText.color := clBtnFace;
  ReplaceText.ReadOnly := true;
  ReplaceText.TabStop := false;

  ReplaceLabel := TLabel.Create(self);
  ReplaceLabel.parent := self;
  ReplaceLabel.left := 15;
  ReplaceLabel.top := 37;
  ReplaceLabel.caption := 'На:';
  ReplaceLabel.focusControl := ReplaceText;

  OKBtn := TButton.create(self);
  OKBtn.Parent := self;
  OKBtn.Default := true;
  OKBtn.caption := 'Да';
  OKBtn.ModalResult := mrOK;
  OKBtn.SetBounds(15,68,64,22);

  SkipBtn := TButton.create(self);
  SkipBtn.Parent := self;
  SkipBtn.caption := 'Нет';
  SkipBtn.ModalResult := mrNo;
  SkipBtn.SetBounds(84,68,64,22);

  AllBtn := TButton.create(self);
  AllBtn.Parent := self;
  AllBtn.caption := 'Заменить все';
  AllBtn.ModalResult := mrYes;
  AllBtn.SetBounds(150,68,72,22);

  CancelBtn := TButton.create(self);
  CancelBtn.Parent := self;
  CancelBtn.Cancel := true;
  CancelBtn.caption := 'Отмена';
  CancelBtn.ModalResult := mrCancel;
  CancelBtn.SetBounds(225,68,64,22);

end;
//------------------------------------------------------------------------------


var
  FindForm: TFindForm;
  ReplaceForm: TReplaceForm;

procedure FindCreate(aOwner: TCustomForm);
begin
  if assigned(FindForm) then exit;
  FindForm := TFindForm.create(aOwner);
end;
//------------------------------------------------------------------------------

procedure ReplaceCreate(aOwner: TCustomForm);
begin
  if Assigned(ReplaceForm) then exit;
  ReplaceForm := TReplaceForm.Create(aOwner);
end;
//------------------------------------------------------------------------------

procedure FindFree;
begin
  if assigned(FindForm) then FindForm.free;
  FindForm := nil;
  if assigned(ReplaceForm) then ReplaceForm.free;
  ReplaceForm := nil;
end;
//------------------------------------------------------------------------------

function GetFindInfo(aOwner: TCustomForm; var fi: TFindInfo): boolean;
begin
  FindCreate(aOwner);
  result := false;
  with FindForm do
  begin
    fOwner := aOwner;
    caption := 'Поиск';
    if fi.findStr <> '' then findText.Text := fi.findStr;
    findText.SelectAll;
    Groupbox1.height := 65;
    Groupbox1.top := 41;
    Groupbox2.height := 65;
    Groupbox2.top := 41;
    Forwards.Top := 19;
    Backwards.top := 39;
    OKBtn.top := 119;
    OKBtn.caption := '&OK';
    OKBtn.left := 63;
    AllBtn.visible := false;
    CancelBtn.top := 119;
    CancelBtn.left := 156;
    prompt.visible := false;
    ReplaceLabel.visible := false;
    replacetext.visible := false;
    height := 182;
    ActiveControl := FindText;
    CenterForm;
    if showmodal <> mrOK then exit;
    fi.findStr := FindText.Text;
    fi.ignoreCase := not CaseSensitive.Checked;
    fi.wholeWords := WholeWords.Checked;
    fi.directionDown := Forwards.Checked;
  end;
  result := true;
end;
//------------------------------------------------------------------------------

function GetReplaceInfo(aOwner: TCustomForm; var fi: TFindInfo): boolean;
var
  mr: TModalResult;
begin
  FindCreate(aOwner);
  result := false;
  with FindForm do
  begin
    fOwner := aOwner;
    caption := 'Заменить';
    if fi.findStr <> '' then findText.Text := fi.findStr;
    findText.SelectAll;
    Groupbox1.height := 84;
    Groupbox1.top := 72;
    Groupbox2.height := 84;
    Groupbox2.top := 72;
    Forwards.Top := 26;
    Backwards.top := 47;
    OKBtn.top := 165;
    OKBtn.caption := 'Заменить';
    OKBtn.left := 15;
    AllBtn.visible := true;
    CancelBtn.top := 165;
    CancelBtn.left := 204;
    prompt.visible := true;
    ReplaceLabel.visible := true;
    replacetext.visible := true;
    height := 231;
    ActiveControl := FindText;

    CenterForm;
    mr := showmodal;
    if not (mr in [mrOK,mrYes]) then exit;
    fi.findStr := FindText.Text;
    fi.replaceStr := ReplaceText.Text;
    fi.ignoreCase := not CaseSensitive.Checked;
    fi.wholeWords := WholeWords.Checked;
    fi.directionDown := Forwards.Checked;
    fi.replacePrompt := Prompt.Checked;
    fi.replaceAll := (mr = mrYes);
    fReplaceAll := fi.replaceAll;
  end;
  result := true;
end;
//------------------------------------------------------------------------------

function ReplacePrompt(aOwner: TCustomForm; Point: TPoint): TReplaceType;
var
  mr: TModalResult;
begin
  result := rtCancel;
  if not assigned(FindForm) or (aOwner = nil) then exit;
  Point := aOwner.ClientToScreen(Point);
  ReplaceCreate(aOwner);
  with ReplaceForm do
  begin
    fOwner := aOwner;
    FindText.Text := FindForm.FindText.Text;
    findText.SelectAll;
    ReplaceText.Text := FindForm.ReplaceText.Text;
    if Point.x + width > screen.width then
      Point.x := screen.width - width - 4;
    Left := Point.x;
    if Point.y - height -8 > 0 then
      Top := Point.y - height -8 else
      Top := Point.y + 30; //30 = guess at lineheight with some margin
    ActiveControl := OkBtn;
    SkipBtn.Enabled := FindForm.fReplaceAll;
    AllBtn.Enabled := FindForm.fReplaceAll;
    mr := ShowModal;
    case mr of
      mrOK: result := rtOK;
      mrNo: result := rtSkip;
      mrYes: result := rtAll;
      else result := rtCancel;
    end;
  end;
end;
//------------------------------------------------------------------------------

destructor TFindForm.Destroy;
begin
  inherited;
  FindForm := nil;
end;

destructor TReplaceForm.Destroy;
begin
  inherited;
  ReplaceForm := nil;
end;

end.

