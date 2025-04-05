using Godot;
using System;
using System.Net.NetworkInformation;

public partial class PlayerController : RigidBody3D
{
    [Export] Node3D cameraGimbal;
    [Export] CharacterBody3D player;
    public const float propellingForce = 50.0f;
    public const float jumpForce = 1000.0f;
    private float pitch = -45f;

    [Export] private float HorizontalMouseSensitivity = 0.2f;
    [Export] private float VerticalMouseSensitivity = 0.2f;
    [Export] private float ZoomedMouseSensitivityModifier = 0.5f;
    [Export] private float CameraScrollSensitivity = 0.25f;
    [Export] private float CameraScrollMaxIn = 4f;
    [Export] private float CameraScrollMaxOut = 10f;
    [Export] private float CameraZValue = 4f;
    [Export] private float CameraDefaultFOV = 75;
    [Export] private float CameraZoomedFOV = 40;
    private bool isZoomed = false;

    public override void _Ready()
    {
        Input.MouseMode = Input.MouseModeEnum.Captured;
        SurfaceManager.Instance().SubscribeCollisionObject(this);
        //if (!IsMultiplayerAuthority())
        //{
        //    return;
        //}

        if (!IsMultiplayerAuthority())
        {
            GetNode<Camera3D>("player/Gimbals/CameraGimbal/SpringArm3D/Camera3D").Current = false;
            return;
        }
        else
        {
            GetNode<Camera3D>("player/Gimbals/CameraGimbal/SpringArm3D/Camera3D").Current = true;
        }
    }


    public override void _Input(InputEvent @event)
    {
        if (!IsMultiplayerAuthority())
        {
            return;
        } 

            InputEventMouseMotion motion = @event as InputEventMouseMotion;
        if (motion != null && Input.MouseMode == Input.MouseModeEnum.Captured)
        {
            float hSensitivity = HorizontalMouseSensitivity;
            float vSensitivity = VerticalMouseSensitivity;

            if (isZoomed)
            {
                hSensitivity *= ZoomedMouseSensitivityModifier;
                vSensitivity *= ZoomedMouseSensitivityModifier;
            }

            float yawDelta = -motion.Relative.X * hSensitivity;
            float pitchDelta = -motion.Relative.Y * vSensitivity;

            // Apply horizontal rotation (yaw)
            cameraGimbal.RotateY(Mathf.DegToRad(yawDelta));

            // Update pitch
            pitch += pitchDelta;
            pitch = Mathf.Clamp(pitch, -90, 90); // Clamp in degrees

            // Apply clamped pitch rotation
            Vector3 currentRotation = cameraGimbal.RotationDegrees;
            GD.Print(currentRotation);
            currentRotation.X = pitch;
            cameraGimbal.RotationDegrees = currentRotation;
        }
    }


    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        if (!IsMultiplayerAuthority())
        {
            return;
        }
        player.GlobalPosition = this.GlobalPosition + new Vector3(0,-0.4f,0);

    }

    public override void _PhysicsProcess(double delta)
    {
        if (!IsMultiplayerAuthority())
        {
            return;
        }

        Vector3 force = Vector3.Zero;

        // Handle Jump.
        if (Input.IsActionJustPressed("ui_accept"))
        {
            force.Y = jumpForce;
            ApplyCentralForce(force);
        }

        Vector2 inputDir = Input.GetVector("left", "right", "forward", "backward");
        Vector3 direction = (cameraGimbal.GlobalBasis * new Vector3(inputDir.X, 0, -inputDir.Y)).Normalized();
        if (direction != Vector3.Zero)
        {
            force.X = direction.X * propellingForce;
            force.Z = direction.Z * propellingForce;
        }

        ApplyTorque(new Vector3(force.Z, 0, force.X));
    }
}