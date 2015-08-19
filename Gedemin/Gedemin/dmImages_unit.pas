

unit dmImages_unit;

interface
                       
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList;

type
  TdmImages = class(TDataModule)
    ilTree: TImageList;
    ilToolBarSmall: TImageList;
    il16x16: TImageList;
    imSynEdit: TImageList;
    imglGutterGlyphs: TImageList;
    imTreeView: TImageList;
    imglActions: TImageList;
    imFunction: TImageList;
    ImageList: TImageList;
    ilConditionType: TImageList;
    ilSelectDoc: TImageList;
    procedure DataModuleCreate(Sender: TObject);

  end;

var
  dmImages: TdmImages;
const
  iiGreenCircle = 195;
  iiFunction = 137;
  iiRunning = 258;
  oiRunning = 0;
  iiCopy = 10;
  iiCut = 9;
  iiPast = 11;
  iiProperties = 1;
  iiDelete = 2;

implementation

{$R *.DFM}

procedure TdmImages.DataModuleCreate(Sender: TObject);
begin
  il16x16.Overlay(iiRunning, oiRunning);
end;

end.
