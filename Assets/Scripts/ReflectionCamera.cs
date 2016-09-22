using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class ReflectionCamera : MonoBehaviour {

	// Variables
	[HideInInspector]
	[SerializeField]
	private Camera _camera;
	private int _downResFactor = 1;

	[SerializeField]
	[Range(0, 1)]
	private float _reflectionVisibility = 0;

	[SerializeField]
	[Range(0, 0.1f)]
	private float _reflectionMagnitude = 0;

	[SerializeField]
	FilterMode filterMode = FilterMode.Bilinear;

	public bool invertCameraX = false;
	public bool invertCameraY = false;

	private string _globalTextureName = "_GlobalRefractionTex";
	private string _globalVisibilityName = "_GlobalVisibility";
	private string _globalMagnitudeName = "_GlobalRefractionMag";

	void OnEnable() {

		// Refernce our camera
		_camera = GetComponent<Camera> ();

		GenerateRT();
		InvertCamera ();
	}

	void InvertCamera() {

		// Reset our camera matrix to avoid weird projection issues
		_camera.ResetWorldToCameraMatrix ();
		_camera.ResetProjectionMatrix ();
		Matrix4x4 mat = _camera.projectionMatrix;
		mat *= Matrix4x4.Scale(new Vector3(
			invertCameraX ? -1 : 1,
			invertCameraY ? -1 : 1,
			1)
		);
		_camera.projectionMatrix = mat;
	}

	public void VisibilityChange(float value) {
		_reflectionVisibility = value;
		Shader.SetGlobalFloat(_globalVisibilityName, _reflectionVisibility);
	}

	public void MagnitudeChange(float value) {
		_reflectionMagnitude = value;
		Shader.SetGlobalFloat(_globalMagnitudeName, _reflectionMagnitude);
	}

	// This function is called when the script is loaded or a value is changed in the inspector (Called in the editor only).
	void OnValidate() {
		Shader.SetGlobalFloat(_globalVisibilityName, _reflectionVisibility);
		Shader.SetGlobalFloat(_globalMagnitudeName, _reflectionMagnitude);
	}

	void GenerateRT () {

		// Destroy render texture if it already exists
		// This avoids memory leak in editor
		if (_camera.targetTexture != null) {
			RenderTexture temp = _camera.targetTexture;
			_camera.targetTexture = null;
			DestroyImmediate (temp);
		}

		_camera.targetTexture = new RenderTexture (_camera.pixelWidth >> _downResFactor, _camera.pixelHeight >> _downResFactor, 16);
		_camera.targetTexture.filterMode = filterMode;
		_camera.targetTexture.name = "Reflection RT";

		Shader.SetGlobalTexture (_globalTextureName, _camera.targetTexture);
		Shader.SetGlobalFloat(_globalVisibilityName, _reflectionVisibility);
		Shader.SetGlobalFloat(_globalMagnitudeName, _reflectionMagnitude);
	}

}
