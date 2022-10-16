import React from "react";
import Reminder from "../Reminder/Reminder";

const RemindersList = props => (
    <ul
        role="list"
        className="todo-list"
        aria-labelledby="list-heading"
    >
        <Reminder name="Eat" completed={true}/>
        <Reminder name="Sleep" completed={false}/>
        <Reminder name="Repeat" completed={false}/>
    </ul>
)

export default RemindersList;
