var CALENDAR_ID = 'YOUR_CALENDAR_ID'
var SHEET_NAME = 'YOUR_SHEET_NAME'

function sheet2calendar() {
  var sheet, i, myTitle, myDate, myDescription, added;
  sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_NAME);
  for (var i = 2; i <= sheet.getLastRow(); i++) {
    myTitle = sheet.getRange(i, 1).getValue();
    myDate = sheet.getRange(i, 2).getValue();
    myDescription = sheet.getRange(i, 3).getValue();
    added = sheet.getRange(i, 4).getValue();
    if(added == "") {
      thisevent = CalendarApp.getCalendarById(CALENDAR_ID).createAllDayEvent(myTitle, myDate, {
        description: myDescription
      });
      sheet.getRange(i, 4).setValue("Complete");
     }
   }
}

