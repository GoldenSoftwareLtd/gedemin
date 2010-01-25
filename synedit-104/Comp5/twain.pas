unit Twain;

{******************************************************************}
{                                                                  }
{ Borland Delphi Runtime Library                                   }
{ Twain interface unit                                             }
{                                                                  }
{ Portions created by TWAIN Working Group,                         }
{ see Copyright statement from original file below                 }
{                                                                  }
{ The original file is: twain.h, released Januar 1999.             }
{ The original Pascal code is: twain.pas, released 20. Dez 1999.   }
{ The initial developer of the Pascal code is: Uli Tessel (UT)     }
{ (UliTessel@swol.de) with help of Matthias Thoma (MT)             }
{ (ma.thoma@gmx.de)                                                }
{                                                                  }
{ Obtained through:                                                }
{ Joint Endeavour of Delphi Innovators (Project JEDI)              }
{                                                                  }
{ You may retrieve the latest version of this file at the Project  }
{ JEDI home page, located at http://delphi-jedi.org                }
{                                                                  }
{ The contents of this file are used with permission, subject to   }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/MPL/MPL-1.1.html                          }
{                                                                  }
{ Software distributed under the License is distributed on an      }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License.                        }
{                                                                  }
{******************************************************************}

{ ========================================================================

 Copyright (C) 1991, 1992 TWAIN Working Group: Aldus, Caere, Eastman-Kodak,
 Hewlett-Packard and Logitech Corporations. All rights reserved.

 Copyright (C) 1997 TWAIN Working Group: Bell+Howell, Canon, DocuMagix,
 Fujitsu, Genoa Technology, Hewlett-Packard, Kofax Imaging Products, and
 Ricoh Corporation. All rights reserved.

 Copyright © 1998 TWAIN Working Group: Adobe Systems Incorporated,
 Canon Information Systems, Eastman Kodak Company,
 Fujitsu Computer Products of America, Genoa Technology,
 Hewlett-Packard Company, Intel Corporation, Kofax Image Products,
 JFL Peripheral Solutions Inc., Ricoh Corporation, and Xerox Corporation.
 All rights reserved.

 TWAIN.h - This is the definitive include file for applications and
     data sources written to the TWAIN specification.
     It defines constants, data structures, messages etc.
     for the public interface to TWAIN.

 Revision History:
  version 1.0, March 6, 1992. TWAIN 1.0.
  version 1.1, January 1993.  Tech Notes 1.1
  version 1.5, June 1993.   Specification Update 1.5
                 Change DC to TW
                 Change filename from DC.H to TWAIN.H
  version 1.5, July 1993.   Remove spaces from country identifiers

  version 1.7, July 1997    Added Capabilities and data structure for
                 document imaging and digital cameras.
                 KHL.
  version 1.7, July 1997    Inserted Borland compatibile structure packing
                 directives provided by Mentor. JMH
  version 1.7, Aug 1997    Expanded file tabs to spaces.
                 NOTE: future authors should be sure to have
                 their editors set to automatically expand tabs
                 to spaces (original tab setting was 4 spaces).
  version 1.7, Sept 1997    Added job control values
                 Added return codes
  version 1.7, Sept 1997    changed definition of pRGBRESPONSE to
                 pTW_RGBRESPONSE
  version 1.7 Aug 1998    Added missing TWEI_BARCODEROTATION values
                 TWBCOR_ types JMH
  version 1.8 August 1998   Added new types and definitions required
                 for 1.8 Specification JMH
  version 1.8 January 1999  Changed search mode from SRCH_ to TWBD_ as
                 in 1.8 Specification, added TWBT_MAXICODE	JMH
  version 1.8 January 1999  Removed undocumented duplicate AUTO<cap> JMH
 ======================================================================== }

{
 Revision History for translation:

   Version 1.8.0: 29.08.99 - UT
      Initial translation, based on twain.h, version 1.8

   Version 1.8.1: 12.09.99 - UT
      SizeOf for all structures checked and corrected.
      (Alignment is 2 Bytes for the C Code and 'packed record' uses
      1 Byte alignment. Only types using TW_xINT8 are affected)

   Version 1.8.2: 19.12.99 UT
      Added MPL and the other JEDI Statements
      Added EXTERNALSYMS to support C++ Builder
      Created the .PAR file (no Unicode things are used by the TWAIN API?)
      A bit better formatting of the source

   Version 1.8.3: 20.12.99
      MT: Added Delphi-Aliases to the structures (like TTWFrame = TW_FRAME)
      UT: Added missing Externalyms for some constants

}

interface

{$HPPEMIT '#include <twain.h>' }

uses Windows;

{***************************************************************************
 * TWAIN Version                                                           *
 *************************************************************************** }
const
{$EXTERNALSYM TWON_PROTOCOLMINOR}
  TWON_PROTOCOLMINOR = 8;    { Changed for Version 1.8 }
{$EXTERNALSYM TWON_PROTOCOLMAJOR}
  TWON_PROTOCOLMAJOR = 1;

{***************************************************************************
 * Platform Dependent Definitions and Typedefs                             *
 *************************************************************************** }

type
  {$EXTERNALSYM TW_HANDLE}
  TW_HANDLE = THANDLE;
  TTWHandle = TW_HANDLE;
  {$EXTERNALSYM TW_MEMREF}
  TW_MEMREF = pointer;
  TTWMemRef = TW_MEMREF;

{***************************************************************************
 * Type Definitions                                                        *
 *************************************************************************** }

{ String types. These include room for the strings and a NULL char,   *
* or, on the Mac, a length byte followed by the string.               *
* TW_STR255 must hold less than 256 chars so length fits in first byte. }
type
  {$EXTERNALSYM pTW_STR32}
  pTW_STR32 = ^TW_STR32;
  PTWStr32 = pTW_STR32;
  {$EXTERNALSYM TW_STR32}
  TW_STR32 = array[0..33] of char;   // char    TW_STR32[34]
  TTWStr32 = TW_STR32;
  {$EXTERNALSYM pTW_STR64}
  pTW_STR64 = ^TW_STR64;
  PTWStr64 = pTW_STR64;
  {$EXTERNALSYM TW_STR64}
  TW_STR64 = array[0..65] of char;   // char    TW_STR64[66]
  TTWStr64 = TW_STR64;
  {$EXTERNALSYM pTW_STR128}
  pTW_STR128 = ^TW_STR128;
  PTWStr128 = pTW_STR128;
  {$EXTERNALSYM TW_STR128}
  TW_STR128 = array[0..129] of char; // char    TW_STR128[130]
  TTWStr128 = TW_STR128;
  {$EXTERNALSYM pTW_STR255}
  pTW_STR255 = ^TW_STR255;
  PTWStr255 = pTW_STR255;
  {$EXTERNALSYM TW_STR255}
  TW_STR255 = array[0..255] of char; // char    TW_STR255[256]
  TTWStr255 = TW_STR255;

{ Numeric types. }
type
  {$EXTERNALSYM pTW_INT8}
  pTW_INT8 = ^TW_INT8;
  PTWInt8 = pTW_INT8;
  {$EXTERNALSYM TW_INT8}
  TW_INT8 = ShortInt;     // char TW_INT8
  TTWInt8 = TW_INT8;
  {$EXTERNALSYM pTW_INT16}
  pTW_INT16 = ^TW_INT16;
  PTWInt16 = pTW_INT16;
  {$EXTERNALSYM TW_INT16}
  TW_INT16 = SmallInt;    // short TW_INT16
  TTWInt16 = TW_INT16;
  {$EXTERNALSYM pTW_INT32}
  pTW_INT32 = ^TW_INT32;
  PTWInt32 = pTW_INT32;
  {$EXTERNALSYM TW_INT32}
  TW_INT32 = LongInt;     // long TW_INT32
  TTWInt32 = TW_INT32;
  {$EXTERNALSYM pTW_UINT8}
  pTW_UINT8 = ^TW_UINT8;
  PTWUInt8 = pTW_UINT8;
  {$EXTERNALSYM TW_UINT8}
  TW_UINT8 = Byte;        // unsigned char TW_UINT8
  TTWUInt8 = TW_UINT8;
  {$EXTERNALSYM pTW_UINT16}
  pTW_UINT16 = ^TW_UINT16;
  PTWUInt16 = pTW_UINT16;
  {$EXTERNALSYM TW_UINT16}
  TW_UINT16 = Word;       // unsigned short TW_UINT16
  TTWUInt16 = TW_UINT16;
  {$EXTERNALSYM pTW_UINT32}
  pTW_UINT32 = ^TW_UINT32;
  PTWUInt32 = pTW_UINT32;
  {$EXTERNALSYM TW_UINT32}
  TW_UINT32 = ULONG;   // unsigned long TW_UINT32
  TTWUInt32 = TW_UINT32;
  {$EXTERNALSYM pTW_BOOL}
  pTW_BOOL = ^TW_BOOL;
  PTWBool = pTW_BOOL;
  {$EXTERNALSYM TW_BOOL}
  TW_BOOL = WordBool;     // unsigned short TW_BOOL
  TTWBool = TW_BOOL;

{ Fixed point structure type. }
type
  {$EXTERNALSYM pTW_FIX32}
  pTW_FIX32 = ^TW_FIX32;
  {$EXTERNALSYM TW_FIX32}
  TW_FIX32 = packed record
    Whole: TW_INT16; { maintains the sign }
    Frac: TW_UINT16;
  end;

  TTWFix32 = TW_Fix32;
  PTWFix32 = pTW_FIX32;

{***************************************************************************
 * Structure Definitions                                                   *
 *************************************************************************** }

{ No DAT needed. }
type
  {$EXTERNALSYM pTW_CIEPOINT}
  pTW_CIEPOINT = ^TW_CIEPOINT;
  {$EXTERNALSYM TW_CIEPOINT}
  TW_CIEPOINT = packed record
    X: TW_FIX32;
    Y: TW_FIX32;
    Z: TW_FIX32;
  end;

  TTWCiePoint = TW_CIEPOINT;
  PTWCiePoint = pTW_CIEPOINT;


{ No DAT needed. }
  {$EXTERNALSYM pTW_DECODEFUNCTION}
  pTW_DECODEFUNCTION = ^TW_DECODEFUNCTION;
  {$EXTERNALSYM TW_DECODEFUNCTION}
  TW_DECODEFUNCTION = packed record
    StartIn: TW_FIX32;
    BreakIn: TW_FIX32;
    EndIn: TW_FIX32;
    StartOut: TW_FIX32;
    BreakOut: TW_FIX32;
    EndOut: TW_FIX32;
    Gamma: TW_FIX32;
    SampleCount: TW_FIX32; { if =0 use the gamma }
  end;

  TTWDecodeFunction = TW_DECODEFUNCTION;
  PTWDecodeFunction = pTW_DECODEFUNCTION;


{ No DAT needed. }
  {$EXTERNALSYM pTW_ELEMENT8}
  pTW_ELEMENT8 = ^TW_ELEMENT8;
  {$EXTERNALSYM TW_ELEMENT8}
  TW_ELEMENT8 = packed record
    Index: TW_UINT8;    { Value used to index into the color table. }
    Channel1: TW_UINT8; { First tri-stimulus value (e.g Red) }
    Channel2: TW_UINT8; { Second tri-stimulus value (e.g Green) }
    Channel3: TW_UINT8; { Third tri-stimulus value (e.g Blue) }
  end;

  TTWElement8 = TW_ELEMENT8;
  PTWElement8 = pTW_ELEMENT8;

{ No DAT. Defines a frame rectangle in ICAP_UNITS coordinates. }
  {$EXTERNALSYM pTW_FRAME}
  pTW_FRAME = ^TW_FRAME;
  {$EXTERNALSYM TW_FRAME}
  TW_FRAME = packed record
    Left: TW_FIX32;
    Top: TW_FIX32;
    Right: TW_FIX32;
    Bottom: TW_FIX32;
  end;

  PTWFrame = pTW_FRAME;
  TTWFrame = TW_FRAME;


{ No DAT needed. Used to manage memory buffers. }
  {$EXTERNALSYM pTW_MEMORY}
  pTW_MEMORY = ^TW_MEMORY;
  {$EXTERNALSYM TW_MEMORY}
  TW_MEMORY = packed record
    Flags: TW_UINT32;  { Any combination of the TWMF_ constants. }
    Length: TW_UINT32; { Number of bytes stored in buffer TheMem. }
    TheMem: TW_MEMREF; { Pointer or handle to the allocated memory buffer. }
  end;

  TTWMemory = TW_MEMORY;
  PTWMemory = pTW_MEMORY;


{ No DAT needed. }
  {$EXTERNALSYM pTW_TRANSFORMSTAGE}
  pTW_TRANSFORMSTAGE = ^TW_TRANSFORMSTAGE;
  {$EXTERNALSYM TW_TRANSFORMSTAGE}
  TW_TRANSFORMSTAGE = packed record
    Decode: array[0..2] of TW_DECODEFUNCTION;
    Mix: array[0..2,0..2] of TW_FIX32;
  end;

  TTWTransformStage = TW_TRANSFORMSTAGE;
  PTWTransformStage = pTW_TRANSFORMSTAGE;

{ No DAT needed. Describes version of software currently running. }
  {$EXTERNALSYM pTW_VERSION}
  pTW_VERSION = ^TW_VERSION;
  {$EXTERNALSYM TW_VERSION}
  TW_VERSION = packed record
    MajorNum: TW_UINT16;  { Major revision number of the software. }
    MinorNum: TW_UINT16;  { Incremental revision number of the software. }
    Language: TW_UINT16;  { e.g. TWLG_SWISSFRENCH }
    Country: TW_UINT16;   { e.g. TWCY_SWITZERLAND }
    Info:  TW_STR32;      { e.g. "1.0b3 Beta release" }
  end;

  PTWVersion = pTW_VERSION;
  TTWVersion = TW_VERSION;

{ TWON_ARRAY. Container for array of values (a simplified TW_ENUMERATION) }
  {$EXTERNALSYM pTW_ARRAY}
  pTW_ARRAY = ^TW_ARRAY;
  {$EXTERNALSYM TW_ARRAY}
  TW_ARRAY = packed record
    ItemType: TW_UINT16;
    NumItems: TW_UINT32; { How many items in ItemList }
    ItemList:array[0..1] of TW_UINT8; { Array of ItemType values starts here }
    // UT: ..1 for alignment to 2 Byte Packing, so sizeof is correct
  end;

  TTWArray = TW_ARRAY;
  PTWArray = pTW_ARRAY;


{ TWON_ENUMERATION. Container for a collection of values. }
  {$EXTERNALSYM pTW_ENUMERATION}
  pTW_ENUMERATION = ^TW_ENUMERATION;
  {$EXTERNALSYM TW_ENUMERATION}
  TW_ENUMERATION = packed record
    ItemType: TW_UINT16;
    NumItems: TW_UINT32;     { How many items in ItemList }
    CurrentIndex: TW_UINT32; { Current value is in ItemList[CurrentIndex] }
    DefaultIndex: TW_UINT32; { Powerup value is in ItemList[DefaultIndex] }
    ItemList:array[0..1] of TW_UINT8; { Array of ItemType values starts here }
    // UT: ..1 for alignment to 2 Byte Packing, so sizeof is correct
  end;

  TTWEnumeration = TW_ENUMERATION;
  PTWEnumeration = pTW_ENUMERATION;

{ TWON_ONEVALUE. Container for one value. }
  {$EXTERNALSYM pTW_ONEVALUE}
  pTW_ONEVALUE = ^TW_ONEVALUE;
  {$EXTERNALSYM TW_ONEVALUE}
  TW_ONEVALUE = packed record
    ItemType: TW_UINT16;
    Item: TW_UINT32;
  end;

  TTWOneValue = TW_ONEVALUE;
  PTWOneValue = pTW_ONEVALUE;

{ TWON_RANGE. Container for a range of values. }
  {$EXTERNALSYM pTW_RANGE}
  pTW_RANGE = ^TW_RANGE;
  {$EXTERNALSYM TW_RANGE}
  TW_RANGE = packed record
    ItemType: TW_UINT16;
    MinValue: TW_UINT32;     { Starting value in the range. }
    MaxValue: TW_UINT32;     { Final value in the range. }
    StepSize: TW_UINT32;     { Increment from MinValue to MaxValue. }
    DefaultValue: TW_UINT32; { Power-up value. }
    CurrentValue: TW_UINT32; { The value that is currently in effect. }
  end;

  TTWRange = TW_RANGE;
  PTWRange = pTW_RANGE;

{ DAT_CAPABILITY. Used by application to get/set capability from/in a data source. }
  {$EXTERNALSYM pTW_CAPABILITY}
  pTW_CAPABILITY = ^TW_CAPABILITY;
  {$EXTERNALSYM TW_CAPABILITY}
  TW_CAPABILITY = packed record
    Cap: TW_UINT16;       { id of capability to set or get, e.g. CAP_BRIGHTNESS }
    ConType: TW_UINT16;   { TWON_ONEVALUE, _RANGE, _ENUMERATION or _ARRAY }
    hContainer: TW_HANDLE;{ Handle to container of type Dat }
  end;

  TTWCapability = TW_CAPABILITY;
  PTWCapability = pTW_CAPABILITY;


{ DAT_CIECOLOR. }
  {$EXTERNALSYM pTW_CIECOLOR}
  pTW_CIECOLOR = ^TW_CIECOLOR;
  {$EXTERNALSYM TW_CIECOLOR}
  TW_CIECOLOR = packed record
    ColorSpace: TW_UINT16;
    LowEndian: TW_INT16;
    DeviceDependent: TW_INT16;
    VersionNumber: TW_INT32;
    StageABC: TW_TRANSFORMSTAGE;
    StageLMN: TW_TRANSFORMSTAGE;
    WhitePoint: TW_CIEPOINT;
    BlackPoint: TW_CIEPOINT;
    WhitePaper: TW_CIEPOINT;
    BlackInk: TW_CIEPOINT;
    Samples:array[0..0] of TW_FIX32;
  end;

  TTWCieColor = TW_CIECOLOR;
  PTWCieColor = pTW_CIECOLOR;

{ DAT_EVENT. For passing events down from the application to the DS. }
  {$EXTERNALSYM pTW_EVENT}
  pTW_EVENT = ^TW_EVENT;
  {$EXTERNALSYM TW_EVENT}
  TW_EVENT = packed record
    pEvent: TW_MEMREF;    { Windows pMSG or Mac pEvent. }
    TWMessage: TW_UINT16; { TW msg from data source, e.g. MSG_XFERREADY }
  end;

  TTWEvent = TW_EVENT;
  PTWEvent = pTW_EVENT;

{ DAT_GRAYRESPONSE }
  {$EXTERNALSYM pTW_GRAYRESPONSE}
  pTW_GRAYRESPONSE = ^TW_GRAYRESPONSE;
  {$EXTERNALSYM TW_GRAYRESPONSE}
  TW_GRAYRESPONSE = packed record
    Response:array[0..0] of TW_ELEMENT8;
  end;

  TTWGrayResponse = TW_GRAYRESPONSE;
  PTWGrayResponse = pTW_GRAYRESPONSE;

{ DAT_IDENTITY. Identifies the program/library/code resource. }
  {$EXTERNALSYM pTW_IDENTITY}
  pTW_IDENTITY = ^TW_IDENTITY;
  {$EXTERNALSYM TW_IDENTITY}
  TW_IDENTITY = packed record
    Id: TW_UINT32;             { Unique number. In Windows, application hWnd }
    Version: TW_VERSION ;      { Identifies the piece of code }
    ProtocolMajor: TW_UINT16;  { Application and DS must set to TWON_PROTOCOLMAJOR }
    ProtocolMinor: TW_UINT16;  { Application and DS must set to TWON_PROTOCOLMINOR }
    SupportedGroups: TW_UINT32; { Bit field OR combination of DG_ constants }
    Manufacturer: TW_STR32;   { Manufacturer name, e.g. "Hewlett-Packard" }
    ProductFamily: TW_STR32;  { Product family name, e.g. "ScanJet" }
    ProductName: TW_STR32;    { Product name, e.g. "ScanJet Plus" }
  end;

  TTWIdentity = TW_IDENTITY;
  PTWIdentity = pTW_IDENTITY;

{ DAT_IMAGEINFO. Application gets detailed image info from DS with this. }
  {$EXTERNALSYM pTW_IMAGEINFO}
  pTW_IMAGEINFO = ^TW_IMAGEINFO;
  {$EXTERNALSYM TW_IMAGEINFO}
  TW_IMAGEINFO = packed record
    XResolution: TW_FIX32;   { Resolution in the horizontal }
    YResolution: TW_FIX32;   { Resolution in the vertical }
    ImageWidth: TW_INT32;    { Columns in the image, -1 if unknown by DS }
    ImageLength: TW_INT32;   { Rows in the image, -1 if unknown by DS }
    SamplesPerPixel: TW_INT16; { Number of samples per pixel, 3 for RGB }
    BitsPerSample:array[0..7] of TW_INT16 ; { Number of bits for each sample }
    BitsPerPixel: TW_INT16;  { Number of bits for each padded pixel }
    Planar: TW_BOOL;         { True if Planar, False if chunky }
    PixelType: TW_INT16;     { How to interp data: ; photo interp (TWPT_) }
    Compression: TW_UINT16;  { How the data is compressed (TWCP_xxxx) }
  end;

  TTWImageInfo = TW_IMAGEINFO;
  PTWImageInfo = pTW_IMAGEINFO;

{ DAT_IMAGELAYOUT. Provides image layout information in current units. }
  {$EXTERNALSYM pTW_IMAGELAYOUT}
  pTW_IMAGELAYOUT = ^TW_IMAGELAYOUT;
  {$EXTERNALSYM TW_IMAGELAYOUT}
  TW_IMAGELAYOUT = packed record
    Frame: TW_FRAME;     { Frame coords within larger document }
    DocumentNumber: TW_UINT32;
    PageNumber: TW_UINT32;   { Reset when you go to next document }
    FrameNumber: TW_UINT32;  { Reset when you go to next page }
  end;

  TTWImageLayout = TW_IMAGELAYOUT;
  PTWImageLayout = pTW_IMAGELAYOUT;

{ DAT_IMAGEMEMXFER. Used to pass image data (e.g. in strips) from DS to application. }
  {$EXTERNALSYM pTW_IMAGEMEMXFER}
  pTW_IMAGEMEMXFER = ^TW_IMAGEMEMXFER;
  {$EXTERNALSYM TW_IMAGEMEMXFER}
  TW_IMAGEMEMXFER = packed record
    Compression: TW_UINT16; { How the data is compressed }
    BytesPerRow: TW_UINT32; { Number of bytes in a row of data }
    Columns: TW_UINT32;     { How many columns }
    Rows: TW_UINT32;        { How many rows }
    XOffset: TW_UINT32;     { How far from the side of the image }
    YOffset: TW_UINT32;     { How far from the top of the image }
    BytesWritten: TW_UINT32;{ How many bytes written in Memory }
    Memory: TW_MEMORY;      { Mem struct used to pass actual image data }
  end;

  TTWImageMemXFER = TW_IMAGEMEMXFER;
  PTWImageMemXFER = pTW_IMAGEMEMXFER;

{ Changed in 1.1: QuantTable, HuffmanDC, HuffmanAC TW_MEMREF -> TW_MEMORY }
{ DAT_JPEGCOMPRESSION. Based on JPEG Draft International Std, ver 10918-1. }
  {$EXTERNALSYM pTW_JPEGCOMPRESSION}
  pTW_JPEGCOMPRESSION = ^TW_JPEGCOMPRESSION;
  {$EXTERNALSYM TW_JPEGCOMPRESSION}
  TW_JPEGCOMPRESSION = packed record
    ColorSpace: TW_UINT16;    { One of the TWPT_xxxx values }
    SubSampling: TW_UINT32;   { Two word "array" for subsampling values }
    NumComponents: TW_UINT16;  { Number of color components in image }
    RestartFrequency: TW_UINT16; { Frequency of restart marker codes in MDU's }
    QuantMap:array[0..3] of TW_UINT16;   { Mapping of components to QuantTables }
    QuantTable:array[0..3] of TW_MEMORY;  { Quantization tables }
    HuffmanMap:array[0..3] of TW_UINT16;  { Mapping of components to Huffman tables }
    HuffmanDC:array[0..1] of TW_MEMORY;   { DC Huffman tables }
    HuffmanAC:array[0..1] of TW_MEMORY;   { AC Huffman tables }
  end;

  TTWJPEGCompression = TW_JPEGCOMPRESSION;
  PTWJPEGCompression = pTW_JPEGCOMPRESSION;

{ DAT_PALETTE8. Color palette when TWPT_PALETTE pixels xfer'd in mem buf. }
  {$EXTERNALSYM pTW_PALETTE8}
  pTW_PALETTE8 = ^TW_PALETTE8;
  {$EXTERNALSYM TW_PALETTE8}
  TW_PALETTE8 = packed record
     NumColors: TW_UINT16;  { Number of colors in the color table. }
     PaletteType: TW_UINT16; { TWPA_xxxx, specifies type of palette. }
     Colors:array[0..255] of TW_ELEMENT8; { Array of palette values starts here. }
  end;

  TTWPalette8 = TW_PALETTE8;
  PTWPalette8 = pTW_PALETTE8;

{ DAT_PENDINGXFERS. Used with MSG_ENDXFER to indicate additional data. }
  {$EXTERNALSYM pTW_PENDINGXFERS}
  pTW_PENDINGXFERS = ^TW_PENDINGXFERS;
  {$EXTERNALSYM TW_PENDINGXFERS}
  TW_PENDINGXFERS = packed record
    Count: TW_UINT16;
    case boolean of
      false: (EOJ: TW_UINT32);
      true: ( Reserved: TW_UINT32);
  end;

  TTWPendingXFERS = TW_PENDINGXFERS;
  PTWPendingXFERS = pTW_PENDINGXFERS;


{ DAT_RGBRESPONSE }
  {$EXTERNALSYM pTW_RGBRESPONSE}
  pTW_RGBRESPONSE = ^TW_RGBRESPONSE;
  {$EXTERNALSYM TW_RGBRESPONSE}
  TW_RGBRESPONSE = packed record
    Response:array[0..0] of TW_ELEMENT8;
  end;

  TTWRGBResponse = TW_RGBRESPONSE;
  PTWRGBResponse = pTW_RGBRESPONSE;

{ DAT_SETUPFILEXFER. Sets up DS to application data transfer via a file. }
  {$EXTERNALSYM pTW_SETUPFILEXFER}
  pTW_SETUPFILEXFER = ^TW_SETUPFILEXFER;
  {$EXTERNALSYM TW_SETUPFILEXFER}
  TW_SETUPFILEXFER = packed record
    FileName: TW_STR255;
    Format: TW_UINT16;  { Any TWFF_ constant }
    VRefNum: TW_INT16; { Used for Mac only }
  end;

  TTWSetupFileXFER = TW_SETUPFILEXFER;
  PTWSetupFileXFER = pTW_SETUPFILEXFER;


{ DAT_SETUPMEMXFER. Sets up DS to application data transfer via a memory buffer. }
  {$EXTERNALSYM pTW_SETUPMEMXFER}
  pTW_SETUPMEMXFER = ^TW_SETUPMEMXFER;
  {$EXTERNALSYM TW_SETUPMEMXFER}
  TW_SETUPMEMXFER = packed record
    MinBufSize: TW_UINT32;
    MaxBufSize: TW_UINT32;
    Preferred: TW_UINT32;
  end;

  TTWSetupMemXFER = TW_SETUPMEMXFER;
  PTWSetupMemXFER = pTW_SETUPMEMXFER;

{ DAT_STATUS. Application gets detailed status info from a data source with this. }
  {$EXTERNALSYM pTW_STATUS}
  pTW_STATUS = ^TW_STATUS;
  {$EXTERNALSYM TW_STATUS}
  TW_STATUS = packed record
    ConditionCode: TW_UINT16; { Any TWCC_ constant }
    Reserved: TW_UINT16;      { Future expansion space }
  end;

  TTWStatus = TW_STATUS;
  PTWStatus = pTW_STATUS;

{ DAT_USERINTERFACE. Coordinates UI between application and data source. }
  {$EXTERNALSYM pTW_USERINTERFACE}
  pTW_USERINTERFACE = ^TW_USERINTERFACE;
  {$EXTERNALSYM TW_USERINTERFACE}
  TW_USERINTERFACE = packed record
    ShowUI: TW_BOOL;    { TRUE if DS should bring up its UI }
    ModalUI: TW_BOOL;   { For Mac only - true if the DS's UI is modal }
    hParent: TW_HANDLE; { For windows only - Application window handle }
  end;

  TTWUserInterface = TW_USERINTERFACE;
  PTWUserInterface = pTW_USERINTERFACE;

{ SDH - 03/21/95 - TWUNK }
{ DAT_TWUNKIDENTITY. Provides DS identity and 'other' information necessary }
{          across thunk link. }
  {$EXTERNALSYM pTW_TWUNKIDENTITY}
  pTW_TWUNKIDENTITY = ^TW_TWUNKIDENTITY;
  {$EXTERNALSYM TW_TWUNKIDENTITY}
  TW_TWUNKIDENTITY = packed record
    identity: TW_IDENTITY;  { Identity of data source. }
    dsPath: TW_STR255;      { Full path and file name of data source. }
  end;

  TTWTwunkIdentity = TW_TWUNKIDENTITY;
  PTWTwunkIdentity = pTW_TWUNKIDENTITY;

{ SDH - 03/21/95 - TWUNK }
{ Provides DS_Entry parameters over thunk link. }
  {$EXTERNALSYM pTW_TWUNKDSENTRYPARAMS}
  pTW_TWUNKDSENTRYPARAMS = ^TW_TWUNKDSENTRYPARAMS;
  {$EXTERNALSYM TW_TWUNKDSENTRYPARAMS}
  TW_TWUNKDSENTRYPARAMS = packed record
    destFlag: TW_INT8;      { TRUE if dest is not NULL }
    alignment: TW_INT8;  // UT: Packed to two byte alignment
    dest: TW_IDENTITY;      { Identity of data source (if used) }
    dataGroup: TW_INT32;    { DSM_Entry dataGroup parameter }
    dataArgType: TW_INT16;  { DSM_Entry dataArgType parameter }
    message: TW_INT16;      { DSM_Entry message parameter }
    pDataSize: TW_INT32;    { Size of pData (0 if NULL) }
    //pData: TW_MEMREF;     { Based on implementation specifics, a }
                            { pData parameter makes no sense in this }
                            { structure, but data (if provided) will be }
                            { appended in the data block. }
  end;

  TTWTwunkDSEntryParams = TW_TWUNKDSENTRYPARAMS;
  PTWTwunkDSEntryParams = pTW_TWUNKDSENTRYPARAMS;

{ SDH - 03/21/95 - TWUNK }
{ Provides DS_Entry results over thunk link. }
  {$EXTERNALSYM pTW_TWUNKDSENTRYRETURN}
  pTW_TWUNKDSENTRYRETURN = ^TW_TWUNKDSENTRYRETURN;
  {$EXTERNALSYM TW_TWUNKDSENTRYRETURN}
  TW_TWUNKDSENTRYRETURN = packed record
    returnCode: TW_UINT16;    { Thunker DsEntry return code. }
    conditionCode: TW_UINT16; { Thunker DsEntry condition code. }
    pDataSize: TW_INT32;      { Size of pData (0 if NULL) }
    //pData: TW_MEMREF;       { Based on implementation specifics, a }
                              { pData parameter makes no sense in this }
                              { structure, but data (if provided) will be }
                              { appended in the data block. }
  end;

  TTWTwunkDSEntryReturn = TW_TWUNKDSENTRYRETURN;
  PTWTwunkDSEntryReturn = pTW_TWUNKDSENTRYRETURN;

{ WJD - 950818 }
{ Added for 1.6 Specification }
{ TWAIN 1.6 CAP_SUPPORTEDCAPSEXT structure }
  {$EXTERNALSYM pTW_CAPEXT}
  pTW_CAPEXT = ^TW_CAPEXT;
  {$EXTERNALSYM TW_CAPEXT}
  TW_CAPEXT = packed record
    Cap: TW_UINT16;  { Which CAP/ICAP info is relevant to }
    Properties: TW_UINT16;  { Messages this CAP/ICAP supports }
  end;

  TTWCapExt = TW_CAPEXT;
  PTWCapExt = pTW_CAPEXT;

{ -----------------------------------------------------------------------

  Version 1.7:   Added Following data structure for Document Imaging
  July 1997     Enhancement.
  KHL        TW_CUSTOMDSDATA -- For Saving and Restoring Source's
                      state.
            TW_INFO     -- Each attribute for extended image
                      information.
            TW_EXTIMAGEINFO -- Extended image information structure.

  ----------------------------------------------------------------------- }

  {$EXTERNALSYM pTW_CUSTOMDSDATA}
  pTW_CUSTOMDSDATA = ^TW_CUSTOMDSDATA;
  {$EXTERNALSYM TW_CUSTOMDSDATA}
  TW_CUSTOMDSDATA = packed record
    InfoLength: TW_UINT32; { Length of Information in bytes. }
    hData: TW_HANDLE;      { Place holder for data, DS Allocates }
  end;

  TTWCustomDSData = TW_CUSTOMDSDATA;
  PTWCustomDSData = pTW_CUSTOMDSDATA;

  {$EXTERNALSYM pTW_INFO}
  pTW_INFO = ^TW_INFO;
  {$EXTERNALSYM TW_INFO}
  TW_INFO = packed record
    InfoID: TW_UINT16;
    ItemType: TW_UINT16;
    NumItems: TW_UINT16;
    CondCode: TW_UINT16;
    Item: TW_UINT32;
  end;

  TTWInfo = TW_INFO;
  PTWInfo = pTW_INFO;

  {$EXTERNALSYM pTW_EXTIMAGEINFO}
  pTW_EXTIMAGEINFO = ^TW_EXTIMAGEINFO;
  {$EXTERNALSYM TW_EXTIMAGEINFO}
  TW_EXTIMAGEINFO = packed record
    NumInfos: TW_UINT32;
    Info:array[0..0] of TW_INFO;
  end;

  TTWExtImageInfo = TW_EXTIMAGEINFO;
  PTWExtImageInfo = pTW_EXTIMAGEINFO;

{ Added 1.8 }

{ DAT_AUDIOINFO, information about audio data }
  {$EXTERNALSYM pTW_AUDIOINFO}
  pTW_AUDIOINFO = ^TW_AUDIOINFO;
  {$EXTERNALSYM TW_AUDIOINFO}
  TW_AUDIOINFO = packed record
    Name: TW_STR255;      { name of audio data }
    Reserved: TW_UINT32;  { reserved space }
  end;

  TTWAudioInfo = TW_AUDIOINFO;
  PTWAudioInfo = pTW_AUDIOINFO;

{ DAT_DEVICEEVENT, information about events }
  {$EXTERNALSYM pTW_DEVICEEVENT}
  pTW_DEVICEEVENT = ^TW_DEVICEEVENT;
  {$EXTERNALSYM TW_DEVICEEVENT}
  TW_DEVICEEVENT = packed record
    Event: TW_UINT32;            { One of the TWDE_xxxx values. }
    DeviceName: TW_STR255;       { The name of the device that generated the event }
    BatteryMinutes: TW_UINT32;   { Battery Minutes Remaining }
    BatteryPercentage: TW_INT16; { Battery Percentage Remaining }
    PowerSupply: TW_INT32;       { Power Supply }
    XResolution: TW_FIX32;       { Resolution }
    YResolution: TW_FIX32;       { Resolution }
    FlashUsed2: TW_UINT32;       { Flash Used2 }
    AutomaticCapture: TW_UINT32; { Automatic Capture }
    TimeBeforeFirstCapture: TW_UINT32; { Automatic Capture }
    TimeBetweenCaptures: TW_UINT32;   { Automatic Capture }
  end;

  TTWDeviceEvent = TW_DEVICEEVENT;
  PTWDeviceEvent = pTW_DEVICEEVENT;

{ DAT_FILESYSTEM, information about TWAIN file system }
  {$EXTERNALSYM pTW_FILESYSTEM}
  pTW_FILESYSTEM = ^TW_FILESYSTEM;
  {$EXTERNALSYM TW_FILESYSTEM}
  TW_FILESYSTEM = packed record
    { DG_CONTROL / DAT_FILESYSTEM / MSG_xxxx fields }
    InputName: TW_STR255;      { The name of the input or source file }
    OutputName: TW_STR255;     { The result of an operation or the name of a destination file }
    Context: TW_MEMREF;        { Source specific data used to remember state information }
    { DG_CONTROL / DAT_FILESYSTEM / MSG_DELETE field }
    Recursive: integer;{int}   { recursively delete all sub-directories }
    { DG_CONTROL / DAT_FILESYSTEM / MSG_GETINFO fields }
    FileType: TW_INT32;        { One of the TWFT_xxxx values }
    Size: TW_UINT32;           { Size of current FileType }
    CreateTimeDate: TW_STR32;  { creation date of the file }
    ModifiedTimeDate: TW_STR32;{ last date the file was modified }
    FreeSpace: TW_UINT32;      { bytes of free space on the current device }
    NewImageSize: TW_INT32;    { estimate of the amount of space a new image would take up }
    NumberOfFiles: TW_UINT32;  { number of files, depends on FileType }
    NumberOfSnippets: TW_UINT32;  { }
    Reserved:array[0..511] of char; { }
  end;

  TTWFileSystem = TW_FILESYSTEM;
  PTWFileSystem = pTW_FILESYSTEM;

{ DAT_PASSTHRU, device dependant data to pass through Data Source }
  {$EXTERNALSYM pTW_PASSTHRU}
  pTW_PASSTHRU = ^TW_PASSTHRU;
  {$EXTERNALSYM TW_PASSTHRU}
  TW_PASSTHRU = packed record
    pCommand: TW_MEMREF;        { Pointer to Command buffer }
    CommandBytes:TW_UINT32;     { Number of bytes in Command buffer }
    Direction: TW_INT32;        { One of the TWDR_xxxx values. Defines the direction of data flow }
    pData: TW_MEMREF;           { Pointer to Data buffer }
    DataBytes: TW_UINT32;       { Number of bytes in Data buffer }
    DataBytesXfered: TW_UINT32; { Number of bytes successfully transferred }
  end;

  TTWPassThru = TW_PASSTHRU;
  PTWPassThru = pTW_PASSTHRU;

{ DAT_SETUPAUDIOFILEXFER, information required to setup an audio file transfer }
  {$EXTERNALSYM pTW_SETUPAUDIOFILEXFER}
  pTW_SETUPAUDIOFILEXFER = ^TW_SETUPAUDIOFILEXFER;
  {$EXTERNALSYM TW_SETUPAUDIOFILEXFER}
  TW_SETUPAUDIOFILEXFER = packed record
    FileName: TW_STR255; { full path target file }
    Format: TW_UINT16;   { one of TWAF_xxxx }
    VRefNum: TW_INT16;
  end;

  TTWSetupAudioFileXFER = TW_SETUPAUDIOFILEXFER;
  PTWSetupAudioFileXFER = pTW_SETUPAUDIOFILEXFER;

{***************************************************************************
 * Generic Constants                                                       *
 *************************************************************************** }
const
  {$EXTERNALSYM TWON_ARRAY}
  TWON_ARRAY        = 3; { indicates TW_ARRAY container }
  {$EXTERNALSYM TWON_ENUMERATION}
  TWON_ENUMERATION  = 4; { indicates TW_ENUMERATION container }
  {$EXTERNALSYM TWON_ONEVALUE}
  TWON_ONEVALUE     = 5; { indicates TW_ONEVALUE container }
  {$EXTERNALSYM TWON_RANGE}
  TWON_RANGE        = 6; { indicates TW_RANGE container }

  {$EXTERNALSYM TWON_ICONID}
  TWON_ICONID     = 962; { res Id of icon used in USERSELECT lbox }
  {$EXTERNALSYM TWON_DSMID}
  TWON_DSMID      = 461; { res Id of the DSM version num resource }
  {$EXTERNALSYM TWON_DSMCODEID}
  TWON_DSMCODEID  = 63;  { res Id of the Mac SM Code resource }

  {$EXTERNALSYM TWON_DONTCARE8}
  TWON_DONTCARE8    = $ff;
  {$EXTERNALSYM TWON_DONTCARE16}
  TWON_DONTCARE16   = $ffff;
  {$EXTERNALSYM TWON_DONTCARE32}
  TWON_DONTCARE32   = $ffffffff;

{ Flags used in TW_MEMORY structure. }
  {$EXTERNALSYM TWMF_APPOWNS}
  TWMF_APPOWNS   = $1;
  {$EXTERNALSYM TWMF_DSMOWNS}
  TWMF_DSMOWNS   = $2;
  {$EXTERNALSYM TWMF_DSOWNS}
  TWMF_DSOWNS    = $4;
  {$EXTERNALSYM TWMF_POINTER}
  TWMF_POINTER   = $8;
  {$EXTERNALSYM TWMF_HANDLE}
  TWMF_HANDLE    = $10;

{ Palette types for TW_PALETTE8 }
  {$EXTERNALSYM TWPA_RGB}
  TWPA_RGB     = 0;
  {$EXTERNALSYM TWPA_GRAY}
  TWPA_GRAY    = 1;
  {$EXTERNALSYM TWPA_CMY}
  TWPA_CMY     = 2;

{ There are four containers used for capabilities negotiation:
 *  TWON_ONEVALUE, TWON_RANGE, TWON_ENUMERATION, TWON_ARRAY
 * In each container structure ItemType can be TWTY_INT8, TWTY_INT16, etc.
 * The kind of data stored in the container can be determined by doing
 * DCItemSize[ItemType] where the following is defined in TWAIN glue code:
 *     DCItemSize[]=  sizeof(TW_INT8),
 *             sizeof(TW_INT16),
 *             etc.
 *             sizeof(TW_UINT32) : ;
 *
  }

  {$EXTERNALSYM TWTY_INT8}
  TWTY_INT8     = $0000;  { Means Item is a TW_INT8 }
  {$EXTERNALSYM TWTY_INT16}
  TWTY_INT16    = $0001;  { Means Item is a TW_INT16 }
  {$EXTERNALSYM TWTY_INT32}
  TWTY_INT32    = $0002;  { Means Item is a TW_INT32 }

  {$EXTERNALSYM TWTY_UINT8}
  TWTY_UINT8    = $0003;  { Means Item is a TW_UINT8 }
  {$EXTERNALSYM TWTY_UINT16}
  TWTY_UINT16   = $0004;  { Means Item is a TW_UINT16 }
  {$EXTERNALSYM TWTY_UINT32}
  TWTY_UINT32   = $0005;  { Means Item is a TW_UINT32 }

  {$EXTERNALSYM TWTY_BOOL}
  TWTY_BOOL     = $0006;  { Means Item is a TW_BOOL }

  {$EXTERNALSYM TWTY_FIX32}
  TWTY_FIX32    = $0007;  { Means Item is a TW_FIX32 }

  {$EXTERNALSYM TWTY_FRAME}
  TWTY_FRAME    = $0008;  { Means Item is a TW_FRAME }

  {$EXTERNALSYM TWTY_STR32}
  TWTY_STR32    = $0009;  { Means Item is a TW_STR32 }
  {$EXTERNALSYM TWTY_STR64}
  TWTY_STR64    = $000a;  { Means Item is a TW_STR64 }
  {$EXTERNALSYM TWTY_STR128}
  TWTY_STR128   = $000b;  { Means Item is a TW_STR128 }
  {$EXTERNALSYM TWTY_STR255}
  TWTY_STR255   = $000c;  { Means Item is a TW_STR255 }

{***************************************************************************
 * Capability Constants                                                    *
 *************************************************************************** }

{ ICAP_BITORDER values (BO_ means Bit Order) }
  {$EXTERNALSYM TWBO_LSBFIRST}
  TWBO_LSBFIRST  = 0;
  {$EXTERNALSYM TWBO_MSBFIRST}
  TWBO_MSBFIRST  = 1;

{ ICAP_COMPRESSION values (CP_ means ComPression ) }
  {$EXTERNALSYM TWCP_NONE}
  TWCP_NONE       = 0;
  {$EXTERNALSYM TWCP_PACKBITS}
  TWCP_PACKBITS   = 1;
  {$EXTERNALSYM TWCP_GROUP31D}
  TWCP_GROUP31D   = 2;  { Follows CCITT spec (no End Of Line) }
  {$EXTERNALSYM TWCP_GROUP31DEOL}
  TWCP_GROUP31DEOL= 3;  { Follows CCITT spec (has End Of Line) }
  {$EXTERNALSYM TWCP_GROUP32D}
  TWCP_GROUP32D   = 4;  { Follows CCITT spec (use cap for K Factor) }
  {$EXTERNALSYM TWCP_GROUP4}
  TWCP_GROUP4     = 5;  { Follows CCITT spec }
  {$EXTERNALSYM TWCP_JPEG}
  TWCP_JPEG       = 6;  { Use capability for more info }
  {$EXTERNALSYM TWCP_LZW}
  TWCP_LZW        = 7;  { Must license from Unisys and IBM to use }
  {$EXTERNALSYM TWCP_JBIG}
  TWCP_JBIG       = 8;  { For Bitonal images -- Added 1.7 KHL }

{ Added 1.8 }
  {$EXTERNALSYM TWCP_PNG}
  TWCP_PNG     = 9;
  {$EXTERNALSYM TWCP_RLE4}
  TWCP_RLE4    = 10;
  {$EXTERNALSYM TWCP_RLE8}
  TWCP_RLE8    = 11;
  {$EXTERNALSYM TWCP_BITFIELDS}
  TWCP_BITFIELDS  = 12;


{ ICAP_IMAGEFILEFORMAT values (FF_means File Format) }
  {$EXTERNALSYM TWFF_TIFF}
  TWFF_TIFF    = 0;   { Tagged Image File Format }
  {$EXTERNALSYM TWFF_PICT}
  TWFF_PICT    = 1;   { Macintosh PICT }
  {$EXTERNALSYM TWFF_BMP}
  TWFF_BMP     = 2;   { Windows Bitmap }
  {$EXTERNALSYM TWFF_XBM}
  TWFF_XBM     = 3;   { X-Windows Bitmap }
  {$EXTERNALSYM TWFF_JFIF}
  TWFF_JFIF    = 4;   { JPEG File Interchange Format }
  {$EXTERNALSYM TWFF_FPX}
  TWFF_FPX     = 5;   { Flash Pix }
  {$EXTERNALSYM TWFF_TIFFMULTI}
  TWFF_TIFFMULTI= 6;  { Multi-page tiff file }
  {$EXTERNALSYM TWFF_PNG}
  TWFF_PNG     = 7;
  {$EXTERNALSYM TWFF_SPIFF}
  TWFF_SPIFF    = 8;
  {$EXTERNALSYM TWFF_EXIF}
  TWFF_EXIF    = 9;


{ ICAP_FILTER values (FT_ means Filter Type) }
  {$EXTERNALSYM TWFT_RED}
  TWFT_RED     = 0;
  {$EXTERNALSYM TWFT_GREEN}
  TWFT_GREEN   = 1;
  {$EXTERNALSYM TWFT_BLUE}
  TWFT_BLUE    = 2;
  {$EXTERNALSYM TWFT_NONE}
  TWFT_NONE    = 3;
  {$EXTERNALSYM TWFT_WHITE}
  TWFT_WHITE   = 4;
  {$EXTERNALSYM TWFT_CYAN}
  TWFT_CYAN    = 5;
  {$EXTERNALSYM TWFT_MAGENTA}
  TWFT_MAGENTA = 6;
  {$EXTERNALSYM TWFT_YELLOW}
  TWFT_YELLOW  = 7;
  {$EXTERNALSYM TWFT_BLACK}
  TWFT_BLACK   = 8;

{ ICAP_LIGHTPATH values (LP_ means Light Path) }
  {$EXTERNALSYM TWLP_REFLECTIVE}
  TWLP_REFLECTIVE   = 0;
  {$EXTERNALSYM TWLP_TRANSMISSIVE}
  TWLP_TRANSMISSIVE = 1;

{ ICAP_LIGHTSOURCE values (LS_ means Light Source) }
  {$EXTERNALSYM TWLS_RED}
  TWLS_RED     = 0;
  {$EXTERNALSYM TWLS_GREEN}
  TWLS_GREEN   = 1;
  {$EXTERNALSYM TWLS_BLUE}
  TWLS_BLUE    = 2;
  {$EXTERNALSYM TWLS_NONE}
  TWLS_NONE    = 3;
  {$EXTERNALSYM TWLS_WHITE}
  TWLS_WHITE   = 4;
  {$EXTERNALSYM TWLS_UV}
  TWLS_UV      = 5;
  {$EXTERNALSYM TWLS_IR}
  TWLS_IR      = 6;

{ ICAP_ORIENTATION values (OR_ means ORientation) }
  {$EXTERNALSYM TWOR_ROT0}
  TWOR_ROT0     = 0;
  {$EXTERNALSYM TWOR_ROT90}
  TWOR_ROT90    = 1;
  {$EXTERNALSYM TWOR_ROT180}
  TWOR_ROT180   = 2;
  {$EXTERNALSYM TWOR_ROT270}
  TWOR_ROT270   = 3;
  {$EXTERNALSYM TWOR_PORTRAIT}
  TWOR_PORTRAIT = TWOR_ROT0;
  {$EXTERNALSYM TWOR_LANDSCAPE}
  TWOR_LANDSCAPE= TWOR_ROT270;

{ ICAP_PLANARCHUNKY values (PC_ means Planar/Chunky ) }
  {$EXTERNALSYM TWPC_CHUNKY}
  TWPC_CHUNKY   = 0;
  {$EXTERNALSYM TWPC_PLANAR}
  TWPC_PLANAR   = 1;

{ ICAP_PIXELFLAVOR values (PF_ means Pixel Flavor) }
  {$EXTERNALSYM TWPF_CHOCOLATE}
  TWPF_CHOCOLATE = 0; { zero pixel represents darkest shade }
  {$EXTERNALSYM TWPF_VANILLA}
  TWPF_VANILLA   = 1; { zero pixel represents lightest shade }

{ ICAP_PIXELTYPE values (PT_ means Pixel Type) }
  {$EXTERNALSYM TWPT_BW}
  TWPT_BW      = 0; { Black and White }
  {$EXTERNALSYM TWPT_GRAY}
  TWPT_GRAY    = 1;
  {$EXTERNALSYM TWPT_RGB}
  TWPT_RGB     = 2;
  {$EXTERNALSYM TWPT_PALETTE}
  TWPT_PALETTE = 3;
  {$EXTERNALSYM TWPT_CMY}
  TWPT_CMY     = 4;
  {$EXTERNALSYM TWPT_CMYK}
  TWPT_CMYK    = 5;
  {$EXTERNALSYM TWPT_YUV}
  TWPT_YUV     = 6;
  {$EXTERNALSYM TWPT_YUVK}
  TWPT_YUVK    = 7;
  {$EXTERNALSYM TWPT_CIEXYZ}
  TWPT_CIEXYZ  = 8;

{ ICAP_SUPPORTEDSIZES values (SS_ means Supported Sizes) }
  {$EXTERNALSYM TWSS_NONE}
  TWSS_NONE      = 0;
  {$EXTERNALSYM TWSS_A4LETTER}
  TWSS_A4LETTER  = 1;
  {$EXTERNALSYM TWSS_B5LETTER}
  TWSS_B5LETTER  = 2;
  {$EXTERNALSYM TWSS_USLETTER}
  TWSS_USLETTER  = 3;
  {$EXTERNALSYM TWSS_USLEGAL}
  TWSS_USLEGAL   = 4;
{ Added 1.5 }
  {$EXTERNALSYM TWSS_A5}
  TWSS_A5        = 5;
  {$EXTERNALSYM TWSS_B4}
  TWSS_B4        = 6;
  {$EXTERNALSYM TWSS_B6}
  TWSS_B6        = 7;
// TWSS_B        =  8;

{ Added 1.7 }
  {$EXTERNALSYM TWSS_USLEDGER}
  TWSS_USLEDGER    = 9;
  {$EXTERNALSYM TWSS_USEXECUTIVE}
  TWSS_USEXECUTIVE = 10;
  {$EXTERNALSYM TWSS_A3}
  TWSS_A3          = 11;
  {$EXTERNALSYM TWSS_B3}
  TWSS_B3          = 12;
  {$EXTERNALSYM TWSS_A6}
  TWSS_A6          = 13;
  {$EXTERNALSYM TWSS_C4}
  TWSS_C4          = 14;
  {$EXTERNALSYM TWSS_C5}
  TWSS_C5          = 15;
  {$EXTERNALSYM TWSS_C6}
  TWSS_C6          = 16;

{ Added 1.8 }
  {$EXTERNALSYM TWSS_4A0}
  TWSS_4A0         = 17;
  {$EXTERNALSYM TWSS_2A0}
  TWSS_2A0         = 18;
  {$EXTERNALSYM TWSS_A0}
  TWSS_A0          = 19;
  {$EXTERNALSYM TWSS_A1}
  TWSS_A1          = 20;
  {$EXTERNALSYM TWSS_A2}
  TWSS_A2          = 21;
  {$EXTERNALSYM TWSS_A4}
  TWSS_A4          = TWSS_A4LETTER;
  {$EXTERNALSYM TWSS_A7}
  TWSS_A7          = 22;
  {$EXTERNALSYM TWSS_A8}
  TWSS_A8          = 23;
  {$EXTERNALSYM TWSS_A9}
  TWSS_A9          = 24;
  {$EXTERNALSYM TWSS_A10}
  TWSS_A10         = 25;
  {$EXTERNALSYM TWSS_ISOB0}
  TWSS_ISOB0       = 26;
  {$EXTERNALSYM TWSS_ISOB1}
  TWSS_ISOB1       = 27;
  {$EXTERNALSYM TWSS_ISOB2}
  TWSS_ISOB2       = 28;
  {$EXTERNALSYM TWSS_ISOB3}
  TWSS_ISOB3       = TWSS_B3;
  {$EXTERNALSYM TWSS_ISOB4}
  TWSS_ISOB4       = TWSS_B4;
  {$EXTERNALSYM TWSS_ISOB5}
  TWSS_ISOB5       = 29;
  {$EXTERNALSYM TWSS_ISOB6}
  TWSS_ISOB6       = TWSS_B6;
  {$EXTERNALSYM TWSS_ISOB7}
  TWSS_ISOB7       = 30;
  {$EXTERNALSYM TWSS_ISOB8}
  TWSS_ISOB8       = 31;
  {$EXTERNALSYM TWSS_ISOB9}
  TWSS_ISOB9       = 32;
  {$EXTERNALSYM TWSS_ISOB10}
  TWSS_ISOB10      = 33;
  {$EXTERNALSYM TWSS_JISB0}
  TWSS_JISB0       = 34;
  {$EXTERNALSYM TWSS_JISB1}
  TWSS_JISB1       = 35;
  {$EXTERNALSYM TWSS_JISB2}
  TWSS_JISB2       = 36;
  {$EXTERNALSYM TWSS_JISB3}
  TWSS_JISB3       = 37;
  {$EXTERNALSYM TWSS_JISB4}
  TWSS_JISB4       = 38;
  {$EXTERNALSYM TWSS_JISB5}
  TWSS_JISB5       = TWSS_B5LETTER;
  {$EXTERNALSYM TWSS_JISB6}
  TWSS_JISB6       = 39;
  {$EXTERNALSYM TWSS_JISB7}
  TWSS_JISB7       = 40;
  {$EXTERNALSYM TWSS_JISB8}
  TWSS_JISB8       = 41;
  {$EXTERNALSYM TWSS_JISB9}
  TWSS_JISB9       = 42;
  {$EXTERNALSYM TWSS_JISB10}
  TWSS_JISB10      = 43;
  {$EXTERNALSYM TWSS_C0}
  TWSS_C0          = 44;
  {$EXTERNALSYM TWSS_C1}
  TWSS_C1          = 45;
  {$EXTERNALSYM TWSS_C2}
  TWSS_C2          = 46;
  {$EXTERNALSYM TWSS_C3}
  TWSS_C3          = 47;
  {$EXTERNALSYM TWSS_C7}
  TWSS_C7          = 48;
  {$EXTERNALSYM TWSS_C8}
  TWSS_C8          = 49;
  {$EXTERNALSYM TWSS_C9}
  TWSS_C9          = 50;
  {$EXTERNALSYM TWSS_C10}
  TWSS_C10         = 51;
  {$EXTERNALSYM TWSS_USSTATEMENT}
  TWSS_USSTATEMENT = 52;
  {$EXTERNALSYM TWSS_BUSINESSCARD}
  TWSS_BUSINESSCARD= 53;

{ ICAP_XFERMECH values (SX_ means Setup XFer) }
  {$EXTERNALSYM TWSX_NATIVE}
  TWSX_NATIVE  = 0;
  {$EXTERNALSYM TWSX_FILE}
  TWSX_FILE    = 1;
  {$EXTERNALSYM TWSX_MEMORY}
  TWSX_MEMORY  = 2;

{ ICAP_UNITS values (UN_ means UNits) }
  {$EXTERNALSYM TWUN_INCHES}
  TWUN_INCHES      = 0;
  {$EXTERNALSYM TWUN_CENTIMETERS}
  TWUN_CENTIMETERS = 1;
  {$EXTERNALSYM TWUN_PICAS}
  TWUN_PICAS       = 2;
  {$EXTERNALSYM TWUN_POINTS}
  TWUN_POINTS      = 3;
  {$EXTERNALSYM TWUN_TWIPS}
  TWUN_TWIPS       = 4;
  {$EXTERNALSYM TWUN_PIXELS}
  TWUN_PIXELS      = 5;

{ Added 1.5 }
{ ICAP_BITDEPTHREDUCTION values (BR_ means Bitdepth Reduction) }
  {$EXTERNALSYM TWBR_THRESHOLD}
  TWBR_THRESHOLD    = 0;
  {$EXTERNALSYM TWBR_HALFTONE}
  TWBR_HALFTONE     = 1;
  {$EXTERNALSYM TWBR_CUSTHALFTONE}
  TWBR_CUSTHALFTONE = 2;
  {$EXTERNALSYM TWBR_DIFFUSION}
  TWBR_DIFFUSION    = 3;

{ Added 1.7 }
{ ICAP_DUPLEX values }
  {$EXTERNALSYM TWDX_NONE}
  TWDX_NONE        = 0;
  {$EXTERNALSYM TWDX_1PASSDUPLEX}
  TWDX_1PASSDUPLEX = 1;
  {$EXTERNALSYM TWDX_2PASSDUPLEX}
  TWDX_2PASSDUPLEX = 2;

{ Added 1.7 }
{ TWEI_BARCODETYPE values }
  {$EXTERNALSYM TWBT_3OF9}
  TWBT_3OF9              = 0;
  {$EXTERNALSYM TWBT_2OF5INTERLEAVED}
  TWBT_2OF5INTERLEAVED   = 1;
  {$EXTERNALSYM TWBT_2OF5NONINTERLEAVED}
  TWBT_2OF5NONINTERLEAVED= 2;
  {$EXTERNALSYM TWBT_CODE93}
  TWBT_CODE93            = 3;
  {$EXTERNALSYM TWBT_CODE128}
  TWBT_CODE128           = 4;
  {$EXTERNALSYM TWBT_UCC128}
  TWBT_UCC128            = 5;
  {$EXTERNALSYM TWBT_CODABAR}
  TWBT_CODABAR           = 6;
  {$EXTERNALSYM TWBT_UPCA}
  TWBT_UPCA              = 7;
  {$EXTERNALSYM TWBT_UPCE}
  TWBT_UPCE              = 8;
  {$EXTERNALSYM TWBT_EAN8}
  TWBT_EAN8              = 9;
  {$EXTERNALSYM TWBT_EAN13}
  TWBT_EAN13             = 10;
  {$EXTERNALSYM TWBT_POSTNET}
  TWBT_POSTNET           = 11;
  {$EXTERNALSYM TWBT_PDF417}
  TWBT_PDF417            = 12;

{ Added 1.8 }
  {$EXTERNALSYM TWBT_2OF5INDUSTRIAL}
  TWBT_2OF5INDUSTRIAL    = 13;
  {$EXTERNALSYM TWBT_2OF5MATRIX}
  TWBT_2OF5MATRIX        = 14;
  {$EXTERNALSYM TWBT_2OF5DATALOGIC}
  TWBT_2OF5DATALOGIC     = 15;
  {$EXTERNALSYM TWBT_2OF5IATA}
  TWBT_2OF5IATA          = 16;
  {$EXTERNALSYM TWBT_3OF9FULLASCII}
  TWBT_3OF9FULLASCII     = 17;
  {$EXTERNALSYM TWBT_CODABARWITHSTARTSTOP}
  TWBT_CODABARWITHSTARTSTOP = 18;
  {$EXTERNALSYM TWBT_MAXICODE}
  TWBT_MAXICODE          = 19;

{ Added 1.7 }
{ TWEI_DESKEWSTATUS values }
  {$EXTERNALSYM TWDSK_SUCCESS}
  TWDSK_SUCCESS    = 0;
  {$EXTERNALSYM TWDSK_REPORTONLY}
  TWDSK_REPORTONLY = 1;
  {$EXTERNALSYM TWDSK_FAIL}
  TWDSK_FAIL       = 2;
  {$EXTERNALSYM TWDSK_DISABLED}
  TWDSK_DISABLED   = 3;

{ Added 1.7 }
{ TWEI_PATCHCODE values }
  {$EXTERNALSYM TWPCH_PATCH1}
  TWPCH_PATCH1   = 0;
  {$EXTERNALSYM TWPCH_PATCH2}
  TWPCH_PATCH2   = 1;
  {$EXTERNALSYM TWPCH_PATCH3}
  TWPCH_PATCH3   = 2;
  {$EXTERNALSYM TWPCH_PATCH4}
  TWPCH_PATCH4   = 3;
  {$EXTERNALSYM TWPCH_PATCH6}
  TWPCH_PATCH6   = 4;
  {$EXTERNALSYM TWPCH_PATCHT}
  TWPCH_PATCHT   = 5;

{ Added 1.7 }
{ CAP_JOBCONTROL values }
  {$EXTERNALSYM TWJC_NONE}
  TWJC_NONE  = 0;
  {$EXTERNALSYM TWJC_JSIC}
  TWJC_JSIC  = 1;
  {$EXTERNALSYM TWJC_JSIS}
  TWJC_JSIS  = 2;
  {$EXTERNALSYM TWJC_JSXC}
  TWJC_JSXC  = 3;
  {$EXTERNALSYM TWJC_JSXS}
  TWJC_JSXS  = 4;

{ Added 1.7 }
{ TWEI_BARCODEROTATION values (BCOR_ means barcode rotation) }
  {$EXTERNALSYM TWBCOR_ROT0}
  TWBCOR_ROT0   = 0;
  {$EXTERNALSYM TWBCOR_ROT90}
  TWBCOR_ROT90  = 1;
  {$EXTERNALSYM TWBCOR_ROT180}
  TWBCOR_ROT180 = 2;
  {$EXTERNALSYM TWBCOR_ROT270}
  TWBCOR_ROT270 = 3;
  {$EXTERNALSYM TWBCOR_ROTX}
  TWBCOR_ROTX   = 4;

{ Added 1.8 }
{ ACAP_AUDIOFILEFORMAT values (AF_ means audio format) }
  {$EXTERNALSYM TWAF_WAV}
  TWAF_WAV   = 0;
  {$EXTERNALSYM TWAF_AIFF}
  TWAF_AIFF  = 1;
  {$EXTERNALSYM TWAF_AU}
  TWAF_AU    = 3;
  {$EXTERNALSYM TWAF_SND}
  TWAF_SND   = 4;

{ CAP_ALARMS values (AL_ means alarms) }
  {$EXTERNALSYM TWAL_ALARM}
  TWAL_ALARM        = 0;
  {$EXTERNALSYM TWAL_FEEDERERROR}
  TWAL_FEEDERERROR  = 1;
  {$EXTERNALSYM TWAL_FEEDERWARNING}
  TWAL_FEEDERWARNING= 2;
  {$EXTERNALSYM TWAL_BARCODE}
  TWAL_BARCODE      = 3;
  {$EXTERNALSYM TWAL_DOUBLEFEED}
  TWAL_DOUBLEFEED   = 4;
  {$EXTERNALSYM TWAL_JAM}
  TWAL_JAM          = 5;
  {$EXTERNALSYM TWAL_PATCHCODE}
  TWAL_PATCHCODE    = 6;
  {$EXTERNALSYM TWAL_POWER}
  TWAL_POWER        = 7;
  {$EXTERNALSYM TWAL_SKEW}
  TWAL_SKEW         = 8;

{ CAP_CLEARBUFFERS values (CB_ means clear buffers) }
  {$EXTERNALSYM TWCB_AUTO}
  TWCB_AUTO      = 0;
  {$EXTERNALSYM TWCB_CLEAR}
  TWCB_CLEAR     = 1;
  {$EXTERNALSYM TWCB_NOCLEAR}
  TWCB_NOCLEAR   = 2;

{ CAP_DEVICEEVENT values (DE_ means device event) }
  {$EXTERNALSYM TWDE_CUSTOMEVENTS}
  TWDE_CUSTOMEVENTS          = $8000;
  {$EXTERNALSYM TWDE_CHECKAUTOMATICCAPTURE}
  TWDE_CHECKAUTOMATICCAPTURE = 0;
  {$EXTERNALSYM TWDE_CHECKBATTERY}
  TWDE_CHECKBATTERY          = 1;
  {$EXTERNALSYM TWDE_CHECKDEVICEONLINE}
  TWDE_CHECKDEVICEONLINE     = 2;
  {$EXTERNALSYM TWDE_CHECKFLASH}
  TWDE_CHECKFLASH            = 3;
  {$EXTERNALSYM TWDE_CHECKPOWERSUPPLY}
  TWDE_CHECKPOWERSUPPLY      = 4;
  {$EXTERNALSYM TWDE_CHECKRESOLUTION}
  TWDE_CHECKRESOLUTION       = 5;
  {$EXTERNALSYM TWDE_DEVICEADDED}
  TWDE_DEVICEADDED           = 6;
  {$EXTERNALSYM TWDE_DEVICEOFFLINE}
  TWDE_DEVICEOFFLINE         = 7;
  {$EXTERNALSYM TWDE_DEVICEREADY}
  TWDE_DEVICEREADY           = 8;
  {$EXTERNALSYM TWDE_DEVICEREMOVED}
  TWDE_DEVICEREMOVED         = 9;
  {$EXTERNALSYM TWDE_IMAGECAPTURED}
  TWDE_IMAGECAPTURED         = 10;
  {$EXTERNALSYM TWDE_IMAGEDELETED}
  TWDE_IMAGEDELETED          = 11;
  {$EXTERNALSYM TWDE_PAPERDOUBLEFEED}
  TWDE_PAPERDOUBLEFEED       = 12;
  {$EXTERNALSYM TWDE_PAPERJAM}
  TWDE_PAPERJAM              = 13;
  {$EXTERNALSYM TWDE_LAMPFAILURE}
  TWDE_LAMPFAILURE           = 14;
  {$EXTERNALSYM TWDE_POWERSAVE}
  TWDE_POWERSAVE             = 15;
  {$EXTERNALSYM TWDE_POWERSAVENOTIFY}
  TWDE_POWERSAVENOTIFY       = 16;

{ CAP_FEEDERALIGNMENT values (FA_ means feeder alignment) }
  {$EXTERNALSYM TWFA_NONE}
  TWFA_NONE   = 0;
  {$EXTERNALSYM TWFA_LEFT}
  TWFA_LEFT   = 1;
  {$EXTERNALSYM TWFA_CENTER}
  TWFA_CENTER = 2;
  {$EXTERNALSYM TWFA_RIGHT}
  TWFA_RIGHT  = 3;

{ CAP_FEEDERORDER values (FO_ means feeder order) }
  {$EXTERNALSYM TWFO_FIRSTPAGEFIRST}
  TWFO_FIRSTPAGEFIRST = 0;
  {$EXTERNALSYM TWFO_LASTPAGEFIRST}
  TWFO_LASTPAGEFIRST  = 1;

{ CAP_FILESYSTEM values (FS_ means file system) }
  {$EXTERNALSYM TWFS_FILESYSTEM}
  TWFS_FILESYSTEM      = 0;
  {$EXTERNALSYM TWFS_RECURSIVEDELETE}
  TWFS_RECURSIVEDELETE = 1;

{ CAP_POWERSUPPLY values (PS_ means power supply) }
  {$EXTERNALSYM TWPS_EXTERNAL}
  TWPS_EXTERNAL = 0;
  {$EXTERNALSYM TWPS_BATTERY}
  TWPS_BATTERY  = 1;

{ CAP_PRINTER values (PR_ means printer) }
  {$EXTERNALSYM TWPR_IMPRINTERTOPBEFORE}
  TWPR_IMPRINTERTOPBEFORE    = 0;
  {$EXTERNALSYM TWPR_IMPRINTERTOPAFTER}
  TWPR_IMPRINTERTOPAFTER     = 1;
  {$EXTERNALSYM TWPR_IMPRINTERBOTTOMBEFORE}
  TWPR_IMPRINTERBOTTOMBEFORE = 2;
  {$EXTERNALSYM TWPR_IMPRINTERBOTTOMAFTER}
  TWPR_IMPRINTERBOTTOMAFTER  = 3;
  {$EXTERNALSYM TWPR_ENDORSERTOPBEFORE}
  TWPR_ENDORSERTOPBEFORE     = 4;
  {$EXTERNALSYM TWPR_ENDORSERTOPAFTER}
  TWPR_ENDORSERTOPAFTER      = 5;
  {$EXTERNALSYM TWPR_ENDORSERBOTTOMBEFORE}
  TWPR_ENDORSERBOTTOMBEFORE  = 6;
  {$EXTERNALSYM TWPR_ENDORSERBOTTOMAFTER}
  TWPR_ENDORSERBOTTOMAFTER   = 7;

{ CAP_PRINTERMODE values (PM_ means printer mode) }
  {$EXTERNALSYM TWPM_SINGLESTRING}
  TWPM_SINGLESTRING   = 0;
  {$EXTERNALSYM TWPM_MULTISTRING}
  TWPM_MULTISTRING    = 1;
  {$EXTERNALSYM TWPM_COMPOUNDSTRING}
  TWPM_COMPOUNDSTRING = 2;

{ ICAP_BARCODESEARCHMODE values (TWBD_ means search) }
  {$EXTERNALSYM TWBD_HORZ}
  TWBD_HORZ     = 0;
  {$EXTERNALSYM TWBD_VERT}
  TWBD_VERT     = 1;
  {$EXTERNALSYM TWBD_HORZVERT}
  TWBD_HORZVERT = 2;
  {$EXTERNALSYM TWBD_VERTHORZ}
  TWBD_VERTHORZ = 3;

{ ICAP_FLASHUSED2 values (FL_ means flash) }
  {$EXTERNALSYM TWFL_NONE}
  TWFL_NONE   = 0;
  {$EXTERNALSYM TWFL_OFF}
  TWFL_OFF    = 1;
  {$EXTERNALSYM TWFL_ON}
  TWFL_ON     = 2;
  {$EXTERNALSYM TWFL_AUTO}
  TWFL_AUTO   = 3;
  {$EXTERNALSYM TWFL_REDEYE}
  TWFL_REDEYE = 4;

{ ICAP_FLIPROTATION values (FR_ means flip rotation) }
  {$EXTERNALSYM TWFR_BOOK}
  TWFR_BOOK    = 0;
  {$EXTERNALSYM TWFR_FANFOLD}
  TWFR_FANFOLD = 1;

{ ICAP_IMAGEFILTER values (IF_ means image filter) }
  {$EXTERNALSYM TWIF_NONE}
  TWIF_NONE    = 0;
  {$EXTERNALSYM TWIF_AUTO}
  TWIF_AUTO    = 1;
  {$EXTERNALSYM TWIF_LOWPASS}
  TWIF_LOWPASS = 2;
  {$EXTERNALSYM TWIF_BANDPASS}
  TWIF_BANDPASS= 3;
  {$EXTERNALSYM TWIF_HIGHPASS}
  TWIF_HIGHPASS= 4;
  {$EXTERNALSYM TWIF_TEXT}
  TWIF_TEXT    = TWIF_BANDPASS;
  {$EXTERNALSYM TWIF_FINELINE}
  TWIF_FINELINE= TWIF_HIGHPASS;

{ ICAP_NOISEFILTER values (NF_ means noise filter) }
  {$EXTERNALSYM TWNF_NONE}
  TWNF_NONE         = 0;
  {$EXTERNALSYM TWNF_AUTO}
  TWNF_AUTO         = 1;
  {$EXTERNALSYM TWNF_LONEPIXEL}
  TWNF_LONEPIXEL    = 2;
  {$EXTERNALSYM TWNF_MAJORITYRULE}
  TWNF_MAJORITYRULE = 3;

{ ICAP_OVERSCAN values (OV_ means overscan) }
  {$EXTERNALSYM TWOV_NONE}
  TWOV_NONE      = 0;
  {$EXTERNALSYM TWOV_AUTO}
  TWOV_AUTO      = 1;
  {$EXTERNALSYM TWOV_TOPBOTTOM}
  TWOV_TOPBOTTOM = 2;
  {$EXTERNALSYM TWOV_LEFTRIGHT}
  TWOV_LEFTRIGHT = 3;
  {$EXTERNALSYM TWOV_ALL}
  TWOV_ALL       = 4;

{ TW_FILESYSTEM.FileType values (FT_ means file type) }
  {$EXTERNALSYM TWFY_CAMERA}
  TWFY_CAMERA        = 0;
  {$EXTERNALSYM TWFY_CAMERATOP}
  TWFY_CAMERATOP     = 1;
  {$EXTERNALSYM TWFY_CAMERABOTTOM}
  TWFY_CAMERABOTTOM  = 2;
  {$EXTERNALSYM TWFY_CAMERAPREVIEW}
  TWFY_CAMERAPREVIEW = 3;
  {$EXTERNALSYM TWFY_DOMAIN}
  TWFY_DOMAIN        = 4;
  {$EXTERNALSYM TWFY_HOST}
  TWFY_HOST          = 5;
  {$EXTERNALSYM TWFY_DIRECTORY}
  TWFY_DIRECTORY     = 6;
  {$EXTERNALSYM TWFY_IMAGE}
  TWFY_IMAGE         = 7;
  {$EXTERNALSYM TWFY_UNKNOWN}
  TWFY_UNKNOWN       = 8;

{***************************************************************************
 * Country Constants                                                       *
 *************************************************************************** }

  {$EXTERNALSYM TWCY_AFGHANISTAN}
  TWCY_AFGHANISTAN    =  1001;
  {$EXTERNALSYM TWCY_ALGERIA}
  TWCY_ALGERIA        =  213;
  {$EXTERNALSYM TWCY_AMERICANSAMOA}
  TWCY_AMERICANSAMOA  =  684;
  {$EXTERNALSYM TWCY_ANDORRA}
  TWCY_ANDORRA        =  033;
  {$EXTERNALSYM TWCY_ANGOLA}
  TWCY_ANGOLA         =  1002;
  {$EXTERNALSYM TWCY_ANGUILLA}
  TWCY_ANGUILLA       =  8090;
  {$EXTERNALSYM TWCY_ANTIGUA}
  TWCY_ANTIGUA        =  8091;
  {$EXTERNALSYM TWCY_ARGENTINA}
  TWCY_ARGENTINA      =   54;
  {$EXTERNALSYM TWCY_ARUBA}
  TWCY_ARUBA          =  297;
  {$EXTERNALSYM TWCY_ASCENSIONI}
  TWCY_ASCENSIONI     =  247;
  {$EXTERNALSYM TWCY_AUSTRALIA}
  TWCY_AUSTRALIA      =   61;
  {$EXTERNALSYM TWCY_AUSTRIA}
  TWCY_AUSTRIA        =   43;
  {$EXTERNALSYM TWCY_BAHAMAS}
  TWCY_BAHAMAS        =  8092;
  {$EXTERNALSYM TWCY_BAHRAIN}
  TWCY_BAHRAIN        =  973;
  {$EXTERNALSYM TWCY_BANGLADESH}
  TWCY_BANGLADESH     =  880;
  {$EXTERNALSYM TWCY_BARBADOS}
  TWCY_BARBADOS       =  8093;
  {$EXTERNALSYM TWCY_BELGIUM}
  TWCY_BELGIUM        =   32;
  {$EXTERNALSYM TWCY_BELIZE}
  TWCY_BELIZE         =  501;
  {$EXTERNALSYM TWCY_BENIN}
  TWCY_BENIN          =  229;
  {$EXTERNALSYM TWCY_BERMUDA}
  TWCY_BERMUDA        =  8094;
  {$EXTERNALSYM TWCY_BHUTAN}
  TWCY_BHUTAN         =  1003;
  {$EXTERNALSYM TWCY_BOLIVIA}
  TWCY_BOLIVIA        =  591;
  {$EXTERNALSYM TWCY_BOTSWANA}
  TWCY_BOTSWANA       =  267;
  {$EXTERNALSYM TWCY_BRITAIN}
  TWCY_BRITAIN        =   6;
  {$EXTERNALSYM TWCY_BRITVIRGINIS}
  TWCY_BRITVIRGINIS   =  8095;
  {$EXTERNALSYM TWCY_BRAZIL}
  TWCY_BRAZIL         =   55;
  {$EXTERNALSYM TWCY_BRUNEI}
  TWCY_BRUNEI         =  673;
  {$EXTERNALSYM TWCY_BULGARIA}
  TWCY_BULGARIA       =  359;
  {$EXTERNALSYM TWCY_BURKINAFASO}
  TWCY_BURKINAFASO    =  1004;
  {$EXTERNALSYM TWCY_BURMA}
  TWCY_BURMA          =  1005;
  {$EXTERNALSYM TWCY_BURUNDI}
  TWCY_BURUNDI        =  1006;
  {$EXTERNALSYM TWCY_CAMAROON}
  TWCY_CAMAROON       =  237;
  {$EXTERNALSYM TWCY_CANADA}
  TWCY_CANADA         =   2;
  {$EXTERNALSYM TWCY_CAPEVERDEIS}
  TWCY_CAPEVERDEIS    =  238;
  {$EXTERNALSYM TWCY_CAYMANIS}
  TWCY_CAYMANIS       =  8096;
  {$EXTERNALSYM TWCY_CENTRALAFREP}
  TWCY_CENTRALAFREP   =  1007;
  {$EXTERNALSYM TWCY_CHAD}
  TWCY_CHAD           =  1008;
  {$EXTERNALSYM TWCY_CHILE}
  TWCY_CHILE          =   56;
  {$EXTERNALSYM TWCY_CHINA}
  TWCY_CHINA          =   86;
  {$EXTERNALSYM TWCY_CHRISTMASIS}
  TWCY_CHRISTMASIS    =  1009;
  {$EXTERNALSYM TWCY_COCOSIS}
  TWCY_COCOSIS        =  1009;
  {$EXTERNALSYM TWCY_COLOMBIA}
  TWCY_COLOMBIA       =   57;
  {$EXTERNALSYM TWCY_COMOROS}
  TWCY_COMOROS        =  1010;
  {$EXTERNALSYM TWCY_CONGO}
  TWCY_CONGO          =  1011;
  {$EXTERNALSYM TWCY_COOKIS}
  TWCY_COOKIS         =  1012;
  {$EXTERNALSYM TWCY_COSTARICA}
  TWCY_COSTARICA      =  506 ;
  {$EXTERNALSYM TWCY_CUBA}
  TWCY_CUBA           =  005;
  {$EXTERNALSYM TWCY_CYPRUS}
  TWCY_CYPRUS         =  357;
  {$EXTERNALSYM TWCY_CZECHOSLOVAKIA}
  TWCY_CZECHOSLOVAKIA =  42;
  {$EXTERNALSYM TWCY_DENMARK}
  TWCY_DENMARK        =   45;
  {$EXTERNALSYM TWCY_DJIBOUTI}
  TWCY_DJIBOUTI       =  1013;
  {$EXTERNALSYM TWCY_DOMINICA}
  TWCY_DOMINICA       =  8097;
  {$EXTERNALSYM TWCY_DOMINCANREP}
  TWCY_DOMINCANREP    =  8098;
  {$EXTERNALSYM TWCY_EASTERIS}
  TWCY_EASTERIS       =  1014;
  {$EXTERNALSYM TWCY_ECUADOR}
  TWCY_ECUADOR        =  593;
  {$EXTERNALSYM TWCY_EGYPT}
  TWCY_EGYPT          =   20;
  {$EXTERNALSYM TWCY_ELSALVADOR}
  TWCY_ELSALVADOR     =  503;
  {$EXTERNALSYM TWCY_EQGUINEA}
  TWCY_EQGUINEA       =  1015;
  {$EXTERNALSYM TWCY_ETHIOPIA}
  TWCY_ETHIOPIA       =  251;
  {$EXTERNALSYM TWCY_FALKLANDIS}
  TWCY_FALKLANDIS     =  1016;
  {$EXTERNALSYM TWCY_FAEROEIS}
  TWCY_FAEROEIS       =  298;
  {$EXTERNALSYM TWCY_FIJIISLANDS}
  TWCY_FIJIISLANDS    =  679;
  {$EXTERNALSYM TWCY_FINLAND}
  TWCY_FINLAND        =  358;
  {$EXTERNALSYM TWCY_FRANCE}
  TWCY_FRANCE         =   33;
  {$EXTERNALSYM TWCY_FRANTILLES}
  TWCY_FRANTILLES     =  596;
  {$EXTERNALSYM TWCY_FRGUIANA}
  TWCY_FRGUIANA       =  594;
  {$EXTERNALSYM TWCY_FRPOLYNEISA}
  TWCY_FRPOLYNEISA    =  689;
  {$EXTERNALSYM TWCY_FUTANAIS}
  TWCY_FUTANAIS       =  1043;
  {$EXTERNALSYM TWCY_GABON}
  TWCY_GABON          =  241;
  {$EXTERNALSYM TWCY_GAMBIA}
  TWCY_GAMBIA         =  220;
  {$EXTERNALSYM TWCY_GERMANY}
  TWCY_GERMANY        =   49;
  {$EXTERNALSYM TWCY_GHANA}
  TWCY_GHANA          =  233;
  {$EXTERNALSYM TWCY_GIBRALTER}
  TWCY_GIBRALTER      =  350;
  {$EXTERNALSYM TWCY_GREECE}
  TWCY_GREECE         =   30;
  {$EXTERNALSYM TWCY_GREENLAND}
  TWCY_GREENLAND      =  299;
  {$EXTERNALSYM TWCY_GRENADA}
  TWCY_GRENADA        =  8099;
  {$EXTERNALSYM TWCY_GRENEDINES}
  TWCY_GRENEDINES     =  8015;
  {$EXTERNALSYM TWCY_GUADELOUPE}
  TWCY_GUADELOUPE     =  590;
  {$EXTERNALSYM TWCY_GUAM}
  TWCY_GUAM           =  671;
  {$EXTERNALSYM TWCY_GUANTANAMOBAY}
  TWCY_GUANTANAMOBAY  =  5399;
  {$EXTERNALSYM TWCY_GUATEMALA}
  TWCY_GUATEMALA      =  502;
  {$EXTERNALSYM TWCY_GUINEA}
  TWCY_GUINEA         =  224;
  {$EXTERNALSYM TWCY_GUINEABISSAU}
  TWCY_GUINEABISSAU   =  1017;
  {$EXTERNALSYM TWCY_GUYANA}
  TWCY_GUYANA         =  592;
  {$EXTERNALSYM TWCY_HAITI}
  TWCY_HAITI          =  509;
  {$EXTERNALSYM TWCY_HONDURAS}
  TWCY_HONDURAS       =  504;
  {$EXTERNALSYM TWCY_HONGKONG}
  TWCY_HONGKONG       =  852 ;
  {$EXTERNALSYM TWCY_HUNGARY}
  TWCY_HUNGARY        =   36;
  {$EXTERNALSYM TWCY_ICELAND}
  TWCY_ICELAND        =  354;
  {$EXTERNALSYM TWCY_INDIA}
  TWCY_INDIA          =   91;
  {$EXTERNALSYM TWCY_INDONESIA}
  TWCY_INDONESIA      =   62;
  {$EXTERNALSYM TWCY_IRAN}
  TWCY_IRAN           =   98;
  {$EXTERNALSYM TWCY_IRAQ}
  TWCY_IRAQ           =  964;
  {$EXTERNALSYM TWCY_IRELAND}
  TWCY_IRELAND        =  353;
  {$EXTERNALSYM TWCY_ISRAEL}
  TWCY_ISRAEL         =  972;
  {$EXTERNALSYM TWCY_ITALY}
  TWCY_ITALY          =   39;
  {$EXTERNALSYM TWCY_IVORYCOAST}
  TWCY_IVORYCOAST     =  225 ;
  {$EXTERNALSYM TWCY_JAMAICA}
  TWCY_JAMAICA        =  8010;
  {$EXTERNALSYM TWCY_JAPAN}
  TWCY_JAPAN          =   81;
  {$EXTERNALSYM TWCY_JORDAN}
  TWCY_JORDAN         =  962;
  {$EXTERNALSYM TWCY_KENYA}
  TWCY_KENYA          =  254;
  {$EXTERNALSYM TWCY_KIRIBATI}
  TWCY_KIRIBATI       =  1018;
  {$EXTERNALSYM TWCY_KOREA}
  TWCY_KOREA          =   82;
  {$EXTERNALSYM TWCY_KUWAIT}
  TWCY_KUWAIT         =  965;
  {$EXTERNALSYM TWCY_LAOS}
  TWCY_LAOS           =  1019;
  {$EXTERNALSYM TWCY_LEBANON}
  TWCY_LEBANON        =  1020;
  {$EXTERNALSYM TWCY_LIBERIA}
  TWCY_LIBERIA        =  231;
  {$EXTERNALSYM TWCY_LIBYA}
  TWCY_LIBYA          =  218;
  {$EXTERNALSYM TWCY_LIECHTENSTEIN}
  TWCY_LIECHTENSTEIN  =   41;
  {$EXTERNALSYM TWCY_LUXENBOURG}
  TWCY_LUXENBOURG     =  352;
  {$EXTERNALSYM TWCY_MACAO}
  TWCY_MACAO          =  853;
  {$EXTERNALSYM TWCY_MADAGASCAR}
  TWCY_MADAGASCAR     =  1021;
  {$EXTERNALSYM TWCY_MALAWI}
  TWCY_MALAWI         =  265;
  {$EXTERNALSYM TWCY_MALAYSIA}
  TWCY_MALAYSIA       =   60;
  {$EXTERNALSYM TWCY_MALDIVES}
  TWCY_MALDIVES       =  960;
  {$EXTERNALSYM TWCY_MALI}
  TWCY_MALI           =  1022;
  {$EXTERNALSYM TWCY_MALTA}
  TWCY_MALTA          =  356;
  {$EXTERNALSYM TWCY_MARSHALLIS}
  TWCY_MARSHALLIS     =  692;
  {$EXTERNALSYM TWCY_MAURITANIA}
  TWCY_MAURITANIA     =  1023;
  {$EXTERNALSYM TWCY_MAURITIUS}
  TWCY_MAURITIUS      =  230;
  {$EXTERNALSYM TWCY_MEXICO}
  TWCY_MEXICO         =   3;
  {$EXTERNALSYM TWCY_MICRONESIA}
  TWCY_MICRONESIA     =  691;
  {$EXTERNALSYM TWCY_MIQUELON}
  TWCY_MIQUELON       =  508;
  {$EXTERNALSYM TWCY_MONACO}
  TWCY_MONACO         =   33;
  {$EXTERNALSYM TWCY_MONGOLIA}
  TWCY_MONGOLIA       =  1024;
  {$EXTERNALSYM TWCY_MONTSERRAT}
  TWCY_MONTSERRAT     =  8011;
  {$EXTERNALSYM TWCY_MOROCCO}
  TWCY_MOROCCO        =  212;
  {$EXTERNALSYM TWCY_MOZAMBIQUE}
  TWCY_MOZAMBIQUE     =  1025;
  {$EXTERNALSYM TWCY_NAMIBIA}
  TWCY_NAMIBIA        =  264;
  {$EXTERNALSYM TWCY_NAURU}
  TWCY_NAURU          =  1026;
  {$EXTERNALSYM TWCY_NEPAL}
  TWCY_NEPAL          =  977;
  {$EXTERNALSYM TWCY_NETHERLANDS}
  TWCY_NETHERLANDS    =   31;
  {$EXTERNALSYM TWCY_NETHANTILLES}
  TWCY_NETHANTILLES   =  599;
  {$EXTERNALSYM TWCY_NEVIS}
  TWCY_NEVIS          =  8012;
  {$EXTERNALSYM TWCY_NEWCALEDONIA}
  TWCY_NEWCALEDONIA   =  687;
  {$EXTERNALSYM TWCY_NEWZEALAND}
  TWCY_NEWZEALAND     =   64;
  {$EXTERNALSYM TWCY_NICARAGUA}
  TWCY_NICARAGUA      =  505;
  {$EXTERNALSYM TWCY_NIGER}
  TWCY_NIGER          =  227;
  {$EXTERNALSYM TWCY_NIGERIA}
  TWCY_NIGERIA        =  234;
  {$EXTERNALSYM TWCY_NIUE}
  TWCY_NIUE           =  1027;
  {$EXTERNALSYM TWCY_NORFOLKI}
  TWCY_NORFOLKI       =  1028;
  {$EXTERNALSYM TWCY_NORWAY}
  TWCY_NORWAY         =   47;
  {$EXTERNALSYM TWCY_OMAN}
  TWCY_OMAN           =  968;
  {$EXTERNALSYM TWCY_PAKISTAN}
  TWCY_PAKISTAN       =   92;
  {$EXTERNALSYM TWCY_PALAU}
  TWCY_PALAU          =  1029;
  {$EXTERNALSYM TWCY_PANAMA}
  TWCY_PANAMA         =  507;
  {$EXTERNALSYM TWCY_PARAGUAY}
  TWCY_PARAGUAY       =  595;
  {$EXTERNALSYM TWCY_PERU}
  TWCY_PERU           =   51;
  {$EXTERNALSYM TWCY_PHILLIPPINES}
  TWCY_PHILLIPPINES   =   63;
  {$EXTERNALSYM TWCY_PITCAIRNIS}
  TWCY_PITCAIRNIS     =  1030;
  {$EXTERNALSYM TWCY_PNEWGUINEA}
  TWCY_PNEWGUINEA     =  675;
  {$EXTERNALSYM TWCY_POLAND}
  TWCY_POLAND         =   48;
  {$EXTERNALSYM TWCY_PORTUGAL}
  TWCY_PORTUGAL       =  351;
  {$EXTERNALSYM TWCY_QATAR}
  TWCY_QATAR          =  974;
  {$EXTERNALSYM TWCY_REUNIONI}
  TWCY_REUNIONI       =  1031;
  {$EXTERNALSYM TWCY_ROMANIA}
  TWCY_ROMANIA        =   40;
  {$EXTERNALSYM TWCY_RWANDA}
  TWCY_RWANDA         =  250;
  {$EXTERNALSYM TWCY_SAIPAN}
  TWCY_SAIPAN         =  670;
  {$EXTERNALSYM TWCY_SANMARINO}
  TWCY_SANMARINO      =   39;
  {$EXTERNALSYM TWCY_SAOTOME}
  TWCY_SAOTOME        =  1033;
  {$EXTERNALSYM TWCY_SAUDIARABIA}
  TWCY_SAUDIARABIA    =  966;
  {$EXTERNALSYM TWCY_SENEGAL}
  TWCY_SENEGAL        =  221;
  {$EXTERNALSYM TWCY_SEYCHELLESIS}
  TWCY_SEYCHELLESIS   =  1034;
  {$EXTERNALSYM TWCY_SIERRALEONE}
  TWCY_SIERRALEONE    =  1035;
  {$EXTERNALSYM TWCY_SINGAPORE}
  TWCY_SINGAPORE      =   65;
  {$EXTERNALSYM TWCY_SOLOMONIS}
  TWCY_SOLOMONIS      =  1036;
  {$EXTERNALSYM TWCY_SOMALI}
  TWCY_SOMALI         =  1037;
  {$EXTERNALSYM TWCY_SOUTHAFRICA}
  TWCY_SOUTHAFRICA    =  27 ;
  {$EXTERNALSYM TWCY_SPAIN}
  TWCY_SPAIN          =   34;
  {$EXTERNALSYM TWCY_SRILANKA}
  TWCY_SRILANKA       =   94;
  {$EXTERNALSYM TWCY_STHELENA}
  TWCY_STHELENA       =  1032;
  {$EXTERNALSYM TWCY_STKITTS}
  TWCY_STKITTS        =  8013;
  {$EXTERNALSYM TWCY_STLUCIA}
  TWCY_STLUCIA        =  8014;
  {$EXTERNALSYM TWCY_STPIERRE}
  TWCY_STPIERRE       =  508;
  {$EXTERNALSYM TWCY_STVINCENT}
  TWCY_STVINCENT      =  8015;
  {$EXTERNALSYM TWCY_SUDAN}
  TWCY_SUDAN          =  1038;
  {$EXTERNALSYM TWCY_SURINAME}
  TWCY_SURINAME       =  597;
  {$EXTERNALSYM TWCY_SWAZILAND}
  TWCY_SWAZILAND      =  268;
  {$EXTERNALSYM TWCY_SWEDEN}
  TWCY_SWEDEN         =   46;
  {$EXTERNALSYM TWCY_SWITZERLAND}
  TWCY_SWITZERLAND    =   41;
  {$EXTERNALSYM TWCY_SYRIA}
  TWCY_SYRIA          =  1039;
  {$EXTERNALSYM TWCY_TAIWAN}
  TWCY_TAIWAN         =  886;
  {$EXTERNALSYM TWCY_TANZANIA}
  TWCY_TANZANIA       =  255;
  {$EXTERNALSYM TWCY_THAILAND}
  TWCY_THAILAND       =   66;
  {$EXTERNALSYM TWCY_TOBAGO}
  TWCY_TOBAGO         =  8016;
  {$EXTERNALSYM TWCY_TOGO}
  TWCY_TOGO           =  228;
  {$EXTERNALSYM TWCY_TONGAIS}
  TWCY_TONGAIS        =  676;
  {$EXTERNALSYM TWCY_TRINIDAD}
  TWCY_TRINIDAD       =  8016;
  {$EXTERNALSYM TWCY_TUNISIA}
  TWCY_TUNISIA        =  216;
  {$EXTERNALSYM TWCY_TURKEY}
  TWCY_TURKEY         =   90;
  {$EXTERNALSYM TWCY_TURKSCAICOS}
  TWCY_TURKSCAICOS    =  8017;
  {$EXTERNALSYM TWCY_TUVALU}
  TWCY_TUVALU         =  1040;
  {$EXTERNALSYM TWCY_UGANDA}
  TWCY_UGANDA         =  256;
  {$EXTERNALSYM TWCY_USSR}
  TWCY_USSR           =   7;
  {$EXTERNALSYM TWCY_UAEMIRATES}
  TWCY_UAEMIRATES     =  971;
  {$EXTERNALSYM TWCY_UNITEDKINGDOM}
  TWCY_UNITEDKINGDOM  =   44;
  {$EXTERNALSYM TWCY_USA}
  TWCY_USA            =   1;
  {$EXTERNALSYM TWCY_URUGUAY}
  TWCY_URUGUAY        =  598;
  {$EXTERNALSYM TWCY_VANUATU}
  TWCY_VANUATU        =  1041;
  {$EXTERNALSYM TWCY_VATICANCITY}
  TWCY_VATICANCITY    =   39;
  {$EXTERNALSYM TWCY_VENEZUELA}
  TWCY_VENEZUELA      =   58;
  {$EXTERNALSYM TWCY_WAKE}
  TWCY_WAKE           =  1042;
  {$EXTERNALSYM TWCY_WALLISIS}
  TWCY_WALLISIS       =  1043;
  {$EXTERNALSYM TWCY_WESTERNSAHARA}
  TWCY_WESTERNSAHARA  =  1044;
  {$EXTERNALSYM TWCY_WESTERNSAMOA}
  TWCY_WESTERNSAMOA   =  1045;
  {$EXTERNALSYM TWCY_YEMEN}
  TWCY_YEMEN          =  1046;
  {$EXTERNALSYM TWCY_YUGOSLAVIA}
  TWCY_YUGOSLAVIA     =   38;
  {$EXTERNALSYM TWCY_ZAIRE}
  TWCY_ZAIRE          =  243;
  {$EXTERNALSYM TWCY_ZAMBIA}
  TWCY_ZAMBIA         =  260;
  {$EXTERNALSYM TWCY_ZIMBABWE}
  TWCY_ZIMBABWE       =  263;

{ Added for 1.8 }
  {$EXTERNALSYM TWCY_ALBANIA}
  TWCY_ALBANIA        =  355;
  {$EXTERNALSYM TWCY_ARMENIA}
  TWCY_ARMENIA        =  374;
  {$EXTERNALSYM TWCY_AZERBAIJAN}
  TWCY_AZERBAIJAN     =  994;
  {$EXTERNALSYM TWCY_BELARUS}
  TWCY_BELARUS        =  375;
  {$EXTERNALSYM TWCY_BOSNIAHERZGO}
  TWCY_BOSNIAHERZGO   =  387;
  {$EXTERNALSYM TWCY_CAMBODIA}
  TWCY_CAMBODIA       =  855;
  {$EXTERNALSYM TWCY_CROATIA}
  TWCY_CROATIA        =  385;
  {$EXTERNALSYM TWCY_CZECHREPUBLIC}
  TWCY_CZECHREPUBLIC  =  420;
  {$EXTERNALSYM TWCY_DIEGOGARCIA}
  TWCY_DIEGOGARCIA    =  246;
  {$EXTERNALSYM TWCY_ERITREA}
  TWCY_ERITREA        =  291;
  {$EXTERNALSYM TWCY_ESTONIA}
  TWCY_ESTONIA        =  372;
  {$EXTERNALSYM TWCY_GEORGIA}
  TWCY_GEORGIA        =  995;
  {$EXTERNALSYM TWCY_LATVIA}
  TWCY_LATVIA         =  371;
  {$EXTERNALSYM TWCY_LESOTHO}
  TWCY_LESOTHO        =  266;
  {$EXTERNALSYM TWCY_LITHUANIA}
  TWCY_LITHUANIA      =  370;
  {$EXTERNALSYM TWCY_MACEDONIA}
  TWCY_MACEDONIA      =  389;
  {$EXTERNALSYM TWCY_MAYOTTEIS}
  TWCY_MAYOTTEIS      =  269;
  {$EXTERNALSYM TWCY_MOLDOVA}
  TWCY_MOLDOVA        =  373;
  {$EXTERNALSYM TWCY_MYANMAR}
  TWCY_MYANMAR        =  95 ;
  {$EXTERNALSYM TWCY_NORTHKOREA}
  TWCY_NORTHKOREA     =  850;
  {$EXTERNALSYM TWCY_PUERTORICO}
  TWCY_PUERTORICO     =  787;
  {$EXTERNALSYM TWCY_RUSSIA}
  TWCY_RUSSIA         =  7 ;
  {$EXTERNALSYM TWCY_SERBIA}
  TWCY_SERBIA         =  381;
  {$EXTERNALSYM TWCY_SLOVAKIA}
  TWCY_SLOVAKIA       =  421;
  {$EXTERNALSYM TWCY_SLOVENIA}
  TWCY_SLOVENIA       =  386;
  {$EXTERNALSYM TWCY_SOUTHKOREA}
  TWCY_SOUTHKOREA     =  82 ;
  {$EXTERNALSYM TWCY_UKRAINE}
  TWCY_UKRAINE        =  380;
  {$EXTERNALSYM TWCY_USVIRGINIS}
  TWCY_USVIRGINIS     =  340;
  {$EXTERNALSYM TWCY_VIETNAM}
  TWCY_VIETNAM        =  84 ;

{***************************************************************************
 * Language Constants                                                      *
 *************************************************************************** }

  {$EXTERNALSYM TWLG_DAN}
  TWLG_DAN      =   0; { Danish }
  {$EXTERNALSYM TWLG_DUT}
  TWLG_DUT      =   1; { Dutch }
  {$EXTERNALSYM TWLG_ENG}
  TWLG_ENG      =   2; { International English }
  {$EXTERNALSYM TWLG_FCF}
  TWLG_FCF      =   3; { French Canadian }
  {$EXTERNALSYM TWLG_FIN}
  TWLG_FIN      =   4; { Finnish }
  {$EXTERNALSYM TWLG_FRN}
  TWLG_FRN      =   5; { French }
  {$EXTERNALSYM TWLG_GER}
  TWLG_GER      =   6; { German }
  {$EXTERNALSYM TWLG_ICE}
  TWLG_ICE      =   7; { Icelandic }
  {$EXTERNALSYM TWLG_ITN}
  TWLG_ITN      =   8; { Italian }
  {$EXTERNALSYM TWLG_NOR}
  TWLG_NOR      =   9; { Norwegian }
  {$EXTERNALSYM TWLG_POR}
  TWLG_POR      =  10; { Portuguese }
  {$EXTERNALSYM TWLG_SPA}
  TWLG_SPA      =  11; { Spanish }
  {$EXTERNALSYM TWLG_SWE}
  TWLG_SWE      =  12; { Swedish }
  {$EXTERNALSYM TWLG_USA}
  TWLG_USA      =  13; { U.S. English }
  
{ Added for 1.8 }
  {$EXTERNALSYM TWLG_USERLOCALE}
  TWLG_USERLOCALE         =  -1;
  {$EXTERNALSYM TWLG_AFRIKAANS}
  TWLG_AFRIKAANS          =  14;
  {$EXTERNALSYM TWLG_ALBANIA}
  TWLG_ALBANIA            =  15;
  {$EXTERNALSYM TWLG_ARABIC}
  TWLG_ARABIC             =  16;
  {$EXTERNALSYM TWLG_ARABIC_ALGERIA}
  TWLG_ARABIC_ALGERIA     =  17;
  {$EXTERNALSYM TWLG_ARABIC_BAHRAIN}
  TWLG_ARABIC_BAHRAIN     =  18;
  {$EXTERNALSYM TWLG_ARABIC_EGYPT}
  TWLG_ARABIC_EGYPT       =  19;
  {$EXTERNALSYM TWLG_ARABIC_IRAQ}
  TWLG_ARABIC_IRAQ        =  20;
  {$EXTERNALSYM TWLG_ARABIC_JORDAN}
  TWLG_ARABIC_JORDAN      =  21;
  {$EXTERNALSYM TWLG_ARABIC_KUWAIT}
  TWLG_ARABIC_KUWAIT      =  22;
  {$EXTERNALSYM TWLG_ARABIC_LEBANON}
  TWLG_ARABIC_LEBANON     =  23;
  {$EXTERNALSYM TWLG_ARABIC_LIBYA}
  TWLG_ARABIC_LIBYA       =  24;
  {$EXTERNALSYM TWLG_ARABIC_MOROCCO}
  TWLG_ARABIC_MOROCCO     =  25;
  {$EXTERNALSYM TWLG_ARABIC_OMAN}
  TWLG_ARABIC_OMAN        =  26;
  {$EXTERNALSYM TWLG_ARABIC_QATAR}
  TWLG_ARABIC_QATAR       =  27;
  {$EXTERNALSYM TWLG_ARABIC_SAUDIARABIA}
  TWLG_ARABIC_SAUDIARABIA =  28;
  {$EXTERNALSYM TWLG_ARABIC_SYRIA}
  TWLG_ARABIC_SYRIA       =  29;
  {$EXTERNALSYM TWLG_ARABIC_TUNISIA}
  TWLG_ARABIC_TUNISIA     =  30;
  {$EXTERNALSYM TWLG_ARABIC_UAE}
  TWLG_ARABIC_UAE         =  31; { United Arabic Emirates }
  {$EXTERNALSYM TWLG_ARABIC_YEMEN}
  TWLG_ARABIC_YEMEN       =  32;
  {$EXTERNALSYM TWLG_BASQUE}
  TWLG_BASQUE             =  33;
  {$EXTERNALSYM TWLG_BYELORUSSIAN}
  TWLG_BYELORUSSIAN       =  34;
  {$EXTERNALSYM TWLG_BULGARIAN}
  TWLG_BULGARIAN          =  35;
  {$EXTERNALSYM TWLG_CATALAN}
  TWLG_CATALAN            =  36;
  {$EXTERNALSYM TWLG_CHINESE}
  TWLG_CHINESE            =  37;
  {$EXTERNALSYM TWLG_CHINESE_HONGKONG}
  TWLG_CHINESE_HONGKONG   =  38;
  {$EXTERNALSYM TWLG_CHINESE_PRC}
  TWLG_CHINESE_PRC        =  39; { People's Republic of China }
  {$EXTERNALSYM TWLG_CHINESE_SINGAPORE}
  TWLG_CHINESE_SINGAPORE  =  40;
  {$EXTERNALSYM TWLG_CHINESE_SIMPLIFIED}
  TWLG_CHINESE_SIMPLIFIED =  41;
  {$EXTERNALSYM TWLG_CHINESE_TAIWAN}
  TWLG_CHINESE_TAIWAN     =  42;
  {$EXTERNALSYM TWLG_CHINESE_TRADITIONAL}
  TWLG_CHINESE_TRADITIONAL=  43;
  {$EXTERNALSYM TWLG_CROATIA}
  TWLG_CROATIA            =  44;
  {$EXTERNALSYM TWLG_CZECH}
  TWLG_CZECH              =  45;
  {$EXTERNALSYM TWLG_DANISH}
  TWLG_DANISH             =  TWLG_DAN;
  {$EXTERNALSYM TWLG_DUTCH}
  TWLG_DUTCH              =  TWLG_DUT;
  {$EXTERNALSYM TWLG_DUTCH_BELGIAN}
  TWLG_DUTCH_BELGIAN      =  46;
  {$EXTERNALSYM TWLG_ENGLISH}
  TWLG_ENGLISH            =  TWLG_ENG;
  {$EXTERNALSYM TWLG_ENGLISH_AUSTRALIAN}
  TWLG_ENGLISH_AUSTRALIAN =  47;
  {$EXTERNALSYM TWLG_ENGLISH_CANADIAN}
  TWLG_ENGLISH_CANADIAN   =  48;
  {$EXTERNALSYM TWLG_ENGLISH_IRELAND}
  TWLG_ENGLISH_IRELAND    =   49;
  {$EXTERNALSYM TWLG_ENGLISH_NEWZEALAND}
  TWLG_ENGLISH_NEWZEALAND =  50;
  {$EXTERNALSYM TWLG_ENGLISH_SOUTHAFRICA}
  TWLG_ENGLISH_SOUTHAFRICA=  51;
  {$EXTERNALSYM TWLG_ENGLISH_UK}
  TWLG_ENGLISH_UK           =  52;
  {$EXTERNALSYM TWLG_ENGLISH_USA}
  TWLG_ENGLISH_USA          =  TWLG_USA;
  {$EXTERNALSYM TWLG_ESTONIAN}
  TWLG_ESTONIAN             =  53;
  {$EXTERNALSYM TWLG_FAEROESE}
  TWLG_FAEROESE             =  54;
  {$EXTERNALSYM TWLG_FARSI}
  TWLG_FARSI                =  55;
  {$EXTERNALSYM TWLG_FINNISH}
  TWLG_FINNISH              =  TWLG_FIN;
  {$EXTERNALSYM TWLG_FRENCH}
  TWLG_FRENCH               =  TWLG_FRN;
  {$EXTERNALSYM TWLG_FRENCH_BELGIAN}
  TWLG_FRENCH_BELGIAN       =  56;
  {$EXTERNALSYM TWLG_FRENCH_CANADIAN}
  TWLG_FRENCH_CANADIAN      =  TWLG_FCF;
  {$EXTERNALSYM TWLG_FRENCH_LUXEMBOURG}
  TWLG_FRENCH_LUXEMBOURG    =  57;
  {$EXTERNALSYM TWLG_FRENCH_SWISS}
  TWLG_FRENCH_SWISS         =  58;
  {$EXTERNALSYM TWLG_GERMAN}
  TWLG_GERMAN               =  TWLG_GER;
  {$EXTERNALSYM TWLG_GERMAN_AUSTRIAN}
  TWLG_GERMAN_AUSTRIAN      =  59;
  {$EXTERNALSYM TWLG_GERMAN_LUXEMBOURG}
  TWLG_GERMAN_LUXEMBOURG    =  60;
  {$EXTERNALSYM TWLG_GERMAN_LIECHTENSTEIN}
  TWLG_GERMAN_LIECHTENSTEIN =  61;
  {$EXTERNALSYM TWLG_GERMAN_SWISS}
  TWLG_GERMAN_SWISS         =  62;
  {$EXTERNALSYM TWLG_GREEK}
  TWLG_GREEK                =  63;
  {$EXTERNALSYM TWLG_HEBREW}
  TWLG_HEBREW               =  64;
  {$EXTERNALSYM TWLG_HUNGARIAN}
  TWLG_HUNGARIAN            =  65;
  {$EXTERNALSYM TWLG_ICELANDIC}
  TWLG_ICELANDIC            =  TWLG_ICE;
  {$EXTERNALSYM TWLG_INDONESIAN}
  TWLG_INDONESIAN           =  66;
  {$EXTERNALSYM TWLG_ITALIAN}
  TWLG_ITALIAN              =  TWLG_ITN;
  {$EXTERNALSYM TWLG_ITALIAN_SWISS}
  TWLG_ITALIAN_SWISS        =  67;
  {$EXTERNALSYM TWLG_JAPANESE}
  TWLG_JAPANESE             =  68;
  {$EXTERNALSYM TWLG_KOREAN}
  TWLG_KOREAN               =  69;
  {$EXTERNALSYM TWLG_KOREAN_JOHAB}
  TWLG_KOREAN_JOHAB         =  70;
  {$EXTERNALSYM TWLG_LATVIAN}
  TWLG_LATVIAN              =  71;
  {$EXTERNALSYM TWLG_LITHUANIAN}
  TWLG_LITHUANIAN           =  72;
  {$EXTERNALSYM TWLG_NORWEGIAN}
  TWLG_NORWEGIAN            =  TWLG_NOR;
  {$EXTERNALSYM TWLG_NORWEGIAN_BOKMAL}
  TWLG_NORWEGIAN_BOKMAL     =  73;
  {$EXTERNALSYM TWLG_NORWEGIAN_NYNORSK}
  TWLG_NORWEGIAN_NYNORSK    =  74;
  {$EXTERNALSYM TWLG_POLISH}
  TWLG_POLISH               =  75;
  {$EXTERNALSYM TWLG_PORTUGUESE}
  TWLG_PORTUGUESE           =  TWLG_POR;
  {$EXTERNALSYM TWLG_PORTUGUESE_BRAZIL}
  TWLG_PORTUGUESE_BRAZIL    =  76;
  {$EXTERNALSYM TWLG_ROMANIAN}
  TWLG_ROMANIAN             =  77;
  {$EXTERNALSYM TWLG_RUSSIAN}
  TWLG_RUSSIAN              =  78;
  {$EXTERNALSYM TWLG_SERBIAN_LATIN}
  TWLG_SERBIAN_LATIN        =  79;
  {$EXTERNALSYM TWLG_SLOVAK}
  TWLG_SLOVAK               =  80;
  {$EXTERNALSYM TWLG_SLOVENIAN}
  TWLG_SLOVENIAN            =  81;
  {$EXTERNALSYM TWLG_SPANISH}
  TWLG_SPANISH              =  TWLG_SPA;
  {$EXTERNALSYM TWLG_SPANISH_MEXICAN}
  TWLG_SPANISH_MEXICAN      =  82;
  {$EXTERNALSYM TWLG_SPANISH_MODERN}
  TWLG_SPANISH_MODERN       =  83;
  {$EXTERNALSYM TWLG_SWEDISH}
  TWLG_SWEDISH              =  TWLG_SWE;
  {$EXTERNALSYM TWLG_THAI}
  TWLG_THAI                 =  84;
  {$EXTERNALSYM TWLG_TURKISH}
  TWLG_TURKISH              =  85;
  {$EXTERNALSYM TWLG_UKRANIAN}
  TWLG_UKRANIAN             =  86;

{ More stuff added for 1.8 }
  {$EXTERNALSYM TWLG_ASSAMESE}
  TWLG_ASSAMESE             =   87;
  {$EXTERNALSYM TWLG_BENGALI}
  TWLG_BENGALI              =   88;
  {$EXTERNALSYM TWLG_BIHARI}
  TWLG_BIHARI               =   89;
  {$EXTERNALSYM TWLG_BODO}
  TWLG_BODO                 =   90;
  {$EXTERNALSYM TWLG_DOGRI}
  TWLG_DOGRI                =   91;
  {$EXTERNALSYM TWLG_GUJARATI}
  TWLG_GUJARATI             =   92;
  {$EXTERNALSYM TWLG_HARYANVI}
  TWLG_HARYANVI             =   93;
  {$EXTERNALSYM TWLG_HINDI}
  TWLG_HINDI                =   94;
  {$EXTERNALSYM TWLG_KANNADA}
  TWLG_KANNADA              =   95;
  {$EXTERNALSYM TWLG_KASHMIRI}
  TWLG_KASHMIRI             =   96;
  {$EXTERNALSYM TWLG_MALAYALAM}
  TWLG_MALAYALAM            =   97;
  {$EXTERNALSYM TWLG_MARATHI}
  TWLG_MARATHI              =   98;
  {$EXTERNALSYM TWLG_MARWARI}
  TWLG_MARWARI              =   99;
  {$EXTERNALSYM TWLG_MEGHALAYAN}
  TWLG_MEGHALAYAN           =   100;
  {$EXTERNALSYM TWLG_MIZO}
  TWLG_MIZO                 =   101;
  {$EXTERNALSYM TWLG_NAGA}
  TWLG_NAGA                 =   102;
  {$EXTERNALSYM TWLG_ORISSI}
  TWLG_ORISSI               =   103;
  {$EXTERNALSYM TWLG_PUNJABI}
  TWLG_PUNJABI              =   104;
  {$EXTERNALSYM TWLG_PUSHTU}
  TWLG_PUSHTU               =   105;
  {$EXTERNALSYM TWLG_SERBIAN_CYRILLIC}
  TWLG_SERBIAN_CYRILLIC     =   106;
  {$EXTERNALSYM TWLG_SIKKIMI}
  TWLG_SIKKIMI              =   107;
  {$EXTERNALSYM TWLG_SWEDISH_FINLAND}
  TWLG_SWEDISH_FINLAND      =   108;
  {$EXTERNALSYM TWLG_TAMIL}
  TWLG_TAMIL                =   109;
  {$EXTERNALSYM TWLG_TELUGU}
  TWLG_TELUGU               =   110;
  {$EXTERNALSYM TWLG_TRIPURI}
  TWLG_TRIPURI              =   111;
  {$EXTERNALSYM TWLG_URDU}
  TWLG_URDU                 =   112;
  {$EXTERNALSYM TWLG_VIETNAMESE}
  TWLG_VIETNAMESE           =   113;

{***************************************************************************
 * Data Groups                                                             *
 *************************************************************************** }

{ More Data Groups may be added in the future.
 * Possible candidates include text, vector graphics, sound, etc.
 * NOTE: Data Group constants must be powers of 2 as they are used
 *    as bitflags when Application asks DSM to present a list of DSs.
  }

{$EXTERNALSYM DG_CONTROL}
  DG_CONTROL    = $0001; { data pertaining to control }
{$EXTERNALSYM DG_IMAGE}
  DG_IMAGE      = $0002; { data pertaining to raster images }
{ Added 1.8 }
{$EXTERNALSYM DG_AUDIO}
  DG_AUDIO      = $0004; { data pertaining to audio }

{***************************************************************************
 * Data Argument Types                                                     *
 *************************************************************************** }

{ SDH - 03/23/95 - WATCH }
{ The thunker requires knowledge about size of data being passed in the }
{ lpData parameter to DS_Entry (which is not readily available due to }
{ type LPVOID. Thus, we key off the DAT_ argument to determine the size. }
{ This has a couple implications: }
{ 1) Any additional DAT_ features require modifications to the thunk code }
{   for thunker support. }
{ 2) Any applications which use the custom capabailites are not supported }
{   under thunking since we have no way of knowing what size data (if }
{   any) is being passed. }

{$EXTERNALSYM DAT_NULL}
  DAT_NULL            = $0000; { No data or structure. }
{$EXTERNALSYM DAT_CUSTOMBASE}
  DAT_CUSTOMBASE      = $8000; { Base of custom DATs. }

{ Data Argument Types for the DG_CONTROL Data Group. }
{$EXTERNALSYM DAT_CAPABILITY}
  DAT_CAPABILITY      = $0001; { TW_CAPABILITY }
{$EXTERNALSYM DAT_EVENT}
  DAT_EVENT           = $0002; { TW_EVENT }
{$EXTERNALSYM DAT_IDENTITY}
  DAT_IDENTITY        = $0003; { TW_IDENTITY }
{$EXTERNALSYM DAT_PARENT}
  DAT_PARENT          = $0004; { TW_HANDLE, application win handle in Windows }
{$EXTERNALSYM DAT_PENDINGXFERS}
  DAT_PENDINGXFERS    = $0005; { TW_PENDINGXFERS }
{$EXTERNALSYM DAT_SETUPMEMXFER}
  DAT_SETUPMEMXFER    = $0006; { TW_SETUPMEMXFER }
{$EXTERNALSYM DAT_SETUPFILEXFER}
  DAT_SETUPFILEXFER   = $0007; { TW_SETUPFILEXFER }
{$EXTERNALSYM DAT_STATUS}
  DAT_STATUS          = $0008; { TW_STATUS }
{$EXTERNALSYM DAT_USERINTERFACE}
  DAT_USERINTERFACE   = $0009; { TW_USERINTERFACE }
{$EXTERNALSYM DAT_XFERGROUP}
  DAT_XFERGROUP       = $000a; { TW_UINT32 }
{ SDH - 03/21/95 - TWUNK }
{ Additional message required for thunker to request the special }
{ identity information. }
{$EXTERNALSYM DAT_TWUNKIDENTITY}
  DAT_TWUNKIDENTITY   = $000b; { TW_TWUNKIDENTITY }
{$EXTERNALSYM DAT_CUSTOMDSDATA}
  DAT_CUSTOMDSDATA    = $000c; { TW_CUSTOMDSDATA. }

{ Added 1.8 }
{$EXTERNALSYM DAT_DEVICEEVENT}
  DAT_DEVICEEVENT     = $000d; { TW_DEVICEEVENT }
{$EXTERNALSYM DAT_FILESYSTEM}
  DAT_FILESYSTEM      = $000e; { TW_FILESYSTEM }
{$EXTERNALSYM DAT_PASSTHRU}
  DAT_PASSTHRU        = $000f; { TW_PASSTHRU }

{ Data Argument Types for the DG_IMAGE Data Group. }
{$EXTERNALSYM DAT_IMAGEINFO}
  DAT_IMAGEINFO       = $0101; { TW_IMAGEINFO }
{$EXTERNALSYM DAT_IMAGELAYOUT}
  DAT_IMAGELAYOUT     = $0102; { TW_IMAGELAYOUT }
{$EXTERNALSYM DAT_IMAGEMEMXFER}
  DAT_IMAGEMEMXFER    = $0103; { TW_IMAGEMEMXFER }
{$EXTERNALSYM DAT_IMAGENATIVEXFER}
  DAT_IMAGENATIVEXFER = $0104; { TW_UINT32 loword is hDIB, PICHandle }
{$EXTERNALSYM DAT_IMAGEFILEXFER}
  DAT_IMAGEFILEXFER   = $0105; { Null data }
{$EXTERNALSYM DAT_CIECOLOR}
  DAT_CIECOLOR        = $0106; { TW_CIECOLOR }
{$EXTERNALSYM DAT_GRAYRESPONSE}
  DAT_GRAYRESPONSE    = $0107; { TW_GRAYRESPONSE }
{$EXTERNALSYM DAT_RGBRESPONSE}
  DAT_RGBRESPONSE     = $0108; { TW_RGBRESPONSE }
{$EXTERNALSYM DAT_JPEGCOMPRESSION}
  DAT_JPEGCOMPRESSION = $0109; { TW_JPEGCOMPRESSION }
{$EXTERNALSYM DAT_PALETTE8}
  DAT_PALETTE8        = $010a; { TW_PALETTE8 }
{$EXTERNALSYM DAT_EXTIMAGEINFO}
  DAT_EXTIMAGEINFO    = $010b; { TW_EXTIMAGEINFO -- for 1.7 Spec. }

{ Added 1.8 }
{ Data Argument Types for the DG_AUDIO Data Group. }
{$EXTERNALSYM DAT_AUDIOFILEXFER}
  DAT_AUDIOFILEXFER   = $0201; { Null data }
{$EXTERNALSYM DAT_AUDIOINFO}
  DAT_AUDIOINFO       = $0202; { TW_AUDIOINFO }
{$EXTERNALSYM DAT_AUDIONATIVEXFER}
  DAT_AUDIONATIVEXFER = $0203; { TW_UINT32 handle to WAV, (AIFF Mac) }

{***************************************************************************
 * Messages                                                                *
 *************************************************************************** }

{ All message constants are unique.
 * Messages are grouped according to which DATs they are used with. }

{$EXTERNALSYM MSG_NULL}
  MSG_NULL        = $0000; { Used in TW_EVENT structure }
{$EXTERNALSYM MSG_CUSTOMBASE}
  MSG_CUSTOMBASE  = $8000; { Base of custom messages }

{ Generic messages may be used with any of several DATs. }
{$EXTERNALSYM MSG_GET}
  MSG_GET               = $0001; { Get one or more values }
{$EXTERNALSYM MSG_GETCURRENT}
  MSG_GETCURRENT        = $0002; { Get current value }
{$EXTERNALSYM MSG_GETDEFAULT}
  MSG_GETDEFAULT        = $0003; { Get default (e.g. power up) value }
{$EXTERNALSYM MSG_GETFIRST}
  MSG_GETFIRST          = $0004; { Get first of a series of items, e.g. DSs }
{$EXTERNALSYM MSG_GETNEXT}
  MSG_GETNEXT           = $0005; { Iterate through a series of items. }
{$EXTERNALSYM MSG_SET}
  MSG_SET               = $0006; { Set one or more values }
{$EXTERNALSYM MSG_RESET}
  MSG_RESET             = $0007; { Set current value to default value }
{$EXTERNALSYM MSG_QUERYSUPPORT}
  MSG_QUERYSUPPORT      = $0008; { Get supported operations on the cap. }

{ Messages used with DAT_NULL }
{$EXTERNALSYM MSG_XFERREADY}
  MSG_XFERREADY         = $0101; { The data source has data ready }
{$EXTERNALSYM MSG_CLOSEDSREQ}
  MSG_CLOSEDSREQ        = $0102; { Request for Application. to close DS }
{$EXTERNALSYM MSG_CLOSEDSOK}
  MSG_CLOSEDSOK         = $0103; { Tell the Application. to save the state. }
{ Added 1.8 }
{$EXTERNALSYM MSG_DEVICEEVENT}
  MSG_DEVICEEVENT      = $0104; { Some event has taken place }

{ Messages used with a pointer to a DAT_STATUS structure }
{$EXTERNALSYM MSG_CHECKSTATUS}
  MSG_CHECKSTATUS      = $0201; { Get status information }

{ Messages used with a pointer to DAT_PARENT data }
{$EXTERNALSYM MSG_OPENDSM}
  MSG_OPENDSM          = $0301; { Open the DSM }
{$EXTERNALSYM MSG_CLOSEDSM}
  MSG_CLOSEDSM         = $0302; { Close the DSM }

{ Messages used with a pointer to a DAT_IDENTITY structure }
{$EXTERNALSYM MSG_OPENDS}
  MSG_OPENDS           = $0401; { Open a data source }
{$EXTERNALSYM MSG_CLOSEDS}
  MSG_CLOSEDS          = $0402; { Close a data source }
{$EXTERNALSYM MSG_USERSELECT}
  MSG_USERSELECT       = $0403; { Put up a dialog of all DS }

{ Messages used with a pointer to a DAT_USERINTERFACE structure }
{$EXTERNALSYM MSG_DISABLEDS}
  MSG_DISABLEDS        = $0501; { Disable data transfer in the DS }
{$EXTERNALSYM MSG_ENABLEDS}
  MSG_ENABLEDS         = $0502; { Enable data transfer in the DS }
{$EXTERNALSYM MSG_ENABLEDSUIONLY}
  MSG_ENABLEDSUIONLY   = $0503; { Enable for saving DS state only. }

{ Messages used with a pointer to a DAT_EVENT structure }
{$EXTERNALSYM MSG_PROCESSEVENT}
  MSG_PROCESSEVENT     = $0601;

{ Messages used with a pointer to a DAT_PENDINGXFERS structure }
{$EXTERNALSYM MSG_ENDXFER}
  MSG_ENDXFER          = $0701;

{ Added 1.8 }
{ Messages used with a pointer to a DAT_FILESYSTEM structure }
{$EXTERNALSYM MSG_CHANGEDIRECTORY}
  MSG_CHANGEDIRECTORY  = $0801;
{$EXTERNALSYM MSG_CREATEDIRECTORY}
  MSG_CREATEDIRECTORY  = $0802;
{$EXTERNALSYM MSG_DELETE}
  MSG_DELETE           = $0803;
{$EXTERNALSYM MSG_FORMATMEDIA}
  MSG_FORMATMEDIA      = $0804;
{$EXTERNALSYM MSG_GETCLOSE}
  MSG_GETCLOSE         = $0805;
{$EXTERNALSYM MSG_GETFIRSTFILE}
  MSG_GETFIRSTFILE     = $0806;
{$EXTERNALSYM MSG_GETINFO}
  MSG_GETINFO          = $0807;
{$EXTERNALSYM MSG_GETNEXTFILE}
  MSG_GETNEXTFILE      = $0808;
{$EXTERNALSYM MSG_RENAME}
  MSG_RENAME           = $0809;

{ Messages used with a pointer to a DAT_PASSTHRU structure }
{$EXTERNALSYM MSG_PASSTHRU}
  MSG_PASSTHRU     = $0901;

{***************************************************************************
 * Capabilities                                                            *
 *************************************************************************** }

{$EXTERNALSYM CAP_CUSTOMBASE}
  CAP_CUSTOMBASE                   = $8000; { Base of custom capabilities }

{ all data sources are REQUIRED to support these caps }
{$EXTERNALSYM CAP_XFERCOUNT}
  CAP_XFERCOUNT                    = $0001;

{ image data sources are REQUIRED to support these caps }
{$EXTERNALSYM ICAP_COMPRESSION}
  ICAP_COMPRESSION                 = $0100;
{$EXTERNALSYM ICAP_PIXELTYPE}
  ICAP_PIXELTYPE                   = $0101;
{$EXTERNALSYM ICAP_UNITS}
  ICAP_UNITS                       = $0102; { default is TWUN_INCHES }
{$EXTERNALSYM ICAP_XFERMECH}
  ICAP_XFERMECH                    = $0103;

{ all data sources MAY support these caps }
{$EXTERNALSYM CAP_AUTHOR}
  CAP_AUTHOR                       = $1000;
{$EXTERNALSYM CAP_CAPTION}
  CAP_CAPTION                      = $1001;
{$EXTERNALSYM CAP_FEEDERENABLED}
  CAP_FEEDERENABLED                = $1002;
{$EXTERNALSYM CAP_FEEDERLOADED}
  CAP_FEEDERLOADED                 = $1003;
{$EXTERNALSYM CAP_TIMEDATE}
  CAP_TIMEDATE                     = $1004;
{$EXTERNALSYM CAP_SUPPORTEDCAPS}
  CAP_SUPPORTEDCAPS                = $1005;
{$EXTERNALSYM CAP_EXTENDEDCAPS}
  CAP_EXTENDEDCAPS                 = $1006;
{$EXTERNALSYM CAP_AUTOFEED}
  CAP_AUTOFEED                     = $1007;
{$EXTERNALSYM CAP_CLEARPAGE}
  CAP_CLEARPAGE                    = $1008;
{$EXTERNALSYM CAP_FEEDPAGE}
  CAP_FEEDPAGE                     = $1009;
{$EXTERNALSYM CAP_REWINDPAGE}
  CAP_REWINDPAGE                   = $100a;
{$EXTERNALSYM CAP_INDICATORS}
  CAP_INDICATORS                   = $100b;  { Added 1.1 }
{$EXTERNALSYM CAP_SUPPORTEDCAPSEXT}
  CAP_SUPPORTEDCAPSEXT             = $100c;  { Added 1.6 }
{$EXTERNALSYM CAP_PAPERDETECTABLE}
  CAP_PAPERDETECTABLE              = $100d;  { Added 1.6 }
{$EXTERNALSYM CAP_UICONTROLLABLE}
  CAP_UICONTROLLABLE               = $100e;  { Added 1.6 }
{$EXTERNALSYM CAP_DEVICEONLINE}
  CAP_DEVICEONLINE                 = $100f;  { Added 1.6 }
{$EXTERNALSYM CAP_AUTOSCAN}
  CAP_AUTOSCAN                     = $1010;  { Added 1.6 }
{$EXTERNALSYM CAP_THUMBNAILSENABLED}
  CAP_THUMBNAILSENABLED            = $1011;  { Added 1.7 }
{$EXTERNALSYM CAP_DUPLEX}
  CAP_DUPLEX                       = $1012;  { Added 1.7 }
{$EXTERNALSYM CAP_DUPLEXENABLED}
  CAP_DUPLEXENABLED                = $1013;  { Added 1.7 }
{$EXTERNALSYM CAP_ENABLEDSUIONLY}
  CAP_ENABLEDSUIONLY               = $1014;  { Added 1.7 }
{$EXTERNALSYM CAP_CUSTOMDSDATA}
  CAP_CUSTOMDSDATA                 = $1015;  { Added 1.7 }
{$EXTERNALSYM CAP_ENDORSER}
  CAP_ENDORSER                     = $1016;  { Added 1.7 }
{$EXTERNALSYM CAP_JOBCONTROL}
  CAP_JOBCONTROL                   = $1017;  { Added 1.7 }
{$EXTERNALSYM CAP_ALARMS}
  CAP_ALARMS                       = $1018;  { Added 1.8 }
{$EXTERNALSYM CAP_ALARMVOLUME}
  CAP_ALARMVOLUME                  = $1019;  { Added 1.8 }
{$EXTERNALSYM CAP_AUTOMATICCAPTURE}
  CAP_AUTOMATICCAPTURE             = $101a;  { Added 1.8 }
{$EXTERNALSYM CAP_TIMEBEFOREFIRSTCAPTURE}
  CAP_TIMEBEFOREFIRSTCAPTURE       = $101b;  { Added 1.8 }
{$EXTERNALSYM CAP_TIMEBETWEENCAPTURES}
  CAP_TIMEBETWEENCAPTURES          = $101c;  { Added 1.8 }
{$EXTERNALSYM CAP_CLEARBUFFERS}
  CAP_CLEARBUFFERS                 = $101d;  { Added 1.8 }
{$EXTERNALSYM CAP_MAXBATCHBUFFERS}
  CAP_MAXBATCHBUFFERS              = $101e;  { Added 1.8 }
{$EXTERNALSYM CAP_DEVICETIMEDATE}
  CAP_DEVICETIMEDATE               = $101f;  { Added 1.8 }
{$EXTERNALSYM CAP_POWERSUPPLY}
  CAP_POWERSUPPLY                  = $1020;  { Added 1.8 }
{$EXTERNALSYM CAP_CAMERAPREVIEWUI}
  CAP_CAMERAPREVIEWUI              = $1021;  { Added 1.8 }
{$EXTERNALSYM CAP_DEVICEEVENT}
  CAP_DEVICEEVENT                  = $1022;  { Added 1.8 }
{$EXTERNALSYM CAP_PAGEMULTIPLEACQUIRE}
  CAP_PAGEMULTIPLEACQUIRE          = $1023;  { Added 1.8 }
{$EXTERNALSYM CAP_SERIALNUMBER}
  CAP_SERIALNUMBER                 = $1024;  { Added 1.8 }
{$EXTERNALSYM CAP_FILESYSTEM}
  CAP_FILESYSTEM                   = $1025;  { Added 1.8 }
{$EXTERNALSYM CAP_PRINTER}
  CAP_PRINTER                      = $1026;  { Added 1.8 }
{$EXTERNALSYM CAP_PRINTERENABLED}
  CAP_PRINTERENABLED               = $1027;  { Added 1.8 }
{$EXTERNALSYM CAP_PRINTERINDEX}
  CAP_PRINTERINDEX                 = $1028;  { Added 1.8 }
{$EXTERNALSYM CAP_PRINTERMODE}
  CAP_PRINTERMODE                  = $1029;  { Added 1.8 }
{$EXTERNALSYM CAP_PRINTERSTRING}
  CAP_PRINTERSTRING                = $102a;  { Added 1.8 }
{$EXTERNALSYM CAP_PRINTERSUFFIX}
  CAP_PRINTERSUFFIX                = $102b;  { Added 1.8 }
{$EXTERNALSYM CAP_LANGUAGE}
  CAP_LANGUAGE                     = $102c;  { Added 1.8 }
{$EXTERNALSYM CAP_FEEDERALIGNMENT}
  CAP_FEEDERALIGNMENT              = $102d;  { Added 1.8 }
{$EXTERNALSYM CAP_FEEDERORDER}
  CAP_FEEDERORDER                  = $102e;  { Added 1.8 }
{$EXTERNALSYM CAP_PAPERBINDING}
  CAP_PAPERBINDING                 = $102f;  { Added 1.8 }
{$EXTERNALSYM CAP_REACQUIREALLOWED}
  CAP_REACQUIREALLOWED             = $1030;  { Added 1.8 }
{$EXTERNALSYM CAP_PASSTHRU}
  CAP_PASSTHRU                     = $1031;  { Added 1.8 }
{$EXTERNALSYM CAP_BATTERYMINUTES}
  CAP_BATTERYMINUTES               = $1032;  { Added 1.8 }
{$EXTERNALSYM CAP_BATTERYPERCENTAGE}
  CAP_BATTERYPERCENTAGE            = $1033;  { Added 1.8 }
{$EXTERNALSYM CAP_POWERDOWNTIME}
  CAP_POWERDOWNTIME                = $1034;  { Added 1.8 }

{ image data sources MAY support these caps }
{$EXTERNALSYM ICAP_AUTOBRIGHT}
  ICAP_AUTOBRIGHT                  = $1100;
{$EXTERNALSYM ICAP_BRIGHTNESS}
  ICAP_BRIGHTNESS                  = $1101;
{$EXTERNALSYM ICAP_CONTRAST}
  ICAP_CONTRAST                    = $1103;
{$EXTERNALSYM ICAP_CUSTHALFTONE}
  ICAP_CUSTHALFTONE                = $1104;
{$EXTERNALSYM ICAP_EXPOSURETIME}
  ICAP_EXPOSURETIME                = $1105;
{$EXTERNALSYM ICAP_FILTER}
  ICAP_FILTER                      = $1106;
{$EXTERNALSYM ICAP_FLASHUSED}
  ICAP_FLASHUSED                   = $1107;
{$EXTERNALSYM ICAP_GAMMA}
  ICAP_GAMMA                       = $1108;
{$EXTERNALSYM ICAP_HALFTONES}
  ICAP_HALFTONES                   = $1109;
{$EXTERNALSYM ICAP_HIGHLIGHT}
  ICAP_HIGHLIGHT                   = $110a;
{$EXTERNALSYM ICAP_IMAGEFILEFORMAT}
  ICAP_IMAGEFILEFORMAT             = $110c;
{$EXTERNALSYM ICAP_LAMPSTATE}
  ICAP_LAMPSTATE                   = $110d;
{$EXTERNALSYM ICAP_LIGHTSOURCE}
  ICAP_LIGHTSOURCE                 = $110e;
{$EXTERNALSYM ICAP_ORIENTATION}
  ICAP_ORIENTATION                 = $1110;
{$EXTERNALSYM ICAP_PHYSICALWIDTH}
  ICAP_PHYSICALWIDTH               = $1111;
{$EXTERNALSYM ICAP_PHYSICALHEIGHT}
  ICAP_PHYSICALHEIGHT              = $1112;
{$EXTERNALSYM ICAP_SHADOW}
  ICAP_SHADOW                      = $1113;
{$EXTERNALSYM ICAP_FRAMES}
  ICAP_FRAMES                      = $1114;
{$EXTERNALSYM ICAP_XNATIVERESOLUTION}
  ICAP_XNATIVERESOLUTION           = $1116;
{$EXTERNALSYM ICAP_YNATIVERESOLUTION}
  ICAP_YNATIVERESOLUTION           = $1117;
{$EXTERNALSYM ICAP_XRESOLUTION}
  ICAP_XRESOLUTION                 = $1118;
{$EXTERNALSYM ICAP_YRESOLUTION}
  ICAP_YRESOLUTION                 = $1119;
{$EXTERNALSYM ICAP_MAXFRAMES}
  ICAP_MAXFRAMES                   = $111a;
{$EXTERNALSYM ICAP_TILES}
  ICAP_TILES                       = $111b;
{$EXTERNALSYM ICAP_BITORDER}
  ICAP_BITORDER                    = $111c;
{$EXTERNALSYM ICAP_CCITTKFACTOR}
  ICAP_CCITTKFACTOR                = $111d;
{$EXTERNALSYM ICAP_LIGHTPATH}
  ICAP_LIGHTPATH                   = $111e;
{$EXTERNALSYM ICAP_PIXELFLAVOR}
  ICAP_PIXELFLAVOR                 = $111f;
{$EXTERNALSYM ICAP_PLANARCHUNKY}
  ICAP_PLANARCHUNKY                = $1120;
{$EXTERNALSYM ICAP_ROTATION}
  ICAP_ROTATION                    = $1121;
{$EXTERNALSYM ICAP_SUPPORTEDSIZES}
  ICAP_SUPPORTEDSIZES              = $1122;
{$EXTERNALSYM ICAP_THRESHOLD}
  ICAP_THRESHOLD                   = $1123;
{$EXTERNALSYM ICAP_XSCALING}
  ICAP_XSCALING                    = $1124;
{$EXTERNALSYM ICAP_YSCALING}
  ICAP_YSCALING                    = $1125;
{$EXTERNALSYM ICAP_BITORDERCODES}
  ICAP_BITORDERCODES               = $1126;
{$EXTERNALSYM ICAP_PIXELFLAVORCODES}
  ICAP_PIXELFLAVORCODES            = $1127;
{$EXTERNALSYM ICAP_JPEGPIXELTYPE}
  ICAP_JPEGPIXELTYPE               = $1128;
{$EXTERNALSYM ICAP_TIMEFILL}
  ICAP_TIMEFILL                    = $112a;
{$EXTERNALSYM ICAP_BITDEPTH}
  ICAP_BITDEPTH                    = $112b;
{$EXTERNALSYM  ICAP_BITDEPTHREDUCTION}
  ICAP_BITDEPTHREDUCTION           = $112c; { Added 1.5 }
{$EXTERNALSYM ICAP_UNDEFINEDIMAGESIZE}
  ICAP_UNDEFINEDIMAGESIZE          = $112d; { Added 1.6 }
{$EXTERNALSYM ICAP_IMAGEDATASET}
  ICAP_IMAGEDATASET                = $112e; { Added 1.7 }
{$EXTERNALSYM ICAP_EXTIMAGEINFO}
  ICAP_EXTIMAGEINFO                = $112f; { Added 1.7 }
{$EXTERNALSYM ICAP_MINIMUMHEIGHT}
  ICAP_MINIMUMHEIGHT               = $1130; { Added 1.7 }
{$EXTERNALSYM ICAP_MINIMUMWIDTH}
  ICAP_MINIMUMWIDTH                = $1131; { Added 1.7 }
{$EXTERNALSYM ICAP_AUTODISCARDBLANKPAGES}
  ICAP_AUTODISCARDBLANKPAGES       = $1134; { Added 1.8 }
{$EXTERNALSYM ICAP_FLIPROTATION}
  ICAP_FLIPROTATION                = $1136; { Added 1.8 }
{$EXTERNALSYM ICAP_BARCODEDETECTIONENABLED}
  ICAP_BARCODEDETECTIONENABLED     = $1137; { Added 1.8 }
{$EXTERNALSYM ICAP_SUPPORTEDBARCODETYPES}
  ICAP_SUPPORTEDBARCODETYPES       = $1138; { Added 1.8 }
{$EXTERNALSYM ICAP_BARCODEMAXSEARCHPRIORITIES}
  ICAP_BARCODEMAXSEARCHPRIORITIES  = $1139; { Added 1.8 }
{$EXTERNALSYM ICAP_BARCODESEARCHPRIORITIES}
  ICAP_BARCODESEARCHPRIORITIES     = $113a; { Added 1.8 }
{$EXTERNALSYM ICAP_BARCODESEARCHMODE}
  ICAP_BARCODESEARCHMODE           = $113b; { Added 1.8 }
{$EXTERNALSYM ICAP_BARCODEMAXRETRIES}
  ICAP_BARCODEMAXRETRIES           = $113c; { Added 1.8 }
{$EXTERNALSYM ICAP_BARCODETIMEOUT}
  ICAP_BARCODETIMEOUT              = $113d; { Added 1.8 }
{$EXTERNALSYM ICAP_ZOOMFACTOR}
  ICAP_ZOOMFACTOR                  = $113e; { Added 1.8 }
{$EXTERNALSYM ICAP_PATCHCODEDETECTIONENABLED}
  ICAP_PATCHCODEDETECTIONENABLED   = $113f; { Added 1.8 }
{$EXTERNALSYM ICAP_SUPPORTEDPATCHCODETYPES}
  ICAP_SUPPORTEDPATCHCODETYPES     = $1140; { Added 1.8 }
{$EXTERNALSYM ICAP_PATCHCODEMAXSEARCHPRIORITIES}
  ICAP_PATCHCODEMAXSEARCHPRIORITIES= $1141; { Added 1.8 }
{$EXTERNALSYM ICAP_PATCHCODESEARCHPRIORITIES}
  ICAP_PATCHCODESEARCHPRIORITIES   = $1142; { Added 1.8 }
{$EXTERNALSYM ICAP_PATCHCODESEARCHMODE}
  ICAP_PATCHCODESEARCHMODE         = $1143; { Added 1.8 }
{$EXTERNALSYM ICAP_PATCHCODEMAXRETRIES}
  ICAP_PATCHCODEMAXRETRIES         = $1144; { Added 1.8 }
{$EXTERNALSYM ICAP_PATCHCODETIMEOUT}
  ICAP_PATCHCODETIMEOUT            = $1145; { Added 1.8 }
{$EXTERNALSYM ICAP_FLASHUSED2}
  ICAP_FLASHUSED2                  = $1146; { Added 1.8 }
{$EXTERNALSYM ICAP_IMAGEFILTER}
  ICAP_IMAGEFILTER                 = $1147; { Added 1.8 }
{$EXTERNALSYM ICAP_NOISEFILTER}
  ICAP_NOISEFILTER                 = $1148; { Added 1.8 }
{$EXTERNALSYM ICAP_OVERSCAN}
  ICAP_OVERSCAN                    = $1149; { Added 1.8 }
{$EXTERNALSYM ICAP_AUTOMATICBORDERDETECTION}
  ICAP_AUTOMATICBORDERDETECTION    = $1150; { Added 1.8 }
{$EXTERNALSYM ICAP_AUTOMATICDESKEW}
  ICAP_AUTOMATICDESKEW             = $1151; { Added 1.8 }
{$EXTERNALSYM ICAP_AUTOMATICROTATE}
  ICAP_AUTOMATICROTATE             = $1152; { Added 1.8 }

{ image data sources MAY support these audio caps }
{$EXTERNALSYM ACAP_AUDIOFILEFORMAT}
  ACAP_AUDIOFILEFORMAT             = $1201; { Added 1.8 }
{$EXTERNALSYM ACAP_XFERMECH}
  ACAP_XFERMECH                    = $1202; { Added 1.8 }

{ -----------------------------------------------------------------------

  Version 1.7:   Following is Extended Image Info Attributes.
  July 1997
  KHL

  ----------------------------------------------------------------------- }

  {$EXTERNALSYM TWEI_BARCODEX}
  TWEI_BARCODEX          = $1200;
  {$EXTERNALSYM TWEI_BARCODEY}
  TWEI_BARCODEY          = $1201;
  {$EXTERNALSYM TWEI_BARCODETEXT}
  TWEI_BARCODETEXT       = $1202;
  {$EXTERNALSYM TWEI_BARCODETYPE}
  TWEI_BARCODETYPE       = $1203;
  {$EXTERNALSYM TWEI_DESHADETOP}
  TWEI_DESHADETOP        = $1204;
  {$EXTERNALSYM TWEI_DESHADELEFT}
  TWEI_DESHADELEFT       = $1205;
  {$EXTERNALSYM TWEI_DESHADEHEIGHT}
  TWEI_DESHADEHEIGHT     = $1206;
  {$EXTERNALSYM TWEI_DESHADEWIDTH}
  TWEI_DESHADEWIDTH      = $1207;
  {$EXTERNALSYM TWEI_DESHADESIZE}
  TWEI_DESHADESIZE       = $1208;
  {$EXTERNALSYM TWEI_SPECKLESREMOVED}
  TWEI_SPECKLESREMOVED   = $1209;
  {$EXTERNALSYM TWEI_HORZLINEXCOORD}
  TWEI_HORZLINEXCOORD    = $120A;
  {$EXTERNALSYM TWEI_HORZLINEYCOORD}
  TWEI_HORZLINEYCOORD    = $120B;
  {$EXTERNALSYM TWEI_HORZLINELENGTH}
  TWEI_HORZLINELENGTH    = $120C;
  {$EXTERNALSYM TWEI_HORZLINETHICKNESS}
  TWEI_HORZLINETHICKNESS = $120D;
  {$EXTERNALSYM TWEI_VERTLINEXCOORD}
  TWEI_VERTLINEXCOORD    = $120E;
  {$EXTERNALSYM TWEI_VERTLINEYCOORD}
  TWEI_VERTLINEYCOORD    = $120F;
  {$EXTERNALSYM TWEI_VERTLINELENGTH}
  TWEI_VERTLINELENGTH    = $1210;
  {$EXTERNALSYM TWEI_VERTLINETHICKNESS}
  TWEI_VERTLINETHICKNESS = $1211;
  {$EXTERNALSYM TWEI_PATCHCODE}
  TWEI_PATCHCODE         = $1212;
  {$EXTERNALSYM TWEI_ENDORSEDTEXT}
  TWEI_ENDORSEDTEXT      = $1213;
  {$EXTERNALSYM TWEI_FORMCONFIDENCE}
  TWEI_FORMCONFIDENCE    = $1214;
  {$EXTERNALSYM TWEI_FORMTEMPLATEMATCH}
  TWEI_FORMTEMPLATEMATCH = $1215;
  {$EXTERNALSYM TWEI_FORMTEMPLATEPAGEMATCH}
  TWEI_FORMTEMPLATEPAGEMATCH = $1216;
  {$EXTERNALSYM TWEI_FORMHORZDOCOFFSET}
  TWEI_FORMHORZDOCOFFSET = $1217;
  {$EXTERNALSYM TWEI_FORMVERTDOCOFFSET}
  TWEI_FORMVERTDOCOFFSET = $1218;
  {$EXTERNALSYM TWEI_BARCODECOUNT}
  TWEI_BARCODECOUNT      = $1219;
  {$EXTERNALSYM TWEI_BARCODECONFIDENCE}
  TWEI_BARCODECONFIDENCE = $121A;
  {$EXTERNALSYM TWEI_BARCODEROTATION}
  TWEI_BARCODEROTATION   = $121B;
  {$EXTERNALSYM TWEI_BARCODETEXTLENGTH}
  TWEI_BARCODETEXTLENGTH = $121C;
  {$EXTERNALSYM TWEI_DESHADECOUNT}
  TWEI_DESHADECOUNT      = $121D;
  {$EXTERNALSYM TWEI_DESHADEBLACKCOUNTOLD}
  TWEI_DESHADEBLACKCOUNTOLD = $121E;
  {$EXTERNALSYM TWEI_DESHADEBLACKCOUNTNEW}
  TWEI_DESHADEBLACKCOUNTNEW = $121F;
  {$EXTERNALSYM TWEI_DESHADEBLACKRLMIN}
  TWEI_DESHADEBLACKRLMIN    = $1220;
  {$EXTERNALSYM TWEI_DESHADEBLACKRLMAX}
  TWEI_DESHADEBLACKRLMAX    = $1221;
  {$EXTERNALSYM TWEI_DESHADEWHITECOUNTOLD}
  TWEI_DESHADEWHITECOUNTOLD = $1222;
  {$EXTERNALSYM TWEI_DESHADEWHITECOUNTNEW}
  TWEI_DESHADEWHITECOUNTNEW = $1223;
  {$EXTERNALSYM TWEI_DESHADEWHITERLMIN}
  TWEI_DESHADEWHITERLMIN    = $1224;
  {$EXTERNALSYM TWEI_DESHADEWHITERLAVE}
  TWEI_DESHADEWHITERLAVE    = $1225;
  {$EXTERNALSYM TWEI_DESHADEWHITERLMAX}
  TWEI_DESHADEWHITERLMAX    = $1226;
  {$EXTERNALSYM TWEI_BLACKSPECKLESREMOVED}
  TWEI_BLACKSPECKLESREMOVED = $1227;
  {$EXTERNALSYM TWEI_WHITESPECKLESREMOVED}
  TWEI_WHITESPECKLESREMOVED = $1228;
  {$EXTERNALSYM TWEI_HORZLINECOUNT}
  TWEI_HORZLINECOUNT     = $1229;
  {$EXTERNALSYM TWEI_VERTLINECOUNT}
  TWEI_VERTLINECOUNT     = $122A;
  {$EXTERNALSYM TWEI_DESKEWSTATUS}
  TWEI_DESKEWSTATUS      = $122B;
  {$EXTERNALSYM TWEI_SKEWORIGINALANGLE}
  TWEI_SKEWORIGINALANGLE = $122C;
  {$EXTERNALSYM TWEI_SKEWFINALANGLE}
  TWEI_SKEWFINALANGLE    = $122D;
  {$EXTERNALSYM TWEI_SKEWCONFIDENCE}
  TWEI_SKEWCONFIDENCE    = $122E;
  {$EXTERNALSYM TWEI_SKEWWINDOWX1}
  TWEI_SKEWWINDOWX1      = $122F;
  {$EXTERNALSYM TWEI_SKEWWINDOWY1}
  TWEI_SKEWWINDOWY1      = $1230;
  {$EXTERNALSYM TWEI_SKEWWINDOWX2}
  TWEI_SKEWWINDOWX2      = $1231;
  {$EXTERNALSYM TWEI_SKEWWINDOWY2}
  TWEI_SKEWWINDOWY2      = $1232;
  {$EXTERNALSYM TWEI_SKEWWINDOWX3}
  TWEI_SKEWWINDOWX3      = $1233;
  {$EXTERNALSYM TWEI_SKEWWINDOWY3}
  TWEI_SKEWWINDOWY3      = $1234;
  {$EXTERNALSYM TWEI_SKEWWINDOWX4}
  TWEI_SKEWWINDOWX4      = $1235;
  {$EXTERNALSYM TWEI_SKEWWINDOWY4}
  TWEI_SKEWWINDOWY4      = $1236;

  {$EXTERNALSYM TWEJ_NONE}
  TWEJ_NONE           = $0000;
  {$EXTERNALSYM TWEJ_MIDSEPARATOR}
  TWEJ_MIDSEPARATOR   = $0001;
  {$EXTERNALSYM TWEJ_PATCH1}
  TWEJ_PATCH1         = $0002;
  {$EXTERNALSYM TWEJ_PATCH2}
  TWEJ_PATCH2         = $0003;
  {$EXTERNALSYM TWEJ_PATCH3}
  TWEJ_PATCH3         = $0004;
  {$EXTERNALSYM TWEJ_PATCH4}
  TWEJ_PATCH4         = $0005;
  {$EXTERNALSYM TWEJ_PATCH6}
  TWEJ_PATCH6         = $0006;
  {$EXTERNALSYM TWEJ_PATCHT}
  TWEJ_PATCHT         = $0007;

{**************************************************************************
 *      Return Codes and Condition Codes section                          *
 ************************************************************************** }

{ Return Codes: DSM_Entry and DS_Entry may return any one of these values. }
  {$EXTERNALSYM TWRC_CUSTOMBASE}
  TWRC_CUSTOMBASE   = $8000;

  {$EXTERNALSYM TWRC_SUCCESS}
  TWRC_SUCCESS      =  0;
  {$EXTERNALSYM TWRC_FAILURE}
  TWRC_FAILURE      =  1; { Application may get TW_STATUS for info on failure }
  {$EXTERNALSYM TWRC_CHECKSTATUS}
  TWRC_CHECKSTATUS  =  2; { "tried hard": ; get status }
  {$EXTERNALSYM TWRC_CANCEL}
  TWRC_CANCEL       =  3;
  {$EXTERNALSYM TWRC_DSEVENT}
  TWRC_DSEVENT      =  4;
  {$EXTERNALSYM TWRC_NOTDSEVENT}
  TWRC_NOTDSEVENT   =  5;
  {$EXTERNALSYM TWRC_XFERDONE}
  TWRC_XFERDONE     =  6;
  {$EXTERNALSYM TWRC_ENDOFLIST}
  TWRC_ENDOFLIST    =  7; { After MSG_GETNEXT if nothing left }
  {$EXTERNALSYM TWRC_INFONOTSUPPORTED}
  TWRC_INFONOTSUPPORTED =  8;
  {$EXTERNALSYM TWRC_DATANOTAVAILABLE}
  TWRC_DATANOTAVAILABLE =  9;

{ Condition Codes: Application gets these by doing DG_CONTROL DAT_STATUS MSG_GET. }
  {$EXTERNALSYM TWCC_CUSTOMBASE}
  TWCC_CUSTOMBASE     = $8000;

  {$EXTERNALSYM TWCC_SUCCESS}
  TWCC_SUCCESS           =  0; { It worked! }
  {$EXTERNALSYM TWCC_BUMMER}
  TWCC_BUMMER            =  1; { Failure due to unknown causes }
  {$EXTERNALSYM TWCC_LOWMEMORY}
  TWCC_LOWMEMORY         =  2; { Not enough memory to perform operation }
  {$EXTERNALSYM TWCC_NODS}
  TWCC_NODS              =  3; { No Data Source }
  {$EXTERNALSYM TWCC_MAXCONNECTIONS}
  TWCC_MAXCONNECTIONS    =  4; { DS is connected to max possible applications }
  {$EXTERNALSYM TWCC_OPERATIONERROR}
  TWCC_OPERATIONERROR    =  5; { DS or DSM reported error, application shouldn't }
  {$EXTERNALSYM TWCC_BADCAP}
  TWCC_BADCAP            =  6; { Unknown capability }
  {$EXTERNALSYM TWCC_BADPROTOCOL}
  TWCC_BADPROTOCOL       =  9; { Unrecognized MSG DG DAT combination }
  {$EXTERNALSYM TWCC_BADVALUE}
  TWCC_BADVALUE          =  10; { Data parameter out of range }
  {$EXTERNALSYM TWCC_SEQERROR}
  TWCC_SEQERROR          =  11; { DG DAT MSG out of expected sequence }
  {$EXTERNALSYM TWCC_BADDEST}
  TWCC_BADDEST           =  12; { Unknown destination Application/Source in DSM_Entry }
  {$EXTERNALSYM TWCC_CAPUNSUPPORTED}
  TWCC_CAPUNSUPPORTED    =  13; { Capability not supported by source }
  {$EXTERNALSYM TWCC_CAPBADOPERATION}
  TWCC_CAPBADOPERATION   =  14; { Operation not supported by capability }
  {$EXTERNALSYM TWCC_CAPSEQERROR}
  TWCC_CAPSEQERROR       =  15; { Capability has dependancy on other capability }

{ Added 1.8 }
  {$EXTERNALSYM TWCC_DENIED}
  TWCC_DENIED            =  16; { File System operation is denied (file is protected) }
  {$EXTERNALSYM TWCC_FILEEXISTS}
  TWCC_FILEEXISTS        =  17; { Operation failed because file already exists. }
  {$EXTERNALSYM TWCC_FILENOTFOUND}
  TWCC_FILENOTFOUND      =  18; { File not found }
  {$EXTERNALSYM TWCC_NOTEMPTY}
  TWCC_NOTEMPTY          =  19; { Operation failed because directory is not empty }
  {$EXTERNALSYM TWCC_PAPERJAM}
  TWCC_PAPERJAM          =  20; { The feeder is jammed }
  {$EXTERNALSYM TWCC_PAPERDOUBLEFEED}
  TWCC_PAPERDOUBLEFEED   =  21; { The feeder detected multiple pages }
  {$EXTERNALSYM TWCC_FILEWRITEERROR}
  TWCC_FILEWRITEERROR    =  22; { Error writing the file (meant for things like disk full conditions) }
  {$EXTERNALSYM TWCC_CHECKDEVICEONLINE}
  TWCC_CHECKDEVICEONLINE =  23; { The device went offline prior to or during this operation }


{ bit patterns: for query the operation that are supported by the data source on a capability }
{ Application gets these through DG_CONTROL/DAT_CAPABILITY/MSG_QUERYSUPPORT }
{ Added 1.6 }
  {$EXTERNALSYM TWQC_GET}
  TWQC_GET        = $0001;
  {$EXTERNALSYM TWQC_SET}
  TWQC_SET        = $0002;
  {$EXTERNALSYM TWQC_GETDEFAULT}
  TWQC_GETDEFAULT = $0004;
  {$EXTERNALSYM TWQC_GETCURRENT}
  TWQC_GETCURRENT = $0008;
  {$EXTERNALSYM TWQC_RESET}
  TWQC_RESET      = $0010;

{***************************************************************************
 * Entry Points                                                            *
 *************************************************************************** }

{*********************************************************************
 * Function: DSM_Entry, the only entry point into the Data Source Manager.
 *
 * Parameters:
 * pOrigin Identifies the source module of the message. This could
 *     identify an Application, a Source, or the Source Manager.
 *
 * pDest  Identifies the destination module for the message.
 *     This could identify an application or a data source.
 *     If this is NULL, the message goes to the Source Manager.
 *
 * DG   The Data Group.
 *     Example: DG_IMAGE.
 *
 * DAT   The Data Attribute Type.
 *     Example: DAT_IMAGEMEMXFER.
 *
 * MSG   The message. Messages are interpreted by the destination module
 *     with respect to the Data Group and the Data Attribute Type.
 *     Example: MSG_GET.
 *
 * pData  A pointer to the data structure or variable identified
 *     by the Data Attribute Type.
 *     Example: (TW_MEMREF)&ImageMemXfer
 *          where ImageMemXfer is a TW_IMAGEMEMXFER structure.
 *
 * Returns:
 * ReturnCode
 *     Example: TWRC_SUCCESS.
 *
 ******************************************************************* }
type
  {$EXTERNALSYM DSMENTRYPROC}
  DSMENTRYPROC =  function(
    pOrigin: pTW_IDENTITY;
    pDest: pTW_IDENTITY;
    DG: TW_UINT32;
    DAT: TW_UINT16;
    MSG: TW_UINT16;
    pData: TW_MEMREF
  ): TW_UINT16; stdcall;

  TDSMEntryProc = DSMENTRYPROC;

var
  DSM_Entry: TDSMEntryProc =  nil;

{*********************************************************************
 * Function: DS_Entry, the entry point provided by a Data Source.
 *
 * Parameters:
 * pOrigin Identifies the source module of the message. This could
 *     identify an application or the Data Source Manager.
 *
 * DG   The Data Group.
 *     Example: DG_IMAGE.
 *
 * DAT   The Data Attribute Type.
 *     Example: DAT_IMAGEMEMXFER.
 *
 * MSG   The message. Messages are interpreted by the data source
 *     with respect to the Data Group and the Data Attribute Type.
 *     Example: MSG_GET.
 *
 * pData  A pointer to the data structure or variable identified
 *     by the Data Attribute Type.
 *     Example: (TW_MEMREF)&ImageMemXfer
 *          where ImageMemXfer is a TW_IMAGEMEMXFER structure.
 *
 * Returns:
 * ReturnCode
 *     Example: TWRC_SUCCESS.
 *
 * Note:
 * The DSPROC type is only used by an application when it calls
 * a Data Source directly, bypassing the Data Source Manager.
 *
 ******************************************************************* }
type
  {$EXTERNALSYM DSENTRYPROC}
  DSENTRYPROC =  function(
    pOrigin: pTW_IDENTITY;
    DG: TW_UINT32;
    DAT: TW_UINT16;
    MSG: TW_UINT16;
    pData: TW_MEMREF
  ): TW_UINT16; stdcall;

  TDSEntryProc = DSENTRYPROC;

var
  DS_Entry: TDSEntryProc = nil;

implementation

end.



