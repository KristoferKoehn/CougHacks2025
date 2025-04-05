using Godot;
using System.Reflection.Metadata.Ecma335;
using System.Xml.Schema;

public partial class CollisionBlock : AnimatableBody3D
{
    Node3D target = null;

    public override void _Ready()
    {
        
    }

    public override void _Process(double delta)
    {
        if (target == null)
        {
            GD.Print("Deleting collision block");
            QueueFree();
        }

        
        Vector3 v1 = GlobalPosition + new Vector3(1f, 0, 1f);
        v1 = new Vector3(v1.X, SurfaceManager.Instance().QueryHeight(v1), v1.Z);
        Vector3 v2 = GlobalPosition + new Vector3(-1f, 0, 1f);
        v2 = new Vector3(v2.X, SurfaceManager.Instance().QueryHeight(v2), v2.Z);
        Vector3 v3 = GlobalPosition + new Vector3(1f, 0, -1f);
        v3 = new Vector3(v3.X, SurfaceManager.Instance().QueryHeight(v3), v3.Z);

        Vector3 v = GetNormal(v1, v2, v3);
        //GetNode<CollisionShape3D>("CollisionShape3D").GlobalRotation = GetPitchRollEulerFromNormal(v);
        GetNode<CollisionShape3D>("CollisionShape3D").GlobalRotation = GetPitchRollEulerFromNormal(v);
        GlobalPosition = new Vector3(target.GlobalPosition.X, SurfaceManager.Instance().QueryHeight(target.GlobalPosition), target.GlobalPosition.Z);
        
    }

    public void SubscribeObject(Node3D n)
    {
        n.TreeExiting += QueueFree;
        target = n;
    }

    Vector3 GetNormal(Vector3 a, Vector3 b, Vector3 c)
    {
        Vector3 ab = b - a;
        Vector3 ac = c - a;
        Vector3 normal = (ab.Cross(ac)).Normalized();
        return normal;
    }

    public static Vector3 GetPitchRollEulerFromNormal(Vector3 normal)
    {
        normal = normal.Normalized();

        // Pitch: angle between Up and normal in X direction
        float pitch = Mathf.Atan2(-normal.X, normal.Y); // rotation around X

        // Roll: angle between Up and normal in Z direction
        float roll = Mathf.Atan2(normal.Z, normal.Y);   // rotation around Z

        return new Vector3(roll, 0f, -pitch); // in radians
    }

}
