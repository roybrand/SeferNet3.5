import '../styles/Header.css';
import Header from './Header';
import '../styles/Table.css'
import Table from './Table';
import '../styles/Panel.css'
import Panel from './Panel';
import '../styles/Main.css'

import { Route, Routes, Navigate } from "react-router-dom";
import { categoryList } from '../utils/CategoryList';

function Main(props) {
    return(<div className='main'>
                <Routes>
                    <Route exact path="/" element={<Navigate to="/translate/All/0/0" />}></Route>
                    <Route exact path="/translate" element={<Navigate to="/translate/All/0/0" />}></Route>
                    <Route exact path="/tables" element={<Navigate to="/tables/All/0/0" />}></Route>
                </Routes>
                <Routes>
                    <Route path="/tables/:table/:category/:status" element={
                        <>
                            <Header onClick={props.onLoginClick}
                                    isLogin={props.isLogin}
                                    setIsLogin={props.setIsLogin}
                                    firstName={props.firstName}
                                    setPageName={props.setPageName}
                                    pageName={props.pageName}
                                    navigateTo={props.navigateTo}
                                    >
                            </Header>
                            <Panel tableName={props.selectedTable}
                                   pageName={props.pageName}
                                   onTableNameChange={props.onTableNameChange}
                                   tableTypeCode={props.translateTableTypeCode}
                                   //onTableTypeCodeChange={props.onTranslateTableTypeCodeChange}
                                   tablesList={props.tablesList}//delete
                                   categoryList={props.categoryList}//delete
                                   getCategoryLabelByCode={props.getCategoryLabelByCode}
                                   onCategoryChange={props.onCategoryChange}
                                   getTableName={props.getTableName}
                                   statusCode={props.statusCode}
                                   onStatusChange={props.onStatusChange}
                                   getStatusByCode={props.getStatusByCode}
                                   >
                            </Panel>                            
                            <Table tableName="רשימת טבלאות"
                                   //setNavigation={props.setNavigation}
                                   getTableName={props.getTableName}
                                   setTableName={props.onTranslateTableNameChange}
                                   columns={props.tablesColumnsHeaders}
                                   styles={props.tablesColumnsStyles}
                                   records={props.tablesRecords}
                                   filters={[]}
                                   pageSize={props.tablesPageSize}
                                   pageIndex={props.tablesPageIndex}
                                   totalCount={props.tablesRecords.length}>
                            </Table>
                        </>} />
                </Routes>
                <Routes>
                    <Route path="/translate/:table/:category/:status" element={
                        <>
                            <Header onClick={props.onLoginClick}
                                    isLogin={props.isLogin}
                                    setIsLogin={props.setIsLogin}
                                    //setTableName={props.onTableNameChange}
                                    firstName={props.firstName}
                                    setPageName={props.setPageName}
                                    navigateTo={props.navigateTo}
                                    >
                            </Header>
                            <Panel tableName={props.selectedTable}
                                   pageName={props.pageName}
                                   onTableNameChange={props.onTableNameChange}
                                   tableTypeCode={props.translateTableTypeCode}
                                   //onTableTypeCodeChange={props.onTranslateTableTypeCodeChange}
                                   tablesList={props.tablesList}//delete
                                   categoryList={props.categoryList}//delete
                                   getCategoryLabelByCode={props.getCategoryLabelByCode}
                                   onCategoryChange={props.onCategoryChange}
                                   getTableName={props.getTableName}
                                   statusCode={props.statusCode}
                                   onStatusChange={props.onStatusChange}
                                   getStatusByCode={props.getStatusByCode}
                                   >
                            </Panel>
                            <Table tableName={props.selectedTable}
                                   setTableName={props.onTableNameChange}
                                   columns={props.translateColumnsHeaders}
                                   styles={props.translateColumnsStyles}
                                   records={props.translateRecords}
                                   filters={props.filters}
                                   pageSize={props.translatePageSize}
                                   pageIndex={props.translatePageIndex}
                                   totalCount={props.translateTotalCount}
                                   onPageIndexChange={props.onTranslatePageIndexChange}
                                   onUpdateClick={props.onTranslateUpdateClick}
                                   renderTranslates={props.renderTranslates}
                                   getTableName={props.getTableName}
                                   //isTableHaveData={isTableHaveData}//delete
                                   >
                            </Table>
                        </>} />
                </Routes>
            </div>
          )
}

export default Main;