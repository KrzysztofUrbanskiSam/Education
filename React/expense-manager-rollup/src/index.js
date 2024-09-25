import React from 'react';
import ReactDOM from 'react-dom';
import HelloWorld from './components/HelloWorld';
import ExpenseEntryItem from './components/ExpenseEntryItem'

const item = {
   id: 1,
   name : "Grape Juice",
   amount : 30.5,
   spendDate: new Date("2020-10-10"),
   category: "Food"
}

var cTime = new Date().toTimeString();
console.log("Entering index.js ", cTime)
ReactDOM.render(
   <React.StrictMode>
      <HelloWorld id="metrics"/>
      <ExpenseEntryItem item={item} />
   </React.StrictMode>,
   document.getElementById('root')
);

var cTime = new Date().toTimeString();
console.log("Exiting index.js", cT)
