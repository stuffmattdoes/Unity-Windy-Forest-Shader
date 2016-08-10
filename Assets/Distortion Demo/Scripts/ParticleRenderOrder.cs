using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ParticleRenderOrder : MonoBehaviour {

	public int renderOrder;

	// Use this for initialization
	void Start () {
	
		GetComponent<ParticleSystem>().GetComponent<Renderer>().sortingOrder = renderOrder;

	}

}
