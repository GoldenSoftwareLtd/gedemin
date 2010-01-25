(*
Device independant bitmap functions.
Copyright (C) 2000, Oliver George

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the
Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA  02111-1307, USA.

==================================================================
That was the license, general implications are:
- free to use
- free to modify
- source code of this library (not your whole app) must be available.

*)

unit dib;

interface

uses
  Windows, classes, graphics;

  procedure write_dib_to_stream(DIBHandle: HBITMAP;Stream: TStream);
  procedure load_dib_into_bitmap(DIBHandle: HBITMAP;Bitmap: TBitmap);

implementation

function ColourCount(lpDib: PBitmapInfo): integer;
var
  lpbi: PBITMAPINFOHEADER;
  lpbc: PBITMAPCOREHEADER;
  bits: integer;
begin

  lpbi := pointer(lpDib);
  lpbc := pointer(lpDib);

  if (lpbi.biSize <> sizeof(BITMAPCOREHEADER)) then
  begin
    if (lpbi.biClrUsed<>0) then
    begin
      result:=lpbi.biClrUsed;
      exit;
    end;
    bits:=lpbi.biBitCount;
  end else
    bits:=lpbc.bcBitCount;

  case bits of
    1: result:=2;
    4: result:=16;
    8: result:=256;
  else
    result:=0;
  end;
end;

function HeaderSize(lpDib: PBitmapInfo): DWORD;
var HeaderSize: DWORD;
begin
  if lpDib.bmiHeader.biBitCount > 8 then
  begin
    HeaderSize := SizeOf(TBitmapInfoHeader);
    if (lpDib.bmiHeader.biCompression and BI_BITFIELDS) <> 0 then
      Inc(HeaderSize, 12);
  end else begin
    HeaderSize := SizeOf(TBitmapInfoHeader) +
                  SizeOf(TRGBQuad) * (1 shl lpDib.bmiHeader.biBitCount);
  end;
  result := HeaderSize;
end;

procedure write_dib_to_stream(DIBHandle: HBITMAP;Stream: TStream);
var
  lpDib: PBitmapInfo;
  BMF: TBitmapFileHeader;
  hdrSize: DWORD;
begin
  lpDib := GlobalLock(DIBHandle);
  try
    hdrSize := HeaderSize(lpDib);
    BMF.bfType := $4D42;
    BMF.bfSize := lpDib.bmiHeader.biSizeImage;
    BMF.bfOffBits := sizeof(BMF) + hdrSize;
    Stream.WriteBuffer(BMF, Sizeof(BMF));
    Stream.WriteBuffer(lpDIB^, hdrSize + lpDib.bmiHeader.biSizeImage);
  finally
    GlobalUnlock(DIBHandle);
  end;
end;

procedure load_dib_into_bitmap(DIBHandle: HBITMAP;Bitmap: TBitmap);
var
  BMPHandle: HBITMAP;
  dc: HDC;
  lpDib: PBitmapInfo;
  lpBits: pchar;
begin
  lpDib := GlobalLock(DIBHandle);
  try
    lpBits := pointer(lpDIB);
    Inc(lpBits, lpDib.bmiHeader.biSize);
    Inc(lpBits, ColourCount(lpDib) * sizeof(RGBQUAD));
    dc := GetDC(0);
    try
      BMPHandle := CreateDIBitmap( dc,
                                   lpDib.bmiHeader,
                                   CBM_INIT,
                                   lpBits,
                                   lpDib^,
                                   DIB_RGB_COLORS );
      if BMPHandle <> 0 then
        bitmap.Handle := BMPHandle;
    finally
      releaseDC(0, dc);
    end;
  finally
    GlobalUnlock(DIBHandle);
  end;
end;

end.

