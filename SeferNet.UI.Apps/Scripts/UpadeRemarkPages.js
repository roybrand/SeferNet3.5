var ErrorBackGrounColor = "#ff9090";
var NormalBackGrounColor = "white";

function CheckDatesConsistency(validFromID, validToID, activeFromId) {

    var strValidFrom = document.getElementById(validFromID).value;
    var strValidTo = document.getElementById(validToID).value;
    var strActiveFrom = document.getElementById(activeFromId).value;

    var validityResponse = "";
    var currentDate = new Date();
    currentDate.getDate();
    currentDate.setHours(0, 0, 0, 0);

    var activeFrom_Valid = false;
    var validFrom_Valid = false;
    var validTo_Valid = false;

    dateValidFrom = ConvertStringToDate(strValidFrom);
    dateValidTo = ConvertStringToDate(strValidTo);
    dateActiveFrom = ConvertStringToDate(strActiveFrom);

    if (CheckStringDate(strValidFrom) == false) {
        validityResponse = validityResponse + "\r\n" + "התאריך 'בתוקף מ' אינו תקין";
        document.getElementById(validFromID).style.backgroundColor = ErrorBackGrounColor;
        validFrom_Valid = false;
    }
    else {
        validFrom_Valid = true;
    }

    if (CheckStringDate(strValidTo) == false) {
        validityResponse = validityResponse + "\r\n" + "התאריך 'בתוקף עד' אינו תקין";
        document.getElementById(validToID).style.backgroundColor = ErrorBackGrounColor;
        validTo_Valid = false;
    }
    else {
        validTo_Valid = true;
    }

    if (CheckStringDate(strActiveFrom) == false) {
        validityResponse = validityResponse + "\r\n" + "התאריך 'מוצג מתאריך' אינו תקין";
        document.getElementById(activeFromId).style.backgroundColor = ErrorBackGrounColor;
        activeFrom_Valid = false;
    }
    else {
        activeFrom_Valid = true;
        //document.getElementById(activeFromId).style.backgroundColor = NormalBackGrounColor;
    }

    if (validFrom_Valid && validTo_Valid && activeFrom_Valid) {

        if (dateValidFrom > dateValidTo) {
            validityResponse = validityResponse + "\r\n" + "תאריך 'תוקף מ' אמור להיות כטן מ'תוקף עד'";
            document.getElementById(validToID).style.backgroundColor = ErrorBackGrounColor;
            document.getElementById(validFromID).style.backgroundColor = ErrorBackGrounColor;
        }
        else {
            document.getElementById(validToID).style.backgroundColor = NormalBackGrounColor;
            document.getElementById(validFromID).style.backgroundColor = NormalBackGrounColor;
        }

        //if (dateActiveFrom < currentDate || dateActiveFrom > dateValidFrom) {
        if (dateActiveFrom > dateValidFrom) {

            validityResponse = validityResponse + "\r\n" + "תאריך 'מוצג מתאריך' אמור להיות קטן או שווה מ'בתוקף מ'";
            document.getElementById(activeFromId).style.backgroundColor = ErrorBackGrounColor;
        }
        else {
            if (activeFrom_Valid) {
                document.getElementById(activeFromId).style.backgroundColor = NormalBackGrounColor;
            }
        }
    }

    if (validityResponse != "") {
        alert(validityResponse);
    }

}

function ConvertStringToDate(strDate) {
    if (strDate == "") {
        return new Date();
    }
    else if (strDate == "היום") {
        var d = new Date();
        d.setHours(0, 0, 0, 0);
        return d;
    }
    else {
        var dateParts = strDate.split("/");
        return new Date(+dateParts[2], dateParts[1] - 1, +dateParts[0]);
    }
}

function CheckStringDate(strDate) {
    if (strDate == "") {
        return true;
    }
    else if (strDate == "היום") {
        return true;
    }
    else {
        var dateParts = strDate.split("/");

        if ((dateParts[1] - 0) <= 31 && (dateParts[1] - 0) <= 12 && (dateParts[2] - 0) > 1900 && (dateParts[2] - 0) <= 9999) {

            return true;
        }
        else {
            return false;
        }
    }
}

function AllRowsAreValid() {
    var rowsAreValid = true;

    $("input[type='text']").each(function () {
        var bgColor = $(this).css('background-color')

        var hexColor = rgb2hex(bgColor);
        if (hexColor == ErrorBackGrounColor) {
            rowsAreValid = false;
            return rowsAreValid;
        }
    })

    if (!rowsAreValid) {
        alert("הנתונים לא תקינים");
        return false;
    }
    else {
        return true;
    }

}

function rgb2hex(rgb) {
    rgb = rgb.slice(4, 17);
    arrRGB = rgb.split(",");

    return "#" + parseInt(arrRGB[0], 10).toString(16)
        + parseInt(arrRGB[1], 10).toString(16)
        + parseInt(arrRGB[2], 10).toString(16);
}

function TodaysDateFormatted() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1;

        var yyyy = today.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        }
        if (mm < 10) {
            mm = '0' + mm;
        }
    return  dd + '/' + mm + '/' + yyyy;
}