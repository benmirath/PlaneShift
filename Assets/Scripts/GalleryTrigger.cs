using UnityEngine;
using System.Collections;

public class GalleryTrigger : MonoBehaviour {
	MeshRenderer renderer;
	Material mat;	
	float timer;
	Light light;

	bool active;
	// Use this for initialization
	void Start () {
		renderer = GetComponentInChildren<MeshRenderer> ();
		if (renderer != null) {
			mat = renderer.material;
		}
		light = GetComponentInChildren<Light> ();

		if (light != null) light.enabled = false;
//		enabled = false;
//		mat = GetComponentInChildren<Material> ();
	}
	
	// Update is called once per frame
	void Update () {
		if (active)
			timer += Time.deltaTime;
		else 
			timer -= (Time.deltaTime * 3);



		mat.SetFloat ("_Timer", Mathf.Max (0, timer));

	}

	void OnTriggerEnter (Collider hit) {

		if (hit.CompareTag ("Player") && mat != null) {
			timer = 0;
			active = true;
			if (light != null) light.enabled = true;
//			enabled = true;
		}
	}
	void OnTriggerExit (Collider hit) {
		if (hit.CompareTag ("Player")) {
//			enabled = false;
			mat.SetFloat ("_Timer", 0);
			active = false;
			if (light != null) light.enabled = false;
		}
	}
}
