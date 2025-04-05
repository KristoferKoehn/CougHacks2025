using Godot;
using System;

public partial class RigidBody3d : RigidBody3D
{
    public override void _Ready()
    {
        //SurfaceManager.Instance().CollisionBuildSubscribers.Add(this);
        SurfaceManager.Instance().SubscribeCollisionObject(this);
        GD.Print("spawning test guy");
    }
}
