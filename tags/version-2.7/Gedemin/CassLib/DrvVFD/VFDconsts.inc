{

   онстанты дл€ доступа к командам протокола VDF-диспле€ Firich   

}

const

// prefix 'c' = _c_ommand

  cInitialize = #$1B#$40;

  cOverwriteMode   = #$1B#$11;
  cVertScrollMode  = #$1B#$12;
  cHorizScrollMode = #$1B#$13;
{  cOverwriteMode   = #$11;
  cVertScrollMode  = #$12;
  cHorizScrollMode = #$13;}

  cClearDisplay = #$0C;
  cClearLine = #$18;

  cWriteToUpperLine = #$1B#$51#$41+'%s'+#$0D;
  cWriteToLowerLine = #$1B#$51#$42+'%s'+#$0D;
  cWriteAndScroll   = #$1B#$51#$44+'%s'+#$0D;

  cSetFontSet   = #$1B#$66+'%s';
  cSetCodeTable = #$1B#$63+'%s';

  cMoveCursor = #$1B#$5B+'%d';

  cCursorUp         = #$1B#$5B#$41;
  cCursorDown       = #$1B#$5B#$42;
  cCursorRight      = #$1B#$5B#$43;
  cCursorLeft       = #$1B#$5B#$44;
  cCursorToHome     = #$1B#$5B#$48;
  cCursorToBottom   = #$1B#$5B#$4B;

{
  cCursorUp         = #$1B#$5B#$41;
  cCursorDown       = #$1B#$5B#$42;
  cCursorRight      = #$1B#$5B#$43;
  cCursorLeft       = #$1B#$5B#$44;
  cCursorToHome     = #$1B#$5B#$48;
  cCursorToBottom   = #$1B#$5B#$4B;
}
  cCursorToPosition = #$1B#$6C+'%s%s'; // col = 1..14, line = 1..2; 



