package ros2_sysmlv2_geometry_msgs {
    doc
    /* Geometric primitive types and common spatial data structures.

       Maps to: geometry_msgs package from ros2/common_interfaces (Jazzy).
       32 message types covering vectors, points, orientations, poses,
       twists, transforms, wrenches, and their stamped/covariance variants.

       Dependency: ros2_sysmlv2_foundation (Header, CovarianceMatrix6x6). */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;

    // ===============================================================
    // Base vector types
    // ===============================================================

    item def Vector3 {
        doc /* 3D vector (x, y, z) using float64.
               Maps to geometry_msgs/msg/Vector3. */
        attribute x : Real;
        attribute y : Real;
        attribute z : Real;
    }

    item def Point {
        doc /* 3D point in space (x, y, z) using float64.
               Maps to geometry_msgs/msg/Point.
               Semantically a position, not a direction. */
        attribute x : Real;
        attribute y : Real;
        attribute z : Real;
    }

    item def Point32 {
        doc /* 3D point using float32 (lower precision, smaller footprint).
               Maps to geometry_msgs/msg/Point32.
               Used in Polygon for memory efficiency. */
        attribute x : Real;
        attribute y : Real;
        attribute z : Real;
    }

    item def Quaternion {
        doc /* Orientation in free space as a unit quaternion.
               Maps to geometry_msgs/msg/Quaternion.
               Default: identity rotation (0, 0, 0, 1). */
        attribute x : Real;
        attribute y : Real;
        attribute z : Real;
        attribute w : Real;
    }

    // ===============================================================
    // 2D types
    // ===============================================================

    item def Pose2D {
        doc /* Deprecated planar pose (x, y, theta).
               Maps to geometry_msgs/msg/Pose2D.
               Prefer Pose for new designs. */
        attribute x : Real;
        attribute y : Real;
        attribute theta : Real;
    }

    // ===============================================================
    // Composed types (pairs of base vectors)
    // ===============================================================

    item def Pose {
        doc /* Position and orientation in free space.
               Maps to geometry_msgs/msg/Pose. */
        item position : Point;
        item orientation : Quaternion;
    }

    item def Twist {
        doc /* Velocity in free space: linear and angular components.
               Maps to geometry_msgs/msg/Twist. */
        item linear : Vector3;
        item angular : Vector3;
    }

    item def Accel {
        doc /* Acceleration in free space: linear and angular components.
               Maps to geometry_msgs/msg/Accel. */
        item linear : Vector3;
        item angular : Vector3;
    }

    item def Wrench {
        doc /* Force and torque in free space.
               Maps to geometry_msgs/msg/Wrench. */
        item force : Vector3;
        item torque : Vector3;
    }

    item def Transform {
        doc /* Geometric transform: translation and rotation.
               Maps to geometry_msgs/msg/Transform. */
        item translation : Vector3;
        item rotation : Quaternion;
    }

    item def Inertia {
        doc /* Mass and inertia tensor.
               Maps to geometry_msgs/msg/Inertia. */
        attribute m : Real;
        item com : Vector3;
        attribute ixx : Real;
        attribute ixy : Real;
        attribute ixz : Real;
        attribute iyy : Real;
        attribute iyz : Real;
        attribute izz : Real;
    }

    // ===============================================================
    // Stamped variants (Header + base type, composition not inheritance)
    // ===============================================================

    item def PointStamped {
        doc /* Timestamped Point. Maps to geometry_msgs/msg/PointStamped. */
        item header : Header;
        item point : Point;
    }

    item def PoseStamped {
        doc /* Timestamped Pose. Maps to geometry_msgs/msg/PoseStamped. */
        item header : Header;
        item pose : Pose;
    }

    item def TwistStamped {
        doc /* Timestamped Twist. Maps to geometry_msgs/msg/TwistStamped. */
        item header : Header;
        item twist : Twist;
    }

    item def AccelStamped {
        doc /* Timestamped Accel. Maps to geometry_msgs/msg/AccelStamped. */
        item header : Header;
        item accel : Accel;
    }

    item def WrenchStamped {
        doc /* Timestamped Wrench. Maps to geometry_msgs/msg/WrenchStamped. */
        item header : Header;
        item wrench : Wrench;
    }

    item def QuaternionStamped {
        doc /* Timestamped Quaternion. Maps to geometry_msgs/msg/QuaternionStamped. */
        item header : Header;
        item quaternion : Quaternion;
    }

    item def Vector3Stamped {
        doc /* Timestamped Vector3. Maps to geometry_msgs/msg/Vector3Stamped. */
        item header : Header;
        item vector : Vector3;
    }

    item def InertiaStamped {
        doc /* Timestamped Inertia. Maps to geometry_msgs/msg/InertiaStamped. */
        item header : Header;
        item inertia : Inertia;
    }

    item def TransformStamped {
        doc /* Timestamped Transform with parent and child frame IDs.
               Maps to geometry_msgs/msg/TransformStamped.
               Published on /tf and /tf_static topics. */
        item header : Header;
        attribute childFrameId : String;
        item transform : Transform;
    }

    item def VelocityStamped {
        doc /* Stamped velocity with reference frame context.
               Maps to geometry_msgs/msg/VelocityStamped. */
        item header : Header;
        attribute bodyFrameId : String;
        attribute referenceFrameId : String;
        item velocity : Twist;
    }

    // ===============================================================
    // WithCovariance variants
    // ===============================================================

    item def PoseWithCovariance {
        doc /* Pose with 6x6 covariance matrix (36 elements, row-major).
               Maps to geometry_msgs/msg/PoseWithCovariance. */
        item pose : Pose;
        attribute covariance : CovarianceMatrix6x6;
    }

    item def TwistWithCovariance {
        doc /* Twist with 6x6 covariance matrix.
               Maps to geometry_msgs/msg/TwistWithCovariance. */
        item twist : Twist;
        attribute covariance : CovarianceMatrix6x6;
    }

    item def AccelWithCovariance {
        doc /* Accel with 6x6 covariance matrix.
               Maps to geometry_msgs/msg/AccelWithCovariance. */
        item accel : Accel;
        attribute covariance : CovarianceMatrix6x6;
    }

    // ===============================================================
    // WithCovariance + Stamped variants
    // ===============================================================

    item def PoseWithCovarianceStamped {
        doc /* Timestamped PoseWithCovariance.
               Maps to geometry_msgs/msg/PoseWithCovarianceStamped. */
        item header : Header;
        item pose : PoseWithCovariance;
    }

    item def TwistWithCovarianceStamped {
        doc /* Timestamped TwistWithCovariance.
               Maps to geometry_msgs/msg/TwistWithCovarianceStamped. */
        item header : Header;
        item twist : TwistWithCovariance;
    }

    item def AccelWithCovarianceStamped {
        doc /* Timestamped AccelWithCovariance.
               Maps to geometry_msgs/msg/AccelWithCovarianceStamped. */
        item header : Header;
        item accel : AccelWithCovariance;
    }

    // ===============================================================
    // Collection types
    // ===============================================================

    item def Polygon {
        doc /* Ordered list of Point32 forming a polygon.
               Maps to geometry_msgs/msg/Polygon. */
        item points : Point32[0..*];
    }

    item def PolygonStamped {
        doc /* Timestamped Polygon. Maps to geometry_msgs/msg/PolygonStamped. */
        item header : Header;
        item polygon : Polygon;
    }

    item def PolygonInstance {
        doc /* Polygon with an instance ID.
               Maps to geometry_msgs/msg/PolygonInstance. */
        item polygon : Polygon;
        attribute id : Integer;
    }

    item def PolygonInstanceStamped {
        doc /* Timestamped PolygonInstance.
               Maps to geometry_msgs/msg/PolygonInstanceStamped. */
        item header : Header;
        item polygon : PolygonInstance;
    }

    item def PoseArray {
        doc /* Array of poses. Used for particle clouds, path candidates.
               Maps to geometry_msgs/msg/PoseArray. */
        item header : Header;
        item poses : Pose[0..*];
    }
}
