unit rpl_dmImages_unit;

interface

uses
  SysUtils, Classes, ImgList, Controls;

type
  TdmImages = class(TDataModule)
    il16x16: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmImages: TdmImages;

implementation

{$R *.dfm}

end.
