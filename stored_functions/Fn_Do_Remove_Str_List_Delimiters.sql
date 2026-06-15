/* Fn_Do_Remove_Str_List_Delimiters.sql
 *
 * Strips the characters this system reserves as list delimiters - double
 * and single quotes, pipe, tilde, caret - from a string, and collapses
 * double spaces. NULL input yields NULL.
 *
 * Why it exists:
 *   Delimited string lists are built and parsed in several places; a value
 *   that itself contains a delimiter character would corrupt any list it is
 *   embedded in. Scrubbing values with this before list assembly is what
 *   keeps those lists parseable.
 *
 * Example:
 *   SELECT Fn_Do_Remove_Str_List_Delimiters('|alpha|, |beta|');  -- 'alpha, beta'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Remove_Str_List_Delimiters`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Remove_Str_List_Delimiters`(v_String MEDIUMTEXT) RETURNS mediumtext CHARSET utf8mb4
BEGIN

RETURN REPLACE(
       REPLACE(
       REPLACE(
       REPLACE(
       REPLACE(
       REPLACE(
       REPLACE(
               v_String,
       CHAR(34), ''), -- double quote, ASCII 34
       CHAR(39), ''), -- single quote, ASCII 39
       '|', ''),
       '~', ''),
       '^', ''),
       '  ', ' '),
       '  ', ' ') ;

END
