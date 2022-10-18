import React, {Component} from "react";
import classes from './FilterButton.module.css'

class FilterButton extends Component {

    render() {

        const cls = [classes.button]

        if (this.props.pressed) {
            cls.push(classes.pressed)
        }

        return (
            <button type="button" className={cls.join(' ')}>
                {this.props.text}
            </button>
        )
    }
}

export default FilterButton;
