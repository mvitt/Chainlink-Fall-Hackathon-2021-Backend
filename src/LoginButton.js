import React, { useEffect, useState } from "react";
import "./styles/output.css";

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
    <>
      <button
        className="flex items-center px-3 py-2 border rounded text-gray-500 border-gray-600 hover:text-gray-800 hover:border-teal-500 appearance-none focus:outline-none"
        onClick={isLoggedIn ? showDisconnectInstructions : connectToMetaMask}
      >
        {isLoggedIn ? "Log Out" : "Log In"}
      </button>
    </>
  );
}

export default LoginButton;
