var Browser =
{ Version: function() {
    var version = 999;
    if (navigator.appVersion.indexOf("MSIE") != -1)
        version = parseFloat(navigator.appVersion.split("MSIE")[1]);
    return version;
}
}