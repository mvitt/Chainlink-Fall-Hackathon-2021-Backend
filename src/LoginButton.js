import React, { useEffect, useState } from "react";
import "./LoginButton.css";

let currentAccount = null;

function LoginButton() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    isConnectedToMetaMask();
  });

  function getAccount(accounts) {
    if (accounts.length === 0) {
      console.log("Please connect to MetaMask");
      setIsLoggedIn(false);
    } else if (currentAccount !== accounts[0]) {
      currentAccount = accounts[0];
      setIsLoggedIn(true);
    }
  }

  const isConnectedToMetaMask = async (e) => {
    window.ethereum.on("accountsChanged", getAccount);
  };

  const connectToMetaMask = async (e) => {
    window.ethereum
      .request({ method: "eth_requestAccounts" })
      .then(getAccount)
      .catch((err) => {
        if (err.code === 4001) {
          console.log("Please connect to MetaMask");
        }
      });
  };

  const showDisconnectInstructions = () => {
    console.log(
      "To log out please click on the MetaMask icon and hit the disconnect button!"
    );
  };

  return (
    <button
      onClick={isLoggedIn ? showDisconnectInstructions : connectToMetaMask}
    >
      {isLoggedIn ? "Log Out" : "Log In"}
    </button>
  );
}

export default LoginButton;
