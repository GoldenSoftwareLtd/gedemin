unit dlgImageListEditor_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ExtDlgs, ComCtrls, StdCtrls, ExtCtrls, ActnList;

type
  TdlgImageListEditor = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Panel3: TPanel;
    Image: TImage;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    OPD: TOpenPictureDialog;
    SPD: TSavePictureDialog;
    IL: TImageList;
    ActionList1: TActionList;
    actAdd: TAction;
    actDelete: TAction;
    actClear: TAction;
    actExport: TAction;
    lvImages: TListView;
    procedure Button3Click(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actClearUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvImagesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
  private
    { Private declarations }
    FImageList: TCustomImageList;
    FLoading: Boolean;
    procedure ShowImages;
    procedure ShowImage;
  public
    { Public declarations }
    function Edit(AnImageList: TCustomImageList): Boolean;
  end;

var
  dlgImageListEditor: TdlgImageListEditor;

implementation

{$R *.dfm}

{ TdlgImageListEditor }

function TdlgImageListEditor.Edit(AnImageList: TCustomImageList): Boolean;
begin
  FImageList := AnImageList;
  IL.Assign(FImageList);
  ShowImages;
  ShowImage;
  if ShowModal = mrOk then
  begin
    FImageList.Assign(IL);
    Result := True;
  end
  else
    Result := False;
  FImageList := nil;
end;

procedure TdlgImageListEditor.ShowImages;
var
  I: Integer;
  L: TListItem;
begin
  Floading := True;
  try
    lvImages.Items.Clear;
    for I := 0 to IL.Count - 1 do
    begin
      L := lvImages.Items.Add;
      L.Caption := IntToStr(I);
      L.ImageIndex := I;
    end;
  finally
    FLoading := False;
  end;
end;

procedure TdlgImageListEditor.Button3Click(Sender: TObject);
begin
  FImageList.Assign(IL);
end;

procedure TdlgImageListEditor.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := lvImages.Selected <> nil
end;

procedure TdlgImageListEditor.actClearExecute(Sender: TObject);
begin
  IL.Clear;
  ShowImages;
  ShowImage;
end;

procedure TdlgImageListEditor.actExportExecute(Sender: TObject);
var
  I: Integer;
  B, B1: TBitmap;
begin
  if SPD.Execute then
  begin
    B := TBitmap.Create;
    try
      B.Height := IL.Height;
      B.Width := IL.Width * IL.Count;
      for I := 0 to IL.Count - 1 do
      begin
        B1 := TBitmap.Create;
        try
//          IL.GetImages(I, B1, nil);
          IL.GetBitmap(I, B1);
          B.Canvas.CopyRect(Rect(I * IL.Width, 0 , (I + 1) * IL.Width, IL.Height), B1.Canvas, Rect(0,0, B1.Width, B1.Height));
        finally
          B1.Free;
        end;
      end;
      B.SaveToFile(SPD.FileName);
    finally
      B.Free;
    end;
  end;
end;

procedure TdlgImageListEditor.actAddExecute(Sender: TObject);
var
  I, J: Integer;
  B: TBitmap;
  C: TColor;
begin
  if OPD.Execute then
  begin
    J := -1;
    for I := 0 to OPD.Files.Count - 1 do
    begin
      B := TBitmap.Create;
      try
        B.LoadFromFile(OPD.Files[I]);
        C := B.Canvas.Pixels[0, B.Height - 1];
        J := IL.AddMasked(B, C);
      finally
        B.Free;
      end;
    end;
    ShowImages;
    if J > -1 then
      lvImages.Selected := lvImages.FindCaption(0, IntToStr(J),False, True, False);
    ShowImage;
  end;
end;

procedure TdlgImageListEditor.actDeleteExecute(Sender: TObject);
begin
  IL.Delete(StrToInt(lvImages.Selected.Caption));
  ShowImages;
  ShowImage;
end;

procedure TdlgImageListEditor.actClearUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lvImages.Items.Count > 0;
end;

procedure TdlgImageListEditor.FormCreate(Sender: TObject);
begin
end;

{ TMyListView }

procedure TdlgImageListEditor.lvImagesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  if not FLoading then
    ShowImage; 
end;

procedure TdlgImageListEditor.ShowImage;
begin
  Image.Canvas.Brush.Style := bsSolid;
  Image.Canvas.Brush.Color := clWhite;
  Image.Align := alClient;
  Image.Canvas.FillRect(Image.Canvas.ClipRect);

  if lvImages.Selected <> nil then
  begin
    IL.GetBitmap(StrToInt(lvImages.Selected.Caption), Image.Picture.Bitmap);
  end;
end;

end.
