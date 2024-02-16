import { settings } from "./Settings";

class Api {
    constructor({ baseUrl }) {
      this._baseUrl = baseUrl;
    }

    GetTabels() {

      //console.log("base url: ", `${this._baseUrl}/DictionaryTranslate/GetTables`)

      return fetch(`${this._baseUrl}/DictionaryTranslate/GetTables`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          //"Access-Control-Allow-Origin": 'https://localhost:7151/',
          //'Access-Control-Allow-Origin': '*',
          //Accept: "applicaiton/json",
        //"Content-Type": "application/json"
        }
      });//.then((response) => console.log(response.json()));
    }

    async CheckToken(token) {

      console.log("CheckToken. token =>", token);

      return await fetch(`${this._baseUrl}/DictionaryTranslate/CheckToken`, {
        //method: "GET",
        method: "POST",
        //mode: "no-cors",
        headers: {
          "Content-Type": "application/json",
          //"Access-Control-Allow-Origin": 'https://localhost:7151/',
          //'Access-Control-Allow-Origin': '*',
          //'Access-Control-Allow-Headers': 'Content-Type',
          //'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
          //'Access-Control-Allow-Methods': 'GET, POST, PUT'
          //Accept: "applicaiton/json",
        //"Content-Type": "application/json"
        },
        body: JSON.stringify({
          token: token
        })
      });//.then((response) => console.log(response.json()));
    }

    GetTranslates(tableName, tableTypeCode, statusCode, pageIndex, pageSize) {

      return fetch(`${this._baseUrl}/DictionaryTranslate/GetTranslates`, {
        //method: "GET",
        method: "POST",
        //mode: "no-cors",
        headers: {
          "Content-Type": "application/json",
          //"Access-Control-Allow-Origin": 'https://localhost:7151/',
          //'Access-Control-Allow-Origin': '*',
          //'Access-Control-Allow-Headers': 'Content-Type',
          //'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept',
          //'Access-Control-Allow-Methods': 'GET, POST, PUT'
          //Accept: "applicaiton/json",
        //"Content-Type": "application/json"
        },
        body: JSON.stringify({
          tableName: tableName,
          tableTypeCode: tableTypeCode,
          statusCode, statusCode,
          pageIndex: pageIndex,
          pageSize: pageSize
        })
      });//.then((response) => console.log(response.json()));
    }

    UpdateTranslate(row) {

      //console.log("(api) table name", row.tableName)
      //console.log("(api) table code", row.tableCode)
      //console.log("(api) table translate", row.translate)

      return fetch(`${this._baseUrl}/DictionaryTranslate/SetTranslate`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
          //"Access-Control-Allow-Origin": 'https://localhost:7151/',
        },
        //headers: this.getHeader(token),
        body: JSON.stringify({
          table: row.tableName,
          code: row.tableCode,
          translate: row.translate,
          timestamp: row.timestamp
        })
      });//.then((response) => this._checkResponse(response));
    }

    GetUserInfo({domain, username, password}) {
      //console.log(domain, username);
      
      //console.log("api url: ", `${this._baseUrl}/api/Login/Login`)

      return fetch(`${this._baseUrl}/Login/Login`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          //"Access-Control-Allow-Origin": 'https://localhost:7151/',
          //'Access-Control-Allow-Origin': '*',
          //Accept: "applicaiton/json",
        //"Content-Type": "application/json"
        },
        body: JSON.stringify({
          domain: domain,
          username: username,
          password: password
        })
      });
    }

    GetTimestampChanges() {
      return fetch(`${this._baseUrl}/DictionaryTranslate/GetTimestampChanges`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          //"mode": "no-cors",
          //"Access-Control-Allow-Origin": 'https://localhost:7151/',
          'Access-Control-Allow-Origin': '*',
          'Accept': 'applicaiton/json',
        //"Content-Type": "application/json"
        }
      });//.then((response) => console.log(response.json()));
    }

    SendEmail(functionName, exception) {
      return fetch(`${this._baseUrl}/DictionaryTranslate/SendEmail`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
          //"Access-Control-Allow-Origin": 'https://localhost:7151/',
        },
        //headers: this.getHeader(token),
        body: JSON.stringify({
          function: functionName,
          exception: exception
        })
      });
    }
  }

//export const api = new Api();

export const api = new Api({
  //baseUrl: "https://around.nomoreparties.co/v1/cohort-3-en",
  //baseUrl: "https://localhost:7151/api",
  //baseUrl: "https://sefernettest.clalit.org.il:4433/SeferNetCore/api"
  baseUrl: settings.baseUrl
});