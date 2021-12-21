import React, { useEffect } from "react";
import { useState } from "react/cjs/react.development";
import "../styles/output.css";
import NavigationLeftLogo from "./NavigationLeftLogo";
import NavigationHamburgerButton from "./NavigationHamburgerButton";
import NavigationMobileView from "./NavigationMobileView";
import NavigationView from "./NavigationView";

function Navigation() {
  const [isMobileViewOpen, setMobileViewOpen] = useState(false);
  const [currentSelection, setCurrentSelection] = useState([
    true,
    false,
    false,
    false,
  ]);

  const toggleMobileMenu = () => {
    setMobileViewOpen(!isMobileViewOpen);
  };

  const setCurrentSelectionCallback = (positionClicked) => {
    const temp = [false, false, false, false];
    temp[positionClicked] = true;
    setCurrentSelection(temp);
  };

  useEffect(() => {
    window.addEventListener("resize", () => {
      setMobileViewOpen(false);
    });
    return () =>
      window.removeEventListener("resize", () => {
        setMobileViewOpen(false);
      });
  }, []);

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
          <NavigationView
            handleClick={setCurrentSelectionCallback}
            highlight={currentSelection}
          />
          <NavigationHamburgerButton handleClick={toggleMobileMenu} />
        </div>
        <NavigationMobileView
          isMobileViewOpen={isMobileViewOpen}
          handleClick={setCurrentSelectionCallback}
          highlight={currentSelection}
        />
      </div>
    </nav>
  );
}

export default Navigation;
