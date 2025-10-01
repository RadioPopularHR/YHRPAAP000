*----------------------------------------------------------------------*
*                                                                      *
*       Input-modules for infotype 9007                                *
*                                                                      *
*----------------------------------------------------------------------*

*&SPWIZARD: INPUT MODULE FOR TC 'TC9007'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: MODIFY TABLE
MODULE TC9007_MODIFY INPUT.
  MODIFY WT_TC9007
    FROM WT_TC9007
    INDEX TC9007-CURRENT_LINE.
  IF sy-subrc <> 0.
    APPEND WT_TC9007.
  endif.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALORES_INFOTIPO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module VALORES_INFOTIPO input.

  PERFORM VALORES_INFOTIPO.

endmodule.                 " VALORES_INFOTIPO  INPUT
