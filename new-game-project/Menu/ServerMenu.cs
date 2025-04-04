using Godot;
using System;

public partial class ServerMenu : Node3D
{
    [Export] VBoxContainer Container { get; set; }

    public override void _Ready()
    {
        SceneSwitcher.Instance().Network.Set("lobby_list_container", Container);
        SceneSwitcher.Instance().Network.Call("_open_lobby_list");
    }

    public void RefreshButtonPressed()
    {
        SceneSwitcher.Instance().Network.Call("_open_lobby_list");
    }

    public void OnHostPressed()
    {
        SceneSwitcher.Instance().Network.Call("_on_host_pressed");
    }
}
