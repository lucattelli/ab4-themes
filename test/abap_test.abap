*&---------------------------------------------------------------------*
*& Z Instant Comprehensive ABAP - Machine Learning Library
*& Copyright (C) 2014 Bruno Lucattelli - lucattelli.com
*& This work is licensed under CC ShareAlike 4.0 International
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* PART0 : DECLARATIONS
*----------------------------------------------------------------------*
* Machine Learning algorithms implements math models that rely
* on floating point variables, vectors and matrices.
*
*  - type_float is a simple floating point variable. example:
*    12345678901234567.12345678901234
*
*  - type_float_vector is an ABAP internal table of type_float
*    variables. example:
*    t_float_vector[1] = 12345678901234567.12345678901234
*    t_float_vector[2] = 12345678901234567.12345678901234
*
*  - type_float_matrix is an ABAP internal table of type_float_vector.
*    yeah, it's an internal table of internal tables. example:
*
*    t_float_matrix[1] = t_float_vector[]
*    t_float_matrix[1][1] = 12345678901234567.12345678901234
*----------------------------------------------------------------------*
TYPES : type_float TYPE p LENGTH 16 DECIMALS 14,
        type_float_vector TYPE TABLE OF type_float WITH DEFAULT KEY,
        type_float_matrix TYPE TABLE OF type_float_vector WITH DEFAULT KEY.

* C_E corresponds to Euler's Number, used by the Sigmoid Equation
CONSTANTS c_e TYPE p DECIMALS 4 VALUE '2.7183'.

*----------------------------------------------------------------------*
* PART1 : FILESYSTEM MANAGEMENT
*----------------------------------------------------------------------*
* On Machine Learning problems, we constantly use data models with
* different types and structures. To make it easier to implement, we
* use the filesystem as the main repository. Those basic routines
* implements frequent needs such as loading text files and formatting
* them into type_float_vector and type_float_matrix IT formats.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  load_file
*&---------------------------------------------------------------------*
*       Loads a file into a raw internal table (a.k.a.: don't format it)
*----------------------------------------------------------------------*
FORM load_file TABLES rawdata USING file.
  DATA  : f TYPE string.
  IF file+1(1) = ':'.
    f = file.
  ELSE.
    CONCATENATE c_basepath file INTO f. "-- this is an obligatory parameter in your program
  ENDIF.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = f
    TABLES
      data_tab                = rawdata
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
* FIXME: Implement suitable error handling here
  ENDIF.
ENDFORM.                    "load_file

*&---------------------------------------------------------------------*
*&      Form  save_file
*&---------------------------------------------------------------------*
*       Saves a file into the filesystem
*----------------------------------------------------------------------*
FORM save_file TABLES rawdata USING file write_separator.
  DATA  : f TYPE string.
  IF file+1(1) = ':'.
    f = file.
  ELSE.
    CONCATENATE c_basepath file INTO f. "-- this is an obligatory parameter in your program
  ENDIF.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = f
      write_field_separator   = write_separator
    TABLES
      data_tab                = rawdata
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
* FIXME: Implement suitable error handling here
  ENDIF.
ENDFORM.                    "save_file

*&---------------------------------------------------------------------*
*&      Form  load_bin_file
*&---------------------------------------------------------------------*
*       Loads a binary file X internal table (a.k.a.: don't format it)
*----------------------------------------------------------------------*
FORM load_bin_file TABLES bindata USING file.
  DATA  : f TYPE string.
  IF file+1(1) = ':'.
    f = file.
  ELSE.
    CONCATENATE c_basepath file INTO f. "-- this is an obligatory parameter in your program
  ENDIF.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = f
      filetype                = 'BIN'
    TABLES
      data_tab                = bindata
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
* FIXME: Implement suitable error handling here
  ENDIF.
ENDFORM.                    "load_bin_file

*&---------------------------------------------------------------------*
*&      Form  load_vector_from_file
*&---------------------------------------------------------------------*
*       Loads data from a text file into a vector
*----------------------------------------------------------------------*
FORM load_vector_from_file TABLES t_vector USING file.

  DATA  : t_rawdata TYPE TABLE OF string.
  DATA  : rawfield TYPE string.
  DATA  : floatfield TYPE type_float.

  PERFORM load_file TABLES t_rawdata USING file.
  LOOP AT t_rawdata INTO rawfield.
    floatfield = rawfield.
    APPEND floatfield TO t_vector.
  ENDLOOP.

ENDFORM.                    "load_vector_from_file

*&---------------------------------------------------------------------*
*&      Form  load_matrix_from_file
*&---------------------------------------------------------------------*
*       Loads data from a text file into a matrix
*----------------------------------------------------------------------*
FORM load_matrix_from_file TABLES t_matrix USING file.

  DATA  : t_rawdata TYPE TABLE OF string.
  DATA  : rawline TYPE string.
  DATA  : t_rawfields TYPE TABLE OF string.
  DATA  : t_vector TYPE type_float_vector.
  DATA  : rawfield TYPE string.
  DATA  : floatfield TYPE type_float.

  PERFORM load_file TABLES t_rawdata USING file.
  LOOP AT t_rawdata INTO rawline.
    CLEAR : t_rawfields, t_vector.
    SPLIT rawline AT cl_abap_char_utilities=>horizontal_tab INTO TABLE t_rawfields.
    LOOP AT t_rawfields INTO rawfield.
      floatfield = rawfield.
      APPEND floatfield TO t_vector.
    ENDLOOP.
    APPEND t_vector TO t_matrix.
  ENDLOOP.

ENDFORM.                    "load_matrix_from_file

*----------------------------------------------------------------------*
* PART2: MATRIX OPERATIONS
*----------------------------------------------------------------------*
* In math, matrices and vectors works different when we use them in
* sum, subtract, multiply and other math operations.
* FIXME: I implemented matrix transposal logic only. It was the only
*        one I really needed. If you need to multiply two matrices
*        at any point, please feel free to add a matrix_multiply here.
*        Thank you for that!
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  matrix_transpose
*&---------------------------------------------------------------------*
*       Transposes a matrix
*----------------------------------------------------------------------*
FORM matrix_transpose TABLES t_im t_tm.

  DATA  : t_input_matrix TYPE type_float_matrix,
          t_input_vector TYPE type_float_vector,
          input_item TYPE type_float,
          vector_size TYPE i,
          current_vector TYPE i,
          t_transposed_vector TYPE type_float_vector,
          t_transposed_matrix TYPE type_float_matrix.

  t_input_matrix[] = t_im[].
  CHECK NOT t_input_matrix[] IS INITIAL.
  READ TABLE t_input_matrix INTO t_input_vector INDEX 1.
  DESCRIBE TABLE t_input_vector LINES vector_size.
  DO vector_size TIMES.
    current_vector = sy-index.
    CLEAR t_transposed_vector.
    LOOP AT t_input_matrix INTO t_input_vector.
      READ TABLE t_input_vector INTO input_item INDEX current_vector.
      APPEND input_item TO t_transposed_vector.
    ENDLOOP.
    APPEND t_transposed_vector TO t_transposed_matrix.
  ENDDO.
  t_tm[] = t_transposed_matrix[].

ENDFORM.                    "matrix_transpose

*----------------------------------------------------------------------*
* PART3: SCALING
*----------------------------------------------------------------------*
* As some Machine Learning problems uses SUM(T_VECTOR) into a single
* floating point variable, huge values for your features inside the
* vector may cause COMPUTE_BCD_OVERFLOW or CONVT_OVERFLOW dumps.
* If you see yourself in this situation, it's a good idea to reduce
* your values in a scalable way. Here I implement a routine for
* feature scaling.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  scale_float_matrix
*&---------------------------------------------------------------------*
*       Scales down the values of a matrix to V >= 0 AND V <= 1
*----------------------------------------------------------------------*
FORM scale_float_matrix TABLES t_im t_osm USING minval maxval.

  DATA : t_input_matrix TYPE type_float_matrix,
         t_input_vector TYPE type_float_vector,
         t_scaled_vector TYPE type_float_vector,
         t_scaled_matrix TYPE type_float_matrix.

  t_input_matrix[] = t_im[].
  LOOP AT t_input_matrix INTO t_input_vector.
    CLEAR t_scaled_vector.
    PERFORM scale_float_vector TABLES t_input_vector
                                      t_scaled_vector
                                USING minval maxval.
    APPEND t_scaled_vector TO t_scaled_matrix.
  ENDLOOP.
  t_osm[] = t_scaled_matrix[].

ENDFORM.                    "scale_float_matrix

*&---------------------------------------------------------------------*
*&      Form  scale_float_vector
*&---------------------------------------------------------------------*
*       Scales down the values of a vector to V >= 0 AND V <= 1
*----------------------------------------------------------------------*
FORM scale_float_vector TABLES t_iv t_osv USING minval maxval.

  DATA  : t_input_vector TYPE type_float_vector,
          input_value TYPE type_float,
          scaled_value TYPE type_float,
          t_scaled_vector TYPE type_float_vector.

  t_input_vector[] = t_iv[].
  LOOP AT t_input_vector INTO input_value.
    CLEAR scaled_value.
    PERFORM get_scaled_val USING input_value minval maxval CHANGING scaled_value.
    APPEND scaled_value TO t_scaled_vector.
  ENDLOOP.
  t_osv[] = t_scaled_vector[].

ENDFORM.                    "scale_float_vector

*&---------------------------------------------------------------------*
*&      Form  get_scaled_val
*&---------------------------------------------------------------------*
*       Calculates a scaled value for FORM SCALE_FLOAT_VECTOR
*----------------------------------------------------------------------*
FORM get_scaled_val USING x xmin xmax CHANGING scaled_x.
  CLEAR scaled_x.
  scaled_x = ( x - xmin ) / ( xmax - xmin ).
ENDFORM.                    "get_scaled_val

*----------------------------------------------------------------------*
* PART4: MEAN NORMALIZATION
*----------------------------------------------------------------------*
* Another way you can reduce the value of your features is to use a
* Mean Normalization algorithm. This technique is easier to "unmean"
* a result from a "meaned" hypothesis.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  matrix_mean_normalization
*&---------------------------------------------------------------------*
*       Normalize a matrix to values between -1 and 1.
*----------------------------------------------------------------------*
FORM matrix_mean_normalization TABLES t_im t_om t_adm.
  DATA  : t_input_matrix TYPE type_float_matrix,
          t_transposed_matrix TYPE type_float_matrix,
          t_transposed_vector TYPE type_float_vector,
          t_transposed_output_vector TYPE type_float_vector,
          t_transposed_output_matrix TYPE type_float_matrix,
          t_output_matrix TYPE type_float_matrix,
          avg TYPE type_float,
          dev TYPE type_float,
          t_avg_dev_vector TYPE type_float_vector,
          t_avg_dev_matrix TYPE type_float_matrix,
          t_adm_transposed TYPE type_float_matrix,
          adm_transposed TYPE type_float_vector.
  t_input_matrix[] = t_im[].
  PERFORM matrix_transpose TABLES t_input_matrix t_transposed_matrix.
  PERFORM matrix_transpose TABLES t_adm t_adm_transposed.
  LOOP AT t_transposed_matrix INTO t_transposed_vector.
    READ TABLE t_adm_transposed INTO adm_transposed INDEX sy-tabix.
    IF sy-subrc IS INITIAL.
      CLEAR : avg, dev.
      READ TABLE adm_transposed INTO avg INDEX 1.
      READ TABLE adm_transposed INTO dev INDEX 2.
    ENDIF.
    PERFORM vector_mean_normalization TABLES t_transposed_vector
                                             t_transposed_output_vector
                                    CHANGING avg dev.
    APPEND t_transposed_output_vector TO t_transposed_output_matrix.
    CLEAR t_avg_dev_vector.
    APPEND avg TO t_avg_dev_vector.
    APPEND dev TO t_avg_dev_vector.
    APPEND t_avg_dev_vector TO t_avg_dev_matrix.
  ENDLOOP.
  PERFORM matrix_transpose TABLES t_transposed_output_matrix t_output_matrix.
  PERFORM matrix_transpose TABLES t_avg_dev_matrix t_adm.
  t_om[] = t_output_matrix[].
ENDFORM.                    "matrix_mean_normalization

*&---------------------------------------------------------------------*
*&      Form  vector_mean_normalization
*&---------------------------------------------------------------------*
*       Normalize a vector to values between -1 and 1.
*----------------------------------------------------------------------*
FORM vector_mean_normalization TABLES t_iv t_ov CHANGING avg dev.

  DATA  : min TYPE type_float,
          max TYPE type_float,
          t_input_vector TYPE type_float_vector,
          input_item TYPE type_float,
          output_item TYPE type_float,
          t_output_vector TYPE type_float_vector.

  IF avg IS INITIAL.
    PERFORM get_average_from_vector TABLES t_iv CHANGING avg.
  ENDIF.
  IF dev IS INITIAL.
    PERFORM get_minval_from_vector TABLES t_iv CHANGING min.
    PERFORM get_maxval_from_vector TABLES t_iv CHANGING max.
    PERFORM get_deviation_from_vector TABLES t_iv USING min max CHANGING dev.
  ENDIF.
  t_input_vector[] = t_iv[].
  LOOP AT t_input_vector INTO input_item.
    output_item = ( input_item - avg ) / ( dev / 2 ).
    APPEND output_item TO t_output_vector.
  ENDLOOP.

  t_ov[] = t_output_vector[].

ENDFORM.                    "vector_mean_normalization

*&---------------------------------------------------------------------*
*&      Form  vector_unmean_normalization
*&---------------------------------------------------------------------*
*       This reverses the Mean Normalization algorithm by using AVG/DEV
*----------------------------------------------------------------------*
FORM vector_unmean_normalization TABLES t_iv t_ov USING avg dev.
  DATA  : t_input_vector TYPE type_float_vector,
          input_item TYPE type_float,
          output_item TYPE type_float,
          t_output_vector TYPE type_float_vector.

  t_input_vector[] = t_iv[].
  LOOP AT t_input_vector INTO input_item.
    output_item = ( input_item * ( dev / 2 ) ) + avg.
    APPEND output_item TO t_output_vector.
  ENDLOOP.
  t_ov[] = t_output_vector[].

ENDFORM.                    "vector_unmean_normalization

*&---------------------------------------------------------------------*
*&      Form  get_minval_from_vector
*&---------------------------------------------------------------------*
*       Retrieves the minimum value from a vector
*----------------------------------------------------------------------*
FORM get_minval_from_vector TABLES t_vector CHANGING minval.
  DATA  : t_v TYPE type_float_vector.
  t_v[] = t_vector[].
  SORT t_v ASCENDING.
  READ TABLE t_v INTO minval INDEX 1.
ENDFORM.                    "get_minval_from_vector

*&---------------------------------------------------------------------*
*&      Form  get_minval_from_matrix
*&---------------------------------------------------------------------*
*       Retrieves the minimum value from a matrix
*----------------------------------------------------------------------*
FORM get_minval_from_matrix TABLES t_matrix CHANGING minval.
  DATA  : t_m TYPE type_float_matrix.
  DATA  : t_v TYPE type_float_vector.
  DATA  : i TYPE type_float.
  t_m[] = t_matrix[].
  LOOP AT t_m INTO t_v.
    PERFORM get_minval_from_vector TABLES t_v CHANGING i.
    IF minval EQ 0 OR minval > i.
      minval = i.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "get_minval_from_matrix

*&---------------------------------------------------------------------*
*&      Form  get_maxval_from_vector
*&---------------------------------------------------------------------*
*       Retrieves the maximum value from a vector
*----------------------------------------------------------------------*
FORM get_maxval_from_vector TABLES t_vector CHANGING minval.
  DATA  : t_v TYPE type_float_vector.
  t_v[] = t_vector[].
  SORT t_v DESCENDING.
  READ TABLE t_v INTO minval INDEX 1.
ENDFORM.                    "get_maxval_from_vector

*&---------------------------------------------------------------------*
*&      Form  get_maxval_from_matrix
*&---------------------------------------------------------------------*
*       Retrieves the maximum value from a matrix
*----------------------------------------------------------------------*
FORM get_maxval_from_matrix TABLES t_matrix CHANGING maxval.
  DATA  : t_m TYPE type_float_matrix.
  DATA  : t_v TYPE type_float_vector.
  DATA  : i TYPE type_float.
  t_m[] = t_matrix[].
  LOOP AT t_m INTO t_v.
    PERFORM get_maxval_from_vector TABLES t_v CHANGING i.
    IF maxval EQ 0 OR maxval < i.
      maxval = i.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "get_maxval_from_matrix

*&---------------------------------------------------------------------*
*&      Form  get_average_from_vector
*&---------------------------------------------------------------------*
*       Retrieves the average value from a vector
*----------------------------------------------------------------------*
FORM get_average_from_vector TABLES t_vector CHANGING avg.
  DATA  : t_v TYPE type_float_vector,
          total TYPE i,
          item TYPE type_float,
          sum TYPE type_float.
  t_v[] = t_vector[].
  DESCRIBE TABLE t_v LINES total.
  CHECK total GT 0.
  LOOP AT t_v INTO item.
    sum = sum + item.
  ENDLOOP.
  avg = sum / total.
ENDFORM.                    "get_average_from_vector

*&---------------------------------------------------------------------*
*&      Form  get_deviation_from_vector
*&---------------------------------------------------------------------*
*       Retrieves the deviation value from a vector
*----------------------------------------------------------------------*
FORM get_deviation_from_vector TABLES t_vector USING min max CHANGING dev.
  DATA  : t_v TYPE type_float_vector,
          i TYPE type_float,
          a TYPE type_float.
  t_v[] = t_vector[].
  IF NOT min IS INITIAL.
    i = min.
  ELSE.
    PERFORM get_minval_from_vector TABLES t_v CHANGING i.
  ENDIF.
  IF NOT max IS INITIAL.
    a = max.
  ELSE.
    PERFORM get_maxval_from_vector TABLES t_v CHANGING a.
  ENDIF.
  dev = a - i.
ENDFORM.                    "get_deviation_from_vector

* PART5: LINEAR REGRESSION WITH MULTIPLE FEATURES

*&---------------------------------------------------------------------*
*&      Form  hypothesis
*&---------------------------------------------------------------------*
*       Return a hypothesis of Y for X by multiplying it by THETA param
*----------------------------------------------------------------------*
FORM hypothesis TABLES t_theta t_x CHANGING hypothesis.
  DATA : theta TYPE type_float,
         x TYPE type_float,
         h TYPE type_float.
  LOOP AT t_theta INTO theta.
    READ TABLE t_x INDEX sy-tabix INTO x.
    CHECK sy-subrc IS INITIAL.
    h = h + ( theta * x ).
  ENDLOOP.
  hypothesis = h.
ENDFORM.                    "hypothesis