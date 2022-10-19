import React, {useState} from "react";
import {nanoid} from "nanoid";
import ReminderForm from "../../components/ReminderForm/ReminderForm";
import ReminderFilters from "../../components/ReminderFilters/ReminderFilters";
import RemindersList from "../../components/ReminderList/RemindersList";
import classes from "./ReminderApp.module.css"

export default function ReminderApp() {

    const [reminders, setReminders] = useState(
        [
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
            }
        ]
    );

    function addReminder(message, datetime) {
        const newReminder = {
            id: nanoid(),
            message,
            triggerDatetime: datetime,
            email: "test@gmail.com",
            notificationType: "email"
        };
        setReminders([...reminders, newReminder]);
    }

        return(
            <div className={classes.ReminderApp}>
                <h1>Reminder App</h1>
                <ReminderForm onAddReminder={addReminder}/>
                <ReminderFilters/>
                <RemindersList reminders={reminders}/>
            </div>
        )
}
