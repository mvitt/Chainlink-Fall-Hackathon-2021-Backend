import React from "react";
import LoginButton from "./LoginButton";
import MetaMaskNeeded from "./MetaMaskNeeded";

function App() {
  if (typeof window.ethereum !== "undefined") {
    return (
      <div>
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
