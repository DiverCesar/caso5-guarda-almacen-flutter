# Guarda de Almacén App (Caso 5: Entrega de Bienes en Guarda de Almacén)

Aplicación móvil profesional desarrollada en **Flutter** para la gestión, entrega y custodia de bienes institucionales (docentes, laboratorios, oficinas y responsables de proyectos). Implementa **Clean Architecture**, **MVVM (Model-View-ViewModel)**, **Provider** como gestor de estado, consumo de **API REST** con fallback transparente en memoria y microinteracciones fluidas con gestos nativos de Android.

---

## 1. Arquitectura y Stack Tecnológico

La aplicación está estructurada bajo los principios de **Clean Architecture** y **MVVM**:

```
lib/
├── core/
│   └── errors/
│       └── exceptions.dart           # Excepciones de negocio (ValidationException, ServerException)
├── domain/                           # Capa de Dominio (Independiente del framework)
│   ├── entities/
│   │   ├── bien.dart                 # Entidad Bien (Estados, disponibilidad, validaciones)
│   │   ├── entrega.dart              # Entidad Entrega (Temporal/Definitiva, retorno, daño)
│   │   └── responsable.dart          # Entidad Responsable (Docente, lab, oficina, proyecto)
│   ├── repositories/
│   │   └── almacen_repository.dart   # Contrato abstracto del repositorio
│   └── usecases/                     # Casos de uso con reglas de negocio estrictas
│       ├── obtener_bienes_usecase.dart
│       ├── crear_bien_usecase.dart            # Regla 1 (Código único) y Regla 3
│       ├── actualizar_bien_usecase.dart       # Regla 8 (Bloqueo por baja)
│       ├── cambiar_estado_bien_usecase.dart
│       ├── eliminar_bien_usecase.dart
│       ├── obtener_responsables_usecase.dart
│       ├── crear_responsable_usecase.dart     # Regla 4 (Asociación obligatoria)
│       ├── obtener_entregas_usecase.dart
│       ├── registrar_entrega_usecase.dart     # Reglas 2, 5, 6, 7 y 8
│       └── registrar_devolucion_usecase.dart  # Reglas 9 y 10 (Daño -> Mantenimiento)
├── data/                             # Capa de Datos
│   ├── models/                       # Modelos JSON (DTOs) con fromJson / toJson
│   │   ├── bien_model.dart
│   │   ├── entrega_model.dart
│   │   └── responsable_model.dart
│   ├── datasources/
│   │   └── almacen_api.dart          # Cliente HTTP REST con fallback en memoria
│   └── repositories/
│       └── almacen_repository_impl.dart # Implementación concreta del repositorio
├── presentation/                     # Capa de Presentación
│   ├── theme/
│   │   └── app_theme.dart            # Material 3: Gris humo (#F6F7F9), Slate (#0F172A), badges
│   ├── viewmodels/
│   │   └── almacen_viewmodel.dart    # ViewModel ChangeNotifier (Estados, filtros, KPIs)
│   ├── views/
│   │   ├── dashboard_view.dart       # Resumen con KPIs métricos y accesos directos
│   │   ├── bienes_view.dart          # Inventario con buscador y chips de filtro
│   │   ├── detalle_bien_view.dart    # Vista detallada con Hero y trazabilidad histórica
│   │   ├── formulario_bien_view.dart # Registro y edición de bienes
│   │   ├── entregas_view.dart        # Pestañas de entregas activas y devueltas
│   │   ├── responsables_view.dart    # Listado y detalle de custodios
│   │   └── main_navigation_view.dart # PageView y NavigationBar con deslizamiento
│   └── widgets/                      # Componentes reutilizables
│       ├── bien_card.dart            # Tarjeta Dismissible con gestos interactivos
│       ├── entrega_card.dart         # Tarjeta Dismissible para devolución rápida
│       ├── estado_badge.dart         # Badge semántico de estado
│       ├── kpi_card.dart             # Tarjeta numérica para dashboard
│       ├── custom_text_field.dart    # Input institucional estilizado
│       ├── formulario_entrega_sheet.dart    # BottomSheet de asignación
│       ├── formulario_devolucion_sheet.dart # BottomSheet de retorno
│       └── formulario_responsable_sheet.dart
├── routes/
│   └── app_routes.dart               # Rutas nombradas centralizadas
└── main.dart                         # Inyección de dependencias e inicio de la app
```

---

## 2. Reglas de Negocio Implementadas (Caso 5)

1. **Código institucional único:** No permite registrar ni editar un bien con un `codigoInstitucional` duplicado.
2. **Solo bienes disponibles:** Un bien solo puede entregarse si su estado actual es `Disponible`.
3. **Estados permitidos del bien:** Estrictamente `Disponible`, `Entregado`, `En mantenimiento` y `Dado de baja`.
4. **Asociación obligatoria:** Toda entrega requiere un `Responsable` institucional registrado.
5. **Campos obligatorios:** Toda entrega exige `fechaEntrega`, `cantidad`, `observacion` y `condicionEntrega`.
6. **Control de stock:** La cantidad a entregar debe ser mayor a 0 y no puede superar `cantidadDisponible`.
7. **Actualización automática de disponibilidad:** Al entregar, se descuenta de `cantidadDisponible`. Si llega a 0, el estado pasa automáticamente a `Entregado`.
8. **Bloqueo por baja:** Un bien con estado `Dado de baja` no puede volver a entregarse ni editarse para reactivación.
9. **Registro de devolución:** Obligatorio registrar `condicionDevolucion`. Si no presenta daño, reincorpora la cantidad al stock disponible y restaura el estado a `Disponible`.
10. **Cambio automático a mantenimiento por daño:** Si en la devolución se indica `presentaDano: true`, el bien pasa automáticamente a `En mantenimiento`, impidiendo nuevas entregas hasta ser reparado.

---

## 3. Gestos Nativos de Android y Microinteracciones

- **Swipe Horizontal (`Dismissible`) en Bienes:**
  - *Deslizar a la derecha:* Abre el modal de **Nueva Entrega** (con aviso háptico de bloqueo si el bien no está disponible).
  - *Deslizar a la izquierda:* Despliega el menú rápido para **Cambiar Estado** (Mantenimiento o Baja).
- **Swipe Horizontal (`Dismissible`) en Entregas Activas:**
  - *Deslizar a la derecha:* Abre inmediatamente el formulario de **Devolución** con el switch de daño y campo de condición.
- **Pull-to-Refresh (`RefreshIndicator`):** Disponible en todas las pantallas para sincronizar con la API REST.
- **Long Press (`onLongPress`) + `HapticFeedback.mediumImpact()`:** Despliega menú contextual en tarjetas de bienes y entregas.
- **Doble Tap (`onDoubleTap`) + `HapticFeedback.lightImpact()`:** En el código institucional para copiarlo al portapapeles con `SnackBar`.
- **Navegación por Deslizamiento (`PageView` / `TabBarView`):** Permite cambiar entre las 4 secciones principales y entre las pestañas de entregas mediante gestos táctiles fluidos.
- **Transición Hero (`Hero`):** Animación fluida del identificador/ícono del bien entre la lista y la vista de detalle.
- **Hojas Arrastrables (`DraggableScrollableSheet`):** Formularios emergentes modernos tipo Bottom Sheet.

---

## 4. Servidor Backend REST API

La aplicación incluye un servidor mock REST en `/backend_api` desarrollado en Node.js puro (cero dependencias externas para arranque inmediato):

### Comandos para arrancar el backend:
```bash
cd backend_api
npm start
# O directamente:
node server.js
```
El servidor escuchará en `http://localhost:3000`.

### Endpoints REST disponibles:
- `GET /api/bienes` - Listar todos los bienes
- `POST /api/bienes` - Registrar un nuevo bien
- `PUT /api/bienes/:id` - Actualizar un bien
- `DELETE /api/bienes/:id` - Eliminar un bien
- `GET /api/responsables` - Listar responsables
- `POST /api/responsables` - Registrar responsable
- `GET /api/entregas` - Listar entregas
- `POST /api/entregas` - Registrar nueva entrega
- `PUT /api/entregas/:id/devolucion` - Registrar devolución de una entrega

> **Resiliencia y Fallback Transparente:** Si el servidor backend no se encuentra iniciado o no es accesible (por ejemplo, en un emulador o entorno de prueba offline), el cliente `AlmacenApi` conmuta de manera 100% transparente a almacenamiento en memoria local precargado con los datos semilla para que la aplicación nunca se rompa.

---

## 5. Rutas Nombradas Centralizadas

Configuradas en `lib/routes/app_routes.dart`:
- `AppRoutes.inicio` (`/`): Pantalla principal con `PageView` (Dashboard, Bienes, Entregas, Responsables).
- `AppRoutes.bienes` (`/bienes`): Listado de inventario.
- `AppRoutes.detalleBien` (`/bien/detalle`): Ficha técnica e historial del bien.
- `AppRoutes.formularioBien` (`/bien/formulario`): Registro y edición de bien.
- `AppRoutes.entregas` (`/entregas`): Gestión de custodias y retornos.
- `AppRoutes.responsables` (`/responsables`): Directorio institucional.

---

## 6. Pruebas y Verificación

Para ejecutar el analizador de código y las pruebas unitarias de reglas de negocio:
```bash
flutter analyze
flutter test
```
