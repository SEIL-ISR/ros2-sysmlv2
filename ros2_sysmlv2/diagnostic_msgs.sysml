package ros2_sysmlv2_diagnostic_msgs {
    doc
    /* Diagnostic message types for robot health monitoring.

       Maps to: diagnostic_msgs package from ros2/common_interfaces (Jazzy).
       3 message types used by the diagnostic_updater and diagnostic_aggregator
       subsystems for hardware health reporting.

       Dependency: ros2_sysmlv2_foundation (Header). */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;

    // ===============================================================
    // Diagnostic level enumeration
    // Source: diagnostic_msgs/msg/DiagnosticStatus.msg constants
    // ===============================================================

    enum def DiagnosticLevel {
        doc /* Severity level for a diagnostic status.
               Maps to byte constants in DiagnosticStatus.msg. */
        enum OK;
        enum Warn;
        enum Error;
        enum Stale;
    }

    // ===============================================================
    // Diagnostic message types
    // ===============================================================

    item def KeyValue {
        doc /* A key-value pair for diagnostic details.
               Maps to diagnostic_msgs/msg/KeyValue. */
        attribute key : String;
        attribute value : String;
    }

    item def DiagnosticStatus {
        doc /* Status report for a single diagnostic source.
               Maps to diagnostic_msgs/msg/DiagnosticStatus. */
        attribute level : DiagnosticLevel;
        attribute name : String;
        attribute diagnosticMessage : String;
        attribute hardwareId : String;
        item values : KeyValue[0..*];
    }

    item def DiagnosticArray {
        doc /* Timestamped array of diagnostic statuses.
               Maps to diagnostic_msgs/msg/DiagnosticArray. */
        item header : Header;
        item status : DiagnosticStatus[0..*];
    }
}
