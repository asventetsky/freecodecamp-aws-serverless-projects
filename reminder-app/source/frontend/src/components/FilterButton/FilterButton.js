import React from "react";
import classes from './FilterButton.module.css'

const FilterButton = props => (
    <button type="button" className={classes.FilterButton} aria-pressed="true">
        {props.text}
    </button>
)

export default FilterButton;
