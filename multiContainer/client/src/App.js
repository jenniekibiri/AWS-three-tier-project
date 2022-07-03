import React, { useEffect, useState } from "react";

import "../node_modules/bootstrap/dist/css/bootstrap.min.css";
import "./App.css";

function App() {
  const [players, setPlayers] = useState([]);

  useEffect(() => {
    fetchPlayers();
  }, []);

  const fetchPlayers = async () => {
    //from aws loadbalancer

    const data = await fetch(
      "http://dev-shecodes-external-lb-1840956510.us-east-1.elb.amazonaws.com/api/users"
    );

    const response = await data.json();
    console.log(response);
    setPlayers(response);
  };

  console.log(players);
  return (
    <div className="main">
      <h1>people</h1>
   <p>sanity</p>
      
      <div className="row">
        {players.map((player) => (
          <div className="card">
            <h1>people</h1>
            <img src={player.image} className="card-img-top image" alt="..." />
            <div className="card-body">
              <h5 className="card-title">{player.name}</h5>
              <p className="card-text">{player.description}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
