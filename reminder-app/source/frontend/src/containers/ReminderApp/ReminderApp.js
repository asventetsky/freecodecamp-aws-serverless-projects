import React, {Component} from "react";
import ReminderForm from "../../components/ReminderForm/ReminderForm";
import ReminderFilters from "../../components/ReminderFilters/ReminderFilters";
import RemindersList from "../../components/ReminderList/RemindersList";
import classes from "./ReminderApp.module.css"

class ReminderApp extends Component {
    state = {
        reminders: []
    }

    render() {
        return(
            <div className={classes.ReminderApp}>
                <h1>TodoMatic</h1>
                <ReminderForm/>
                <ReminderFilters/>
                <h2 id="list-heading">
                    3 tasks remaining
                </h2>
                <RemindersList/>
            </div>
        )
    }
}

export default ReminderApp;
