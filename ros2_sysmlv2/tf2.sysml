library package ros2_sysmlv2_tf2 {
    doc
    /* ROS2 TF2 coordinate frame system: frames, transforms, and REP 105.

       Models the TF2 transform framework that maintains the geometric
       relationship between coordinate frames in a robot system. Frames
       form a tree connected by static and dynamic transforms, published
       on /tf_static and /tf topics respectively.

       The message type TransformStamped (header, childFrameId, transform)
       is already modeled in ros2_sysmlv2_geometry_msgs. This package
       provides the frame and transform tree architecture on top of it.

       Ground truth sources:
         - REP 105 (https://www.ros.org/reps/rep-0105.html):
           standard frame names (map, odom, base_link)
         - tf2_ros: /tf and /tf_static topic conventions
         - geometry_msgs/msg/TransformStamped.msg (already modeled)

       Dependency: ros2_sysmlv2_foundation, ros2_sysmlv2_geometry_msgs,
                   ros2_sysmlv2_comm. */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;
    private import ros2_sysmlv2_geometry_msgs::*;
    private import ros2_sysmlv2_comm::*;

    // ===============================================================
    // Coordinate frame definition
    // ===============================================================

    part def CoordinateFrame {
        doc /* A named coordinate frame in the TF2 tree.
               Each frame has a unique string identifier (frameId) that
               matches the frame_id / child_frame_id fields in
               TransformStamped messages.

               Usage:
                 part cameraFrame : CoordinateFrame {
                     :>> frameId = "camera_link";
                 } */

        attribute frameId : String;
    }

    // ===============================================================
    // Transform connection definitions
    // A transform connects a parent frame to a child frame.
    // Static transforms are published once (latched); dynamic transforms
    // are published continuously at a variable rate.
    // ===============================================================

    connection def StaticTransform {
        doc /* A fixed geometric relationship between two frames.
               Published once on /tf_static with TransientLocal durability.
               Does not change over time (e.g., sensor mount offsets).

               Maps to tf2_ros.StaticTransformBroadcaster.
               The transform attribute holds the concrete geometric offset.

               Usage:
                 connection : StaticTransform
                     connect baseLink to cameraFrame {
                         :>> transform { ... }
                     } */

        end parent : CoordinateFrame;
        end child : CoordinateFrame;
        item transform : TransformStamped;
    }

    connection def DynamicTransform {
        doc /* A time-varying geometric relationship between two frames.
               Published continuously on /tf at variable rates.
               Changes as the robot moves (e.g., odometry, localization).

               Maps to tf2_ros.TransformBroadcaster.

               Usage:
                 connection : DynamicTransform
                     connect odomFrame to baseLinkFrame; */

        end parent : CoordinateFrame;
        end child : CoordinateFrame;
    }

    // ===============================================================
    // REP 105 standard coordinate frames
    // Source: https://www.ros.org/reps/rep-0105.html
    //
    // REP 105 defines the minimum set of coordinate frames that every
    // mobile robot should provide for interoperability with the ROS
    // navigation stack (Nav2, AMCL, robot_localization, etc.).
    // ===============================================================

    part def MapFrame :> CoordinateFrame {
        doc /* Global fixed frame (REP 105: "map").
               World-fixed, z-up. The long-term global reference.
               Discontinuous: may jump when localization corrects.
               Typically published by AMCL or a global localizer. */

        :>> frameId = "map";
    }

    part def OdomFrame :> CoordinateFrame {
        doc /* Odometry frame (REP 105: "odom").
               World-fixed, continuous but drifts over time.
               Guaranteed smooth (no jumps) but accumulates error.
               Typically published by wheel odometry or visual odometry. */

        :>> frameId = "odom";
    }

    part def BaseLinkFrame :> CoordinateFrame {
        doc /* Robot body frame (REP 105: "base_link").
               Rigidly attached to the mobile robot base.
               Origin typically at the robot's rotational center.
               All sensors and actuators have static transforms to this frame. */

        :>> frameId = "base_link";
    }

    // ===============================================================
    // Standard frame tree (REP 105 canonical chain)
    // map -> odom -> base_link
    //
    // This is the minimum frame tree that every mobile robot should
    // provide. Additional sensor frames (camera_link, lidar_link, etc.)
    // connect to base_link via static transforms.
    // ===============================================================

    part def StandardFrameTree {
        doc /* REP 105 canonical coordinate frame tree.
               Composes the three standard frames with their transform
               connections:
                 map --(dynamic)--> odom --(dynamic)--> base_link

               Both transforms are dynamic because:
                 - map->odom: updated by global localizer (AMCL)
                 - odom->base_link: updated by odometry source

               Usage:
                 part def MyRobot {
                     part frames : StandardFrameTree;
                     // Add sensor frames connected to base_link
                 } */

        part mapFrame : MapFrame;
        part odomFrame : OdomFrame;
        part baseLinkFrame : BaseLinkFrame;

        connection mapToOdom : DynamicTransform
            connect mapFrame to odomFrame;

        connection odomToBaseLink : DynamicTransform
            connect odomFrame to baseLinkFrame;
    }
}
