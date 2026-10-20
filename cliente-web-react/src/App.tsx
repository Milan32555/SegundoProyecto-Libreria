import { Route, Routes } from "react-router-dom";
import Estructura from "./componentes/Estructura";
import { ProveedorAvisos } from "./componentes/ui/Avisos";
import { ProveedorAyudas } from "./componentes/ui/Ayuda";
import MenuPrincipal from "./paginas/MenuPrincipal";
import AcercaDe from "./paginas/AcercaDe";

import AgregarLibro from "./paginas/libro/AgregarLibro";
import ActualizarLibro from "./paginas/libro/ActualizarLibro";
import EliminarLibro from "./paginas/libro/EliminarLibro";
import ListarLibros from "./paginas/libro/ListarLibros";
import ConsultarLibro from "./paginas/libro/ConsultarLibro";

import AgregarEjemplar from "./paginas/ejemplar/AgregarEjemplar";
import ActualizarEjemplar from "./paginas/ejemplar/ActualizarEjemplar";
import EliminarEjemplar from "./paginas/ejemplar/EliminarEjemplar";
import ListarEjemplares from "./paginas/ejemplar/ListarEjemplares";
import ConsultarEjemplar from "./paginas/ejemplar/ConsultarEjemplar";

/** Una ruta (pantalla) por caso de uso. */
export default function App() {
  return (
    <ProveedorAyudas delayDuration={300}>
      <ProveedorAvisos>
        <Estructura>
          <Routes>
            <Route path="/" element={<MenuPrincipal />} />

            <Route path="/libros/listar" element={<ListarLibros />} />
            <Route path="/libros/consultar" element={<ConsultarLibro />} />
            <Route path="/libros/agregar" element={<AgregarLibro />} />
            <Route path="/libros/actualizar" element={<ActualizarLibro />} />
            <Route path="/libros/eliminar" element={<EliminarLibro />} />

            <Route path="/ejemplares/listar" element={<ListarEjemplares />} />
            <Route path="/ejemplares/consultar" element={<ConsultarEjemplar />} />
            <Route path="/ejemplares/agregar" element={<AgregarEjemplar />} />
            <Route path="/ejemplares/actualizar" element={<ActualizarEjemplar />} />
            <Route path="/ejemplares/eliminar" element={<EliminarEjemplar />} />

            <Route path="/acerca-de" element={<AcercaDe />} />
          </Routes>
        </Estructura>
      </ProveedorAvisos>
    </ProveedorAyudas>
  );
}
