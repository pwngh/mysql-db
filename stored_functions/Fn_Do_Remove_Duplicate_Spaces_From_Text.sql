/* Fn_Do_Remove_Duplicate_Spaces_From_Text.sql
 *
 * Trims text and collapses runs of spaces to a single space. NULL when the
 * input is NULL or whitespace-only.
 *
 * Why it exists:
 *   Pre-cleaning for text that came from humans - pasted names, addresses,
 *   free-form dates - before it is parsed or stored. The date display
 *   parser depends on it so that delimiter positions are predictable.
 *
 * Used by: Fn_Do_Convert_Date_Format_From_Display_To_Internal.
 *
 * Example:
 *   SELECT Fn_Do_Remove_Duplicate_Spaces_From_Text('  a   b  ');  -- 'a b'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Remove_Duplicate_Spaces_From_Text`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Remove_Duplicate_Spaces_From_Text`(v_The_Text TEXT) RETURNS text CHARSET utf8mb4
BEGIN

IF (v_The_Text IS NULL) THEN
      RETURN NULL ;
END IF;

IF (TRIM(v_The_Text) = '') THEN
      RETURN NULL ;
END IF;

RETURN TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(v_The_Text), '  ', ' '), '     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '  ', ' ')) ;

END
