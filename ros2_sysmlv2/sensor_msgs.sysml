package ros2_sysmlv2_sensor_msgs {
    doc
    /* Sensor data message types for ROS2.

       Maps to: sensor_msgs package from ros2/common_interfaces (Jazzy).
       27 message types covering IMU, LiDAR, camera, GPS, battery,
       joint state, and other sensor modalities.

       Dependencies: ros2_sysmlv2_foundation (Header),
                     ros2_sysmlv2_geometry_msgs (Quaternion, Vector3, etc.). */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;
    private import ros2_sysmlv2_geometry_msgs::*;

    // ===============================================================
    // Supporting types
    // ===============================================================

    item def RegionOfInterest {
        doc /* Region of interest in an image. Maps to sensor_msgs/msg/RegionOfInterest. */
        attribute xOffset : Integer;
        attribute yOffset : Integer;
        attribute height : Integer;
        attribute width : Integer;
        attribute doRectify : Boolean;
    }

    // ===============================================================
    // Navigation-critical sensors
    // ===============================================================

    item def Imu {
        doc /* Inertial Measurement Unit data: orientation, angular velocity,
               linear acceleration, each with 3x3 covariance.
               Maps to sensor_msgs/msg/Imu. */
        item header : Header;
        item orientation : Quaternion;
        attribute orientationCovariance : Real[9];
        item angularVelocity : Vector3;
        attribute angularVelocityCovariance : Real[9];
        item linearAcceleration : Vector3;
        attribute linearAccelerationCovariance : Real[9];
    }

    item def LaserScan {
        doc /* Single scan from a planar laser range-finder.
               Maps to sensor_msgs/msg/LaserScan. */
        item header : Header;
        attribute angleMin : Real;
        attribute angleMax : Real;
        attribute angleIncrement : Real;
        attribute timeIncrement : Real;
        attribute scanTime : Real;
        attribute rangeMin : Real;
        attribute rangeMax : Real;
        attribute ranges : Real[0..*];
        attribute intensities : Real[0..*];
    }

    item def PointField {
        doc /* Description of a single field in a PointCloud2 message.
               Maps to sensor_msgs/msg/PointField.
               Constants INT8=1..FLOAT64=8 modeled as PointFieldDatatype enum. */
        attribute name : String;
        attribute offset : Integer;
        attribute datatype : Integer;
        attribute count : Integer;
    }

    item def PointCloud2 {
        doc /* Multi-dimensional point cloud with arbitrary field descriptors.
               Maps to sensor_msgs/msg/PointCloud2. */
        item header : Header;
        attribute height : Integer;
        attribute width : Integer;
        item fields : PointField[0..*];
        attribute isBigendian : Boolean;
        attribute pointStep : Integer;
        attribute rowStep : Integer;
        attribute data : Integer[0..*];
        attribute isDense : Boolean;
    }

    item def Image {
        doc /* Raw camera image data.
               Maps to sensor_msgs/msg/Image. */
        item header : Header;
        attribute height : Integer;
        attribute width : Integer;
        attribute encoding : String;
        attribute isBigendian : Integer;
        attribute step : Integer;
        attribute data : Integer[0..*];
    }

    item def CompressedImage {
        doc /* Compressed image data (JPEG, PNG, etc.).
               Maps to sensor_msgs/msg/CompressedImage. */
        item header : Header;
        attribute format : String;
        attribute data : Integer[0..*];
    }

    item def CameraInfo {
        doc /* Camera calibration and metadata.
               Maps to sensor_msgs/msg/CameraInfo. */
        item header : Header;
        attribute height : Integer;
        attribute width : Integer;
        attribute distortionModel : String;
        attribute d : Real[0..*];
        attribute k : Real[9];
        attribute r : Real[9];
        attribute p : Real[12];
        attribute binningX : Integer;
        attribute binningY : Integer;
        item roi : RegionOfInterest;
    }

    // ===============================================================
    // LiDAR variants
    // ===============================================================

    item def LaserEcho {
        doc /* Multi-echo return from a single laser beam.
               Maps to sensor_msgs/msg/LaserEcho. */
        attribute echoes : Real[0..*];
    }

    item def MultiEchoLaserScan {
        doc /* Multi-echo variant of LaserScan.
               Maps to sensor_msgs/msg/MultiEchoLaserScan. */
        item header : Header;
        attribute angleMin : Real;
        attribute angleMax : Real;
        attribute angleIncrement : Real;
        attribute timeIncrement : Real;
        attribute scanTime : Real;
        attribute rangeMin : Real;
        attribute rangeMax : Real;
        item ranges : LaserEcho[0..*];
        item intensities : LaserEcho[0..*];
    }

    item def PointCloud {
        doc /* Legacy point cloud (prefer PointCloud2).
               Maps to sensor_msgs/msg/PointCloud. */
        item header : Header;
        item points : Point32[0..*];
        item channels : ChannelFloat32[0..*];
    }

    item def ChannelFloat32 {
        doc /* Named float array channel for PointCloud.
               Maps to sensor_msgs/msg/ChannelFloat32. */
        attribute name : String;
        attribute values : Real[0..*];
    }

    // ===============================================================
    // Localization sensors
    // ===============================================================

    item def NavSatStatus {
        doc /* GPS fix quality status.
               Maps to sensor_msgs/msg/NavSatStatus.
               Constants: STATUS_NO_FIX=-1, STATUS_FIX=0, STATUS_SBAS_FIX=1, STATUS_GBAS_FIX=2. */
        attribute status : Integer;
        attribute service : Integer;
    }

    item def NavSatFix {
        doc /* GPS/GNSS fix data.
               Maps to sensor_msgs/msg/NavSatFix.
               Covariance type constants: UNKNOWN=0, APPROXIMATED=1, DIAGONAL_KNOWN=2, KNOWN=3. */
        item header : Header;
        item status : NavSatStatus;
        attribute latitude : Real;
        attribute longitude : Real;
        attribute altitude : Real;
        attribute positionCovariance : Real[9];
        attribute positionCovarianceType : Integer;
    }

    item def MagneticField {
        doc /* Magnetic field measurement.
               Maps to sensor_msgs/msg/MagneticField. */
        item header : Header;
        item magneticField : Vector3;
        attribute magneticFieldCovariance : Real[9];
    }

    item def TimeReference {
        doc /* External time source reference.
               Maps to sensor_msgs/msg/TimeReference. */
        item header : Header;
        item timeRef : Time;
        attribute source : String;
    }

    // ===============================================================
    // Robot state
    // ===============================================================

    item def JointState {
        doc /* Joint position, velocity, and effort for a robot.
               Maps to sensor_msgs/msg/JointState. */
        item header : Header;
        attribute name : String[0..*];
        attribute position : Real[0..*];
        attribute velocity : Real[0..*];
        attribute effort : Real[0..*];
    }

    item def MultiDOFJointState {
        doc /* Multi-DOF joint state using geometric transforms.
               Maps to sensor_msgs/msg/MultiDOFJointState. */
        item header : Header;
        attribute jointNames : String[0..*];
        item transforms : Transform[0..*];
        item twist : Twist[0..*];
        item wrench : Wrench[0..*];
    }

    item def BatteryState {
        doc /* Battery charge, voltage, current, and health.
               Maps to sensor_msgs/msg/BatteryState.
               Power supply status, health, and technology constants
               modeled separately as enum defs. */
        item header : Header;
        attribute voltage : Real;
        attribute temperature : Real;
        attribute current : Real;
        attribute charge : Real;
        attribute capacity : Real;
        attribute designCapacity : Real;
        attribute percentage : Real;
        attribute powerSupplyStatus : Integer;
        attribute powerSupplyHealth : Integer;
        attribute powerSupplyTechnology : Integer;
        attribute present : Boolean;
        attribute cellVoltage : Real[0..*];
        attribute cellTemperature : Real[0..*];
        attribute location : String;
        attribute serialNumber : String;
    }

    item def Temperature {
        doc /* Single temperature reading. Maps to sensor_msgs/msg/Temperature. */
        item header : Header;
        attribute temperature : Real;
        attribute variance : Real;
    }

    item def FluidPressure {
        doc /* Single fluid pressure reading. Maps to sensor_msgs/msg/FluidPressure. */
        item header : Header;
        attribute fluidPressure : Real;
        attribute variance : Real;
    }

    item def RelativeHumidity {
        doc /* Relative humidity reading. Maps to sensor_msgs/msg/RelativeHumidity. */
        item header : Header;
        attribute relativeHumidity : Real;
        attribute variance : Real;
    }

    item def Illuminance {
        doc /* Illuminance (ambient light) reading. Maps to sensor_msgs/msg/Illuminance. */
        item header : Header;
        attribute illuminance : Real;
        attribute variance : Real;
    }

    // ===============================================================
    // Ranging
    // ===============================================================

    item def Range {
        doc /* Single range reading from ultrasonic or infrared sensor.
               Maps to sensor_msgs/msg/Range.
               Constants: ULTRASOUND=0, INFRARED=1. */
        item header : Header;
        attribute radiationType : Integer;
        attribute fieldOfView : Real;
        attribute minRange : Real;
        attribute maxRange : Real;
        attribute range : Real;
        attribute variance : Real;
    }

    // ===============================================================
    // Input devices
    // ===============================================================

    item def Joy {
        doc /* Joystick state: axes and buttons.
               Maps to sensor_msgs/msg/Joy. */
        item header : Header;
        attribute axes : Real[0..*];
        attribute buttons : Integer[0..*];
    }

    item def JoyFeedback {
        doc /* Joystick feedback command (LED, rumble, buzzer).
               Maps to sensor_msgs/msg/JoyFeedback.
               Constants: TYPE_LED=0, TYPE_RUMBLE=1, TYPE_BUZZER=2. */
        attribute type : Integer;
        attribute id : Integer;
        attribute intensity : Real;
    }

    item def JoyFeedbackArray {
        doc /* Array of joystick feedback commands.
               Maps to sensor_msgs/msg/JoyFeedbackArray. */
        item array : JoyFeedback[0..*];
    }
}
