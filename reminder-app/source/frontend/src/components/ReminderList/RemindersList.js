import React from "react";
import Reminder from "../Reminder/Reminder";

const RemindersList = props => (
    <div>
        <h2 id="list-heading">
            {props.reminders.length} reminders remaining
        </h2>
        <ul
            role="list"
            className="todo-list"
            aria-labelledby="list-heading"
        >
            {
                props.reminders.map((reminder) =>
                    <Reminder
                        key={reminder.id}
                        triggerDatetime={reminder.triggerDatetime}
                        message={reminder.message}
                    />
                )
            }
        </ul>
    </div>
)

export default RemindersList;
