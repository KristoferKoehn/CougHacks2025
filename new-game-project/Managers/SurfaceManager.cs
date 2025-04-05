using Godot;
using Godot.Collections;
using System;

public partial class SurfaceManager : Node
{

    private static SurfaceManager instance = null;

    //start surface parameterization:
    [Export] public float Plane_Radius = 4000.0f;
    [Export] public float Noise_Scale = 10f;
    [Export] public float Time_Scale = 0.2f;
    [Export] public float Seed = 20f;
    [Export] public Vector2 SubdivisionSize = new Vector2(1024, 1024);

    public PackedScene CollisionBlockScene = GD.Load<PackedScene>("res://GameObjects/CollisionBlock/CollisionBlock.tscn");

    public Array<Node3D> CollisionBuildSubscribers = new Array<Node3D>();
    Array<Vector3> vectors = new Array<Vector3>() 
    {
        new Vector3(-0.5f, 0, -0.5f) * 2, new Vector3(0.5f, 0, -0.5f) * 2, new Vector3(0.5f, 0, 0.5f) * 2,
        new Vector3(-0.5f, 0, -0.5f) * 2, new Vector3(0.5f, 0, 0.5f) * 2, new Vector3(-0.5f, 0, 0.5f) * 2,
    };

    public Surface Surface { get; set; }

    public float time = 0;

    public static SurfaceManager Instance()
    {
        if (instance == null)
        {
            instance = new SurfaceManager();
            SceneSwitcher.Instance().AddChild(instance);
            instance.Name = "SurfaceManager";
        }
        return instance;
    }

    public override void _Ready()
    {
        SurfaceMeshManager.Instance();
    }

    public override void _Process(double delta)
    {
        if (Surface == null)
        {
            return;
        } 

        Vector3[] collisions = new Vector3[CollisionBuildSubscribers.Count * 6];
        int count = 0;
        foreach (Node3D node in CollisionBuildSubscribers)
        {
            foreach (Vector3 v in vectors)
            {
                collisions[count++] = (v + new Vector3(node.GlobalPosition.X, QueryHeight(node.GlobalPosition + v), node.GlobalPosition.Z));
            }
        }

        ConcavePolygonShape3D ccs = Surface.collisionShape.Shape as ConcavePolygonShape3D;

        ccs.SetFaces(collisions);
    }

    public void SubscribeCollisionObject(Node3D node)
    {
        CollisionBlock cb = CollisionBlockScene.Instantiate<CollisionBlock>();
        SceneSwitcher.CurrentLevel.CallDeferred("add_child", cb);
        cb.SubscribeObject(node);
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="vec"></param>
    /// <param name="time_">when you want to get the height from. Absolute time value from beginning of calculation.</param>
    /// <returns></returns>
    public float QueryHeight(Vector3 vec, float _time = 0.0f)
    {
        float t = _time == 0.0f ? this.time : _time;
        Vector2 uv = (new Vector2(vec.X, vec.Z) + new Vector2(Plane_Radius / 2.0f, Plane_Radius / 2.0f)) / Plane_Radius;
        uv = uv * 20.0f + new Vector2(t, 0.1113f);
        //float f = PerlinDomainWarp(uv, SurfaceMeshManager.Instance().Seed);
        float f = Mathf.Sin(uv.X * 10.0f) * Mathf.Sin(t + uv.Y * 3.0f);

        return f * Noise_Scale;
    }


}
