(***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower Async Professional
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 1991-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{*********************************************************}
{*                   AWFAXCVT.PAS 4.06                   *}
{*********************************************************}
{* Low-level fax conversion/unpacking utilities          *}
{*********************************************************}

{
  Used by the TApdFaxUnpacker and TApdFaxConverter (AdFaxCvt.pas), and
  by the printer drivers.
}

{Global defines potentially affecting this unit}
{$I AWDEFINE.INC}

{Options required for this unit}
{$V-,I-,B-,X+,G+,O-}

{$IFNDEF PrnDrv}
{$J+,H+}
{$ENDIF}

{$IFNDEF PRNDRV}
  {$DEFINE BindFaxFont}
{$ENDIF}

unit AwFaxCvt;
  {-Fax conversion}

interface

uses
  {-------RTL}
  {$IFNDEF Prndrv}
  Graphics,
  Classes,
  Controls,
  Forms,
  {$ENDIF}
  WinTypes,
  WinProcs,
  SysUtils,
  Messages,
  {-------APW}
  OoMisc;

{--Abstract converter functions--}

procedure acInitFaxConverter(var Cvt : PAbsFaxCvt; Data : Pointer;
                            CB : TGetLineCallback; OpenFile : TOpenFileCallback;
                            CloseFile : TCloseFileCallback; DefaultExt : PChar);
  {-Initialize a fax converter engine}

procedure acDoneFaxConverter(var Cvt : PAbsFaxCvt);
  {-Destroy a fax converter engine}

procedure acSetOtherData(Cvt : PAbsFaxCvt; OtherData : Pointer);
  {-Set other data pointer}

procedure acOptionsOn(Cvt : PAbsFaxCvt; OptionFlags : Word);
  {-Activate multiple fax converter options}

procedure acOptionsOff(Cvt : PAbsFaxCvt; OptionFlags : Word);
  {-Deactivate multiple options}

function acOptionsAreOn(Cvt : PAbsFaxCvt; OptionFlags : Word) : Bool;
  {-Return TRUE if all specified options are on}

procedure acSetMargins(Cvt : PAbsFaxCvt; Left, Top : Cardinal);
  {-Set left and top margins for converter}

procedure acSetResolutionMode(Cvt : PAbsFaxCvt; HiRes : Bool);
  {-Select standard or high resolution mode}

procedure acSetResolutionWidth(Cvt : PAbsFaxCvt; RW : Cardinal);
  {-Select standard (1728 pixels) or wide (2048 pixels) width}

procedure acSetStationID(Cvt : PAbsFaxCvt; ID : PChar);
  {-Set the station ID of the converter}

procedure acSetStatusCallback(Cvt : PAbsFaxCvt; CB : TCvtStatusCallback);
  {-Set the procedure called for conversion status}

procedure acSetStatusWnd(Cvt : PAbsFaxCvt; HWindow : TApdHwnd);
  {-Set the handle of the window that receives status messages}

function acOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
  {-Open a converter input file}

procedure acCloseFile(Cvt : PAbsFaxCvt);
  {-Close a converter input file}

function acGetRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                         var EndOfPage, MorePages : Bool) : Integer;
  {-Read a raster line from an input file}

function acCreateOutputFile(Cvt : PAbsFaxCvt) : Integer;
  {-Create an APF file}

function acCloseOutputFile(Cvt : PAbsFaxCvt) : Integer;
  {-Close an APF file}

procedure acInitDataLine(Cvt : PAbsFaxCvt);
  {-Initialize the converter's line buffer}

function acAddData(Cvt : PAbsFaxCvt; var Buffer; Len : Cardinal; DoInc : Bool) : Integer;
  {-Add a block of data to the output file}

function acAddLine(Cvt : PAbsFaxCvt; var Buffer; Len : Cardinal) : Integer;
  {-Add a line of image data to the file}

procedure acCompressRasterLine(Cvt : PAbsFaxCvt; var Buffer);
  {-compress a raster line of bits into runlength codes}

procedure acMakeEndOfPage(Cvt : PAbsFaxCvt; var Buffer; var Len : Integer);
  {-Encode end-of-page data into Buffer}

function acOutToFileCallback(Cvt : PAbsFaxCvt; var Data; Len : Integer;
                             EndOfPage, MorePages : Bool) : Integer;
  {-Output a compressed raster line to an APF file}

function acConvertToFile(Cvt : PAbsFaxCvt; FileName, DestFile : PChar) : Integer;
  {-Convert an image to a fax file}

function acConvert(Cvt : PAbsFaxCvt; FileName : PChar;
                   OutCallback : TPutLineCallback) : Integer;
  {-Convert an input file, sending data to OutHandle or to OutCallback}

{$IFNDEF PRNDRV}                                                 
{--Text converter functions--}

procedure fcInitTextConverter(var Cvt : PAbsFaxCvt);
  {-Initialize a text-to-fax converter}

procedure fcDoneTextConverter(var Cvt : PAbsFaxCvt);
  {-Destroy a text-to-fax converter}

procedure fcInitTextExConverter(var Cvt : PAbsFaxCvt);  
  {-Initialize an extended text-to-fax converter}

procedure fcDoneTextExConverter(var Cvt : PAbsFaxCvt); 
  {-Destroy an extended text-to-fax converter}

procedure fcSetTabStop(Cvt : PAbsFaxCvt; TabStop : Cardinal);
  {-Set the number of spaces equivalent to a tab character}

function fcLoadFont(Cvt : PAbsFaxCvt; FileName : PChar;
                    FontHandle : Cardinal; HiRes : Bool) : Integer;
  {-Load selected font from APFAX.FNT or memory}

function fcSetFont(Cvt : PAbsFaxCvt; Font : TFont; HiRes : Boolean) : Integer;  
  {-Set font for extended text converter}

procedure fcSetLinesPerPage(Cvt : PAbsFaxCvt; LineCount : Cardinal);
  {-Set the number of text lines per page}

function fcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
  {-Open a text file for input}

procedure fcCloseFile(Cvt : PAbsFaxCvt);
  {-Close text file}

procedure fcRasterizeText(Cvt : PAbsFaxCvt; St : PChar; Row : Cardinal; var Data);
  {-Turn a row in a string into a raster line}

function fcGetTextRasterLine( Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                              var EndOfPage, MorePages : Bool) : Integer;
  {-Callback to convert one row of a string into a raster line}

{--TIFF converter functions--}

procedure tcInitTiffConverter(var Cvt : PAbsFaxCvt);
  {-Initialize a TIFF-to-fax converter}

procedure tcDoneTiffConverter(var Cvt : PAbsFaxCvt);
  {-Destroy a TIFF converter}

function tcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
  {-Open a TIFF file for input}

procedure tcCloseFile(Cvt : PAbsFaxCvt);
  {-Close TIFF file}

function tcGetTiffRasterLine( Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                              var EndOfPage, MorePages : Bool) : Integer;
  {-Callback to read a row of TIFF raster data}

{--PCX converter functions--}

procedure pcInitPcxConverter(var Cvt : PAbsFaxCvt);
  {-Initialize a PCX-to-fax converter}

procedure pcDonePcxConverter(var Cvt : PAbsFaxCvt);
  {-Destroy a PCX-to-fax converter}

function pcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
  {-Open a PCX file for input}

procedure pcCloseFile(Cvt : PAbsFaxCvt);
  {-Close PCX file}

function pcGetPcxRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                            var EndOfPage, MorePages : Bool) : Integer;
  {-Callback to read a row of PCX raster data}

{--DCX converter functions--}

procedure dcInitDcxConverter(var Cvt : PAbsFaxCvt);
  {-Initialize a DCX-to-fax converter}

procedure dcDoneDcxConverter(var Cvt : PAbsFaxCvt);
  {-Destroy a PCX-to-fax converter}

function dcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
  {-Open a DCX file for input}

procedure dcCloseFile(Cvt : PAbsFaxCvt);
  {-Close DCX file}

function dcGetDcxRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                            var EndOfPage, MorePages : Bool) : Integer;
  {-Callback to read a row of DCX raster data}

{--BMP converter functions--}

procedure bcInitBmpConverter(var Cvt : PAbsFaxCvt);
  {-Initialize a BMP-to-fax converter}

procedure bcDoneBmpConverter(var Cvt : PabsFaxCvt);
  {-Destroy a BMP-to-fax converter}

function bcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
  {-Open a BMP file for input}

procedure bcCloseFile(Cvt : PAbsFaxCvt);
  {-Close BMP file}

function bcGetBmpRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                            var EndOfPage, MorePages : Bool) : Integer;
  {-Callback to read a row of BMP raster data}

procedure bcInitBitmapConverter(var Cvt : PAbsFaxCvt);
  {-Initialize a bitmap-to-fax converter}

procedure bcDoneBitmapConverter(var Cvt : PAbsFaxCvt);
  {-Destroy a bitmap-to-fax converter}

function bcSetInputBitmap(var Cvt : PAbsFaxCvt; Bitmap : HBitmap) : Integer;
  {-Set bitmap that will be converted}

function bcOpenBitmap(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
  {-Open bitmap "file"}

procedure bcCloseBitmap(Cvt : PAbsFaxCvt);
  {-Close bitmap "file"}

function bcGetBitmapRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                               var EndOfPage, MorePages : Bool) : Integer;
  {-Read a raster line from a bitmap}

{--Basic fax unpacker--}


function upInitFaxUnpacker( var Unpack : PUnpackFax; Data : Pointer;
                            CB : TUnpackLineCallback) : Integer;
  {-Initialize a fax unpacker}

procedure upDoneFaxUnpacker(var Unpack : PUnpackFax);
  {-Destroy a fax unpacker}

procedure upOptionsOn(Unpack : PUnpackFax; OptionFlags : Word);
  {-Turn on one or more unpacker options}

procedure upOptionsOff(Unpack : PUnpackFax; OptionFlags : Word);
  {-Turn off one or more unpacker options}

function upOptionsAreOn(Unpack : PUnpackFax; OptionFlags : Word) : Bool;
  {-Return True if all specified options are on}

procedure upSetStatusCallback(Unpack : PUnpackFax; Callback : TUnpackStatusCallback);
  {-Set up a routine to be called to report unpack status}

function upSetWhitespaceCompression(Unpack : PUnpackFax; FromLines, ToLines : Cardinal) : Integer;

  {-Set the whitespace compression option.}

procedure upSetScaling(Unpack : PUnpackFax; HMult, HDiv, VMult, VDiv : Cardinal);
  {-Set horizontal and vertical scaling factors}

function upGetFaxHeader(Unpack : PUnpackFax; FName : PChar; var FH : TFaxHeaderRec) : Integer;
  {-Return header for fax FName}

function upGetPageHeader(Unpack : PUnpackFax; FName : PChar; Page : Cardinal; var PH : TPageHeaderRec) : Integer;

  {-Return header for Page in fax FName}

function upUnpackPage(Unpack : PUnpackFax; FName : PChar; Page : Cardinal) : Integer;
  {-Unpack page number Page, calling the put line callback for each raster line}

function upUnpackFile(Unpack : PUnpackFax; FName : PChar) : Integer;
  {-Unpack all pages in a fax file}

function upUnpackPageToBitmap(Unpack : PUnpackFax; FName : PChar; Page : Cardinal;
                              var Bmp : TMemoryBitmapDesc; Invert : Bool) : Integer;

  {-Unpack a page of fax into a memory bitmap}

function upUnpackFileToBitmap(Unpack : PUnpackFax; FName : PChar; var Bmp : TMemoryBitmapDesc;
                              Invert : Bool) : Integer;

  {-Unpack a fax into a memory bitmap}

function upUnpackFileToBuffer(Unpack : PUnpackFax; FName : PChar) : Integer;

  {-Unpack a fax into a memory bitmap}

function upUnpackPageToBuffer(Unpack : PUnpackFax; FName : PChar; Page : Cardinal; UnpackingFile : Boolean) : Integer;

  {-Unpack a page of fax into a memory bitmap}

function upPutMemoryBitmapLine(Unpack : PUnpackFax; plFlags : Word; var Data; Len, PageNum : Cardinal) : Integer;

  {-Callback to output a raster line to an in-memory bitmap}

{--Output to image file routines--}

function upUnpackPageToPcx(Unpack : PUnpackFax; FName, OutName : PChar; Page : Cardinal) : Integer;

  {-Unpack one page of an APF file to a PCX file}

function upUnpackFileToPcx(Unpack : PUnpackFax; FName, OutName : PChar) : Integer;

  {-Unpack an APF file to a PCX file}

function upUnpackPageToDcx(Unpack : PUnpackFax; FName, OutName : PChar; Page : Cardinal) : Integer;

  {-Unpack one page of an APF file to a DCX file}

function upUnpackFileToDcx(Unpack : PUnpackFax; FName, OutName : PChar) : Integer;

  {-Unpack an APF file to a DCX file}

function upUnpackPageToTiff(Unpack : PUnpackFax; FName, OutName : PChar; Page : Cardinal) : Integer;

  {-Unpack one page of an APF file to a TIF file}

function upUnpackFileToTiff(Unpack : PUnpackFax; FName, OutName : PChar) : Integer;

  {-Unpack an APF file to a TIF file}

function upUnpackPageToBmp(Unpack : PUnpackFax; FName, OutName : PChar; Page : Cardinal) : Integer;

  {-Unpack one page of an APF file to a BMP file}

function upUnpackFileToBmp(Unpack : PUnpackFax; FName, OutName : PChar) : Integer;

  {-Unpack an APF file to a BMP file}

{--misc--}
function awIsAnAPFFile(FName : PChar) : Bool;
  {-Return TRUE if the file FName is a valid APF file}

{$ENDIF}

implementation


{$IFDEF BindFaxFont}
{$IFDEF Win32}
{$R AWFAXCVT.R32}
{$ELSE}
{$R AWFAXCVT.R16}
{$ENDIF}
{$ENDIF}

const
  {General}
  DefUpdateInterval          = 16;          {Lines per status call}
  DefFontFile                = 'APFAX.FNT'; {Default font file name}
  FaxFileExt                 = 'APF';       {Fax file extension}
  DefLeftMargin              = 50;          {Default left margin of 1/4 inch}
  DefTopMargin               = 0;           {Default top margin of zero}
  DefFaxTabStop              = 4;           {Default tab stops}

  {Default fax conversion options}
  DefFaxCvtOptions = fcYield + fcDoubleWidth + fcCenterImage;

  {No bad options}
  BadFaxCvtOptions = 0;

  ReadBufferSize = 8192;        {Max size of file read buffer}
  LinePadSize    = 2;           {Assure this many nulls per line}
  MaxFontBytes   = 24576;       {Maximum bytes for a font}
  LineBufSize    = 512;         {Size of unpacker's line buffer}

  {End of line bit codes for fax images}
  EOLRec     : TCodeRec = (Code : $0001; Sig : 12);
  LongEOLRec : TCodeRec = (Code : $0001; Sig : 16);

  {$IFDEF BindFaxFont}
  {font resource data}
  AwFontResourceType = 'AWFAXFONT';
  AwFontResourceName = 'FAXFONT';
  {$ENDIF}

  {TIFF tag values}
  SubfileType         = 255;
  ImageWidth          = 256;
  ImageLength         = 257;
  BitsPerSample       = 258;
  Compression         = 259;
  PhotometricInterp   = 262;
  StripOffsets        = 273;
  RowsPerStrip        = 278;
  StripByteCounts     = 279;

  {TIFF tag integer types}
  tiffByte            = 1;
  tiffASCII           = 2;
  tiffShort           = 3;
  tiffLong            = 4;
  tiffRational        = 5;

  {TIFF compression values}
  compNone = $0001;
  compHuff = $0002;
  compFAX3 = $0003;
  compFAX4 = $0004;
  compWRDL = $8003;
  compMPNT = $8005;

  {For decoding white runs}
  WhiteTable : TTermCodeArray = (
    (Code : $0035; Sig : 8),
    (Code : $0007; Sig : 6),
    (Code : $0007; Sig : 4),
    (Code : $0008; Sig : 4),
    (Code : $000B; Sig : 4),
    (Code : $000C; Sig : 4),
    (Code : $000E; Sig : 4),
    (Code : $000F; Sig : 4),
    (Code : $0013; Sig : 5),
    (Code : $0014; Sig : 5),
    (Code : $0007; Sig : 5),
    (Code : $0008; Sig : 5),
    (Code : $0008; Sig : 6),
    (Code : $0003; Sig : 6),
    (Code : $0034; Sig : 6),
    (Code : $0035; Sig : 6),
    (Code : $002A; Sig : 6),
    (Code : $002B; Sig : 6),
    (Code : $0027; Sig : 7),
    (Code : $000C; Sig : 7),
    (Code : $0008; Sig : 7),
    (Code : $0017; Sig : 7),
    (Code : $0003; Sig : 7),
    (Code : $0004; Sig : 7),
    (Code : $0028; Sig : 7),
    (Code : $002B; Sig : 7),
    (Code : $0013; Sig : 7),
    (Code : $0024; Sig : 7),
    (Code : $0018; Sig : 7),
    (Code : $0002; Sig : 8),
    (Code : $0003; Sig : 8),
    (Code : $001A; Sig : 8),
    (Code : $001B; Sig : 8),
    (Code : $0012; Sig : 8),
    (Code : $0013; Sig : 8),
    (Code : $0014; Sig : 8),
    (Code : $0015; Sig : 8),
    (Code : $0016; Sig : 8),
    (Code : $0017; Sig : 8),
    (Code : $0028; Sig : 8),
    (Code : $0029; Sig : 8),
    (Code : $002A; Sig : 8),
    (Code : $002B; Sig : 8),
    (Code : $002C; Sig : 8),
    (Code : $002D; Sig : 8),
    (Code : $0004; Sig : 8),
    (Code : $0005; Sig : 8),
    (Code : $000A; Sig : 8),
    (Code : $000B; Sig : 8),
    (Code : $0052; Sig : 8),
    (Code : $0053; Sig : 8),
    (Code : $0054; Sig : 8),
    (Code : $0055; Sig : 8),
    (Code : $0024; Sig : 8),
    (Code : $0025; Sig : 8),
    (Code : $0058; Sig : 8),
    (Code : $0059; Sig : 8),
    (Code : $005A; Sig : 8),
    (Code : $005B; Sig : 8),
    (Code : $004A; Sig : 8),
    (Code : $004B; Sig : 8),
    (Code : $0032; Sig : 8),
    (Code : $0033; Sig : 8),
    (Code : $0034; Sig : 8));

  WhiteMUTable : TMakeUpCodeArray = (
    (Code : $001B; Sig : 5),
    (Code : $0012; Sig : 5),
    (Code : $0017; Sig : 6),
    (Code : $0037; Sig : 7),
    (Code : $0036; Sig : 8),
    (Code : $0037; Sig : 8),
    (Code : $0064; Sig : 8),
    (Code : $0065; Sig : 8),
    (Code : $0068; Sig : 8),
    (Code : $0067; Sig : 8),
    (Code : $00CC; Sig : 9),
    (Code : $00CD; Sig : 9),
    (Code : $00D2; Sig : 9),
    (Code : $00D3; Sig : 9),
    (Code : $00D4; Sig : 9),
    (Code : $00D5; Sig : 9),
    (Code : $00D6; Sig : 9),
    (Code : $00D7; Sig : 9),
    (Code : $00D8; Sig : 9),
    (Code : $00D9; Sig : 9),
    (Code : $00DA; Sig : 9),
    (Code : $00DB; Sig : 9),
    (Code : $0098; Sig : 9),
    (Code : $0099; Sig : 9),
    (Code : $009A; Sig : 9),
    (Code : $0018; Sig : 6),
    (Code : $009B; Sig : 9),
    (Code : $0008; Sig : 11),
    (Code : $000C; Sig : 11),
    (Code : $000D; Sig : 11),
    (Code : $0012; Sig : 12),
    (Code : $0013; Sig : 12),
    (Code : $0014; Sig : 12),
    (Code : $0015; Sig : 12),
    (Code : $0016; Sig : 12),
    (Code : $0017; Sig : 12),
    (Code : $001C; Sig : 12),
    (Code : $001D; Sig : 12),
    (Code : $001E; Sig : 12),
    (Code : $001F; Sig : 12));

  BlackTable : TTermCodeArray = (
    (Code : $0037; Sig : 10),
    (Code : $0002; Sig : 3),
    (Code : $0003; Sig : 2),
    (Code : $0002; Sig : 2),
    (Code : $0003; Sig : 3),
    (Code : $0003; Sig : 4),
    (Code : $0002; Sig : 4),
    (Code : $0003; Sig : 5),
    (Code : $0005; Sig : 6),
    (Code : $0004; Sig : 6),
    (Code : $0004; Sig : 7),
    (Code : $0005; Sig : 7),
    (Code : $0007; Sig : 7),
    (Code : $0004; Sig : 8),
    (Code : $0007; Sig : 8),
    (Code : $0018; Sig : 9),
    (Code : $0017; Sig : 10),
    (Code : $0018; Sig : 10),
    (Code : $0008; Sig : 10),
    (Code : $0067; Sig : 11),
    (Code : $0068; Sig : 11),
    (Code : $006C; Sig : 11),
    (Code : $0037; Sig : 11),
    (Code : $0028; Sig : 11),
    (Code : $0017; Sig : 11),
    (Code : $0018; Sig : 11),
    (Code : $00CA; Sig : 12),
    (Code : $00CB; Sig : 12),
    (Code : $00CC; Sig : 12),
    (Code : $00CD; Sig : 12),
    (Code : $0068; Sig : 12),
    (Code : $0069; Sig : 12),
    (Code : $006A; Sig : 12),
    (Code : $006B; Sig : 12),
    (Code : $00D2; Sig : 12),
    (Code : $00D3; Sig : 12),
    (Code : $00D4; Sig : 12),
    (Code : $00D5; Sig : 12),
    (Code : $00D6; Sig : 12),
    (Code : $00D7; Sig : 12),
    (Code : $006C; Sig : 12),
    (Code : $006D; Sig : 12),
    (Code : $00DA; Sig : 12),
    (Code : $00DB; Sig : 12),
    (Code : $0054; Sig : 12),
    (Code : $0055; Sig : 12),
    (Code : $0056; Sig : 12),
    (Code : $0057; Sig : 12),
    (Code : $0064; Sig : 12),
    (Code : $0065; Sig : 12),
    (Code : $0052; Sig : 12),
    (Code : $0053; Sig : 12),
    (Code : $0024; Sig : 12),
    (Code : $0037; Sig : 12),
    (Code : $0038; Sig : 12),
    (Code : $0027; Sig : 12),
    (Code : $0028; Sig : 12),
    (Code : $0058; Sig : 12),
    (Code : $0059; Sig : 12),
    (Code : $002B; Sig : 12),
    (Code : $002C; Sig : 12),
    (Code : $005A; Sig : 12),
    (Code : $0066; Sig : 12),
    (Code : $0067; Sig : 12));

  BlackMUTable : TMakeUpCodeArray = (
    (Code : $000F; Sig : 10),
    (Code : $00C8; Sig : 12),
    (Code : $00C9; Sig : 12),
    (Code : $005B; Sig : 12),
    (Code : $0033; Sig : 12),
    (Code : $0034; Sig : 12),
    (Code : $0035; Sig : 12),
    (Code : $006C; Sig : 13),
    (Code : $006D; Sig : 13),
    (Code : $004A; Sig : 13),
    (Code : $004B; Sig : 13),
    (Code : $004C; Sig : 13),
    (Code : $004D; Sig : 13),
    (Code : $0072; Sig : 13),
    (Code : $0073; Sig : 13),
    (Code : $0074; Sig : 13),
    (Code : $0075; Sig : 13),
    (Code : $0076; Sig : 13),
    (Code : $0077; Sig : 13),
    (Code : $0052; Sig : 13),
    (Code : $0053; Sig : 13),
    (Code : $0054; Sig : 13),
    (Code : $0055; Sig : 13),
    (Code : $005A; Sig : 13),
    (Code : $005B; Sig : 13),
    (Code : $0064; Sig : 13),
    (Code : $0065; Sig : 13),
    (Code : $0008; Sig : 11),
    (Code : $000C; Sig : 11),
    (Code : $000D; Sig : 11),
    (Code : $0012; Sig : 12),
    (Code : $0013; Sig : 12),
    (Code : $0014; Sig : 12),
    (Code : $0015; Sig : 12),
    (Code : $0016; Sig : 12),
    (Code : $0017; Sig : 12),
    (Code : $001C; Sig : 12),
    (Code : $001D; Sig : 12),
    (Code : $001E; Sig : 12),
    (Code : $001F; Sig : 12));

  {Sizes for small font used for header line}
  SmallFontRec : TFontRecord = (
    Bytes  : 16;
    PWidth : 12;
    Width  : 2;
    Height : 8);

  {Sizes for standard font}
  StandardFontRec : TFontRecord = (
    Bytes  : 48;
    PWidth : 20;
    Width  : 3;
    Height : 16);

  {$IFNDEF Win32}
  procedure RotateCode(var Code : Word; Sig : Word); assembler;
    {-Flip code MSB for LSB}
  asm
    les   di,Code
    mov   dx,es:[di]
    xor   ax,ax
    mov   cx,16
@1: shr   dx,1
    rcl   ax,1
    loop  @1
    mov   cx,16
    sub   cx,Sig
    shr   ax,cl
    mov   es:[di],ax
  end;
  {$ELSE}
  procedure RotateCode(var Code : Word; Sig : Word); assembler; register;
    {-Flip code MSB for LSB}
  asm
    push  edi
    push  ebx

    {load parameters}
    mov   edi,eax         {edi = Code}
    mov   ebx,edx         {ebx = Sig }

    mov   dx,word ptr [edi]
    xor   ax,ax
    mov   ecx,16
@1: shr   dx,1
    rcl   ax,1
    dec   ecx
    jnz   @1
    mov   cx,16
    sub   cx,bx
    shr   ax,cl
    mov   [edi],ax

    pop   ebx
    pop   edi
  end;
  {$ENDIF}

{Miscellaneous}

  function awIsAnAPFFile(FName : PChar) : Bool;
    {-Return TRUE if the file FName is a valid APF file}
  var
    F   : File;
    Sig : TSigArray;
    SaveFileMode : Word;

  begin
    awIsAnAPFFile := False;

    {open the file}
    Assign(F, FName);
    SaveFileMode := FileMode;
    FileMode := fmOpenRead or fmShareDenyWrite;
    Reset(F, 1);
    FileMode := SaveFileMode;                                          
    if (IoResult <> 0) then
      Exit;

    {read in what ought top be a signature}
    BlockRead(F, Sig, SizeOf(Sig));
    if (IoResult <> 0) then begin
      Close(F); if (IoResult = 0) then ;
      Exit;
    end;
    Close(F); if (IoResult = 0) then ;

    awIsAnAPFFile := (DefAPFSig = Sig);
  end;

  {$IFNDEF Win32}
  procedure FastZero(var Buf; Len : Cardinal); assembler;
  asm
    cld               {go forward}
    les   di,Buf      {ES:DI->Buf}
    mov   cx,Len      {CX = length of buffer}
    xor   ax,ax       {store zeros}
    shr   cx,1        {CX = CX/2}
    rep   stosw       {store zeros by word}
    adc   cx,cx       {any leftover}
    rep   stosb       {store zeros by byte}
  end;

  function MaxCardinal(A, B : Cardinal) : Cardinal; assembler;
  asm
    mov ax,a
    cmp ax,b
    jae @1
    mov ax,b
  @1:
  end;
  {$ELSE}
  procedure FastZero(var Buf; Len : Cardinal); assembler; register;
  asm
    push  edi

    cld

    {load parameters}
    mov   edi,eax     {eax = Buf}
    mov   ecx,edx     {edx = Len}
    and   edx,3
    shr   ecx,2
    xor   eax,eax     {store zeros}

    {store by dword}
    rep   stosd

    {store by byte}
    mov   ecx,edx
    rep   stosb

    pop   edi
  end;

  function MaxCardinal(A, B : Cardinal) : Cardinal; assembler; register;
  asm
    cmp   eax,edx       {eax = A, edx = B}
    jae   @1
    mov   eax,edx
  @1:
  end;
  {$ENDIF}

{Buffered file code}

const
  CvtOutBufSize = 4096;

function InitOutFile(var F : PBufferedOutputFile; Name : PChar) : Integer;
var
  Code : Integer;

begin
  F := AllocMem(SizeOf(TBufferedOutputFile));
  FastZero(F^, SizeOf(TBufferedOutputFile));
  with F^ do begin
    {initialize buffer}
    Buffer := AllocMem(CvtOutBufSize);
    FastZero(Buffer^, CvtOutBufSize);

    {create the output file}
    Assign(OutFile, Name);
    Rewrite(OutFile, 1);
    Code := -IoResult;
    if (Code < ecOK) then begin
      FreeMem(Buffer, CvtOutBufSize);
      FreeMem(F, SizeOf(TBufferedOutputFile));
      InitOutFile := Code;
      Exit;
    end;

    InitOutFile := ecOK;
  end;
end;

procedure CleanupOutFile(var F : PBufferedOutputFile);
begin
  Close(F^.OutFile); if (IoResult = 0) then ;
  Erase(F^.OutFile); if (IoResult = 0) then ;
  FreeMem(F^.Buffer, CvtOutBufSize);
  FreeMem(F, SizeOf(TBufferedOutputFile));
end;

function FlushOutFile(var F : PBufferedOutputFile) : Integer;
var
  Code : Integer;

begin
  FlushOutFile := ecOK;

  with F^ do begin
    if (BufPos = 0) then
      Exit;

    BlockWrite(OutFile, Buffer^, BufPos);
    Code := -IoResult;
    if (Code < ecOK) then begin
      CleanupOutFile(F);
      FlushOutFile := Code;
    end else
      BufPos := 0;
  end;
end;

function WriteOutFile(var F : PBufferedOutputFile; var Data; Len : Cardinal) : Integer;
var
  Code         : Integer;
  InPosn       : Cardinal;
  BytesLeft    : Cardinal;
  BytesToWrite : Cardinal;

begin
  WriteOutFile := ecOK;

  with F^ do
    {will all the new data fit into the output buffer?}
    if ((BufPos + Len) < CvtOutBufSize) then begin
      Move(Data, Buffer^[BufPos], Len);
      Inc(BufPos, Len);
    end else begin
      if (BufPos > 0) then begin
        {move as much data as possible into the buffer and flush it}
        BytesToWrite := CvtOutBufSize - BufPos;
        InPosn       := BytesToWrite;
        Move(Data, Buffer^[BufPos], BytesToWrite);
        BufPos := CvtOutBufSize;
        Code := FlushOutFile(F);
        if (Code < ecOK) then begin
          WriteOutFile := Code;
          Exit;
        end;
      end else begin
        BytesToWrite := 0;
        InPosn       := 0;
      end;

      {if there's very little data remaining, buffer it and exit}
      BytesLeft := Len - BytesToWrite;
      if (BytesLeft < CvtOutBufSize) then begin
        Move(TByteArray(Data)[BytesToWrite], Buffer^, BytesLeft);
        BufPos := BytesLeft;
        Exit;
      end;

      {round down to nearest multiple of CvtOutBufSize}
      BytesToWrite := BytesLeft and (not Pred(CvtOutBufSize));
      Dec(BytesLeft, BytesToWrite);

      {write out as many chunks of CvtOutBufSize as we can}
      BlockWrite(OutFile, TByteArray(Data)[InPosn], BytesToWrite);
      Code := -IoResult;
      if (Code < ecOK) then begin
        CleanupOutFile(F);
        WriteOutFile := Code;
        Exit;
      end;
      Inc(InPosn, BytesToWrite);

      {move the rest of the data into the buffer}
      Move(TByteArray(Data)[InPosn], Buffer^, BytesLeft);
      BufPos := BytesLeft;
    end;
end;

function SeekOutFile(var F : PBufferedOutputFile; Posn : LongInt) : Integer;
var
  Code : Integer;

begin
  Code := FlushOutFile(F);
  if (Code < ecOK) then begin
    SeekOutFile := Code;
    Exit;
  end;

  Seek(F^.OutFile, Posn);
  Code := -IoResult;
  if (Code < ecOK) then
    CleanupOutFile(F);
  SeekOutFile := Code;
end;

function OutFilePosn(var F : PBufferedOutputFile) : LongInt;
begin
  with F^ do
    OutFilePosn := FilePos(OutFile) + BufPos;
end;

function CloseOutFile(var F : PBufferedOutputFile) : Integer;
var
  Code : Integer;

begin
  {flush any remaining data}
  Code := FlushOutFile(F);
  if (Code < ecOK) then begin
    CloseOutFile := Code;
    Exit;
  end;

  with F^ do begin
    {close the output file}
    Close(OutFile);
    Code := -IoResult;
    if (Code < ecOK) then begin
      Erase(OutFile); if (IoResult = 0) then ;
    end;
    CloseOutFile := Code;
    FreeMem(Buffer, CvtOutBufSize);
    FreeMem(F, SizeOf(TBufferedOutputFile));
  end;
end;

{Abstract fax conversion routines}

  procedure acInitDataLine(Cvt : PAbsFaxCvt);
    {-Initialize the converter's line buffer}
  begin
    with Cvt^ do begin
      FastZero(DataLine^, MaxData);
      ByteOfs := 0;
      BitOfs  := 0;
    end;
  end;

  procedure acInitFaxConverter(var Cvt : PAbsFaxCvt; Data : Pointer;
                              CB : TGetLineCallback; OpenFile : TOpenFileCallback;
                              CloseFile : TCloseFileCallback; DefaultExt : PChar);
    {-Initialize a fax converter engine}
  begin

    Cvt := AllocMem(SizeOf(TAbsFaxCvt));

    {initialize converter structure}
    with Cvt^ do begin
      Flags         := DefFaxCvtOptions;
      ResWidth      := StandardWidth;
      LeftMargin    := DefLeftMargin;
      TopMargin     := DefTopMargin;
      UserData      := Data;
      GetLine       := CB;
      OpenCall      := OpenFile;
      CloseCall     := CloseFile;
      InFileName[0] := #0;
      StrCopy(DefExt, DefaultExt);

      {initialize compression buffer}
      DataLine := AllocMem(MaxData);

      {initialize temporary buffer}
      TmpBuffer := AllocMem(MaxData);
    end;

    acInitDataLine(Cvt);
  end;

  procedure acDoneFaxConverter(var Cvt : PAbsFaxCvt);
    {-Destroy a fax converter engine}
  begin
    with Cvt^ do begin
      FreeMem(DataLine, MaxData);
      FreeMem(TmpBuffer, MaxData);
    end;

    FreeMem(Cvt, SizeOf(TAbsFaxCvt));
    Cvt := nil;
  end;

  procedure acSetOtherData(Cvt : PAbsFaxCvt; OtherData : Pointer);
    {-Set other data pointer}
  begin
    Cvt^.OtherData := OtherData;
  end;

  procedure acOptionsOn(Cvt : PAbsFaxCvt; OptionFlags : Word);
    {-Activate multiple fax converter options}
  begin
    with Cvt^ do
      Flags := Flags or (OptionFlags and not Cardinal(BadFaxCvtOptions));
  end;

  procedure acOptionsOff(Cvt : PAbsFaxCvt; OptionFlags : Word);
    {-Deactivate multiple options}
  begin
    with Cvt^ do
      Flags := Flags and not (OptionFlags and not BadFaxCvtOptions);
  end;

  function acOptionsAreOn(Cvt : PAbsFaxCvt; OptionFlags : Word) : Bool;
    {-Return True if all specified options are on}
  begin
    with Cvt^ do
      acOptionsAreOn := ((Flags and OptionFlags) = OptionFlags);
  end;

  procedure acSetMargins(Cvt : PAbsFaxCvt; Left, Top : Cardinal);
    {-Set left and top margins for converter}
  begin
    with Cvt^ do begin
      LeftMargin := Left;
      TopMargin  := Top;
    end;
  end;

  procedure acSetResolutionMode(Cvt : PAbsFaxCvt; HiRes : Bool);
    {-Select standard or high resolution mode}
  begin
    Cvt^.UseHighRes := HiRes;
  end;

  procedure acSetResolutionWidth(Cvt : PAbsFaxCvt; RW : Cardinal);
    {-Select standard (1728 pixels) or wide (2048 pixels) width}
  begin
    with Cvt^ do
      if (RW = rw2048) then
        ResWidth := WideWidth
      else
        ResWidth := StandardWidth;
  end;

  procedure acSetStationID(Cvt : PAbsFaxCvt; ID : PChar);
    {-Set the station ID of the converter}
  begin
    with Cvt^ do
      StrLCopy(StationID, ID, SizeOf(StationID) - 1);
  end;

  procedure acSetStatusCallback(Cvt : PAbsFaxCvt; CB : TCvtStatusCallback);
    {-Set the procedure called for conversion status}
  begin
    if (@CB <> nil) then begin
      Cvt^.StatusWnd  := 0;
      Cvt^.StatusFunc := CB;
    end;
  end;

  procedure acSetStatusWnd(Cvt : PAbsFaxCvt; HWindow : TApdHwnd);
    {-Set the handle of the window that receives status messages}
  begin
    if (HWindow <> 0) then begin
      Cvt^.StatusFunc := nil;
      Cvt^.StatusWnd  := HWindow;
    end;
  end;

  {$IFNDEF Win32}
  procedure acAddCodePrim(Cvt : PAbsFaxCvt; Code : Word; SignificantBits : Word); assembler;
    {-Lowlevel routine to add a runlength code to the line buffer}
  asm
    les   di,Cvt

    mov   ax,Code
    xor   dx,dx                            {dx:ax = extended code}
    mov   cx,TAbsFaxCvt(es:[di]).BitOfs    {cx = bit offset}
    mov   si,cx                            {save a copy of bit offset}
    jcxz  @2
@1: shl   ax,1                             {shift code for bit offset}
    rcl   dx,1
    loop  @1

@2: mov   bx,TAbsFaxCvt(es:[di]).ByteOfs   {bx = byte offset}
    add   si,SignificantBits
    mov   cx,si
    shr   cx,3
    add   TAbsFaxCvt(es:[di]).ByteOfs,cx   {update ByteOfs}
    and   si,7
    mov   TAbsFaxCvt(es:[di]).BitOfs,si    {update BitOfs}

    les   di,TAbsFaxCvt(es:[di]).DataLine
    add   di,bx
    or    es:[di],ax                       {or new bit pattern in place}
    or    es:[di+2],dl
  end;

  {$ELSE}
  procedure acAddCodePrim(Cvt : PAbsFaxCvt; Code : Word; SignificantBits : Word); assembler; register;
    {-Lowlevel routine to add a runlength code to the line buffer}
  asm
    push  esi
    push  edi
    push  ebx

    {load parameters}
    xor   ebx,ebx
    mov   bx,cx       {cx = SignificantBits}
    and   edx,$0000FFFF

    mov   ecx,TAbsFaxCvt([eax]).BitOfs
    mov   esi,ecx     {save copy of bit offset}
    or    ecx,ecx
    jz    @1

    shl   edx,cl      {shift code for bit offset}

@1: mov   edi,TAbsFaxCvt([eax]).ByteOfs
    add   esi,ebx
    mov   ecx,esi
    shr   ecx,3
    add   TAbsFaxCvt([eax]).ByteOfs,ecx
    and   esi,7
    mov   TAbsFaxCvt([eax]).BitOfs,esi

    mov   eax,TAbsFaxCvt([eax]).DataLine
    add   eax,edi
    or    [eax],dx
    shr   edx,16
    or    [eax+2],dl

    pop   ebx
    pop   edi
    pop   esi
  end;
  {$ENDIF}

  {$IFNDEF Win32}
  procedure acAddCode(Cvt : PAbsFaxCvt; RunLen : Cardinal; IsWhite : Boolean); assembler;
    {-Adds a code representing RunLen pixels of white (IsWhite=True) or black
      to the current line buffer}
  asm
    mov   ax,word ptr IsWhite                                      
    mov   bx,RunLen

    {Long run?}
    cmp   bx,64
    jb    @2

    {Long white run?}
    or    al,al
    jz    @1

    {Long white run}
    shr   bx,6
    dec   bx
    mov   si,offset WhiteMUTable
    shl   bx,2
    les   di,Cvt
    push  es
    push  di
    push  word ptr [bx+si]
    push  word ptr [bx+si+2]
    call  acAddCodePrim
    mov   bx,RunLen
    and   bx,63
    mov   si,offset WhiteTable
    jmp   @4

    {Long black run}
@1: shr   bx,6
    dec   bx
    mov   si,offset BlackMUTable
    shl   bx,2
    les   di,Cvt
    push  es
    push  di
    push  word ptr [bx+si]
    push  word ptr [bx+si+2]
    call  acAddCodePrim
    mov   bx,RunLen
    and   bx,63
    mov   si,offset BlackTable
    jmp   @4

    {Short white run?}
@2: or    al,al
    jz    @3

    {Short white run}
    mov   si,offset WhiteTable
    jmp   @4

    {Short black run}
@3: mov   si,offset BlackTable

    {Add last code}
@4: shl   bx,2
    les   di,Cvt
    push  es
    push  di
    push  word ptr [bx+si]
    push  word ptr [bx+si+2]
    call  acAddCodePrim
@5:
  end;
  {$ELSE}
  procedure acAddCode(Cvt : PAbsFaxCvt; RunLen : Cardinal; IsWhite : Boolean); assembler; register;
    {-Adds a code representing RunLen pixels of white (IsWhite=True) or black
      to the current line buffer}
  asm
    push  esi
    push  edi

    {load parameters}
    mov   edi,eax     {eax = Cvt}

    {long run?}
    cmp   edx,64
    jb    @2

    {long white run?}
    or    cl,cl
    jz    @1

    {long white run}
    push  edx
    shr   edx,6
    dec   edx
    mov   esi,offset WhiteMUTable
    mov   eax,edi
    mov   cx,word ptr [edx*4+esi+2]
    mov   dx,word ptr [edx*4+esi]
    call  acAddCodePrim
    pop   edx
    and   edx,63
    mov   esi,offset WhiteTable
    jmp   @4

    {long black run}
@1: push  edx
    shr   edx,6
    dec   edx
    mov   esi,offset BlackMUTable
    mov   eax,edi
    mov   cx,word ptr [edx*4+esi+2]
    mov   dx,word ptr [edx*4+esi]
    call  acAddCodePrim
    pop   edx
    and   edx,63
    mov   esi,offset BlackTable
    jmp   @4

    {Short white run?}
@2: or    cl,cl
    jz    @3

    {short white run}
    mov   esi,offset WhiteTable
    jmp   @4

    {short black run}
@3: mov   esi,offset BlackTable

    {add last code}
@4: mov   eax,edi
    mov   cx,word ptr [edx*4+esi+2]
    mov   dx,word ptr [edx*4+esi]
    call  acAddCodePrim

@5: pop   edi
    pop   esi
  end;
  {$ENDIF}

  procedure CountRunsAndAddCodes(Cvt : PAbsFaxCvt; var Buffer);
    {walk the pixel array, counting runlengths and adding codes to match}
  var
    SaveCvt       : PAbsFaxCvt;
    RunLen        : Integer;
    Width         : Integer;
    Margin        : Integer;
    TotalRunWidth : Integer;
    TotalRun      : Integer;
    IsWhite       : Boolean;
    PrevWhite     : Boolean;
    DblWdth       : Boolean;{D6}
    P             : PByte;
    B             : Byte;

  begin
    SaveCvt := Cvt;

    with Cvt^ do begin
      {Add margin}
      Width         := ResWidth;
      TotalRunWidth := ResWidth;
      Margin        := LeftMargin;
      TotalRun  := 0;
      P         := PByte(@Buffer);
      B         := P^;
      PrevWhite := ((B and $80) = 0);
      if PrevWhite then begin
        RunLen := Succ(Margin);
        IsWhite := True;
      end else begin
        {add margin, or a zero-runlength white code if there isn't one}
        RunLen := 1;
        acAddCode(Cvt, LeftMargin, True);
        Dec(TotalRunWidth, Margin);
        IsWhite := False;
      end;

      DblWdth := DoubleWidth;{D6}

      {$IFNDEF Win32}
      asm
        mov   dl,B
        mov   dh,$40
        mov   bl,PrevWhite             
        mov   bh,bl
        mov   cx,Width
        sub   cx,Margin

        {get NewWhite}
    @1: mov   bl,1
        test  dl,dh
        jz    @2
        dec   bl

        {update mask and get new byte if needed}
    @2: mov   al,dh
        shr   al,1
        jnz   @3
        inc   word ptr P
        les   di,P
        mov   dl,es:[di]
        mov   al,$80
    @3: mov   dh,al

        {NewWhite = PrevWhite?}
        cmp   bh,bl
        jne   @4

        {Last pixel?}
        cmp   cx,1
        jne   @5
        test  DblWdth,1{D6}
        jz    @4
        mov   ax,TotalRunWidth
        sub   ax,TotalRun
        mov   RunLen,ax
        shr   RunLen,1

        {Save registers}
    @4: push  bx
        push  cx
        push  dx

        {Add output code}
        test  DblWdth,1{D6}
        jz    @6
        shl   RunLen,1
    @6:
        {Increment TotalRun}
        mov   ax,TotalRun
        add   ax,RunLen
        mov   TotalRun,ax

        les   di,Cvt
        push  es
        push  di
        push  RunLen
        push  word ptr IsWhite
        call  acAddCode

        {Restore registers}
        pop   dx
        pop   cx
        pop   bx

        {Update state}
        xor   IsWhite,1
        mov   RunLen,0
        mov   bh,bl

        {Increment RunLen and loop}
    @5: inc   RunLen
        loop  @1
      end;

      {$ELSE}

      asm
        push  edi
        push  ebx

        mov   dl,B
        mov   dh,$40
        movzx ebx,PrevWhite                                         
        mov   bh,bl
        mov   ecx,Width
        sub   ecx,Margin

        {get NewWhite}
    @1: mov   bl,1
        test  dl,dh
        jz    @2
        dec   bl

        {update mask and get new byte if needed}
    @2: mov   al,dh
        shr   al,1
        jnz   @3
        inc   dword ptr P
        mov   edi,P
        mov   dl,byte ptr [edi]
        mov   al,$80
    @3: mov   dh,al

        {NewWhite = PrevWhite?}
        cmp   bh,bl
        jne   @4

        {Last pixel?}
        cmp   ecx,1
        jne   @5
        test  DblWdth,1{D6}
        jz    @4
        mov   eax,TotalRunWidth
        sub   eax,TotalRun
        mov   RunLen,eax
        shr   RunLen,1

        {Save registers}
    @4: push  eax
        push  edx
        push  ecx

        {Add output code}
        test  DblWdth,1{D6}
        jz    @6
        shl   RunLen,1
    @6:
        {Increment TotalRun}
        mov   eax,TotalRun
        add   eax,RunLen
        mov   TotalRun,eax

        mov   eax,SaveCvt
        mov   edx,RunLen
        movzx ecx,IsWhite                                         
        call  acAddCode

        {Restore registers}
        pop   ecx
        pop   edx
        pop   eax

        {Update state}
        xor   IsWhite,1
        mov   RunLen,0
        mov   bh,bl

        {Increment RunLen and loop}
    @5: inc   RunLen
        dec   ecx
        jnz   @1

        pop   ebx
        pop   edi
      end;
      {$ENDIF}
    end;
  end;

  procedure acCompressRasterLine(Cvt : PAbsFaxCvt; var Buffer);
    {-compress a raster line of bits into runlength codes}
  var
    Width   : Cardinal;
    P       : PByte;                                               
    IsWhite : Boolean;

  begin
    with Cvt^ do begin
      {clear used portion of previous line}
      FastZero(DataLine^, ByteOfs+1);

      ByteOfs := 0;
      BitOfs  := 0;

      {add EOL code}
      acAddCodePrim(Cvt, LongEOLRec.Code, LongEOLRec.Sig);

      {is the line all white?}
      P     := PByte(@Buffer);                                   
      Width := ResWidth;

      {$IFNDEF Win32}
      asm
        les   di,P
        xor   al,al
        mov   cx,Width
        shr   cx,3
        cld
        repe  scasb
        mov   IsWhite,True
        je    @1
        mov   IsWhite,False
    @1:
      end;
      {$ELSE}
      asm
        push  edi
        mov   edi,P
        xor   eax,eax
        mov   ecx,Width
        shr   ecx,3
        cld
        repe  scasb
        mov   IsWhite,True
        je    @1
        mov   IsWhite,False
    @1: pop   edi
      end;
      {$ENDIF}

      if IsWhite then
        {yes; add a single code for the all-white line}
        acAddCode(Cvt, Width, True)

      else
        CountRunsAndAddCodes(Cvt, Buffer);

      {Make sure there are at least LinePadSize nulls after the data}
      ByteOfs := ByteOfs + LinePadSize;
    end;
  end;

  function acConvertStatus(Cvt : PAbsFaxCvt; StatFlags : Word) : Integer;
  begin
    acConvertStatus := ecOK;

    with Cvt^ do begin
      if (StatusWnd <> 0) then begin
        if (SendMessage(StatusWnd, apw_FaxCvtStatus, StatFlags, LongInt(Cvt)) <> 0) then
          acConvertStatus := ecConvertAbort;
      end else if (@StatusFunc <> nil) then
        if StatusFunc(Cvt, StatFlags, BytesRead, BytesToRead) then
          acConvertStatus := ecConvertAbort;
    end;
  end;


  function acOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a converter input file}
  begin
    with Cvt^ do
      if (@OpenCall <> nil) then
        acOpenFile := OpenCall(Cvt, FileName)
      else
        acOpenFile := ecOK;                                           
  end;

  procedure acCloseFile(Cvt : PAbsFaxCvt);
    {-Close a converter input file}
  begin
    with Cvt^ do
      if (@CloseCall <> nil) then
        CloseCall(Cvt);
  end;

  function acGetRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                           var EndOfPage, MorePages : Bool) : Integer;
    {-Read a raster line from an input file}
  var
    Code : Integer;

  begin
    with Cvt^ do begin
      Inc(CurrLine);
      Code := GetLine(Cvt, Data, Len, EndOfPage, MorePages);
      if (Code = ecOK) then
        Code := acConvertStatus(Cvt, 0);
      acGetRasterLine := Code;
    end;
  end;

  function acAddData(Cvt : PAbsFaxCvt; var Buffer; Len : Cardinal; DoInc : Bool) : Integer;
    {-Add a block of data to the output file}
  begin
    with Cvt^ do begin
      {write the data to the file}
      acAddData := WriteOutFile(OutFile, Buffer, Len);

      {increment the length of the image data}
      if DoInc then
        Inc(PageHeader.ImgLength, Len);
    end;
  end;

  function acAddLine(Cvt : PAbsFaxCvt; var Buffer; Len : Cardinal) : Integer;
    {-Add a line of image data to the file}
  var
    Code : Integer;

  begin
    {add a length word for the data}
    Code := acAddData(Cvt, Len, SizeOf(Word), True);

    {add the data}
    if (Code = ecOK) then
      Code := acAddData(Cvt, Buffer, Len, True);
    acAddLine := Code;
  end;

  procedure acMakeEndOfPage(Cvt : PAbsFaxCvt; var Buffer; var Len : Integer);
    {-Encode end-of-page data into Buffer}
  var
    I : Cardinal;

  begin
    with Cvt^ do begin
      acInitDataLine(Cvt);
      acAddCodePrim(Cvt, LongEOLRec.Code, LongEOLRec.Sig);
      for I := 1 to 7 do                                           
        acAddCodePrim(Cvt, EOLRec.Code, EOLRec.Sig);

      Move(DataLine^, Buffer, ByteOfs);
      Len := ByteOfs;
    end;
  end;

  function acOutToFileCallback(Cvt : PAbsFaxCvt; var Data; Len : Integer;
                               EndOfPage, MorePages : Bool) : Integer;
    {-Output a compressed raster line to an APF file}
  var
    Code : Integer;
    I    : Integer;

    function UpdatePageHeader : Integer;
      {-update the current page's header}
    label
      Breakout;

    var
      Code : Integer;
      L    : LongInt;

    begin
      with Cvt^ do begin
        {save current file position for later}
        L := OutFilePosn(OutFile);

        {go to the page header}
        Code := SeekOutFile(OutFile, CurPagePos);
        if (Code < ecOK) then
          goto Breakout;

        {update the header}
        Code := WriteOutFile(Outfile, PageHeader, SizeOf(TPageHeaderRec));
        if (Code < ecOK) then
          goto Breakout;

        {return to original position}
        Code := SeekOutFile(OutFile, L);

      Breakout:
        UpdatePageHeader := Code;
      end;
    end;

  begin
    acOutToFileCallback := ecOK;

    with Cvt^ do begin
      if EndOfPage then begin
        {make end of page marker}
        acInitDataLine(Cvt);
        acAddCodePrim(Cvt, LongEOLRec.Code, LongEOLRec.Sig);
        for I := 1 to 7 do                                      
          acAddCodePrim(Cvt, EOLRec.Code, EOLRec.Sig);

        {add end of page to output}
        Code := acAddLine(Cvt, DataLine^, ByteOfs);
        if (Code < ecOK) then begin
          acOutToFileCallback := Code;
          Exit;
        end;

        {increment page count}
        Inc(MainHeader.PageCount);
        Code := UpdatePageHeader;
        if (Code < ecOK) then begin
          acOutToFileCallback := Code;
          Exit;
        end;
      end else if (LastPage <> CurrPage) then begin
        {create the page header}
        FastZero(PageHeader, SizeOf(PageHeader));
        with PageHeader do begin
          ImgFlags := ffLengthWords;
          if UseHighRes then
            ImgFlags := ImgFlags or ffHighRes;
          if (ResWidth = WideWidth) then
            ImgFlags := ImgFlags or ffHighWidth;
        end;

        {put the page header to the file}
        CurPagePos := OutFilePosn(OutFile);
        Code := acAddData(Cvt, PageHeader, SizeOf(PageHeader), False);
        if (Code < ecOK) then begin
          acOutToFileCallback := Code;
          Exit;
        end;

        LastPage := CurrPage;
      end;

      if not EndOfPage then
        acOutToFileCallback := acAddLine(Cvt, Data, Len);
    end;
  end;

  function ConverterYield : Integer;
    {-Yield a timeslice to other windows procedures}
  var
    Msg : TMsg;

  begin
    ConverterYield := ecOK;
    if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
      if (Msg.Message = wm_Quit) then begin
        PostQuitMessage(Msg.wParam);
        ConverterYield := ecGotQuitMsg;
      end else begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
        ConverterYield := ecOK;
      end;
  end;

  function acCreateOutputFile(Cvt : PAbsFaxCvt) : Integer;
    {-Create an APF file}
  var
    Code : Integer;

  begin
    with Cvt^ do begin
      {initialize fax file and page headers}
      FastZero(MainHeader, SizeOf(MainHeader));
      Move(DefAPFSig, MainHeader.Signature, SizeOf(MainHeader.Signature));
      MainHeader.PageOfs := SizeOf(MainHeader);
      FastZero(PageHeader, SizeOf(PageHeader));

      {create output file}
      Code := InitOutFile(OutFile, OutFileName);
      if (Code = ecOK) then
        Code := WriteOutFile(OutFile, MainHeader, SizeOf(Mainheader));

      acCreateOutputFile := Code;
    end;
  end;

  function acCloseOutputFile(Cvt : PAbsFaxCvt) : Integer;
    {-Close an APF file}
  var
    Code : Integer;

    {$IFNDEF Win32}
    function NowAsFileDate: Longint;
    var
      Month, Day, Hour, Min, Sec, HSec: Byte;
    var
      Year: Word;
    begin
      asm
        MOV     AH,2AH
        INT     21H
        MOV     Year,CX
        MOV     Month,DH
        MOV     Day,DL
        MOV     AH,2CH
        INT     21H
        MOV     Hour,CH
        MOV     Min,CL
        MOV     Sec,DH
        MOV     HSec,DL
      end;
      LongRec(Result).Lo := (Sec shr 1) or (Min shl 5) or (Hour shl 11);
      LongRec(Result).Hi := Day or (Month shl 5) or ((Year - 1980) shl 9);
    end;
    {$ENDIF}

    function GetPackedDateTime : LongInt;
      {-Get the current date and time in BP7 packed date format}
    var
      DT : TDateTime;
    begin
      {$IFDEF Win32}
      DT     := Now;
      Result := DateTimeToFileDate(DT);
      {$ELSE}
      Result := NowAsFileDate;                                      
      {$ENDIF}
    end;

    function UpdateMainHeader : Integer;
      {-update the contents of the main header in the file}
    label
      Breakout;

    var
      Code : Integer;
      L    : LongInt;
      SLen : Cardinal;

    begin
      with Cvt^ do begin
        {refresh needed fields of MainHeader rec}
        with MainHeader do begin
          SenderID := StrPas(StationID);
          SLen     := Length(SenderID);
          if (SLen < 20) then
            FillChar(SenderID[Succ(SLen)], 20 - SLen, 32);

          FDateTime := GetPackedDateTime;
        end;

        {save current file position for later}
        L := OutFilePosn(OutFile);

        {seek to head of file}
        Code := SeekOutFile(OutFile, 0);
        if (Code < ecOK) then
          goto Breakout;

        {write the header}
        Code := WriteOutFile(OutFile, MainHeader, SizeOf(MainHeader));
        if (Code < ecOK) then
          goto Breakout;

        {return to original position}
        Code := SeekOutFile(OutFile, L);

      Breakout:
        UpdateMainHeader := Code;
      end;
    end;

  begin
    Code := UpdateMainHeader;
    if (Code = ecOK) then
      Code := CloseOutFile(Cvt^.OutFile);

    acCloseOutputFile := Code;
  end;

  function acConvertToFile(Cvt : PAbsFaxCvt; FileName, DestFile : PChar) : Integer;
    {-Convert an image to a fax file}
  var
    Code : Integer;

  label
    ErrorExit;

    function CreateOutputFile : Integer;
      {-Create the output fax file}
    begin
      with Cvt^ do begin
        if (DestFile = nil) or (DestFile^ = #0) then begin
          {create an APF file name in the source file's directory}
          JustPathNameZ(OutFileName, FileName);
          AddBackslashZ(OutFileName, OutfileName);

          {get name of output file}
          JustFileNameZ(OutFileName + StrLen(OutFileName), FileName);
          ForceExtensionZ(OutFileName, OutFileName, FaxFileExt);
          {$IFNDEF Win32}
          AnsiUpper(OutFileName);
          {$ENDIF}
        end else
          DefaultExtensionZ(OutFileName, DestFile, FaxFileExt);

        {create the output file}
        CreateOutputFile := acCreateOutputFile(Cvt);
      end;
    end;

  begin
    with Cvt^ do begin
      {create the output file}
      Code := CreateOutputFile;
      if (Code < ecOK) then
        goto ErrorExit;

      {convert the file}
      Code := acConvert(Cvt, FileName, acOutToFileCallback);
      if (Code < ecOK) then begin
        CleanupOutFile(OutFile);
        goto ErrorExit;
      end;

      {update main header of fax file and close file}
      Code := acCloseOutputFile(Cvt);
      if (Code < ecOK) then
        CleanupOutFile(OutFile);

    ErrorExit:
      acConvertToFile := Code;
    end;
  end;

  function acConvert(Cvt : PAbsFaxCvt; FileName : PChar;
                     OutCallback : TPutLineCallback) : Integer;
    {-Convert an input file, sending data to OutHandle or to OutCallback}
  const
    WhiteLine : array[1..6] of char = #$00#$80#$B2'Y'#$01#$00;
  var
    Code         : Integer;
    MorePages    : Bool;
    EndOfPage    : Bool;
    I            : Cardinal;
    Len          : Integer;
    BytesPerLine : Cardinal;
  label
    ErrorExit;

    function OutputDataLine : Integer;
    begin
      with Cvt^ do
        if (@OutCallback <> nil) then
          OutputDataLine := OutCallback(Cvt, DataLine^, ByteOfs, False, False)
        else
          OutputDataLine := ecOK;
    end;

    function DoEndOfPage : Integer;
    begin
      with Cvt^ do
        if (@OutCallback <> nil) then
          DoEndOfPage := OutCallback(Cvt, DataLine^, 0, True, MorePages)
        else
          DoEndOfPage := ecOK;
    end;

  begin
    with Cvt^ do begin
      {initialize position counter}
      CurrPage := 0;
      CurrLine := 0;

      BytesPerLine := ResWidth div 8;

      {provide an extension if the user didn't}
      DefaultExtensionZ(InFileName, FileName, DefExt);

      {show the initial status}
      Code := acConvertStatus(Cvt, csStarting);
      if (Code < ecOK) then begin
        acConvert := Code;
        Exit;
      end;

      {open the input file}
      Code := acOpenFile(Cvt, InFileName);
      if (Code < ecOK) then begin
        acConvert := Code;
        Exit;
      end;

      MorePages := True;

      while MorePages do begin
        Inc(CurrPage);
        CurrLine := 0;

        {Add top margin}
        for I := 1 to TopMargin do begin
          acInitDataLine(Cvt);
          Move(WhiteLine, DataLine^[0], 6);
          ByteOfs := 6;
          Code := OutputDataLine;
          if (Code < ecOK) then
            goto ErrorExit;
        end;

        {make initial call to GetLine function}
        FastZero(TmpBuffer^, BytesPerLine);
        Code := acGetRasterLine(Cvt, TmpBuffer^, Len, EndOfPage, MorePages);
        if (Code < ecOK) then
          goto ErrorExit;

        {read and compress raster lines until the end of the page}
        while not EndOfPage do begin
          if not HalfHeight or (HalfHeight and Odd(CurrLine)) then begin
            acCompressRasterLine(Cvt, TmpBuffer^);
            Code := OutputDataLine;
            if (Code < ecOK) then
              goto ErrorExit;
          end;

          {read the next line}
          FastZero(TmpBuffer^, BytesPerLine);
          Code := acGetRasterLine(Cvt, TmpBuffer^, Len, EndOfPage, MorePages);
          if (Code < ecOK) then
            goto ErrorExit;

          if FlagIsSet(Flags, fcYield) and FlagIsSet(Flags, fcYieldOften) and ((CurrLine and 15) = 0) then begin
            Code := ConverterYield;
            if (Code < ecOK) then
              goto ErrorExit;
          end;
        end;

        if PadPage then begin                                            {!!.04}
          {Add bottom margin}                                            {!!.04}
          for I := CurrLine to 2155 do begin                             {!!.04}
            acInitDataLine(Cvt);                                         {!!.04}
            Move(WhiteLine, DataLine^[0], 6);                            {!!.04}
            ByteOfs := 6;                                                {!!.04}
            Code := OutputDataLine;                                      {!!.04}
            if (Code < ecOK) then                                        {!!.04}
              goto ErrorExit;                                            {!!.04}
          end;                                                           {!!.04}
        end;                                                             {!!.04}

        Code := DoEndOfPage;
        if (Code < ecOK) then
          goto ErrorExit;

        {yield if the user wants it}
        if FlagIsSet(Flags, fcYield) then begin
          Code := ConverterYield;
          if (Code < ecOK) then
            goto ErrorExit;
        end;
      end;
    end;

    Code := ecOK;

  ErrorExit:
    {show final status}
    acConvertStatus(Cvt, csEnding);
    acCloseFile(Cvt);
    acConvert := Code;
  end;

{$IFNDEF PRNDRV}                                              

{Text-to-fax conversion routines}

  procedure fcInitTextConverter(var Cvt : PAbsFaxCvt);
  var
    TextCvtData : PTextFaxData;
  begin
    Cvt := nil;

    {Initialize text converter specific data}
    TextCvtData := AllocMem(SizeOf(TTextFaxData));

    TextCvtData^.ReadBuffer := AllocMem(ReadBufferSize);
    TextCvtData^.FontPtr := AllocMem(MaxFontBytes);

    TextCvtData^.TabStop := DefFaxTabStop;
    TextCvtData^.IsExtended := False;                             

    {initialize the abstract converter}
    acInitFaxConverter( Cvt, TextCvtData, fcGetTextRasterLine,
                                fcOpenFile, fcCloseFile, DefTextExt);
  end;

  procedure fcInitTextExConverter(var Cvt : PAbsFaxCvt);
    {-Initialize an extended text-to-fax converter}
  var
    TextCvtData : PTextFaxData;
  begin
    Cvt := nil;

    {Initialize text converter specific data}
    TextCvtData := AllocMem(SizeOf(TTextFaxData));

    TextCvtData^.ReadBuffer := AllocMem(ReadBufferSize);
    TextCvtData^.Bitmap := Graphics.TBitmap.Create;
    TextCvtData^.Bitmap.Monochrome := True;

    TextCvtData^.TabStop := DefFaxTabStop;
    TextCvtData^.IsExtended := True;

    TextCvtData^.ImageData := nil;
    TextCvtData^.ImageSize := 0;

    {initialize the abstract converter}
    acInitFaxConverter( Cvt, TextCvtData, fcGetTextRasterLine,
                                fcOpenFile, fcCloseFile, DefTextExt);
  end;

  procedure fcDoneTextConverter(var Cvt : PAbsFaxCvt);
    {-Destroy a text-to-fax converter}
  begin
    with PTextFaxData(Cvt^.UserData)^ do begin
      FreeMem(FontPtr, MaxFontBytes);
      FreeMem(ReadBuffer, ReadBufferSize);
    end;
    FreeMem(Cvt^.UserData, SizeOf(TTextFaxData));

    acDoneFaxConverter(Cvt);
  end;

  procedure fcDoneTextExConverter(var Cvt : PAbsFaxCvt);      
    {-Destroy an extended text-to-fax converter}
  begin
    with PTextFaxData(Cvt^.UserData)^ do begin
      FreeMem(ReadBuffer, ReadBufferSize);
      Bitmap.Free;
      FreeMem(ImageData, ImageSize);
    end;
    FreeMem(Cvt^.UserData, SizeOf(TTextFaxData));

    acDoneFaxConverter(Cvt);
  end;

  procedure fcSetTabStop(Cvt : PAbsFaxCvt; TabStop : Cardinal);
    {-Set the number of spaces equivalent to a tab character}
  begin
    if (TabStop = 0) then
      Exit;

    PTextFaxData(Cvt^.UserData)^.TabStop := TabStop;
  end;

  function fcLoadFont(Cvt : PAbsFaxCvt; FileName : PChar;
                      FontHandle : Cardinal; HiRes : Bool) : Integer;
    {-Load selected font from APFAX.FNT or memory}
  {$IFNDEF BindFaxFont}
  label
    Error;

  var
    ToRead    : Cardinal;
    ActRead   : Cardinal;
    SaveMode  : Integer;
    Code      : Integer;
    F         : File;
  {$ELSE}
  var
    P         : Pointer;
    ResHandle : THandle;
    MemHandle : THandle;
    Len       : Cardinal;
  {$ENDIF}
    I         : Integer;
    J         : Integer;
    Row       : Cardinal;
    NewRow    : Cardinal;
    NewBytes  : Cardinal;

  begin
    with Cvt^, PTextFaxData(Cvt^.UserData)^ do begin
    {$IFDEF BindFaxFont}
      {find resource for font}
      ResHandle := FindResource(HInstance, AwFontResourceName, AwFontResourceType);
      if (ResHandle = 0) then begin
        fcLoadFont := ecFontFileNotFound;
        Exit;
      end;

      {get handle to font data}
      MemHandle := LoadResource(HInstance, ResHandle);
      if (MemHandle = 0) then begin
        fcLoadFont := ecFontFileNotFound;
        Exit;
      end;

      {turn font handle into pointer}
      {$IFNDEF Win32}
      P := GlobalLock(MemHandle);
      {$ELSE}
      P := Pointer(MemHandle);
      {$ENDIF}

      {get data about font}
      if (FontHandle = StandardFont) then begin
        P       := GetPtr(P, Cardinal(SmallFont) * 256);
        FontRec := StandardFontRec;
      end else
        FontRec := SmallFontRec;
      Len := LongInt(FontHandle) * 256;

      {get font data}
      Move(P^, FontPtr^, Len);

      {scale up font if HiRes requested}
      if HiRes then
        with FontRec do begin
          {allocate temporary buffer for scaled up font}
          NewBytes := Bytes * 2;

          {double raster lines of font}
          for J := 255 downto 0 do begin
            NewRow := 0;
            Row    := 0;
            for I := 1 to Height do begin
              Move(FontPtr^[(Cardinal(J) * Bytes) + Row],
                FontPtr^[(Cardinal(J) * NewBytes) + NewRow], Width);
              Move(FontPtr^[(Cardinal(J) * Bytes) + Row],
                FontPtr^[(Cardinal(J) * NewBytes) + NewRow+Width], Width);
              Inc(Row, Width);
              Inc(NewRow, Width * 2);
            end;
          end;

          {adjust FontRec}
          Bytes  := NewBytes;
          Height := Height * 2;
        end;

      {$IFNDEF Win32}
      GlobalUnlock(MemHandle);
      {$ENDIF}
      FreeResource(MemHandle);

      FontLoaded := True;
      fcLoadFont := ecOK;

    end;
    {$ELSE}
      {assume failure}
      FontLoaded := False;

      {open font file}
      SaveMode := FileMode;
      FileMode := ApdShareFileRead;                                    
      Assign(F, FileName);
      Reset(F, 1);
      FileMode := SaveMode;
      Code := -IoResult;
      if (Code = ecFileNotFound) or (Code = ecPathNotFound) then
        Code := ecFontFileNotFound;
      if (Code < ecOK) then begin
        fcLoadFont := Code;
        Exit;
      end;

      {initialize font}
      FastZero(FontPtr^, MaxFontBytes);
      case FontHandle of
        SmallFont   : FontRec := SmallFontRec;
        StandardFont:
          begin
            FontRec := StandardFontRec;
            {seek past small font in file}
            Seek(F, (SmallFont * 256));
          end;
      end;
      Code := -IoResult;
      if (Code < ecOK) then
        goto Error;

      {get number of bytes to read--number of characters * bytes per char}
      ToRead := FontRec.Bytes * 256;

      {read font}
      BlockRead(F, FontPtr^, ToRead, ActRead);
      Code := -IoResult;
      if (Code < ecOK) then
        goto Error;
      if (ActRead < ToRead) then begin
        Code := ecDeviceRead;
        goto Error;
      end;

      {scale font up if HiRes requested}
      if HiRes then
        with FontRec do begin
          NewBytes := Bytes * 2;

          {double raster lines of font}
          for J := 255 downto 0 do begin
            NewRow := 0;
            Row    := 0;
            for I := 1 to Height do begin
              Move(FontPtr^[(J * Bytes) + Row], FontPtr^[(J * NewBytes) + NewRow], Width);
              Move(FontPtr^[(J * Bytes) + Row], FontPtr^[(J * NewBytes) + NewRow + Width], Width);
              Inc(Row, Width);
              Inc(NewRow, Width * 2);
            end;
          end;

          {adjust font parameters}
          Bytes  := NewBytes;
          Height := Height * 2;
        end;

      Close(F); if (IoResult = 0) then ;
      FontLoaded := True;
      fcLoadFont := ecOK;
      Exit;
    end;

  Error:
    Close(F); if (IoResult = 0) then ;
    fcLoadFont := Code;
    {$ENDIF}
  end;

  function fcSetFont(Cvt : PAbsFaxCvt; Font : TFont; HiRes : Boolean) : Integer; 
    {-Set font for extended text converter}
  var
    NewImageSize : LongInt;
    NewLineBytes : Cardinal;
    BmpInfo : TBitmap;
  begin
    Result := ecOK;
    with Cvt^, PTextFaxData(UserData)^ do begin
      Bitmap.Canvas.Font.Assign(Font);
      UseHighRes := HiRes;
      if UseHighRes then
        Bitmap.Canvas.Font.Size := Bitmap.Canvas.Font.Size * 2;
      Bitmap.Width := (ResWidth - LeftMargin);
      Bitmap.Height := Bitmap.Canvas.TextHeight('Wy');
      FontRec.Height := Bitmap.Height;

      GetObject(Bitmap.Handle, SizeOf(TBitmap), @BmpInfo);
      NewLineBytes := BmpInfo.bmWidthBytes;
      NewImageSize := LongInt(NewLineBytes) * BmpInfo.bmHeight;

      if NewImageSize > (64*1024) then begin
        Result := ecEnhFontTooBig;
        Exit;
      end;

      if (NewImageSize <> ImageSize) then begin
        LineBytes := NewLineBytes;
        if Assigned(ImageData) then
          FreeMem(ImageData, ImageSize);
        ImageSize := NewImageSize;
        GetMem(ImageData, ImageSize);
      end;
    end;
  end;

  function fcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a text file for input}
  begin
    with PTextFaxData(Cvt^.UserData)^ do begin
      OnLine    := 0;
      CurRow    := 0;

      {open the input file}
      InFile := TLineReader.Create(
        TFileStream.Create(
        {$IFDEF Windows}
        StrPas(FileName),
        {$ELSE}
        FileName,
        {$ENDIF}
        fmOpenRead or fmShareDenyWrite));
    end;
    Result := ecOK;
  end;

  procedure fcCloseFile(Cvt : PAbsFaxCvt);
    {-Close text file}
  begin
    with PTextFaxData(Cvt^.UserData)^ do begin
      {close the file}
      InFile.Free;                                                 
    end;
  end;

  procedure fcSetLinesPerPage(Cvt : PAbsFaxCvt; LineCount : Cardinal);
    {-Set the number of text lines per page}
  begin
    PTextFaxData(Cvt^.UserData)^.LineCount := LineCount;
  end;

  {$IFNDEF Win32}
  procedure fcAddRasterChar(var CharData;
                            var Data;
                                LPWidth  : Cardinal;
                            var LByteOfs : Cardinal;
                            var LBitOfs  : Cardinal); assembler;
    {-Rasterize one line of one character, adding it to Data}
  asm
    les  di,LByteOfs
    mov  bx,es:[di]
    les  di,LBitOfs
    mov  cx,es:[di]
    les  di,Data
    add  di,bx
    mov  dx,LPWidth

    push ds
    lds  si,CharData
    cld

@1: lodsb                 {get next byte of character data}
    xor  ah,ah
    ror  ax,cl            {rotate by current bit offset}
    or   es:[di],ax       {OR it into position}
    mov  ax,dx            {ax = remaining pixels}
    cmp  ax,8             {at least 8 remaining?}
    jb   @2               {jump if not}
    inc  di               {next output byte}
    sub  dx,8             {update remaining pixels}
    jnz  @1               {loop if more}
    jmp  @3               {get out if not}
@2: sub  dx,ax            {update remaining pixels}
    add  cx,ax            {update bit offset}
    mov  ax,cx
    shr  ax,3
    add  di,ax            {update byte offset}
    and  cx,7             {update bit offset}
    or   dx,dx            {more pixels to merge?}
    jnz  @1               {jump if so}

@3: pop  ds
    mov  si,word ptr Data
    sub  di,si
    mov  bx,di
    les  di,LByteOfs
    mov  es:[di],bx
    les  di,LBitOfs
    mov  es:[di],cx
  end;
  {$ELSE}
  procedure fcAddRasterChar(var CharData;
                            var Data;
                                LPWidth  : Cardinal;
                            var LByteOfs : Cardinal;
                            var LBitOfs  : Cardinal); assembler; register;
  asm
    push  esi
    push  edi
    push  ebx

    cld

    {load parameters}
    mov   esi,LByteOfs
    mov   edi,edx         {edx = Data}
    mov   ebx,edi
    add   edi,[esi]
    mov   edx,ecx         {ecx = LPWidth}
    mov   esi,LBitOfs
    mov   ecx,[esi]
    mov   esi,eax         {eax = CharData}

@1: mov   al,[esi]        {get next byte of character data}
    inc   esi
    xor   ah,ah
    ror   ax,cl           {rotate by current bit offset}
    or    [edi],ax        {OR it into position}
    mov   eax,edx         {ax = remaining pixels}
    cmp   ax,8            {at least 8 remaining?}
    jb    @2              {jump if not}
    inc   edi             {next output byte}
    sub   edx,8           {update remaining pixels}
    jnz   @1              {loop if more}
    jmp   @3              {get out if not}

@2: sub   edx,eax         {update remaining pixels}
    add   ecx,eax         {update bit offset}
    mov   eax,ecx
    shr   eax,3
    add   edi,eax         {update byte offset}
    and   ecx,7           {update bit offset}
    or    edx,edx         {more pixels to merge?}
    jnz   @1              {jump if so}

@3: sub   edi,ebx
    mov   ebx,edi
    mov   edi,LByteOfs
    mov   [edi],ebx
    mov   edi,LBitOfs
    mov   [edi],ecx

    pop   ebx
    pop   edi
    pop   esi
  end;
  {$ENDIF}

  { Move source to Dest -- doubling each bit.  Count is amount of source }
  { to move -- Dest is assumed to be big enough to handle (Count x 2)    }
  {$IFDEF Win32}
  procedure StretchMove(const Source; var Dest; Count : Integer); register;
  asm
    push  esi
    mov   esi, eax            // Source pointer to ESI
    push  edi
    push  ebx
    mov   edi, edx            // Dest pointer to EDI
    xor   edx, edx            // Clear EDX

  @@1:
    mov   bl, [esi]           // Load source byte
    mov   eax, 8

  @@2:
    shl   edx, 2              // Shift bits into position
    rcl   bl, 1               // Set CF if high bit is set
    jnc   @@3
    or    dl, 03h             // Set bits

  @@3:
    dec   eax                 // Loop if bits left
    jnz   @@2

    mov   [edi], dh           // DH to output
    mov   [edi+1], dl         // DL to output
    add   edi, 2              // Advance Dest pointer

    inc   esi                 // Advance Source pointer
    dec   ecx                 // Decrement counter, loop if more to read
    jnz   @@1

    pop   ebx                 // Restore registers
    pop   edi
    pop   esi
  end;
  {$ELSE}
  procedure StretchMove(const Source; var Dest; Count : Integer); assembler;
  asm
    push  ds
    lds   si,[Source]
    les   di,[Dest]
    mov   dx,Count
    cld
  @@1:
    lodsb
    mov   cx,8
    xor   bx,bx
  @@2:
    shl   bx,1
    shl   bx,1
    rcl   al,1
    jnc   @@3
    add   bx,3  {11b}
  @@3:
    loop  @@2
    mov   ax,bx
    ror   ax,8
    stosw
    dec   dx
    jnz   @@1
    pop   ds
  end;
  {$ENDIF}

  procedure fcRasterizeText(Cvt : PAbsFaxCvt; St : PChar; Row : Cardinal; var Data);
    {-Turn a row in a string into a raster line}
  var
    SLen       : Cardinal;
    LByteOfs   : Cardinal;
    LBitOfs    : Cardinal;
    I          : Integer;
    YW         : Integer;
    CHandle    : HDC;

  begin
    with Cvt^, PTextFaxData(Cvt^.UserData)^ do begin
      {validate row}
      if (Row > FontRec.Height) then
        Exit;
      if IsExtended then begin                                 
        if (Row = 1) then begin
          CHandle := Bitmap.Canvas.Handle;
          PatBlt(CHandle, 0, 0, Bitmap.Width, Bitmap.Height, WHITENESS);
          TextOut(CHandle, 0, 0, St, StrLen(St));
          PatBlt(CHandle, 0, 0, Bitmap.Width, Bitmap.Height, DSTINVERT);
          GetBitmapBits(Bitmap.Handle, ImageSize, ImageData);
          Offset := 0;
        end;
        if UseHighRes then
          Move(GetPtr(ImageData, Offset)^, Data, (LineBytes))
        else
          StretchMove(GetPtr(ImageData, Offset)^, Data, (LineBytes div 2));
        Inc(Offset, LineBytes);
      end else begin                                          
        YW := (Row - 1) * FontRec.Width;
        LByteOfs := 0;
        LBitOfs  := 0;
        SLen := StrLen(St);
        if (SLen > 0) then
          for I := 0 to Pred(SLen) do
            fcAddRasterChar(FontPtr^[Byte(St[I])*FontRec.Bytes+YW],
              Data, FontRec.PWidth, LByteOfs, LBitOfs);
      end;
    end;
  end;

  {$IFNDEF Win32}
  function fcDetab(Dest : PChar; Src : PChar; TabSize : Byte) : PChar; assembler;
    {-Expand tabs in a string to blanks on spacing TabSize}
  asm
    push   ds
    cld
    xor    cx,cx                    {Default input length = 0}
    xor    dx,dx                    {Default output length = 0 in DL}
    lds    si,Src                   {DS:SI => input string}
    les    di,Dest                  {ES:DI => output string}
    push   es                       {save ES:DI for function result}
    push   di
    xor    bh,bh
    mov    bl,TabSize               {BX has tab size}
    or     bl,bl                    {Return zero length string if TabSize = 0}
    jz     @@Done

    mov    ah,09                    {Store tab in AH}

  @@Next:
    lodsb                           {Next input character}
    or     al,al                    {Is it a null?}
    jz     @@Done
    cmp    al,ah                    {Is it a tab?}
    je     @@Tab                    {Yes, compute next tab stop}
    stosb                           {No, store to output}
    inc    dx                       {Increment output length}
    jmp    @@Next                   {Next character}

  @@Tab:
    push   dx                       {Save output length}
    mov    ax,dx                    {Current output length in DX:AX}
    xor    dx,dx
    div    bx                       {OLen DIV TabSize in AL}
    inc    ax                       {Round up to next tab position}
    mul    bx                       {Next tab position in AX}
    pop    dx                       {Restore output length}
    sub    ax,dx                    {Count of blanks to insert}
    add    dx,ax                    {New output length in DL}
    mov    cx,ax                    {Loop counter for blanks}
    mov    ax,$0920                 {Tab in AH, Blank in AL}
    rep    stosb                    {Store blanks}
    jmp    @@Next                   {Back for next input}

  @@Done:
    xor    al,al
    stosb
    pop    ax                       {function result = Dest}
    pop    dx
    pop    ds
  end;
  {$ELSE}
  function fcDetab(Dest : PChar; Src : PChar; TabSize : Byte;
    BufLen : DWORD) : PChar; assembler; register;                        {!!.04}
    {-Expand tabs in a string to blanks on spacing TabSize}
  asm
    push  esi
    push  edi
    push  ebx

    push  eax

    cld

    {load parameters}
    mov   edi,eax     {edi = Dest}
    mov   esi,edx     {esi = Src}
    xor   ebx,ebx
    mov   bl,cl       {cl = TabSize}

    xor   ecx,ecx     {Default input length = 0}
    xor   edx,edx     {Default output length = 0 in DL}
    or    bl,bl
    jz    @@Done      {Return zero length string if tabsize = 0}

    mov   ah,09       {store tab in AH}

  @@Next:
    mov   al,[esi]    {next input character}
    or    al,al       {is it a null?}
    jz    @@Done
    inc   esi
    cmp   al,ah       {is it a tab?}
    je    @@Tab       {yes, compute next tab stop}
    mov   [edi],al    {no, store to output}
    inc   edi
    inc   edx         {increment output length}
    cmp   edx,BufLen  {check if we have room in buffer}                  {!!.04}
    jge   @@Done      {bail if not}                                      {!!.04}
    jmp   @@Next      {next character}

  @@Tab:
    push  edx         {save output length}
    mov   eax,edx     {current output length in edx:eax}
    xor   edx,edx
    div   ebx         {OLen div TabSize in al}
    inc   eax         {Round up to next tab position}
    mul   ebx         {next tab position in eax}
    pop   edx         {restore output length}
    sub   eax,edx     {count of blanks to insert}
    add   edx,eax     {new output length in edx}
    cmp   edx,BufLen  {check if we have room in the buffer}              {!!.04}
    jge   @@Done      {bail if not}                                      {!!.04}
    mov   ecx,eax     {loop counter for blanks}
    mov   ax,$0920    {tab in ah, blank in al}
    rep   stosb       {store blanks}
    jmp   @@Next      {back for next input}

  @@Done:
    mov   byte ptr [edi],0

    pop   eax         {function result = Dest}

    pop   ebx
    pop   edi
    pop   esi
  end;
  {$ENDIF}

  function fcGetTextRasterLine( Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                                var EndOfPage, MorePages : Bool) : Integer;
    {-Convert a string of text into a raster line}
  var
    SLen         : Cardinal;
    MaxLen       : Integer;
    C            : Integer;
    FFPos        : Integer;
    FFWasPending : Boolean;
    St           : string;                                        
    B            : TByteArray absolute Data;
  begin
    {assume success}
    fcGetTextRasterLine := ecOK;
    with Cvt^, PTextFaxData(UserData)^ do begin
      FFWasPending := False;
      {do we need to load a new string?}
      if (CurRow = 0) then begin
        {if at end of file, exit}
        if InFile.EOLF and (Pending = '') then begin
          if (CurrLine = 1) then begin
            EndOfPage := False;
            MorePages := False;
            FillChar(Data, ResWidth div 8, 0);
          end else begin
            EndOfPage := True;
            MorePages := False;
          end;
          Exit;
        end;

        {read the line from the input file}
        if FFPending then begin
          St := Pending;
          Pending := '';                                           
          FFPending    := False;
          FFWasPending := True;
        end else begin
          St := InFile.NextLine;
          BytesRead := InFile.BytesRead;
          BytesToRead := InFile.FileSize;
        end;

        {check for form feeds}
        FFPos := pos(#12, St);                                     
        if (FFPos <> 0) then begin
          Pending := Copy(St,FFPos+1,255);
          {$IFDEF Windows}
          St[0] := Chr(FFPos-1);
          {$ELSE}
          SetLength(St,FFPos-1);
          {$ENDIF}
          FFPending := True;
        end;
        CurRow := 1;

        {expand the tabs in the line of text}
        AppendStr(St,#0);
        {$IFDEF Windows}
        fcDetab(CurStr, @St[1], TabStop);
        {$ELSE}
        fcDetab(CurStr, pChar(St), TabStop, High(CurStr));               {!!.04}
        {$ENDIF}

        if not IsExtended then begin                              
          {adjust the string length, accounting for margins}
          {this is handled automagically by the bitmap size in extended text mode}
          SLen := StrLen(CurStr);
          C := LeftMargin div FontRec.PWidth;
          MaxLen := Integer(ResWidth div FontRec.PWidth) - C;
          if (SLen > Cardinal(MaxLen)) then
            SLen := MaxLen;
          CurStr[SLen] := #0;
        end;                                                          

        {check to see if we're at the end of the page}
        Inc(OnLine);
        if FFWasPending or ((LineCount <> 0) and (OnLine > LineCount)) then begin
          OnLine := 1;
          EndOfPage := True;
          MorePages := not InFile.EOLF or (Pending <> '');
          if MorePages and FFWasPending and (Pending = '') then
            CurRow := 0;
          Exit;
        end;
      end;

      {convert the next string row}
      if IsExtended then begin
        Len := ResWidth div 8;
      end else begin
        Len := FontRec.PWidth * StrLen(CurStr);
        Len := (Len div 8) + Ord((Len mod 8) <> 0);
      end;
      fcRasterizeText(Cvt, CurStr, CurRow, Data);

      Inc(CurRow);

      if (CurRow > FontRec.Height) then
        CurRow := 0;

      EndOfPage := False;
      MorePages := True;
    end;
  end;

{TIFF-to-fax conversion routines}

  procedure tcInitTiffConverter(var Cvt : PAbsFaxCvt);
    {-Initialize a text-to-fax converter}
  var
    TiffCvtData : PTiffFaxData;
  begin
    Cvt := nil;

    {initialize converter specific data}
    TiffCvtData := AllocMem(SizeOf(TTiffFaxData));

    TiffCvtData^.ReadBuffer := AllocMem(ReadBufferSize);
    TiffCvtData^.CompMethod := compNONE;

    {initialize the abstract converter}
    acInitFaxConverter( Cvt, TiffCvtData, tcGetTiffRasterLine,
                                tcOpenFile, tcCloseFile, DefTiffExt);
  end;

  procedure tcDoneTiffConverter(var Cvt : PAbsFaxCvt);
    {-Destroy a TIFF converter}
  begin
    FreeMem(PTiffFaxData(Cvt^.UserData)^.ReadBuffer, ReadBufferSize);
    FreeMem(Cvt^.UserData, SizeOf(TTiffFaxData));
    acDoneFaxConverter(Cvt);
  end;

  function tcGetByte(Cvt : PAbsFaxCvt; var B : Byte) : Integer;
    {-Read a byte from a TIFF file}
  var
    Code : Integer;

  begin
    with PTiffFaxData(Cvt^.UserData)^ do begin
      {buffer empty?}
      if (CurrRBOfs >= CurrRBSize) then begin
        {refill buffer}
        BlockRead(InFile, ReadBuffer^, ReadBufferSize, CurrRBSize);
        if (CurrRBSize = 0) then
          Code := ecDeviceRead
        else
          Code := -IoResult;
        if (Code < ecOK) then begin
          tcGetByte := Code;
          Exit;
        end;
        CurrRBOfs := 0;
      end;
      B := ReadBuffer^[CurrRBOfs];
      Inc(CurrRBOfs);
      tcGetByte := ecOK;
    end;
  end;

  function tcGetWord(Cvt : PAbsFaxCvt; var W : Word) : Integer;
    {-Read a word from a TIFF file}
  var
    B    : array[1..2] of Byte;
    Code : Integer;

  begin
    {read two bytes}
    Code := tcGetByte(Cvt, B[1]);
    if (Code = ecOK) then
      Code := tcGetByte(Cvt, B[2]);
    if (Code < ecOK) then begin
      tcGetWord := Code;
      Exit;
    end;

    tcGetWord := ecOK;
    if PTiffFaxData(Cvt^.UserData)^.Intel then
      Move(B[1], W, SizeOf(Word))
    else
      W := B[2] + Word(B[1] shl 8);
  end;

  function tcGetLong(Cvt : PAbsFaxCvt; var L : LongInt) : Integer;
    {-Read a long integer from a TIFF file}
  var
    B    : array[1..4] of Byte;
    I    : Integer;
    Code : Integer;

  begin
    {read four bytes}
    for I := 1 to 4 do begin
      Code := tcGetByte(Cvt, B[I]);
      if (Code < ecOK) then begin
        tcGetLong := Code;
        Exit;
      end;
    end;

    tcGetLong := ecOK;
    if PTiffFaxData(Cvt^.UserData)^.Intel then
      Move(B[1], L, SizeOf(LongInt))
    else
      L := LongInt(B[1]) shl 24 +
           LongInt(B[2]) shl 16 +
           LongInt(B[3]) shl 8  +
           LongInt(B[4]);
  end;

  function tcSeek(Cvt : PAbsFaxCvt; NewOfs : LongInt) : Integer;
  begin
    with PTiffFaxData(Cvt^.UserData)^ do begin
      {seek to location in input file}
      Seek(InFile, NewOfs);
      tcSeek := -IoResult;

      {force buffer reload}
      CurrRBSize := 0;
      CurrRBOfs  := 999;
    end;
  end;

  function tcOpenInputFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a TIFF file for reading}
  var
    Code     : Integer;
    SaveMode : Integer;

  label
    ErrorExit;

    function ValidateTiff : Integer;
      {-Read the TIFF file header and validate it}
    var
      C1 : Char;
      C2 : Char;
      L  : LongInt;

    label
      ValidError;

    begin
      {assume failure}
      ValidateTiff := ecBadGraphicsFormat;

      with PTiffFaxData(Cvt^.UserData)^ do begin
        {get Intel or Motorola byte-order flags}
        Code := tcGetByte(Cvt, Byte(C1));
        if (Code < ecOK) then
          goto ValidError;
        Code := tcGetByte(Cvt, Byte(C2));
        if (Code < ecOK) then
          goto ValidError;

        if (C1 = 'I') and (C2 = 'I') then
          Intel := True
        else if (C1 = 'M') and (C2 = 'M') then
          Intel := False
        else
          Exit;

        {Get version flag}
        Code := tcGetWord(Cvt, Version);
        if (Code < ecOK) then
          goto ValidError;

        {find start of image directory}
        Code := tcGetLong(Cvt, L);
        if (Code < ecOK) then
          goto ValidError;
        if (L > 0) then begin
          Code := tcSeek(Cvt, L);
          if (Code < ecOK) then
            goto ValidError;
        end;

        ValidateTiff := ecOK;
        Exit;

      ValidError:
        ValidateTiff := Code;
      end;
    end;

    function DecodeTag : Integer;
      {-Retrieve and decode the next tag field from the file}
    const
      LastMasks : array[0..7] of Byte =
        ($FF, $80, $C0, $E0, $F0, $F8, $FC, $FE);

    var
      Tag     : Word;
      TagType : Word;
      Dummy   : Word;
      Len     : LongInt;
      Offset  : LongInt;
      Code    : Integer;

      function Pixels2Bytes(W : Cardinal) : Cardinal;
      begin
        Pixels2Bytes := (W + 7) shr 3;
      end;

    begin
      with PTiffFaxData(Cvt^.UserData)^ do begin
        {get next tag}
        Code := tcGetWord(Cvt, Tag);
        if (Code = ecOK) then
          Code := tcGetWord(Cvt, TagType);
        if (Code < ecOK) then begin
          DecodeTag := Code;
          Exit;
        end;

        {process the tag}
        case TagType of
          tiffShort :
            begin
              Code := tcGetWord(Cvt, Dummy);
              if (Code = ecOK) then begin
                Len := Dummy;
                Code := tcGetWord(Cvt, Dummy);
                if (Code = ecOK) then begin
                  Code := tcGetWord(Cvt, Dummy);
                  Offset := Dummy;
                  if (Code = ecOK) then
                    Code := tcGetWord(Cvt, Dummy);
                end;
              end;
            end;

          tiffLong:
            begin
              Code := tcGetLong(Cvt, Len);
              if (Code = ecOK) then
                Code := tcGetLong(Cvt, Offset);
            end;

          else
            {unsupported tag, just read and discard the data}
            Code := tcGetLong(Cvt, Len);
            if (Code = ecOK) then
              Code := tcGetLong(Cvt, Offset);
        end;

        case Tag of
          SubFileType      : SubFile := Cardinal(Offset);
          ImageWidth       :
            begin
              ImgWidth    := Cardinal(Offset);
              ImgBytes    := Pixels2Bytes(ImgWidth);
              LastBitMask := LastMasks[ImgWidth mod 8];
            end;

          ImageLength      :
            begin
              NumLines := Cardinal(Offset);
              ImgLen   := NumLines;
            end;
          RowsPerStrip     :
            if (TagType = tiffLong) then
              RowStrip := Offset
            else
              RowStrip := Offset and $0000FFFF;

          StripOffsets     :
            if (TagType = tiffLong) then begin
              StripOfs := Offset;
              StripCnt := Len;
            end else begin
              StripOfs := Offset and $0000FFFF;
              StripCnt := Len and $0000FFFF;
            end;

          Compression      :
            begin
              CompMethod := Cardinal(Offset);
              if (CompMethod <> compNone) and (CompMethod <> compMPNT) then
                Code := ecBadGraphicsFormat;
            end;

          PhotoMetricInterp: PhotoMet := Cardinal(Offset);
          BitsPerSample    :
            if (Offset <> 1) then
              Code := ecBadGraphicsFormat;

          StripByteCounts  : ByteCntOfs := Offset;
        end;

        DecodeTag := Code;
      end;
    end;

    function ReadTagDir : Integer;
      {-Read the tag directory from the TIFF file header}
    var
      W    : Word;
      X    : Word;
      Code : Integer;

    begin
      with PTiffFaxData(Cvt^.UserData)^ do begin
        {assume we're at the start of a directory; get the tags count}
        Code := tcGetWord(Cvt, W);
        if (Code < ecOK) then begin
          ReadTagDir := Code;
          Exit;
        end;

        {read that many tags and decode}
        for X := 1 to W do begin
          Code := DecodeTag;
          if (Code < ecOK) then begin
            ReadTagDir := Code;
            Exit;
          end;
        end;

        {Have we picked up the data we need?}
        if (ImgWidth = 0) or (NumLines = 0) or (StripOfs = 0) then
          ReadTagDir := ecBadGraphicsFormat
        else
          ReadTagDir := ecOK;
      end;
    end;

    function LoadStripInfo : Integer;
      {-Load strip offsets/lengths}
    var
      Len : Cardinal;
      I   : Cardinal;

    label
      StripError;

    begin
      with PTiffFaxData(Cvt^.UserData)^ do begin
        {get memory for array}
        Len := StripCnt * SizeOf(TStripRecord);
        StripInfo := AllocMem(Len);

        {seek to start of strip byte count list}
        Code := tcSeek(Cvt, ByteCntOfs);
        if (Code < ecOK) then
          goto StripError;

        {load lengths}
        for I := 1 to StripCnt do begin
          Code := tcGetLong(Cvt, StripInfo^[I].Length);
          if (Code < ecOK) then
            goto StripError;
        end;

        {seek to start of strip offset list}
        Code := tcSeek(Cvt, StripOfs);
        if (Code < ecOK) then
          goto StripError;

        {load offfsets}
        for I := 1 to StripCnt do begin
          Code := tcGetLong(Cvt, StripInfo^[I].Offset);
          if (Code < ecOK) then
            goto StripError;
        end;

        LoadStripInfo := ecOK;
        Exit;

      StripError:
        LoadStripInfo := Code;
        FreeMem(StripInfo, Len);
      end;
    end;

  begin
    with PTiffFaxData(Cvt^.UserData)^ do begin
      CurrRBSize := 0;
      CurrRBOfs  := $FFFF;
      SaveMode   := FileMode;
      FileMode   := ApdShareFileRead;                                  
      Assign(InFile, FileName);
      Reset(InFile, 1);
      FileMode   := SaveMode;
      Code       := -IoResult;
      if (Code < ecOK) then begin
        tcOpenInputFile := Code;
        Exit;
      end;

      {validate the TIFF file format and read the tag directory}
      Code := ValidateTiff;
      if (Code = ecOK) then
        Code := ReadTagDir;
      if (Code < ecOK) then
        goto ErrorExit;

      {If it's a multi-strip file, load the strip offset lengths}
      if (StripCnt > 1) then begin
        Code := LoadStripInfo;
        if (Code < ecOK) then
          goto ErrorExit;
      end;

      Cvt^.BytesToRead := ImgBytes * ImgLen;

      tcOpenInputFile := ecOK;
      Exit;

    ErrorExit:
      Close(InFile); if (IoResult = 0) then ;
      tcOpenInputFile := Code;
    end;
  end;

  function tcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a TIFF file for input}
  var
    Code : Integer;

  begin
    {open the input file}
    Code := tcOpenInputFile(Cvt, FileName);
    if (Code < ecOK) then begin
      tcOpenFile := Code;
      Exit;
    end;

    {initialize converter parameters}
    with Cvt^, PTiffFaxData(UserData)^ do begin
      if FlagIsSet(Flags, fcDoubleWidth) then
        DoubleWidth := not UseHighRes and
                       ((ImgWidth * 2) <= (ResWidth - LeftMargin));
      HalfHeight := not UseHighRes and not DoubleWidth and FlagIsSet(Flags, fcHalfHeight);

      {center image in fax image}
      CenterOfs := 0;
      if FlagIsSet(Flags, fcCenterImage) then
        if ((ResWidth - ImgWidth) >= 16) then begin
          {only center if at least one byte on each side}
          if DoubleWidth then
            CenterOfs := (ResWidth - (ImgWidth * 2)) div 32
          else
            CenterOfs := (ResWidth - ImgWidth) div 16;
        end;

      OnStrip  := 1;
      OnRaster := 1;

      {set single-strip values if this is a multi-strip image}
      if (StripCnt > 1) then begin
        NumLines := RowStrip;

        Code := tcSeek(Cvt, StripInfo^[1].Offset);
        if (Code < ecOK) then begin
          FreeMem(StripInfo, StripCnt * SizeOf(TStripRecord));
          Close(InFile); if (IoResult = 0) then ;
          tcOpenFile := Code;
          Exit;
        end;

      {otherwise, seek to the beginning of the image for single strip}
      end else begin
        Code := tcSeek(Cvt, ImgStart+StripOfs);
        if (Code < ecOK) then begin
          Close(InFile); if (IoResult = 0) then ;
          tcOpenFile := Code;
          Exit;
        end;
      end;
    end;

    tcOpenFile := ecOK;
  end;

  procedure tcCloseFile(Cvt : PAbsFaxCvt);
    {-Close TIFF file}
  begin
    with Cvt^, PTiffFaxData(UserData)^ do begin
      Close(InFile); if (IoResult = 0) then ;

      FreeMem(StripInfo, StripCnt * SizeOf(TStripRecord));
    end;
  end;

  function tcGetTiffRasterLine( Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                                var EndOfPage, MorePages : Bool) : Integer;
    {-Callback to read a row of TIFF raster data}
  var
    Code : Integer;
    Buf  : TByteArray absolute Data;

    function ReadRasterLine : Integer;
      {-Read and decompress the next line of raster data from the file}
    var
      W    : Cardinal;
      Code : Integer;
      B    : Byte;
      C    : Byte;

    begin
      with Cvt^, PTiffFaxData(UserData)^ do begin
        if (CompMethod = compNone) then begin
          {read each byte of raster image}
          for W := 0 to Pred(ImgBytes) do begin
            Code := tcGetByte(Cvt, Buf[W]);
            if (Code < ecOK) then begin
              ReadRasterLine := Code;
              Exit;
            end;

          end;
          Inc(BytesRead, ImgBytes);
        end else if (CompMethod = compMPNT) then begin
          W := 0;
          {decode compressed bytes until we have enough for one line}
          while (W < ImgBytes) do begin
            {get control byte}
            Code := tcGetByte(Cvt, B);
            if (Code < ecOK) then begin
              ReadRasterLine := Code;
              Exit;
            end;

            {if high bit is set, this is a run length}
            if ((B and $80) = $80) then begin
              {get run length}
              B := Byte(-ShortInt(B) + 1);

              {get byte to repeat}
              Code := tcGetByte(Cvt, C);
              if (Code < ecOK) then begin
                ReadRasterLine := Code;
                Exit;
              end;

              {repeat the byte}
              if ((W + B) < MaxData) then
                FillChar(Buf[W], B, C);
              Inc(W, B);
            end else begin
              {literal data counter = B + 1}
              Inc(B);
              {read B bytes and put them in the output line}
              while (B > 0) do begin
                if (W < MaxData) then begin
                  Code := tcGetByte(Cvt, Buf[W]);
                  if (Code < ecOK) then begin
                    ReadRasterLine := Code;
                    Exit;
                  end;
                end;
                Inc(W);
                Dec(B);
              end;
            end;
          end;

          Inc(BytesRead, ImgBytes);
        end;

        if (PhotoMet > 0) then
          for W := 0 to Pred(ImgBytes) do begin
            Buf[W] := not(Buf[W]);
            if (W = Word(Pred(ImgBytes))) then                      
              Buf[W] := Buf[W] and LastBitMask;
          end;
      end;

      ReadRasterLine := ecOK;
    end;

    function DecodeStripLine : Integer;
      {-Decode current strip, assume already seeked to image start}
    var
      Code      : Integer;
      ByteWidth : Cardinal;

    begin
      with Cvt^, PTiffFaxData(UserData)^ do begin
        ByteWidth := (ImgWidth div 8) + Ord((ImgWidth mod 8) <> 0);

        Code := ReadRasterLine;
        if (Code < ecOK) then begin
          DecodeStripLine := Code;
          Exit;
        end;

        if (CenterOfs <> 0) then begin
          if ((CenterOfs + ByteWidth) < MaxData) then begin
            Move(Buf[0], Buf[CenterOfs], ByteWidth);
            FastZero(Buf[0], CenterOfs);
          end;
        end;
      end;

      DecodeStripLine := ecOK;
    end;

  begin
    with Cvt^, PTiffFaxData(UserData)^ do begin
      tcGetTiffRasterLine := ecOK;

      MorePages := False;
      EndOfPage := (OnRaster > NumLines) and (OnStrip = StripCnt);
      if EndOfPage then
        Exit;

      {if this is a single strip image, process this strip}
      if (StripCnt = 1) then begin
        {Decode the next raster line in the strip}
        Code := DecodeStripLine;
        Inc(OnRaster);

      {multiple strip image--seek to next strip}
      end else begin
        {Decode this the next raster line in the strip}
        Code := DecodeStripLine;
        Inc(OnRaster);
        if (OnRaster > NumLines) and (OnStrip < StripCnt) then begin
          OnRaster := 1;
          Inc(OnStrip);
          {set single-strip values}
          if (OnStrip = StripCnt) then
            NumLines := (ImgLen - (Pred(StripCnt) * RowStrip))
          else
            NumLines := RowStrip;

          {seek to the beginning of the next strip}
          Code := tcSeek(Cvt, StripInfo^[OnStrip].Offset);
          if (Code < ecOK) then begin
            tcGetTiffRasterLine := Code;
            Exit;
          end;
        end;
      end;
      Len := ImgBytes;
    end;

    tcGetTiffRasterLine := Code;
  end;

{PCX conversion routines}

  procedure pcInitPcxData(var PcxCvtData : PPcxFaxData);
    {-Initialize base PCX converter data}
  begin
    PcxCvtData  := nil;

    {initialize converter specific data}
    PcxCvtData := AllocMem(SizeOf(TPcxFaxData));
    with PcxCvtData^ do
      ReadBuffer := AllocMem(ReadBufferSize);

  end;

  procedure pcDonePcxData(var PcxCvtData : PPcxFaxData);
    {-Destroy base PCX converter data}
  begin
    FreeMem(PcxCvtData^.ReadBuffer, ReadBufferSize);
    FreeMem(PcxCvtData^.DcxData, SizeOf(TDcxFaxData));
    FreeMem(PcxCvtData, SizeOf(TPcxFaxData));
    PcxCvtData := nil;
  end;

  procedure pcInitPcxConverter(var Cvt : PAbsFaxCvt);
    {-Initialize a PCX-to-fax converter}
  var
    PcxCvtData : PPcxFaxData;
  begin
    Cvt := nil;

    {initialize converter specific data}
    pcInitPcxData(PcxCvtData);

    {initialize the abstract converter}
    acInitFaxConverter( Cvt, PcxCvtData, pcGetPcxRasterLine,
                                pcOpenFile, pcCloseFile, DefPcxExt);
  end;

  procedure pcDonePcxConverter(var Cvt : PAbsFaxCvt);
    {-Destroy a PCX-to-fax converter}
  begin
    pcDonePcxData(PPcxFaxData(Cvt^.UserData));
    acDoneFaxConverter(Cvt);
  end;

  function pcPreparePcxImage(Cvt : PAbsFaxCvt) : Integer;
    {-Prepare a PCX image for conversion}
  var
    Code : Integer;

    function ValidatePcxHdr : Bool;
      {-Make sure the PCX header is valid}
    begin
      ValidatePcxHdr := False;
      with Cvt^, PPcxFaxData(UserData)^, PcxHeader do begin
        {if Mfgr byte <> $0A or Encoding byte <> $01, it's not a PCX file}
        if (Mfgr <> $0A) or (Encoding <> $01) then
          Exit;

        {we only handle color depth = 1 (monochrome)}
        if (BitsPixel <> $01) then
          Exit;

        {validate image is not too wide}
        if (Cardinal(XMax - XMin) > ResWidth) then                  
          Exit;
      end;
      ValidatePcxHdr := True;
    end;

  begin
    pcPreparePcxImage := ecOK;

    with Cvt^, PPcxFaxData(UserData)^ do begin
      BlockRead(InFile, PcxHeader, SizeOf(TPcxHeaderRec));
      Code := -IoResult;
      if (Code < ecOK) then begin
        pcPreparePcxImage := Code;
        Exit;
      end;

      {validate the PCX file}
      if not ValidatePcxHdr then begin
        pcPreparePcxImage := ecBadGraphicsFormat;
        Exit;
      end;

      {need double width scaling?}
      with PcxHeader do begin
        PcxWidth := (XMax - XMin + 1);
        if FlagIsSet(Flags, fcDoubleWidth) then
          DoubleWidth := not UseHighRes and
                         ((PcxWidth * 2) <= (ResWidth - LeftMargin));
        HalfHeight := not UseHighRes and not DoubleWidth and FlagIsSet(Flags, fcHalfHeight);
      end;

      {center PCX image in fax image}
      CenterOfs := 0;
      if FlagIsSet(Flags, fcCenterImage) then
        if ((ResWidth - PcxWidth) >= 16) then begin
          {only center if at least one byte on each side}
          if DoubleWidth then
            CenterOfs := (ResWidth - (PcxWidth * 2)) div 32
          else
            Centerofs := (ResWidth - PcxWidth) div 16;
        end;

      CurrRBSize   := 1;
      CurrRBOfs    := $FFFF;
      ActBytesLine := ((PcxHeader.XMax - PcxHeader.XMin + 1) + 7) shr 3;
    end;
  end;

  function pcOpenInputFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a PCX file for reading}
  var
    Code     : Integer;
    SaveMode : Integer;

  label
    ErrorExit;

  begin
    pcOpenInputFile := ecOK;

    with Cvt^, PPcxFaxData(UserData)^ do begin
      Assign(InFile, FileName);
      SaveMode := FileMode;
      FileMode := ApdShareFileRead;                                    
      Reset(InFile, 1);
      FileMode := SaveMode;
      Code := -IoResult;
      if (Code < ecOK) then begin
        pcOpenInputFile := Code;
        Exit;
      end;

      Code := pcPreparePcxImage(Cvt);
      if (Code < ecOK) then begin
        Close(InFile); if (IoResult = 0) then ;
        pcOpenInputFile := Code;
      end else begin
        PcxBytes    := FileSize(InFile) - SizeOf(TPcxHeaderRec);
        BytesToRead := PcxBytes;
        Code := -IoResult;
        if (Code < ecOK) then begin
          Close(InFile); if (IoResult = 0) then ;
          pcOpenInputFile := Code;
        end else
          ActBytesLine := (PcxHeader.XMax - PcxHeader.XMin + 1) div 8;
      end;
    end;
  end;

  function pcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a PCX file for input}
  var
    Code : Integer;

  begin
    with Cvt^, PPcxFaxData(UserData)^ do begin
      {open the input file}
      Code := pcOpenInputFile(Cvt, FileName);
      if (Code < ecOK) then begin
        pcOpenFile := Code;
        Exit;
      end;
    end;

    pcOpenFile := ecOK;
  end;

  procedure pcCloseFile(Cvt : PAbsFaxCvt);
    {-Close PCX file}
  begin
    with Cvt^, PPcxFaxData(UserData)^ do begin
      Close(InFile); if (IoResult = 0) then ;
    end;
  end;

  function pcGetPcxRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                              var EndOfPage, MorePages : Bool) : Integer;
    {-Callback to read a row of PCX raster data}
  var
    Buf       : TByteArray absolute Data;
    ByteWidth : Cardinal;
    Code      : Integer;

    function ReadRasterLine : Integer;
      {-Read a raster line from a PCX file}
    var
      First : Bool;
      OK    : Bool;
      N     : Integer;
      Code  : Integer;
      B     : Byte;
      L     : Byte;

    begin
      with Cvt^, PPcxFaxData(UserData)^ do begin
        First := False;
        L     := 0;

        {unpack the next raster line of PCX data}
        N := 0;
        while (PcxBytes > 0) and (N < PcxHeader.BytesLine) do begin
          if (CurrRBOfs >= CurrRBSize) then begin
            BlockRead(InFile, ReadBuffer^, ReadBufferSize, CurrRBSize);
            Code := -IoResult;
            if (Code < ecOK) then begin
              ReadRasterLine := Code;
              Exit;
            end;

            if (CurrRBSize > PcxBytes) then
              CurrRBSize := PcxBytes;
            CurrRBOfs := 0;
          end;

          B := ReadBuffer^[CurrRBOfs];
          Inc(CurrRBOfs);
          Inc(BytesRead);

          if First then begin
            B := not B;         {PCX files store in reverse format (1=white)}

            {make sure data fits}
            if ((N + L) < MaxData) then begin
              {ignore extra bytes for 2.8 and earlier}
              if (PcxHeader.Ver <= 3) then
                Ok := Cardinal(N+L) <= ActBytesLine
              else
                Ok := True;
              if Ok then
                FillChar(Buf[N], L, B);
            end;
            Inc(N, L);
            First := False;
          end else if ((B and $C0) = $C0) then begin
            L := B and $3F;
            First := True;
          end else begin
            if (N < MaxData) then
              Buf[N] := not B;
            Inc(N);
          end;

          Dec(PcxBytes);
        end;
      end;

      ReadRasterLine := ecOK;
    end;

  begin
    with Cvt^, PPcxFaxData(UserData)^ do begin
      pcGetPcxRasterLine := ecOK;

      MorePages := False;
      EndOfPage := (PcxBytes = 0) or (CurrRBSize = 0);
      if (EndOfPage) then
        Exit;

      FastZero(Buf, MaxData);
      Code := ReadRasterLine;
      if (Code < ecOK) then begin
        pcGetPcxRasterLine := Code;
        Exit;
      end;

      if (CurrRBSize <> 0) then begin
        ByteWidth := PcxWidth div 8;
        if (CenterOfs <> 0) then begin
          if ((CenterOfs+ByteWidth) < MaxData) then begin
            Move(Buf[0], Buf[CenterOfs], ByteWidth);
            FastZero(Buf[0], CenterOfs);
          end;
        end;
      end;

      Len := PcxHeader.BytesLine;
    end;
  end;

{DCX conversion routines}

  procedure dcInitDcxConverter(var Cvt : PAbsFaxCvt);
    {-Initialize a DCX-to-fax converter}
  var
    PcxCvtData : PPcxFaxData;
    DcxCvtData : PDcxFaxData;
  begin
    Cvt := nil;

    {initialize converter specific data}
    DcxCvtData := AllocMem(SizeOf(TDcxFaxData));

    pcInitPcxData(PcxCvtData);
    PcxCvtData^.DcxData := DcxCvtData;

    {initialize the abstract converter}
    acInitFaxConverter( Cvt, PcxCvtData, dcGetDcxRasterLine,
                                dcOpenFile, dcCloseFile, DefDcxExt);
  end;

  procedure dcDoneDcxConverter(var Cvt : PAbsFaxCvt);
    {-Destroy a PCX-to-fax converter}
  begin
    pcDonePcxData(PPcxFaxData(Cvt^.UserData));
    acDoneFaxConverter(Cvt);
  end;

  function dcOpenInputFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a DCX file for reading}
  var
    Code     : Integer;
    R        : Cardinal;
    I        : Cardinal;
    J        : Cardinal;
    PJ       : Cardinal;
    Pivot    : LongInt;
    Sz       : LongInt;
    SaveMode : Integer;

  begin
    with Cvt^, PPcxFaxData(UserData)^, DcxData^ do begin
      {open the file}
      Assign(InFile, FileName);
      SaveMode := FileMode;
      FileMode := ApdShareFileRead;                                    
      Reset(InFile, 1);
      FileMode := SaveMode;
      Code := -IoResult;
      if (Code < ecOK) then begin
        dcOpenInputFile := Code;
        Exit;
      end;

      {read the header}
      BlockRead(InFile, DcxHeader, SizeOf(DcxHeader), R);
      Sz := FileSize(InFile);
      Code := -IoResult;
      if (Code < ecOK) then begin
        Close(InFile); if (IoResult = 0) then ;
        dcOpenInputFile := Code;
        Exit;
      end;

      {validate the header}
      if (DcxHeader.ID <> DCXHeaderID) then begin
        dcOpenInputFile := ecBadGraphicsFormat;
        Close(InFile); if (IoResult = 0) then ;
        Exit;
      end;

      dcOpenInputFile := ecOK;

      {figure out how many pages there are in the index}
      DcxNumPag := 1;
      while (DcxHeader.Offsets[DcxNumPag] <> 0) do
        Inc(DcxNumPag);
      Dec(DcxNumPag);

      Move(DcxHeader.Offsets, DcxPgSz, SizeOf(LongInt) * DcxNumPag);
      if (DcxNumPag > 1) then begin
        {sort the index}
        repeat
          Pivot := DcxPgSz[1];
          for J := 2 to DcxNumPag do begin
            PJ := Pred(J);
            if (DcxPgSz[PJ] > DcxPgSz[J]) then begin
              Pivot       := DcxPgSz[PJ];
              DcxPgSz[PJ] := DcxPgSz[J];
              DcxPgSz[J]  := Pivot;
            end;
          end;
        until (Pivot = DcxPgSz[1]);

        {adjust the image lengths}
        for I := 1 to Pred(DcxNumPag) do
          DcxPgSz[I] := DcxPgSz[Succ(I)] - DcxPgSz[I];
        DcxPgSz[DcxNumPag] := Sz - DcxPgSz[DcxNumPag];

        BytesToRead := 0;
        for I := 1 to DcxNumPag do
          Inc(BytesToRead, DcxPgSz[I] - SizeOf(TPcxHeaderRec));
      end else begin
        DcxPgSz[1] := Sz - DcxHeader.Offsets[1] + 1;
        BytesToRead := DcxPgSz[1] - SizeOf(TPcxHeaderRec);
      end;
    end;
  end;

  function dcPrepPage(Cvt : PAbsFaxCvt; Page : Integer) : Integer;
    {-Prepare the next page in a DCX file for reading}
  var
    Code : Integer;

  begin
    dcPrepPage := ecOK;

    with Cvt^, PPcxFaxData(UserData)^, DcxData^ do begin
      Seek(InFile, DcxHeader.Offsets[Page]);
      {read the PCX header}
      Code := pcPreparePcxImage(Cvt);
      if (Code < ecOK) then begin
        dcPrepPage := Code;
        Exit;
      end;

      PcxBytes := DcxPgSz[Page] - SizeOf(TPcxHeaderRec);
    end;
  end;

  function dcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a DCX file for reading}
  var
    Code : Integer;

  begin
    with Cvt^, PPcxFaxData(UserData)^, DcxData^ do begin
      {open the input file}
      Code := dcOpenInputFile(Cvt, FileName);
      if (Code < ecOK) then begin
        dcOpenFile := Code;
        Exit;
      end;

      {prepare the first PCX file for reading}
      Code := dcPrepPage(Cvt, 1);

      dcOpenFile := Code;
    end;
  end;

  procedure dcCloseFile(Cvt : PAbsFaxCvt);
    {-Close DCX file}
  begin
    with Cvt^, PPcxFaxData(UserData)^, DcxData^ do begin
      Close(InFile); if (IoResult = 0) then ;
    end;
  end;

  function dcGetDcxRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                              var EndOfPage, MorePages : Bool) : Integer;
    {-Callback to read a row of DCX raster data}
  begin
    with Cvt^, PPcxFaxData(UserData)^, DcxData^ do begin
      dcGetDcxRasterLine := pcGetPcxRasterLine(Cvt, Data, Len, EndOfPage, MorePages);

      if EndOfPage then begin
        MorePages := (CurrPage < DcxNumPag);
        if MorePages then
          dcGetDcxRasterLine := dcPrepPage(Cvt, Succ(CurrPage));
      end;
    end;
  end;

{BMP-to-fax conversion routines}

  procedure bcInitBmpConverter(var Cvt : PAbsFaxCvt);
    {-Initialize a BMP-to-fax converter}
  var
    BmpCvtData : PBitmapFaxData;

  begin
    Cvt := nil;

    {initialize converter specific data}
    BmpCvtData := AllocMem(SizeOf(TBitmapFaxData));

    {initialize abstract converter}
    acInitFaxConverter( Cvt, BmpCvtData, bcGetBitmapRasterLine,
                                bcOpenFile, bcCloseFile, DefBmpExt);
  end;

  procedure bcDoneBmpConverter(var Cvt : PAbsFaxCvt);
    {-Destroy a BMP-to-fax converter}
  begin
    FreeMem(Cvt^.UserData, SizeOf(TBitmapFaxData));
    acDoneFaxConverter(cvt);
  end;

  function bcOpenFile(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open a BMP file for input}
  var
    Bmp : Graphics.TBitmap;
  begin
    {Open the input file}
    Bmp := Graphics.TBitmap.Create;
    try
      try
        Bmp.LoadFromFile(StrPas(FileName));
        Cvt^.InBitmap := Bmp;
        Result := bcSetInputBitmap(Cvt, 0);
        if Result <> ecOk then Exit;
        Result := bcOpenBitmap(Cvt, '');
        if Result <> ecOk then Exit;
      finally
        Bmp.Free;
      end;
    except
      on EInvalidGraphic do Result := ecBadGraphicsFormat;
      on E : EInOutError do Result := -E.ErrorCode;
    else
      Result := ecBadGraphicsFormat;
    end;
  end;

  procedure bcCloseFile(Cvt : PAbsFaxCvt);
    {-Close BMP file}
  begin
    { Call the bitmap converter's Close }
    bcCloseBitmap(Cvt);
  end;

  function bcGetBmpRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                              var EndOfPage, MorePages : Bool) : Integer;
    {-Callback to read a row of BMP raster data}
  begin
    { Call the bitmap converter's GetRasterLine -- not used internally }
    { This function is retained for backward compatability only }
    Result := bcGetBitmapRasterLine(Cvt, Data, Len, EndOfPage, MorePages);
  end;

  procedure bcInitBitmapConverter(var Cvt : PAbsFaxCvt);
    {-Initialize a bitmap-to-fax converter}
  var
    BmpCvtData : PBitmapFaxData;

  begin
    Cvt := nil;

    {initialize converter specific data}
    BmpCvtData := AllocMem(SizeOf(TBitmapFaxData));

    {initialize abstract converter}
    acInitFaxConverter( Cvt, BmpCvtData, bcGetBitmapRasterLine,
                                bcOpenBitmap, bcCloseBitmap, '');

  end;

  procedure bcDoneBitmapConverter(var Cvt : PAbsFaxCvt);
    {-Destroy a bitmap-to-fax converter}
  begin
    FreeMem(Cvt^.UserData, SizeOf(TBitmapFaxData));
    acDoneFaxConverter(Cvt);
  end;

  function bcSetInputBitmap(var Cvt : PAbsFaxCvt; Bitmap : HBitmap) : Integer;
    {-Set bitmap that will be converted}
  var
    BmpInfo : TBitmap;
  begin
    if (Bitmap = 0) and (Cvt^.InBitmap = nil) then
      Result := ecBadArgument
    else with PBitmapFaxData(Cvt^.UserData)^ do begin
      if Bitmap = 0 then begin
        DataBitmap := Graphics.TBitmap.Create;
        DataBitmap.Assign(Graphics.TBitmap(Cvt^.InBitmap));
        BmpHandle := DataBitmap.Handle;
      end else begin
        GetObject(Bitmap, SizeOf(TBitmap), @BmpInfo);
        if (BmpInfo.bmBitsPixel <> 1) then begin
          Result := ecBadArgument;
          Exit;
        end else begin
          BmpHandle := Bitmap;
        end;
      end;
      Result := ecOK;
    end;
  end;

  procedure InitDitherMatrix(Cvt : PAbsFaxCvt);

    function DV(X, Y, Size : Integer) : Integer;
    begin
      Result := 0;
      while Size > 0 do begin
        Result := Result shl 1 or ((X and 1) xor (Y and 1)) shl 1 or (Y and 1);
        X := X shr 1;
        Y := Y shr 1;
        Dec(Size);
      end;
    end;

  var
    I, J : Integer;
  begin
    with Cvt^, PBitmapFaxData(Cvt^.UserData)^ do begin
      for I := 0 to Pred(DMSize) do
        for J := 0 to Pred(DMSize) do
          DM[I,J] := 10*DV(I,J,4);
    end;
  end;

  function bcGetDitheredRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
    var EndOfPage, MorePages : Bool) : Integer; {$IFDEF Windows} far; {$ENDIF}
    {-Read a raster line from a non-monochrome bitmap and dither it}
  type
    TColorRec = packed record
      R : Byte;
      G : Byte;
      B : Byte;
      D : Byte;
    end;
  const
    BitArray : array[0..7] of Byte = ($01, $80, $40, $20, $10, $08, $04, $02);
  var
    I, YOffset : Integer;
    B : ^Byte;
    BitOffset : Byte;
    Clr : TColorRec;
    Pix : TColor;
  begin
    Result := ecOK;
    with Cvt^, PBitmapFaxData(Cvt^.UserData)^ do begin
      MorePages := False;
      EndOfPage := (OnLine >= NumLines);
      YOffset := Pred(OnLine) mod DMSize;
      B := @TByteArray(Data)[CenterOfs];
      for I := 0 to Pred(Width) do begin
        Pix := DataBitmap.Canvas.Pixels[I , Pred(OnLine)];
        Clr := TColorRec(Pix);
        BitOffset := (Succ(I) mod 8);
        if ((Clr.B) + (Clr.G) + (Clr.R)) < DM[(I mod DMSize), (YOffset)] then
          { set the appropriate bit }
          B^ := B^ or BitArray[BitOffset];
        if (BitOffset = 0) then begin
          Application.ProcessMessages;
          Inc(B);
        end;
      end;

      Len := ResWidth shr 3;     { divide by 8 }

      Inc(Offset, BytesPerLine);
      Inc(OnLine);
      Inc(BytesRead, BytesPerLine);
    end;
  end;

  function bcOpenBitmap(Cvt : PAbsFaxCvt; FileName : PChar) : Integer;
    {-Open bitmap "file"}
  var
    BmpInfo : TBitmap;
    Sz      : LongInt;
    COffset : integer;                                                 

  begin
    with Cvt^, PBitmapFaxData(Cvt^.UserData)^ do begin
      if (BmpHandle = 0) then begin
        bcOpenBitmap := ecBadArgument;
        Exit;
      end;

      {initialize fields of bitmap data structure}
      GetObject(BmpHandle, SizeOf(TBitmap), @BmpInfo);
      BytesPerLine := BmpInfo.bmWidthBytes;
      Width        := BmpInfo.bmWidth;
      Sz           := LongInt(BytesPerLine) * BmpInfo.bmHeight;
      BytesToRead  := Sz;
      NumLines     := BmpInfo.bmHeight;
      OnLine       := 1;
      Offset       := 0;

      if (BmpInfo.bmBitsPixel <> 1) then begin
        NeedsDithering := True;
        GetLine := bcGetDitheredRasterLine;
        InitDitherMatrix(Cvt);
      end;

      if FlagIsSet(Flags, fcDoubleWidth) then
        DoubleWidth := not UseHighRes and
          ((BmpInfo.bmWidth * 2) <= LongInt(ResWidth - (LeftMargin*2)));
                                          {section rewritten }         
      HalfHeight := not UseHighRes and not DoubleWidth and
        FlagIsSet(Flags, fcHalfHeight);

      {center image in fax image}
      CenterOfs := 0;

      if FlagIsSet(Flags, fcCenterImage) then begin
        {only center if at least one byte on each side}
        if DoubleWidth then
          COffset := (LongInt(ResWidth) -
                      (longint(BmpInfo.bmWidth) + longint(LeftMargin))*2) div 32
        else
          COffset := (LongInt(ResWidth) -
                      longint(BmpInfo.bmWidth) -
                      longint(LeftMargin)) div 16;
        if (COffset < 0) then
          CenterOfs := 0
        else
          CenterOfs := COffset;
      end;
                                          { end rewrite }              

      if not NeedsDithering then begin
        {allocate memory to hold the bitmap}
        BitmapBufHandle := GlobalAlloc(gmem_Moveable or gmem_ZeroInit, Sz);
        if (BitmapBufHandle = 0) then begin
          bcOpenBitmap := ecOutOfMemory;
          Exit;
        end;
        BitmapBuf := GlobalLock(BitmapBufHandle);

        {put bitmap data into buffer}
        GetBitmapBits(BmpHandle, Sz, BitmapBuf);
      end;                                                           

      bcOpenBitmap := ecOK;
    end;
  end;

  procedure bcCloseBitmap(Cvt : PAbsFaxCvt);
    {-Close bitmap "file"}
  begin
    with Cvt^, PBitmapFaxData(Cvt^.UserData)^ do begin
      GlobalUnlock(BitmapBufHandle);
      GlobalFree(BitmapBufHandle);
      DataBitmap.Free;

      FastZero(UserData^, SizeOf(TBitmapFaxData));
    end;
  end;

  function bcGetBitmapRasterLine(Cvt : PAbsFaxCvt; var Data; var Len : Integer;
                                 var EndOfPage, MorePages : Bool) : Integer;
    {-Read a raster line from a bitmap}
  var
    ActiveBits : Integer;
    Mask       : Byte;
    I          : Integer;
    ActBytesPerLine : integer;
  begin
    bcGetBitmapRasterLine := ecOK;

    with Cvt^, PBitmapFaxData(Cvt^.UserData)^ do begin
      { Just in case someone uses this function externally }
      if NeedsDithering then begin
        Result := bcGetDitheredRasterLine(Cvt, Data, Len, EndOfPage, MorePages);
        Exit;
      end;                                                                        
      MorePages := False;
      EndOfPage := (OnLine >= NumLines);

      {$IFNDEF Win32}
      if (CenterOfs = 0) then
        hmemcpy(@Data, GetPtr(BitmapBuf, Offset), BytesPerLine)
      else
        hmemcpy(@TByteArray(Data)[CenterOfs], GetPtr(BitmapBuf, Offset), BytesPerLine);
      {$ELSE}
      if (CenterOfs = 0) then
        Move(GetPtr(BitmapBuf, Offset)^, Data, BytesPerLine)
      else
        Move(GetPtr(BitmapBuf, Offset)^, TByteArray(Data)[CenterOfs], BytesPerLine);
      {$ENDIF}
      Len := ResWidth div 8;

                                          { section rewritten }        
      {the number of bytes stored in BytesPerLine is *always* even, so
       we need to (1) set any unused bits in the last partial byte to
       'white' or 1, and (2) set the last full byte (if it exists!) to
       white as well.}
      ActBytesPerLine := (Width + 7) div 8;
      if (ActBytesPerLine <> longint(BytesPerLine)) then
        TByteArray(Data)[longint(CenterOfs) + ActBytesPerLine] := $FF;
      ActiveBits := Width mod 8;
      if (ActiveBits <> 0) then begin
        Mask := 0;
        for i := ActiveBits to 7 do
          Mask := (Mask shl 1) or 1;
        TByteArray(Data)[longint(CenterOfs) + (ActBytesPerLine-1)] :=
          TByteArray(Data)[longint(CenterOfs) + (ActBytesPerLine-1)] or Mask;
      end;
                                          { end new }                  

      NotBuffer(TByteArray(Data)[CenterOfs], BytesPerLine);

      Inc(Offset, BytesPerLine);
      Inc(OnLine);
      Inc(BytesRead, BytesPerLine);
    end;
  end;

{utilitarian routines}

  {$IFNDEF Win32}
  function ActualLen(var Data; Len : Cardinal) : Cardinal; assembler;
    {-return actual length, in bytes, of a raster line}
  asm
    les   di,Data
    add   di,Len
    dec   di
    xor   ax,ax
    mov   cx,Len
    std
    repe  scasb
    je    @1
    mov   ax,cx
    inc   ax
  @1:
    cld
  end;

  function ActualLenInverted(var Data; Len : Cardinal) : Cardinal; assembler;
    {-return actual length, in bytes, of a raster line}
  asm
    les   di,Data
    add   di,Len
    dec   di
    mov   ax,$FFFF
    mov   cx,Len
    std
    repe  scasb
    je    @1
    mov   ax,cx
    inc   ax
    jmp   @2
@1: xor   ax,ax
@2: cld
  end;

  procedure HalfWidthBuf(var Data; var Len : Cardinal); assembler;
  asm
    push  ds
    lds   si,Data             {DS:SI->Data}
    mov   bx,si               {BX = offset of output}
    les   di,Len              {ES:DI->Len}
    mov   cx,es:[di]          {CX is loop counter}
    shr   cx,1                {Count by words}
    mov   es:[di],cx
    or    cx,cx
    jz    @2

@1: mov   ax,[si]             {get the next two data bytes}
    mov   dx,ax
    mov   ah,al
    mov   al,dh
    xor   dx,dx               {clear output data}

    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1

    or    dh,dl
    mov   [bx],dh
    inc   bx
    inc   si
    inc   si
    dec   cx
    jnz   @1

@2: pop   ds
  end;

  {$ELSE}
  function ActualLen(var Data; Len : Cardinal) : Cardinal; assembler; register;
    {-return actual length, in bytes, of a raster line}
  asm
    push  edi

    mov   edi,eax       {eax = Data}
    add   edi,edx       {edx = Len}
    dec   edi
    xor   eax,eax
    mov   ecx,edx
    std
    repe  scasb
    je    @1
    mov   eax,ecx
    inc   eax
  @1:
    cld

    pop   edi
  end;

  function ActualLenInverted(var Data; Len : Cardinal) : Cardinal; assembler; register;
    {-return actual length, in bytes, of a raster line}
  asm
    push  edi

    mov   edi,eax       {eax = Data}
    add   edi,edx       {edx = Len}
    dec   edi
    mov   eax,$FFFFFFFF
    mov   ecx,edx
    std
    repe  scasb
    je    @1
    mov   eax,ecx
    inc   eax
    jmp   @2
@1: xor   eax,eax
@2: cld

    pop   edi
  end;

  procedure HalfWidthBuf(var Data; var Len : Cardinal); assembler; register;
  asm
    push  esi
    push  ebx

    mov   ecx,[edx]       {ECX is loop counter; EDX->Len}
    shr   ecx,1           {count by words}
    mov   [edx],ecx       {store new length}

    mov   esi,eax         {ESI->Data}
    mov   ebx,esi         {EBX = offset of output}

@1: mov   ax,[esi]
    mov   edx,eax
    mov   ah,al
    mov   al,dh
    xor   edx,edx         {clear output data}

    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1
    shr   ax,1
    rcr   dh,1
    shr   ax,1
    rcr   dl,1

    or    dh,dl
    mov   [ebx],dh
    inc   ebx
    inc   esi
    inc   esi
    dec   ecx
    jnz   @1

@2: pop   ebx
    pop   esi
  end;
  {$ENDIF}

{Fax unpacking}

  function upInitFaxUnpacker(var Unpack : PUnpackFax; Data : Pointer; CB : TUnpackLineCallback) : Integer;
    {-Initialize a fax unpacker}
  var
    Code : Integer;

  label
    Error;

    function BuildTrees : Integer;
      {-Build black and white decompression trees}
    var
      Code : Integer;

      function InitTree(var T : PTreeArray) : Integer;
        {-Initialize an empty tree}
      begin
        with Unpack^ do begin
          T := AllocMem(SizeOf(TTreeArray));
          TreeLast   := 0;
          TreeNext   := 0;
          CurCode    := 0;
          CurSig     := 0;
          InitTree := ecOK;
        end;
      end;

      procedure BuildTree(T : PTreeArray; var TC : TTermCodeArray; var MUC : TMakeUpCodeArray);
        {-Recursively build a tree containing all fax codes}
      var
        SaveLast : Integer;

        procedure AddCode(Code : Word);
          {-Add a new code element to a tree}
        begin
          with Unpack^ do begin
            Inc(TreeNext);
            if (TreeNext > MaxTreeRec) then
              {out of tree space}
              Exit;

            with T^[TreeLast] do
              if (Code = 1) then
                Next1 := TreeNext
              else
                Next0 := TreeNext;
          end;
        end;

        function CodeMatch : Integer;
          {-Return run length of matching code, or -1 for no match}
        var
          I     : Integer;
          TCode : Word;

        begin
          with Unpack^ do begin
            TCode := CurCode;
            RotateCode(TCode, CurSig);
            for I := 0 to MaxCodeTable do
              with TC[I] do
                if (TCode = Code) and (CurSig = Sig) then begin
                  CodeMatch := I;
                  Exit;
                end;

            for I := 0 to MaxMUCodeTable do
              with MUC[I] do
                if (TCode = Code) and (CurSig = Sig) then begin
                  CodeMatch := 64 * (I + 1);
                  Exit;
                end;

            if (TCode = EOLRec.Code) and (CurSig = EOLRec.Sig) then
              CodeMatch := -2
            else
              CodeMatch := -1;
          end;
        end;

        procedure SetCode(N0, N1 : Integer);
          {-Store terminating code}
        begin
          with Unpack^, T^[TreeNext] do begin
            Next0 := N0;
            Next1 := N1;
          end;
        end;

      begin
        with Unpack^ do begin
          if (CurSig < 13) then begin
            {add a 0 to the tree}
            AddCode(0);
            Inc(CurSig);
            CurCode := CurCode shl 1;
            Match := CodeMatch;
            case Match of
              -2: {end of line}
                SetCode(-2, 0);
              -1: { no match}
                begin
                  {use recursion to add next bit}
                  SaveLast := TreeLast;
                  TreeLast := TreeNext;
                  BuildTree(T, TC, MUC);
                  TreeLast := SaveLast;
                end;
              else
                SetCode(-1, Match);
            end;

            {add a 1 to the tree}
            AddCode(1);
            CurCode := CurCode or 1;
            Match := CodeMatch;
            case Match of
              -2: {end of line}
                SetCode(-2, 0);
              -1:
                begin
                  {use recursion to add next bit}
                  SaveLast := TreeLast;
                  TreeLast := TreeNext;
                  BuildTree(T, TC, MUC);
                  TreeLast := SaveLast;
                end;
              else
                SetCode(-1, Match);
            end;

            CurCode := CurCode shr 1;
            Dec(CurSig);
          end;
        end;
      end;

    begin
      with Unpack^ do begin
        Code := InitTree(WhiteTree);
        if (Code < ecOK) then begin
          BuildTrees := Code;
          Exit;
        end;

        BuildTree(WhiteTree, WhiteTable, WhiteMUTable);
        {force a loop into the table for EOL resync}
        WhiteTree^[11].Next0 := 11;

        Code := InitTree(BlackTree);
        if (Code < ecOK) then begin
          FreeMem(WhiteTree, SizeOf(TTreeArray));
          BuildTrees := Code;
          Exit;
        end;

        BuildTree(BlackTree, BlackTable, BlackMUTable);
        {force a loop into the table for EOL resync}
        BlackTree^[11].Next0 := 11;

        BuildTrees := ecOk;
      end;
    end;

  begin
    Unpack := AllocMem(SizeOf(TUnpackFax));

    with Unpack^ do begin
      UserData   := Data;
      Flags      := DefUnpackOptions;
      LineBuffer := nil;
      TmpBuffer  := nil;
      FileBuffer := nil;
      WhiteTree  := nil;
      BlackTree  := nil;

      LineBuffer := AllocMem(LineBufSize+16);{~~}
      TmpBuffer := AllocMem(LineBufSize);
      FileBuffer := AllocMem(MaxData);

      with Scale do begin
        HMult := 1;
        HDiv  := 1;
        VMult := 1;
        VDiv  := 1;
      end;

      Code := BuildTrees;
      OutputLine := CB;
    end;

  Error:
    if (Code < ecOK) then begin
      FreeMem(Unpack^.FileBuffer, MaxData);
      FreeMem(Unpack^.LineBuffer, LineBufSize+16);{~~}
      FreeMem(Unpack^.TmpBuffer, LineBufSize);
      FreeMem(Unpack, SizeOf(TUnpackFax));
      Unpack := nil;
    end;

    upInitFaxUnpacker := Code;
  end;

  procedure upDoneFaxUnpacker(var Unpack : PUnpackFax);
    {-Destroy a fax unpacker}
  begin
    FreeMem(Unpack^.WhiteTree, SizeOf(TTreeArray));
    FreeMem(Unpack^.BlackTree, SizeOf(TTreeArray));
    FreeMem(Unpack^.FileBuffer, MaxData);
    FreeMem(Unpack^.LineBuffer, LineBufSize+16);{~~}
    FreeMem(Unpack^.TmpBuffer, LineBufSize);                         
    FreeMem(Unpack, SizeOf(TUnpackFax));
    Unpack := nil;
  end;

  procedure upOptionsOn(Unpack : PUnpackFax; OptionFlags : Word);
    {-Turn on one or more unpacker options}
  const
    BadCombo = ufAutoDoubleHeight or ufAutoHalfWidth;

  begin
    with Unpack^ do begin
      if ((OptionFlags and BadCombo) = BadCombo) then
        Exit;

      if (((Flags or OptionFlags) and BadCombo) = BadCombo) then
        upOptionsOff(Unpack, BadCombo);
      Flags := Flags or (OptionFlags and not BadUnpackOptions);
    end;
  end;

  procedure upOptionsOff(Unpack : PUnpackFax; OptionFlags : Word);
    {-Turn off one or more unpacker options}
  begin
    with Unpack^ do
      Flags := Flags and not (OptionFlags and not BadUnpackOptions);
  end;

  function upOptionsAreOn(Unpack : PUnpackFax; OptionFlags : Word) : Bool;
    {-Return True if all specified options are on}
  begin
    upOptionsAreOn := ((Unpack^.Flags and OptionFlags) = OptionFlags);
  end;

  procedure upSetStatusCallback(Unpack : PUnpackFax; Callback : TUnpackStatusCallback);
    {-Set up a routine to be called to report unpack status}
  begin
    Unpack^.Status := Callback;
  end;

  function upSetWhitespaceCompression(Unpack : PUnpackFax; FromLines, ToLines : Cardinal) : Integer;
    {-Set the whitespace compression option.}
  begin
    if (ToLines > FromLines) or ((FromLines = 0) and (ToLines <> 0)) then begin
      upSetWhitespaceCompression := ecBadArgument;
      Exit;
    end;
    upSetWhitespaceCompression := ecOK;

    with Unpack^ do begin
      WSFrom := FromLines;
      WSTo   := ToLines;
    end;
  end;

  procedure upSetScaling(Unpack : PUnpackFax; HMult, HDiv, VMult, VDiv : Cardinal);
    {-Set horizontal and vertical scaling factors}
  begin
    with Unpack^ do begin
      Scale.HMult := HMult;
      Scale.HDiv  := HDiv;
      Scale.VMult := VMult;
      Scale.VDiv  := VDiv;
    end;
  end;

  function ValidSignature(var TestSig) : Bool;
  var
    T : TSigArray absolute TestSig;

  begin
    ValidSignature := (T = DefAPFSig);
  end;

  function upGetFaxHeader(Unpack : PUnpackFax; FName : PChar; var FH : TFaxHeaderRec) : Integer;
    {-Return header for fax FName}
  var
    Code     : Integer;
    SaveMode : Integer;
    F        : File;

  label
    ExitPoint;

  begin
    {protect against empty filename}
    if (FName = nil) or (FName^ = #0) then begin
      upGetFaxHeader := ecFileNotFound;
      Exit;
    end;

    with Unpack^ do begin
      {open the fax file}
      SaveMode := FileMode;
      FileMode := ApdShareFileRead;                                    
      Assign(F, FName);
      Reset(F, 1);
      FileMode := SaveMode;
      Code := -IoResult;
      if (Code < ecOK) then begin
        upGetFaxHeader := Code;
        Exit;
      end;

      {read the fax header}
      BlockRead(F, FH, SizeOf(TFaxHeaderRec));
      Code := -IoResult;
      if (Code < ecOK) then
        goto ExitPoint;

      if not ValidSignature(FH) then begin
        Code := ecFaxBadFormat;
        goto ExitPoint;
      end;

      Code := ecOK;

    ExitPoint:
      Close(F);
      if (IoResult = 0) then ;

      upGetFaxHeader := Code;
    end;
  end;

  function upGetPageHeader(Unpack : PUnpackFax; FName : PChar; Page : Cardinal; var PH : TPageHeaderRec) : Integer;
    {-Return header for Page in fax FName}
  var
    Offset   : LongInt;
    I        : Cardinal;
    SaveMode : Integer;
    Code     : Integer;
    FH       : TFaxHeaderRec;
    F        : File;

  label
    ExitPoint;

  begin
    {protect against empty filename}
    if (FName = nil) or (FName^ = #0) then begin
      upGetPageHeader := ecFileNotFound;
      Exit;
    end;

    with Unpack^ do begin
      SaveMode := FileMode;
      FileMode := ApdShareFileRead;                                    
      Assign(F, FName);
      Reset(F, 1);
      FileMode := SaveMode;
      Code     := -IoResult;
      if (Code < ecOK) then begin
        upGetPageHeader := Code;
        Exit;
      end;

      {read header}
      BlockRead(F, FH, SizeOf(TFaxHeaderRec));
      Code := -IoResult;
      if (Code < ecOK) then
        goto ExitPoint;

      if not ValidSignature(FH) then begin
        Code := ecFaxBadFormat;
        goto ExitPoint;
      end;

      if (Page > FH.PageCount) then begin
        Code := ecFaxBadFormat;
        goto ExitPoint;
      end;

      {read the header of each page until we get to the one we want}
      Offset := FH.PageOfs;
      for I:= 1 to Page do begin
        Seek(F, Offset);
        Code := -IoResult;
        if (Code < ecOK) then
          goto ExitPoint;
        BlockRead(F, PH, SizeOf(TPageHeaderRec));
        Code :=-IoResult;
        if (Code < ecOK) then
          goto ExitPoint;

        Inc(Offset, SizeOf(TPageHeaderRec) + PH.ImgLength);
      end;

      Code := ecOK;

    ExitPoint:
      Close(F);
      if (IoResult = 0) then ;
      upGetPageHeader := Code;
    end;
  end;

  procedure upOutputRun(Unpack : PUnpackFax; IsWhite : Bool; Len : Integer);
    {-Output current run}

    {$IFDEF Win32}
    procedure UpdateLinePosition(UP : PUnpackFax; Len : Integer); assembler; register;
    asm
      push  edi

      mov   edi,eax       {eax = UP}
                          {edx = Len}
      add   edx,[edi].TUnpackFax.LineBit
      mov   eax,edx
      shr   eax,3
      add   [edi].TUnpackFax.LineOfs,eax
      and   edx,7
      mov   [edi].TUnpackFax.LineBit,edx

      pop   edi
    end;

    procedure OutputBlackRun(UP : PUnpackFax; Len : Integer); assembler; register;
    asm
      push  edi
      push  ebx

      mov   edi,eax       {eax = UP}
      push  edi
      mov   ecx,edx       {edx = Len}

      mov   ebx,[edi].TUnpackFax.LineBit
      mov   eax,[edi].TUnpackFax.LineOfs
      mov   edi,[edi].TUnpackFax.LineBuffer
      add   edi,eax
      or    ebx,ebx
      jz    @3
      mov   edx,ecx
      mov   al,$80
      mov   cl,bl
      shr   al,cl
      mov   ecx,edx

  @1: or    byte ptr [edi],al
      inc   ebx
      shr   al,1
      dec   ecx
      cmp   ebx,8
      jae   @2
      or    ecx,ecx
      jz    @2
      jmp   @1

  @2: mov   eax,ebx
      shr   eax,3
      add   edi,eax
      and   ebx,7

  @3: cmp   ecx,8
      jb    @4
      mov   edx,ecx
      shr   ecx,3
      cld
      mov   al,$FF
      rep   stosb
      and   edx,7
      mov   ecx,edx

  @4: or    ecx,ecx
      jz    @6
      mov   edx,ecx
      mov   al,$80
      mov   cl,bl
      shr   al,cl
      mov   ecx,edx

  @5: or    byte ptr [edi],al
      inc   ebx
      shr   al,1
      dec   ecx
      jnz   @5

  @6: mov   eax,edi
      pop   edi
      sub   eax,[edi].TUnpackFax.LineBuffer
      mov   [edi].TUnpackFax.LineOfs,eax
      mov   [edi].TUnpackFax.LineBit,ebx

      pop   ebx
      pop   edi
    end;
    {$ENDIF}

  begin
    with Unpack^ do begin
      if Len > 0 then
        if IsWhite then begin
          {update line position; line already filled with zeros}
          {$IFNDEF Win32}
          asm
            les di,Unpack
            mov bx,es:[di].LineBit
            add bx,Len
            mov ax,bx
            shr ax,3
            add es:[di].LineOfs,ax
            and bx,7
            mov es:[di].LineBit,bx
          end;
          {$ELSE}
          UpdateLinePosition(Unpack, Len);
          {$ENDIF}
        end else begin
          {$IFNDEF Win32}
          asm
            mov cx,Len
            les di,Unpack
            mov bx,es:[di].LineBit
            mov ax,es:[di].LineOfs
            les di,es:[di].LineBuffer
            add di,ax
            cmp bx,0
            jz  @3
            mov dx,cx
            mov al,$80
            mov cl,bl
            shr al,cl
            mov cx,dx
    @1:     or es:[di],al
            inc bx
            shr al,1
            dec cx
            cmp bx,8
            jae @2
            jcxz @2
            jmp @1
    @2:     mov ax,bx
            shr ax,3
            add di,ax
            and bx,7
    @3:     cmp cx,8
            jb @4
            mov dx,cx
            shr cx,3
            cld
            mov al,$FF
            rep stosb
            and dx,7
            mov cx,dx
    @4:     jcxz @6
            mov dx,cx
            mov al,$80
            mov cl,bl
            shr al,cl
            mov cx,dx
    @5:     or es:[di],al
            inc bx
            shr al,1
            loop @5
    @6:     mov ax,di
            les di,Unpack
            sub ax,word ptr es:[di].LineBuffer
            mov es:[di].LineOfs,ax
            mov es:[di].LineBit,bx
          end;
          {$ELSE}
          OutputBlackRun(Unpack, Len);
          {$ENDIF}
        end;
    end;
  end;

  function upValidLineLength(Unpack : PUnpackFax; Len : Cardinal) : Bool;
    {-Return True if Len is a valid line length}
  begin
    with Unpack^ do
      upValidLineLength := (Len = (StandardWidth div 8)) or
                           (Len = (WideWidth     div 8))
  end;

  {$IFNDEF Win32}
  function LineHasData(var Buf; Len : Cardinal) : Boolean; assembler;
    {-Return TRUE if raster row contains any non-zero bytes}
  asm
    cld
    les   di,Buf
    xor   ax,ax
    mov   cx,Len
    rep   scasb
    je    @2
@1: inc   ax
@2:
  end;
  {$ELSE}
  function LineHasData(var Buf; Len : Cardinal) : Boolean; assembler; register;
    {-Return TRUE if raster row contains any non-zero bytes}
  asm
    push  edi

    cld
    mov   edi,eax   {eax = Buf}
    xor   eax,eax
    mov   ecx,edx   {edx = Len}
    rep   scasb
    je    @2
@1: inc   eax
@2:
    pop   edi
  end;
  {$ENDIF}

  function upOutputLine(Unpack : PUnpackFax; TheFlags : Cardinal) : Integer;
    {-Output an unpacked raster line}
  var
    Code   : Integer;
    TheLen : Cardinal;

  begin
    with Unpack^ do begin
      Code := ecOK;

      TheLen := LineOfs;
      if ((TheFlags and upStarting) = 0) and ((TheFlags and upEnding) = 0) then begin
        if Inverted then
          NotBuffer(LineBuffer^, LineOfs);

        {automatically output a second copy of the line, if desired}
        if ((PageHeader.ImgFlags and ffHighRes) = 0) then
          if ((Flags and ufAutoDoubleHeight) <> 0) and (@OutputLine <> nil) then begin
            Code := OutputLine(Unpack, TheFlags, LineBuffer^, TheLen, CurrPage);
            if (Code < ecOK) then begin
              upOutputLine := Code;
              Exit;
            end;
          end else if ((Flags and ufAutoHalfWidth) <> 0) and (LineOfs <> 0) then          
            HalfWidthBuf(LineBuffer^, TheLen);
      end;

      if (@OutputLine <> nil) then
        Code := OutputLine(Unpack, TheFlags, LineBuffer^, TheLen, CurrPage);

      upOutputLine := Code;
    end;
  end;

  function upUnpackPagePrim(Unpack : PUnpackFax; FName : PChar; Page : Cardinal) : Integer;
    {-Unpack page number Page, calling the put line callback for each raster line}
  var
    Code        : Integer;
    LengthWords : Bool;
    IsWhite     : Bool;
    CheckZero   : Bool;
    WaitEOL     : Bool;
    CurTree     : PTreeArray;
    TreeIndex   : Integer;
    LineCnt     : Cardinal;
    CurOfs      : Cardinal;
    ActRead     : Cardinal;
    TotRead     : LongInt;
    RunLen      : Cardinal;
    CurByte     : Byte;
    CurMask     : Byte;
    F           : File;

    procedure ReportStatus;
    begin
      with Unpack^ do
        if (@Status <> nil) then
          if (ImgRead > ImgBytes) then
            Status(Unpack, FName, Page, ImgBytes, ImgBytes)
          else
            Status(Unpack, FName, Page, ImgRead, ImgBytes);
    end;

  label
    ExitPoint,
    Again;

    function ReadNextLine : Integer;
      {-Read the next wordlength raster line}
    var
      Len  : Word;
      Code : Integer;

    begin
      {read length word}
      BlockRead(F, Len, SizeOf(Word));
      Code := -IoResult;
      if (Code < ecOK) then begin
        ReadNextLine := Code;
        Exit;
      end;

      {trim the line if too long}
      if (Len > MaxData) then
        Len := MaxData;

      {read the data}
      BlockRead(F, Unpack^.FileBuffer^, Len);
      ActRead := Len;
      ReadNextLine := -IoResult;
    end;

    function OpenFaxFile : Integer;
      {-Read and validate the fax file's header}
    var
      Code     : Integer;
      SaveMode : Integer;

    begin
      {protect against empty filename}
      if (FName = nil) or (FName^ = #0) then begin
        OpenFaxFile := ecFileNotFound;
        Exit;
      end;

      {open the fax file}
      SaveMode := FileMode;
      FileMode := ApdShareFileRead;                                    
      Assign(F, FName);
      Reset(F, 1);
      FileMode := SaveMode;
      Code := -IoResult;
      if (Code < ecOK) then begin
        OpenFaxFile := Code;
        Exit;
      end;

      {seek past the fax header}
      BlockRead(F, Unpack^.FaxHeader, SizeOf(TFaxHeaderRec));
      Code := -IoResult;
      if (Code < ecOK) then begin
        OpenFaxFile := Code;
        Close(F); if (IoResult = 0) then ;
        Exit;
      end;

      {validate the fax header}
      if not ValidSignature(Unpack^.FaxHeader) then begin
        OpenFaxFile := ecFaxBadFormat;
        Close(F); if (IoResult = 0) then ;
        Exit;
      end;

      {make sure the page is in range}
      if (Page > Unpack^.FaxHeader.PageCount) then begin
        OpenFaxFile := ecFaxBadFormat;
        Close(F); if (IoResult = 0) then ;
        Exit;
      end;

      OpenFaxFile := ecOK;
    end;

    function FindPage : Integer;
      {-Find the page to unpack}
    var
      Code : Integer;
      Posn : LongInt;
      X    : Cardinal;

    begin
      with Unpack^ do begin
        {find the header of the first page}
        Seek(F, FaxHeader.PageOfs);
        BlockRead(F, PageHeader, SizeOf(TPageHeaderRec));
        Code := -IoResult;
        if (Code < ecOK) then begin
          FindPage := Code;
          Exit;
        end;

        LengthWords := FlagIsSet(PageHeader.ImgFlags, ffLengthWords);

        Posn := FilePos(F);
        if (Page > 1) then
          {read the header of each page and seek to the next up to Page}
          for X := 1 to Pred(Page) do begin
            {get the position of the next page header}
            Inc(Posn, PageHeader.ImgLength);

            {seek to to the next page header and read it}
            Seek(F, Posn);
            BlockRead(F, PageHeader, SizeOf(TPageHeaderRec));
            Code := -IoResult;
            if (Code < ecOK) then begin
              FindPage := Code;
              Exit;
            end;

            LengthWords := FlagIsSet(PageHeader.ImgFlags, ffLengthWords);

            Posn := FilePos(F);
          end;
      end;

      FindPage := ecOK;
    end;

    function OutputBlanks(Num : Cardinal) : Integer;
    var
      I    : Cardinal;
      Code : Integer;

    begin
      Unpack^.LineOfs := 0;
      for I := 1 to Num do begin
        Inc(Unpack^.CurrLine);
        Code := upOutputLine(Unpack, 0);
        if (Code < ecOK) then begin
          OutputBlanks := Code;
          Exit;
        end;
      end;

      OutputBlanks := ecOK;
    end;

    procedure InitForNextLine;
    begin
      with Unpack^ do begin
        FastZero(LineBuffer^, LineOfs);
        LineOfs := 0;
        LineBit := 0;
        IsWhite := True;
        CurTree := WhiteTree;
      end;
    end;

    function OutputRasterLine : Integer;
      {-Output a line and perform whitespace compression}
    var
      SaveOfs : Cardinal;

    begin
      OutputRasterLine := ecOK;

      with Unpack^ do begin
        {check whitespace count if whitespace compression active}
        if (WSFrom <> 0) and (WSTo <> 0) then begin
          if LineHasData(LineBuffer^, LineOfs) then begin
            {if there were more than WSFrom white lines, output WSTo}
            {white lines}
            SaveOfs := LineOfs;

            if (WSFrom > 0) and (WhiteCount >= WSFrom) then
              Code := OutputBlanks(WSTo)

            {otherwise, output WhiteCount blanks}
            else if (WhiteCount > 0) then
              Code := OutputBlanks(WhiteCount)
            else
              Code := ecOK;

            if (Code < ecOK) then begin
              OutputRasterLine := Code;
              Exit;
            end;

            WhiteCount := 0;

            {output the data normally}
            LineOfs          := SaveOfs;
            OutputRasterLine := upOutputLine(Unpack, 0);

            InitForNextLine;
          end else begin
            Inc(WhiteCount);
            InitForNextLine;
          end;
        end else begin
          OutputRasterLine := upOutputLine(Unpack, 0);
          InitForNextLine;
        end;

        Inc(CurrLine);
      end;
    end;

    function OutputRemainingBlanks : Integer;
    begin
      with Unpack^ do begin
        {output any remaining whitespace}
        if (WhiteCount > 0) and (WSFrom <> WSTo) then
          if (WhiteCount >= WSFrom) then
            Code := OutputBlanks(WSTo)
          else
            Code := OutputBlanks(WhiteCount)
        else
          Code := ecOK;

        OutputRemainingBlanks := Code;
      end;
    end;

  begin
    with Unpack^ do begin
      WhiteCount := 0;
      CurrLine   := 0;

      Code := OpenFaxFile;
      if (Code < ecOK) then begin
        upUnpackPagePrim := Code;
        Exit;
      end;

      Code := FindPage;
      if (Code < ecOK) then
        goto ExitPoint;

      {initialize decompression vars}
      FastZero(LineBuffer^, LineBufSize);
      IsWhite   := True;
      CurTree   := WhiteTree;
      TreeIndex := 0;
      LineOfs   := 0;
      LineBit   := 0;
      LineCnt   := 0;
      CurOfs    := 0;
      ActRead   := 0;
      TotRead   := 0;

      CheckZero := False;
      WaitEOL   := True;
      Code      := ecOK;

      repeat
        if (LineCnt >= 3) then
          {More than 5 blank EOL's means end of fax}
          goto ExitPoint;

        if CurOfs >= ActRead then begin
          if LengthWords then begin
            Code := ReadNextLine;
            if (Code < ecOK) then
              goto ExitPoint;
          end else begin
  Again:
            {have we read the whole image?}
            if (TotRead >= PageHeader.ImgLength) and (TotRead > 0) then
              goto ExitPoint;

            {Get a FileBuffer from the file}
            BlockRead(F, FileBuffer^, MaxData, ActRead);
            Code := -IoResult;
            if (Code < ecOK) then
              goto ExitPoint;

            if (ActRead = 0) then begin
              {End of file without fax terminator}
              Code := ecFaxBadFormat;
              goto ExitPoint;
            end;
          end;

          Inc(TotRead, ActRead);
          Inc(ImgRead, ActRead);
          if LengthWords then begin
            Inc(TotRead, SizeOf(Word));
            Inc(ImgRead, SizeOf(Word));
          end;
          CurOfs := 0;
        end;
        CurByte := FileBuffer^[CurOfs];
        Inc(CurOfs);

        CurMask := $01;
        while CurMask <> 0 do begin
          if (CurByte and CurMask <> 0) then begin
            if not CheckZero then
              TreeIndex := CurTree^[TreeIndex].Next1;
          end else begin
            CheckZero := False;
            TreeIndex := CurTree^[TreeIndex].Next0;
          end;
          case CurTree^[TreeIndex].Next0 of
            -1 : {complete code}
              begin
                if not WaitEOL then begin
                  RunLen := CurTree^[TreeIndex].Next1;
                  if (LineOfs+(RunLen shr 3)) < LineBufSize then begin
                    upOutputRun(Unpack, IsWhite, RunLen);
                    if RunLen < 64 then begin
                      IsWhite := not IsWhite;
                      if IsWhite then
                        CurTree := WhiteTree
                      else
                        CurTree := BlackTree;
                    end;
                  end;
                end;
                TreeIndex := 0;
                LineCnt := 0;
              end;
            -2 : {end of line}
              begin
                {ignore blank line if first line or a terminator}
                if (LineOfs > 0) or (LineBit > 0) then begin
                  if upValidLineLength(Unpack, LineOfs) then begin
                    Code := OutputRasterLine;
                    if (Code < ecOK) then
                      goto ExitPoint;
                  end else
                    InitForNextLine;
                end else
                  InitForNextLine;   
                TreeIndex := 0;
                Inc(LineCnt);
                WaitEOL := False;
              end;
            +0 : {invalid code, ignore and start over}
              begin
                TreeIndex := 0;
                Inc(BadCodes);
                CheckZero := True;
              end;
          end;
          CurMask := (CurMask and $7F) shl 1;
        end;

        if upOptionsAreOn(Unpack, ufAbort) then
          goto ExitPoint;                                           

        if upOptionsAreOn(Unpack, ufYield) and ((CurrLine and 15) = 0) then begin
          Code := ConverterYield;
          if (Code < ecOK) then
            goto ExitPoint;
        end;

        ReportStatus;
      until False;


  ExitPoint:
      {output any remaining blank lines}
      if (Code = ecOK) then
        Code := OutputRemainingBlanks;

      ReportStatus;

      upUnpackPagePrim := Code;
      Close(F); if (IoResult = 0) then ;
    end;
  end;

  function upOutputBuffer(Unpack : PUnpackFax) : Integer;
    {-Output a memory bitmap buffer to user callback}
  var
    I    : LongInt;
    Code : Integer;

  begin
    with Unpack^ do begin
      {tell the output function we're starting}
      Code := upOutputLine(Unpack, upStarting);
      if (Code < ecOK) then begin
        upOutputBuffer := Code;
        GlobalFree(Handle);
        Exit;
      end;

      {output each line of the buffer to the output function}
      for I := 0 to Pred(Height) do begin
        {$IFNDEF Win32}
        hmemcpy(LineBuffer, GetPtr(Lines, Width * I), Width);
        {$ELSE}
        Move(GetPtr(Lines, LongInt(Width) * I)^, LineBuffer^, Width); 
        {$ENDIF}
        Code := upOutputLine(Unpack, 0);
        if (Code < ecOK) then begin
          upOutputBuffer := Code;
          GlobalFree(Handle);
          Exit;
        end;
      end;

      {tell the output function the output is done}
      upOutputBuffer := upOutputLine(Unpack, upEnding);
    end;
  end;

  function upInitPageUnpack(Unpack : PUnpackFax; FName : PChar; Page : Cardinal) : Integer;
  var
    Code : Integer;
    PH   : TPageHeaderRec;

  begin
    with Unpack^ do begin
      ImgBytes := 0;
      ImgRead  := 0;

      Code := upGetPageHeader(Unpack, FName, Page, PH);
      if (Code < ecOK) then begin
        upInitPageUnpack := Code;
        Exit;
      end;

      upInitPageUnpack := ecOK;

      ImgBytes := PH.ImgLength;
    end;
  end;

  function upInitFileUnpack(Unpack : PUnpackFax; FName : PChar) : Integer;
  var
    Code    : Integer;
    OnPage  : Cardinal;
    FH      : TFaxHeaderRec;
    PH      : TPageHeaderRec;
    FaxFile : File;

  label
    ErrorExit;

  begin
    {protect against empty filename}
    if (FName = nil) or (FName^ = #0) then begin
      upInitFileUnpack := ecFileNotFound;
      Exit;
    end;

    with Unpack^ do begin
      ImgBytes := 0;
      ImgRead  := 0;

      Assign(FaxFile, FName);
      Reset(FaxFile, 1);
      Code := -IoResult;
      if (Code < ecOK) then begin
        upInitFileUnpack := Code;
        Exit;
      end;

      BlockRead(FaxFile, FH, SizeOf(TFaxHeaderRec));
      Seek(FaxFile, FH.PageOfs);
      Code := -IoResult;
      if (Code < ecOK) then
        goto ErrorExit;

      for OnPage := 1 to FH.PageCount do begin
        BlockRead(FaxFile, PH, SizeOf(TPageHeaderRec));
        Code := -IoResult;
        if (Code < ecOK) then
          goto ErrorExit;

        Inc(ImgBytes, PH.ImgLength);
        Seek(FaxFile, FilePos(FaxFile) + PH.ImgLength);
      end;

      Close(FaxFile);
      upInitFileUnpack := -IoResult;
      Exit;

    ErrorExit:
      Close(FaxFile); if (IoResult = 0) then ;
      upInitFileUnpack := Code;
    end;
  end;

  function upUnpackPage(Unpack : PUnpackFax; FName : PChar; Page : Cardinal) : Integer;
    {-Unpack page number Page, calling the put line callback for each raster line}
  var
    Code : Integer;

  begin
    with Unpack^ do begin
      CurrPage := Page;

      {do we need to scale the output?}
      if (Scale.HMult <> Scale.HDiv) or (Scale.VMult <> Scale.VDiv) then
        Code := upUnpackPageToBuffer(Unpack, FName, Page, False)
      else begin
        Code := upInitPageUnpack(Unpack, FName, Page);
        if (Code = ecOK) then
          Code := upOutputLine(Unpack, upStarting);
        if (Code < ecOK) then begin
          upUnpackPage := Code;
          Exit;
        end;

        Code := upUnpackPagePrim(Unpack, FName, Page);
        if (Code < ecOK) then begin
          upUnpackPage := Code;
          Exit;
        end;

        Code := upOutputLine(Unpack, upEnding);
      end;

      {are we all done?}
      if (Code = ecOK) and ((Scale.HMult <> Scale.HDiv) or (Scale.VMult <> Scale.VDiv)) then
        upUnpackPage := upOutputBuffer(Unpack)
      else
        upUnpackPage := ecOK;
    end;
  end;

  function upUnpackFile(Unpack : PUnpackFax; FName : PChar) : Integer;
    {-Unpack all pages in a fax file}
  var
    I     : Cardinal;
    Code  : Integer;

  begin
    with Unpack^ do begin
      {do we need to scale the output?}
      if (Scale.HMult <> Scale.HDiv) or (Scale.VMult <> Scale.VDiv) then
        Code := upUnpackFileToBuffer(Unpack, FName)
      else begin
        Code := upGetFaxHeader(Unpack, FName, FaxHeader);
        if (Code < ecOK) then begin
          upUnpackFile := Code;
          Exit;
        end;

        Code := upInitFileUnpack(Unpack, FName);
        if (Code = ecOK) then
          Code := upOutputLine(Unpack, upStarting);
        if (Code < ecOK) then begin
          upUnpackFile := Code;
          Exit;
        end;

        for I := 1 to FaxHeader.PageCount do begin
          CurrPage := I;
          Code := upUnpackPagePrim(Unpack, FName, I);
          if (Code < ecOK) then begin
            upUnpackFile := Code;
            Exit;
          end;
        end;

        Code := upOutputLine(Unpack, upEnding);
      end;

      {are we all done?}
      if (Code = ecOK) and ((Scale.HMult <> Scale.HDiv) or (Scale.VMult <> Scale.VDiv)) then
        upUnpackFile := upOutputBuffer(Unpack)
      else
        upUnpackFile := ecOK;
    end;
  end;

  function upUnpackPageToBitmap(Unpack : PUnpackFax; FName : PChar; Page : Cardinal;
                                var Bmp : TMemoryBitmapDesc; Invert : Bool) : Integer;
    {-Unpack a page of fax into a memory bitmap}
  var
    Code : Integer;

  begin
    with Unpack^ do begin
      CurrPage   := Page;
      SaveHook   := OutputLine;
      OutputLine := upPutMemoryBitmapLine;

      Code := upInitPageUnpack(Unpack, FName, Page);
      if (Code = ecOK) then
        Code := upOutputLine(Unpack, upStarting);
      if (Code < ecOK) then begin
        OutputLine           := SaveHook;
        upUnpackPageToBitmap := Code;
        Exit;
      end;

      Inverted := Invert;
      Code := upUnpackPagePrim(Unpack, FName, Page);
      if (Code < ecOK) then begin
        OutputLine           := SaveHook;
        upUnpackPageToBitmap := Code;
        Inverted             := False;
        Exit;
      end;
      Code       := upOutputLine(Unpack, upEnding);
      OutputLine := SaveHook;
      Inverted   := False;

      if (Code < ecOK) then
        DeleteObject(MemBmp.Bitmap)
      else
        Bmp := MemBmp;

      upUnpackPageToBitmap := Code;
    end;
  end;

  function upUnpackFileToBitmap(Unpack : PUnpackFax; FName : PChar; var Bmp : TMemoryBitmapDesc;
                                Invert : Bool) : Integer;
    {-Unpack a fax into a memory bitmap}
  var
    Code  : Integer;
    I     : Cardinal;

  begin
    with Unpack^ do begin
      SaveHook   := OutputLine;
      OutputLine := upPutMemoryBitmapLine;

      Code := upGetFaxHeader(Unpack, FName, FaxHeader);
      if (Code < ecOK) then begin
        OutputLine           := SaveHook;
        upUnpackFileToBitmap := Code;
        Exit;
      end;

      Code := upInitFileUnpack(Unpack, FName);
      if (Code = ecOK) then
        Code := upOutputLine(Unpack, upStarting);
      if (Code < ecOK) then begin
        OutputLine           := SaveHook;
        upUnpackFileToBitmap := Code;
        Exit;
      end;

      Inverted := Invert;
      for I := 1 to FaxHeader.PageCount do begin
        CurrPage := I;
        Code := upUnpackPagePrim(Unpack, FName, I);
        if (Code < ecOK) then begin
          upUnpackFileToBitmap := Code;
          Inverted := False;
          Exit;
        end;
      end;
      Code       := upOutputLine(Unpack, upEnding);
      OutputLine := SaveHook;
      Inverted   := False;

      if (Code < ecOK) then
        DeleteObject(MemBmp.Bitmap)
      else
        Bmp := MemBmp;

      upUnpackFileToBitmap := Code;
    end;
  end;

  function upPutMemoryBitmapLine(Unpack : PUnpackFax; plFlags : Word;
                                 var Data; Len, PageNum : Cardinal): Integer;
    {-Output a raster line to an in-memory bitmap}
  var
    NewHandle : Cardinal;
    P         : Pointer;
    Offset    : LongInt;

    function InitOutputBitmap : Integer;
    begin
      with Unpack^ do begin
        Width  := 1;
        Height := 0;

        {calculate the maximum width of each line}
        if ((PageHeader.ImgFlags and ffHighWidth) = ffHighWidth) then
          MaxWid := WideWidth div 8
        else
          MaxWid := WideWidth {StandardWidth} div 8;{~~}

        {allocate the memory handle for the first block of data}
        Handle := GlobalAlloc(gmem_Moveable or gmem_ZeroInit,
                              DWORD(MaxWid) * RasterBufferPageSize);  
        if (Handle = 0) then begin
          InitOutputBitmap := ecOutOfMemory;
          Exit;
        end;

        {get a pointer to the memory block}
        Lines := GlobalLock(Handle);
        Pages := 1;

        InitOutputBitmap := ecOK;
      end;
    end;

    function OutputLineToBitmap : Integer;
    begin
      with Unpack^ do begin
        {allocate more memory if we need it}
        if (Height <> 0) and ((Height mod RasterBufferPageSize) = 0) then begin
          GlobalUnlock(Handle);
          { some memory leak detectors will detect that this causes a 524,288 byte leak }
          { this isn't a leak, the memory was allocated earlier, then reallocated }
          { here, but the total allocated memory is freed in CreateDestBitmap } 
          NewHandle := GlobalRealloc( Handle,
            MaxWid * RasterBufferPageSize * DWORD(Succ(Pages)),      
            gmem_ZeroInit);
          if (NewHandle = 0) then begin
            OutputLineToBitmap := ecOutOfMemory;
            GlobalFree(Handle);
            Exit;
          end;

          Lines  := GlobalLock(NewHandle);
          Handle := NewHandle;
          Inc(Pages);
        end;

        OutputLineToBitmap := ecOK;

        Offset := LongInt(Height) * LongInt(MaxWid);               
        if (Len > 0) then begin
          {$IFNDEF Win32}
          hmemcpy(GetPtr(Lines, Offset), @Data, Len);

          {$ELSE}
          P := GetPtr(Lines, Offset);
          Move(Data, P^, Len);
          {$ENDIF}
        end else begin
          {fill whitespace buffer}
          if Inverted then
            FillChar(TmpBuffer^, MaxWid, $FF)
          else
            FillChar(TmpBuffer^, MaxWid, $00);

          {$IFNDEF Win32}
          hmemcpy(GetPtr(Lines, Offset), TmpBuffer, MaxWid);

          {$ELSE}
          P := GetPtr(Lines, Offset);
          Move(TmpBuffer^, P^, MaxWid);
          {$ENDIF}
        end;
        Inc(Height);

        if Inverted then
          Width := MaxCardinal(Width, ActualLenInverted(Data, Len))
        else
          Width := MaxCardinal(Width, ActualLen(Data, Len));
      end;
    end;

    function PackImage : Integer;
      {-Calculate the optimum number of bytes per line and arrange
        the raster lines on that boundary}
    var
      I         : LongInt;
      W         : Cardinal;
      Pad       : Bool;
      Src       : PByteArray;
      Dest      : PByteArray;
      NewHandle : THandle;

    begin
      PackImage := ecOK;

      with Unpack^ do begin
        W   := Width;
        Pad := Odd(Width);
        if Pad then
          Inc(W);

        if (Width <> 0) and (Height <> 0) then begin
          for I := 1 to Pred(Height) do begin
            Src  := GetPtr(Lines, DWORD(I) * MaxWid);
            Dest := GetPtr(Lines, DWORD(I) * W);       

            {$IFNDEF Win32}
            hmemcpy(Dest, Src, Width);
            if Pad then
              if Inverted then
                Byte(GetPtr(Lines, (I * W) + Width)^) := $FF
              else
                Byte(GetPtr(Lines, (I * W) + Width)^) := $00;
            {$ELSE}
            Move(Src^, Dest^, Width);
            if Pad then
              if Inverted then
                Dest^[Width] := $FF
              else
                Dest^[Width] := $00;
            {$ENDIF}
          end;
          Width := W;

          GlobalUnlock(Handle);
          NewHandle := GlobalRealloc(Handle, LongInt(Width) * LongInt(Height), gmem_ZeroInit);
          if (NewHandle = 0) then begin
            GlobalFree(Handle);
            PackImage := ecOutOfMemory;
            Exit;
          end;

          Handle := NewHandle;
          Lines  := GlobalLock(Handle);
        end else begin
          GlobalUnlock(Handle);
          Handle := 0;
          Lines  := nil;
        end;                                          
      end;
    end;

    function CreateDestBitmap : Integer;
      {-Create a bitmap from the buffer}
    begin
      {create bitmap data structure}
      with Unpack^ do begin
        MemBmp.Width  := Width * 8;
        MemBmp.Height := Height;

        {create the bitmap}
        if (Lines <> nil) then begin                  
          MemBmp.Bitmap := CreateBitmap(MemBmp.Width, MemBmp.Height, 1, 1, Lines);
          if (MemBmp.Bitmap = 0) then
            CreateDestBitmap := ecCantMakeBitmap
          else
            CreateDestBitmap := ecOK;

          GlobalUnlock(Handle);
          GlobalFree(Handle);
        end else begin
          MemBmp.Bitmap    := 0;
          MemBmp.Width     := 0;
          MemBmp.Height    := 0;
          CreateDestBitmap := ecOK;
        end;                                         
      end;
    end;

    function ScaleBitmap : Integer;
      {-Scale the bitmap based on user-specified dimensions}
    var
      ScaledWidth  : Cardinal;
      ScaledHeight : Cardinal;
      W            : Cardinal;
      Temp         : HBitmap;
      OldSrc       : HBitmap;
      OldDest      : HBitmap;
      TempDC       : HDC;
      SrcDC        : HDC;
      DestDC       : HDC;

    begin
      with Unpack^ do begin
        if (MemBmp.Width = 0) or (MemBmp.Height = 0) then begin
          ScaleBitmap := ecOK;
          Exit;
        end;                                                    

        ScaleBitmap := ecCantMakeBitmap;

        {calculate the scaled dimensions of the bitmap}
        W            := Width * 8;
        ScaledWidth  := (W      * Scale.HMult) div Scale.HDiv;
        ScaledHeight := (Height * Scale.VMult) div Scale.VDiv;

        {create destination bitmap}
        Temp := CreateBitmap(ScaledWidth, ScaledHeight, 1, 1, nil);
        if (Temp = 0) then
          Exit;

        {create a source DC and a dest DC for StretchBlting data into dest}
        TempDC := GetDC(0);
        if (TempDC = 0) then begin
          DeleteObject(Temp);
          Exit;
        end;
        SrcDC  := CreateCompatibleDC(TempDC);
        ReleaseDC(0, TempDC);
        if (SrcDC = 0) then begin
          DeleteObject(Temp);
          Exit;
        end;
        DestDC := CreateCompatibleDC(SrcDC);
        if (DestDC = 0) then begin
          DeleteDC(SrcDC);
          DeleteObject(Temp);
          Exit;
        end;

        {select bitmaps into DCs}
        OldSrc  := SelectObject(SrcDC, MemBmp.Bitmap);
        OldDest := SelectObject(DestDC, Temp);

        {scale image}
        StretchBlt(DestDC, 0, 0, ScaledWidth, ScaledHeight,
                   SrcDC , 0, 0, W, Height, SrcCopy);

        {restore DCs}
        SelectObject(SrcDC , OldSrc);
        SelectObject(DestDC, OldDest);

        {cleanup}
        DeleteDC(SrcDC);
        DeleteDC(DestDC);
        DeleteObject(MemBmp.Bitmap);

        {set destination information}
        Width         := ScaledWidth div 8;
        Height        := ScaledHeight;
        MemBmp.Bitmap := Temp;
        MemBmp.Width  := ScaledWidth;
        MemBmp.Height := ScaledHeight;
      end;

      ScaleBitmap := ecOK;
    end;

    function FinishBitmap : Integer;
    var
      Code      : Integer;
      CopyBytes : LongInt;

    begin
      with Unpack^ do begin
        {pack the bitmap}
        Code := PackImage;
        if (Code < ecOK) then begin
          FinishBitmap := Code;
          Exit;
        end;

        FinishBitmap := ecOK;

        if ToBuffer then begin
          {if we're scaling this data, create memory bitmap}
          if (Scale.HMult <> Scale.HDiv) or (Scale.VMult <> Scale.VDiv) then begin
            Code := CreateDestBitmap;
            if (Code < ecOK) then begin
              FinishBitmap := Code;
              Exit;
            end;

            {scale the bitmap}
            Code := ScaleBitmap;
            if (Code < ecOK) then begin
              DeleteObject(MemBmp.Bitmap);
              FinishBitmap := Code;
              Exit;
            end;

            {put the data back into a buffer}
            if Odd(Width) then
              Inc(Width);
            CopyBytes := DWORD(Height) * Width;                     
            Handle := GlobalAlloc(gmem_Moveable or gmem_ZeroInit, CopyBytes);
            if (Handle = 0) then begin
              FinishBitmap := ecOutOfMemory;
              Exit;
            end;
            Lines := GlobalLock(Handle);

            GetBitmapBits(MemBmp.Bitmap, CopyBytes, Lines);
            DeleteObject(MemBmp.Bitmap);
          end;
        end else begin
          Code := CreateDestBitmap;
          {if error, or no scaling, just exit}
          if (Code < ecOK) or (Scale.HMult = Scale.HDiv) and (Scale.VMult = Scale.VDiv) then begin
            FinishBitmap := Code;
            Exit;
          end;

          {scale the bitmap}
          Code := ScaleBitmap;
          if (Code < ecOK) then begin
            DeleteObject(MemBmp.Bitmap);
            FinishBitmap := Code;
            Exit;
          end;
        end;
      end;
    end;

  begin
    if FlagIsSet(plFlags, upStarting) then
      upPutMemoryBitmapLine := InitOutputBitmap
    else if not FlagIsSet(plFlags, upEnding) then
      upPutMemoryBitmapLine := OutputLineToBitmap
    else
      upPutMemoryBitmapLine := FinishBitmap
  end;

  function upUnpackPageToBuffer(Unpack : PUnpackFax; FName : PChar; Page : Cardinal; UnpackingFile : Boolean) : Integer;
    {-Unpack a page of fax into a memory bitmap}
  var
    Code : Integer;

  begin
    with Unpack^ do begin
      CurrPage   := Page;
      SaveHook   := OutputLine;
      OutputLine := upPutMemoryBitmapLine;
      ToBuffer   := True;

      if not UnpackingFile then
        Code := upInitPageUnpack(Unpack, FName, Page)
      else
        Code := ecOK;
      if (Code = ecOK) then
        Code := upOutputLine(Unpack, upStarting);
      if (Code < ecOK) then begin
        OutputLine           := SaveHook;
        upUnpackPageToBuffer := Code;
        Exit;
      end;

      Code := upUnpackPagePrim(Unpack, FName, Page);
      if (Code < ecOK) then begin
        OutputLine           := SaveHook;
        upUnpackPageToBuffer := Code;
        Exit;
      end;

      Code                 := upOutputLine(Unpack, upEnding);
      OutputLine           := SaveHook;
      upUnpackPageToBuffer := Code;
    end;
  end;

  function upUnpackFileToBuffer(Unpack : PUnpackFax; FName : PChar) : Integer;
    {-Unpack a fax into a memory bitmap}
  var
    Code  : Integer;
    I     : Cardinal;

  begin
    with Unpack^ do begin
      SaveHook   := OutputLine;
      OutputLine := upPutMemoryBitmapLine;
      ToBuffer   := True;

      Code := upGetFaxHeader(Unpack, FName, FaxHeader);
      if (Code < ecOK) then begin
        OutputLine           := SaveHook;
        upUnpackFileToBuffer := Code;
        Exit;
      end;

      Code := upInitFileUnpack(Unpack, FName);
      if (Code = ecOK) then
        Code := upOutputLine(Unpack, upStarting);
      if (Code < ecOK) then begin
        OutputLine           := SaveHook;
        upUnpackFileToBuffer := Code;
        Exit;
      end;

      for I := 1 to FaxHeader.PageCount do begin
        CurrPage := I;
        Code := upUnpackPagePrim(Unpack, FName, I);
        if (Code < ecOK) then begin
          OutputLine           := SaveHook;
          upUnpackFileToBuffer := Code;
          Exit;
        end;
      end;

      Code                 := upOutputLine(Unpack, upEnding);
      OutputLine           := SaveHook;
      upUnpackFileToBuffer := Code;
    end;
  end;

  procedure GetOutFileName(UserName, OutName, InName, DefaultExt : PChar);
  var
    Ext : array[0..255] of Char;

  begin
    if (UserName = nil) or (UserName^ = #0) then
      ForceExtensionZ(OutName, InName, DefaultExt)
    else begin
      JustExtensionZ(Ext, UserName);
      if (Ext[0] = #0) then
        ForceExtensionZ(OutName, UserName, DefaultExt)
      else
        StrCopy(OutName, UserName);
    end;
  end;

{Unpack to PCX routines}

type
  PPcxUnpackData = ^TPcxUnpackData;
  TPcxUnpackData = record
    PBOfs      : Cardinal;
    PcxOfs     : LongInt;
    OutFile    : PBufferedOutputFile;
    PackBuffer : array[0..511] of Byte;
  end;

  function OutputPcxImage(Unpack : PUnpackFax; var Data : TPcxUnpackData) : Integer;
  var
    Code    : Integer;
    I       : Cardinal;
    OutLine : PByteArray;

    function WritePcxHeader : Integer;
    var
      PH : TPcxHeaderRec;

    begin
      with Unpack^, Data do begin
        {construct PCX header}
        FastZero(PH, SizeOf(PH));
        with PH do begin
          Mfgr      := $0A;
          Ver       := $02;
          Encoding  := 1;
          BitsPixel := 1;
          XMax      := Pred(Width * 8);
          YMax      := Pred(Height);
          Planes    := 1;
          BytesLine := Width;
        end;

        {write PCX header}
        WritePcxHeader := WriteOutFile(OutFile, PH, SizeOf(TPcxHeaderRec));
      end;
    end;

    {$IFNDEF Win32}
    procedure CompressLine(Unpack : PUnpackFax; Data : PPcxUnpackData; OutLine : PByteArray); assembler;
    asm
      push  ds

      lds   si,Unpack                           {DS:SI->Unpack}
      mov   cx,[si].TUnpackFax.Width            {CX = # of input bytes}
      lds   si,OutLine                          {DS:SI->Input data}
      les   di,Data                             {ES:DI->PCX pack data struct}
      add   di,OFFSET TPcxUnpackData.PackBuffer {ES:DI->Data.PackBuffer}
      mov   bx,di                               {Save BX to count output len}

      or    cx,cx                               {any data to pack?}
      jz    @7                                  {if not, exit}

      mov   al,[si]                             {get first byte of input}
      inc   si
      xor   dx,dx                               {run length of 1}
      dec   cx
      jz    @2                                  {jump if no data left}

      {count run loop}
  @1: cmp   dl,62                               {maximum run length reached?}
      je    @5                                  {jump if so}
      cmp   al,[si]                             {still running?}
      jne   @2                                  {jump if not}
      inc   si                                  {increment input pointer}
      inc   dx                                  {increment run counter}
      dec   cx                                  {one more byte of input used}
      jz    @5                                  {output run if no more data}
      jmp   @1

      {output data}
  @2: or    dx,dx                               {run data to output?}
      jnz   @5                                  {jump if so}
      not   al
      mov   ah,al                               {save data byte}
      and   al,$C0                              {top two bits on?}
      cmp   al,$C0
      jne   @3                                  {if not, just output}
      mov   byte ptr es:[di],$C1                {output 1-byte run to}
      inc   di                                  {  avoid misinterp of data}
  @3: mov   es:[di],ah                          {output data byte}
      inc   di                                  {increment output pointer}
      or    cx,cx                               {any data left?}
      jz    @7                                  {jump if not}
      mov   al,[si]                             {get next data byte}
      inc   si                                  {increment input pointer}
      dec   cx                                  {decrement input counter}
      jnz   @1                                  {jump if any data left}

      {output last literal data byte}
      not   al
      mov   ah,al                               {save data byte}
      and   al,$C0                              {top two bits on?}
      cmp   al,$C0
      jne   @4                                  {if not, just output}
      mov   byte ptr es:[di],$C1                {output 1-byte run to}
      inc   di                                  {  avoid misinterp of data}
  @4: mov   es:[di],ah                          {output data byte}
      inc   di                                  {increment output counter}
      jmp   @7

      {output run}
  @5: inc   dx                                  {increment for actual count}
      or    dl,$C0                              {mask on two MSBs}
      mov   es:[di],dl                          {output run code}
      inc   di                                  {increment output pointer}
      not   al                                  {invert bits of raster data}
      mov   es:[di],al                          {output data byte}
      inc   di                                  {increment output pointer}
      xor   dx,dx                               {zero run counter}
      or    cx,cx                               {any data left?}
      jz    @7                                  {jump if not}
      mov   al,[si]                             {get next input byte}
      inc   si
      dec   cx                                  {decrement input counter}
      jnz   @1                                  {jump if no any data left}

      {output last literal data byte}
      not   al
      mov   ah,al                               {save data byte}
      and   al,$C0                              {top two bits on?}
      cmp   al,$C0
      jne   @6                                  {if not, just output}
      mov   byte ptr es:[di],$C1                {output 1-byte run to}
      inc   di                                  {  avoid misinterp of data}
  @6: mov   es:[di],ah                          {output data byte}
      inc   di                                  {increment output counter}

      {cleanup}
  @7: lds   si,Data                             {DS:SI->PCX unpack data}
      sub   di,bx                               {DI = length of output}
      mov   [si].TPcxUnpackData.PBOfs,di        {Set output length}

      pop   ds
    end;
    {$ELSE}
    procedure CompressLine(Unpack : PUnpackFax; Data : PPcxUnpackData; OutLine : PByteArray); assembler; register;
    asm
      push  edi
      push  esi
      push  ebx

      push  edx                                 {save Data for later}
      mov   esi,ecx                             {ecx = OutLine}
      mov   ecx,[eax].TUnpackFax.Width          {ECX = # of input bytes}
      mov   edi,edx                             {edx = Data}
      add   edi,OFFSET TPcxUnpackData.PackBuffer{edi->Data.PackBuffer}
      mov   ebx,edi                             {save EBX to count output len}

      or    ecx,ecx                             {any data to pack?}
      jz    @7

      mov   al,[esi]                            {get first byte of input}
      inc   esi
      xor   edx,edx                             {run length of 1}
      dec   ecx
      jz    @2                                  {jump if no data left}

      {count run loop}
  @1: cmp   dl,62                               {maximum run length reached?}
      je    @5                                  {jump if so}
      cmp   al,[esi]                            {still running?}
      jne   @2                                  {jump if not}
      inc   esi                                 {increment input pointer}
      inc   edx                                 {increment run counter}
      dec   ecx                                 {one more byte of input used}
      jz    @5                                  {output run if no more data}
      jmp   @1

      {output data}
  @2: or    edx,edx                             {run data to output?}
      jnz   @5                                  {jump if so}
      not   al
      mov   ah,al                               {save data byte}
      and   al,$C0                              {top two bits on?}
      cmp   al,$C0
      jne   @3                                  {if not, just output}
      mov   byte ptr [edi],$C1                  {output 1-byte run to}
      inc   edi                                 {  avoid misinterp of data}
  @3: mov   [edi],ah                            {output data byte}
      inc   edi                                 {increment output pointer}
      or    ecx,ecx                             {any data left?}
      jz    @7                                  {jump if not}
      mov   al,[esi]                            {get next data byte}
      inc   esi                                 {increment input pointer}
      dec   ecx                                 {decrement input counter}
      jnz   @1                                  {jump if any data left}

      {output last literal data byte}
      not   al
      mov   ah,al                               {save data byte}
      and   al,$C0                              {top two bits on?}
      cmp   al,$C0
      jne   @4                                  {if not, just output}
      mov   byte ptr [edi],$C1                  {output 1-byte run to}
      inc   edi                                 {  avoid misinterp of data}
  @4: mov   [edi],ah                            {output data byte}
      inc   edi                                  {increment output counter}
      jmp   @7

      {output run}
  @5: inc   edx                                 {increment for actual count}
      or    dl,$C0                              {mask on two MSBs}
      mov   [edi],dl                            {output run code}
      not   al                                  {invert bits of raster data}
      mov   [edi+1],al                          {output data byte}
      inc   edi                                 {increment output pointer}
      inc   edi                                 {increment output pointer}
      xor   edx,edx                             {zero run counter}
      or    ecx,ecx                             {any data left?}
      jz    @7                                  {jump if not}
      mov   al,[esi]                            {get next input byte}
      inc   esi
      dec   ecx                                 {decrement input counter}
      jnz   @1                                  {jump if no any data left}

      {output last literal data byte}
      not   al
      mov   ah,al                               {save data byte}
      and   al,$C0                              {top two bits on?}
      cmp   al,$C0
      jne   @6                                  {if not, just output}
      mov   byte [edi],$C1                      {output 1-byte run to}
      inc   edi                                 {  avoid misinterp of data}
  @6: mov   [edi],ah                            {output data byte}
      inc   edi                                 {increment output counter}

  @7: pop   esi                                 {restore Data into ESI}
      sub   edi,ebx                             {EDI = length of output}
      mov   [esi].TPcxUnpackData.PBOfs,edi      {Set output length}

      pop   ebx
      pop   esi
      pop   edi
    end;
    {$ENDIF}

  begin
    with Unpack^, Data do begin
      {write file header}
      Code := WritePcxHeader;
      if (Code < ecOK) then begin
        OutputPcxImage := Code;
        Exit;
      end;

      if Width > 0 then begin                                       
        {get memory for output line}
        OutLine := AllocMem(Width);

        {go through each line and write it}
        for I := 0 to Pred(Height) do begin
          {$IFNDEF Win32}
          hmemcpy(OutLine, GetPtr(Lines, LongInt(Width) * I), Width);
          {$ELSE}
          Move(GetPtr(Lines, LongInt(Width) * LongInt(I))^, OutLine^, Width);
          {$ENDIF}
          CompressLine(Unpack, @Data, OutLine);
          Code := WriteOutFile(OutFile, PackBuffer, PBOfs);
          if (Code < ecOK) then begin
            OutputPcxImage := Code;
            Exit;
          end;
        end;

        FreeMem(OutLine, Width);
      end;                                                         
      OutputPcxImage := ecOK;
    end;
  end;

  function OutputToPcx(Unpack : PUnpackFax; InName, OutName : PChar) : Integer;
  var
    Data        : TPcxUnpackData;
    Code        : Integer;
    OutFileName : array[0..255] of Char;

  begin
    FastZero(Data, SizeOf(TPcxUnpackData));

    with Unpack^, Data do begin
      GetOutFileName(OutName, OutFileName, InName, DefPcxExt);
      Code := InitOutFile(OutFile, OutFileName);
      if (Code < ecOK) then begin
        GlobalUnlock(Handle);
        GlobalFree(Handle);
        OutputToPcx := Code;
        Exit;
      end;

      Code := OutputPcxImage(Unpack, Data);
      GlobalUnlock(Handle);
      GlobalFree(Handle);
      if (Code < ecOK) then begin
        OutputToPcx := Code;
        Exit;
      end;

      OutputToPcx := CloseOutFile(OutFile);
    end;
  end;

  function upUnpackPageToPcx(Unpack : PUnpackFax; FName, OutName : PChar; Page : Cardinal) : Integer;
    {-Unpack one page of an APF file to a PCX file}
  var
    Code : Integer;

  begin
    Code := upUnpackPageToBuffer(Unpack, FName, Page, False);
    if (Code = ecOK) then
      Code := OutputToPcx(Unpack, FName, OutName);
    upUnpackPageToPcx := Code;
  end;

  function upUnpackFileToPcx(Unpack : PUnpackFax; FName, OutName : PChar) : Integer;
    {-Unpack an APF file to a PCX file}
  var
    Code : Integer;

  begin
    Code := upUnpackFileToBuffer(Unpack, FName);
    if (Code = ecOK) then
      Code := OutputToPcx(Unpack, FName, OutName);
    upUnpackFileToPcx := Code;
  end;

type
  PDcxUnpackData = ^TDcxUnpackData;
  TDcxUnpackData = record
    PCXData   : TPcxUnpackData;
    NumPages  : Integer;
    DcxHeader : TDcxHeaderRec;
  end;

  function CreateDCXFile(const Unpack : PUnpackFax; InName, OutName : PChar; var Data : PDcxUnpackData) : Integer;
  var
    OutFileName : array[0..255] of Char;
    Code        : Integer;

  begin
    CreateDCXFile := ecOK;

    {allocate memory for converter data}
    Data := AllocMem(SizeOf(TDcxUnpackData));

    with Data^, PCXData do begin
      GetOutFileName(OutName, OutFileName, InName, DefDcxExt);

      {create the output file}
      Code := InitOutFile(OutFile, OutFileName);
      if (Code < ecOK) then begin
        FreeMem(Data, SizeOf(TDcxUnpackData));
        CreateDcxFile := Code;
        Exit;
      end;

      {write the header to the output file}
      DcxHeader.ID := 987654321;
      Code := WriteOutFile(OutFile, DcxHeader, SizeOf(TDcxHeaderRec));

      {check for errors}
      if (Code < ecOK) then begin
        FreeMem(Data, SizeOf(TDcxUnpackData));
        CreateDCXFile := Code;
        Exit;
      end;
    end;
  end;

  function OutputPageToDcx(Unpack : PUnpackFax; var Data : PDcxUnpackData) : Integer;
  var
    Code : Integer;

  begin
    OutputPageToDcx := ecOK;

    with Unpack^, Data^, PcxData do begin
      {update DCX header}
      Inc(NumPages);
      DCXHeader.Offsets[NumPages] := OutFilePosn(OutFile);

      Code := OutputPcxImage(Unpack, PcxData);
      GlobalUnlock(Handle);
      GlobalFree(Handle);
      if (Code < ecOK) then begin
        OutputPageToDcx := Code;
        FreeMem(Data, SizeOf(TDcxUnpackData));
        Exit;
      end;
    end;
  end;

  function CloseDcxFile(Unpack : PUnpackFax; var Data : PDcxUnpackData) : Integer;
  var
    Code : Integer;

  begin
    with Unpack^, Data^, PcxData do begin
      {write updated header back to file}
      Code := SeekOutFile(OutFile, 0);
      if (Code = ecOK) then
        Code := WriteOutFile(OutFile, DcxHeader, SizeOf(TDcxHeaderRec));
      if (Code = ecOK) then
        Code := CloseOutFile(OutFile);

      FreeMem(Data, SizeOf(TDcxUnpackData));
      CloseDcxFile := Code;
    end;
  end;

  function upUnpackPageToDcx(Unpack : PUnpackFax; FName, OutName : PChar; Page : Cardinal) : Integer;
    {-Unpack one page of an APF file to a DCX file}
  var
    Code : Integer;
    Data : PDcxUnpackData;

  begin
    Code := upUnpackPageToBuffer(Unpack, FName, Page, False);
    if (Code = ecOK) then begin
      Code := CreateDCXFile(Unpack, FName, OutName, Data);
      if (Code = ecOK) then begin
        Code := OutputPageToDcx(Unpack, Data);
        if (Code = ecOK) then
          Code := CloseDcxFile(Unpack, Data);
      end;
    end;
    upUnpackPageToDcx := Code;
  end;

  function upUnpackFileToDcx(Unpack : PUnpackFax; FName, OutName : PChar) : Integer;
    {-Unpack an APF file to a DCX file}
  var
    Code : Integer;
    I    : Cardinal;
    Data : PDcxUnpackData;

  begin
    with Unpack^ do begin
      Code := ecOK;                                                      {!!.04}
      try                                                                {!!.04}
        {read the fax file header}
        Code := upGetFaxHeader(Unpack, FName, FaxHeader);
        if (Code < ecOK) then begin
          upUnpackFileToDcx := Code;
          Exit;
        end;

        {create the output file}
        Code := CreateDCXFile(Unpack, FName, OutName, Data);
        if (Code < ecOK) then begin
          upUnpackFileToDcx := Code;
          Exit;
        end;

        Code := upInitFileUnpack(Unpack, FName);
        if (Code < ecOK) then begin
          FreeMem(Data, SizeOf(TDcxUnpackData));
          upUnpackFileToDcx := Code;
          Exit;
        end;

        {output each page as a PCX image}
        for I := 1 to FaxHeader.PageCount do begin
          Code := upUnpackPageToBuffer(Unpack, FName, I, True);
          if (Code = ecOK) then
            Code := OutputPageToDcx(Unpack, Data);

          if (Code < ecOK) then begin
            FreeMem(Data, SizeOf(TDcxUnpackData));
            upUnpackFileToDcx := Code;
            Exit;
          end;
        end;

      finally                                                            {!!.04}
        {close the output file}
        if Code = ecOK then                                              {!!.04}
          Code := CloseDCXFile(Unpack, Data)                             {!!.04}
        else                                                             {!!.04}
          { an error occured, preserve the return value }
          CloseDCXFile(Unpack, Data);                                    {!!.04}
        upUnpackFileToDcx := Code;                                       {!!.04}
      end;                                                               {!!.04}
    end;
  end;

{Unpack to TIFF routines}

  {$IFNDEF Win32}
  procedure TiffEncode( var InBuf ;     InLen  : Cardinal;
                        var OutBuf; var OutLen : Cardinal ); assembler;
  asm
    push ds

    mov  ax,InLen                 {get input length}
    or   ax,ax                    {is it zero?}
    jnz  @I1                      {jump if not}
    xor  di,di                    {return zero output length}
    jmp  @A

@I1:les  di,OutBuf                {di = current output offset}
    mov  dx,di                    {dx = saved starting output offset}
    mov  bx,di                    {bx = control byte offset}
    mov  byte ptr es:[bx],0       {reset initial control byte}

    lds  si,InBuf                 {si = current input offset}

    cmp  ax,1                     {is input length 1?}
    ja   @I2                      {jump if not}

    mov  al,[si]                  {get first input byte}
    mov  es:[bx+1],al             {store it past control byte}
    mov  di,2                     {output length is two}
    jmp  @A                       {exit}

@I2:cld                           {forward}
    mov  cx,si
    add  cx,ax                    {cx = offset just beyond end of input}

    mov  ax,[si]                  {does data start with a run?}
    cmp  ah,al
    je   @I3                      {jump if so}

    inc  di                       {prepare to store first input byte}
    mov  es:[di],al               {store it}
    inc  di                       {prepare to store next input byte}
    inc  si                       {we've used first input byte}

@I3:dec  si                       {first time in, adjust for next inc si}

@1: inc  si                       {next input byte}
    cmp  si,cx
    jae  @9                       {jump out if done}

    mov  ax,[si]                  {get next two bytes}
    cmp  ah,al                    {the same?}
    jne  @5                       {jump if not a run}
    mov  bx,di                    {save OutPos offset}
    mov  byte ptr es:[bx],0       {reset control byte}
    mov  es:[bx+1],al             {store run byte}

@2: inc  si                       {next input byte}
    cmp  si,cx                    {end of input?}
    jae  @3                       {jump if so}
    cmp  [si],al                  {still a run?}
    jne  @3                       {jump if not}
    cmp  byte ptr es:[bx],$81     {max run length?}
    je   @3                       {jump if so}
    dec  byte ptr es:[bx]         {decrement control byte}
    jmp  @2                       {loop}

@3: dec  si                       {back up one input character}
    inc  di                       {step past control and run bytes}
    inc  di
    jmp  @1                       {loop}

@5: cmp  byte ptr es:[bx],$7f     {run already in progress?}
    jb  @6                        {jump if not}
    mov  bx,di                    {start a new control sequence}
    mov  byte ptr es:[bx],0       {reset control byte}
    inc  di                       {next output position}
    jmp  @7
@6: inc  byte ptr es:[bx]         {increase non-run length}
@7: stosb                         {copy input byte to output}
    jmp  @1

@9: pop  ds
    sub  di,dx
@A: les  si,OutLen
    mov  es:[si],di
  end;
  {$ELSE}
  procedure TiffEncode( var InBuf ;     InLen  : Cardinal;
                        var OutBuf; var OutLen : Cardinal ); assembler; register;
  asm
    push  edi
    push  esi
    push  ebx

    mov   esi,eax                 {eax = InBuf = esi = current input offset}
    mov   eax,edx                 {edx = InLen}
    or    eax,eax                 {input length zero?}
    jnz   @I1                     {jump if not}
    xor   edi,edi                 {return zero output length}
    jmp   @A

@I1:mov   edi,ecx                 {ecx = OutBuf}
    mov   edx,edi                 {edx = saved starting output offset}
    mov   ebx,edi                 {ebx = control byte offset}
    mov   byte ptr [edi],0        {reset inital control byte}

    cmp   eax,1                   {is input length 1?}
    ja    @I2                     {jump if not}

    mov   al,[esi]                {get first input byte}
    mov   [ebx+1],al              {store it past control byte}
    mov   edi,2                   {output length is two}
    jmp   @A                      {exit}

@I2:mov   ecx,esi
    add   ecx,eax                 {ecx = offset just beyond end of input}

    mov   ax,[esi]                {does data start with a run?}
    cmp   ah,al
    je    @I3                     {jump if so}

    mov   [edi+1],al              {store first input byte}
    inc   edi
    inc   edi                     {prepare to store next input byte}
    inc   esi                     {we've used first input byte}

@I3:dec   esi                     {first time in, adjust for next inc esi}

@1: inc   esi                     {next input byte}
    cmp   esi,ecx
    jae   @9                      {jump out if done}

    mov   ax,[esi]                {get next two bytes}
    cmp   ah,al                   {the same?}
    jne   @5                      {jump if not a run}
    mov   ebx,edi                 {save OutPos offset}
    mov   byte ptr [edi],0        {reset control byte}
    mov   [edi+1],al              {store run byte}

@2: inc   esi                     {next input byte}
    cmp   esi,ecx                 {end of input?}
    jae   @3                      {jump if so}
    cmp   [esi],al                {still a run?}
    jne   @3                      {jump if not}
    cmp   byte ptr [ebx],$81      {max run length?}
    je    @3                      {jump if so}
    dec   byte ptr [ebx]          {decrement control byte}
    jmp   @2                      {loop}

@3: dec   esi                     {back up one input character}
    inc   edi                     {step past control and run bytes}
    inc   edi
    jmp   @1                      {loop}

@5: cmp   byte ptr [ebx],$7F      {run already in progress?}
    jb    @6                      {jump if not}
    mov   ebx,edi                 {start a new control sequence}
    mov   byte ptr [edi],0        {reset control byte}
    inc   edi                     {next output position}
    jmp   @7
@6: inc   byte ptr [ebx]          {increase non-run length}
@7: mov   [edi],al                {copy input byte to output}
    inc   edi
    jmp   @1

@9: sub   edi,edx
@A: mov   esi,OutLen
    mov   [esi],edi

    pop   ebx
    pop   esi
    pop   edi
  end;
  {$ENDIF}

  function OutputToTiff(Unpack : PUnpackFax; InName, OutName : PChar) : Integer;
  type
    TTiffHeader = packed record
      ByteOrder                : array[1..2] of Char;
      Version                  : Word;
      ImgDirStart              : LongInt;
      NumTags                  : Word;
      SubFileTag               : Word;
      SubFileTagType           : Word;
      SubFileData              : array[1..4] of Word;
      ImageWidthTag            : Word;
      ImageWidthTagType        : Word;
      ImageWidthData           : array[1..4] of Word;
      ImageLengthTag           : Word;
      ImageLengthTagType       : Word;
      ImageLengthData          : array[1..4] of Word;
      BitsPerSampleTag         : Word;
      BitsPerSampleTagType     : Word;
      BitsPerSampleData        : array[1..4] of Word;
      CompressionTag           : Word;
      CompressionTagType       : Word;
      CompressionData          : array[1..4] of Word;
      PhotoMetricInterpTag     : Word;
      PhotoMetricInterpTagType : Word;
      PhotoMetricInterpData    : array[1..4] of Word;
      StripOffsetsTag          : Word;
      StripOffsetsTagType      : Word;
      StripOffsetsData         : array[1..2] of LongInt;
      RowsPerStripTag          : Word;
      RowsPerStripTagType      : Word;
      RowsPerStripData         : array[1..2] of LongInt;
      StripByteCountsTag       : Word;
      StripByteCountsTagType   : Word;
      StripByteCountsData      : array[1..2] of LongInt;
    end;

  const
    {TIFF tag values}
    SubfileType       = 255;
    ImageWidth        = 256;
    ImageLength       = 257;
    BitsPerSample     = 258;
    Compression       = 259;
    PhotometricInterp = 262;
    StripOffsets      = 273;
    RowsPerStrip      = 278;
    StripByteCounts   = 279;

    {TIFF tag integer types}
    tiffByte          = 1;
    tiffASCII         = 2;
    tiffShort         = 3;
    tiffLong          = 4;
    tiffRational      = 5;

    TiffHeader : TTiffHeader =
      ( ByteOrder                : ('I', 'I');
        Version                  : 42;
        ImgDirStart              : 8;
        NumTags                  : 9;
        SubFileTag               : SubfileType;
        SubFileTagType           : tiffShort;
        SubFileData              : ($0001, $0000, $0001, $0000);
        ImageWidthTag            : ImageWidth;
        ImageWidthTagType        : tiffShort;
        ImageWidthData           : ($0001, $0000, $0000, $0000);
        ImageLengthTag           : ImageLength;
        ImageLengthTagType       : tiffShort;
        ImageLengthData          : ($0001, $0000, $0000, $0000);
        BitsPerSampleTag         : BitsPerSample;
        BitsPerSampleTagType     : tiffShort;
        BitsPerSampleData        : ($0001, $0000, $0001, $0000);
        CompressionTag           : Compression;
        CompressionTagType       : tiffShort;
        CompressionData          : ($0001, $0000, compMPNT, $0000);
        PhotoMetricInterpTag     : PhotoMetricInterp;
        PhotoMetricInterpTagType : tiffShort;
        PhotoMetricInterpData    : ($0001, $0000, $0000, $0000);
        StripOffsetsTag          : StripOffsets;
        StripOffsetsTagType      : tiffLong;
        StripOffsetsData         : ($00000001, SizeOf(TTiffHeader));
        RowsPerStripTag          : RowsPerStrip;
        RowsPerStripTagType      : tiffLong;
        RowsPerStripData         : ($00000001, $00000000);
        StripByteCountsTag       : StripByteCounts;
        StripByteCountsTagType   : tiffLong;
        StripByteCountsData      : ($00000001, $00000000));

  var
    Code        : Integer;
    OnLine      : Cardinal;
    OutFile     : PBufferedOutputFile;
    OutLine     : Pointer;
    CompBuf     : Pointer;
    CompLen     : Cardinal;
    Bytes       : LongInt;
    OutFileName : array[0..255] of Char;

    procedure Cleanup;
    begin
      with Unpack^ do begin
        GlobalUnlock(Handle);
        GlobalFree(Handle);
        FreeMem(OutLine, Width);
      end;
    end;

  begin
    GetOutFileName(OutName, OutFileName, InName, DefTiffExt);

    with Unpack^ do begin
      {allocate memory for line buffer}
      OutLine := AllocMem(Width);
      CompBuf := AllocMem(Width * 2);

      {create output file}
      Code := InitOutFile(OutFile, OutFileName);
      if (Code < ecOK) then begin
        Cleanup;
        OutputToTiff := Code;
        Exit;
      end;

      {fix up the tiff header}
      with TiffHeader do begin
        ImageWidthData[3]   := Width * 8;
        ImageLengthData[3]  := Height;
        RowsPerStripData[2] := Height;
      end;

      {output byte-order and version header}
      Code := WriteOutFile(OutFile, TiffHeader, SizeOf(TTiffHeader));
      if (Code < ecOK) then begin
        Cleanup;
        OutputToTiff := Code;
        Exit;
      end;

      {output each line of the buffer to the BMP file}
      FastZero(OutLine^, Width);
      FastZero(CompBuf^, Width * 2);
      Bytes := 0;
      for OnLine := 0 to Pred(Height) do begin
        {$IFNDEF Win32}
        hmemcpy(OutLine, GetPtr(Lines, LongInt(Width) * OnLine), Width);
        {$ELSE}
        Move(GetPtr(Lines, LongInt(Width) * LongInt(OnLine))^, OutLine^, Width);
        {$ENDIF}
        TiffEncode(OutLine^, Width, CompBuf^, CompLen);
        Inc(Bytes, CompLen);
        Code := WriteOutFile(OutFile, CompBuf^, CompLen);
        if (Code < ecOK) then begin
          Cleanup;
          OutputToTiff := Code;
          Exit;
        end;
      end;

      FreeMem(CompBuf, Width * 2);
      FreeMem(OutLine, Width);
      GlobalUnlock(Handle);
      GlobalFree(Handle);

      {redo the header}
      TiffHeader.StripByteCountsData[2] := Bytes;
      Code := SeekOutFile(OutFile, 0);
      if (Code = ecOK) then
        Code := WriteOutFile(OutFile, TiffHeader, SizeOf(TTiffHeader));
      if (Code = ecOK) then
        Code := CloseOutFile(OutFile);

      OutputToTiff := Code;
    end;
  end;

  function upUnpackPageToTiff(Unpack : PUnpackFax; FName, OutName : PChar; Page : Cardinal) : Integer;
    {-Unpack one page of an APF file to a TIF file}
  var
    Code : Integer;

  begin
    Code := upUnpackPageToBuffer(Unpack, FName, Page, False);
    if (Code = ecOK) then
      Code := OutputToTiff(Unpack, FName, OutName);
    upUnpackPageToTiff:= Code;
  end;

  function upUnpackFileToTiff(Unpack : PUnpackFax; FName, OutName : PChar) : Integer;
    {-Unpack an APF file to a TIF file}
  var
    Code : Integer;

  begin
    Code := upUnpackFileToBuffer(Unpack, FName);
    if (Code = ecOK) then
      Code := OutputToTiff(Unpack, FName, OutName);
    upUnpackFileToTiff := Code;
  end;

{Unpack to BMP routines}

  function OutputToBitmap(Unpack : PUnpackFax; InName, OutName : PChar) : Integer;
  const
    BmpPalette : array[1..8] of Byte = ($00, $00, $00, $00, $FF, $FF, $FF, $00);

  var
    Code        : Integer;
    OnLine      : Cardinal;
    LineBytes   : Cardinal;
    OutFile     : PBufferedOutputFile;
    FileHeader  : TBitmapFileHeader;
    InfoHeader  : TBitmapInfoHeader;
    OutLine     : Pointer;
    OutFileName : array[0..255] of Char;

    procedure Cleanup;
    begin
      with Unpack^ do begin
        FreeMem(OutLine, LineBytes);
        GlobalUnlock(Handle);
        GlobalFree(Handle);
      end;
    end;

  begin
    GetOutFileName(OutName, OutFileName, InName, DefBmpExt);

    with Unpack^ do begin

      if Height > 32767 then begin
        OutputToBitmap := ecBmpTooBig;
        Exit;                            
      end;

      LineBytes  := (Width + 3) and $FFFC;

      {get memory for output line}
      OutLine := AllocMem(LineBytes);

      {build the headers for the bitmap}
      FastZero(FileHeader, SizeOf(TBitmapFileHeader));
      with FileHeader do begin
        bfType    := $4D42;
        bfOffBits := SizeOf(TBitmapFileHeader) + SizeOf(TBitmapInfoHeader) + SizeOf(BmpPalette);
        bfSize    := (DWORD(LineBytes) * Height) + bfOffBits;       
      end;
      FastZero(InfoHeader, SizeOf(TBitmapInfoHeader));
      with InfoHeader do begin
        biSize        := SizeOf(TBitmapInfoHeader);
        biWidth       := LongInt(Width) * 8;
        biHeight      := Height;
        biPlanes      := 1;
        biBitCount    := 1;
      end;

      {create the output file and write the headers}
      Code := InitOutFile(OutFile, OutName);
      if (Code < ecOK) then begin
        Cleanup;
        OutputToBitmap := Code;
        Exit;
      end;

      Code := WriteOutFile(OutFile, FileHeader, SizeOf(TBitmapFileHeader));
      if (Code = ecOK) then begin
        Code := WriteOutFile(OutFile, InfoHeader, SizeOf(TBitmapInfoHeader));
        if (Code = ecOK) then
          Code := WriteOutFile(OutFile, BmpPalette, SizeOf(BmpPalette));
      end;
      if (Code < ecOK) then begin
        Cleanup;
        OutputToBitmap := Code;
        Exit;
      end;

      {output each line of the buffer to the BMP file}
      FastZero(OutLine^, LineBytes);
      NotBuffer(OutLine^, LineBytes);
      for OnLine := Pred(Height) downto 0 do begin
        {$IFNDEF Win32}
        hmemcpy(OutLine, GetPtr(Lines, LongInt(Width) * OnLine), Width);
        {$ELSE}
        Move(GetPtr(Lines, LongInt(Width) * Integer(OnLine))^, OutLine^, Width);
        {$ENDIF}
        NotBuffer(OutLine^, Width);
        Code := WriteOutFile(OutFile, OutLine^, LineBytes);
        if (Code < ecOK) then begin
          Cleanup;
          OutputToBitmap := Code;
          Exit;
        end;
      end;

      OutputToBitmap := CloseOutFile(OutFile);

      {free memory}
      GlobalUnlock(Handle);
      GlobalFree(Handle);
      FreeMem(OutLine, LineBytes);
    end;
  end;

  function upUnpackPageToBmp(Unpack : PUnpackFax; FName, OutName : PChar; Page : Cardinal) : Integer;
    {-Unpack one page of an APF file to a BMP file}
  var
    Code : Integer;

  begin
    Code := upUnpackPageToBuffer(Unpack, FName, Page, False);
    if (Code = ecOK) then
      Code := OutputToBitmap(Unpack, FName, OutName);
    upUnpackPageToBmp := Code;
  end;

  function upUnpackFileToBmp(Unpack : PUnpackFax; FName, OutName : PChar) : Integer;
    {-Unpack an APF file to a BMP file}
  var
    Code : Integer;

  begin
    Code := upUnpackFileToBuffer(Unpack, FName);
    if (Code = ecOK) then
      Code := OutputToBitmap(Unpack, FName, OutName);
    upUnpackFileToBmp := Code;
  end;

{$ENDIF}{(IFNDEF PRNDRV)}

{Initialization routines}

  procedure RotateCodeGroup(var TC : TTermCodeArray; var MUC : TMakeUpCodeArray);
    {-Flip bits in white or black groups}
  var
    I : Integer;
  begin
    for I := 0 to MaxCodeTable do
      with TC[I] do
        RotateCode(Code, Sig);
    for I := 0 to MaxMUCodeTable do
      with MUC[I] do
        RotateCode(Code, Sig);
  end;

  procedure RotateCodes;
    {-Flip bits in all codes}
  begin
    RotateCodeGroup(WhiteTable, WhiteMUTable);
    RotateCodeGroup(BlackTable, BlackMUTable);
    RotateCode(EOLRec.Code, EOLRec.Sig);
    RotateCode(LongEOLRec.Code, LongEOLRec.Sig);
  end;

initialization
  RotateCodes;
end.
