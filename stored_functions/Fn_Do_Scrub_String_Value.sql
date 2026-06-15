/* Fn_Do_Scrub_String_Value.sql
 *
 * Trims a VARCHAR and returns NULL when nothing is left.
 *
 * Why it exists:
 *   The baseline scrub for free-text values. Collapsing '', '   ', and NULL
 *   into a single representation (NULL) keeps "no value" unambiguous in
 *   storage and lets downstream IFNULL/IS NULL checks behave predictably.
 *
 * See also: Fn_Do_Scrub_Text_Value - identical contract for TEXT columns.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_String_Value('  text  ');  -- 'text'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_String_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_String_Value`(v_Str VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4
BEGIN

RETURN (CASE WHEN (v_Str IS NULL)
             THEN NULL
             -- ----------------
             WHEN (TRIM(IFNULL(v_Str,'')) = '')
             THEN NULL
             -- ----------------
             ELSE TRIM(v_Str) END) ;

END
