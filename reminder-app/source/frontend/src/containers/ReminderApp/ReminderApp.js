import React, {useEffect, useState} from "react";
import {nanoid} from "nanoid";
import ReminderForm from "../../components/ReminderForm/ReminderForm";
import ReminderFilters from "../../components/ReminderFilters/ReminderFilters";
import RemindersList from "../../components/ReminderList/RemindersList";
import classes from "./ReminderApp.module.css"
import axios from "axios";

export default function ReminderApp() {

    const [reminders, setReminders] = useState([]);

    useEffect(() => {
        let reminders = []
        axios.get(
            "https:///mk5tkka5ee.execute-api.eu-central-1.amazonaws.com/dev/reminders?email=artyom.sven@gmail.com"
        )
            .then(response => {
                    response.data.forEach(reminder =>
                        reminders.push(
                            {
                                id: reminder.id,
                                message: reminder.message,
                                triggerDatetime: reminder.trigger_datetime,
                                email: reminder.user_id,
                                notificationType: reminder.notification_type
                            }
                        )
                    );
                    setReminders(reminders);
            })
            .catch(error => console.log(error))
    }, [])

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
