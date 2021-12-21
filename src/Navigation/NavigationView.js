import React from "react";
import PropTypes from "prop-types";
import NavigationItem from "./NavigationItem";

function NavigationView(props) {
  return (
    <div className="hidden md:flex items-center space-x-1">
      <NavigationItem
        itemText="Home"
        itemLink="#test"
        isActive={props.highlight[0]}
        position={0}
        handleClick={props.handleClick}
      />
      <NavigationItem
        itemText="Place Bet"
        itemLink="#test"
        isActive={props.highlight[1]}
        position={1}
        handleClick={props.handleClick}
      />
      <NavigationItem
        itemText="About"
        itemLink="#test"
        isActive={props.highlight[2]}
        position={2}
        handleClick={props.handleClick}
      />
      <NavigationItem
        itemText="Contact Us"
        itemLink="#test"
        isActive={props.highlight[3]}
        position={3}
        handleClick={props.handleClick}
      />
    </div>
  );
}

NavigationView.propTypes = {
  handleClick: PropTypes.func,
  highlight: PropTypes.array,
};

export default NavigationView;
