import React from "react";
import FilterButton from "../FilterButton/FilterButton";
import classes from "./ReminderFilters.module.css"

const RemindersFilters = props => (
    <div className={classes.ReminderFilters}>
        <FilterButton text="All" pressed={true}/>
        <FilterButton text="Active" pressed={false}/>
        <FilterButton text="Completed" pressed={false}/>
    </div>
)

export default RemindersFilters;
