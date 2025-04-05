using Godot;
using System;

public partial class Level0 : Node3D
{
    public override void _Ready()
    {
        Multiplayer.ConnectedToServer += SpawnClientPlayer;
    }

    public void SpawnClientPlayer()
    {
        Multiplayer.ConnectedToServer -= SpawnClientPlayer;
        SceneSwitcher.Instance().Network.RpcId(1, "spawn_network_object", new Vector3(0, 20, 0), Vector3.Zero, Basis.Identity, 0, Multiplayer.GetUniqueId());
        GD.Print("we are calling the RPC");
    }
}
