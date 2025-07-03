import 'package:flutter/material.dart';

class IntakeProgressProvider extends ChangeNotifier {
  int totalIntakes = 0;
  int takenIntakes = 0;

  void setTotalIntakes(int total) {
    totalIntakes = total;
    if (takenIntakes > totalIntakes) takenIntakes = totalIntakes;
    notifyListeners();
  }

  void markAsTaken() {
    if (takenIntakes < totalIntakes) {
      takenIntakes++;
      notifyListeners();
    }
  }

  void resetProgress() {
    takenIntakes = 0;
    notifyListeners();
  }

  double get progress {
    if (totalIntakes == 0) return 0;
    return takenIntakes / totalIntakes;
  }

  void setProgress(int completed, int total) {
    takenIntakes = completed;
    totalIntakes = total;
    notifyListeners();
  }
}
