SELECT 
  ID, 
  LB, 
  RB, 
  PARENT, 
  CONTACTTYPE, 
  NAME, 
  ADDRESS, 
  DISTRICT, 
  CITY, 
  REGION, 
  ZIP, 
  COUNTRY, 
  PLACEKEY, 
  NOTE, 
  EXTERNALKEY, 
  EMAIL, 
  URL, 
  POBOX, 
  PHONE, 
  FAX, 
  CREATORKEY, 
  CREATIONDATE, 
  EDITORKEY, 
  EDITIONDATE, 
  AFULL, 
  ACHAG, 
  AVIEW, 
  DISABLED, 
  USR$INV_ACCOUNTKEY, 
  GD_CONTACT_USR$INV_ACCOUNTKEY.ALIAS AS GD_CONTACT_USR$INV_ACC542947627, 
  USR$WG_LISTNUM, 
  RESERVED, 
  USR$INV_TYPEDEPART, 
  GD_CONTACT_USR$INV_TYPEDEPART.USR$NAME AS GD_CONTACT_USR$INV_TY1878560578, 
  USR$WAGE_OLDEMPLKEY, 
  USR$MN_USEPORTION, 
  USR$WAGE_OLDDEPTKEY, 
  USR$IMNSKEY, 
  GD_CONTACT_USR$IMNSKEY.USR$NAME AS GD_CONTACT_USR$IMNSKEY_USR$NAME, 
  GD_CONTACT_USR$IMNSKEY.USR$ALIAS AS GD_CONTACT_USR$IMNSKEY_65533898, 
  USR$MN_EXTRACATEGORYKEY, 
  GD_CONTACT_USR$MN_EXTR438642148.USR$NAME AS GD_CONTACT_USR$MN_EXT3855444882, 
  USR$ACCOUNTKEY, 
  GD_CONTACT_USR$ACCOUNTKEY.ALIAS AS GD_CONTACT_USR$ACCOUNTKEY_ALIAS, 
  USR$FA_OKEDKEY, 
  GD_CONTACT_USR$FA_OKEDKEY.USR$CODE AS GD_CONTACT_USR$FA_OKE1290354862, 
  USR$TRANSACTIONKEY, 
  GD_CONTACT_USR$TRANSACTIONKEY.NAME AS GD_CONTACT_USR$TRANSA3998485333, 
  USR$FA_OKONH 
FROM 
  GD_CONTACT
    LEFT JOIN 
      AC_ACCOUNT GD_CONTACT_USR$INV_ACCOUNTKEY
    ON 
      GD_CONTACT_USR$INV_ACCOUNTKEY.ID  =  GD_CONTACT.USR$INV_ACCOUNTKEY
    LEFT JOIN 
      USR$INV_DEPOTTYPE GD_CONTACT_USR$INV_TYPEDEPART
    ON 
      GD_CONTACT_USR$INV_TYPEDEPART.ID  =  GD_CONTACT.USR$INV_TYPEDEPART
    LEFT JOIN 
      USR$WG_IMNS GD_CONTACT_USR$IMNSKEY
    ON 
      GD_CONTACT_USR$IMNSKEY.ID  =  GD_CONTACT.USR$IMNSKEY
    LEFT JOIN 
      USR$MN_EXTRACATEGORY GD_CONTACT_USR$MN_EXTR438642148
    ON 
      GD_CONTACT_USR$MN_EXTR438642148.ID  =  GD_CONTACT.USR$MN_EXTRACATEGORYKEY
    LEFT JOIN 
      AC_ACCOUNT GD_CONTACT_USR$ACCOUNTKEY
    ON 
      GD_CONTACT_USR$ACCOUNTKEY.ID  =  GD_CONTACT.USR$ACCOUNTKEY
    LEFT JOIN 
      USR$FA_OKED GD_CONTACT_USR$FA_OKEDKEY
    ON 
      GD_CONTACT_USR$FA_OKEDKEY.ID  =  GD_CONTACT.USR$FA_OKEDKEY
    LEFT JOIN 
      AC_TRANSACTION GD_CONTACT_USR$TRANSACTIONKEY
    ON 
      GD_CONTACT_USR$TRANSACTIONKEY.ID  =  GD_CONTACT.USR$TRANSACTIONKEY 