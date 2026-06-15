/* Fn_Do_Scrub_Text_Value.sql
 *
 * Trims a TEXT value and returns NULL when nothing is left.
 *
 * Why it exists:
 *   TEXT-typed twin of Fn_Do_Scrub_String_Value, kept as a separate function
 *   so neither path silently truncates: VARCHAR(255) values use the string
 *   scrub, larger bodies of text use this one.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Text_Value('  text  ');  -- 'text'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Text_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Text_Value`(v_Text TEXT) RETURNS text CHARSET utf8mb4
BEGIN

RETURN (CASE WHEN (v_Text IS NULL)
             THEN NULL
             -- ----------------
             WHEN (TRIM(IFNULL(v_Text,'')) = '')
             THEN NULL
             -- ----------------
             ELSE TRIM(v_Text) END) ;

END
