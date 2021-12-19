import React from "react";
import PropTypes from "prop-types";

function NavigationMobileItem(props) {
  return (
    <div>
      <a
        href={props.itemLink}
        className={
          props.isActive
            ? "block text-sm px-2 py-4 hover:text-white bg-orange-400 font-semibold transition duration-300"
            : "block text-sm px-2 py-4 hover:text-white hover:bg-orange-400 font-semibold transition duration-300"
        }
      >
        {props.itemText}
      </a>
    </div>
  );
}
NavigationMobileItem.propTypes = {
  itemText: PropTypes.string,
  itemLink: PropTypes.string,
  isActive: PropTypes.bool,
};

export default NavigationMobileItem;
