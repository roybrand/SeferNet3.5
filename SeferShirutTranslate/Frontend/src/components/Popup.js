import React, { Children } from 'react';
import '../styles/Popup.css'
import { motion } from "framer-motion";

function Popup(props) {

    //const [isOpen, setIsOpen] = React.useState(true);
    function onSubmit() {
        console.log("(popup) submited")

    }

    function onClose() {
        //console.log("on close clicked")
        //props.setIsOpen2(false)
        props.onClose(false);
    }

    return(<motion.div className={props.isOpen ? 'popup popup_open' : 'popup' /**change this name */} 
                       initial= {{
                            opacity: 0,
                            
                       }}
                       animate={{
                       opacity: 1,     
                    }}>
                <div className='popup__container'>
                    <div className="popup__container-header"><button className="popup__close" onClick={/*props.*/onClose}></button></div>
                    <div className="popup__container-content">{ props.children }</div>
                </div>
           </motion.div>
)
}

export default Popup;