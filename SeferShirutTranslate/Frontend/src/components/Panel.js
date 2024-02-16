import React from 'react';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import Autocomplete from '@mui/material/Autocomplete';
import { tablesList } from '../utils/TablesList';
import { categoryList } from '../utils/CategoryList';
import { statusList } from '../utils/StatusList';

function Panel(props)
{
    return(
    <div className="panel">

        <Autocomplete
            disablePortal={true}
            id="autocomplete-tables"
            options={tablesList}
            value={props.getTableName(props.tableName)}
            isOptionEqualToValue={(option) => {/*console.log("option1: ", option);*/ return(option.label); }}
            renderInput={(params) => <TextField {...params} label="טבלה" size='small' />}
            ListboxProps={{style: {maxHeight: 150}}}
            style={{ width: 250, marginRight: 4, marginTop: 8}}
            onChange={(event, options, reason) => props.onTableNameChange(event, options, reason)}
        />
        
        <Autocomplete
            disablePortal={true}
            id="autocomplete-category"
            //options={categoryList.map((option) => ({label: option.label, code: option.code}))}
            //options={categoryList}
            options={categoryList.map(option => (option.hebrewLabel))}
            //value={getCategoryLabelByCode(props.tableTypeCode)}
            //value={categoryList.map((option, value) => {if(option.code === props.tableTypeCode) return (option.hebrewLabel);    console.log(`(auto value) option=${option.code}, value=${value}`)                })}
            value={props.getCategoryLabelByCode(props.tableTypeCode)}
            //value={props.getTableName(props.tableName)}
            //isOptionEqualToValue={(option, value) => option.value === value.value}
            //isOptionEqualToValue={(option, value) =>  {if(option === value) console.log("value=>", value, "option =>", option); value='654'}}
            //isOptionEqualToValue={(option, value) => ({label: option.label, code: option.code})} //works
            //isOptionEqualToValue={(option) => {/*console.log("option2: ", option);*/ return(option.code + '111'); }}
            renderInput={(params) => <TextField {...params} label="קטגוריה" size='small' />}
            ListboxProps={{style: {maxHeight: 150}}}
            style={{ width: 200, marginRight: 4, marginLeft: 4, marginTop: 8, marginBottom: 8}}
            onChange={(event, option) => props.onCategoryChange(event, option)}
        />

        <Autocomplete
            disablePortal={true}
            id="autocomplete-status"
            //options={statusList}
            options={statusList.map(option => (option.hebrewLabel))}
            value={props.getStatusByCode(props.statusCode)}
            isOptionEqualToValue={(option) => {/*console.log("option1: ", option);*/ return(option.hebrewLabel); }}
            renderInput={(params) => <TextField {...params} label="סטטוס" size='small' />}
            ListboxProps={{style: {maxHeight: 150}}}
            style={{ width: 200, marginRight: 4, marginTop: 8}}
            onChange={(event, option) => props.onStatusChange(event, option)}
        />


        <Button variant="contained" style={{height: 40, marginTop: 8, marginLeft: 4, visibility: 'hidden'}}>חיפוש</Button>
        <Button variant="contained" style={{height: 40, marginTop: 8, visibility: 'hidden'}}>ניקוי</Button>
        

    </div>
    )
}

export default Panel;