import React from "react";
import classes from "./ReminderForm.module.css"

const ReminderForm = props => (
    <div className={classes.form}>
        <form>
            <h2 className="label-wrapper">
                What needs to be notified?
            </h2>
            <ul className={classes.wrapper}>
                <li className={classes.formRow}>
                    <label htmlFor="message">Message</label>
                    <input type="text" id="message"/>
                </li>
                <li className={classes.formRow}>
                    <label htmlFor="datetime">Datetime</label>
                    <input type="text" id="datetime"/>
                </li>
                <li className={classes.formRow}>
                    <button type="submit">Add</button>
                </li>
            </ul>
        </form>
    </div>
)

export default ReminderForm;