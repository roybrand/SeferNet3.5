import Popup from "./Popup";

function Error(props) {

    return(<div>
            <Popup isOpen={props.isOpen} onClose={props.onClose}>
                {props.errorImage}
                {props.errorHeader}
                {props.errorMessage}
            </Popup>
           </div>)
}

export default Error;