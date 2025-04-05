using Godot;
using System;
using System.Net;

public partial class Level0 : Node3D
{
    public override void _Ready()
    {
        SceneSwitcher.Instance().Network.Set("network_object_spawn", this);
        SpawnClientPlayer();
    }

    public void SpawnClientPlayer()
    {
        SceneSwitcher.Instance().Network.RpcId(1, "spawn_network_object", new Vector3(0, 20, 0), Vector3.Zero, Basis.Identity, 0, Multiplayer.GetUniqueId());
        GD.Print("we are calling the RPC");
    }
}
