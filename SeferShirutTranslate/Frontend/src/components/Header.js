import { Link } from "react-router-dom"

function Header(props) {

    function setPageName(name) {
        props.setPageName(name)
        //console.log("(header) page name: ", name)
        //console.log("(header) props page name: ", props.pageName)
    }

    function getMenu() {
        return(<div className="header__menu">
                 <Link className="header__link" to={props.navigateTo("/tables")} onClick={() => setPageName('tables')}>טבלאות</Link>
                 <Link className="header__link" to={props.navigateTo("/translate")} onClick={() => setPageName('translate')}>תרגום</Link>
               </div>
        )
    }

    return (<div className='header'>
                {getMenu()}
                <div className="header__headline">ניהול שפה</div>
            </div>
            )

    /*if(props.isLogin) {
        return (
            <div className='header'>
                <div className="header__login">
                    <span className="header__name">שלום {`${props.firstName}`}</span>
                    <button className="header__button" onClick={() => { props.onClick(false); props.setIsLogin(false) } }>התנתק</button>
                </div>
                {getMenu()}
                <div className="header__headline">ניהול שפה</div>
            </div>
        )
    }
    else {
        return (
            <div className='header'>
                <div className="header__login">
                    <button className="header__button" onClick={() => { props.onClick(true) } }>התחבר</button>
                </div>
                {getMenu()}
                <div className="header__headline">ניהול שפה</div>
            </div>
        )
    }*/
    
}

export default Header;