using Godot;

public partial class RigidBody3d : RigidBody3D
{

    public int multiplayerID = 1;

    public override void _Ready()
    {
        this.SetMultiplayerAuthority(multiplayerID);
        //SurfaceManager.Instance().CollisionBuildSubscribers.Add(this);
        SurfaceManager.Instance().SubscribeCollisionObject(this);
        GD.Print("spawning test guy");
    }
}
