import React from "react";
import FilterButton from "../FilterButton/FilterButton";
import classes from "./ReminderFilters.module.css"

const RemindersFilters = props => (
    <div className={classes.ReminderFilters}>
        <FilterButton text="All"/>
        <FilterButton text="Active"/>
        <FilterButton text="Completed"/>
    </div>
)

export default RemindersFilters;
