import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/datasources/almacen_api.dart';
import 'data/repositories/almacen_repository_impl.dart';
import 'domain/usecases/actualizar_bien_usecase.dart';
import 'domain/usecases/cambiar_estado_bien_usecase.dart';
import 'domain/usecases/crear_bien_usecase.dart';
import 'domain/usecases/crear_responsable_usecase.dart';
import 'domain/usecases/eliminar_bien_usecase.dart';
import 'domain/usecases/obtener_bienes_usecase.dart';
import 'domain/usecases/obtener_entregas_usecase.dart';
import 'domain/usecases/obtener_responsables_usecase.dart';
import 'domain/usecases/registrar_devolucion_usecase.dart';
import 'domain/usecases/registrar_entrega_usecase.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/viewmodels/almacen_viewmodel.dart';
import 'presentation/views/bienes_view.dart';
import 'presentation/views/detalle_bien_view.dart';
import 'presentation/views/entregas_view.dart';
import 'presentation/views/formulario_bien_view.dart';
import 'presentation/views/main_navigation_view.dart';
import 'presentation/views/responsables_view.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final api = AlmacenApi();
  final repository = AlmacenRepositoryImpl(api);

  final obtenerBienes = ObtenerBienesUseCase(repository);
  final crearBien = CrearBienUseCase(repository);
  final actualizarBien = ActualizarBienUseCase(repository);
  final cambiarEstadoBien = CambiarEstadoBienUseCase(repository);
  final eliminarBien = EliminarBienUseCase(repository);

  final obtenerResponsables = ObtenerResponsablesUseCase(repository);
  final crearResponsable = CrearResponsableUseCase(repository);

  final obtenerEntregas = ObtenerEntregasUseCase(repository);
  final registrarEntrega = RegistrarEntregaUseCase(repository);
  final registrarDevolucion = RegistrarDevolucionUseCase(repository);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AlmacenViewModel(
        obtenerBienes: obtenerBienes,
        crearBien: crearBien,
        actualizarBien: actualizarBien,
        cambiarEstadoBien: cambiarEstadoBien,
        eliminarBien: eliminarBien,
        obtenerResponsables: obtenerResponsables,
        crearResponsable: crearResponsable,
        obtenerEntregas: obtenerEntregas,
        registrarEntregaUseCase: registrarEntrega,
        registrarDevolucionUseCase: registrarDevolucion,
      )..cargarTodo(),
      child: const GuardaAlmacenApp(),
    ),
  );
}

class GuardaAlmacenApp extends StatelessWidget {
  const GuardaAlmacenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guarda de Almacén',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.inicio,
      routes: {
        AppRoutes.inicio: (_) => const MainNavigationView(),
        AppRoutes.bienes: (_) => const BienesView(),
        AppRoutes.detalleBien: (_) => const DetalleBienView(),
        AppRoutes.formularioBien: (_) => const FormularioBienView(),
        AppRoutes.entregas: (_) => const EntregasView(),
        AppRoutes.responsables: (_) => const ResponsablesView(),
      },
    );
  }
}
