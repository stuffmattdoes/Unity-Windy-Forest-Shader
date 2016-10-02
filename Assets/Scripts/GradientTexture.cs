using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class GradientTexture : MonoBehaviour {

	// Variables
	public enum GradientType {
		linear,
		radial
	};
	public GradientType gradientType = GradientType.linear;
	public Gradient gradientFill;
	[Range (0, 360)] public int angle = 0;

	private Material mat;

	// Use this for initialization
	void Start () {
		mat = GetComponent<Renderer> ().material;
	}

	void OnEnable () {
		mat = GetComponent<Renderer> ().material;
	}

	void OnValidate() {
		SetColors ();
	}

	void SetColors() {

		// Colors
		mat.SetColor ("_ColorTop", gradientFill.colorKeys[0].color);
		mat.SetColor ("_ColorMid", gradientFill.colorKeys[1].color);
		mat.SetColor ("_ColorBot", gradientFill.colorKeys[2].color);

		// Locations
		mat.SetFloat ("_Location0", gradientFill.colorKeys [0].time);
		mat.SetFloat ("_Location1", gradientFill.colorKeys [1].time);
		mat.SetFloat ("_Location2", gradientFill.colorKeys [2].time);

		// Angle
		mat.SetFloat("_Angle", angle);

	}

}
