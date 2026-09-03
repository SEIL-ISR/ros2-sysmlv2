package ros2_sysmlv2_action_msgs {
    doc
    /* Action infrastructure message types.

       Maps to: action_msgs package from ros2/rcl_interfaces (Jazzy).
       3 message types that underpin the ROS2 action protocol.
       GoalStatus tracks the lifecycle of action goals.

       Dependency: ros2_sysmlv2_foundation (Time). */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;

    // ===============================================================
    // Goal status enumeration
    // Source: action_msgs/msg/GoalStatus.msg constants
    // ===============================================================

    enum def GoalStatusKind {
        doc /* Lifecycle state of an action goal.
               Maps to int8 constants in GoalStatus.msg. */
        enum Unknown;
        enum Accepted;
        enum Executing;
        enum Canceling;
        enum Succeeded;
        enum Canceled;
        enum Aborted;
    }

    // ===============================================================
    // Action infrastructure message types
    // ===============================================================

    item def GoalInfo {
        doc /* Unique identifier and timestamp for an action goal.
               Maps to action_msgs/msg/GoalInfo.
               goalId is a UUID (16 bytes) represented as a String. */
        attribute goalId : String;
        item stamp : Time;
    }

    item def GoalStatus {
        doc /* Current lifecycle status of an action goal.
               Maps to action_msgs/msg/GoalStatus. */
        item goalInfo : GoalInfo;
        attribute status : GoalStatusKind;
    }

    item def GoalStatusArray {
        doc /* Array of goal statuses, published by action servers.
               Maps to action_msgs/msg/GoalStatusArray. */
        item statusList : GoalStatus[0..*];
    }
}
