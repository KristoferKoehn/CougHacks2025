using Godot;
using System;

public partial class SurfaceMeshManager : Node
{

    private static SurfaceMeshManager instance = null;
    string test = "";
    [Export] bool stop_processing = false;
    public static SurfaceMeshManager Instance()
    {
        if (instance == null)
        {
            instance = new SurfaceMeshManager();
            SceneSwitcher.Instance().AddChild(instance);
            instance.Name = "SurfaceMeshManager";
        }
        return instance;
    }

    RenderingDevice rd;
    Rid buffer = new Rid();
    byte[] inputBytes;

    RDTextureFormat fmt;
    public Texture2Drd HeightMapRD;
    public Rid SurfaceHeightmap;
    Sprite2D sp;


    float[] input;

    public Surface sfc;


    public override void _Ready()
    {
        rd = RenderingServer.GetRenderingDevice();
        inputBytes = new byte[32];
        buffer = rd.StorageBufferCreate((uint)1024 * 1024 * 4);
        fmt = new RDTextureFormat();
        fmt.Format = RenderingDevice.DataFormat.R16Sfloat;
        fmt.Width = 1024;
        fmt.Height = 1024;
        fmt.UsageBits = RenderingDevice.TextureUsageBits.StorageBit | 
                        RenderingDevice.TextureUsageBits.SamplingBit | 
                        RenderingDevice.TextureUsageBits.CanCopyToBit | 
                        RenderingDevice.TextureUsageBits.CanCopyFromBit |
                        RenderingDevice.TextureUsageBits.ColorAttachmentBit |
                        RenderingDevice.TextureUsageBits.CanUpdateBit;

        SurfaceHeightmap = rd.TextureCreate(fmt, new RDTextureView());
        rd.TextureClear(SurfaceHeightmap, new Color(0,1,0,0), 0, 1 , 0 , 1);
        HeightMapRD = new Texture2Drd();
        HeightMapRD.TextureRdRid = SurfaceHeightmap;

    }


    public override void _Process(double delta)
    {

        if (stop_processing)
        {
            return;
        }
        // Create a local rendering device.
        // Load GLSL shader
        var shaderFile = GD.Load<RDShaderFile>("res://Compute/SurfaceCompute.glsl");
        var shaderBytecode = shaderFile.GetSpirV();
        var shader = rd.ShaderCreateFromSpirV(shaderBytecode);
        // Prepare our data. We use floats in the shader, so we need 32 bit.
        input = [1024f, 1024f, SurfaceManager.Instance().Seed, SurfaceManager.Instance().time, SurfaceManager.Instance().Noise_Scale, 0, 0, 0];

        Buffer.BlockCopy(input, 0, inputBytes, 0, inputBytes.Length);

        // Create a uniform to assign the buffer to the rendering device
        var uniformA = new RDUniform
        {
            UniformType = RenderingDevice.UniformType.Image,
            Binding = 0
            
        };
        uniformA.AddId(SurfaceHeightmap);

        var uniformSet = rd.UniformSetCreate([uniformA], shader, 0); //this causes element limit reach, free afterwards?
        // Create a compute pipeline
        var pipeline = rd.ComputePipelineCreate(shader);
        var computeList = rd.ComputeListBegin();
        rd.ComputeListBindComputePipeline(computeList, pipeline);
        rd.ComputeListBindUniformSet(computeList, uniformSet, 0);
        rd.ComputeListSetPushConstant(computeList, inputBytes, (uint)inputBytes.Length);
        rd.ComputeListDispatch(computeList, xGroups: 64, yGroups: 64, zGroups: 1);
        rd.ComputeListEnd();

        rd.FreeRid(uniformSet);
        rd.FreeRid(pipeline);
        rd.FreeRid(shader);
       
    }
}
