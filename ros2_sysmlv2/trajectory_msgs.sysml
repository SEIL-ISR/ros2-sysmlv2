library package ros2_sysmlv2_trajectory_msgs {
    doc
    /* Joint and multi-DOF trajectory types for robot motion control.

       Maps to: trajectory_msgs package from ros2/common_interfaces (Jazzy).
       4 message types used by ros2_control, MoveIt, and trajectory tracking.

       Dependency: ros2_sysmlv2_foundation (Header, Duration),
                   ros2_sysmlv2_geometry_msgs (Transform, Twist). */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;
    private import ros2_sysmlv2_geometry_msgs::*;

    // ===============================================================
    // Joint trajectory types
    // ===============================================================

    item def JointTrajectoryPoint {
        doc /* A single point on a joint-space trajectory.
               Maps to trajectory_msgs/msg/JointTrajectoryPoint. */
        attribute positions : Real[0..*] ordered nonunique;
        attribute velocities : Real[0..*] ordered nonunique;
        attribute accelerations : Real[0..*] ordered nonunique;
        attribute effort : Real[0..*] ordered nonunique;
        item timeFromStart : Duration;
    }

    item def JointTrajectory {
        doc /* An ordered sequence of joint-space trajectory points.
               Maps to trajectory_msgs/msg/JointTrajectory. */
        item header : Header;
        attribute jointNames : String[0..*] ordered nonunique;
        item points : JointTrajectoryPoint[0..*] ordered;
    }

    // ===============================================================
    // Multi-DOF joint trajectory types
    // ===============================================================

    item def MultiDOFJointTrajectoryPoint {
        doc /* A single point on a multi-DOF (Cartesian) trajectory.
               Maps to trajectory_msgs/msg/MultiDOFJointTrajectoryPoint. */
        item transforms : Transform[0..*] ordered;
        item velocities : Twist[0..*] ordered;
        item accelerations : Twist[0..*] ordered;
        item timeFromStart : Duration;
    }

    item def MultiDOFJointTrajectory {
        doc /* An ordered sequence of multi-DOF trajectory points.
               Maps to trajectory_msgs/msg/MultiDOFJointTrajectory. */
        item header : Header;
        attribute jointNames : String[0..*] ordered nonunique;
        item points : MultiDOFJointTrajectoryPoint[0..*] ordered;
    }
}
