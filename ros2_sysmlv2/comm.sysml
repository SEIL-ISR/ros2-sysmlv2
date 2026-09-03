package ros2_sysmlv2_comm {
    doc
    /* ROS2 communication patterns, QoS policies, and connection types.

       Defines how nodes interact: topic publish/subscribe, service
       request/response, and action goal/feedback/result patterns.
       Includes QoS policy enums, QoS profile attribute with all 9 fields,
       7 preset profiles matching rmw/qos_profiles.h, and connection
       definitions for wiring nodes together.

       Ground truth sources:
         - QoS enums: rclpy/qos.py (ReliabilityPolicy, DurabilityPolicy,
           HistoryPolicy, LivelinessPolicy)
         - QoS profile fields: rclpy/qos.py QoSProfile.__slots__ (9 fields)
         - Preset profiles: rmw/include/rmw/qos_profiles.h
         - Port patterns: rclpy/node.py (create_publisher, create_subscription,
           create_service, create_client) and rclpy/action/ (ActionServer,
           ActionClient)

       Dependency: ros2_sysmlv2_foundation (Time, Duration). */

    private import ScalarValues::*;
    private import ros2_sysmlv2_foundation::*;

    // ===============================================================
    // Abstract base item for typed port messages
    // ===============================================================

    abstract item def Message {
        doc /* Abstract base for all ROS2 message types used in ports.
               Users redefine the message item with a concrete type:
                 port myPub : TopicPublisher {
                     out item :>> msg : LaserScan;
                 }
               All item defs in geometry_msgs, sensor_msgs, nav_msgs
               can be used as the concrete message type. */
    }

    // ===============================================================
    // QoS policy enums
    // Source: rclpy/qos.py, matches rmw/types.h
    // ===============================================================

    enum def ReliabilityKind {
        doc /* QoS reliability policy.
               Maps to rclpy.qos.ReliabilityPolicy / rmw_qos_reliability_policy_t. */
        enum SystemDefault;
        enum Reliable;
        enum BestEffort;
        enum Unknown;
        enum BestAvailable;
    }

    enum def DurabilityKind {
        doc /* QoS durability policy.
               Maps to rclpy.qos.DurabilityPolicy / rmw_qos_durability_policy_t. */
        enum SystemDefault;
        enum TransientLocal;
        enum Volatile;
        enum Unknown;
        enum BestAvailable;
    }

    enum def HistoryKind {
        doc /* QoS history policy.
               Maps to rclpy.qos.HistoryPolicy / rmw_qos_history_policy_t. */
        enum SystemDefault;
        enum KeepLast;
        enum KeepAll;
        enum Unknown;
    }

    enum def LivelinessKind {
        doc /* QoS liveliness policy.
               Maps to rclpy.qos.LivelinessPolicy / rmw_qos_liveliness_policy_t. */
        enum SystemDefault;
        enum Automatic;
        enum ManualByTopic;
        enum Unknown;
        enum BestAvailable;
    }

    // ===============================================================
    // QoS profile attribute definition
    // Source: rclpy/qos.py QoSProfile.__slots__ (9 fields)
    // ===============================================================

    attribute def QoSProfile {
        doc /* Quality of Service profile for a communication endpoint.
               Maps to rclpy.qos.QoSProfile / rmw_qos_profile_t.
               All 9 fields from QoSProfile.__slots__.

               Modeling note: QoSProfile is `attribute def` (referential) because
               it is used as `attribute qos : QoSProfile` inside port defs, and
               OMG SysML v2.0 §7.12.2 requires non-port features of a port def
               to be referential. By §7.6.1 + §7.7.2 this forces QoSProfile's
               own nested features to also be referential. The rmw_time_t-typed
               fields (lifespan, deadline, livelinessLeaseDuration) are therefore
               declared as `ref item ... : Duration`: the `ref` keyword (§7.6.3)
               makes the item usage referential, satisfying §7.6.1 while
               preserving the structured Duration type from foundation.sysml.
               The full rule chain rests on the OMG SysML v2 spec,
               sections 7.6.1, 7.6.3, 7.7.2, 7.10.2 and 7.12.2. */
        attribute history : HistoryKind;
        attribute depth : Integer;
        attribute reliability : ReliabilityKind;
        attribute durability : DurabilityKind;
        ref item lifespan : Duration;
        ref item deadline : Duration;
        attribute liveliness : LivelinessKind;
        ref item livelinessLeaseDuration : Duration;
        attribute avoidRosNamespaceConventions : Boolean;
    }

    // ===============================================================
    // Preset QoS profiles
    // Source: rmw/include/rmw/qos_profiles.h
    // ===============================================================

    attribute sensorDataQoS : QoSProfile {
        doc /* For sensor data streams (LiDAR, IMU, camera).
               Maps to rmw_qos_profile_sensor_data. */
        :>> history = HistoryKind::KeepLast;
        :>> depth = 5;
        :>> reliability = ReliabilityKind::BestEffort;
        :>> durability = DurabilityKind::Volatile;
        :>> liveliness = LivelinessKind::SystemDefault;
        :>> avoidRosNamespaceConventions = false;
    }

    attribute defaultQoS : QoSProfile {
        doc /* General purpose default profile.
               Maps to rmw_qos_profile_default. */
        :>> history = HistoryKind::KeepLast;
        :>> depth = 10;
        :>> reliability = ReliabilityKind::Reliable;
        :>> durability = DurabilityKind::Volatile;
        :>> liveliness = LivelinessKind::SystemDefault;
        :>> avoidRosNamespaceConventions = false;
    }

    attribute servicesDefaultQoS : QoSProfile {
        doc /* For services (request/response).
               Maps to rmw_qos_profile_services_default. */
        :>> history = HistoryKind::KeepLast;
        :>> depth = 10;
        :>> reliability = ReliabilityKind::Reliable;
        :>> durability = DurabilityKind::Volatile;
        :>> liveliness = LivelinessKind::SystemDefault;
        :>> avoidRosNamespaceConventions = false;
    }

    attribute parametersQoS : QoSProfile {
        doc /* For parameter operations. Larger queue to avoid lost requests.
               Maps to rmw_qos_profile_parameters. */
        :>> history = HistoryKind::KeepLast;
        :>> depth = 1000;
        :>> reliability = ReliabilityKind::Reliable;
        :>> durability = DurabilityKind::Volatile;
        :>> liveliness = LivelinessKind::SystemDefault;
        :>> avoidRosNamespaceConventions = false;
    }

    attribute parameterEventsQoS : QoSProfile {
        doc /* For parameter change events. Same as parameters profile.
               Maps to rmw_qos_profile_parameter_events. */
        :>> history = HistoryKind::KeepLast;
        :>> depth = 1000;
        :>> reliability = ReliabilityKind::Reliable;
        :>> durability = DurabilityKind::Volatile;
        :>> liveliness = LivelinessKind::SystemDefault;
        :>> avoidRosNamespaceConventions = false;
    }

    attribute systemDefaultQoS : QoSProfile {
        doc /* All policies deferred to DDS vendor defaults.
               Maps to rmw_qos_profile_system_default. */
        :>> history = HistoryKind::SystemDefault;
        :>> depth = 0;
        :>> reliability = ReliabilityKind::SystemDefault;
        :>> durability = DurabilityKind::SystemDefault;
        :>> liveliness = LivelinessKind::SystemDefault;
        :>> avoidRosNamespaceConventions = false;
    }

    attribute bestAvailableQoS : QoSProfile {
        doc /* Match majority of endpoints while maintaining highest service level.
               Policies chosen at subscription/publisher creation time.
               Maps to rmw_qos_profile_best_available. */
        :>> history = HistoryKind::KeepLast;
        :>> depth = 10;
        :>> reliability = ReliabilityKind::BestAvailable;
        :>> durability = DurabilityKind::BestAvailable;
        :>> liveliness = LivelinessKind::BestAvailable;
        :>> avoidRosNamespaceConventions = false;
    }

    attribute transientLocalQoS : QoSProfile {
        doc /* Latched-topic profile: late joiners receive the last sample.
               NOT an rmw named profile; this is the map-topic profile
               hardcoded across Nav2 Jazzy:
               rclcpp::QoS(rclcpp::KeepLast(1)).transient_local().reliable()
               - publisher: nav2_map_server/src/map_server/map_server.cpp:118
               - subscriber: nav2_amcl/src/amcl_node.cpp:1394,1563
               - subscriber: nav2_costmap_2d/plugins/static_layer.cpp:78-97
                 (via map_subscribe_transient_local, default true)
               Observed against a running nav2_map_server: a modeled
               /map publisher declaring volatile durability does not
               match the live publisher, which latches. */
        :>> history = HistoryKind::KeepLast;
        :>> depth = 1;
        :>> reliability = ReliabilityKind::Reliable;
        :>> durability = DurabilityKind::TransientLocal;
        :>> liveliness = LivelinessKind::SystemDefault;
        :>> avoidRosNamespaceConventions = false;
    }

    // ===============================================================
    // Topic publish/subscribe port definitions
    // Source: rclpy/node.py create_publisher(), create_subscription()
    // ===============================================================

    port def TopicPublisher {
        doc /* A topic publisher endpoint.
               Maps to rclpy Node.create_publisher(msg_type, topic, qos_profile).
               Users redefine 'message' to set the concrete type:
                 port myPub : TopicPublisher {
                     :>> topicName = "/scan";
                     :>> qos = sensorDataQoS;
                     out item :>> msg : LaserScan;
                 } */
        attribute topicName : String;
        attribute qos : QoSProfile;
        out item msg : Message;
    }

    port def TopicSubscriber {
        doc /* A topic subscriber endpoint.
               Maps to rclpy Node.create_subscription(msg_type, topic, callback, qos_profile).
               Users redefine 'message' to set the concrete type. */
        attribute topicName : String;
        attribute qos : QoSProfile;
        in item msg : Message;
    }

    // ===============================================================
    // Service request/response port definitions
    // Source: rclpy/node.py create_service(), create_client()
    // ===============================================================

    port def ServiceServer {
        doc /* A service server endpoint.
               Maps to rclpy Node.create_service(srv_type, srv_name, callback).
               One server per service name. Users redefine request/response items. */
        attribute serviceName : String;
        in item request : Message;
        out item response : Message;
    }

    port def ServiceClient {
        doc /* A service client endpoint.
               Maps to rclpy Node.create_client(srv_type, srv_name).
               Multiple clients allowed per service name. */
        attribute serviceName : String;
        out item request : Message;
        in item response : Message;
    }

    // ===============================================================
    // Action goal/feedback/result port definitions
    // Source: rclpy/action/server.py ActionServer, rclpy/action/client.py ActionClient
    // ===============================================================

    port def ActionServer {
        doc /* An action server endpoint for long-running operations.
               Maps to rclpy ActionServer(node, action_type, action_name).
               Internally composed of 3 services + 2 topics.
               Users redefine goal/feedback/result items. */
        attribute actionName : String;
        in item goal : Message;
        out item feedback : Message;
        out item result : Message;
    }

    port def ActionClient {
        doc /* An action client endpoint.
               Maps to rclpy ActionClient(node, action_type, action_name).
               Sends goals, receives feedback and results. */
        attribute actionName : String;
        out item goal : Message;
        in item feedback : Message;
        in item result : Message;
    }

    // ===============================================================
    // Connection definitions (wiring between ports)
    // ===============================================================

    connection def TopicConnection {
        doc /* Wires a topic publisher to a subscriber on the same topic.
               The connection implies same topic name and compatible message type. */
        end pub : TopicPublisher;
        end sub : TopicSubscriber;
    }

    connection def ServiceBinding {
        doc /* Binds a service client to a service server.
               Implies same service name and compatible srv type. */
        end server : ServiceServer;
        end client : ServiceClient;
    }

    connection def ActionBinding {
        doc /* Binds an action client to an action server.
               Implies same action name and compatible action type. */
        end server : ActionServer;
        end client : ActionClient;
    }

    // ===============================================================
    // QoS compatibility constraint
    // Source: rmw/qos_profiles.h rmw_qos_profile_check_compatible()
    // ===============================================================

    constraint def QoSCompatible {
        doc /* Checks QoS compatibility between a publisher and subscriber.
               Rules from rmw_qos_profile_check_compatible():
                 - Reliable pub + BestEffort sub = compatible
                 - BestEffort pub + Reliable sub = INCOMPATIBLE
                 - TransientLocal pub + Volatile sub = compatible
                 - Volatile pub + TransientLocal sub = INCOMPATIBLE
               Maps to rmw_qos_compatibility_type_t. */
        in pubQoS : QoSProfile;
        in subQoS : QoSProfile;
    }
}
