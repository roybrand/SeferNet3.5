import React from "react";
import Popup from "./Popup";
import '../styles/Login.css';

function Login(props)
{
    const [domain, setDomain] = React.useState("Clalit");
    const [username, setUsername] = React.useState("");
    const [password, setPassword] = React.useState("");

    function onSubmit() {

        props.getUserInfo(domain, username, password);
    }

    function onDomainChange(event) {
        setDomain(event.target.value);
    }

    function onUsernameChange(event) {
        setUsername(event.target.value);
    }

    function onPasswordChange(event) {
        setPassword(event.target.value);
    }

    return (<Popup isOpen={props.isOpen}
                   onClose={props.onClose}
                   getUserInfo={props.getUserInfo}
            >
                <input placeholder="Domain" type="text" value={domain} onChange={onDomainChange} className="login__input"></input>
                <input placeholder="Username" type="text" value={username} onChange={onUsernameChange} className="login__input"></input>
                <input placeholder="Password" type="password" value={password} onChange={onPasswordChange} className="login__input"></input>
                <button type="button" onClick={onSubmit} className="login__button">התחבר</button>
            </Popup>
    )
}

export default Login;