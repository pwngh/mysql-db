/* Fn_Do_Scrub_Boolean_Value.sql
 *
 * Normalizes boolean-ish input (1/Y/Yes/True, 0/N/No/False) to '1' or '0'.
 * Anything unrecognized comes back NULL rather than being guessed at.
 *
 * Why it exists:
 *   Part of the scrub layer every inbound value passes through before it is
 *   stored or used in a query. Boolean values arrive from JSON args and form
 *   posts in many spellings; normalizing here means flag columns and WHERE
 *   clauses only ever deal with '1'/'0'.
 *
 * Notes:
 *   - Matching is exact-token, case-insensitive under the default collation.
 *   - Returns VARCHAR, not TINYINT: scrub functions keep string-in/string-out
 *     contracts so they compose cleanly inside JSON request handling.
 *
 * See also: Fn_Do_Convert_To_Yes_No, the display-side counterpart.
 *
 * Example:
 *   SELECT Fn_Do_Scrub_Boolean_Value('Yes');  -- '1'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Scrub_Boolean_Value`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Scrub_Boolean_Value`(v_Val VARCHAR(20)) RETURNS varchar(20) CHARSET utf8mb4
BEGIN

RETURN (CASE WHEN (IFNULL(v_Val,'') = '') THEN NULL
             WHEN (IFNULL(v_Val,'') = '1') THEN '1'
             WHEN (IFNULL(v_Val,'') = 'Y') THEN '1'
             WHEN (IFNULL(v_Val,'') = 'Yes') THEN '1'
             WHEN (IFNULL(v_Val,'') = 'True') THEN '1'
             WHEN (IFNULL(v_Val,'') = '0') THEN '0'
             WHEN (IFNULL(v_Val,'') = 'N') THEN '0'
             WHEN (IFNULL(v_Val,'') = 'No') THEN '0'
             WHEN (IFNULL(v_Val,'') = 'False') THEN '0'
             ELSE NULL END) ;

END
