*----------------------------------------------------------------------*
* Sample code for ABAP Editor theme showcase
*----------------------------------------------------------------------*
DATA: l_matnr      TYPE matnr,
      l_number     TYPE i,
      lt_materials TYPE TABLE OF mara.
CONSTANTS: l_file TYPE string VALUE `file_name_0oO1l.txt`. "comment

START-OF-SELECTION.

  DO 10 TIMES.
    l_number = ( 3 + 7 ) * 100.
  ENDDO.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = l_matnr
    IMPORTING
      output = l_matnr.

  SELECT mara~matnr mara~matkl INTO CORRESPONDING FIELDS OF TABLE lt_materials
    FROM mara WHERE mara~matnr = l_matnr.

  cl_gui_frontend_services=>gui_download(
    EXPORTING
      filename                  = l_file    " Name of file
      filetype                  = 'ASC'    " File type (ASCII, binary ...)
    CHANGING
      data_tab                  = lt_materials    " Transfer table
    EXCEPTIONS
      OTHERS                    = 24
  ).
