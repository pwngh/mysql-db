# MySQL Utility Function Library

A reusable library of MySQL stored functions for input scrubbing/validation, date and currency display formatting, JSON helpers, and text utilities — plus example table DDL with audit triggers, an example JSON-args page-data function/procedure pair, and an example scheduled event.

Everything is plain `.sql`, one routine per file, targeting MySQL 8.0+.

## Repository layout

| Directory | Contents |
| --- | --- |
| `stored_functions/` | The utility function library (36 `Fn_Do_*` functions) plus the example `Fn_Get_Page_Data` |
| `stored_procedures/` | `App_Get_Page_Data` — example wrapper procedure that returns result JSON plus execution metadata |
| `tables/` | Example table DDL: a data table with audit-column triggers and a reference/lookup table |
| `events/` | Example scheduled event: nightly cleanup of old example-table rows |

## Installation

Apply the scripts in this order (later objects call earlier ones at run time):

1. `stored_functions/` — order within the folder does not matter; MySQL resolves function-to-function calls at execution time
2. `tables/` — adjust the `mysql_db` schema name to your own database
3. `stored_procedures/`
4. `events/` — requires the event scheduler (`SET GLOBAL event_scheduler = ON;`)

Each routine script is a documentation header, a `DROP ... IF EXISTS`, then the `CREATE`, so re-running a script upgrades the routine in place. Because routine bodies contain semicolons, apply the scripts with a client that handles multi-statement scripts (MySQL Workbench, DataGrip, etc.), or wrap them with a delimiter override for the `mysql` CLI:

```bash
for f in stored_functions/*.sql; do
  awk '/^DROP / { print; print "DELIMITER ;;"; next } { print } END { print ";;" }' "$f" \
    | mysql -u root -p my_database
done
```

Notes:

- The scripts declare `DEFINER=admin@%`. Change or remove the `DEFINER` clause to match a user that exists on your server.
- If binary logging is enabled, you may need `SET GLOBAL log_bin_trust_function_creators = 1;` (or `SUPER`/`SET_USER_ID` privileges) to create the functions.
- Time-zone conversions (`CONVERT_TZ` with named zones) require the MySQL time-zone tables to be loaded.

## Function catalog

### Scrubbing and validation

| Function | Description |
| --- | --- |
| `Fn_Do_Scrub_Boolean_Value` | Normalizes `Y`/`Yes`/`True`/`1` and `N`/`No`/`False`/`0` to `'1'`/`'0'`, otherwise NULL |
| `Fn_Do_Scrub_Data_Id_Value` | Validates a data-record ID against the data auto-increment range (1000000001–4294967295), else NULL |
| `Fn_Do_Scrub_Date_Value` | Returns a valid `DATE` or NULL |
| `Fn_Do_Scrub_DateTime_Value` | Returns a valid `DATETIME` (microsecond precision preserved when present) or NULL |
| `Fn_Do_Scrub_Decimal_Value` | Strips non-numeric characters and returns a `DECIMAL(9,3)` value |
| `Fn_Do_Scrub_Decimal_Money_Value` | Strips non-numeric characters, allowing one leading minus and one decimal point; returns a `DECIMAL(8,2)` value or NULL |
| `Fn_Do_Scrub_Integer_Value` | Strips non-numeric characters and returns a signed or unsigned integer |
| `Fn_Do_Scrub_IP_Address_Value` | Trims an IP-address string; NULL when empty |
| `Fn_Do_Scrub_Mac_Address_Value` | Trims a MAC-address string; NULL when empty |
| `Fn_Do_Scrub_Ref_Id_Value` | Validates a reference-record ID against the reference range (10001–4294967295), else NULL |
| `Fn_Do_Scrub_String_Value` | Trims a `VARCHAR` value; NULL when empty |
| `Fn_Do_Scrub_Text_Value` | Trims a `TEXT` value; NULL when empty |
| `Fn_Do_Scrub_Time_Zone_Value` | Maps common US time-zone aliases (`CST`, `ET`, `Pacific`, ...) to IANA names; defaults to `America/Chicago` |

### JSON helpers

| Function | Description |
| --- | --- |
| `Fn_Do_Get_JSON_Element_Value` | Extracts an unquoted element value from a JSON object by key (case-tolerant; the `$.` prefix is optional) |
| `Fn_Do_Scrub_JSON_Object` | Returns the JSON object as text, or NULL unless it is structurally valid and non-trivial |

### Date and time formatting

| Function | Description |
| --- | --- |
| `Fn_Do_As_Of_Display_String_Value` | Builds an `As of: Tue, 2-9-2021, 3:07 pm (CST)` report-header string for a given time zone |
| `Fn_Do_As_Of_Display_String_Value_Min` | Shorter "As of:" variant, e.g. `As of: Mar 13, 2024, 7:33 pm (CDT)` |
| `Fn_Do_Convert_Date_Format_From_Display_To_Internal` | Best-effort parse of display dates (slashes, dots, 2-digit years, trailing times) into `YYYY-MM-DD` |
| `Fn_Do_Format_Date_Standard_Display` | `2024-03-13` → `13-MAR-24` |
| `Fn_Do_Format_Date_Standard_Display_To_Hour` | `2024-03-13 19:33:19` → `13-MAR-24 7p` |
| `Fn_Do_Format_Date_To_Display_Format_With_Weekday` | `2021-02-09` → `Tue, 2-9-2021` |
| `Fn_Do_Format_Date_To_Timestamp_Milliseconds` | Date → Unix epoch timestamp in milliseconds |
| `Fn_Do_Format_DateTime_Standard_Display_Short_To_Min` | `2024-03-13 19:33:19` → `Mar 13, 2024, 7:33 pm` |
| `Fn_Do_Format_DateTime_Standard_Display_To_Min` | `2021-02-09 15:07:41` → `Tue, 2-9-2021, 3:07 pm` |
| `Fn_Do_Format_DateTime_Standard_Display_To_Sec` | `2024-03-13 19:33:19` → `Wed, 3-13-2024, 7:33:19 pm` |
| `Fn_Do_Format_DateTime_Time_Zone_Prefix_Display_To_Min` | Converts a UTC datetime to a time zone, prefixes a label, and appends the zone abbreviation |
| `Fn_Do_Get_CT_DateTime` | Current datetime in US Central Time |

### Number, currency, and boolean display

| Function | Description |
| --- | --- |
| `Fn_Do_Format_Number_To_Currency_Display` | `1234.5` → `$1,234.50` |
| `Fn_Do_Format_Number_To_Currency_Display_Short` | Whole-dollar display: `1234.5` → `$1,235` |
| `Fn_Do_Format_Number_Wrap_With_Parenthesis` | Wraps a value in parentheses (accounting-style negatives) |
| `Fn_Do_Convert_To_Yes_No` | Boolean-ish input (`Y`/`On`/`1`/`true`/...) → `Yes`/`No` |

### Text utilities

| Function | Description |
| --- | --- |
| `Fn_Do_Remove_Duplicate_Spaces_From_Text` | Trims and collapses runs of spaces down to a single space |
| `Fn_Do_Remove_Str_List_Delimiters` | Strips quote, pipe, tilde, and caret delimiter characters from a string list |
| `Fn_Do_Titlecase_Text` | Title-cases text with handling for small words, acronyms, `Mc`/`Mac` surnames, and US state abbreviations |

### Process helpers

| Function | Description |
| --- | --- |
| `Fn_Do_Get_Elapsed_Micro_Time` | Elapsed-time display between two `DATETIME(6)` values (used for query timing in result metadata) |
| `Fn_Do_Get_Random_Process_Key` | Random integer key (10000–4294967295) for tagging a process run |

### Example page-data pattern

| Object | Description |
| --- | --- |
| `Fn_Get_Page_Data` (function) | Example JSON-args data function: scrubs its arguments, retries on deadlock/lock-timeout, and returns a result JSON object or a structured error JSON |
| `App_Get_Page_Data` (procedure) | Example application entry point: calls `Fn_Get_Page_Data` and returns the result JSON alongside query name, database, execution time, and elapsed time |

## Usage examples

```sql
SELECT Fn_Do_Format_DateTime_Standard_Display_To_Sec('2024-03-13 19:33:19');
-- Wed, 3-13-2024, 7:33:19 pm

SELECT Fn_Do_Format_Number_To_Currency_Display('1234.5');
-- $1,234.50

SELECT Fn_Do_Scrub_Integer_Value('$1,234 USD');
-- 1234

SELECT Fn_Do_Get_JSON_Element_Value('{"v_User_Account_Id": "1000000001"}', 'v_User_Account_Id');
-- 1000000001
```

The page-data pattern is called with a single JSON argument:

```sql
CALL App_Get_Page_Data(JSON_OBJECT('v_User_Account_Id', '1000000001'));
```

## License

MIT — see [LICENSE](LICENSE).
