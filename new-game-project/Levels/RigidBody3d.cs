using Godot;

public partial class RigidBody3d : RigidBody3D
{

    public int multiplayerID = 1;

    public override void _EnterTree()
    {
        SetMultiplayerAuthority(multiplayerID);
    }

    public override void _Ready()
    {
        
        //SurfaceManager.Instance().CollisionBuildSubscribers.Add(this);
        SurfaceManager.Instance().SubscribeCollisionObject(this);
        GD.Print("spawning test guy");
    }
}
