import React from "react";
//import Login from "./Login-old";
//import { useParams } from 'react-router';
//import { useNavigate, useLocation } from "react-router-dom";
//import { tab } from "@testing-library/user-event/dist/tab";
import { motion } from "framer-motion";

function Table(props) {

    //const { table, category } = useParams();

    //const navigate = useNavigate();

    //const location = useLocation();
    //const [pageIndex, setPageIndex] = React.useState(1);

    function getFormattedDate(date) {

        //console.log("getFormattedDate: ", date)

        return date.substring(0, 16).replace('T', ' ');
    }

    function getIndexes() {

        const indexes = [];
        let count = 1;

        for(let index = 0; index < props.totalCount; index += props.pageSize) {
            indexes.push(count++)
        }

        return(<select className="table__page-index" onChange={(event) =>  props.onPageIndexChange(event.target.value)}>
        {
            indexes.map(index => <option value={index}>{index}</option>)
        }
        </select> 
        )
    }
    
    return (
    <motion.div className="table"
                initial= {{
                    opacity: 0,
                    
                }}
                animate={{
                    opacity: 1,
                    
                }}>
        <div className="table__name">טבלה: {props.getTableName(props.tableName)} ({props.totalCount} רשומות)</div>
        <div className="table__pagging">עמוד: { getIndexes() } גודל עמוד: {<input className="table__page-size" value={props.pageSize}></input>}</div>
        { console.log("(Tables) records.length", props.records) }
        <div className="table__body">
        {
            <div key={0} id={0} className="table__row-header">
                {
                    props.columns.map((column) => {
                        return(<div className={column.class}>{column.name}</div>)
                    })
                }
            </div>
        }
        {
            props.records.map((rowItem, rowIndex) => {

                //get tabble count fro paging

                //If the filter is in the client - this line is the filter:
                //if(((rowIndex + 1) < (props.pageIndex * props.pageSize + 1 - props.pageSize)) || (rowIndex + 1 > (props.pageIndex * props.pageSize + 1))) return;

                let columns = [...props.styles];
                return (
                    <div key={`${rowItem["id"]}`} id={`${rowItem["id"]}`} className="table__row">
                    {
                        columns.map((columnItem, columnIndex) => {
                            switch(props.styles[columnIndex].element)
                            {
                                case "span":
                                    return(<div className={props.styles[columnIndex].class}><span className={props.styles[columnIndex].elementClass}>{rowItem[columnItem.name]}</span></div>)

                                case "input":
                                    return(<div className={props.styles[columnIndex].class}><input className={columnItem.elementClass} type="text" value={rowItem.translate} onChange={(event) => columnItem.function(event, rowIndex)}/></div>)

                                case "button":
                                    return(<div className={props.styles[columnIndex].class}><button className={columnItem.elementClass} value={props.translate} onClick={() => columnItem.function(rowItem)}>עדכן</button></div>)
                                    
                                case "date":
                                    return(<div className={props.styles[columnIndex].class}><span className={props.styles[columnIndex].elementClass}>{getFormattedDate(rowItem[columnItem.name])}</span></div>)
                            }
                        })
                    }
                    </div>
                )
            })
        }
        </div>
    </motion.div>
    )
}
export default Table;
