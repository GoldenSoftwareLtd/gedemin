{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynEditKeyCmds.pas, released 2000-04-07.
The Original Code is based on the mwKeyCmds.pas file from the
mwEdit component suite by Martin Waldenburg and other developers, the Initial
Author of this file is Brad Stowers.
All Rights Reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynEditKeyConst.pas,v 1.1 2001/08/06 11:55:09 jjans Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}

unit SynEditKeyConst;

{ This unit provides a translation of DELPHI and KYLIX key constants to
  more readable SynEdit constants }

{$I SynEdit.inc}

interface

uses
{$IFDEF SYN_KYLIX}
  Qt;
{$ELSE}
  Windows;
{$ENDIF}

const

{$IFDEF SYN_KYLIX}

  SYNEDIT_RETURN = KEY_RETURN;
  SYNEDIT_ESCAPE = KEY_ESCAPE;
  SYNEDIT_SPACE  = KEY_SPACE;
  SYNEDIT_PRIOR  = KEY_PRIOR;
  SYNEDIT_NEXT   = KEY_NEXT;
  SYNEDIT_END    = KEY_END;
  SYNEDIT_HOME   = KEY_HOME;
  SYNEDIT_UP     = KEY_UP;
  SYNEDIT_DOWN   = KEY_DOWN;
  SYNEDIT_BACK   = KEY_BACKSPACE;

{$ELSE}

  SYNEDIT_RETURN = VK_RETURN;
  SYNEDIT_ESCAPE = VK_ESCAPE;
  SYNEDIT_SPACE  = VK_SPACE;
  SYNEDIT_PRIOR  = VK_PRIOR;
  SYNEDIT_NEXT   = VK_NEXT;
  SYNEDIT_END    = VK_END;
  SYNEDIT_HOME   = VK_HOME;
  SYNEDIT_UP     = VK_UP;
  SYNEDIT_DOWN   = VK_DOWN;
  SYNEDIT_BACK   = VK_BACK;

{$ENDIF }

implementation
end.
