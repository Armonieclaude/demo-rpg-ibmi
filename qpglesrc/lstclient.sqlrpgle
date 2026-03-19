**FREE
// ============================================================
// Programme : LSTCLIENT
// Objet     : Liste les clients de la table DEMOGIT.CLIENT
// Auteur    : Sylvain AKTEPE  NOTOS (Groupe Armonie)
// Date      : Mars 2026
// Compil    : CRTSQLRPGI OBJ(DEMOGIT/LSTCLIENT)
//             SRCSTMF('/home/SAKTEPE/demo-rpg-ibmi/qrpglesrc/lstclient.sqlrpgle')
//             COMMIT(*NONE) DBGVIEW(*SOURCE)
// ============================================================
CTL-OPT COPYRIGHT('(C) ARMONIE 2026.')
        OPTION(*SRCSTMT)
        DFTACTGRP(*NO)
        ACTGRP(*CALLER)
        DATFMT(*ISO)
        TIMFMT(*ISO);

// ---------------------------------------------------------------
// Déclaration des variables
// ---------------------------------------------------------------
Dcl-S wNom    Char(30);
Dcl-S wPrenom Char(30);
Dcl-S wMsg    Char(52);

// ---------------------------------------------------------------
// Options SQL
// ---------------------------------------------------------------
EXEC SQL
  SET OPTION COMMIT = *NONE,
             DATFMT = *ISO,
             TIMFMT = *ISO,
             ALWCPYDTA = *OPTIMIZE,
             CLOSQLCSR = *ENDMOD;

// ---------------------------------------------------------------
// Traitement principal
// ---------------------------------------------------------------

// Déclaration du curseur
EXEC SQL
  DECLARE C1 CURSOR FOR
    SELECT NOMCLI, PRECLI
      FROM DEMOGIT.CLIENT
     ORDER BY NUMCLI;

// Ouverture du curseur
EXEC SQL OPEN C1;

// Première lecture
EXEC SQL FETCH C1 INTO :wNom, :wPrenom;

// Boucle de lecture
DoW SQLCOD = 0;
  wMsg = %TrimR(wPrenom) + ' ' + %TrimR(wNom);
  Dsply wMsg;
  EXEC SQL FETCH C1 INTO :wNom, :wPrenom;
EndDo;

// Fermeture du curseur
EXEC SQL CLOSE C1;

*InLR = *On;
Return;
