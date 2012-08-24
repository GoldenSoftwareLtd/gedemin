//=============================================================================
// Define the localization you need here by uncommenting the appropriate line.
{$define KBMMEM_RES_ENGLISH}
//{$define KBMMEM_RES_GERMAN}
//{$define KBMMEM_RES_FRENCH}
//{$define KBMMEM_RES_BRASIL}
//{$define KBMMEM_RES_RUSSIAN}
//{$define KBMMEM_RES_SPANISH}
//{$define KBMMEM_RES_ITALIAN}
//{$define KBMMEM_RES_ROMANIAN}
//{$define KBMMEM_RES_SLOVAKIAN}
//{$define KBMMEM_RES_CZECH}
//{$define KBMMEM_RES_DUTCH}
//{$define KBMMEM_RES_DANISH}
//{$define KBMMEM_RES_HUNGARIAN}
//{$define KBMMEM_RES_UKRAINIAN}
//{$define KBMMWM_RES_SWEDISH}
//=============================================================================

{$ifdef KBMMEM_RES_ENGLISH}
  kbmMemResEng,
{$else}
 {$ifdef KBMMEM_RES_GERMAN}
  kbmMemResGer,
 {$else}
  {$ifdef KBMMEM_RES_FRENCH}
   kbmMemResFra,
  {$else}
   {$ifdef KBMMEM_RES_BRASIL}
    kbmMemResBra,
   {$else}
    {$ifdef KBMMEM_RES_RUSSIAN}
     kbmMemResRus,
    {$else}
     {$ifdef KBMMEM_RES_SPANISH}
      kbmMemResSpa,
     {$else}
      {$ifdef KBMMEM_RES_ITALIAN}
       kbmMemResIta,
      {$else}
       {$ifdef KBMMEM_RES_ROMANIAN}
        kbmMemResRom,
       {$else}
        {$ifdef KBMMEM_RES_SLOVAKIAN}
         kbmMemResSky,
        {$else}
         {$ifdef KBMMEM_RES_CZECH}
          kbmMemResCsy,
         {$else}
          {$ifdef KBMMEM_RES_DUTCH}
           kbmMemResDut,
          {$else}
           {$ifdef KBMMEM_RES_DANISH}
            kbmMemResDan,
           {$else}
            {$ifdef KBMMEM_RES_HUNGARIAN}
             kbmMemResHun,
            {$else}
             {$ifdef KBMMEM_RES_UKRAINIAN}
              kbmMemResUkr,
             {$else}
              {$ifdef KBMMEM_RES_SWEDISH}
               kbmMemResSve,
              {$endif} 
             {$endif}
            {$endif}
           {$endif}
          {$endif}
         {$endif}
        {$endif}
       {$endif}
      {$endif}
     {$endif}
    {$endif}
   {$endif}
  {$endif}
 {$endif}
{$endif}
