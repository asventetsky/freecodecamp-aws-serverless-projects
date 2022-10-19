import React, {useState} from "react";
import classes from "./ReminderForm.module.css"

export default function ReminderForm(props) {

    const [message, setMessage] = useState("")
    const [datetime, setDatetime] = useState("")

    function handleSubmit(e) {
        e.preventDefault();
        props.onAddReminder(message, datetime);
        setMessage("");
        setDatetime("");
    }

    function handleMessageChange(e) {
        setMessage(e.target.value);
    }

    function handleDatetimeChange(e) {
        setDatetime(e.target.value);
    }

    return (
        <div className={classes.form}>
            <form onSubmit={handleSubmit}>
                <h2 className="label-wrapper">
                    What needs to be notified?
                </h2>
                <ul>
                    <li className={classes.formRow}>
                        <label htmlFor="message">Message</label>
                        <input type="text" id="message" onChange={handleMessageChange}/>
                    </li>
                    <li className={classes.formRow}>
                        <label htmlFor="datetime">Datetime</label>
                        <input type="text" id="datetime" onChange={handleDatetimeChange}/>
                    </li>
                    <li className={classes.formRow}>
                        <button type="submit">Add</button>
                    </li>
                </ul>
            </form>
        </div>
        )
}

