package ros2_sysmlv2_std_msgs {
    doc
    /* Standard messages for ROS2.

       Maps to: std_msgs package from ros2/common_interfaces.
       Provides basic data types used across the ROS2 ecosystem.

       Note: Primitive wrapper messages (Bool, Int8, Float32, etc.)
       are deliberately omitted: SysML v2 has native scalar types
       in ScalarValues (Boolean, Integer, Real, String) that serve
       the same purpose. */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;

    // ===============================================================
    // Color
    // Maps to: std_msgs/msg/ColorRGBA
    // ===============================================================

    item def ColorRGBA {
        doc /* RGBA color with floating point channels [0.0, 1.0].
               Maps to std_msgs/msg/ColorRGBA. */
        attribute r : Real;
        attribute g : Real;
        attribute b : Real;
        attribute a : Real;
    }

    // ===============================================================
    // Empty message (used for parameterless triggers)
    // Maps to: std_msgs/msg/Empty
    // ===============================================================

    item def Empty {
        doc /* Empty message type. Used for topics/services that carry
               no payload: the message arrival itself is the signal.
               Maps to std_msgs/msg/Empty. */
    }

    // ===============================================================
    // Multi-dimensional array support
    // Maps to: std_msgs/msg/MultiArrayDimension, MultiArrayLayout
    // ===============================================================

    item def MultiArrayDimension {
        doc /* Describes one dimension of a multi-dimensional array.
               Maps to std_msgs/msg/MultiArrayDimension. */
        attribute label : String;
        attribute size : Integer;
        attribute stride : Integer;
    }

    item def MultiArrayLayout {
        doc /* Layout descriptor for multi-dimensional arrays.
               Maps to std_msgs/msg/MultiArrayLayout. */
        item dim : MultiArrayDimension[0..*];
        attribute dataOffset : Integer;
    }
}
