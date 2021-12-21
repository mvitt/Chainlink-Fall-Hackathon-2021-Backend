import React from "react";
import PropTypes from "prop-types";
import NavigationMobileItem from "./NavigationMobileItem";

function NavigationMobileView(props) {
  return (
    <div
      className={props.isMobileViewOpen ? "mobile-menu" : "hidden mobile-menu"}
    >
      <NavigationMobileItem
        itemText="Home"
        itemLink="#home"
        isActive={props.highlight[0]}
        position={0}
        handleClick={props.handleClick}
      />
      <NavigationMobileItem
        itemText="Place Bet"
        itemLink="#home"
        isActive={props.highlight[1]}
        position={1}
        handleClick={props.handleClick}
      />
      <NavigationMobileItem
        itemText="About"
        itemLink="#home"
        isActive={props.highlight[2]}
        position={2}
        handleClick={props.handleClick}
      />
      <NavigationMobileItem
        itemText="Contact Us"
        itemLink="#home"
        isActive={props.highlight[3]}
        position={3}
        handleClick={props.handleClick}
      />
    </div>
  );
}
NavigationMobileView.propTypes = {
  isMobileViewOpen: PropTypes.bool,
  handleClick: PropTypes.func,
  highlight: PropTypes.array,
};

export default NavigationMobileView;
