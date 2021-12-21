import React from "react";
import PropTypes from "prop-types";

function NavigationHamburgerButton(props) {
  return (
    <div className="md:hidden flex items-center" onClick={props.handleClick}>
      <button className="outline-none menu-button">
        <svg
          className="w-6 h-6 text-gray-500"
          x-show="! showMenu"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
          viewBox="0 00 24 24"
          stroke="currentColor"
        >
          <path d="m4 6h16M4 12h16M4 18h16"></path>
        </svg>
      </button>
    </div>
  );
}
NavigationHamburgerButton.propTypes = {
  handleClick: PropTypes.func,
};

export default NavigationHamburgerButton;
