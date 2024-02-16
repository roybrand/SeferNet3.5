
        function validFalse()
		{			
			window.event.returnValue = true;
		}
		
		function MouseOverItem()
		{
		    window.event.srcElement.style.backgroundColor="#D3e5fd";		    
		}
		function MouseOutItem()
		{
		    window.event.srcElement.style.backgroundColor="transparent";
		}

		function ClearCheckBoxes() 
		{
		    inputs = document.getElementsByTagName('input');

		    for (i = 0; i < inputs.length; i++) 
		    {
		        if (inputs[i].checked) 
		        {
		            inputs[i].checked = false;
		        }
		    }
		}		
    
    

