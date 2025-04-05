using Godot;
using System.Collections.Generic;

public partial class SceneSwitcher : Node
{

    public Stack<Node3D> SceneStack = new Stack<Node3D>();
    public static Window root;
    private static SceneSwitcher instance = null;
    public static Node3D CurrentLevel = null;
    public Node Network { get; private set; }

    public Godot.Collections.Dictionary<int, PackedScene> NetworkSceneDict = new() {
        { 0, GD.Load<PackedScene>("res://Menu/ServerMenu.tscn")},
        { 1, GD.Load<PackedScene>("res://Levels/Level0.tscn")},
        { 2, GD.Load<PackedScene>("res://Levels/desert.tscn")},
    };

    public Godot.Collections.Dictionary<int, PackedScene> NetworkObjectDict = new() {
        { 0, GD.Load<PackedScene>("res://GameObjects/TestingObjects/Player_Test.tscn")},
        { 1, GD.Load<PackedScene>("res://GameObjects/TestingObjects/Bullet_Test.tscn")},
    };

    public override void _Ready()
    {
        root = GetTree().Root;
        instance = this;
        Network = GetTree().Root.GetNode<Node>("/root/Network");
        //PushScene("res://Main.tscn");
        PushScene(NetworkSceneDict[0]);
        SurfaceMeshManager.Instance();
        Network.Set("scene_dictionary", NetworkSceneDict);
        Network.Set("object_dictionary", NetworkObjectDict);
        Network.Set("network_object_spawn", GetNode<Node3D>("MultiplayerSpawnNode"));
        GD.Print($"ATTACHING SPAWNER NODE: {GetNode<Node3D>("MultiplayerSpawnNode")}");
        Callable c = new Callable(this, MethodName.NetworkSceneChange);
        Network.Connect("scene_change", c);
    }

    public static SceneSwitcher Instance()
    {
        return instance;
    }

    public void PushScene(PackedScene Scene) // used to move to another scene
    {
        Node previousScene = null;
        if (SceneStack.Count > 0)
        {
            previousScene = SceneStack.Peek();
            RemoveChild(previousScene);
        }
        Node3D scene = Scene.Instantiate<Node3D>();

        CurrentLevel = scene;
        SceneStack.Push(scene);
        AddChild(scene);
    }

    public void NetworkSceneChange(int scene_id)
    {
        GD.Print("scene change: " + NetworkSceneDict[scene_id].ResourceName);
        PushScene(NetworkSceneDict[scene_id]);
    }

    public void PopScene() // used to go back to the previous scene (gets rid of the current scene forever).
    {
        if (SceneStack.Count == 0)
        {
            return;
        }

        Node node = SceneStack.Pop();

        if (node.GetParent() == this)
        {
            this.RemoveChild(node);
            node.QueueFree();
        }

        if (SceneStack.Count > 0)
        {
            Node previousScene = SceneStack.Peek();
            if (previousScene.GetParent() != this)
            {
                this.AddChild(previousScene);
            }
        }
    }
}