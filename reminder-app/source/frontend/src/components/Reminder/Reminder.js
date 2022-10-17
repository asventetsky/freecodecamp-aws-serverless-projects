import React from "react";
import classes from "./Reminder.module.css"

const Reminder = props => (
    <li className={classes.reminder}>
        <div className={classes.message}>
            {props.message}
        </div>
        <div className={classes.triggerDate}>
            {props.triggerDatetime}
        </div>
    </li>
)

export default Reminder;