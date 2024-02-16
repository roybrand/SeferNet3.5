import { Hidden } from "@mui/material";
import { motion } from "framer-motion";

const container = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        delayChildren: 11.5,
        duration: 20
        
      }
    }
  }
  
function Loader(props) {

    return(<div className={props.isLoading ? "loader loader_open" : "loader"}
    //variants={container}
    //initial="hidden"
    //animate="show"
                       >
              <span className="loader__content"></span>
           </div>)
}

export default Loader