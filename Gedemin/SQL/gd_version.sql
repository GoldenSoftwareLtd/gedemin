
/****************************************************/
/****************************************************/
/**                                                **/
/**                                                **/
/**   Copyright (c) 1999-00 by                     **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

CREATE TABLE fin_versioninfo
(
  id            dintkey,
  versionstring dversionstring,
  releasedate   ddate NOT NULL,
  comment       dtext254
);

ALTER TABLE fin_versioninfo ADD CONSTRAINT fin_pk_versioninfo_id
  PRIMARY KEY (id);

COMMIT;

GRANT SELECT ON fin_versioninfo TO startuser;

COMMIT;

SET TERM ^ ;

CREATE PROCEDURE fin_p_ver_getdbversion
  RETURNS (ID INTEGER, VersionString VARCHAR(20),
    ReleaseDate DATE, Comment VARCHAR(255) CHARACTER SET WIN1251)
AS
BEGIN
  SELECT id, versionstring, releasedate, comment
  FROM fin_versioninfo
  WHERE id = (SELECT MAX(id) FROM fin_versioninfo)
  INTO :ID, :VersionString, :ReleaseDate, :Comment;
END
^

SET TERM ; ^

COMMIT;

GRANT EXECUTE ON PROCEDURE fin_p_ver_getdbversion TO startuser;

COMMIT;

INSERT INTO fin_versioninfo
  VALUES (1, '0000.0000.0001.0000', '01.02.1999', 'Начало...');

INSERT INTO fin_versioninfo
  VALUES (2, '0000.0000.0001.0001', '07.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (3, '0000.0000.0001.0002', '08.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (4, '0000.0000.0001.0003', '11.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (5, '0000.0000.0001.0004', '18.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (6, '0000.0000.0001.0005', '27.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (7, '0000.0000.0001.0006', '03.03.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (8, '0000.0000.0001.0007', '22.04.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (9, '0000.0000.0001.0008', '23.07.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (10, '0000.0000.0001.0009', '30.07.1999', 'Phone tables added');

INSERT INTO fin_versioninfo
  VALUES (11, '0000.0000.0001.0010', '03.08.1999', 'Icon tables added');

INSERT INTO fin_versioninfo
  VALUES (12, '0000.0001.0000.0001', '19.06.2000', 'Gedemin started');

INSERT INTO fin_versioninfo
  VALUES (13, '0000.0001.0000.0002', '24.06.2000', 'Andreik added ON DELETE clause to FOREIGN KEY defenitions');

INSERT INTO fin_versioninfo
  VALUES (14, '0000.0001.0000.0003', '27.06.2000', '...');

INSERT INTO fin_versioninfo
  VALUES (15, '0000.0001.0000.0004', '10.07.2000', 'Audit levels added by Andreik');

INSERT INTO fin_versioninfo
  VALUES (16, '0000.0001.0000.0005', '03.08.2000', 'Першы кандыдат да выпуску адраснай кнiгi');

INSERT INTO fin_versioninfo
  VALUES (17, '0000.0001.0000.0006', '08.08.2000', 'Другi кандыдат да выпуску адраснай кнiгi');

INSERT INTO fin_versioninfo
  VALUES (18, '0000.0001.0000.0007', '09.08.2000', 'Views added');

INSERT INTO fin_versioninfo
  VALUES (19, '0000.0001.0000.0008', '15.08.2000', 'Functions (macros) added');

INSERT INTO fin_versioninfo
  VALUES (20, '0000.0001.0000.0009', '17.08.2000', 'Payment order added');

INSERT INTO fin_versioninfo
  VALUES (21, '0000.0001.0000.0010', '18.08.2000', 'New version');

INSERT INTO fin_versioninfo
  VALUES (22, '0000.0001.0000.0011', '20.08.2000', 'Generators names changed');

INSERT INTO fin_versioninfo
  VALUES (23, '0000.0001.0000.0012', '27.08.2000', 'Next release');

INSERT INTO fin_versioninfo
  VALUES (24, '0000.0001.0000.0014', '28.08.2000', 'Order by added in gd_p_getfolderelement');

INSERT INTO fin_versioninfo
  VALUES (25, '0000.0001.0000.0015', '31.08.2000', 'Some bug base fields added');

INSERT INTO fin_versioninfo
  VALUES (26, '0000.0001.0000.0016', '08.09.2000', 'Interval trees implemented');

INSERT INTO fin_versioninfo
  VALUES (27, '0000.0001.0000.0017', '14.09.2000', 'Desktops implemented');

INSERT INTO fin_versioninfo
  VALUES (28, '0000.0001.0000.0018', '18.09.2000', 'Goods added');

INSERT INTO fin_versioninfo
  VALUES (29, '0000.0001.0000.0019', '28.09.2000', '...');

INSERT INTO fin_versioninfo
  VALUES (30, '0000.0001.0000.0020', '22.10.2000', 'Filters added');

INSERT INTO fin_versioninfo
  VALUES (31, '0000.0001.0000.0021', '26.10.2000', 'First launch of new phone!!!');

INSERT INTO fin_versioninfo
  VALUES (32, '0000.0001.0000.0022', '14.11.2000', 'Berioza 2');

INSERT INTO fin_versioninfo
  VALUES (33, '0000.0001.0000.0023', '30.11.2000', 'Berioza 3');

INSERT INTO fin_versioninfo
  VALUES (34, '0000.0001.0000.0024', '04.12.2000', 'Bank statements to Berioza');

INSERT INTO fin_versioninfo
  VALUES (35, '0000.0001.0000.0025', '27.12.2000', 'Big clean up!');

INSERT INTO fin_versioninfo
  VALUES (36, '0000.0001.0000.0026', '12.02.2001', 'My birthday :)');

INSERT INTO fin_versioninfo
  VALUES (37, '0000.0001.0000.0027', '11.03.2001', 'Bankstatement fields added. Upgrade is mandatory.');

INSERT INTO fin_versioninfo
  VALUES (38, '0000.0001.0000.0028', '24.04.2001', 'Cattle tables added.');

INSERT INTO fin_versioninfo
  VALUES (39, '0000.0001.0000.0029', '10.11.2001', 'New operations');

INSERT INTO fin_versioninfo
  VALUES (40, '0000.0001.0000.0030', '12.02.2002', 'My birthday again :(');

INSERT INTO fin_versioninfo
  VALUES (41, '0000.0001.0000.0031', '08.07.2002', 'Triggers for system tables added');

INSERT INTO fin_versioninfo
  VALUES (42, '0000.0001.0000.0032', '08.11.2002', 'GD_JOURNAL has got its final state');

INSERT INTO fin_versioninfo
  VALUES (43, '0000.0001.0000.0033', '13.01.2003', 'ST_SETTINGSTATE for installer was added');

INSERT INTO fin_versioninfo
  VALUES (44, '0000.0001.0000.0034', '04.02.2003', 'Support financial report (add tables gd_tax..)');

INSERT INTO fin_versioninfo
  VALUES (45, '0000.0001.0000.0035', '23.04.2003', 'WG_POSITION added');

INSERT INTO fin_versioninfo
  VALUES (46, '0000.0001.0000.0036', '08.06.2003', 'employee becomes a children to department');

INSERT INTO fin_versioninfo
  VALUES (47, '0000.0001.0000.0045', '18.08.2003', 'Changed domain DGOLDQUANTITY');

INSERT INTO fin_versioninfo
  VALUES (48, '0000.0001.0000.0046', '22.08.2003', 'Changed trigger INV_AU_MOVEMENT ');

INSERT INTO fin_versioninfo
  VALUES (49, '0000.0001.0000.0047', '03.09.2003', 'Added fields into AT_SETTING');

INSERT INTO fin_versioninfo
  VALUES (50, '0000.0001.0000.0048', '20.09.2003', 'Computed indice adde');

INSERT INTO fin_versioninfo
  VALUES (51, '0000.0001.0000.0049', '22.09.2003', 'Additional fields into gd_company added');

INSERT INTO fin_versioninfo
  VALUES (52, '0000.0001.0000.0052', '10.10.2003', 'Block');

INSERT INTO fin_versioninfo
  VALUES (53, '0000.0001.0000.0061', '09.12.2003', 'Additional fields into inv_balanceoption added');

INSERT INTO fin_versioninfo
  VALUES (54, '0000.0001.0000.0062', '19.12.2003', 'DataType field into gd_const added');

INSERT INTO fin_versioninfo
  VALUES (55, '0000.0001.0000.0063', '07.01.2004', 'Some triggers removed');

INSERT INTO fin_versioninfo
  VALUES (56, '0000.0001.0000.0064', '12.01.2004', 'Column RATE was added in BN_BANKSTATEMENT');

INSERT INTO fin_versioninfo
  VALUES (57, '0000.0001.0000.0066', '12.01.2004', 'Column ACCOUNTKEY was added in BN_BANKSTATEMENTLINE');

INSERT INTO fin_versioninfo
  VALUES (58, '0000.0001.0000.0068', '18.01.2004', 'Column FIXLENGTH was added in GD_LASTNUMBER');

INSERT INTO fin_versioninfo
  VALUES (59, '0000.0001.0000.0085', '17.06.2004', 'New general ledger');

INSERT INTO fin_versioninfo
  VALUES (60, '0000.0001.0000.0086', '28.06.2004', 'FIX gd_taxtype');

INSERT INTO fin_versioninfo
  VALUES (61, '0000.0001.0000.0087', '28.07.2004', 'Add EQ');

INSERT INTO fin_versioninfo
  VALUES (62, '0000.0001.0000.0090', '08.12.2004', 'Fix inv_price');

INSERT INTO fin_versioninfo
  VALUES (63, '0000.0001.0000.0091', '10.02.2005', 'Modify block triggers');

INSERT INTO fin_versioninfo
  VALUES (64, '0000.0001.0000.0092', '01.03.2005', 'Sync triggers procedures changed');

INSERT INTO fin_versioninfo
  VALUES (65, '0000.0001.0000.0093', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (66, '0000.0001.0000.0094', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (67, '0000.0001.0000.0095', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (68, '0000.0001.0000.0096', '12.04.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (69, '0000.0001.0000.0097', '10.10.2005', 'Minor changes');

INSERT INTO fin_versioninfo
  VALUES (70, '0000.0001.0000.0098', '10.01.2006', 'Minor changes');

INSERT INTO fin_versioninfo
  VALUES (71, '0000.0001.0000.0099', '15.03.2006', 'Tables for SQL monitor added');

INSERT INTO fin_versioninfo
  VALUES (72, '0000.0001.0000.0100', '17.03.2006', 'Type of description field of goodgroup has been changed');

INSERT INTO fin_versioninfo
  VALUES (73, '0000.0001.0000.0101', '17.04.2006', 'Bankbranch field added');

INSERT INTO fin_versioninfo
  VALUES (74, '0000.0001.0000.0102', '04.05.2006', 'Bankbranch field added to bankstatement');

INSERT INTO fin_versioninfo
  VALUES (75, '0000.0001.0000.0103', '30.05.2006', 'Employee branch added into Explorer');

INSERT INTO fin_versioninfo
  VALUES (76, '0000.0001.0000.0104', '18.09.2006', 'Ability to exclude some document types from block period added');

INSERT INTO fin_versioninfo
  VALUES (77, '0000.0001.0000.0105', '31.07.2006', 'Add fields from AC_RECORD into AC_ENTRY');

INSERT INTO fin_versioninfo
  VALUES (78, '0000.0001.0000.0106', '15.09.2006', 'Change StoredProc AC_CIRCULATIONLIST');

INSERT INTO fin_versioninfo
  VALUES (79, '0000.0001.0000.0107', '27.10.2006', 'Исправлена процедура AC_ACCOUNTEXSALDO');

INSERT INTO fin_versioninfo
  VALUES (80, '0000.0001.0000.0108', '09.11.2006', 'Возвращены изменения триггеров - параметр ROWCOUNT - возрващал неверное значение');

INSERT INTO fin_versioninfo
  VALUES (81, '0000.0001.0000.0109', '12.11.2006', 'Добавлена процедура INV_GETCARDMOVEMENT для ускорения вывода остатков на дату');

INSERT INTO fin_versioninfo
  VALUES (82, '0000.0001.0000.0110', '24.11.2006', 'Пересчитываем складские остатки после восстановления складских триггеров');

INSERT INTO fin_versioninfo
  VALUES (84, '0000.0001.0000.0112', '03.01.2007', 'Fixed triggers for FireBird 2.0');

INSERT INTO fin_versioninfo
  VALUES (85, '0000.0001.0000.0113', '20.01.2007', 'Stripped security descriptors from rp_reportgroup');

INSERT INTO fin_versioninfo
  VALUES (86, '0000.0001.0000.0114', '22.01.2007', 'surname field of gd_people became not null');

INSERT INTO fin_versioninfo
  VALUES (87, '0000.0001.0000.0115', '24.01.2007', 'Fixed block and GD_AU_DOCUMENT triggers');

INSERT INTO fin_versioninfo
  VALUES (88, '0000.0001.0000.0116', '28.01.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (89, '0000.0001.0000.0117', '31.01.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (90, '0000.0001.0000.0118', '04.02.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (91, '0000.0001.0000.0119', '26.02.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (92, '0000.0001.0000.0120', '22.04.2007', 'GD_P_GETRUID changed');

INSERT INTO fin_versioninfo
  VALUES (93, '0000.0001.0000.0121', '02.05.2007', 'RUID changed');

INSERT INTO fin_versioninfo
  VALUES (94, '0000.0001.0000.0122', '07.05.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (95, '0000.0001.0000.0123', '30.06.2007', 'Add generators');

INSERT INTO fin_versioninfo
  VALUES (96, '0000.0001.0000.0124', '3.08.2007', 'Add barcode indices');

INSERT INTO fin_versioninfo
  VALUES (97, '0000.0001.0000.0125', '4.10.2007', 'Add check constraints');

INSERT INTO fin_versioninfo
  VALUES (98, '0000.0001.0000.0126', '22.10.2007', 'GD_AU_DOCUMENT');

INSERT INTO fin_versioninfo
  VALUES (100, '0000.0001.0000.0127', '16.01.2008', 'inv_balanceoption');

INSERT INTO fin_versioninfo
  VALUES (101, '0000.0001.0000.0128', '10.06.2008', 'FastReport4');

/*
INSERT INTO fin_versioninfo
  VALUES (102, '0000.0001.0000.0134', '09.07.2008', 'Добавлены RPL таблицы');

INSERT INTO fin_versioninfo
  VALUES (103, '0000.0001.0000.0135', '15.10.2008', 'Добавлен расчет сальдо по проводкам');

INSERT INTO fin_versioninfo
  VALUES (104, '0000.0001.0000.0136', '19.12.2008', 'Добавлено поле OKULP в таблицу GD_COMPANYCODE');

INSERT INTO fin_versioninfo
  VALUES (105, '0000.0001.0000.0137', '12.01.2009', 'Добавлено поле ISINTERNAL в таблицу AC_TRANSACTION для определения внутренних проводок');

INSERT INTO fin_versioninfo
  VALUES (106, '0000.0001.0000.0138', '25.04.2009', 'Проставлены пропущенные гранты');
*/

INSERT INTO fin_versioninfo
  VALUES (107, '0000.0001.0000.0139', '07.09.2009', 'GD_SQL_HISTORY table added and other changes');

INSERT INTO fin_versioninfo
  VALUES (108, '0000.0001.0000.0140', '09.07.2008', 'Добавлены RPL таблицы');

INSERT INTO fin_versioninfo
  VALUES (109, '0000.0001.0000.0141', '15.10.2008', 'Добавлен расчет сальдо по проводкам');

INSERT INTO fin_versioninfo
  VALUES (110, '0000.0001.0000.0142', '19.12.2008', 'Добавлено поле OKULP в таблицу GD_COMPANYCODE');

INSERT INTO fin_versioninfo
  VALUES (111, '0000.0001.0000.0143', '12.01.2009', 'Добавлено поле ISINTERNAL в таблицу AC_TRANSACTION для определения внутренних проводок');

INSERT INTO fin_versioninfo
  VALUES (112, '0000.0001.0000.0144', '25.04.2009', 'Проставлены пропущенные гранты');


INSERT INTO fin_versioninfo
  VALUES (114, '0000.0001.0000.0145', '25.09.2009', 'Storage being converted into new data structures');
  
INSERT INTO fin_versioninfo
  VALUES (115, '0000.0001.0000.0146', '08.03.2010', 'Editorkey and editiondate fields were added to storage table');

INSERT INTO fin_versioninfo
  VALUES (116, '0000.0001.0000.0147', '26.04.2010', 'Storage tree is not a lb-rb tree any more');

COMMIT;

CREATE UNIQUE DESC INDEX fin_x_versioninfo_id
  ON fin_versioninfo (id);

COMMIT;
