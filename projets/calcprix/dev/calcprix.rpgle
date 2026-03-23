**FREE
// ============================================================
// Programme : CALCPRIX
// Objet     : Calcul du prix TTC avec remise
// Auteur    : Sylvain AKTEPE — NOTOS (Groupe Armonie)
// Date      : Mars 2026
// Compil    : CRTBNDRPG OBJ(LIB/CALCPRIX)
//             SRCSTMF('/home/SYLVAIN/projets/calcprix/dev/qrpglesrc/calcprix.rpgle')
//             DBGVIEW(*SOURCE) REPLACE(*YES)
// ============================================================
CTL-OPT COPYRIGHT('(C) ARMONIE 2026.')
        OPTION(*SRCSTMT)
        DFTACTGRP(*NO)
        ACTGRP(*CALLER)
        DATFMT(*ISO)
        TIMFMT(*ISO);

// ---------------------------------------------------------------
// Prototypes des procédures
// ---------------------------------------------------------------
Dcl-Pr CalcTTC   Packed(9:2);
  pPrixHT        Packed(9:2) Const;
  pTauxTVA       Packed(5:2) Const;
End-Pr;

Dcl-Pr AppliquerRemise  Packed(9:2);
  pMontant       Packed(9:2) Const;
  pRemise        Packed(5:2) Const;
End-Pr;

// ---------------------------------------------------------------
// Variables
// ---------------------------------------------------------------
Dcl-S wPrixHT    Packed(9:2);
Dcl-S wTauxTVA   Packed(5:2);
Dcl-S wRemise    Packed(5:2);
Dcl-S wPrixTTC   Packed(9:2);
Dcl-S wPrixFinal Packed(9:2);
Dcl-S wMsg       Char(50);
Dcl-S wReponse   Char(1);

// ---------------------------------------------------------------
// Data Structure article
// ---------------------------------------------------------------
Dcl-DS dsArticle Qualified;
  Nom            Char(20) Inz('Clavier IBM');
  PrixHT         Packed(9:2) Inz(89.99);
  TauxTVA        Packed(5:2) Inz(20.00);
  Remise         Packed(5:2) Inz(10.00);
End-DS;

// ---------------------------------------------------------------
// Traitement principal
// ---------------------------------------------------------------

dsply 'toto' '' wReponse;

// Afficher l'article
wMsg = 'Article : ' + %TrimR(dsArticle.Nom);
Dsply wMsg '' wReponse;

// Calcul du TTC
wPrixTTC = CalcTTC(dsArticle.PrixHT : dsArticle.TauxTVA);
wMsg = 'Prix TTC : ' + %Char(wPrixTTC) + ' EUR';
Dsply wMsg '' wReponse;

// Appliquer la remise
wPrixFinal = AppliquerRemise(wPrixTTC : dsArticle.Remise);
wMsg = 'Apres remise ' + %Char(dsArticle.Remise) + '% : '
     + %Char(wPrixFinal) + ' EUR';
Dsply wMsg '' wReponse;

*InLR = *On;
Return;

// ===============================================================
// Procédure : CalcTTC
// Calcule le prix TTC à partir du HT et du taux de TVA
// ===============================================================
Dcl-Proc CalcTTC;
  Dcl-Pi CalcTTC  Packed(9:2);
    pPrixHT       Packed(9:2) Const;
    pTauxTVA      Packed(5:2) Const;
  End-Pi;

  Dcl-S wResultat Packed(9:2);

  wResultat = pPrixHT * (1 + pTauxTVA / 100);

  Return wResultat;
End-Proc;

// ===============================================================
// Procédure : AppliquerRemise
// Applique un pourcentage de remise sur un montant
// ===============================================================
Dcl-Proc AppliquerRemise;
  Dcl-Pi AppliquerRemise  Packed(9:2);
    pMontant      Packed(9:2) Const;
    pRemise       Packed(5:2) Const;
  End-Pi;

  Dcl-S wResultat Packed(9:2);

  wResultat = pMontant * (1 - pRemise / 100);

  Return wResultat;
End-Proc;
