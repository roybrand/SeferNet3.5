import React from 'react';
import logo from '../images/logo.svg';
import '../styles/App.css'
//import '../styles/Main.css';
import Main from './Main';
import { api } from '../utils/api';
//import Table2 from './Table2';
import Popup from './Popup';
import Login from './Login';
import Error from './Error';
//import { useNavigate } from "react-router-dom";
import Loader from './Loader';
import '../styles/Loader.css';
import { useParams } from 'react-router';
import { useNavigate, useLocation } from "react-router-dom";
import { tab } from '@testing-library/user-event/dist/tab';
import { categoryList } from '../utils/CategoryList';
import { tablesList } from '../utils/TablesList';
import { statusList } from '../utils/StatusList';
import Constants from '../utils/Constants';

function App() {
  //next: 1. Upload to test server backend and frontend
  //      2. Pass login user from sefer in aspx to rest api
  //      3. How to get table type
  //      4. Promise error
  //      5. Send email about error
  //      6. Add all tables with empty values add select by timestemp 
  //      7. Add category menu
  //      8. Close popup on Enter click and chose menu item in dropdown
  //      9. Get token from sefer net link redirect
  //     10. Get id from category drop down (id - not name) - done
  //     11. Create own own autocomplite
  //     12. Fix this error - 'Each child in a list should have a unique "key" prop'
  //     13. Work on time stamp - "Wait for translate"
  //     14. Add status drop down
  //     15. Stick panel (with the drop downs) to top on scroll
  //     16. ISS is not get the route (not the parameters) - v
  //     17. Upgrade the table to work with  paging
  //     18. add all tabels to translate table
  //     19. Display table data in pagging
  //     20. Pass userInfo by the token <-----------------
  //     21. Add array of page load - if all finish then close loading <------------------------

  const [translates, setTranslates] = React.useState([]);
  const [rowsForUpdate, setRowsForUpdate] = React.useState([]);
  const [translatePageSize, setTranslatePageSize] = React.useState(100);
  const [translatePageIndex, setTranslatePageIndex] = React.useState(1);
  const [translateTotalCount, setTranslateTotalCount] = React.useState(0);
  const [tables, setTabels] = React.useState([]);
  const [tablesPageSize, settablesPageSize] = React.useState(50);
  const [tablesPageIndex, settablesPageIndex] = React.useState(1);
  const [isLogin, setIsLogin] = React.useState(true);
  const [isLoginOpen, setIsLoginOpen] = React.useState(false);
  const [errorMessage, setErrorMessage] = React.useState("");
  const [isErrorOpen, setIsErrorOpen] = React.useState(false);
  const [pageName, setPageName] = React.useState("translate"); // change to selectedPageName
  const [selectedTable, setSelectedTable] = React.useState("All");
  const [selectedTableTypeCode, setSelectedTableTypeCode] = React.useState(0);
  const [selectedStatusCode, setSelectedStatusCode] = React.useState(0);
  const [token, setToken] = React.useState("");
  const [firstName, setFirstName] = React.useState("");
  const [isLoading, setIsLoading] = React.useState(false);
  //arary for all on load
  const [completeLoading, setCompleteLoading] = React.useState({tables: false, translates: false})
  
  //const [isPostBack, setIsPostBack] = React.useState(false); //not in use
  //const [isUpdateFromUrlEnd, setIsUpdateFromUrlEnd] = React.useState(false); //not in use

  const navigate = useNavigate();

  const { table, category } = useParams();

  const location = useLocation();

  function onSetPageName(name) {
    setPageName(name)
  }

  function onTableNameChange(event, value, reason) {//delete event an reason
    let tableName;

    if(value == null) {
      tableName = "";
    }
    else {
      tableName = value.label;
    }
    
    if(tableName == "כולם")
    {
      tableName = "All"; 
    }

    setSelectedTable(tableName);
    setNavigation("OnChange", null, tableName, null, null);
  }

  /*function onTableTypeCodeChange(value) {
    setSelectedTableTypeCode(value)
  }*/

  /*************************************
   * categoryCode equels tableTypeCode *
   *************************************/
  function onCategoryChange(event, option) {//change option to value. delete event
    const categoryHebrewLabel = option;
    const categoryCode = getCategoryCodeByHebrewLabel(categoryHebrewLabel);

    setSelectedTableTypeCode(categoryCode);
    setNavigation("OnChange", null, null, categoryCode, null);
  }

  function getCategoryLabelByCode(tableTypeCode) {
    let label;

    categoryList.forEach((item) => {
        if(item.code == tableTypeCode) {
            label = item.hebrewLabel
        }
    })

    return label;
  }

  function getCategoryCodeByHebrewLabel(category) {
    let code;

    categoryList.forEach((item) => {
        if(item.hebrewLabel == category) {
            code = item.code;
        }
    })

    return code;
  }

  function onStatusChange(event, option) {//change option to value. delete event
    const statusHebrewLabel = option;
    const statusCode = getStatusCodeByLabel(statusHebrewLabel);

    //console.log("onStatusChange. status code => ", statusCode);

    setSelectedStatusCode(statusCode);

    setNavigation("OnChange", null, null, null, statusCode);
  }

  function getStatusCodeByLabel(statusLabel) {
    let code;

    statusList.forEach((item) => {
        if(item.hebrewLabel == statusLabel) {
            code = item.code
        }
    })

    return code;
  }

  function renderTranslates(translates) {
    setTranslates(translates);
  }

  function onTranslateUpdateClick(row) {

    api.UpdateTranslate(row)
  }

  function onTablesUpdateClick(row) {
    //navigate(`/translate/${row.tableName}/All`);

    setNavigation("OnChange", "translate", row.tableName, 0);
  }

  function onLoginClick(isOpen){
    
    setIsLoginOpen(isOpen);
  }

  function onTranslatePageIndexChange(value) {

    console.log("onTranslatePageIndexChange fire. value => ", value)

    setTranslatePageIndex(value);
  }

  function getData(row) {
    if(row['unitType'] != '') return row['unitType'];
    else if(row['activityStatus'] != '') return row['activityStatus'];
    else if(row['agreementType'] != '') return row['agreementType'];
    else if(row['dept'] != '') return row['dept'];
    else if(row['DICYesAndNo'] != '') return row['DICYesAndNo'];
  }

  function getTimestamp(row) {
    if(row['tableName'] === 'UnitType') return row['unitTypeTimestamp'];
    else if(row['tableName'] === 'DIC_ActivityStatus') return row['activityStatusTimestamp'];
    else if(row['tableName'] === 'DIC_AgreementTypes') return row['agreementTypeTimestamp'];
  }

  function clearData(data) {
    let cleanRow;
    let cleanData = [];

    data.map((row) => {
      cleanRow = {};
      cleanRow['id'] = row['id']
      cleanRow['tableName'] = row['tableName']
      cleanRow['tableTypeCode'] = row['tableTypeCode']
      cleanRow['tableCode'] = row['tableCode']
      cleanRow['translate'] = row['translate']
      cleanRow['languageDescription'] = row['languageDescription']
      cleanRow['lastUpdate'] = row['lastUpdate']
      cleanRow['data'] = getData(row);
      cleanRow['timestamp'] = getTimestamp(row);
      cleanRow['totalCount'] = row['totalCount']

      cleanData.push(cleanRow);
    })

    return cleanData;
  }

  /* filterData notes **************************************
   * data:   The source data from backend                  *
   * filter: Parameters to search in data                  *
   * Not in use anymore. The filter not is in the backend  *
   *********************************************************/
  function filterData(data, filters) {

    data = clearData(data);

    setTranslateTotalCount(data[0].totalCount)

    let index;

    index = filters.findIndex((filter) => {
      return (filter.column == "tableName" && filter.value == "All");
    })

    if(index > -1) filters.splice(index, 1); //If seleceted table = All - then remove it from the filter search (to display all data)

    index = filters.findIndex((filter) => {
      return (filter.column == "tableTypeCode" && filter.value == "0");
    })

    if(index > -1) filters.splice(index, 1); //If seleceted category (table type) = 0 - then remove it from the filter search (to display all data)

    let result = [];

    let matches = [];

    let selectedData = (data.filter((row) => {//Return a row if it mach all filters

      matches = [];

      for(let filter of filters) {
        if(row[filter.column] == filter.value) matches.push(true)
        else matches.push(false)
      }
      
      if(matches.every(element => element === true)) return row;
    }))

    if(selectedStatusCode == 1 || selectedStatusCode == 2) {
      selectedData = filterByTimestamp(selectedData, selectedStatusCode)
    }

    selectedData = selectedData.map((row) => {
      return jsonToKeyValueArray(row).map((column) =>
      {
        return jsonToArray(column);
      })
    })
    
    let rowObject;
    selectedData.forEach((row) => {
      rowObject = {}
      row.forEach((column) => {
        rowObject[column[0]] = column[1];
      })
      result.push(rowObject)
    })

    return result;
  }

  function filterByTimestamp(data, statusCode) {
    let waitsForUpdate = [];
    let notWaitsForUpdate = [];
    let foundRow;

    data.forEach((translateItem, index) => {
      foundRow = rowsForUpdate.filter((filter) =>  filter.timeStamp == translateItem['timestamp'] )

      if(foundRow.length > 0) waitsForUpdate.push(translateItem);
      else notWaitsForUpdate.push(translateItem);
    })

    if(statusCode == 1) return notWaitsForUpdate;
    else if(statusCode == 2) return waitsForUpdate;
    else return data;
  }

  function jsonToKeyValueArray(json){
    let result = [];
    let keys = Object.keys(json);
    keys.forEach(function(key) {
        result.push({[key]: json[key]});
    });
    return result;
  }

  function jsonToArray(json) {
    let result = [];
    let keys = Object.keys(json);
    keys.forEach(function(key) {
        result.push(key, json[key]);
    });
    return result;
  }

  function jsonArrayToKeyValueArray(json) {
    let result = [];
    json.forEach((item) => {
      result.push(jsonToArray(item));
    })

    return result;
  }

  function getUserInfo(domain, username, password) {

    api.GetUserInfo({domain, username, password}).then((response) => {

        response.json().then((data) => {
                        
            if(data.userID > 0)
            {
              setFirstName(data.firstName);
              setIsLogin(true);
              setIsLoginOpen(false);
              setIsLoading(false);
            }
            else {
              console.log("User not found")
              api.SendEmail("OnLoad.GetUserInfo", "User not found. userID <= 0")
              setIsLoading(false);
              setIsLoginOpen(false);
              setIsErrorOpen(true);
              setErrorMessage("המשתמש לא נמצא")
            }
        })
    }).catch((error) => {
      console.log("getUserInfo error: ", error);
      setIsLoading(false);
      setIsLogin(false);
      setIsErrorOpen(true);
      setErrorMessage("שגיאת מערכת. בעיה בטעינת נתונים. נשלח מייל למפתחים")
      api.SendEmail("OnLoad.GetUserInfo", error);
    })
  }

  function getTableName (tableName) {

    //console.log("tableName =>", tableName)

    if(tableName.toLowerCase() === "all") {
      tableName = "כולם"
    }

    return tableName;
  }

  function getStatusByCode(statusCode) {
    let label;

    statusList.forEach((item) => {
        if(item.code == statusCode) {
            label = item.hebrewLabel
        }
    })

    return label;
  }

  //make array for all the onload functions - if all finish loading = false

  /* On load notes ****************************************************************************
   * All the changes in state parameters need to be pass through the thus on load functions.  *
   * Change the state parameters and let thus function to do the job throw the on load        *
   ********************************************************************************************/
  React.useEffect(() => {
    setIsLoading(true);

    console.log("(PageLoad) tables. token =", token, getDatetime())

    /*if(token === "") {
      api.CheckToken(token).then((response) => {
        console.log("(PageLoad) tables. response =", response, getDatetime())
        if(response.ok != true) {
          console.log("CheckToken response.ok is false")
          setIsLoading(false);
          //setIsErrorOpen(true);
          //setErrorMessage("שגיאת מערכת. בעיה בטעינת נתונים. נשלח מייל למפתחים");
          api.SendEmail("OnLoad.CheckToken token return false", `User ${firstName} got response.ok is false.<br/>token = ${token}`);
        }
        
        response.json().then((data) => {
          setIsLoading(false);
          setIsErrorOpen(false);
          setToken(data.token)

          console.log("(PageLoad) tables token returns", getDatetime())
        })

      }).catch((error) => {
        console.log("CheckToken error: ", error)
        setIsLoading(false);
        setIsErrorOpen(true);
        setErrorMessage("שגיאת מערכת. בעיה בטעינת נתונים. נשלח מייל למפתחים");
        api.SendEmail("OnLoad.CheckToken", error);
      })
    }
    else {*/
     
      api.GetTabels().then((response) => {

        response.json().then((data) => {

          data.map((column, index) => {
            column["id"] = "Table-" + (index + 1);
          })

          setTabels(data);

        })
      }).catch((error) => {
        console.log("GetTabels error: ", error)
        setIsLoading(false);
        //setIsErrorOpen(true);
        //setErrorMessage("שגיאת מערכת. בעיה בטעינת נתונים. נשלח מייל למפתחים");
        api.SendEmail("OnLoad.GetTabels", error);
      })
    //}

  }, [selectedTable, selectedTableTypeCode, selectedStatusCode, rowsForUpdate, token]); //delete token rowsForUpdate...

  React.useEffect(() => {
    setIsLoading(true);

    console.log("(PageLoad) completeLoading:", completeLoading, getDatetime())

    /*if(token === "") {
      api.CheckToken(token).then((response) => {
        if(response.ok != true) {
          console.log("CheckToken response.ok is false")
          setIsLoading(false);
          setIsErrorOpen(true);
          setErrorMessage("שגיאת מערכת. בעיה בטעינת נתונים. נשלח מייל למפתחים");
          api.SendEmail("OnLoad.CheckToken token return false");
        }
        
        response.json().then((data) => {
          setIsLoading(false);
          setIsErrorOpen(false);
          setToken(data.token)

          console.log("(PageLoad) translates token returns", getDatetime())
        })

      }).catch((error) => {
        console.log("CheckToken error: ", error)
        setIsLoading(false);
        setIsErrorOpen(true);
        setErrorMessage("שגיאת מערכת. בעיה בטעינת נתונים. נשלח מייל למפתחים");
        api.SendEmail("OnLoad.CheckToken", error);
      })
    }
    else {*/
     
      console.log("GetTranslates start", getDatetime())
      
      api.GetTranslates(selectedTable, selectedTableTypeCode, selectedStatusCode, translatePageIndex, translatePageSize).then((response) => {
        
        response.json().then((data) => {

          console.log("GetTranslates call. translate data =>", data)

          data = clearData(data);

          setTranslateTotalCount(data[0].totalCount)

          data.map((column, index) => {
            column["id"] = "Translate-" + (index + 1);
          })

          console.log("GetTranslates result return", getDatetime())

          //console.log("data. count found? =>", data)

          //const filteredData = filterData(data, filters);

          //console.log("filteredData: ", filteredData);

          setIsLoading(false)

          setIsErrorOpen(false);

          //setTranslates(filteredData);
          setTranslates(data);

        })
      }).catch((error) => {
        console.log("GetTranslates error: ", error)
        setIsLoading(false);
        setIsErrorOpen(true);
        setErrorMessage("שגיאת מערכת. בעיה בטעינת נתונים. נשלח מייל למפתחים");
        api.SendEmail("OnLoad.GetTranslation", error);
      })
    //}

  }, [selectedTable, selectedTableTypeCode, selectedStatusCode, rowsForUpdate, translatePageIndex, translatePageSize, token]);
  
  React.useEffect(() => {
    setIsLoading(true);

    console.log("(PageLoad) GetTimestampChanges change", getDatetime())

    if(selectedStatusCode == 1 || selectedStatusCode == 2) {
      api.GetTimestampChanges().then((response) => {

        response.json().then((data) => {
          setRowsForUpdate(data);

          console.log("(PageLoad) GetTimestampChanges return", getDatetime())
        })
      }).catch((error) => {
        console.log("OnStatusChange error: ", error)
        api.SendEmail("OnLoad.GetTranslation", error);
        setIsLoading(false);
        setIsErrorOpen(true);
        setErrorMessage("שגיאת מערכת. בעיה בטעינת נתונים. נשלח מייל למפתחים");
      })
    }
  }, [selectedTable, selectedTableTypeCode, selectedStatusCode]);

  React.useEffect(() => {
    setNavigation("OnLoad", pageName, selectedTable, selectedTableTypeCode, selectedStatusCode);
  }, []);

  /*React.useEffect(() => {//delete it
    setIsPostBack(true);
  }, []);*/

  function setNavigation(source, selectedPage, selectedTable, selectedTableTypeCode, selectedStatusCode) {
    const pathnameList = location.pathname.split('/')
    let page = pathnameList[1];
    let table = pathnameList[2];
    let categoryCode = pathnameList[3];
    let statusCode = pathnameList[4];
    const token = pathnameList[5];

    console.log("(Navigation) token =>", token);

    let navigationPath = null;

    switch(source)
    {
      case 'OnLoad':

        if(page === "" || page === null || typeof(selectedPage) === 'undefined') {
          page = "translate";
        }
    
        if(table === "" || table === null || typeof(table) === 'undefined') {
          table = "All"
        }

        if(categoryCode === "" || categoryCode === null || typeof(categoryCode) === 'undefined') {
          categoryCode = "0";
        }
        
        if(statusCode === "" || statusCode === null || typeof(statusCode) === 'undefined') {
          statusCode = "0"; 
        }

      break;

      case 'OnChange':

        if(selectedPage !=  null) {
          page = selectedPage;
        }

        if(selectedTable !=  null) {
          table = selectedTable;
        }

        if(selectedTableTypeCode !=  null) {
          categoryCode = selectedTableTypeCode;
        }

        if(selectedStatusCode !=  null){
          statusCode = selectedStatusCode;
        }

        if(page === "" || page === null || typeof(selectedPage) === 'undefined') {
          page = "translate";
        }
    
        if(table === "" || table === null || typeof(table) === 'undefined') {
          table = "All"
        }

        if(categoryCode === "" || categoryCode === null || typeof(categoryCode) === 'undefined') {
          categoryCode = "0";
        }
        
        if(statusCode === "" || statusCode === null || typeof(statusCode) === 'undefined') {
          statusCode = "0"; 
        }

      break;
    }

    setPageName(page)
    setSelectedTable(table);
    setSelectedTableTypeCode(categoryCode);
    setSelectedStatusCode(statusCode);

    if(typeof(token) != 'undefined') setToken(token);

    navigationPath = `/${page}/${table}/${categoryCode}/${statusCode}`

    if(navigationPath != null) navigate(navigationPath);

    const message = `<NavigationPath>${navigationPath}</NavigationPath>`;

    window.parent.postMessage(message, '*');
  }

  function navigateTo(link) {
    return `${link}/${selectedTable}/${selectedTableTypeCode}/${selectedStatusCode}`
  }

  function isTableInList(name)
  {
    return tablesList.includes(name);
  }

  function isCategoryInList(name)
  {
    return categoryList.includes(name);
  }

  function updateTranslates (event, indexToUpdate) {
        
    const updatedTranslates = translates.map((element, index) => {

         if(index === indexToUpdate) {
             element.translate = event.target.value;
         }

         return element;
     });

     renderTranslates(updatedTranslates);
  }

  function getDatetime() {
    
    return `${new Date().getDay()}/${new Date().getMonth()}/${new Date().getFullYear()} ${new Date().getHours()}:${new Date().getMinutes()}:${new Date().getSeconds()}:${new Date().getMilliseconds()}`;
  }

  /*window.addEventListener('message', function (event) {
    // Get the sent data
    const data = event.data;

    console.log("message data from parent2: ", data);
    // If you encode the message in JSON before sending them,
    // then decode here
    // const decoded = JSON.parse(data);
  });*/
  
  const translateColumnsHeaders = [{name: "שם טבלה", class: "table__column table__column_width-150"},
                                   {name: "מקור", class: "table__column table__column_width-100"},
                                   {name: "תרגום", class: "table__column table__column_width-150"},
                                   {name: "שפה", class: "table__column table__column_width-100"},
                                   {name: "עדכון אחרון", class: "table__column table__column_width-150"}];
  
  if(isLogin) translateColumnsHeaders.push({name: "", class: "table__column table__column_width-100"})

  const columnsStyles = [{name: "tableName", class: "table__column table__column_width-150", element: "span", elementClass: "table__element", function: null, filter: selectedTable},
                         {name: "data", class: "table__column table__column_width-100", element: "span", elementClass: "table__element", function: null},
                         {name: "translate", class: "table__column table__column_width-150", element: "input", elementClass: "table__changeable-input table__column_background", function: updateTranslates},
                         {name: "languageDescription", class: "table__column table__column_width-100", element: "span", elementClass: "table__element", function: null},
                         {name: "lastUpdate", class: "table__column table__column_width-150 table__column_left", element: "date", elementClass: "table__element", function: null}];

  if(isLogin) columnsStyles.push({name: "button", class: "table__column table__column_width-100 table__column_center", element: "button", elementClass: "table__button", function: onTranslateUpdateClick});
  
  const filters = [{column: "tableName", value: selectedTable},
                   {column: "tableTypeCode", value: selectedTableTypeCode}
                 //{column: "languageDescription", value: "����������"}
                 /*{column: "tableCode", value: 1}*/]

  const tablesColumnsHeaders = [{name: "שם טבלה", class: "table__column table__column_width-150", element: "span", function: null},
                                {name: "קטגוריה", class: "table__column table__column_width-100", element: "span", function: null},
                                {name: "עדכון אחרון", class: "table__column table__column_width-100 table__column_left", element: "date", function: null}];

  if(isLogin) tablesColumnsHeaders.push({name: "", class: "table__column table__column_width-100 table__column_left", element: "span", function: null});

  const tablesColumnsStyles = [{name: "tableName", class: "table__column table__column_width-150", element: "span", elementClass: "table__element", function: null},
                               {name: "type", class: "table__column table__column_width-100", element: "span", elementClass: "table__element", function: null},
                               {name: "lastUpdate", class: "table__column table__column_width-100 table__column_left", element: "date", elementClass: "table__element", function: null}];

  if(isLogin) tablesColumnsStyles.push({name: "button", class: "table__column table__column_width-100 table__column_center", element: "button", elementClass: "table__button", function: onTablesUpdateClick});

  {
   return (
      <div className="app">
        
        <Error isOpen={isErrorOpen}
               setIsOpen={setIsErrorOpen}
               errorMessage={errorMessage}
               onClose={setIsErrorOpen}>
        </Error>

        <Loader isLoading={isLoading} errorMessage={errorMessage}></Loader>
        <Login  isOpen={isLoginOpen}
                setIsOpen={setIsLoginOpen}
                isLogin={isLogin}
                onClose={onLoginClick}
                getUserInfo={getUserInfo}
        >    
        </Login>
        
        {/*<Login isLogin={isLogin}
               isOpen={isLoginOpen}
               setIsLoginOpen={setIsLoginOpen}
               onClose={onLoginClick}
               getUserInfo={getUserInfo}
               >
        </Login>*/}
        <Main isLoginOpen={isLoginOpen}
              isLogin={isLogin}
              setIsLogin={setIsLogin}
              onLoginClick={onLoginClick}
              firstName={firstName}
              navigateTo={navigateTo}
              tablesColumnsHeaders={tablesColumnsHeaders}
              tablesColumnsStyles={tablesColumnsStyles}
              tablesRecords={tables} //compare
              tablesPageSize={100}
              tablesPageIndex={1}
              tablesList={tablesList}  // this two parameters
              onTableNameChange={onTableNameChange}
              pageName={pageName}
              //setNavigation={setNavigation}
              setPageName={onSetPageName}
              translateTableTypeCode={selectedTableTypeCode}
              //onTranslateTableTypeCodeChange={onTableTypeCodeChange}
              translateColumnsHeaders={translateColumnsHeaders}
              translateColumnsStyles={columnsStyles}
              translateRecords={translates}
              translateFilters={filters}
              translatePageSize={translatePageSize}
              translatePageIndex={translatePageIndex}
              translateTotalCount={translateTotalCount}
              onTranslatePageIndexChange={onTranslatePageIndexChange}
              onTranslateUpdateClick={onTranslateUpdateClick}
              selectedTable={selectedTable}
              getTableName={getTableName}
              onCategoryChange={onCategoryChange}
              getCategoryLabelByCode={getCategoryLabelByCode}
              statusCode={selectedStatusCode}
              onStatusChange={onStatusChange}
              getStatusByCode={getStatusByCode}
              renderTranslates={renderTranslates}
              >
        </Main>
      </div>
    )
  }
}

export default App;
