import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

part 'panel_position_provider.g.dart';

class PanelPositionUpdate {
  final PanelState position;
  final bool move;
  PanelPositionUpdate(this.position, this.move);
}

@riverpod
class PanelPosition extends _$PanelPosition {
  @override
  PanelPositionUpdate build() => PanelPositionUpdate(PanelState.HIDDEN, false);

  void move(PanelState position) {
    state = PanelPositionUpdate(position, true);
  }
  void update(PanelState position) {
    state = PanelPositionUpdate(position, false);
  }
}
