import React, {useEffect, useState} from "react";
import ReminderForm from "../../components/ReminderForm/ReminderForm";
import ReminderFilters from "../../components/ReminderFilters/ReminderFilters";
import RemindersList from "../../components/ReminderList/RemindersList";
import classes from "./ReminderApp.module.css"
import axios from "axios";

export default function ReminderApp() {

    const serverUrl = process.env.REACT_APP_SERVER_URL
    const [reminders, setReminders] = useState([]);

    useEffect(() => {
        let reminders = []
        axios.get(`${serverUrl}/reminders?email=artyom.sven@gmail.com`)
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
            "userId": "artyom.sven@gmail.com",
            "triggerDatetime": datetime,
            "notificationType": "email",
            "message": message
        };
        console.log(newReminder)
        axios.post(`${serverUrl}/reminder`, newReminder)
            .then(response =>
                newReminder.id = response.data.id
            )
            .catch(error => console.log(error));
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
