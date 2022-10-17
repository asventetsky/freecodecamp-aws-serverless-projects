import React, {Component} from "react";
import ReminderForm from "../../components/ReminderForm/ReminderForm";
import ReminderFilters from "../../components/ReminderFilters/ReminderFilters";
import RemindersList from "../../components/ReminderList/RemindersList";
import classes from "./ReminderApp.module.css"

class ReminderApp extends Component {
    state = {
        reminders: [
            {
                "id": 1,
                "message": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                "triggerDatetime": "2022-10-20T10:15:00",
                "email": "test@gmail.com",
                "notificationType": "email"
            },
            {
                "id": 2,
                "message": "Suspendisse mattis placerat suscipit.",
                "triggerDatetime": "2022-10-25T15:20:00",
                "email": "test@gmail.com",
                "notificationType": "email"
            },
            {
                "id": 3,
                "message": "Praesent varius, mauris at sodales aliquam, lorem lectus eleifend enim, vitae blandit turpis purus et leo.",
                "triggerDatetime": "2022-10-30T20:25:00",
                "email": "test@gmail.com",
                "notificationType": "email"
            },
            {
                "id": 4,
                "message": "Praesent varius, mauris at sodales aliquam, lorem lectus eleifend enim, vitae blandit turpis purus et leo.",
                "triggerDatetime": "2022-10-31T20:30:00",
                "email": "test@gmail.com",
                "notificationType": "email"
            }
        ]
    }

    render() {
        return(
            <div className={classes.ReminderApp}>
                <h1>Reminder App</h1>
                <ReminderForm/>
                <ReminderFilters/>
                <RemindersList reminders={this.state.reminders}/>
            </div>
        )
    }
}

export default ReminderApp;
