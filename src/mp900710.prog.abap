*----------------------------------------------------------------------*
*                                                                      *
*       Data definition for infotype 9007                              *
*                                                                      *
*----------------------------------------------------------------------*
PROGRAM MP900700 MESSAGE-ID RP.

TABLES: P9007,
        T591S.
* the following tables are filled globally:
* T001P, T500P
* they can be made available with a TABLES-statement
DATA: BEGIN OF WT_TC9007 OCCURS 0,
        ACCAO type P9007-ACCAO01,
        ENTIDADE type P9007-ENTID01,
        DATA type P9007-DATA01,
      END OF WT_TC9007.
*
FIELD-SYMBOLS: <PNNNN> STRUCTURE P9007
                       DEFAULT P9007.

DATA: PSAVE LIKE P9007.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC9007' ITSELF
CONTROLS: TC9007 TYPE TABLEVIEW USING SCREEN 2000.
