*----------------------------------------------------------------------*
*                                                                      *
*       Subroutines for infotype 9007                                  *
*                                                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OUTPUT_P9007
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM output_p9007 .

* Texto do subinfotipo
  IF NOT p9007-subty IS INITIAL.
    SELECT SINGLE * FROM t591s WHERE
      sprsl = sy-langu AND
      infty = p9007-infty and
      subty = p9007-subty.
  ENDIF.

ENDFORM.                    " OUTPUT_P9007
*&---------------------------------------------------------------------*
*&      Form  VALORES_INFOTIPO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM valores_infotipo .

  FIELD-SYMBOLS : <a> TYPE p9007-accao01,
                  <b> TYPE p9007-entid01,
                  <c> TYPE p9007-data01.

  DATA: auxnome1(20),
        auxnome2(20),
        auxnome3(20),
        w_cont(2) TYPE n.

  LOOP AT wt_tc9007.
    IF NOT wt_tc9007-accao IS INITIAL OR NOT wt_tc9007-entidade IS INITIAL.
      w_cont = sy-tabix.
*   NOMES DOS CAMPOS
      CONCATENATE 'P9007-ACCAO' w_cont INTO auxnome1.
      ASSIGN (auxnome1) TO <a>.
      <a> = wt_tc9007-accao.

      CONCATENATE 'P9007-ENTID' w_cont INTO auxnome2.
      ASSIGN (auxnome2) TO <b>.
      <b> = wt_tc9007-entidade.

      CONCATENATE 'P9007-DATA' w_cont INTO auxnome3.
      ASSIGN (auxnome3) TO <c>.
      <c> = wt_tc9007-data.

    ENDIF.
  ENDLOOP.
ENDFORM.                    " VALORES_INFOTIPO
