package ros2_sysmlv2_foundation {
    doc
    /* Foundation layer for the ROS2-SysMLv2 domain library.

       Provides the base types that all other layers depend on:
       time primitives (Time, Duration), the universal message
       header (Header), covariance matrix type, and RMW
       transport configuration.

       Maps to: builtin_interfaces, std_msgs/Header, and
       ROS2 middleware abstractions. */

    private import ScalarValues::*;

    // ===============================================================
    // Time primitives
    // Maps to: builtin_interfaces/msg/Time, Duration
    // ===============================================================

    item def Time {
        doc /* ROS2 timestamp. Maps to builtin_interfaces/msg/Time.
               Two-integer representation: seconds + nanoseconds.
               Modeled as item def because builtin_interfaces/Time.msg is a
               structured message type (OMG SysML v2.0 §7.10). */
        attribute sec : Integer;
        attribute nanosec : Integer;
    }

    item def Duration {
        doc /* ROS2 duration. Maps to builtin_interfaces/msg/Duration.
               Same two-integer representation as Time.
               Modeled as item def for the same reason as Time. */
        attribute sec : Integer;
        attribute nanosec : Integer;
    }

    // ===============================================================
    // Universal message header
    // Maps to: std_msgs/msg/Header
    // ===============================================================

    item def Header {
        doc /* Standard metadata for higher-level stamped data types.
               Maps to std_msgs/msg/Header.
               Included in every Stamped message variant. */
        item stamp : Time;
        attribute frameId : String;
    }

    // ===============================================================
    // Covariance matrix (reused by geometry and sensor messages)
    // ===============================================================

    attribute def CovarianceMatrix6x6 {
        doc /* Row-major 6x6 covariance matrix stored as 36 elements.
               Order: (x, y, z, rotation about x, rotation about y,
               rotation about z).
               Used by PoseWithCovariance, TwistWithCovariance, etc. */
        attribute values : Real[36];
    }

    // ===============================================================
    // RMW (middleware) configuration
    // ===============================================================

    enum def RMWKind {
        doc /* ROS2 middleware implementation selection.
               Zenoh is the primary target for this library (Tier 1 in Jazzy).
               DDS implementations are secondary/fallback. */
        enum Zenoh;
        enum FastRTPS;
        enum CycloneDDS;
    }

    attribute def RMWConfig {
        doc /* Deployment-time middleware configuration.
               Maps to the RMW_IMPLEMENTATION environment variable
               and ROS_DOMAIN_ID. */
        attribute rmwImplementation : RMWKind;
        attribute domainId : Integer;
    }
}
