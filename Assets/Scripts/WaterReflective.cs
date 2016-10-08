using System;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode] // Make water live-update even when not in play mode
public class WaterReflective : MonoBehaviour {
	
	public bool disablePixelLights = true;
	public int textureSize = 256;
	public float clipPlaneOffset = 0.07f;
	public LayerMask reflectLayers = -1;

	private Dictionary<Camera, Camera> m_ReflectionCameras = new Dictionary<Camera, Camera>(); // Camera -> Camera table
	private RenderTexture m_ReflectionTexture;
	private int m_OldReflectionTextureSize;
	private static bool s_InsideWater;


	// This is called when it's known that the object will be rendered by some
	// camera. We render reflections and do other updates here.
	// Because the script executes in edit mode, reflections for the scene view
	// camera will just work!
	public void OnWillRenderObject() {
		if (!enabled
			|| !GetComponent<Renderer>()
			|| !GetComponent<Renderer>().sharedMaterial
			|| !GetComponent<Renderer>().enabled) {
			return;
		}

		Camera cam = Camera.current;

		if (!cam) {
			return;
		}

		// Safeguard from recursive water reflections.
		if (s_InsideWater) {
			return;
		}

		s_InsideWater = true;

		Camera reflectionCamera;
		CreateWaterObjects(cam, out reflectionCamera);

		// find out the reflection plane: position and normal in world space
		Vector3 pos = transform.position;
		Vector3 normal = transform.up;

		// Optionally disable pixel lights for reflection
		int oldPixelLightCount = QualitySettings.pixelLightCount;

		if (disablePixelLights) {
			QualitySettings.pixelLightCount = 0;
		}

		UpdateCameraModes(cam, reflectionCamera);

		// Render reflection if needed
		// Reflect camera around reflection plane
		float d = -Vector3.Dot(normal, pos) - clipPlaneOffset;
		Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);

		Matrix4x4 reflection = Matrix4x4.zero;
		CalculateReflectionMatrix(ref reflection, reflectionPlane);
		Vector3 oldpos = cam.transform.position;
		Vector3 newpos = reflection.MultiplyPoint(oldpos);
		reflectionCamera.worldToCameraMatrix = cam.worldToCameraMatrix * reflection;

		// Setup oblique projection matrix so that near plane is our reflection
		// plane. This way we clip everything below/above it for free.
		Vector4 clipPlane = CameraSpacePlane(reflectionCamera, pos, normal, 1.0f);
		reflectionCamera.projectionMatrix = cam.CalculateObliqueMatrix(clipPlane);

		reflectionCamera.cullingMask = ~(1 << 4) & reflectLayers.value; // never render water layer
		reflectionCamera.targetTexture = m_ReflectionTexture;
		bool oldCulling = GL.invertCulling;
		GL.invertCulling = !oldCulling;
		reflectionCamera.transform.position = newpos;
		Vector3 euler = cam.transform.eulerAngles;
		reflectionCamera.transform.eulerAngles = new Vector3(-euler.x, euler.y, euler.z);
		reflectionCamera.Render();
		reflectionCamera.transform.position = oldpos;
		GL.invertCulling = oldCulling;
		GetComponent<Renderer>().sharedMaterial.SetTexture("_ReflectionTex", m_ReflectionTexture);

		// Restore pixel light count
		if (disablePixelLights) {
			QualitySettings.pixelLightCount = oldPixelLightCount;
		}

		// Setup shader keywords based on water mode
		Shader.EnableKeyword("WATER_REFLECTIVE");
		s_InsideWater = false;
	}


	// Cleanup all the objects we possibly have created
	void OnDisable() {
		if (m_ReflectionTexture) {
			DestroyImmediate(m_ReflectionTexture);
			m_ReflectionTexture = null;
		}
		
		foreach (var kvp in m_ReflectionCameras) {
			DestroyImmediate((kvp.Value).gameObject);
		}
		m_ReflectionCameras.Clear();
	}


	// This just sets up some matrices in the material; for really
	// old cards to make water texture scroll.
	void Update() {
		if (!GetComponent<Renderer>()) {
			return;
		}
		
		Material mat = GetComponent<Renderer>().sharedMaterial;
		
		if (!mat) {
			return;
		}

//		Vector4 waveSpeed = mat.GetVector("_WaveSpeed");
//		float waveScale = mat.GetFloat("_WaveScale");
//		Vector4 waveScale4 = new Vector4(waveScale, waveScale, waveScale * 0.4f, waveScale * 0.45f);

		// Time since level load, and do intermediate calculations with doubles
//		double t = Time.timeSinceLevelLoad / 20.0;
//		Vector4 offsetClamped = new Vector4(
//			(float)Math.IEEERemainder(waveSpeed.x * waveScale4.x * t, 1.0),
//			(float)Math.IEEERemainder(waveSpeed.y * waveScale4.y * t, 1.0),
//			(float)Math.IEEERemainder(waveSpeed.z * waveScale4.z * t, 1.0),
//			(float)Math.IEEERemainder(waveSpeed.w * waveScale4.w * t, 1.0)
//		);

//		mat.SetVector("_WaveOffset", offsetClamped);
//		mat.SetVector("_WaveScale4", waveScale4);
	}

	void UpdateCameraModes(Camera src, Camera dest) {
		if (dest == null) {
			return;
		}
		// set water camera to clear the same way as current camera
		dest.clearFlags = src.clearFlags;
		dest.backgroundColor = src.backgroundColor;

		if (src.clearFlags == CameraClearFlags.Skybox) {
			Skybox sky = src.GetComponent<Skybox>();
			Skybox mysky = dest.GetComponent<Skybox>();

			if (!sky || !sky.material) {
				mysky.enabled = false;
			}
			else {
				mysky.enabled = true;
				mysky.material = sky.material;
			}
		}
		// update other values to match current camera.
		// even if we are supplying custom camera&projection matrices,
		// some of values are used elsewhere (e.g. skybox uses far plane)
		dest.farClipPlane = src.farClipPlane;
		dest.nearClipPlane = src.nearClipPlane;
		dest.orthographic = src.orthographic;
		dest.fieldOfView = src.fieldOfView;
		dest.aspect = src.aspect;
		dest.orthographicSize = src.orthographicSize;
	}


	// On-demand create any objects we need for water
	void CreateWaterObjects(Camera currentCamera, out Camera reflectionCamera) {

		reflectionCamera = null;
		
		// Reflection render texture
		if (!m_ReflectionTexture
			|| m_OldReflectionTextureSize != textureSize) {
			
			if (m_ReflectionTexture) {
				DestroyImmediate(m_ReflectionTexture);
			}
			
			m_ReflectionTexture = new RenderTexture(textureSize, textureSize, 16);
			m_ReflectionTexture.name = "__WaterReflection" + GetInstanceID();
			m_ReflectionTexture.isPowerOfTwo = true;
			m_ReflectionTexture.hideFlags = HideFlags.DontSave;
			m_OldReflectionTextureSize = textureSize;
		}

		// Camera for reflection
		m_ReflectionCameras.TryGetValue(currentCamera, out reflectionCamera);
		
		// catch both not-in-dictionary and in-dictionary-but-deleted-GO
		if (!reflectionCamera) {
			GameObject go = new GameObject("Water Refl Camera id" + GetInstanceID() + " for " + currentCamera.GetInstanceID(), typeof(Camera), typeof(Skybox));
			reflectionCamera = go.GetComponent<Camera>();
			reflectionCamera.enabled = false;
			reflectionCamera.transform.position = transform.position;
			reflectionCamera.transform.rotation = transform.rotation;
			reflectionCamera.gameObject.AddComponent<FlareLayer>();
			go.hideFlags = HideFlags.HideAndDontSave;
			m_ReflectionCameras[currentCamera] = reflectionCamera;
		}

	}

	// Given position/normal of the plane, calculates plane in camera space.
	Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign) {
		Vector3 offsetPos = pos + normal * clipPlaneOffset;
		Matrix4x4 m = cam.worldToCameraMatrix;
		Vector3 cpos = m.MultiplyPoint(offsetPos);
		Vector3 cnormal = m.MultiplyVector(normal).normalized * sideSign;
		return new Vector4(cnormal.x, cnormal.y, cnormal.z, -Vector3.Dot(cpos, cnormal));
	}

	// Calculates reflection matrix around the given plane
	static void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane) {
		reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
		reflectionMat.m01 = (- 2F * plane[0] * plane[1]);
		reflectionMat.m02 = (- 2F * plane[0] * plane[2]);
		reflectionMat.m03 = (- 2F * plane[3] * plane[0]);

		reflectionMat.m10 = (- 2F * plane[1] * plane[0]);
		reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
		reflectionMat.m12 = (- 2F * plane[1] * plane[2]);
		reflectionMat.m13 = (- 2F * plane[3] * plane[1]);

		reflectionMat.m20 = (- 2F * plane[2] * plane[0]);
		reflectionMat.m21 = (- 2F * plane[2] * plane[1]);
		reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
		reflectionMat.m23 = (- 2F * plane[3] * plane[2]);

		reflectionMat.m30 = 0F;
		reflectionMat.m31 = 0F;
		reflectionMat.m32 = 0F;
		reflectionMat.m33 = 1F;
	}
}
