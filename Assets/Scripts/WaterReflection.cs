using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class WaterReflection : MonoBehaviour {

	// Variables
	[SerializeField]
	[HideInInspector]
	private Camera _camera;
	private int _downResFactor = 1;

	[SerializeField]
	[Range(0, 1)]
	private float _refractionVisibility = 0;
	[SerializeField]
	[Range(0, 0.1f)]
	private float _refractionMagnitude = 0;

	private string _globalTextureName = "_GlobalRefractionTex";
	private string _globalVisibilityName = "_GlobalVisibility";
	private string _globalMagnitudeName = "_GlobalRefractionMag";

	public void VisibilityChange(float value) {
		_refractionVisibility = value;
		Shader.SetGlobalFloat(_globalVisibilityName, _refractionVisibility);
	}

	public void MagnitudeChange(float value) {
		_refractionMagnitude = value;
		Shader.SetGlobalFloat(_globalMagnitudeName, _refractionMagnitude);
	}

	void OnEnable() {
		GenerateRT();
		Shader.SetGlobalFloat(_globalVisibilityName, _refractionVisibility);
		Shader.SetGlobalFloat(_globalMagnitudeName, _refractionMagnitude);
	}

	// This function is called when the script is loaded or a value is changed in the inspector (Called in the editor only).
	void OnValidate() {
		Shader.SetGlobalFloat(_globalVisibilityName, _refractionVisibility);
		Shader.SetGlobalFloat(_globalMagnitudeName, _refractionMagnitude);
	}

	void GenerateRT() {
		_camera = GetComponent<Camera> ();

		// If our camera already has a reflection texture, destroy it to prevent memory leaks
		if (_camera.targetTexture != null) {
			RenderTexture temp = _camera.targetTexture;
			_camera.targetTexture = null;
			DestroyImmediate (temp);
		}

		_camera.targetTexture = new RenderTexture (_camera.pixelWidth, _camera.pixelHeight, 16);
		_camera.targetTexture.name = "Water Reflection Tex";

		// Set our newly-created render texture as a global texture that all our shaders have access to
		Shader.SetGlobalTexture (_globalTextureName, _camera.targetTexture);

//		Shader.SetGlobalFloat(_globalVisibilityName, _refractionVisibility);
//		Shader.SetGlobalFloat(_globalMagnitudeName, _refractionMagnitude);

	}
}
