import '../../domain/models/scheduling_appointment_model.dart';

sealed class EditAppointmentState {
  const EditAppointmentState();
}

class EditAppointmentInitial extends EditAppointmentState {
  const EditAppointmentInitial();
}

class EditAppointmentSaving extends EditAppointmentState {
  const EditAppointmentSaving();
}

class EditAppointmentSuccess extends EditAppointmentState {
  final SchedulingAppointmentModel appointment;
  const EditAppointmentSuccess(this.appointment);
}

class EditAppointmentError extends EditAppointmentState {
  final String message;
  const EditAppointmentError(this.message);
}
