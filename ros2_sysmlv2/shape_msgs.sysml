package ros2_sysmlv2_shape_msgs {
    doc
    /* Geometric shape primitives for collision checking and planning.

       Maps to: shape_msgs package from ros2/common_interfaces (Jazzy).
       4 message types used by MoveIt, collision checking, and grasp planning.

       Dependency: ros2_sysmlv2_geometry_msgs (Point, Polygon). */

    private import ScalarValues::*;
    private import ros2_sysmlv2_geometry_msgs::*;

    // ===============================================================
    // Mesh types
    // ===============================================================

    item def MeshTriangle {
        doc /* A triangle defined by 3 vertex indices into a vertex array.
               Maps to shape_msgs/msg/MeshTriangle. */
        attribute vertexIndices : Integer[3];
    }

    item def Mesh {
        doc /* A triangle mesh defined by vertices and triangle indices.
               Maps to shape_msgs/msg/Mesh. */
        item triangles : MeshTriangle[0..*];
        item vertices : Point[0..*];
    }

    // ===============================================================
    // Primitive shapes
    // ===============================================================

    item def Plane {
        doc /* An infinite plane defined by ax + by + cz + d = 0.
               Maps to shape_msgs/msg/Plane.
               coef[4] = [a, b, c, d]. */
        attribute coef : Real[4];
    }

    item def SolidPrimitive {
        doc /* A solid geometric primitive (box, sphere, cylinder, cone, prism).
               Maps to shape_msgs/msg/SolidPrimitive.
               Type discriminator selects the shape; dimensions array
               holds shape-specific parameters. */
        attribute primitiveType : Integer;
        attribute dimensions : Real[0..3];
        item polygon : Polygon;
    }
}
