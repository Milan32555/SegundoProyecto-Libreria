import 'package:flutter/material.dart';

/// Menú lateral (Drawer), equivalente al menú de la ventana principal en un
/// cliente de escritorio: permite ir a cada caso de uso y tiene una sección
/// "Ayuda" con "Acerca de...".
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF3A5BD9)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Librería',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('LIBRO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _opcion(context, Icons.add, 'Adicionar', '/libros/agregar'),
          _opcion(context, Icons.delete_outline, 'Eliminar', '/libros/eliminar'),
          _opcion(context, Icons.edit_outlined, 'Actualizar', '/libros/actualizar'),
          _opcion(context, Icons.list_alt, 'Listar', '/libros/listar'),
          _opcion(context, Icons.search, 'Buscar por criterios', '/libros/consultar'),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text('EJEMPLAR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _opcion(context, Icons.add, 'Adicionar', '/ejemplares/agregar'),
          _opcion(context, Icons.delete_outline, 'Eliminar', '/ejemplares/eliminar'),
          _opcion(context, Icons.edit_outlined, 'Actualizar', '/ejemplares/actualizar'),
          _opcion(context, Icons.list_alt, 'Listar', '/ejemplares/listar'),
          _opcion(context, Icons.search, 'Buscar por criterios', '/ejemplares/consultar'),
          const Divider(),
          _opcion(context, Icons.help_outline, 'Acerca de...', '/acerca-de'),
        ],
      ),
    );
  }

  Widget _opcion(BuildContext context, IconData icono, String titulo, String ruta) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      onTap: () {
        Navigator.pop(context); // cierra el Drawer
        Navigator.pushNamed(context, ruta);
      },
    );
  }
}
