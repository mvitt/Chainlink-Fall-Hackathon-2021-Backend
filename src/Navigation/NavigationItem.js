import React from "react";
import PropTypes from "prop-types";

function NavigationItem(props) {
  return (
    <a
      href={props.itemLink}
      className={
        props.isActive
          ? "py-4 px-2 text-gray-500 border-b-4 border-orange-400 font-semibold"
          : "py-4 px-2 text-gray-500 hover:text-orange-400 font-semibold"
      }
      onClick={() => props.handleClick(props.position)}
    >
      {props.itemText}
    </a>
  );
}
NavigationItem.propTypes = {
  itemText: PropTypes.string,
  itemLink: PropTypes.string,
  isActive: PropTypes.bool,
  position: PropTypes.number,
  handleClick: PropTypes.func,
};

export default NavigationItem;
