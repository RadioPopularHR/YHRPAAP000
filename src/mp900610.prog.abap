*----------------------------------------------------------------------*
*                                                                      *
*       Data definition for infotype 9006                              *
*                                                                      *
*----------------------------------------------------------------------*
PROGRAM mp900600 MESSAGE-ID rp.

TABLES: p9006,
        *P9006,
        P0007,
        P2001,
        T001P,
        T591S,
        T554D,
        T554S,
        T554T,
        T554V,
        T554W,
        ythr00001.
* the following tables are filled globally:
* T001P, T500P
* they can be made available with a TABLES-statement
FIELD-SYMBOLS: <pnnnn> STRUCTURE p9006
                       DEFAULT p9006.
*
DATA: psave LIKE p9006.
* Tabelas Auxiliares
DATA: BEGIN OF t_aux2001 OCCURS 0,
        awart LIKE pa2001-awart,
        atext LIKE t554t-atext,
        endda LIKE pa2001-endda,
        begda LIKE pa2001-begda,
      END OF t_aux2001.
*
*** Tabelle ISCREEN wird im PBO mit den Satzen des Screens gefuellt
DATA:   BEGIN OF ISCREEN OCCURS 10,
          SUBTY LIKE T554S-SUBTY,
          BEGDA LIKE T554S-BEGDA,
          ENDDA LIKE T554S-ENDDA,
END OF ISCREEN.
*
DATA:   BEGIN OF ILINE OCCURS 30,
  INFTY LIKE P9006-INFTY,
  SUBTY LIKE T554S-SUBTY,
  OBJPS LIKE P9006-OBJPS,
  BEGDA LIKE T554S-BEGDA,
  ENDDA LIKE T554S-ENDDA,
  OPERA,
END OF ILINE.
*
DATA:  BEGIN OF OPERA,
  NOOPERA VALUE ' ',
  DELETE  VALUE 'D',
  INSERT  VALUE 'I',
END OF OPERA.
* Variaveis Auxilizares
DATA: ABSENCE      LIKE P9006-INFTY VALUE '2001',
      ACCIDENT     LIKE P9006-INFTY VALUE '9006',
      BOTH                          VALUE ' ',
      MAN                           VALUE '1',
      WOMAN                         VALUE '2',
      ILINE_INDEX  LIKE SY-INDEX,
      ACTIVE                        VALUE 'X',
      SUPRESS                       VALUE 'D',
      INFTY_0001   LIKE P9006-INFTY VALUE '0001',
      INFTY_PERSON LIKE P9006-INFTY VALUE '0002',
      INFTY_0007   LIKE P9006-INFTY VALUE '0007',
      YES_SPRPS    LIKE P9006-SPRPS VALUE '4',
      NO_SPRPS     LIKE P9006-SPRPS VALUE ' ',
      SAVE_BEGDA   LIKE P9006-BEGDA,
      SAVE_ENDDA   LIKE P9006-ENDDA,
      SAVE_OBJPS   LIKE P9006-OBJPS.
*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC2001' ITSELF
CONTROLS: TC2001 TYPE TABLEVIEW USING SCREEN 2000.

*&SPWIZARD: LINES OF TABLECONTROL 'TC2001'
DATA:     G_TC2001_LINES  LIKE SY-LOOPC.

CLASS cl_pt_container_util  DEFINITION LOAD.                "XHB-UNI
CLASS cl_hr_pnnnn_type_cast DEFINITION LOAD.                "XHB-UNI

INCLUDE MPZDAT00.
