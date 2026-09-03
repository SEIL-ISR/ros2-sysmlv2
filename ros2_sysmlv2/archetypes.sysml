package ros2_sysmlv2_archetypes {
    doc
    /* Abstract node archetypes for common ROS2 architectural patterns.

       Each archetype captures a recurring communication pattern observed
       across multiple ROS2 nodes. They are abstract. Users specialize
       them with concrete message types and topic names.

       Archetypes grounded against Nav2 Jazzy source:
         - Planner: PlannerServer, SmootherServer
         - Controller: ControllerServer
         - BehaviorCoordinator: BtNavigator
         - Estimator: AmclNode
         - MapProvider: MapServer
         - VelocityFilter: VelocitySmoother, CollisionMonitor

       Pattern-based archetypes (standard ROS2 patterns, no single
       source file as ground truth):
         - SensorDriver: IMU/LiDAR/camera driver nodes
         - PerceptionPipeline: object detection, point cloud processing

       Dependency: ros2_sysmlv2_lifecycle, ros2_sysmlv2_comm,
                   ros2_sysmlv2_tf2. */

    private import ScalarValues::*;
    private import ros2_sysmlv2_comm::*;
    private import ros2_sysmlv2_lifecycle::*;
    private import ros2_sysmlv2_tf2::*;

    // ===============================================================
    // 1. SensorDriver: publishes sensor data at a fixed rate
    //    Pattern-based: every robot has sensor driver nodes.
    //    Examples: IMU driver, LiDAR driver, camera driver.
    // ===============================================================

    abstract part def SensorDriver :> LifecycleNode {
        doc /* Abstract sensor driver node.
               Publishes sensor readings at a fixed update rate.
               The sensor data port must be redefined with a concrete
               message type in specializations.

               Pattern: single publisher, no subscribers.
               Lifecycle: configure loads driver, activate starts publishing.

               Usage:
                 part def MyImuDriver :> SensorDriver {
                     :>> updateRateHz = 400.0;
                     :>> frameId = "imu_link";
                     port :>> sensorPub : TopicPublisher {
                         :>> topicName = "/imu/data";
                         out item :>> msg : Imu;
                     }
                 } */

        attribute updateRateHz : Real;
        attribute frameId : String;
        port sensorPub : TopicPublisher;
    }

    // ===============================================================
    // 2. Controller: follows a reference trajectory, publishes commands
    //    Grounded: nav2_controller/ControllerServer
    //      - ActionServer(follow_path), pub cmd_vel, sub odom
    // ===============================================================

    abstract part def Controller :> LifecycleNode {
        doc /* Abstract motion controller node.
               Receives a reference to follow (path, trajectory, velocity),
               subscribes to state feedback (odometry), and publishes
               actuator commands (velocity, effort).

               Pattern: action server + pub commands + sub state.
               Grounded against: nav2_controller/ControllerServer.

               Usage:
                 part def MyController :> Controller {
                     :>> controlFrequencyHz = 20.0;
                     port :>> commandPub : TopicPublisher {
                         :>> topicName = "/cmd_vel";
                         out item :>> msg : Twist;
                     }
                 } */

        attribute controlFrequencyHz : Real;
        port commandPub : TopicPublisher;
        port stateSub : TopicSubscriber;
        port controlAction : ActionServer;
    }

    // ===============================================================
    // 3. Planner: computes a plan on request, publishes the result
    //    Grounded: nav2_planner/PlannerServer
    //      - ActionServer(compute_path_to_pose), pub plan
    //    Also: nav2_smoother/SmootherServer (smooth_path variant)
    // ===============================================================

    abstract part def Planner :> LifecycleNode {
        doc /* Abstract planning node.
               Receives a planning request (goal pose, constraints) via
               an action server and publishes the computed plan.

               Pattern: action server + pub plan result.
               Grounded against: nav2_planner/PlannerServer
               (compute_path_to_pose action, plan topic publisher).

               Usage:
                 part def MyPlanner :> Planner {
                     port :>> planAction : ActionServer {
                         :>> actionName = "compute_path_to_pose";
                     }
                 } */

        port planAction : ActionServer;
        port planPub : TopicPublisher;
    }

    // ===============================================================
    // 4. Estimator: fuses sensor data, publishes pose + TF
    //    Grounded: nav2_amcl/AmclNode
    //      - pub amcl_pose, sub scan, sub map, TF broadcaster
    //    Also: robot_localization EKF/UKF nodes (same pattern)
    // ===============================================================

    abstract part def Estimator :> LifecycleNode {
        doc /* Abstract state estimation / localization node.
               Subscribes to sensor data and publishes pose estimates
               and coordinate frame transforms.

               Pattern: multi-sub sensors + pub pose + TF broadcast.
               Grounded against: nav2_amcl/AmclNode (amcl_pose publisher,
               scan subscriber, map subscriber, map->odom TF broadcast).

               Usage:
                 part def MyLocalizer :> Estimator {
                     port :>> posePub : TopicPublisher {
                         :>> topicName = "/amcl_pose";
                         out item :>> msg : PoseWithCovarianceStamped;
                     }
                 } */

        port posePub : TopicPublisher;
        port sensorSub : TopicSubscriber;
    }

    // ===============================================================
    // 5. BehaviorCoordinator: orchestrates via action clients
    //    Grounded: nav2_bt_navigator/BtNavigator
    //      - ActionServer(navigate_to_pose), action clients to
    //        planner, controller, behaviors, smoother
    // ===============================================================

    abstract part def BehaviorCoordinator :> LifecycleNode {
        doc /* Abstract behavior coordination node.
               Receives high-level goals and orchestrates other nodes
               via action clients. May use a behavior tree, finite
               state machine, or custom orchestration logic internally.

               Pattern: action server (goal input) + action clients (delegated work).
               Grounded against: nav2_bt_navigator/BtNavigator
               (NavigateToPose action server, action clients to planner/
               controller/behaviors).

               BT internals are NOT modeled. Behavior tree node
               composition is deferred to a future behavior-trees-sysmlv2
               package.

               Usage:
                 part def MyNavigator :> BehaviorCoordinator {
                     port :>> goalAction : ActionServer {
                         :>> actionName = "navigate_to_pose";
                     }
                 } */

        port goalAction : ActionServer;
        attribute btXml : String;
    }

    // ===============================================================
    // 6. MapProvider: publishes map data, serves map requests
    //    Grounded: nav2_map_server/MapServer
    //      - pub map, service load_map, service get_map
    // ===============================================================

    abstract part def MapProvider :> LifecycleNode {
        doc /* Abstract map serving node.
               Publishes occupancy grid or other map representations.
               Provides services for loading and retrieving maps.

               Pattern: pub map + service endpoints.
               Grounded against: nav2_map_server/MapServer
               (map publisher, load_map and get_map services).

               Usage:
                 part def MyMapServer :> MapProvider {
                     port :>> mapPub : TopicPublisher {
                         :>> topicName = "/map";
                     }
                 } */

        port mapPub : TopicPublisher;
        port mapService : ServiceServer;
    }

    // ===============================================================
    // 7. PerceptionPipeline: processes raw sensor data
    //    Pattern-based: obstacle detection, point cloud filtering,
    //    object recognition. No single Nav2 node as exemplar.
    // ===============================================================

    abstract part def PerceptionPipeline :> LifecycleNode {
        doc /* Abstract perception processing node.
               Subscribes to raw sensor data and publishes processed
               detections, filtered point clouds, or semantic labels.

               Pattern: sub raw sensor + pub processed output.
               Pattern-based: Isaac ROS perception nodes, PCL pipelines,
               obstacle detection nodes.

               Usage:
                 part def MyObjectDetector :> PerceptionPipeline {
                     port :>> rawSub : TopicSubscriber {
                         :>> topicName = "/camera/image_raw";
                     }
                     port :>> processedPub : TopicPublisher {
                         :>> topicName = "/detections";
                     }
                 } */

        port rawSub : TopicSubscriber;
        port processedPub : TopicPublisher;
    }

    // ===============================================================
    // 8. VelocityFilter: filters velocity commands (safety/smoothing)
    //    Grounded: nav2_velocity_smoother/VelocitySmoother,
    //              nav2_collision_monitor/CollisionMonitor
    //      - sub cmd_vel_in, pub cmd_vel_out
    // ===============================================================

    abstract part def VelocityFilter :> LifecycleNode {
        doc /* Abstract velocity filtering node.
               Subscribes to raw velocity commands and publishes
               filtered/smoothed/safety-checked commands.

               Pattern: sub cmd_vel in + pub cmd_vel out.
               Grounded against: nav2_velocity_smoother/VelocitySmoother
               (cmd_vel -> cmd_vel_smoothed) and nav2_collision_monitor/
               CollisionMonitor (cmd_vel_in -> cmd_vel_out with safety).

               Usage:
                 part def MySafetyStopper :> VelocityFilter {
                     port :>> cmdVelIn : TopicSubscriber {
                         :>> topicName = "/cmd_vel";
                     }
                     port :>> cmdVelOut : TopicPublisher {
                         :>> topicName = "/cmd_vel_safe";
                     }
                 } */

        port cmdVelIn : TopicSubscriber;
        port cmdVelOut : TopicPublisher;
    }
}
