import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import App from "./App";

// Fuentes incluidas en el proyecto (SIL Open Font License): la demo funciona sin internet.
// IBM Plex Sans para la interfaz y Literata para los títulos de libros y el logotipo.
import "@fontsource/ibm-plex-sans/latin-400.css";
import "@fontsource/ibm-plex-sans/latin-500.css";
import "@fontsource/ibm-plex-sans/latin-600.css";
import "@fontsource/literata/latin-500.css";
import "@fontsource/literata/latin-600.css";

import "./estilos/tokens.css";
import "./estilos/app.css";

// Elemento raiz el cual REACT va a usar para crear toda la interfaz
ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
);
