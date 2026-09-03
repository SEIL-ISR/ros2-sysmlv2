package ros2_sysmlv2_visualization_msgs {
    doc
    /* Visualization message types for RViz display.

       Maps to: visualization_msgs package from ros2/common_interfaces (Jazzy).
       4 core message types (Marker, MarkerArray, MeshFile, UVCoordinate).
       Interactive marker types (7 additional) are omitted in alpha:
       they are RViz-specific and not architecturally relevant.

       Dependency: ros2_sysmlv2_foundation (Header, Duration),
                   ros2_sysmlv2_geometry_msgs (Pose, Vector3, Point),
                   ros2_sysmlv2_std_msgs (ColorRGBA),
                   ros2_sysmlv2_sensor_msgs (CompressedImage). */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;
    private import ros2_sysmlv2_geometry_msgs::*;
    private import ros2_sysmlv2_std_msgs::*;
    private import ros2_sysmlv2_sensor_msgs::*;

    // ===============================================================
    // Supporting types
    // ===============================================================

    item def UVCoordinate {
        doc /* UV texture coordinate.
               Maps to visualization_msgs/msg/UVCoordinate. */
        attribute u : Real;
        attribute v : Real;
    }

    item def MeshFile {
        doc /* A mesh loaded from a file (e.g., STL, DAE).
               Maps to visualization_msgs/msg/MeshFile. */
        attribute filename : String;
        attribute data : Integer[0..*];
    }

    // ===============================================================
    // Marker types
    // ===============================================================

    item def Marker {
        doc /* A visual marker for display in RViz.
               Maps to visualization_msgs/msg/Marker.
               Supports 13 shape types (ARROW through ARROW_STRIP)
               and 4 action types (ADD, MODIFY, DELETE, DELETEALL). */
        item header : Header;
        attribute ns : String;
        attribute markerId : Integer;
        attribute markerType : Integer;
        attribute markerAction : Integer;
        item pose : Pose;
        item scale : Vector3;
        item color : ColorRGBA;
        item lifetime : Duration;
        attribute frameLocked : Boolean;
        item points : Point[0..*];
        item colors : ColorRGBA[0..*];
        attribute textureResource : String;
        item texture : CompressedImage;
        item uvCoordinates : UVCoordinate[0..*];
        attribute text : String;
        attribute meshResource : String;
        item meshFile : MeshFile;
        attribute meshUseEmbeddedMaterials : Boolean;
    }

    item def MarkerArray {
        doc /* An array of markers for batch display in RViz.
               Maps to visualization_msgs/msg/MarkerArray. */
        item markers : Marker[0..*];
    }
}
