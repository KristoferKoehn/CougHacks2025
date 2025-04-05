using Godot;
using System;
using System.Net.NetworkInformation;

public partial class Gimbals : Node3D
{
    [Export] Node3D cameraGimbal;
    [Export] SpringArm3D cameraArm;
    [Export] Node3D boardGimbal;
    public const float propellingForce = 50.0f;
    public const float jumpForce = 1000.0f;

    private float pitch = -45f;


    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        Input.MouseMode = Input.MouseModeEnum.Captured;
        SurfaceManager.Instance().CollisionBuildSubscribers.Add(this);
        if (!IsMultiplayerAuthority())
        {
            return;
        }
    }

    public override void _ExitTree()
    {
        SurfaceManager.Instance().CollisionBuildSubscribers.Remove(this);
    }

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
            boardGimbal.RotateY(Mathf.DegToRad(yawDelta));

            // Update pitch
            pitch += pitchDelta;
            pitch = Mathf.Clamp(pitch, -90, 90); // Clamp in degrees

            // Apply clamped pitch rotation
            Vector3 currentRotation = cameraArm.RotationDegrees;
            currentRotation.X = pitch;
            cameraArm.RotationDegrees = currentRotation;
        }
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(double delta)
    {
        if (!IsMultiplayerAuthority())
        {
            return;
        }
        cameraGimbal.GlobalPosition = this.GlobalPosition;
        boardGimbal.GlobalPosition = this.GlobalPosition;

        if (Input.IsActionJustPressed("ui_cancel"))
        {
            if (Input.MouseMode == Input.MouseModeEnum.Captured)
            {
                Input.MouseMode = Input.MouseModeEnum.Visible;
            }
            else
            {
                Input.MouseMode = Input.MouseModeEnum.Captured;
            }
        }

        Vector2 inputDir = Input.GetVector("left", "right", "forward", "backward").Normalized();
        if (inputDir != Vector2.Zero)
        {
            float inputYRotation = Mathf.Atan2(-inputDir.X, -inputDir.Y);
            boardGimbal.GlobalRotation = new Vector3(boardGimbal.GlobalRotation.X, cameraGimbal.GlobalRotation.Y + inputYRotation, boardGimbal.GlobalRotation.Z);
        }

        float angleScaleOnHeight = (boardGimbal.GlobalPosition.Y - SurfaceManager.Instance().QueryHeight(boardGimbal.GlobalPosition)) / 10.0f;
        if (angleScaleOnHeight > 1.0f)
        {
            angleScaleOnHeight = 1.0f;
        }
        if (angleScaleOnHeight < 0.0f)
        {
            angleScaleOnHeight = 0.0f;
        }
        angleScaleOnHeight = 1 - angleScaleOnHeight;

        float positiveZHeight = SurfaceManager.Instance().QueryHeight(boardGimbal.GlobalPosition + (boardGimbal.GlobalBasis * new Vector3(0, 0, -0.1f)));
        float negativeZHeight = SurfaceManager.Instance().QueryHeight(boardGimbal.GlobalPosition + (boardGimbal.GlobalBasis * new Vector3(0, 0, 0.1f)));
        float zDifference = positiveZHeight - negativeZHeight;
        float zRadians = Mathf.Atan2(zDifference / 2.0f, 0.1f) * angleScaleOnHeight;

        float positiveXHeight = SurfaceManager.Instance().QueryHeight(boardGimbal.GlobalPosition + (boardGimbal.GlobalBasis * new Vector3(0.1f, 0, 0)));
        float negativeXHeight = SurfaceManager.Instance().QueryHeight(boardGimbal.GlobalPosition + (boardGimbal.GlobalBasis * new Vector3(-0.1f, 0, 0)));
        float xDifference = positiveXHeight - negativeXHeight;
        float xRadians = Mathf.Atan2(xDifference / 2.0f, 0.1f) * angleScaleOnHeight;

        boardGimbal.GlobalRotation = new Vector3(zRadians, boardGimbal.GlobalRotation.Y, xRadians);
    }
}