/* App_Get_Page_Data.sql
 *
 * Example application entry point: the procedure a client CALLs to fetch
 * page data. Wraps Fn_Get_Page_Data and returns one row of result JSON plus
 * execution metadata.
 *
 * Why it exists:
 *   The App_* procedures are the outermost layer of the JSON API pattern:
 *   thin, uniform wrappers that return Result_Json together with Query_Name,
 *   Database_Name, execution timestamp, Elapsed_Time, and the echoed
 *   Args_Json. Keeping the logic in the Fn_Get_* function and only the
 *   result-set shape here means every endpoint looks the same to the
 *   application, and the function stays SELECT-able for debugging.
 *
 * Input / Output:
 *   - v_Args_Json: request arguments, passed through to Fn_Get_Page_Data
 *   - Returns one row: Query_Name, Database_Name,
 *     Execution_CT_DateTime_Display, Elapsed_Time, Query_Comment,
 *     Result_Json, Args_Json
 *
 * Example:
 *   CALL App_Get_Page_Data(JSON_OBJECT('v_User_Account_Id', '1000000001'));
 */

DROP PROCEDURE IF EXISTS `App_Get_Page_Data`;

CREATE DEFINER=`admin`@`%` PROCEDURE `App_Get_Page_Data`(IN v_Args_Json JSON)
BEGIN
DECLARE v_This_Procedure_Name VARCHAR(80) DEFAULT 'App_Get_Page_Data' ;
DECLARE v_Start_UTC_DateTime DATETIME(6) DEFAULT UTC_TIMESTAMP(6) ;

SELECT v_This_Procedure_Name AS 'Query_Name' ,
       (SELECT DATABASE()) AS 'Database_Name' ,
       (SELECT Fn_Do_Format_DateTime_Standard_Display_To_Sec(Fn_Do_Get_CT_DateTime())) AS 'Execution_CT_DateTime_Display' ,
       (SELECT Fn_Do_Get_Elapsed_Micro_Time(v_Start_UTC_DateTime, NULL)) AS 'Elapsed_Time' ,
       'Executed Successfully' AS 'Query_Comment' ,
       (SELECT Fn_Get_Page_Data(v_Args_Json)) AS 'Result_Json' ,
       v_Args_Json AS 'Args_Json' ;

END
