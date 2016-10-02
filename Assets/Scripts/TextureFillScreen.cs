using UnityEngine;
using System.Collections;

public class TextureFillScreen : MonoBehaviour {

	// Variables
	[Range(0, 1)] public float texturePadding  = 0.5f;

	private Camera cam;
	private Vector2 frustumSize;
	private Vector2 screen;

	void Start() {
		cam = Camera.main;
		screen = new Vector2 (
			Screen.width,
			Screen.height
		);
		Resize ();
	}

	void Update() {
		if (screen.x != Screen.width) {
			Debug.Log ("Screen resolution change");

			Resize ();

			screen = new Vector2 (
				Screen.width,
				Screen.height
			);
		}
	}

	void Resize() {

		// Set the x,y position equal to our main camera
		transform.position = new Vector3 (
			cam.transform.position.x,
			cam.transform.position.y,
			transform.position.z
		);

		// Obtain the distance from our camera
		float distance = Mathf.Abs(cam.transform.position.z) + Mathf.Abs(transform.position.z);

		// Obtain our camera's frustum dimensions at this distance
		frustumSize.y = 2.0f * distance * Mathf.Tan(cam.fieldOfView * 0.5f * Mathf.Deg2Rad);
		frustumSize.x = frustumSize.y * cam.aspect;

		// Now scale our quad accordingly
		transform.localScale = new Vector3 (
			frustumSize.x + texturePadding,
			frustumSize.y + texturePadding,
			1
		);
	}

}
