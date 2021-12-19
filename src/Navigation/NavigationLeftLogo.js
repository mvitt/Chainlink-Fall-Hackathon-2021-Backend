import React from "react";
import PropTypes from "prop-types";

function NavigationLeftLogo(props) {
  return (
    <div className="flex space-x-7">
      <a href={props.itemLink} className="flex items-center py-4 px-2">
        <img
          src={props.imageLink}
          alt={props.imageAlt}
          className="h-8 w-8 mr-2"
        />
        <span className="font-semibold text-gray-500 text-lg">
          {props.itemText}
        </span>
      </a>
    </div>
  );
}
NavigationLeftLogo.propTypes = {
  itemText: PropTypes.string,
  itemLink: PropTypes.string,
  imageLink: PropTypes.string,
  imageAlt: PropTypes.string,
};

export default NavigationLeftLogo;
