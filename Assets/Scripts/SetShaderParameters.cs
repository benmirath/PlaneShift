using UnityEngine;
using System.Collections;

public class SetShaderParameters : MonoBehaviour {
	public Vector2 instanceSize;
	void Start () {
		Renderer rend = GetComponent<Renderer> ();
		if (rend != null) {
			rend.material.SetFloat ("_TileX", instanceSize.x);
			rend.material.SetFloat ("_TileY", instanceSize.y);
		
		}
	}

}
