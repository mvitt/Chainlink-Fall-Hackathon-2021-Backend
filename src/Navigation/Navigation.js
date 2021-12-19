import React from "react";
import { useState } from "react/cjs/react.development";
import "../styles/output.css";
import NavigationItem from "./NavigationItem";
import NavigationMobileItem from "./NavigationMobileItem";
import NavigationLeftLogo from "./NavigationLeftLogo";

function Navigation() {
  const [isMobileViewOpen, setMobileViewOpen] = useState(false);

  const toggleMobileMenu = () => {
    setMobileViewOpen(!isMobileViewOpen);
  };

  return (
    <nav className="bg-white shadow-lg">
      <div className="max-w-6xl mx-auto px-4">
        <div className="flex justify-between">
          <NavigationLeftLogo
            itemText="Weather-Bet"
            itemLink="#home"
            imageLink="https://www.feirox.com/rivu/2016/04/Klara-1.png"
            imageAlt="Logo"
          />

          <div className="hidden md:flex items-center space-x-1">
            <NavigationItem itemText="Home" itemLink="#test" isActive={true} />
            <NavigationItem
              itemText="Services"
              itemLink="#test"
              isActive={false}
            />
            <NavigationItem
              itemText="About"
              itemLink="#test"
              isActive={false}
            />
            <NavigationItem
              itemText="Contact Us"
              itemLink="#test"
              isActive={false}
            />
          </div>
          <div
            className="md:hidden flex items-center"
            onClick={toggleMobileMenu}
          >
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
        </div>
        <div
          className={isMobileViewOpen ? "mobile-menu" : "hidden mobile-menu"}
        >
          <NavigationMobileItem
            itemText="Home"
            itemLink="#home"
            isActive={true}
          />
          <NavigationMobileItem
            itemText="Services"
            itemLink="#home"
            isActive={false}
          />
          <NavigationMobileItem
            itemText="About"
            itemLink="#home"
            isActive={false}
          />
          <NavigationMobileItem
            itemText="Contact Us"
            itemLink="#home"
            isActive={false}
          />
        </div>
      </div>
    </nav>
  );
}

export default Navigation;
