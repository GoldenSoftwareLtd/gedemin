unit dbf_str;

{ French }

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Ouverture: fichier non trouv�: "%s"';

  STRING_RECORD_LOCKED                := 'Enregistrement verrouill�.';
  STRING_READ_ERROR                   := 'Erreur de lecture.';
  STRING_WRITE_ERROR                  := 'Erreur d'�criture'. (Disque plein?)';
  STRING_WRITE_INDEX_ERROR            := 'Erreur d'�criture; indices probablement corrompus. (Disque plein?)';
  STRING_KEY_VIOLATION                := 'Violation de cl�. (doublon dans un index).'+#13+#10+
                                         'Index: %s'+#13+#10+'Enregistrement=%d Cle=''%s''';

  STRING_INVALID_DBF_FILE             := 'Fichier DBF invalide.';
  STRING_FIELD_TOO_LONG               := 'Valeur trop longue: %d caract�res (ne peut d�passer %d).';
  STRING_INVALID_FIELD_COUNT          := 'Nombre de champs non valide: %d (doit �tre entre 1 et 4095).';
  STRING_INVALID_FIELD_TYPE           := 'Type de champ ''%s'' invalide pour le champ %s.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Impossible de cr�er le champ "%s", champ type %x VCL non support� par DBF';

  STRING_INVALID_MDX_FILE             := 'Fichier MDX invalide.';
  STRING_PARSER_UNKNOWN_FIELD         := 'Champ inconnu %s';
  STRING_PARSER_INVALID_FIELDTYPE     := 'Type de champ invalide pour le champ %s';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'R�sultat d''Index trop long pour "%s", >100 caract�res (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Type d''index non valide: doit �tre string ou float';
  STRING_CANNOT_OPEN_INDEX            := 'Impossible d''ouvrir l''index: "%s"';
  STRING_TOO_MANY_INDEXES             := 'Impossible de cr�er l''index: trop d''index dans le fichier.';
  STRING_INDEX_NOT_EXIST              := 'L''index "%s" n''existe pas.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Access exclusif requis pour cette op�ration.';

  STRING_PROGRESS_PACKINGRECORDS      := 'Emballe enregistrements';
  STRING_PROGRESS_READINGRECORDS      := 'Lit enregistrements';
  STRING_PROGRESS_APPENDINGRECORDS    := 'Ajoute enregistrements';
  STRING_PROGRESS_SORTING_RECORDS     := '�crit records';
  STRING_PROGRESS_WRITING_RECORDS     := 'Trie records';
end.

