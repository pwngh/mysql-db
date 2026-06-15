/* Fn_Do_Convert_To_Yes_No.sql
 *
 * Converts a boolean-ish token (Yes/On/Y/1/true and their negatives) to the
 * display words 'Yes' or 'No'. Unrecognized input returns NULL.
 *
 * Why it exists:
 *   Flag columns are stored as '1'/'0'; this is the display-side conversion,
 *   kept in the DB layer so every page and export prints flags the same way.
 *   Matching is exact-token, case-insensitive under the default collation.
 *
 * See also: Fn_Do_Scrub_Boolean_Value, the storage-side counterpart.
 *
 * Example:
 *   SELECT Fn_Do_Convert_To_Yes_No('on');  -- 'Yes'
 */

DROP FUNCTION IF EXISTS `Fn_Do_Convert_To_Yes_No`;

CREATE DEFINER=`admin`@`%` FUNCTION `Fn_Do_Convert_To_Yes_No`(v_Var VARCHAR(20)) RETURNS varchar(20) CHARSET utf8mb4
BEGIN

SET v_Var = (SELECT Fn_Do_Scrub_String_Value(v_Var)) ;

RETURN (CASE WHEN (IFNULL(v_Var,'') = '') THEN NULL
             -- ------------------------
             WHEN (IFNULL(v_Var,'') = 'Yes') THEN 'Yes'
             WHEN (IFNULL(v_Var,'') = 'On') THEN 'Yes'
             WHEN (IFNULL(v_Var,'') = 'Y') THEN 'Yes'
             WHEN (IFNULL(v_Var,'') = '1') THEN 'Yes'
             WHEN (IFNULL(v_Var,'') = 'true') THEN 'Yes'
             -- ------------------------
             WHEN (IFNULL(v_Var,'') = 'No') THEN 'No'
             WHEN (IFNULL(v_Var,'') = 'Off') THEN 'No'
             WHEN (IFNULL(v_Var,'') = 'N') THEN 'No'
             WHEN (IFNULL(v_Var,'') = '0') THEN 'No'
             WHEN (IFNULL(v_Var,'') = 'false') THEN 'No'
             -- ------------------------
             ELSE NULL END) ;

END
