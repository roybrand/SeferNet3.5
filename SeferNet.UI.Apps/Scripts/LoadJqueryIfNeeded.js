/* Load jquery file if the file is not have been loaded yet */
var jqueryScript = document.getElementById("scriptJQ");

var mainDirectory = document.location.toString().split(document.domain)[1].split("/")[1];

if (jqueryScript == null) {
    var filename = "/" + mainDirectory + "/Scripts/srcScripts/jquery.js";
    var scriptTag = document.createElement("script")
    scriptTag.setAttribute("type", "text/javascript")
    scriptTag.setAttribute("src", filename);
    scriptTag.setAttribute("id", "scriptJQ");
    document.getElementsByTagName("head")[0].appendChild(scriptTag);
}