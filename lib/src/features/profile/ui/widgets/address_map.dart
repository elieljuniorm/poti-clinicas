import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_decorations.dart';
import '../../../../core/ui/theme/app_text_styles.dart';
import '../../application/address_map_controller.dart';
import '../../domain/models/address_model.dart';
import '../../domain/models/geo_point_model.dart';
import '../states/address_map_state.dart';

/// Mapa do endereço (OpenStreetMap). Sempre visível.
///
/// Mostra o pino do endereço buscado pelo [AddressMapController].
/// Um toque no mapa escolhe o ponto e entrega o endereço dele em
/// [aoSelecionarEndereco], para o formulário preencher os campos.
class AddressMap extends ConsumerStatefulWidget {
  final ValueChanged<AddressModel> aoSelecionarEndereco;

  /// `true` enquanto o dedo está no mapa. A tela usa para travar a rolagem,
  /// senão o arraste vertical rola a página em vez de mover o mapa.
  final ValueChanged<bool>? aoUsarMapa;
  final bool habilitado;

  const AddressMap({
    super.key,
    required this.aoSelecionarEndereco,
    this.aoUsarMapa,
    this.habilitado = true,
  });

  @override
  ConsumerState<AddressMap> createState() => _AddressMapState();
}

class _AddressMapState extends ConsumerState<AddressMap> {
  static const _zoomEndereco = 17.0;
  static const _zoomCidade = 13.0;

  final _mapController = MapController();
  bool _mapaPronto = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng _latLng(GeoPointModel ponto) =>
      LatLng(ponto.latitude, ponto.longitude);

  double _zoom(AddressMapState mapa) =>
      mapa.marcador != null ? _zoomEndereco : _zoomCidade;

  Future<void> _aoTocarMapa(TapPosition _, LatLng ponto) async {
    if (!widget.habilitado) return;

    final endereco = await ref
        .read(addressMapControllerProvider.notifier)
        .selecionarPonto(
          GeoPointModel(latitude: ponto.latitude, longitude: ponto.longitude),
        );
    if (endereco != null && mounted) widget.aoSelecionarEndereco(endereco);
  }

  @override
  Widget build(BuildContext context) {
    // Endereço novo encontrado: leva a câmera até ele (ou até Belém).
    ref.listen<AddressMapState>(addressMapControllerProvider, (previous, next) {
      if (_mapaPronto && previous?.centro != next.centro) {
        _mapController.move(_latLng(next.centro), _zoom(next));
      }
    });

    final mapa = ref.watch(addressMapControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 260,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: AppDecorations.card,
          clipBehavior: Clip.antiAlias,
          child: Listener(
            onPointerDown: (_) => widget.aoUsarMapa?.call(true),
            onPointerUp: (_) => widget.aoUsarMapa?.call(false),
            onPointerCancel: (_) => widget.aoUsarMapa?.call(false),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _latLng(mapa.centro),
                    initialZoom: _zoom(mapa),
                    onMapReady: () => _mapaPronto = true,
                    onTap: _aoTocarMapa,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.poti_5f',
                    ),
                    if (mapa.marcador != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _latLng(mapa.marcador!),
                            width: 44,
                            height: 44,
                            // A ponta do ícone fica em cima do ponto.
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Symbols.location_on,
                              size: 44,
                              fill: 1,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    const SimpleAttributionWidget(
                      source: Text('OpenStreetMap contributors'),
                    ),
                  ],
                ),
                if (mapa.isSearching)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: _IndicadorBusca(),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            mapa.aviso ?? 'Toque no mapa para ajustar o local do endereço.',
            style: AppTextStyles.sectionSubtitle.copyWith(
              color: mapa.aviso != null ? AppColors.error : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Widgets internos
// ============================================================

class _IndicadorBusca extends StatelessWidget {
  const _IndicadorBusca();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.borderAccent,
        ),
      ),
    );
  }
}
