METHOD PRELP_TO_P9006 .

  CALL METHOD read_container
    EXPORTING
      im_container = im_prelp
    IMPORTING
      ex_value     = result.

ENDMETHOD.
