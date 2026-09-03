package ros2_sysmlv2_params {
    doc
    /* ROS2 parameter system: types, descriptors, ranges, and declarations.

       Models the ROS2 node parameter infrastructure that allows runtime
       configuration of nodes via typed, described, constrained parameters.

       Ground truth sources:
         - rcl_interfaces/msg/ParameterType.msg (10 type constants)
         - rcl_interfaces/msg/ParameterDescriptor.msg (8 fields)
         - rcl_interfaces/msg/IntegerRange.msg (3 fields)
         - rcl_interfaces/msg/FloatingPointRange.msg (3 fields)
         - rcl_interfaces/msg/Parameter.msg (2 fields)
         - rclpy/node.py (declare_parameter, get_parameter)

       Note: ParameterValue.msg is a union-like struct dispatching on type.
       SysML v2 does not have union types, so we model the type enum and
       descriptor but not the variant value holder. The type enum captures
       the essential semantics for architecture modeling.

       Dependency: ros2_sysmlv2_foundation. */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;

    // ===============================================================
    // Parameter type enumeration
    // Source: rcl_interfaces/msg/ParameterType.msg (10 constants)
    // ===============================================================

    enum def ParameterTypeKind {
        doc /* Discriminator for parameter value types.
               Maps to rcl_interfaces/msg/ParameterType.msg.
               Each enum value corresponds to a PARAMETER_* constant. */
        enum NotSet;
        enum Bool;
        enum Integer;
        enum Double;
        enum StringType;
        enum ByteArray;
        enum BoolArray;
        enum IntegerArray;
        enum DoubleArray;
        enum StringArray;
    }

    // ===============================================================
    // Range constraint types
    // Source: rcl_interfaces/msg/IntegerRange.msg,
    //         rcl_interfaces/msg/FloatingPointRange.msg
    // ===============================================================

    attribute def IntegerRange {
        doc /* Bounds and step for an integer-typed parameter.
               Maps to rcl_interfaces/msg/IntegerRange.msg.
               A step of 0 implies a continuous range. */
        attribute fromValue : Integer;
        attribute toValue : Integer;
        attribute step : Integer;
    }

    attribute def FloatingPointRange {
        doc /* Bounds and step for a floating-point-typed parameter.
               Maps to rcl_interfaces/msg/FloatingPointRange.msg.
               A step of 0.0 implies a continuous range. */
        attribute fromValue : Real;
        attribute toValue : Real;
        attribute step : Real;
    }

    // ===============================================================
    // Parameter descriptor
    // Source: rcl_interfaces/msg/ParameterDescriptor.msg (8 fields)
    // ===============================================================

    attribute def ParameterDescriptor {
        doc /* Describes a node parameter: its name, type, documentation,
               mutability, and value constraints.
               Maps to rcl_interfaces/msg/ParameterDescriptor.msg.

               Usage in a node definition:
                 attribute maxSpeed : ParameterDescriptor {
                     :>> name = "max_speed";
                     :>> parameterType = ParameterTypeKind::Double;
                     :>> description = "Maximum linear velocity in m/s";
                     :>> readOnly = false;
                     :>> floatingPointRange { :>> fromValue = 0.0; :>> toValue = 2.0; :>> step = 0.1; }
                 } */
        attribute name : String;
        attribute parameterType : ParameterTypeKind;
        attribute description : String;
        attribute additionalConstraints : String;
        attribute readOnly : Boolean;
        attribute dynamicTyping : Boolean;
        attribute floatingPointRange : FloatingPointRange;
        attribute integerRange : IntegerRange;
    }

    // ===============================================================
    // Declared parameter (name + type + descriptor)
    // Convenience definition for declaring parameters on nodes.
    // Source: rclpy Node.declare_parameter(name, value, descriptor)
    // ===============================================================

    attribute def DeclaredParameter {
        doc /* A fully declared parameter on a node.
               Maps to rclpy Node.declare_parameter(name, value, descriptor).

               Usage in a node definition:
                 part def MyNode :> LifecycleNode {
                     attribute maxVel : DeclaredParameter {
                         :>> name = "max_velocity";
                         :>> parameterType = ParameterTypeKind::Double;
                         :>> descriptor { :>> description = "Max vel in m/s"; }
                     }
                 } */
        attribute name : String;
        attribute parameterType : ParameterTypeKind;
        attribute descriptor : ParameterDescriptor;
    }
}
