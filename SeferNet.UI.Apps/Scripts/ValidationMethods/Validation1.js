 var preservedWords = new Array("select", "delete", "alter", "update", "create", "<", ">", ";",
 "drop", "fetch", "grant", "execute", "exec", "echo", "script");

 // Used as client validation method by CustomValidator.
 function CheckPreservedWords(sender, args) 
 {
     //debugger;
     var controlName = sender.controltovalidate;
     var control = document.getElementById(controlName);
     var controlValue = control.value;

     for (var i = 0; i < preservedWords.length; i++)
     {
         var regStr = '\\b'+preservedWords[i]+'\\b';
         var reg = new RegExp(regStr, "i");
         
         if (controlValue.search(reg) != -1)
         {
             args.IsValid = false;
             return;
         } 
     }
     args.isValid = true;
 }
