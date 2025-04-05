using Godot;

public partial class RigidBody3d : RigidBody3D
{

    public int multiplayerID = 1;

    public override void _EnterTree()
    {
        GetNode<MultiplayerSynchronizer>("MultiplayerSynchronizer").SetMultiplayerAuthority(multiplayerID);
    }

    public override void _Ready()
    {
        //SurfaceManager.Instance().CollisionBuildSubscribers.Add(this);
        SurfaceManager.Instance().SubscribeCollisionObject(this);
        GD.Print("spawning test guy " + GetMultiplayerAuthority());

    }

    public override void _Process(double delta)
    {
        if (Input.IsActionJustPressed("jump"))
        {
            SceneSwitcher.Instance().Network.Call("rpc_ping_handle", "frick");
        }
    }
}
