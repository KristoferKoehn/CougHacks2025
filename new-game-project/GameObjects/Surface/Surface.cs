using Godot;

public partial class Surface : MeshInstance3D
{

    [Export]
	Vector3 pos = Vector3.Zero;
    [Export]
    float time = 0;
    [Export]
    public CollisionShape3D collisionShape;

    public override void _Ready()
	{
        SurfaceManager.Instance().Surface = this;
        MaterialOverride.Set("shader_parameter/heightmap", SurfaceMeshManager.Instance().HeightMapRD);
        GetNode<CollisionShape3D>("StaticBody3D/CollisionShape3D");
    }

    public override void _Process(double delta)
	{
        time += (float)delta * SurfaceManager.Instance().Time_Scale;
        SurfaceManager.Instance().time = time;
        PlaneMesh mesh = Mesh as PlaneMesh;
        mesh.SubdivideDepth = (int)SurfaceManager.Instance().SubdivisionSize.Y;
        mesh.SubdivideWidth = (int)SurfaceManager.Instance().SubdivisionSize.X;
        MaterialOverride.Set("shader_parameter/PLANE_SIZE", (int)SurfaceManager.Instance().Plane_Radius);
        mesh.Size = new Vector2(SurfaceManager.Instance().Plane_Radius, SurfaceManager.Instance().Plane_Radius);
    }

}
