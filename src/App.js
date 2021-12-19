import React from "react";
import LoginButton from "./LoginButton";
import MetaMaskNeeded from "./MetaMaskNeeded";
import Navigation from "./Navigation/Navigation";

function App() {
  if (typeof window.ethereum !== "undefined") {
    return (
      <div>
        <Navigation />
        <LoginButton />
      </div>
    );
  } else {
    return (
      <div>
        <MetaMaskNeeded />
      </div>
    );
  }
}

export default App;
