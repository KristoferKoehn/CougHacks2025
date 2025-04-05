using Godot;

public partial class RigidBody3d : RigidBody3D
{
    [Export]
    public int multiplayerID = 1;

    public override void _EnterTree()
    {
        SetMultiplayerAuthority(int.Parse(Name));
        GlobalPosition = new Vector3(0, 40, 0);
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
            if (IsMultiplayerAuthority())
            {
                SceneSwitcher.Instance().Network.Call("rpc_id", 1, "spawn_network_object", GlobalPosition, new Vector3(0, 10, 0), Basis.Identity, 1, 1);
            }
            
        }
    }
}
